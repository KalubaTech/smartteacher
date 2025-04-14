import 'package:get_storage/get_storage.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_teacher/views/auth_screens/pro_register.dart';
import 'package:smart_teacher/views/page_anchor.dart';

class AuthHelper{

  TeacherController _teacherController = Get.find();

  FirebaseFirestore _fs = FirebaseFirestore.instance;

  Future<bool>signUp({required TeacherModel teacher})async{
    try{
      //get teachers from fs
      var _teachersData = await _fs.collection('teachers').where('email', isEqualTo: teacher.email).get();

      bool isRegistered = _teachersData.docs.isNotEmpty;

      if(!isRegistered){
           Map<String, dynamic>data = {
             'uid':teacher.uid,
             'firstname':teacher.firstname,
             'lastname':teacher.lastname,
             'email':teacher.email,
             'phone':teacher.phone,
             'password':teacher.password,
             'photo':teacher.photo,
             'isAdmin': teacher.isAdmin,
             'school':''
           };
          var doc = await _fs.collection('teachers').add(data);

           teacher = TeacherModel(
               uid: doc.id,
               firstname: teacher.firstname,
               lastname: teacher.lastname,
               email: teacher.email,
               phone: teacher.phone,
               password: teacher.password,
               photo: teacher.photo,
               school: teacher.school,
               isAdmin: false
           );
           _teacherController.teacher.value.add(teacher);
           _teacherController.update();
           Get.offAll(()=>ProRegister());
      }else{
         teacher = TeacherModel(
             uid: _teachersData.docs.first.id,
             firstname: _teachersData.docs.first.get('firstname'),
             lastname: _teachersData.docs.first.get('lastname'),
             email: _teachersData.docs.first.get('email'),
             phone: _teachersData.docs.first.get('phone'),
             password: _teachersData.docs.first.get('password'),
             photo: _teachersData.docs.first.get('photo'),
             school: _teachersData.docs.first.get('school'),
             isAdmin: _teachersData.docs.first.get('isAdmin') //Get.offAll(()=>ProRegister());
         );

        _teacherController.teacher.value.add(teacher);
        _teacherController.update();

        if(_teacherController.teacher.value.first.school == ''){
          Get.offAll(()=>ProRegister());
        }else{
          Get.offAll(()=>PageAnchor(), transition: Transition.fadeIn);
        }
      }

      GetStorage().write('user', teacher.uid);

      return true;
    }catch(error){
      print("ERROR----->${error}");
      return false;
    }
  }

  Future<bool>signIn(String email, String password)async{
    try{
      TeacherModel teacherModel = _teacherController.teacher.where((teacher)=>teacher.email==email && password == teacher.password).first;
      //SIGN IN PROCESS
      return true;
    }catch(e){
      return false;
    }
  }

  //SIGN IN WITH FINGERPRINT
  void signInWithFingerPrint(uid)async{
    var teacher = await DataPrefetch().getTeacherByUid(uid);
    DataPrefetch().getMyClasses(teacher.uid);
    _teacherController.teacher.add(teacher);
    _teacherController.update();

    if(teacher.school==''){
      Get.offAll(()=>ProRegister(), transition: Transition.fadeIn);
    }else{
      Get.offAll(()=>PageAnchor(), transition: Transition.fadeIn);
    }

  }

  Future<TeacherModel>registerWithEmailAndPassword(String name, String email, String password)async{
    TeacherModel _teacher = TeacherModel(
        uid: '',
        firstname: '',
        lastname: '',
        email: '',
        phone: '',
        password: '',
        school: '',
        isAdmin: false);

    try{
      var data = {
        'firstname': name,
        'lastname': '',
        'email': email,
        'phone': '',
        'password': password,
        'school': ''
      };
      DocumentReference d = await _fs.collection('teachers').add(data);

      // Fetch the added document
      DocumentSnapshot docSnapshot = await d.get();

      // Create TeacherModel from the document data
      _teacher = TeacherModel(
        uid: docSnapshot.id,
        firstname: docSnapshot['firstname'], // Access fields from the document
        lastname: docSnapshot['lastname'],
        email: docSnapshot['email'],
        phone: docSnapshot['phone'],
        password: docSnapshot['password'],
        school: docSnapshot['school'],
        isAdmin: false,
      );
    }catch(e){
      print(e);
    }

    _teacherController.teacher.value.add(_teacher);
    _teacherController.update();

    return _teacher;

  }

  Future<TeacherModel>loginWithEmailAndPassword(String email, String password)async{
    TeacherModel _teacher = TeacherModel(
        uid: '',
        firstname: '',
        lastname: '',
        email: '',
        phone: '',
        password: '',
        school: '',
        isAdmin: false
    );

    try{
      var d = await _fs.collection('teachers').where('email', isEqualTo: email).where('password', isEqualTo: password).get();

      // Fetch the added document
        if(d.docs.isNotEmpty){
          var docSnapshot = d.docs.first;
          // Create TeacherModel from the document data
          _teacher = TeacherModel(
            uid: docSnapshot.id,
            firstname: docSnapshot['firstname'], // Access fields from the document
            lastname: docSnapshot['lastname'],
            email: docSnapshot['email'],
            phone: docSnapshot['phone'],
            password: docSnapshot['password'],
            school: docSnapshot['school'],
            isAdmin: docSnapshot['isAdmin'],
          );
        }

    }catch(e){
      print(e);
    }

    _teacherController.teacher.value.add(_teacher);
    _teacherController.update();

    return _teacher;

  }
}