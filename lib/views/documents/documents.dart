import 'package:admob_easy/ads/services/banner_ad.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/ListTiles/image_leading_tile.dart';
import 'package:smart_teacher/views/documents/class_list.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/documents/lesson_plans/lesson_plans.dart';
import 'package:smart_teacher/views/documents/mark_schedule/mark_schedule.dart';
import 'package:smart_teacher/views/documents/report_forms/report_forms.dart';
import 'package:smart_teacher/views/documents/schemes_of_work/schemes_of_work.dart';
import '../../controllers/my_subscription_controller.dart';
import '../../utils/colors.dart';

class Documents extends StatefulWidget {
  Documents({super.key});

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10
          ),
          children: [
            GetBuilder<MySubscriptionController>(
                builder: (c){
                  return c.getCurrentSub()!=null?c.getCurrentSub()!.isActive?Container():Container(margin: EdgeInsets.only(bottom: 0),child: AdMobEasyBanner()):SlideInDown(child: Container(margin: EdgeInsets.only(bottom: 0),child: AdMobEasyBanner()));
                }
            ),
            SizedBox(height: 10,),
            ImageLeadingTile(
                title: 'Class List',
                iconPath: 'assets/class.png',
                ontap: (){
                    Get.to(()=>ClassList(), transition:Transition.fadeIn);
                },
            ),
            ImageLeadingTile(
                title: 'Mark Schedule',
                iconPath: 'assets/markschedule.png',
                ontap: (){
                  Get.to(()=>MarkSchedule(), transition:Transition.fadeIn);
                },
            ),
            ImageLeadingTile(
                title: 'Schemes of Work',
                iconPath: 'assets/scheme.png',
                ontap: (){
                 // Get.to(()=>SchemesOfWork(), transition:Transition.fadeIn);
                },
                active: false
            ),
            ImageLeadingTile(
                title: 'Lesson Plans',
                iconPath: 'assets/plan.png',
                ontap: (){
                  Get.to(()=>LessonPlans(), transition:Transition.fadeIn);
                },
            ),
            ImageLeadingTile(
              title: 'Report Forms',
              iconPath: 'assets/report.png',
              ontap: (){
                Get.to(()=>ReportForms(), transition:Transition.fadeIn);
              },
            ),
          ],
        ),
      ),
    );
  }
}
