import 'package:flutter/material.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/views/timetable/add_timetable.dart';
import 'package:get/get.dart';
import '../../helpers/data_prefetch.dart';
import '../page_anchor.dart';

class PresetTimetable extends StatelessWidget {
  PresetTimetable({super.key});

  TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    DataPrefetch().getMyClasses(_teacherController.teacher.first.uid);
    return Scaffold(
      bottomSheet: Container(
        color: Colors.white,
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                onPressed: (){
                  Get.offAll(()=>PageAnchor(), transition: Transition.fade);
                },
                child: Text('Finish')
            )
          ],
        ),
      ),
      body: AddTimetable(),
    );
  }
}
