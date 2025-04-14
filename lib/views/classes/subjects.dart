import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/my_subjects_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import '../../components/kalubtn.dart';
import '../../components/kalutext.dart';
import '../../helpers/common_methods.dart';
import '../../helpers/data_prefetch.dart';
import '../../utils/colors.dart';

class Subjects extends StatelessWidget {
  ClassModel classModel;
  Subjects({required this.classModel});

  var gender = 'm'.obs;
  var intake = '2025'.obs;

  TeacherController _teacherController = Get.find();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          TextEditingController _subjectName = TextEditingController();

          Get.bottomSheet(
              Container(
                height: 210,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)
                            )
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20
                          ),
                          child: Column(
                            children: [
                              Text('Add subject you teach ${classModel.name}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),),
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    SizedBox(height: 20,),
                                    Kalutext(controller: _subjectName, hintText: 'Subject Name',),
                                  ],
                                ),
                              ),
                              Kalubtn(
                                  label: 'Add',
                                  onclick: (){
                                    CommonMethods().addSubject(_subjectName.text, _teacherController.teacher.first.uid, classModel.uid, _teacherController.teacher.first.school);
                                  })
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
          );
        },
        child: Icon(Icons.add),
      ),
      body: GetBuilder<MySubjectsController>(
        builder: (mySubjectsController) {
          return Builder(
            //future: DataPrefetch().fetchMySubjects(_teacherController.teacher.first.uid, classModel.uid, _teacherController.teacher.first.school),
            builder: (context) {
              if (mySubjectsController.mysubjects.isNotEmpty) {
                var subjects = mySubjectsController.mysubjects!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: mySubjectsController.mysubjects.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var subject = subjects[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Karas.primary.withValues(alpha: 0.2),
                              radius: 16,
                              child: Icon(Icons.subject),
                            ),
                            title: Text(
                              '${subject.subject.name}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            trailing:  PopupMenuButton(
                                itemBuilder: (c)=>[
                                  PopupMenuItem(
                                    onTap: (){
                                      TextEditingController _subjectNameController = TextEditingController();

                                      _subjectNameController.text = subject.subject.name;
                                      Get.bottomSheet(
                                          Container(
                                            height: 240,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                              colors: [
                                                                Karas.secondary,
                                                                Color(
                                                                    0xFF049780)
                                                              ]
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors.black.withValues(alpha: 0.1),
                                                                blurRadius: 1,
                                                                spreadRadius: 1
                                                            )
                                                          ],
                                                          borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(20),
                                                            topLeft: Radius.circular(20),
                                                          )
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(height: 10,),
                                                          Container(
                                                            height: 8,
                                                            width: 40,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey,
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                          ),
                                                          SizedBox(height: 4,),
                                                          Expanded(
                                                              child: Container(
                                                                margin: EdgeInsets.all(8),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.grey.shade200,
                                                                    borderRadius: BorderRadius.circular(10)
                                                                ),
                                                                child: ListView(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: 20,
                                                                          vertical: 10
                                                                      ),
                                                                      child: Text('Edit subject', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                                                                    ),
                                                                    Divider(height: 8,),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    Container(
                                                                      child: Kalutext(
                                                                        controller: _subjectNameController,
                                                                        backgroundColor: Colors.white,
                                                                      ),
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: 20
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: [
                                                                          ElevatedButton(
                                                                              onPressed: (){
                                                                                mySubjectsController.mysubjects.value.where((ss)=>ss.subject.uid == subject.subject.uid).first.subject.name = _subjectNameController.text;
                                                                                mySubjectsController.update();

                                                                                FirebaseFirestore
                                                                                    .instance
                                                                                    .collection('subjects')
                                                                                    .doc(subject.subject.uid)
                                                                                    .update({'name': _subjectNameController.text});

                                                                                Fluttertoast.showToast(msg: 'Subject name updated!');
                                                                                Get.back();

                                                                              },
                                                                              child: Text('Save')
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                )
                                              ],
                                            ),
                                          ),
                                          barrierColor: Colors.black.withValues(alpha: 0.2)
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue, size: 18,),
                                        SizedBox(width: 10,),
                                        Text('Edit'),
                                      ],
                                    ),

                                  ),
                                  PopupMenuItem(
                                    onTap: (){
                                      Get.defaultDialog(
                                          title: 'Action',
                                          titleStyle: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold,),
                                          titlePadding: EdgeInsets.only(
                                              top: 10
                                          ),
                                          confirm: ElevatedButton(
                                              onPressed: ()async{
                                                mySubjectsController.mysubjects.value.removeWhere((ss)=>ss.subject.uid == subject.subject.uid);
                                                mySubjectsController.update();
                                                //FirebaseFirestore.instance.collection('teacher_class').doc(cls.uid).
                                                var doc = await FirebaseFirestore.instance.collection('teacher_subject')
                                                    .where('subject', isEqualTo: subject.subject.uid)
                                                    .where('class', isEqualTo: subject.classid)
                                                    .where('teacher', isEqualTo: _teacherController.teacher.first.uid).get();

                                                if(doc.docs.isNotEmpty){
                                                  FirebaseFirestore.instance.collection('teacher_subject_class').doc(doc.docs.first.id).delete();
                                                  Fluttertoast.showToast(msg: 'Subject removed successfully!');
                                                }
                                                Get.back();
                                              },
                                              child: Text('Confirm',)
                                          ),
                                          cancel: ElevatedButton(onPressed: (){Get.back();}, child: Text('Cancel')),
                                          backgroundColor: Karas.primary,
                                          content: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 10
                                            ),
                                            child: Column(
                                              children: [
                                                Text('Are you sure you want to remove  from my classes?', style: TextStyle(fontSize: 16, color: Colors.red),)
                                              ],
                                            ),
                                          )
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red, size: 18,),
                                        SizedBox(width: 10,),
                                        Text('Delete'),
                                      ],
                                    ),

                                  ),
                                ]
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: Text('No Subjects Found'));
              }
            },
          );
        }
      ),
    );
  }
}
