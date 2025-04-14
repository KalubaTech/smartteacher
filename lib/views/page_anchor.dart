import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/dashboard/dashboard.dart';
import 'package:smart_teacher/views/documents/documents.dart';
import 'package:smart_teacher/views/profile/profile.dart';
import 'package:smart_teacher/views/settings/settings_screen.dart';
import 'package:smart_teacher/views/timetable/timetable.dart';
import 'package:flutter_ripple_animation/ripple_animation.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

import '../controllers/globals.dart';

class PageAnchor extends StatefulWidget {
  PageAnchor({super.key});

  @override
  State<PageAnchor> createState() => _PageAnchorState();
}

class _PageAnchorState extends State<PageAnchor> {
  int _bottomNavIndex = 0;
  final PageController _controller = PageController();
  int _backPressCount = 0;
  Timer? _callTimeoutTimer;

  final TeacherController _teacherController = Get.find();
  final Globals _globals = Get.find<Globals>();

  bool canpop = false;

  var isCalling = false.obs;

  final player = AudioPlayer();


  playRingtone() async {
    Vibration.vibrate(preset: VibrationPreset.zigZagAlert);
    await player.setReleaseMode(ReleaseMode.loop); // 🔁 Set looping mode
    await player.play(
      AssetSource('ringtone.mp3'),
      mode: PlayerMode.mediaPlayer,
      volume: 1,
    );
  }

  // Listen for changes in the participants field of Firestore
  void listenForVideoCallStatus() {
    FirebaseFirestore.instance
        .collection('video_call')
        .where('status', isEqualTo: 'calling')
        .where('calleeId', isEqualTo: _teacherController.teacher.first.uid)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var snapshot = querySnapshot.docs.first;
        playRingtone();
        callingBottomSheet(snapshot);
      } else {
          player.stop();
          Vibration.cancel();
         Get.back();
      }
    });
  }

  callingBottomSheet(snapshot)async{
    // Start ringtone loop
    await player.setReleaseMode(ReleaseMode.loop);
    await player.play(
      AssetSource('ringtone.mp3'),
      mode: PlayerMode.mediaPlayer,
      volume: 1,
    );

    // Start vibrating every 1 second for 60 seconds
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: List.generate(60, (i) => i.isEven ? 1000 : 1000), amplitude: 2);
    }

    // Set 60-second timeout
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = Timer(Duration(seconds: 60), () {
      CommonMethods().endCall(snapshot.id);
    });
    Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/call_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Incoming Call...',
                        style: TextStyle(color: Colors.white)),
                    Text(
                      '${snapshot.get('callerName')}',
                      style: GoogleFonts.gabarito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                    SizedBox(height: 40),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('video_call')
                          .where('calleeId', isEqualTo: _teacherController.teacher.first.uid)
                          .where('status', isEqualTo: 'talking')
                          .snapshots(),
                      builder: (context, snaps) {
                        return RipplesAnimation(
                          size: 60,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(
                                '${snapshot.get('callerPhoto')}'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      child: CircleAvatar(
                        radius: 35,
                        child: Icon(Icons.call_end, color: Colors.red,size: 40,),
                      ),
                      onTap: () {
                        CommonMethods()
                            .endCall(snapshot.id);
                      },
                    ),
                    SizedBox(width: 40),
                    InkWell(
                      onTap: () {
                        CommonMethods().joinMeeting(
                          room:
                          '${snapshot.get('callerId')}_${snapshot.get('calleeId')}',
                          userDisplayName:
                          '${snapshot.get('calleeName')}',
                          userAvatarURL:
                          '${snapshot.get('calleePhoto')}',
                          audioMuted: false,
                        );
                        CommonMethods()
                            .answerCall(snapshot.id);
                      },
                      child: CircleAvatar(
                        radius: 35,
                        child: Icon(Icons.call_end, color: Colors.green,size: 40,),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white,
        isScrollControlled: true
    );
  }

  @override
  void initState() {
    super.initState();

    // Listen for the meeting status and update UI when changes occur
    listenForVideoCallStatus();

    String? user = GetStorage().read('user');
    if (user != null) {
      DataPrefetch().getMyClasses(user);
      DataPrefetch().fetchMySubscription(user);
      DataPrefetch().fetchMyTimetable(user);
    }

    DataPrefetch().fetchSubscriptionPlans();

    if (_teacherController.teacher.isNotEmpty) {
      DataPrefetch().getMyClasses(_teacherController.teacher.first.uid);
      DataPrefetch().fetchSchool(_teacherController.teacher.first.school);
      DataPrefetch().fetchAllMySubjects(_teacherController.teacher.first.uid, _teacherController.teacher.first.school);
    }

    CommonMethods().updateToken();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_bottomNavIndex == 0) {
            _backPressCount++;
            if (_backPressCount >= 3) {
              Get.back();
              setState(() {
                canpop = true;
              });
            } else {
              Fluttertoast.showToast(
                msg: 'Press again to exit',
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _backPressCount = 0);
              });
            }
          } else {
            setState(() {
              _bottomNavIndex = 0;
              _controller.animateToPage(
                0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            });
          }
        }
      },
      canPop: canpop,
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => _bottomNavIndex = index);
          },
          children: [
            Dashboard(),
            Documents(),
            Timetable(),
            SettingsScreen(),
            Profile(),
          ],
        ),
        bottomNavigationBar: Obx(
          ()=> AnimatedBottomNavigationBar(
            height: isCalling.value? 0: 50,
            icons: const [
              Icons.dashboard,
              Icons.work,
              Icons.calendar_month,
              Icons.settings,
              Icons.person,
            ],
            activeIndex: _bottomNavIndex,
            activeColor: Karas.secondary,
            inactiveColor: Colors.grey,
            notchSmoothness: NotchSmoothness.softEdge,
            gapWidth: 0,
            onTap: (index) {
              if (index != _bottomNavIndex) {
                setState(() => _bottomNavIndex = index);
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            elevation: 10,
            backgroundGradient: LinearGradient(colors: [
              Colors.grey.shade300,
              Colors.white,
              Colors.grey.shade300,
              Colors.white
            ]),
            rightCornerRadius: 0,
            shadow: BoxShadow(
              color: Colors.grey.shade600,
              blurRadius: 1,
              spreadRadius: 1,
            ),
          ),
        ),
      ),
    );
  }

}
