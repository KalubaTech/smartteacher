import 'package:flutter/material.dart';
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
        builder: (context) {
          return FutureBuilder(
            future: DataPrefetch().fetchMySubjects(_teacherController.teacher.first.uid, classModel.uid, _teacherController.teacher.first.school),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                var subjects = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var subject = subjects[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Karas.primary.withOpacity(0.2),
                              radius: 16,
                              child: Icon(Icons.subject),
                            ),
                            title: Text(
                              '${subject.subject.name}',
                              style: TextStyle(fontSize: 14),
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
