import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_teacher/controllers/classes_controller.dart';
import 'package:smart_teacher/controllers/pupils_controller.dart';
import 'package:smart_teacher/controllers/schools_controoler.dart';
import 'package:smart_teacher/controllers/subjects_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/auth_screens/pro_register.dart';
import 'package:smart_teacher/views/auth_screens/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_teacher/views/auth_screens/sign_in_with_google.dart';

import 'controllers/my_classes_controller.dart';
import 'controllers/my_subjects_controller.dart';

void main() async{
  Get.put(TeacherController());
  Get.put(PupilsController());
  Get.put(ClassesController());
  Get.put(SubjectsController());
  Get.put(SchoolsController());
  Get.put(MyClassesController());
  Get.put(MySubjectsController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage().initStorage;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Teacher',
      theme: ThemeData(
        //primaryColor: Karas.primary,
        colorSchemeSeed: Karas.primary,
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}
