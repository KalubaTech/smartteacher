import 'dart:io';

import 'package:admob_easy/ads/admob_easy.dart';
import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_teacher/controllers/classes_controller.dart';
import 'package:smart_teacher/controllers/my_school_controller.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/pupils_controller.dart';
import 'package:smart_teacher/controllers/schools_controoler.dart';
import 'package:smart_teacher/controllers/subjects_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/services/notification_service.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/auth_screens/pro_register.dart';
import 'package:smart_teacher/views/auth_screens/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_teacher/views/auth_screens/sign_in_with_google.dart';
import 'package:smart_teacher/views/preset_screens/preset_classes.dart';

import 'controllers/globals.dart';
import 'controllers/meeting_participants_controller.dart';
import 'controllers/my_classes_controller.dart';
import 'controllers/my_subjects_controller.dart';
import 'controllers/subscription_plans_controller.dart';
import 'firebase_options.dart';

void main() async{
  Get.put(TeacherController());
  Get.put(PupilsController());
  Get.put(ClassesController());
  Get.put(SubjectsController());
  Get.put(SchoolsController());
  Get.put(MyClassesController());
  Get.put(MySubscriptionController());
  Get.put(MySchoolController());
  Get.put(SubscriptionPlansController());
  Get.put(MySubjectsController());
  Get.put(TimetableController());
  Get.put(ParticipantController());
  Get.put(Globals());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage().initStorage;

/*  NotificationService().initializeNotifications();
  NotificationService().showPersistentNotification();
  NotificationService().createNotificationChannel();*/

  AdmobEasy.instance.initialize(
      androidRewardedAdID: 'ca-app-pub-2615276835858154/4882719642',
      //androidInitAdID: 'ca-app-pub-3940256099942544/1033173712',
      androidBannerAdID: 'ca-app-pub-2615276835858154/6540025051',
      //androidAppOpenAdID: 'ca-app-pub-3940256099942544/9257395921',
      testDevices: ['543E082C0B43E6BF17AF6D4F72541F51']
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
     
  });
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Karas.primary,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Karas.primary,
  ));


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Globals globals = Get.find();
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
      home:  FirebaseNotificationsHandler(
          localNotificationsConfiguration: LocalNotificationsConfiguration(
            androidConfig: AndroidNotificationsConfig(
              // ...
            ),
            iosConfig: IosNotificationsConfig(
              // ...
            ),
          ),
          shouldHandleNotification: (msg) {
            // add some logic and return bool on whether to handle a notif or not
            return true;
          },
          onOpenNotificationArrive: (info) {

          },
          onTap: (info) {
            final payload = info.payload;
            final appState = info.appState;
            final firebaseMessage = info.firebaseMessage;

            /// If you want to push a screen on notification tap
            ///
            // Globals.navigatorKey.currentState?.pushNamed(
            //   payload['screenId'],
            // );
            ///
            /// or
            ///
            /// Get current context
            // final context = Globals.navigatorKey.currentContext!;


          },
          onFcmTokenInitialize: (token) {
            globals.fcmTokenNotifier.value = token!;
            globals.update();
            //print(token);
          },
          onFcmTokenUpdate: (token) {
            globals.fcmTokenNotifier.value = token;
            globals.update();
            //print(token);
          },
          child:  LoginScreen()
      ),
    );
  }
}
