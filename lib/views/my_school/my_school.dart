import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/my_school_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/parents/parents.dart';

class MySchool extends StatelessWidget {
  MySchool({super.key});


  MySchoolController _mySchoolController = Get.find();
  
  TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My School', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500),),
        backgroundColor: Karas.background,
      ),
      body: Container(
        child: ListView(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20
              ),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 1,
                    spreadRadius: 0.5
                  )
                ],
              ),
              child: Column(
                children: [
                  Text('${_mySchoolController.myschool.value.name}', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('District: ${_mySchoolController.myschool.value.district}', style: TextStyle(color: Colors.grey, fontSize: 13),),
                      SizedBox(width: 10,),
                      Text('Province: ${_mySchoolController.myschool.value.province}', style: TextStyle(color: Colors.grey, fontSize: 13),),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text('Teachers', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            SizedBox(height: 10,),
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('teachers').where('school', isEqualTo: _mySchoolController.myschool.value.uid).get(),
              builder: (c,s){
                if(s.hasData){
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20
                    ),
                    itemCount: s.data!.docs.length,
                    itemBuilder: (c,i){
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Container(
                              child: ClipRRect(
                                  child: CachedNetworkImage(
                                      width: 30,
                                      imageUrl: '${s.data!.docs[i].get('photo')}'),
                                 borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10
                                  ),
                                  child: Text('${_teacherController.teacher.first.uid == s.data!.docs[i].id ? 'You': s.data!.docs[i].get('firstname').toString().capitalize}', style: TextStyle(fontWeight: FontWeight.w600),),
                                )
                            ),
                          ],
                        ), 
                      );
                    }
                  );
                }else{
                  return Container();
                }
              },
            ),
            SizedBox(height: 20,),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text('Classes', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            SizedBox(height: 10,),
            FutureBuilder(
              future: FirebaseFirestore.instance.collection('classes').orderBy('name').where('school', isEqualTo: _mySchoolController.myschool.value.uid).get(),
              builder: (c,s){
                if(s.hasData){
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20
                      ),
                      itemCount: s.data!.docs.length,
                      itemBuilder: (c,i){
                        return Container(
                          child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      vertical: 4
                                    ),
                                    child: Row(
                                      children: [
                                        Text('${i + 1}.'),
                                        SizedBox(width: 10,),
                                        Text('${s.data!.docs[i].get('name')}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
                                      ],
                                    ),
                                  )
                              ),
                            ],
                          ),
                        );

                      }
                  );
                }else{
                  return Container();
                }
              },
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                children: [
                  Text('Parents', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
                  Spacer(),
                  InkWell(
                      onTap: (){
                        Get.to(()=>Parents(), transition: Transition.fade);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5
                        ),
                          child: Text('View all', style: TextStyle(color: Karas.primary, fontSize: 13, fontWeight: FontWeight.bold),)
                      )
                   ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
