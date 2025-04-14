import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/documents/lesson_plans/lesson_plans.dart';
import 'package:smart_teacher/views/timetable/timetable.dart';

class NotificationService{


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification actions
        switch (response.actionId) {
          case 'action_1':
            print('Action 1 clicked');

            Get.to(()=>Timetable());
            break;
          case 'action_2':
            Get.to(()=>LessonPlans());
            break;
          default:
            print('Notification clicked');
            break;
        }
      },
    );
  }

  void showPersistentNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'Your Channel Name', // Channel Name
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Make the notification persistent
      autoCancel: false, // Prevent the notification from being dismissed
      showWhen: false, // Hide the timestamp
      actions: [
        // Add actions (menu items) to the notification
        AndroidNotificationAction(
          'action_1',
          'Timetable',
          showsUserInterface: true,
          icon: DrawableResourceAndroidBitmap('ic_schedule_1'), // Reference the drawable resource
        ),
        AndroidNotificationAction(
          'action_2',
          'Lesson Plans',
          icon: DrawableResourceAndroidBitmap('ic_schedule_1'), // Reference the drawable resource
        ),
      ],
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Persistent Notification', // Title
      'This is a persistent notification with a menu.', // Body
      platformChannelSpecifics,
    );
  }

  void createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Channel ID
      'Your Channel Name', // Channel Name
      description: 'Your Channel Description',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


}