import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/timetable/add_timetable.dart';
import '../../utils/colors.dart';

class Timetable extends StatelessWidget {
  const Timetable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: () {
          Get.to(()=>AddTimetable(), transition: Transition.fade);
        },
        child: Icon(Icons.add, color: Colors.white,),
        //params
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/empty-folder.png'),
      ),
    );
  }
}
