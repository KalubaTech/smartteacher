import 'package:admob_easy/admob_easy.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/containers/carousel_container.dart';
import 'package:smart_teacher/components/containers/home_grid_item_container.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/subscription_plans_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/controllers/timetable_controller.dart';
import 'package:smart_teacher/meetings/meetings.dart';
import 'package:smart_teacher/services/auth_service.dart';
import 'package:smart_teacher/services/local_auth_service.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/chat/chat_heads.dart';
import 'package:smart_teacher/views/classes/classes.dart';
import 'package:smart_teacher/views/classes/online_classes.dart';
import 'package:smart_teacher/views/documents/documents.dart';
import 'package:smart_teacher/views/ebooks/ebooks.dart';
import 'package:smart_teacher/views/settings/subscription/subscription.dart';
import 'package:smart_teacher/views/timetable/timetable.dart';

import '../../helpers/common_methods.dart';
import '../announcements/notice_board.dart';
import '../notifications/notifications.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  TeacherController _teacherController = Get.find();

  void allowBiometrics()async{
    bool hasBiometrics = await LocalAuthService().isBiometricAvailable();
    var isBioSwitchedOn = false.obs;
    //GetStorage().remove('biometrics');

    if((!GetStorage().hasData('biometrics'))){
      if(hasBiometrics&&(GetStorage().read('biometrics')==false||GetStorage().read('biometrics')==null)){
        Get.defaultDialog(
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Text('Allow unlocking with Fingerprint next time you log in.'),
                  SizedBox(height: 20,),
                  Obx(
                    ()=> Switch(
                      value: isBioSwitchedOn.value,
                      onChanged: (value){
                        GetStorage().write('biometrics', value);
                        isBioSwitchedOn.value = value!;
                      },
                      activeColor: Karas.primary,
                    ),
                  )
                ],
              ),
            ),
            title: 'Biometrics',
            radius: 10
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    allowBiometrics();
    CommonMethods().deactivateSubscription(_teacherController.teacher.first.uid);
    return GetBuilder<TimetableController>(
        builder: (tcontroller)
    {
      return DraggableHome(
          backgroundColor: Karas.background,
          appBarColor: Karas.primary,
          title: Container(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: CachedNetworkImage(
                    width: 30,
                    height: 30,
                    imageUrl: '${_teacherController.teacher.first.photo}',
                    errorWidget: (e, x, r) =>
                        CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_teacherController.teacher.first.firstname}',
                          style: GoogleFonts.passionOne(
                              fontSize: 19, color: Colors.black),)
                      ],
                    )
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .where('targets', arrayContains: 'teachers')
                  //.where('deletedIds', whereNotIn: [[_parentController.parent.first.uid]])
                      .where('seenIds', whereNotIn: [[_teacherController.teacher.first.uid]])
                      .snapshots(),
                  builder: (context, snapshot) {
                    int unseenCount = 0;

                    if (snapshot.hasData) {
                      unseenCount = snapshot.data!.docs.length;
                    }

                    return IconButton(
                      onPressed: () => Get.to(() => Notifications()),
                      icon: Badge(
                        isLabelVisible: unseenCount > 0,
                        label: Text(unseenCount.toString()),
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          headerWidget: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  // 135deg corresponds to top-left to bottom-right
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xC27EDAA4), // #4f8c6a at 0%
                    Color(0xFF65D3A9), // #65d3a9 at 64%
                    Color(0xFF65D3A9), // #65d3a9 at 64%
                    Color(0xFF1AE8CF), // #27d1bd at 66%
                    Color(0xFF6BC67A), // #6bc67a at 100%
                  ],
                  stops: [
                    0.0,
                    0.64,
                    0.64,
                    0.66,
                    1.0
                  ], // Corresponding stops for the colors
                )
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageUrl: '${_teacherController.teacher.first.photo}',
                        errorWidget: (e, x, r) =>
                            CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher', style: GoogleFonts.aladin(),),
                          Text('${_teacherController.teacher.first.firstname}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.passionOne(
                                fontSize: 24,
                            ),)
                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('targets', arrayContains: 'teachers')
                      //.where('deletedIds', whereNotIn: [[_parentController.parent.first.uid]])
                          .where('seenIds', whereNotIn: [[_teacherController.teacher.first.uid]])
                          .snapshots(),
                      builder: (context, snapshot) {
                        int unseenCount = 0;

                        if (snapshot.hasData) {
                          unseenCount = snapshot.data!.docs.length;
                        }

                        return IconButton(
                          onPressed: () => Get.to(() => Notifications()),
                          icon: Badge(
                            isLabelVisible: unseenCount > 0,
                            label: Text(unseenCount.toString()),
                            child: const Icon(Icons.notifications, color: Colors.white),
                          ),
                        );
                      },
                    ),
              /*      IconButton(
                        onPressed: () async {
                          await AuthService().signOut();
                        },
                        icon: Icon(Icons.logout)
                    )*/
                  ],
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
          headerExpandedHeight: 0.2,
          body: [
            SizedBox(height: 0,),
            GetBuilder<MySubscriptionController>(
                builder: (c){
                  return c.getCurrentSub()!=null?c.getCurrentSub()!.isActive?Container():Container(margin: EdgeInsets.only(bottom: 10),child: AdMobEasyBanner()):SlideInDown(child: Container(margin: EdgeInsets.only(bottom: 10),child: AdMobEasyBanner()));
                }
            ),
            FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: 110.0,
                  showIndicator: true,
                  autoPlayInterval: Duration(seconds: 8),
                  autoPlay: true,
                  viewportFraction: 0.93,
                  slideIndicator: CircularWaveSlideIndicator(),
                ),
                items: [
                  ...CommonMethods().getTimetablesBeforeStartTime().map((tt) {
                    return CarouselContainer(
                        backImage: 'assets/event.png',
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                // 135deg corresponds to top-left to bottom-right
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0x271A684E), // #4f8c6a at 0%
                                  Color(0x9EA6EDC2), // #65d3a9 at 64%
                                  Color(0xD58FDABA), // #65d3a9 at 64%
                                  Color(0xB669C3B6), // #27d1bd at 66%
                                  Color(0xDB87D1A1), //  #6bc67a at  1 00 %
                                ],
                                stops: [
                                  0.0,
                                  0.64,
                                  0.90,
                                  0.70,
                                  1.0
                                ], // Corresponding stops for the colors
                              )
                          ),
                          child: GetBuilder<SubscriptionPlansController>(
                              builder: (subscriptionPlans) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        Text('${tt.starttime}',
                                          style: GoogleFonts.abyssinicaSil(
                                              fontSize: 14),),
                                        Text('${tt.subject}',
                                          style: GoogleFonts.russoOne(
                                              fontSize: 18),),
                                        SizedBox(height: 0,),
                                        Text('GRADE ${tt.classname}',
                                          style: GoogleFonts.russoOne(
                                              fontSize: 14),),
                                      ],
                                    )
                                  ],
                                );
                              }
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20
                          ),
                        )
                    );
                  }),
                  GetBuilder<MySubscriptionController>(
                      builder: (mysubscriptioncont) {
                        var activeSub = mysubscriptioncont.getCurrentSub();
                        return (activeSub != null) ?
                        CarouselContainer(
                            backImage: 'assets/subscription-business.png',
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    // 135deg corresponds to top-left to bottom-right
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x271A684E), // #4f8c6a at 0%
                                      Color(0x9EA6EDC2), // #65d3a9 at 64%
                                      Color(0xD58FDABA), // #65d3a9 at 64%
                                      Color(0xB669C3B6), // #27d1bd at 66%
                                      Color(0xDB87D1A1), //  #6bc67a at  1 00 %
                                    ],
                                    stops: [
                                      0.0,
                                      0.64,
                                      0.90,
                                      0.70,
                                      1.0
                                    ], // Corresponding stops for the colors
                                  )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${activeSub!.plan.capitalize}',
                                        style: GoogleFonts.abyssinicaSil(
                                            fontSize: 11),),
                                      Text(
                                        'ZMK ${activeSub!.amount.capitalize}',
                                        style: GoogleFonts.russoOne(
                                            fontSize: 18),),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end,
                                        children: [
                                          Text('${'${CommonMethods()
                                              .calculateRamainingDays(
                                              DateTime.now(),
                                              activeSub!.expiry_date)}'}',
                                            style: GoogleFonts.russoOne(
                                                fontSize: 18),),
                                          Text('${' days'}',
                                            style: GoogleFonts.abel(
                                                fontSize: 10),),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20
                              ),
                            )
                        ) :
                        CarouselContainer(
                            backImage: 'assets/subscription-business.png',
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    // 135deg corresponds to top-left to bottom-right
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x271A684E), // #4f8c6a at 0%
                                      Color(0x9EA6EDC2), // #65d3a9 at 64%
                                      Color(0xD58FDABA), // #65d3a9 at 64%
                                      Color(0xB669C3B6), // #27d1bd at 66%
                                      Color(0xDB87D1A1), //  #6bc67a at  1 00 %
                                    ],
                                    stops: [
                                      0.0,
                                      0.64,
                                      0.90,
                                      0.70,
                                      1.0
                                    ], // Corresponding stops for the colors
                                  )
                              ),
                              child: GetBuilder<SubscriptionPlansController>(
                                  builder: (subscriptionPlans) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            Text('${subscriptionPlans.sub_plans
                                                .isNotEmpty
                                                ? subscriptionPlans.sub_plans
                                                .first.plan.capitalize
                                                : ''}',
                                              style: GoogleFonts.abyssinicaSil(
                                                  fontSize: 11),),
                                            Text(
                                              'ZMK ${subscriptionPlans.sub_plans
                                                  .isNotEmpty
                                                  ? subscriptionPlans.sub_plans
                                                  .first.amount.capitalize
                                                  : ''}',
                                              style: GoogleFonts.russoOne(
                                                  fontSize: 18),),
                                            SizedBox(height: 10,),
                                            InkWell(
                                              onTap: () {
                                                Get.to(() => Subscription(),
                                                    transition: Transition
                                                        .fade);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Karas.primary,
                                                          Color(0xfe053335)
                                                        ],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .circular(10),
                                                    border: Border.all(
                                                        color: Colors.yellow,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.yellow,
                                                        spreadRadius: 2,
                                                        blurRadius: 3
                                                      )
                                                    ]
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                child: Text('Pay to remove ads',
                                                  style: TextStyle(
                                                      color: Colors.yellow,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight
                                                          .w600),),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  }
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20
                              ),
                            )
                        );
                      }
                  ),
                ]
            ),   
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 12,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Color(0xff1d714a),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
                    ),
                  ),
                  SizedBox(width: 0,),
                  Container(
                     padding: EdgeInsets.symmetric(horizontal: 10),
                     decoration: BoxDecoration(
                         color: Color(0xff1d714a),
                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                     ),
                      child: Text('Activities', style: GoogleFonts.aladin(fontSize: 20, color: Colors.yellow),)
                  ),
                  SizedBox(width: 0,),
                  Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xff1d714a),
                                  Color(0xff1e7b4e),
                                  Color(0xff2ed07e),
                                  Color(0xff1bceae),
                                ]
                            ),
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20))
                        ),
                      )
                  )
                ],
              ),
            ),
            GridView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                HomeGridItemContainer(
                    icon: 'assets/class.png',
                    label: 'My Classes',
                    backgroundColor: Karas.primary.withOpacity(0.3),
                    onclick: () {
                      Get.to(() => Classes(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/ebook.png',
                    label: 'eBooks',
                    backgroundColor: Karas.info.withOpacity(0.3),
                    onclick: () {
                      Get.to(() => Ebooks(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/schedule.png',
                    label: 'My Timetable',
                    backgroundColor: Karas.danger.withOpacity(0.3),
                    onclick: () {
                      Get.to(() => Timetable(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/stamp.png',
                    label: 'Documents File',
                    backgroundColor: Karas.secondary.withValues(alpha: 0.3),
                    onclick: () {
                      Get.to(() => Documents(), transition: Transition.fade);
                    }
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 15
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 12,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Color(0xff1d714a),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
                    ),
                  ),
                  SizedBox(width: 0,),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Color(0xff1d714a),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
                      ),
                      child: Text('Commucation', style: GoogleFonts.aladin(fontSize: 20, color: Colors.yellow),)
                  ),
                  SizedBox(width: 0,),
                  Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xff1d714a),
                                  Color(0xff1e7b4e),
                                  Color(0xff2ed07e),
                                  Color(0xff1bceae),
                                ]
                            ),
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20))
                        ),
                      )
                  )
                ],
              ),
            ),
            GridView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                HomeGridItemContainer(
                    icon: 'assets/promote.png',
                    label: 'Notice Board',
                    backgroundColor: Color(0xEC0D56A5).withValues(alpha: 0.3),
                    onclick: () {
                      Get.to(() => NoticeBoard(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/comments.png',
                    label: 'Messaging',
                    backgroundColor: Karas.info.withValues(alpha: 0.5),
                    onclick: () {
                      Get.to(() => TeacherChatHeads(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/meeting.png',
                    label: 'Meetings',
                    backgroundColor: Karas.danger.withValues(alpha: 0.5),
                    onclick: () {
                      Get.to(() => Meetings(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/webinar.png',
                    label: 'Online Classes',
                    backgroundColor: Karas.danger.withValues(alpha: 0.5),
                    onclick: () {
                      Get.to(() => OnlineClasses(), transition: Transition.fade);
                    }
                ),
              ],
            ),
            SizedBox(height: 20,)
          ]
      );
    });
  }
}
