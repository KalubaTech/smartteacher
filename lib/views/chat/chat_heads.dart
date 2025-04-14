import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/chat/chat.dart';

import '../../controllers/teacher_controller.dart';
import '../../models/parrent_model.dart';

class TeacherChatHeads extends StatelessWidget {
  TeacherChatHeads({super.key});

  final TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    final teacherId = _teacherController.teacher.value.first.uid;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Get.to(() => SearchParent(), transition: Transition.leftToRight);
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Karas.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Messaging',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('teacher', isEqualTo: teacherId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No messages yet',
                style: GoogleFonts.gabarito(fontSize: 16),
              ),
            );
          }

          // Group messages by parent and get the most recent one for each
          final messages = snapshot.data!.docs;
          final Map<String, QueryDocumentSnapshot> latestMessages = {};

          for (var message in messages) {
            final parentId = message['parent'] as String;
            if (!latestMessages.containsKey(parentId)) {
              latestMessages[parentId] = message;
            }
          }

          return ListView.builder(
            itemCount: latestMessages.length,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            itemBuilder: (context, index) {
              final parentId = latestMessages.keys.elementAt(index);
              final chatDoc = latestMessages[parentId]!;
              final data = chatDoc.data() as Map<String, dynamic>;

              final message = data['message'] ?? '';
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();
              final isRead = data['read'] ?? false;
              final isSender = data['sender'] == teacherId;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('parents')
                    .doc(parentId)
                    .get(),
                builder: (context, parentSnapshot) {
                  if (!parentSnapshot.hasData) {
                    return _buildLoadingTile(message, timestamp);
                  }

                  if (!parentSnapshot.data!.exists) {
                    return _buildUnknownUserTile(message, timestamp);
                  }

                  final parentData = parentSnapshot.data!.data() as Map<String, dynamic>;
                  final parentName = parentData['fullname'] ?? 'Unknown Parent';
                  final parentAvatar = parentData['photo'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: parentAvatar != null
                          ? NetworkImage(parentAvatar)
                          : null,
                      child: parentAvatar == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(parentName,
                      style: GoogleFonts.gabarito(
                        fontWeight: FontWeight.bold,
                        color: isRead ? Colors.black : Karas.primary,
                      ),
                    ),
                    subtitle: Text(
                      isSender ? 'You: $message' : message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.gabarito(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_formatTime(timestamp)),
                        if (!isRead && !isSender)
                          const Icon(Icons.circle, size: 10, color: Colors.green),
                      ],
                    ),
                    onTap: () {
                      // Mark as read if it's a received message
                      if (!isRead && !isSender) {
                        chatDoc.reference.update({'read': true});
                      }

                      ParentModel _parent = ParentModel(
                        uid: parentId,
                        fullname: parentData['fullname'],
                        email: parentData['email'],
                        phone: parentData['phone'],
                        photo: parentData['photo'],
                      );

                      // Navigate to chat screen
                      Get.to(() => TeacherChatScreen(
                        parent: _parent,
                      ));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingTile(String message, DateTime timestamp) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text('Loading...', style: GoogleFonts.gabarito()),
      subtitle: Text(message),
      trailing: Text(_formatTime(timestamp)),
    );
  }

  Widget _buildUnknownUserTile(String message, DateTime timestamp) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text('Unknown Parent', style: GoogleFonts.gabarito()),
      subtitle: Text(message),
      trailing: Text(_formatTime(timestamp)),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDay = DateTime(time.year, time.month, time.day);

    if (messageDay == today) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDay == yesterday) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}