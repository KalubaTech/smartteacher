import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/utils/colors.dart';
import '../../controllers/teacher_controller.dart';

class NoticeBoard extends StatefulWidget {
  const NoticeBoard({super.key});

  @override
  State<NoticeBoard> createState() => _NoticeBoardState();
}

class _NoticeBoardState extends State<NoticeBoard> {
  final TeacherController _teacherController = Get.find();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final RxList<String> _selectedTargets = <String>[].obs;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final CardSwiperController _cardController = CardSwiperController();

  final List<String> targetOptions = ['teachers', 'parents', 'pupils', 'all'];

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> saveNotice(String subject, String body) async {
    try {
      await FirebaseFirestore.instance.collection('notice_board').add({
        'subject': subject,
        'body': body,
        'targets': _selectedTargets,
        'datetime': FieldValue.serverTimestamp(),
        'school': _teacherController.teacher.first.school,
        'teacher': _teacherController.teacher.first.uid,
      });
      Get.back();
      //Get.snackbar('Success', 'Notice published successfully');

      if(_selectedTargets.contains('parents') || _selectedTargets.contains('all')){
        //send notifications to parents
        CommonMethods().sendParentNotifications(
            _teacherController.teacher.first.school,
            'New announcement', body);

        CommonMethods().addNotification(
            title: 'New Announcement',
            message: 'The following announcement was added: ${body}',
            senderName: '${_teacherController.teacher.first.firstname.capitalize}',
            senderId: '${_teacherController.teacher.first.uid}',
            targets: _selectedTargets.value);
      }

      if(_selectedTargets.contains('teachers') || _selectedTargets.contains('all')){
        //send notifications to parents
        CommonMethods().sendTeacherNotifications(
            _teacherController.teacher.first.school,
            'New announcement (${_teacherController.teacher.first.firstname}):',
            subject,
            _teacherController.teacher.first.uid);

      }


    } catch (e) {
      Get.snackbar('Error', 'Failed to publish notice');
    }
  }

  Future<void> _editNotice(String docId, String newSubject, String newBody) async {
    try {
      await FirebaseFirestore.instance.collection('notice_board').doc(docId).update({
        'subject': newSubject,
        'body': newBody,
        'datetime': FieldValue.serverTimestamp(),
      });
      Get.back();
      Get.snackbar('Success', 'Notice updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update notice');
    }
  }

  Future<void> _deleteNotice(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('notice_board').doc(docId).delete();
      Get.back();
      Get.snackbar('Success', 'Notice deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete notice');
    }
  }

  Widget _buildNoticeCard(DocumentSnapshot doc) {
    final notice = doc.data() as Map<String, dynamic>;
    final date = notice['datetime'] != null
        ? (notice['datetime'] as Timestamp).toDate()
        : DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM').format(date);
    final isCurrentTeacher = notice['teacher'] == _teacherController.teacher.first.uid;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: Colors.grey,
          )
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.50, 0.51, 1.0],
          colors: [
            Color.fromRGBO(255, 183, 107, 1),
            Color.fromRGBO(255, 167, 61, 1),
            Color.fromRGBO(255, 124, 0, 1),
            Color.fromRGBO(255, 127, 4, 1),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isCurrentTeacher)
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Text('Details'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'details') {
                          _showNoticeDetails(notice);
                        } else if (value == 'edit') {
                          _showEditDialog(doc.id, notice);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(doc.id);
                        }
                      },
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  '${notice['subject']?.toString().toUpperCase() ?? 'NO SUBJECT'}',
                  style: GoogleFonts.gabarito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Text(
                    notice['body']?.toString() ?? '',
                    style: GoogleFonts.almarai(fontSize: 16),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 16),
                    Text('  $formattedDate', style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    const Icon(Icons.remove_red_eye),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(Map<String, dynamic> notice) {
    final date = notice['datetime'] != null
        ? (notice['datetime'] as Timestamp).toDate()
        : DateTime.now();
    final formattedDate = DateFormat('EEE, d MMM yyyy - hh:mm a').format(date);
    final targets = (notice['targets'] as List<dynamic>?)?.join(', ') ?? '';

    Get.defaultDialog(
      title: 'Notice Details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject: ${notice['subject'] ?? ''}'),
          const SizedBox(height: 10),
          Text('Message: ${notice['body'] ?? ''}'),
          const SizedBox(height: 10),
          Text('Date: $formattedDate'),
          const SizedBox(height: 10),
          Text('Targets: $targets'),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> notice) {
    final editSubjectController = TextEditingController(text: notice['subject']);
    final editBodyController = TextEditingController(text: notice['body']);

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'Edit Notice',
              style: GoogleFonts.gabarito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: editSubjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: editBodyController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (editSubjectController.text.isEmpty || editBodyController.text.isEmpty) {
                    Get.snackbar('Error', 'Subject and message cannot be empty');
                    return;
                  }
                  _editNotice(docId, editSubjectController.text, editBodyController.text);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String docId) {
    Get.defaultDialog(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10
      ),
      title: 'Delete Notice',
      middleText: 'Are you sure you want to delete this notice?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () {
        _deleteNotice(docId);
      },
    );
  }

  Widget _buildComposeForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compose Notice',
              style: GoogleFonts.gabarito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Target Audience',
              style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: targetOptions.map((target) {
                return Obx(() {
                  final isSelected = _selectedTargets.contains(target);
                  return FilterChip(
                    label: Text(target.capitalizeFirst!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _selectedTargets.add(target);
                      } else {
                        _selectedTargets.remove(target);
                      }
                    },
                  );
                });
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_subjectController.text.isEmpty ||
                      _bodyController.text.isEmpty ||
                      _selectedTargets.isEmpty) {
                    Get.snackbar('Required', 'Please fill all fields');
                    return;
                  }
                  saveNotice(_subjectController.text, _bodyController.text);
                },
                child: const Text('Publish Notice'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Karas.primary,
        foregroundColor: Colors.white,
        leadingWidth: 30,
        centerTitle: true,
        title: Text(
          'Notice Board',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _subjectController.clear();
          _bodyController.clear();
          _selectedTargets.clear();
          Get.bottomSheet(
            Container(
              height: Get.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: _buildComposeForm(),
            ),
            isScrollControlled: true,
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notice_board')
            .where('school', isEqualTo: _teacherController.teacher.first.school)
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
                  const Icon(Icons.announcement, size: 50, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No notices available',
                    style: GoogleFonts.gabarito(fontSize: 18),
                  ),
                  Text(
                    'Tap the + button to create one',
                    style: GoogleFonts.gabarito(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: CardSwiper(
                  controller: _cardController,
                  cardsCount: notices.length,
                  onSwipe: (i,j,d){
                    //print(j);
                    return true;
                  },
                  cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                    return _buildNoticeCard(notices[index]);
                  },
                  backCardOffset: const Offset(10, 15),
                  scale: 0.97,
                  numberOfCardsDisplayed: notices.length > 3 ? 3 : notices.length,
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}