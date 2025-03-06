import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/dashboard/dashboard.dart';
import 'package:smart_teacher/views/documents/documents.dart';
import 'package:smart_teacher/views/profile/profile.dart';
import 'package:smart_teacher/views/settings/settings_screen.dart';
import 'package:smart_teacher/views/timetable/timetable.dart';

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
  final TeacherController _teacherController = Get.find();
  final Globals _globals = Get.find<Globals>();


  bool canpop = false;

  @override
  void initState() {
    super.initState();

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
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: const [
            Icons.dashboard,
            Icons.work,
            Icons.calendar_month,
            Icons.settings,
            Icons.person,
          ],
          activeIndex: _bottomNavIndex,
          activeColor: Karas.primary,
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
        ),
      ),
    );
  }
}
