import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/dashboard/dashboard.dart';
import 'package:smart_teacher/views/documents/documents.dart';
import 'package:smart_teacher/views/profile/profile.dart';
import 'package:smart_teacher/views/settings/settings_screen.dart';

class PageAnchor extends StatefulWidget {
  PageAnchor({super.key});

  @override
  State<PageAnchor> createState() => _PageAnchorState();
}

class _PageAnchorState extends State<PageAnchor> {
  int _bottomNavIndex = 0;
  PageController _controller = PageController();
  int _backPressCount = 0;

  @override
  void initState() {
    super.initState();
    DataPrefetch().getMyClasses(GetStorage().read('user'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backPressCount++;
        if (_backPressCount < 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Press back ${3 - _backPressCount} more time(s) to exit"),
              duration: Duration(seconds: 1),
            ),
          );
          Future.delayed(Duration(seconds: 2), () {
            _backPressCount = 0; // Reset counter after 2 seconds
          });
          return false; // Prevent app from closing
        }
        return true; // Allow app to close on the third press
      },
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: (p) {
            setState(() {
              _bottomNavIndex = p;
            });
          },
          children: [
            Dashboard(),
            Documents(),
            SettingsScreen(),
            Profile(),
          ],
        ),
        floatingActionButton: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: FloatingActionButton(
            backgroundColor: Karas.danger,
            onPressed: () {},
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
          icons: [
            Icons.dashboard,
            Icons.work,
            Icons.settings,
            Icons.person,
          ],
          activeIndex: _bottomNavIndex,
          activeColor: Karas.primary,
          inactiveColor: Colors.grey,
          notchSmoothness: NotchSmoothness.softEdge,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            _controller.animateToPage(_bottomNavIndex,
                duration: Duration(milliseconds: 200), curve: Curves.easeIn);
          },
          gapLocation: GapLocation.center,
        ),
      ),
    );
  }
}
