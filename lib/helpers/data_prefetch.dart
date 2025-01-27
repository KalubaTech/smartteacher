import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/my_subject_model.dart';
import 'package:smart_teacher/models/province_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/models/school_model.dart';
import 'package:smart_teacher/models/subject_model.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:get/get.dart';

import '../controllers/my_subjects_controller.dart';

class DataPrefetch{
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  MyClassesController _myClassesController = Get.find();
  MySubjectsController _mySubjectsController = Get.find();

  Future<List<SchoolModel>>fetchSchoolsByDistrict(district)async{
    print(district);
    List<SchoolModel> schools = [];

    var data = await _firebaseFirestore.collection('schools').where('district', isEqualTo: district).get();

    if(data.docs.isNotEmpty){
      for(var doc in data.docs){
          SchoolModel _school = SchoolModel(
              uid: doc.id,
              name: doc.get('name'),
              district: doc.get('district'),
              province: doc.get('province')
          );
          schools.add(_school);
      }
    }

    return schools;
  }
  Future<List<ProvinceModel>>fetchProvinces()async{
    List<ProvinceModel> provinces = [];

    try{
      var data = await _firebaseFirestore.collection('provinces').get();

      if(data.docs.isNotEmpty){
        for(var doc in data.docs){
          ProvinceModel province =
          ProvinceModel(
              province: doc.get('province').toString(),
              districts: doc.get('districts')
          );

          provinces.add(province);
        }
      }
      print(provinces);
    }catch(error){
      print(error);
    }

    return provinces;
  }

  Future<TeacherModel>getTeacherByUid(uid)async{
    TeacherModel? _teacher;
    var data = await _firebaseFirestore.collection('teachers')
    .doc(uid).get();
    if(data.exists){
      var doc = data;
      _teacher = TeacherModel(
          uid: doc.id,
          firstname: doc.get('firstname'),
          lastname: doc.get('lastname'),
          email: doc.get('email'),
          phone: doc.get('phone'),
          password: doc.get('password'),
          school: doc.get('school'),
          photo: doc.get('photo')
      );
    }
    return _teacher!;
  }

  Future<List<ClassModel>>getClassesBySchool(schoolid)async{
    List<ClassModel>classes = [];

    var data = await _firebaseFirestore.collection('classes').where('school', isEqualTo: schoolid).get();

    if(data.docs.isNotEmpty){
      for(var doc in data.docs){
        ClassModel _class = ClassModel(
            uid: doc.id,
            name: doc.get('name'),
            school: schoolid
        );

        classes.add(_class);
      }
    }

    return classes;
  }

  void getMyClasses(teacher)async{
    List<ClassModel> classes = [];

    var data = await _firebaseFirestore.collection('teacher_class').where('teacher', isEqualTo: teacher).get();

    if(data.docs.isNotEmpty){
      for(var doc in data.docs){
        var dat = await _firebaseFirestore.collection('classes').doc(doc.get('class')).get();
        if(dat.exists){
          ClassModel classModel = ClassModel(uid: dat.id, name: dat.get('name'), school: dat.get('school'));
          classes.add(classModel);
        }
      }
    }

    _myClassesController.myclasses.value = classes;
    _myClassesController.update();
  }

  Future<List<PupilModel>>fetchPupils(classid)async{
    List<PupilModel>pupils=[];

    var data = await _firebaseFirestore.collection('pupils').where('class', isEqualTo: classid).get();

    if(data.docs.isNotEmpty){
       for(var doc in data.docs){
          PupilModel pupilModel = PupilModel(
              uid: doc.id, 
              firstname: doc.get('firstname'),
              lastname: doc.get('lastname'),
              classid: doc.get('class'),
              intake: doc.get('intake'),
              gender: doc.get('gender')
          );

          pupils.add(pupilModel);
       }
    }

    return pupils;

  }
  Future<List<SubjectModel>>fetchClassSubjects(school)async{
    List<SubjectModel>subjects=[];
    try{
      var data = await _firebaseFirestore.collection('subjects')
          .where('school', isEqualTo: school)
          .get();

      if(data.docs.isNotEmpty){
        for(var doc in data.docs){
          SubjectModel subjectModel = SubjectModel(
            uid: doc.id,
            name: doc.get('name'),
          );

          subjects.add(subjectModel);
        }
      }

    }catch(e){
     // print(e);
    }
    return subjects;

  }

  Future<List<MySubjectModel>>fetchMySubjects(teacher,classid, school)async{
    List<MySubjectModel> subjects = [];
    try{
      //print(teacher);
      //print(classid);
      var data = await _firebaseFirestore.collection('teacher_subject_class').where('teacher', isEqualTo: teacher).where('class', isEqualTo: classid).get();
      var allSubjects = await fetchClassSubjects(school);

     // print(allSubjects.length);

      if(data.docs.isNotEmpty){
        for(var doc in data.docs){
         // print(doc.get('subject'));

          SubjectModel subject = allSubjects.where((sub)=>sub.uid==doc.get('subject')).first;
          MySubjectModel mysub = MySubjectModel(
              subject: subject,
              teacherid: teacher,
              classid: classid);

          subjects.add(mysub);
        }
      }

      _mySubjectsController.mysubjects.value = subjects;
      _mySubjectsController.update();

     // print("HELLO ${subjects.length}");
    }catch(e){
      //print(e);
    }

    return subjects;
  }

}