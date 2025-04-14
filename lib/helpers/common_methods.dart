import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:docman/docman.dart';
import 'package:flutter_ripple_animation/ripple_animation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/timetable_model.dart';
import 'package:smart_teacher/views/auth_screens/sign_in_with_google.dart';
import 'package:smart_teacher/views/documents/lesson_plans/lesson_plans.dart';

import '../controllers/globals.dart';
import '../services/auth_service.dart';

class CommonMethods{

  MySubscriptionController _mySubscriptionController = Get.find();
  TimetableController _timetableController = Get.find();

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  TeacherController _teacherController = Get.find();  


  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      print("✅ Storage permission granted!");
      return true;
    } else if (await Permission.storage.isDenied) {
      print("❌ Storage permission denied!");
      return false;
    } else if (await Permission.storage.isPermanentlyDenied) {
      print("⚠️ Storage permission permanently denied. Open settings.");
      await openAppSettings(); // Opens app settings for manual permission granting
      return true;
    }
    return false;
  }

  void addPupil(String fname, String lname, String gender, String intake, String classid, school, email)async{

    Map<String, dynamic>data = {
      'firstname':fname,
      'lastname':lname,
      'gender':gender,
      'intake':[intake],
      'class':[classid],
      'currentClass':classid,
      'photo':'',
      'school':school,
      'email':email
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

  Globals _globals = Get.find();

  void updateToken(){
    FirebaseFirestore.instance.collection('teachers').doc(_teacherController.teacher.first.uid).update({'token':_globals.fcmTokenNotifier.value});
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

  //send notification to device
  Future<void> sendFCM(String token, String title, String body) async {
    final response = await http.post(
      Uri.parse('https://kalootech.com/backend/fcm.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
      print(response.body);
    } else {
      print('Failed to send message');
      print(response.body);
    }
  }


  Future<void> sendParentNotifications(String schoolId, String title, String body) async {
    try {
      // 1. Get all pupils in this school
      final pupilsSnapshot = await FirebaseFirestore.instance
          .collection('pupils')
          .where('school', isEqualTo: schoolId)
          .get();

      if (pupilsSnapshot.docs.isEmpty) return;

      // 2. Get all parent-child relationships for these pupils
      final pupilIds = pupilsSnapshot.docs.map((doc) => doc.id).toList();
      final parentChildSnapshot = await FirebaseFirestore.instance
          .collection('parent-child')
          .where('child', whereIn: pupilIds)
          .get();

      if (parentChildSnapshot.docs.isEmpty) return;

      // 3. Get distinct parent IDs
      final parentIds = parentChildSnapshot.docs
          .map((doc) => doc['parent'] as String)
          .toSet() // Remove duplicates
          .toList();

      // 4. Get parent FCM tokens and send notifications
      final parentsSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .where(FieldPath.documentId, whereIn: parentIds)
          .get();

      for (final parentDoc in parentsSnapshot.docs) {
        final token = parentDoc['token'];
        if (token != null && token is String) {
          await sendFCM(token, title, body);
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to send parent notifications');
    }
  }

  Future<void> sendTeacherNotifications(
      String schoolId,
      String title,
      String body,
      String excludedTeacherId,
      ) async {
    try {
      // Get all teachers at this school except the excluded one
      final teachersSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('school', isEqualTo: schoolId)
          .where(FieldPath.documentId, isNotEqualTo: excludedTeacherId)
          .get();

      if (teachersSnapshot.docs.isEmpty) return;

      // Send notifications to each teacher
      for (final teacherDoc in teachersSnapshot.docs) {
        final token = teacherDoc['token'];
        if (token != null && token is String) {
          await sendFCM(token, title, body);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send teacher notifications');
    }
  }


  Future<void> addNotification({
    required String title,
    required String message,
    required String senderName,
    required String senderId,
    required List<String> targets,
  }) async {
    try {
      final now = DateTime.now();

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'notification': message,
        'senderName': senderName,
        'senderId': senderId,
        'datetime': Timestamp.fromDate(now),
        'seenIds': [], // Initially no one has seen it
        'deletedIds': [], // Initially no one has deleted it
        'targets': targets, // e.g. ['parents', 'teachers'] or ['all']
      });

      print('Notification added successfully');
    } catch (e) {
      print('Error adding notification: $e');
      rethrow;
    }
  }

  endCall(id)async{
    await FirebaseFirestore.instance.collection('video_call').doc(id).update({'status':'ended'});
    Fluttertoast.showToast(msg: 'Ended Called');
  }

  answerCall(id)async{
    await FirebaseFirestore.instance.collection('video_call').doc(id).update({'status':'talking'});
  }


  JitsiMeet jitsiMeet = JitsiMeet();


  Future<void> joinMeeting({
    required String room,
    String serverUrl = "https://meet.jit.si",
    String subject = "Meeting",
    required String userDisplayName,
    String? userEmail,
    String? userAvatarURL,
    bool audioOnly = false,
    bool audioMuted = false,
    bool videoMuted = false,
  }) async {
    try {
      // Feature flags
      // Create feature flags
      final featureFlags = {
        "welcomePage.enabled": false,
        "resolution": FeatureFlagVideoResolutions.resolution360p,
        "unsaferoomwarning.enabled": false,
        "add-people.enabled": false
        // Add any other feature flags you need
      };

      // Create conference options
      var options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.engagemedia.org",
        room: room,
        configOverrides: {
          "startWithAudioMuted": audioMuted,
          "startWithVideoMuted": videoMuted,
          "subject": subject,
        },
        featureFlags: featureFlags,
        userInfo: JitsiMeetUserInfo(
          displayName: userDisplayName,
          email: userEmail,
          avatar: userAvatarURL,
        ),
      );
      // Join meeting
      await jitsiMeet.join(
        options,
      );
    } catch (error) {
      debugPrint("Join meeting error: $error");
    }
  }


  addVideoCall(callerId, callerName, callerPhoto,calleeId, calleeName, calleePhoto, calleeRole)async{

    var data = {
      'callerId':callerId,
      'callerName':callerName,
      'callerPhoto':callerPhoto,
      'calleeId':calleeId,
      'calleeName':calleeName,
      'calleePhoto':calleePhoto,
      'status':'calling',
      'datetime':'${DateTime.now()}'
    };

    await FirebaseFirestore.instance.collection('video_call').add(data).then((d){
      playOutgoingRingtone();
      Get.bottomSheet(
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/call_background.jpg'),
                  fit: BoxFit.cover
              ),
            ),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('video_call').doc(d.id).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData && snapshot.data!.get('status')=='talking'){
                    Get.back();
                    joinMeeting(
                        room: '${callerId}_$calleeId',
                        userDisplayName: '${callerName}',
                        userAvatarURL: '${callerPhoto}',
                        audioMuted: false
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                snapshot.hasData && snapshot.data!.get('status')=='ended'?
                                Text('Call ended...', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),):
                                Text('Calling...', style: TextStyle(color: Colors.white),),
                                Text('${calleeName}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
                                SizedBox(height: 40,),
                                RipplesAnimation(
                                    size: 60,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: NetworkImage('${calleePhoto}'),
                                    )
                                )
                              ],
                            ),
                          )
                      ),
                      snapshot.hasData && snapshot.data!.get('status')=='ended'?
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: CircleAvatar(
                                radius: 35,
                                child: Icon(Icons.close, size: 40,color: Colors.red,),
                              ),
                              onTap: (){
                                player.stop();
                                Get.back();
                                CommonMethods().endCall(d.id);
                              },
                            ),
                            SizedBox(width: 40,),
                            InkWell(
                              child: CircleAvatar(
                                radius: 35,
                                child: Icon(Icons.call_end, size: 40,color: Colors.green,),
                              ),
                              onTap: (){
                                CommonMethods().callback(d.id);
                              },
                            ),

                          ],
                        ),
                      ) :
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 40
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              child: CircleAvatar(
                                radius: 35,
                                child: Icon(Icons.call_end, size: 40,color: Colors.red,),
                              ),
                              onTap: (){
                                player.stop();
                                Get.back();
                                CommonMethods().endCall(d.id);

                              },
                            ),

                          ],
                        ),
                      )
                    ],
                  );
                }
            ),
          ),
          backgroundColor: Colors.white,
          isScrollControlled: true,
          isDismissible: false
      );
    }
    );

    var calleeData = await FirebaseFirestore.instance.collection(calleeRole).doc(calleeId).get();
    var token = calleeData.get('token');

    sendFCM(token, 'Incoming call...', '${callerName}');


  }


  var player = AudioPlayer();

/*  endCall(id)async{
    await FirebaseFirestore.instance.collection('video_call').doc(id).update({'status':'ended'});
    Fluttertoast.showToast(msg: 'Ended Called');
  }


  answerCall(id)async{
    await FirebaseFirestore.instance.collection('video_call').doc(id).update({'status':'talking'});
  }*/

  playOutgoingRingtone() async {
    await player.setReleaseMode(ReleaseMode.loop); // 🔁 Set looping mode
    await player.play(
      AssetSource('outgoing_call.mp3'),
      mode: PlayerMode.mediaPlayer,
      volume: 1,
    );
  }
  playIncomingRingtone()async{
    await player.setReleaseMode(ReleaseMode.loop); // 🔁 Set looping mode
    await player.play(
      AssetSource('ringtone.mp3'),
      mode: PlayerMode.mediaPlayer,
      volume: 1,
    );
  }
  stopRinging(){
    player.stop();
    print('STOP RINGING');
  }

  callback(docid){
    FirebaseFirestore.instance.collection('video_call').doc(docid).update({'status':'calling'});
  }


  String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM d, y – h:mm a');
    return formatter.format(dateTime);
  }



}