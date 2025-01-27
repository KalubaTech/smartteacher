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
             'photo':teacher.photo
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
               school: teacher.school
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
             school: _teachersData.docs.first.get('school')
         );
        _teacherController.teacher.value.add(teacher);
        _teacherController.update();
        Get.offAll(()=>PageAnchor());
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

    Get.offAll(()=>PageAnchor(), transition: Transition.leftToRightWithFade);
  }
}