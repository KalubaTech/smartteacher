import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docman/docman.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/timetable_model.dart';
import 'package:smart_teacher/views/auth_screens/sign_in_with_google.dart';
import 'package:smart_teacher/views/documents/lesson_plans/lesson_plans.dart';

import '../services/auth_service.dart';

class CommonMethods{

  MySubscriptionController _mySubscriptionController = Get.find();
  TimetableController _timetableController = Get.find();

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  TeacherController _teacherController = Get.find();

  void addPupil(String fname, String lname, String gender, String intake, String classid, school)async{


    Map<String, dynamic>data = {
      'firstname':fname,
      'lastname':lname,
      'gender':gender,
      'intake':[intake],
      'class':[classid],
      'school':school
    };

    _firebaseFirestore.collection('pupils').add(data);
    Fluttertoast.showToast(msg: 'Added successfully');
    Get.back();
  }

  void addSubject(subject, teacher, classid, school){
    var data = {
      'name':subject,
      'school':school
    };

    _firebaseFirestore.collection('subjects').add(data)
        .then((sData){
          var tscData = {
            'subject':sData.id,
            'teacher':teacher,
            'class':classid
          };
          _firebaseFirestore.
          collection('teacher_subject_class').
          add(tscData);
          Get.back();
        });
  }

  Future<List<File>> pickFiles() => DocMan.pick.files(extensions: ['pdf', '.doc', 'docx']);

  String timeToWords(String time) {
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    List<String> result = [];

    if (hours > 0) result.add("$hours hour${hours > 1 ? 's' : ''}");
    if (minutes > 0) result.add("$minutes minute${minutes > 1 ? 's' : ''}");
    if (seconds > 0) result.add("$seconds second${seconds > 1 ? 's' : ''}");

    return result.join(" ");
  }
  
  String timediffInWords(String starttime, String stoptime){
    // Define the two times
    TimeOfDay startTime = TimeOfDay(hour: int.parse(starttime.split(':').first), minute: int.parse(starttime.split(':').last));
    TimeOfDay endTime = TimeOfDay(hour: int.parse(stoptime.split(':').first), minute: int.parse(stoptime.split(':').last));

    // Convert the times to DateTime objects
    DateTime startDateTime = DateTime(2024, 1, 1, startTime.hour, startTime.minute);
    DateTime endDateTime = DateTime(2024, 1, 1, endTime.hour, endTime.minute);

    // Calculate the difference
    Duration difference = endDateTime.difference(startDateTime);
    
    return timeToWords(difference.toString().split('.').first);
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    String formatted = '';
    if (hours > 0) formatted += '$hours hour${hours > 1 ? 's' : ''} ';
    if (minutes > 0) formatted += '$minutes minute${minutes > 1 ? 's' : ''} ';
    if (seconds > 0) formatted += '$seconds second${seconds > 1 ? 's' : ''}';

    return formatted.trim();
  } 

  Map<int, String> romanMap = {
    1000: "M", 900: "CM", 500: "D", 400: "CD",
    100: "C", 90: "XC", 50: "L", 40: "XL",
    10: "X", 9: "IX", 5: "v", 4: "iv", 1: "i"
  };

// Roman fraction approximation
  Map<double, String> romanFractions = {
    0.5: "S",    // Semis (½)
    0.25: "•",   // Quadrans (¼)
    0.75: "¾",   // Three quadrans (¾)
  };

  String toRomanNumerals(double number) {
    int integerPart = number.floor();
    double decimalPart = number - integerPart;

    String romanInteger = "";
    int temp = integerPart;

    // Convert integer part to Roman numerals
    for (var value in romanMap.keys) {
      while (temp >= value) {
        romanInteger += romanMap[value]!;
        temp -= value;
      }
    }

    // Convert decimal part (if exists)
    String romanDecimal = "";
    if (decimalPart > 0) {
      double closestFraction = romanFractions.keys.reduce((a, b) =>
      (decimalPart - a).abs() < (decimalPart - b).abs() ? a : b);
      romanDecimal = romanFractions[closestFraction] ?? "";
    }

    return romanInteger + (romanDecimal.isNotEmpty ? ".$romanDecimal" : "");
  }

