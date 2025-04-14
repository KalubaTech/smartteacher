import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/models/timetable_model.dart';
import 'package:smart_teacher/utils/colors.dart';

class OnlineClasses extends StatefulWidget {
  const OnlineClasses({super.key});

  @override
  State<OnlineClasses> createState() => _OnlineClassesState();
}

class _OnlineClassesState extends State<OnlineClasses> {
  final TeacherController _teacherController = Get.find();
  final TimetableController _timetableController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  TimetableModel? _selectedPeriod;
  final _meetingLinkController = TextEditingController();
  final _additionalNotesController = TextEditingController();
  String _roomId = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _meetingLinkController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Karas.background,
        title: Text('Online Classes', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _roomId = _generateRandomRoomId();
          });
          _showSetupBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: _buildClassList(),
    );
  }

  Widget _buildClassList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('online_classes')
          .where('teacher', isEqualTo: _teacherController.teacher.first.uid)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No online classes scheduled yet',
              style: GoogleFonts.gabarito(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            return _buildClassCard(data, doc);
          },
        );
      },
    );
  }

  Widget _buildClassCard(Map<String, dynamic> data, doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['subject'],
                  style: GoogleFonts.gabarito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(data['class']),
                  backgroundColor: Karas.primary.withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${data['day']} • ${data['time']}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Text(
              'Room ID: ${data['room']}',
              style: GoogleFonts.gabarito(fontWeight: FontWeight.w500),
            ),
            if (data['notes'] != null && data['notes'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${data['notes']}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.notifications_active, size: 18, color: Colors.white,),
                    label: const Text('Alert pupils', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Karas.info,
                    ),
                    onPressed: () {

                    },
                  ),
                ),
                SizedBox(width: 10,),
                IconButton(
                  icon: const Icon(Icons.video_call, size: 28, color: Colors.white,),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    backgroundColor: Karas.danger,
                  ),
                  onPressed: () {
                    CommonMethods().joinMeeting(
                      room: '${data['room']}',
                      subject: '${data['class']} - ${data['subject']} class',
                      userDisplayName: '${_teacherController.teacher.value.first.firstname}',
                      userAvatarURL: '${_teacherController.teacher.value.first.photo}',
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteClass(doc.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteClass(String docId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Class', style: GoogleFonts.gabarito()),
        content: const Text('Are you sure you want to delete this online class?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _firestore.collection('online_classes').doc(docId).delete();
                Get.snackbar(
                  'Deleted',
                  'Online class removed successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete class: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _generateRandomRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _showInfoDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Online Classes', style: GoogleFonts.gabarito()),
        content: const Text(
          'Schedule online classes by selecting a period from your timetable. '
              'A unique meeting link will be automatically generated for each class.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSetupBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 5,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Schedule Online Class',
                  style: GoogleFonts.gabarito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Timetable Period Selection
                DropdownButtonFormField<TimetableModel>(
                  decoration: InputDecoration(
                    labelText: 'Select Period',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: _selectedPeriod,
                  items: _timetableController.timetable.map((period) {
                    return DropdownMenuItem<TimetableModel>(
                      value: period,
                      child: Text(
                        '${period.day}: ${period.subject} (${period.starttime} - ${period.stoptime}) - ${period.classname}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a period';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Room ID Display
                TextFormField(
                  initialValue: _roomId,
                  decoration: InputDecoration(
                    labelText: 'Room ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _roomId = _generateRandomRoomId();
                        });
                      },
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Meeting Link: https://smart-classroom.com/join/$_roomId',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Additional Notes
                TextFormField(
                  controller: _additionalNotesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Karas.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _scheduleOnlineClass,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Schedule Class',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _scheduleOnlineClass() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final onlineClassDetails = {
          'room': _roomId,
          'subject': _selectedPeriod!.subject,
          'class': _selectedPeriod!.classname,
          'day': _selectedPeriod!.day,
          'time': '${_selectedPeriod!.starttime} - ${_selectedPeriod!.stoptime}',
          'notes': _additionalNotesController.text,
          'teacher': _teacherController.teacher.first.uid,
          'teacher_name': _teacherController.teacher.first.firstname,
          'school': _teacherController.teacher.first.school,
          'created_at': DateTime.now(),
          'formatted_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        };

        await _firestore.collection('online_classes').add(onlineClassDetails);

        Get.back();
        Get.snackbar(
          'Success',
          'Online class scheduled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        setState(() {
          _selectedPeriod = null;
          _additionalNotesController.clear();
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          'Failed to schedule class: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}