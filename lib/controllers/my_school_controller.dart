import 'package:get/get.dart';
import 'package:smart_teacher/models/school_model.dart';

class MySchoolController extends GetxController{
  var myschool = SchoolModel(
      uid: '',
      name: '',
      district: '',
      province: '',
      type: ''
  ).obs;
}