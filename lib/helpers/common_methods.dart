import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docman/docman.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/models/subject_model.dart';

class CommonMethods{
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void addPupil(String fname, String lname, String gender, String intake, String classid)async{
    Map<String, dynamic>data = {
      'firstname':fname,
      'lastname':lname,
      'gender':gender,
      'intake':intake,
      'class':classid
    };

    _firebaseFirestore.collection('pupils').add(data);
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

}