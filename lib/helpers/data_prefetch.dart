import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/my_school_controller.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/schools_controoler.dart';
import 'package:smart_teacher/controllers/subscription_plans_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/my_subject_model.dart';
import 'package:smart_teacher/models/my_subscription.dart';
import 'package:smart_teacher/models/province_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/models/school_model.dart';
import 'package:smart_teacher/models/subject_model.dart';
import 'package:smart_teacher/models/subscription_model.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/models/timetable_model.dart';

import '../controllers/my_subjects_controller.dart';

class DataPrefetch{
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  MyClassesController _myClassesController = Get.find();
  MySubjectsController _mySubjectsController = Get.find();
  MySchoolController _mySchoolController = Get.find();
  SubscriptionPlansController _subscriptionPlansController = Get.find();
  MySubscriptionController _mySubscriptionController = Get.find();
  TimetableController _timetableController = Get.find();


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
              province: doc.get('province'),
              type: doc.get('type'),
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
          photo: doc.get('photo'), 
          isAdmin: doc.get('isAdmin')
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

  Future<List<PupilModel>>fetchPupils(schoolid)async{

    List<PupilModel>pupils=[];

    var data = await _firebaseFirestore.collection('pupils').where('school', isEqualTo: schoolid).get();

    if(data.docs.isNotEmpty){
       for(var doc in data.docs){
          PupilModel pupilModel = PupilModel(
              uid: doc.id,
              firstname: doc.get('firstname'),
              lastname: doc.get('lastname'),
              classid: doc.get('class'),
              intake: doc.get('intake'),
              gender: doc.get('gender'), 
              email: doc.get('email'), 
              photo: doc.get('photo')
          );

          pupils.add(pupilModel);
       }
    }

    return pupils;

  }
  Future<List<PupilModel>>fetchClassPupils(classid,schoolid)async{
    List<PupilModel>pupils=[];

    var data = await _firebaseFirestore.collection('pupils').where('school', isEqualTo: schoolid).get();

    if(data.docs.isNotEmpty){
      for(var doc in data.docs){
        PupilModel pupilModel = PupilModel(
            uid: doc.id,
            firstname: doc.get('firstname'),
            lastname: doc.get('lastname'),
            classid: doc.get('class'),
            intake: doc.get('intake'),
            gender: doc.get('gender'),
            email: doc.get('email'), 
            photo: doc.get('photo')
        );

        pupils.add(pupilModel);
      }
    }

    return pupils;

  }
  Future<PupilModel>fetchPupil(id)async{
    var data = await _firebaseFirestore.collection('pupils').doc(id).get();

    return PupilModel(
        uid: data.id,
        firstname: data.get('firstname'),
        classid: data.get('class'),
        gender: data.get('gender'),
        intake: data.get('intake'),
        lastname: data.get('lastname'),
       email: data.get('email'), 
        photo: data.get('photo')
    );
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
  Future<SchoolModel>fetchSchool(schoolid)async{

    SchoolModel _school = SchoolModel(uid: '', name: '', district: '', province: '', type: '');
    try{
      //print(teacher);
      //print(classid);
      var data = await _firebaseFirestore.collection('schools').doc(schoolid).get();
 
      if(data.exists){
        _school =  SchoolModel(
            uid: '${data.id}',
            name: '${data.get('name')}',
            district: '${data.get('district')}',
            province: '${data.get('province')}',
            type: '${data.get('type')}',
        );
        _mySchoolController.myschool.value = _school;

      }
      
     // print("HELLO ${subjects.length}");
    }catch(e){
      //print(e);
    }

    return _school;
  }

  fetchSubscriptionPlans()async{

    List<SubscriptionModel> subs = [];

    try{
      //print(teacher);
      //print(classid);
      var data = await _firebaseFirestore.collection('subscription_plans').get();

      if(data.docs.isNotEmpty){

         for(var doc in data.docs){
           subs.add(SubscriptionModel.fromJson(doc.data()));
         }


      }

      _subscriptionPlansController.sub_plans.value = subs;
      _subscriptionPlansController.update();

      // print("HELLO ${subjects.length}");
    }catch(e){
      //print(e);
    }

  }
  fetchMySubscription(teacher)async{
    var data = await _firebaseFirestore.collection('current_subscription').where('teacher', isEqualTo: teacher).get();

    List<MySubscription> _mysubmodel = [];

    try{
      if(data.docs.isNotEmpty){
        for(var doc in data.docs){

          var sub = MySubscription(
              plan: doc.get('plan'),
              amount: doc.get('amount'),
              dateTime: DateTime.parse(doc.get('dateTime')),
              isActive: doc.get('isActive'),
              expiry_date: DateTime.parse(doc.get('expiry_date')),
              uid: doc.id
          );

          _mysubmodel.add(sub);
        }

        _mySubscriptionController.my_subscription.value = _mysubmodel;
        _mySubscriptionController.update();

        print(_mysubmodel);
      }
    }catch(e){
      print(e);
    }

  }

  fetchMyTimetable(teacher)async{
    var data = await _firebaseFirestore.collection('timetable').where('teacher', isEqualTo: teacher).get();
    List<TimetableModel> mytimetables = [];

    
    if(data.docs.isNotEmpty){
      for(var doc in data.docs){
        TimetableModel ttm = TimetableModel(
            classname: doc.get('class'), 
            subject: doc.get('subject'), 
            duration: CommonMethods().timediffInWords(doc.get('starttime'), doc.get('stoptime')),
            day: doc.get('day'), 
            starttime: doc.get('starttime'), 
            stoptime: doc.get('stoptime')
        );

        mytimetables.add(ttm);
      }

      _timetableController.timetable.value = mytimetables;
      _timetableController.update();
    }
  }
  Future<List<MySubjectModel>>fetchAllMySubjects(teacher, school)async{
    List<MySubjectModel> subjects = [];
    try{
      //print(teacher);
      //print(classid);
      var data = await _firebaseFirestore.collection('teacher_subject_class').where('teacher', isEqualTo: teacher).get();
      var allSubjects = await fetchClassSubjects(school);

      // print(allSubjects.length);

      if(data.docs.isNotEmpty){
        for(var doc in data.docs){
          // print(doc.get('subject'));

          SubjectModel subject = allSubjects.where((sub)=>sub.uid==doc.get('subject')).first;
          MySubjectModel mysub = MySubjectModel(
              subject: subject,
              teacherid: teacher,
              classid: doc.get('class'));

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