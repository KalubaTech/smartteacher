import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/utils/colors.dart';
import '../../controllers/teacher_controller.dart';

class CreateMeetingPage extends StatefulWidget {
  const CreateMeetingPage({super.key});

  @override
  State<CreateMeetingPage> createState() => _CreateMeetingPageState();
}

class _CreateMeetingPageState extends State<CreateMeetingPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final List<String> _selectedParticipants = [];
  String _selectedRole = 'teacher';
  String? _selectedParticipantType = 'teachers';
  DateTime? _selectedDateTime;
  bool _selectAllTeachers = false;
  bool _selectAllParents = false;
  bool _selectAllPupils = false;
  final TeacherController _teacherController = Get.find();

  @override
  void dispose() {
    _subjectController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _initMeeting() async {
    if (_subjectController.text.isEmpty ||
        (_selectedParticipants.isEmpty &&
            !_selectAllTeachers &&
            !_selectAllParents &&
            !_selectAllPupils) ||
        _selectedDateTime == null) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    try {
      final meetingData = {
        'initiator': _teacherController.teacher.first.uid,
        'initiatorRole': _selectedRole,
        'subject': _subjectController.text,
        'room': _roomController.text.isNotEmpty
            ? _roomController.text
            : 'room_${DateTime.now().millisecondsSinceEpoch}',
        'school': _teacherController.teacher.first.school,
        'scheduled_datetime': _selectedDateTime,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'scheduled',
      };

      if (_selectAllTeachers) {
        meetingData['all_teachers'] = true;
      } else if (_selectAllParents) {
        meetingData['all_parents'] = true;
      } else if (_selectAllPupils) {
        meetingData['all_pupils'] = true;
      } else {
        meetingData['participants'] = _selectedParticipants;
      }

      await FirebaseFirestore.instance.collection('meetings').add(meetingData);

      Get.back();
      Get.snackbar('Success', 'Meeting created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create meeting: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Karas.primary,
        foregroundColor: Colors.white,
        title: const Text('Schedule Meeting'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20
        ),
        shrinkWrap: true,
        children: [
          // Meeting Subject
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Meeting Subject*',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Custom Room ID (optional)
          TextField(
            controller: _roomController,
            decoration: const InputDecoration(
              labelText: 'Custom Room ID (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Schedule DateTime
          const Text('Meeting Date & Time*', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _selectDateTime(context),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                    _selectedDateTime != null
                        ? CommonMethods().formatDateTime(_selectedDateTime!)
                        : 'Select Date & Time',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Participant Type Selection
          const Text('Select Participant Type:', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                vertical: 10
              ),
              shrinkWrap: true,
              children: [
                Radio<String>(
                  value: 'teachers',
                  groupValue: _selectedParticipantType,
                  onChanged: (value) {
                    setState(() {
                      _selectedParticipantType = value;
                      _selectedParticipants.clear();
                      _selectAllTeachers = false;
                    });
                  },
                ),
                const Text('Teachers'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'parents',
                  groupValue: _selectedParticipantType,
                  onChanged: (value) {
                    setState(() {
                      _selectedParticipantType = value;
                      _selectedParticipants.clear();
                      _selectAllParents = false;
                    });
                  },
                ),
                const Text('Parents'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'pupils',
                  groupValue: _selectedParticipantType,
                  onChanged: (value) {
                    setState(() {
                      _selectedParticipantType = value;
                      _selectedParticipants.clear();
                      _selectAllPupils = false;
                    });
                  },
                ),
                const Text('Pupils'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Select All Checkboxes
          if (_selectedParticipantType == 'teachers') ...[
            CheckboxListTile(
              title: const Text('Select All Teachers'),
              value: _selectAllTeachers,
              onChanged: (value) {
                setState(() {
                  _selectAllTeachers = value!;
                  if (!_selectAllTeachers) {
                    _selectedParticipants.clear();
                  }
                });
              },
            ),
          ] else if (_selectedParticipantType == 'parents') ...[
            CheckboxListTile(
              title: const Text('Select All Parents'),
              value: _selectAllParents,
              onChanged: (value) {
                setState(() {
                  _selectAllParents = value!;
                  if (!_selectAllParents) {
                    _selectedParticipants.clear();
                  }
                });
              },
            ),
          ] else if (_selectedParticipantType == 'pupils') ...[
            CheckboxListTile(
              title: const Text('Select All Pupils'),
              value: _selectAllPupils,
              onChanged: (value) {
                setState(() {
                  _selectAllPupils = value!;
                  if (!_selectAllPupils) {
                    _selectedParticipants.clear();
                  }
                });
              },
            ),
          ],
          const SizedBox(height: 10),

          // Participants Selection
          _buildParticipantSelector(),
          const SizedBox(height: 20),

          // Selected Participants
          if (_selectedParticipants.isNotEmpty) ...[
            const Text('Selected Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _selectedParticipants.map((id) {
                return Chip(
                  label: FutureBuilder<DocumentSnapshot>(
                    future: _selectedParticipantType == 'teachers'
                        ? FirebaseFirestore.instance.collection('teachers').doc(id).get()
                        : _selectedParticipantType == 'parents'
                        ? FirebaseFirestore.instance.collection('parents').doc(id).get()
                        : FirebaseFirestore.instance.collection('pupils').doc(id).get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        if (data != null) {
                          final name = _selectedParticipantType == 'teachers'
                              ? '${data['firstname'] ?? ''} ${data['lastname'] ?? ''}'
                              : _selectedParticipantType == 'parents'
                              ? data['fullname'] ?? 'Parent'
                              : '${data['firstname'] ?? ''} ${data['lastname'] ?? ''}';
                          return Text(name.trim().isEmpty ? 'Unknown' : name);
                        }
                      }
                      return const Text('Loading...');
                    },
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedParticipants.remove(id);
                      if (_selectedParticipantType == 'teachers') {
                        _selectAllTeachers = false;
                      } else if (_selectedParticipantType == 'parents') {
                        _selectAllParents = false;
                      } else if (_selectedParticipantType == 'pupils') {
                        _selectAllPupils = false;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _initMeeting,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Karas.primary,
              ),
              child: const Text('Schedule Meeting', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantSelector() {
    final schoolId = _teacherController.teacher.first.school;

    switch (_selectedParticipantType) {
      case 'teachers':
        return _buildTeacherSelector(schoolId);
      case 'parents':
        return _buildParentSelector(schoolId);
      case 'pupils':
        return _buildPupilSelector(schoolId);
      default:
        return Container();
    }
  }

  Widget _buildTeacherSelector(String schoolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teachers')
          .where('school', isEqualTo: schoolId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final teachers = snapshot.data!.docs.where((doc) =>
        doc.id != _teacherController.teacher.first.uid).toList();

        if (teachers.isEmpty) {
          return const Text('No other teachers found in this school');
        }

        if (_selectAllTeachers && teachers.isNotEmpty) {
          final allTeacherIds = teachers.map((doc) => doc.id).toList();
          final selectedSet = _selectedParticipants.toSet();
          final allTeacherSet = allTeacherIds.toSet();

          if (selectedSet.length != allTeacherSet.length || !selectedSet.containsAll(allTeacherSet)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedParticipants
                  ..clear()
                  ..addAll(allTeacherIds);
              });
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Teachers:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                final teacherData = teacher.data() as Map<String, dynamic>?;
                final firstName = teacherData?['firstname'] ?? '';
                final lastName = teacherData?['lastname'] ?? '';
                final teacherName = '$firstName $lastName'.trim();

                return CheckboxListTile(
                  title: Text(teacherName.isEmpty ? 'Unknown Teacher' : teacherName),
                  value: _selectedParticipants.contains(teacher.id),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedParticipants.add(teacher.id);
                        _selectAllTeachers = false;
                      } else {
                        _selectedParticipants.remove(teacher.id);
                      }
                    });
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildParentSelector(String schoolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('parent-child')
          .where('school', isEqualTo: schoolId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final parentIds = <String>{};
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('parent')) {
            parentIds.add(data['parent'] as String);
          }
        }

        if (parentIds.isEmpty) {
          return const Text('No parents found for this school');
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('parents')
              .where(FieldPath.documentId, whereIn: parentIds.toList())
              .get(),
          builder: (context, parentSnapshot) {
            if (!parentSnapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final parents = parentSnapshot.data!.docs;

            if (parents.isEmpty) {
              return const Text('No parent details available');
            }

            if (_selectAllParents && parents.isNotEmpty) {
              final allParentIds = parents.map((doc) => doc.id).toList();
              final selectedSet = _selectedParticipants.toSet();
              final allParentSet = allParentIds.toSet();

              if (selectedSet.length != allParentSet.length || !selectedSet.containsAll(allParentSet)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _selectedParticipants
                      ..clear()
                      ..addAll(allParentIds);
                  });
                });
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Parents:', style: TextStyle(fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: parents.length,
                  itemBuilder: (context, index) {
                    final parent = parents[index];
                    final parentData = parent.data() as Map<String, dynamic>?;
                    final fullname = parentData?['fullname'] ?? 'Unknown Parent';

                    return CheckboxListTile(
                      title: Text(fullname),
                      value: _selectedParticipants.contains(parent.id),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedParticipants.add(parent.id);
                            _selectAllParents = false;
                          } else {
                            _selectedParticipants.remove(parent.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPupilSelector(String schoolId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pupils')
          .where('school', isEqualTo: schoolId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final pupils = snapshot.data!.docs;

        if (pupils.isEmpty) {
          return const Text('No pupils found in this school');
        }

        if (_selectAllPupils && pupils.isNotEmpty) {
          final allPupilIds = pupils.map((doc) => doc.id).toList();
          final selectedSet = _selectedParticipants.toSet();
          final allPupilSet = allPupilIds.toSet();

          if (selectedSet.length != allPupilSet.length || !selectedSet.containsAll(allPupilSet)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedParticipants
                  ..clear()
                  ..addAll(allPupilIds);
              });
            });
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Pupils:', style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pupils.length,
              itemBuilder: (context, index) {
                final pupil = pupils[index];
                final pupilData = pupil.data() as Map<String, dynamic>?;
                final firstName = pupilData?['firstname'] ?? '';
                final lastName = pupilData?['lastname'] ?? '';
                final pupilName = '$firstName $lastName'.trim();

                return CheckboxListTile(
                  title: Text(pupilName.isEmpty ? 'Unknown Pupil' : pupilName),
                  value: _selectedParticipants.contains(pupil.id),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedParticipants.add(pupil.id);
                        _selectAllPupils = false;
                      } else {
                        _selectedParticipants.remove(pupil.id);
                      }
                    });
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}