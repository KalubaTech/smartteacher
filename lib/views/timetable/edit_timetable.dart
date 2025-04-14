import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';

import '../../helpers/data_prefetch.dart';

class EditTimetable extends StatefulWidget {
  final TimetableItem item;
  EditTimetable(this.item);

  @override
  _EditTimetableState createState() => _EditTimetableState();
}

class _EditTimetableState extends State<EditTimetable> {
  final MyClassesController _myClassesController = Get.find();
  final TeacherController _teacherController = Get.find();

  var day = 'Monday'.obs;
  var classname = ''.obs;
  var subject = ''.obs;
  var start = TimeOfDay(hour: 9, minute: 0).obs;
  var stop = TimeOfDay(hour: 17, minute: 0).obs;
  var isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  Future<void> _prefillData() async {
    try {
      var ttiData = await FirebaseFirestore.instance
          .collection('timetable')
          .doc(widget.item.data.split(',').first)
          .get();

      if (ttiData.exists) {
        day.value = ttiData.get('day');
        classname.value = ttiData.get('class');
        subject.value = ttiData.get('subject');

        List<String> startParts = ttiData.get('starttime').split(':');
        start.value = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );

        List<String> stopParts = ttiData.get('stoptime').split(':');
        stop.value = TimeOfDay(
          hour: int.parse(stopParts[0]),
          minute: int.parse(stopParts[1]),
        );
      }
    } catch (e) {
      print("Error fetching timetable data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: start.value,
    );
    if (picked != null && picked != start.value) {
      start.value = picked;
    }
  }

  Future<void> _selectStopTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: stop.value,
    );
    if (picked != null && picked != stop.value) {
      stop.value = picked;
    }
  }

  void _updateTimetable() {
    var docId = widget.item.data.split(',').first;

    var updatedData = {
      'day': day.value,
      'starttime': '${start.value.hour.toString().padLeft(2, '0')}:${start.value.minute.toString().padLeft(2, '0')}',
      'stoptime': '${stop.value.hour.toString().padLeft(2, '0')}:${stop.value.minute.toString().padLeft(2, '0')}',
      'subject': subject.value,
      'class': classname.value,
      'teacher': _teacherController.teacher.first.uid
    };

    FirebaseFirestore.instance.collection('timetable').doc(docId).update(updatedData).then((_) {
      Get.snackbar(
        "Updated",
        "Timetable item updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }).catchError((error) {
      Get.snackbar(
        "Error",
        "Failed to update timetable item: $error",
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Timetable Item',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading.value
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: [
          SizedBox(height: 20),
          DropdownSearch<String>(
            items: (e,r)=> ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
            selectedItem: day.value,
            onChanged: (value) => day.value = value!,
            popupProps: const PopupProps.menu(fit: FlexFit.loose),
          ),
          SizedBox(height: 20),
          DropdownSearch<String>(
            items: (e,r)=> _myClassesController.myclasses.map((c) => c.name).toList(),
            selectedItem: classname.value,
            onChanged: (value) => classname.value = value!,
            popupProps: const PopupProps.menu(fit: FlexFit.loose),
          ),
          SizedBox(height: 20),
          Obx(
                () => FutureBuilder(
                future: DataPrefetch().fetchMySubjects(
                    _teacherController.teacher.first.uid,
                    '${_myClassesController.myclasses.value.where((c)=>c.name==classname.value).isNotEmpty
                        ?_myClassesController.myclasses.value.where((c)=>c.name==classname.value).first.uid:
                    ''
                    }',
                    _teacherController.teacher.first.school
                ),
                builder: (context, s) {
                  return DropdownSearch<String>(
                    items: (a,b)=> [
                      ...s.hasData?s.data!.map((subject)=>subject.subject.name)
                          .toList():['']
                    ],
                    selectedItem: subject.value,
                    onChanged: (value) {
                      if (value != null) {
                        subject.value = value;
                      }
                    },
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                    ),
                    popupProps: const PopupProps.menu(fit: FlexFit.loose),
                  );
                }
            ),
          ),
          SizedBox(height: 20),
          // Add Start Time Selection
          InkWell(
            onTap: _selectStartTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Time: ${start.value.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.edit, color: Colors.grey),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          // Add Stop Time Selection
          InkWell(
            onTap: _selectStopTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stop Time: ${stop.value.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.edit, color: Colors.grey),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateTimetable,
            child: const Text('Update'),
          ),
          SizedBox(height: 20),
        ],
      ),
    ));
  }
}