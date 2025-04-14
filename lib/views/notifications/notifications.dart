import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/utils/colors.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final TeacherController _teacherController = Get.find();
  late String _teacherId;

  @override
  void initState() {
    super.initState();
    _teacherId = _teacherController.teacher.value.first.uid;
  }

  Future<void> _markAsSeen(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'seenIds': FieldValue.arrayUnion([_teacherId])
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as seen');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'deletedIds': FieldValue.arrayUnion([_teacherId])
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Karas.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('targets', arrayContains: 'teachers')
            .where('deletedIds', whereNotIn: [[_teacherId]])
            .orderBy('datetime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No notifications',
                    style: GoogleFonts.gabarito(fontSize: 18),
                  ),
                  Text(
                    'You\'ll see new notifications here',
                    style: GoogleFonts.gabarito(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deletedIds = data['deletedIds'] as List<dynamic>? ?? [];
            return !deletedIds.contains(_teacherId);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final seenIds = data['seenIds'] as List<dynamic>? ?? [];
              final isSeen = seenIds.contains(_teacherId);

              final date = data['datetime'] != null
                  ? (data['datetime'] as Timestamp).toDate()
                  : DateTime.now();
              final formattedDate = DateFormat('MMM d, y • h:mm a').format(date);

              // Mark as seen when viewed
              if (!isSeen) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markAsSeen(doc.id);
                });
              }

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await Get.defaultDialog(
                    title: 'Delete Notification',
                    middleText: 'Are you sure you want to delete this notification?',
                    textConfirm: 'Delete',
                    textCancel: 'Cancel',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back(result: true);
                    },
                  );
                },
                onDismissed: (direction) {
                  _deleteNotification(doc.id);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSeen ? Colors.white : Colors.blue[50],
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(data['senderName']?.toString().substring(0, 1) ?? '?'),
                    ),
                    title: Text(
                      data['title']?.toString() ?? 'No title',
                      style: GoogleFonts.gabarito(
                        fontWeight: isSeen ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['notification']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle notification tap (e.g., navigate to related content)
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}