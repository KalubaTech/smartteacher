import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/views/classes/class_graduate.dart';
import 'package:smart_teacher/views/classes/pupils/pupil.dart';
import '../../components/kalubtn.dart';
import '../../components/kalutext.dart';
import '../../helpers/common_methods.dart';
import '../../helpers/data_prefetch.dart';
import '../../utils/colors.dart';

class Pupils extends StatefulWidget {
  ClassModel classModel;
  Pupils({required this.classModel});

  @override
  State<Pupils> createState() => _PupilsState();
}

class _PupilsState extends State<Pupils> {
  var gender = 'a'.obs;
 // Default to 'All'
  var intake = ''.obs;

  TeacherController _teacherController = Get.find();

  var pupilsList = <PupilModel>[].obs;

  @override
  Widget build(BuildContext context) {
    intake.value = '${DateTime.now().year}';
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController _pupilFName = TextEditingController();
          TextEditingController _pupilLName = TextEditingController();
          TextEditingController _pupilLEmail = TextEditingController();
          var gender = 'm'.obs;
          var intake = '${DateTime.now().year}'.obs;
          Get.bottomSheet(
            Container(
              height: 320,
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Add pupil to ${widget.classModel.name}',
                              style: GoogleFonts.gabarito(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  SizedBox(height: 20),
                                  Kalutext(
                                    controller: _pupilFName,
                                    hintText: 'First Name',
                                  ),
                                  Kalutext(
                                    controller: _pupilLName,
                                    hintText: 'Last Name',
                                  ),
                                  Kalutext(
                                    controller: _pupilLEmail,
                                    hintText: 'Email Address',
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('    Gender:'),
                                            SizedBox(width: 10),
                                            Obx(
                                                  () => DropdownButton(
                                                value: gender.value,
                                                items: [
                                                  DropdownMenuItem(
                                                    child: Text('Male'),
                                                    value: 'm',
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text('Female'),
                                                    value: 'f',
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  gender.value = value!;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('    Intake:'),
                                            SizedBox(width: 10),
                                            Obx(
                                                  () => DropdownButton(
                                                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                value: intake.value,
                                                items: List.generate(8, (i) {
                                                  int cYear = DateTime.now().year;
                                                  return DropdownMenuItem(
                                                    child: Text('${cYear - i}'),
                                                    value: '${cYear - i}',
                                                  );
                                                }),
                                                onChanged: (value) {
                                                  intake.value = value!;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Kalubtn(
                              label: 'Add',
                              onclick: () {
                                CommonMethods().addPupil(
                                  _pupilFName.text,
                                  _pupilLName.text,
                                  gender.value,
                                  intake.value,
                                  widget.classModel.uid,
                                  _teacherController.teacher.first.school,
                                  _pupilLEmail.text
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 80,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(
                      () => ClassGraduate(
                    classModel: widget.classModel,
                    intake: int.parse(intake.value),
                    pupils: pupilsList.value,
                  ),
                  transition: Transition.fade,
                );
              },
              child: Image.asset(
                'assets/share.png',
                width: 40,
              ),
            )
          ],
        ),
      ),
      body: FutureBuilder(
        future: DataPrefetch().fetchPupils(_teacherController.teacher.first.school),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            var pupils = snapshot.data!;

            var filtePupils = pupils.where((p) {
              return p.classid.map((i) => i.toString()).toList().contains(widget.classModel.uid);
            }).toList();

            return Obx(() {
              // Filter pupils based on selected gender and intake
              var filteredPupils = filtePupils.where((pupil) {
                bool matchesGender = gender.value == 'a' || pupil.gender == gender.value;
                bool matchesIntake = pupil.intake.contains(intake.value);
                return matchesGender && matchesIntake;
              }).toList();

              pupilsList.value = filtePupils;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Container(
                      color: Karas.primary.withValues(alpha: 0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  ' Gender:',
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                                SizedBox(width: 10),
                                Obx(
                                      () => DropdownButton(
                                    alignment: AlignmentDirectional.centerStart,
                                    value: gender.value,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text('All'),
                                        value: 'a',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Male'),
                                        value: 'm',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Female'),
                                        value: 'f',
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      gender.value = value!;
                                    },
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '    Year:',
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 34,
                                    width: 80,
                                    child: DropdownSearch<String>(
                                      decoratorProps: DropDownDecoratorProps(
                                        baseStyle: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 1,
                                            vertical: 1
                                          )
                                        )
                                      ),
                                      items: (a,b)=>pupils.expand((p) => p.intake).toList().map((s)=>s.toString()).toSet().toList(),
                                      selectedItem: intake.value,
                                      onChanged: (value) {
                                        // Update the reactive variable after the build process
                                        Future.microtask(() {
                                          intake.value = value!;
                                        });
                                      },
                                      compareFn: (x, y) => x == y,
                                      popupProps: PopupProps.menu(
                                        fit: FlexFit.loose,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredPupils.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var pupil = filteredPupils[index];
                        return ListTile(
                          onTap: (){
                            Get.to(()=>Pupil(pupil: pupil, classModel: widget.classModel,), transition: Transition.fade);
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withValues(alpha: 0.1),
                            radius: 16,
                            child: Icon(
                              pupil.gender=='m'? Icons.person: Icons.person_2,
                              color: Karas.primary,
                            ),
                          ),
                          title: Text(
                            '${pupil.firstname} ${pupil.lastname}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: PopupMenuButton(
                              itemBuilder: (c)=>[
                                PopupMenuItem(
                                  onTap: (){
                                    Get.to(()=>Pupil(pupil: pupil, classModel: widget.classModel,), transition: Transition.fade);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.area_chart, color: Colors.deepOrange, size: 18,),
                                      SizedBox(width: 10,),
                                      Text('Performance'),
                                    ],
                                  ),

                                ),
                                PopupMenuItem(
                                  onTap: (){
                                    var pupilGender = pupil.gender;
                                    TextEditingController _pupilFirstNameController = TextEditingController();
                                    TextEditingController _pupilLastNameController = TextEditingController();
                                    TextEditingController _emailController = TextEditingController();

                                    _pupilLastNameController.text = pupil.lastname;
                                    _pupilFirstNameController.text = pupil.firstname;
                                    _emailController.text = pupil.email;

                                    Get.bottomSheet(
                                        Container(
                                          height: 400,
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
                                                                    child: Text('Edit pupil details', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                                                                  ),
                                                                  Divider(height: 8,),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    child: Kalutext(
                                                                      controller: _pupilFirstNameController,
                                                                      backgroundColor: Colors.white,
                                                                      hintText: 'First Name',
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 20
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    child: Kalutext(
                                                                      controller: _pupilLastNameController,
                                                                      backgroundColor: Colors.white,
                                                                      hintText: 'Last Name',
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 20
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    child: Kalutext(
                                                                      controller: _emailController,
                                                                      backgroundColor: Colors.white,
                                                                      hintText: 'Email Address',
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal: 20
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal: 20,
                                                                      vertical: 0
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Text('Gender:  '),
                                                                        DropdownButton(
                                                                          value: pupilGender,
                                                                          items: [
                                                                            DropdownMenuItem(
                                                                              child: Text('Male'),
                                                                              value: 'm',
                                                                            ),
                                                                            DropdownMenuItem(
                                                                              child: Text('Female'),
                                                                              value: 'f',
                                                                            ),
                                                                          ],
                                                                          onChanged: (value) {
                                                                            pupilGender = value!;
                                                                          },
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        ElevatedButton(
                                                                            onPressed: (){
                                                                       /*       mySubjectsController.mysubjects.value.where((ss)=>ss.subject.uid == subject.subject.uid).first.subject.name = _subjectNameController.text;
                                                                              mySubjectsController.update();

                                                                              FirebaseFirestore
                                                                                  .instance
                                                                                  .collection('subjects')
                                                                                  .doc(subject.subject.uid)
                                                                                  .update({'name': _subjectNameController.text});
*/

                                                                              FirebaseFirestore
                                                                                  .instance
                                                                                  .collection('pupils')
                                                                                  .doc(pupil.uid)
                                                                                  .update(
                                                                                  {
                                                                                    'firstname': _pupilFirstNameController.text,
                                                                                    'lastname':_pupilLastNameController.text,
                                                                                    'gender':pupilGender,
                                                                                    'email':_emailController.text
                                                                                  }
                                                                              );
                                                                              Fluttertoast.showToast(msg: 'Pupil details updated!');
                                                                              setState(() {
                                                                                intake.value = pupil.intake.last;
                                                                              });
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
                              /*                mySubjectsController.mysubjects.value.removeWhere((ss)=>ss.subject.uid == subject.subject.uid);
                                              mySubjectsController.update();
                                              //FirebaseFirestore.instance.collection('teacher_class').doc(cls.uid).
                                              var doc = await FirebaseFirestore.instance.collection('teacher_subject')
                                                  .where('subject', isEqualTo: subject.subject.uid)
                                                  .where('class', isEqualTo: subject.classid)
                                                  .where('teacher', isEqualTo: _teacherController.teacher.first.uid).get();

                                              if(doc.docs.isNotEmpty){
                                                FirebaseFirestore.instance.collection('teacher_subject_class').doc(doc.docs.first.id).delete();
                                                Fluttertoast.showToast(msg: 'Subject removed successfully!');
                                              }*/
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
            });
          } else {
            return Center(child: Text('No Pupils Found'));
          }
        },
      ),
    );
  }
}