  Future<void>saveLessonPlan(Map<String, dynamic>data)async{
    await _firebaseFirestore.collection('lesson_plans').add(data);
    Get.defaultDialog(
        content: Column(
          children: [
            const CircleAvatar(child: Icon(Icons.download_done)),
            const SizedBox(height: 10),
            const Text('Saved successfully!'),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  Get.off(()=>LessonPlans());
                },
                child: const Text('Close'))
          ],
        ),
        title: '',
        barrierDismissible: false
    );
  }

  int calculateRamainingDays(DateTime startdate, DateTime enddate){
    int remainingDays = enddate.difference(startdate).inDays;

    return remainingDays;
  }

  int planDays(String plan){
    switch(plan){
      case 'per month':
        return 30;
      case 'per term':
        return 30 * 3;
      case 'per year':
        return 365;
      default:
        return 3;
    }
  }

  deactivateSubscription(String teacher)async{
    var mysub = _mySubscriptionController.getCurrentSub();

    if(mysub!=null){
      if(calculateRamainingDays(DateTime.now(), mysub.expiry_date)<1){
        _firebaseFirestore.collection('current_subscription').doc(mysub.uid).update({'isActive':false}).then((d){
          DataPrefetch().fetchMySubscription(teacher);
        });
      }
    }
  }

  List<TimetableModel>todaysTimetable(){
    var days = ['', 'monday', 'tuesday', 'wednesday','thursday','friday', 'saturday', 'sunday'];

    var todayIndex = DateTime.now().weekday;

     //print(days[todayIndex]);

    return _timetableController.timetable.where((tt){
     //print(todayIndex);
      return tt.day.toLowerCase() == days[todayIndex];
    }).toList();

  }

  List<TimetableModel> getTimetablesBeforeStartTime() {
    // Get the current time
    DateTime now = DateTime.now();

    // Filter timetables that are yet to start
    List<TimetableModel> filteredTimetables = todaysTimetable().where((timetable) {
      // Parse the start time string into a DateTime object
      DateTime startTime = _parseTimeString(timetable.starttime);

      // Compare the start time with the current time
      return startTime.isAfter(now);
    }).toList();

    return filteredTimetables;
  }

  DateTime _parseTimeString(String timeString) {
    // Assuming timeString is in the format "HH:mm"
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    // Get today's date with the parsed time
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  getCollabos(classid)async{
    var req_data = await _firebaseFirestore.collection('collabo').where('class', isEqualTo: classid).get();


  }

  requestCollabos(classid, teacherid)async{

    var req_data = await _firebaseFirestore.collection('collabo').where('class', isEqualTo: classid).get();

    if(req_data.docs.isNotEmpty){
      return;
    }

    var data = {
      'class': classid,
      'teachers': [],
      'teacherid': teacherid
    };

    _firebaseFirestore.collection('collabo').add(data);

    Fluttertoast.showToast(msg: 'You have request results collaboration!');

  }

  acceptCollabo(uid,List teachers)async{
    _firebaseFirestore.collection('collabo').doc(uid).update({'teachers':teachers});

    Fluttertoast.showToast(msg: 'Accepted successfully!');
  }
  cancelCollabo(uid, teacher)async{
    //_firebaseFirestore.collection('collabo').doc(uid).update({'teachers':teachers});

    Fluttertoast.showToast(msg: 'Cancelled successfully!');
  }



  //delete user
  Future<void> deleteUser(String uid) async {
    List<String> collections = [
      'timetable',
      'teacher_subject_class',
      'teacher_class',
      'results',
      'lesson_plans',
      'current_subscription'
    ];

    try {
      for (String collection in collections) {
        // Query documents where teacher == uid
        QuerySnapshot querySnapshot = await _firebaseFirestore
            .collection(collection)
            .where('teacher', isEqualTo: uid)
            .get();

        // Delete each document found
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await _firebaseFirestore.collection(collection).doc(doc.id).delete();
        }
      }

      await _firebaseFirestore.collection('teachers').doc(uid).delete();
      await AuthService().signOut();
    } catch (e) {
      print("Error deleting user data: $e");
    }
  }

}