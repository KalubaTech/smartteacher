import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';

class Profile extends StatelessWidget {
  Profile({super.key});


  @override
  Widget build(BuildContext context) {

    return GetBuilder<TeacherController>(
      builder: (teacherController) {
        TeacherModel teacher = teacherController.teacher.first;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Profile', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500),),
          ),
          body: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 1,
                        spreadRadius: 0.5

                      )
                    ]
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: '${teacher.photo}',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)
                      ),
                      boxShadow: [

                      ]
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        ListTile(
                          leading: Icon(Icons.person, color: Colors.orange,),
                          title: Text('${teacher.firstname}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                          subtitle: Text('Name', style: TextStyle(color: Colors.grey, fontSize: 13),),
                          trailing: IconButton(
                              onPressed: (){
                                TextEditingController _nameController = TextEditingController();
                                _nameController.text = teacher.firstname;
                                Get.bottomSheet(
                                  Container(
                                    height: 280,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20)
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
                                              ),
                                              child: Column(
                                                children: [
                                                  SizedBox(height: 20,),
                                                  Text('Edit Your Name', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
                                                  Expanded(
                                                    child: Container(
                                                      width: double.infinity,
                                                      child: ListView(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 20
                                                        ),
                                                        children: [
                                                          Kalutext(
                                                              controller: _nameController,
                                                            hintText: 'Name',
                                                          ),
                                                          SizedBox(height: 20,),
                                                          Kalubtn(
                                                              width: 100,
                                                              borderRadius: 20,
                                                              label: 'Save',
                                                              onclick: (){
                                                                  FirebaseFirestore.instance
                                                                      .collection('teachers')
                                                                      .doc(teacher.uid).update({'firstname':_nameController.text});

                                                                  teacherController.teacher.first.firstname = _nameController.text;
                                                                  teacherController.update();
                                                                  Get.back();
                                                              })
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit, size: 16, color: Karas.primary,)),
                        ),
                        Container(color: Colors.grey.shade100,height: 1,),
                        ListTile(
                          leading: Icon(Icons.email, color: Colors.green,),
                          title: Text('${teacher.email}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                          subtitle: Text('Email Address', style: TextStyle(color: Colors.grey, fontSize: 13),),
                        ),
                        Container(color: Colors.grey.shade100,height: 1,),
                        ListTile(
                          leading: Icon(Icons.school, color: Colors.cyan,),
                          title: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection('schools').doc(teacher.school).snapshots(),
                            builder: (context, snapshot) {
                              return snapshot.hasData?
                              Text('${snapshot.data!.get('name')}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),):Container();
                            }
                          ),
                          subtitle: Text('School', style: TextStyle(color: Colors.grey, fontSize: 13),),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}
