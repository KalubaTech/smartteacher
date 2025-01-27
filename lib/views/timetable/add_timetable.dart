import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';

class AddTimetable extends StatelessWidget {
  AddTimetable({super.key});

  MyClassesController _myClassesController = Get.find();

  TeacherController _teacherController = Get.find();

  var day = 'Monday'.obs;
  var classname = 'Class'.obs;
  var subject = 'Subject'.obs;
  var start = TimeOfDay(hour: 9, minute: 0).obs;
  var stop = TimeOfDay(hour: 17, minute: 0).obs;

  Future<void> _selectTime(BuildContext context, Rx<TimeOfDay> time) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time.value,
      initialEntryMode: TimePickerEntryMode.inputOnly
    );
    if (picked != null && picked != time.value) {
      time.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Your Timetable',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          SizedBox(height: 20,),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                  color: Colors.green,
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(
                      () => DropdownSearch<String>(
                        items: (a,b)=> [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                            ],
                    selectedItem: day.value,
                    onChanged: (value) {
                      if (value != null) {
                        day.value = value;
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
                    popupProps: const PopupProps.menu(
                      fit: FlexFit.loose
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                  color: Colors.orange,
                ),
                child: const Icon(
                  Icons.timelapse,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(
                      () => InkWell(
                    onTap: () => _selectTime(context, start),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Start: ${start.value.format(context)}',
                        style: GoogleFonts.gabarito(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(
                      () => InkWell(
                    onTap: () => _selectTime(context, stop),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stop: ${stop.value.format(context)}',
                        style: GoogleFonts.gabarito(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Divider(color: Colors.grey.shade100,),
          Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      color: Colors.cyan,
                    ),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                          () => DropdownSearch<String>(
                        items: (a,b)=> [
                          ..._myClassesController.myclasses.value.map((c)=>c.name).toList()
                        ],
                        selectedItem: classname.value,
                        onChanged: (value) {
                          if (value != null) {
                            classname.value = value;
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      color: Colors.cyan,
                    ),
                    child: const Icon(
                      Icons.subject,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
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
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              var data = {
                'day':day.value,
                'starttime':'${start.value.hour<10?'0${start.value.hour}':start.value.hour}:${start.value.minute<10?'0${start.value.minute}':start.value.minute}',
                'stoptime':'${stop.value.hour<10?'0${stop.value.hour}':stop.value.hour}:${stop.value.minute<10?'0${stop.value.minute}':stop.value.minute}',
                'subject':subject.value,
                'class':classname.value,
                'teacher':_teacherController.teacher.first.uid
              };
              FirebaseFirestore.instance.collection('timetable').add(data);
              Get.snackbar(
                "Timetable Added",
                "Day: ${day.value}, Start: ${start.value.format(context)}, Stop: ${stop.value.format(context)}",
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Save Timetable'),
          ),
        ],
      ),
    );
  }
}
