import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/documents/report_forms/generate_for_pupil.dart';

class ReportForms extends StatefulWidget {
  ReportForms({super.key});

  @override
  State<ReportForms> createState() => _ReportFormsState();
}

class _ReportFormsState extends State<ReportForms> {
  String selected_class = '';

  String selected_year = '';

  MyClassesController _myClassesController = Get.find();

  TeacherController _teacherController = Get.find();

  List<PupilModel> pupils = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Forms', style: GoogleFonts.gabarito(fontSize: 20, fontWeight:  FontWeight.bold),),
        actions: [

        ],
      ),
      backgroundColor: Colors.white, 
      body: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300
                  )
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch(
                          compareFn: (a, b) => true,
                          items: (String filter, b) async {
                            return [
                              ... _myClassesController.myclasses.map((cls)=>cls.name)
                            ];
                          },
                          selectedItem: '',
                          onChanged: (value) {
                            setState(() {
                              selected_class = _myClassesController.myclasses.where((cl)=>cl.name==value).first.uid;
                            });

                          },
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Select Class',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                          ),
                          popupProps: const PopupProps.menu(
                            fit: FlexFit.loose,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                        child: SizedBox(
                      height: 40,
                      child: FutureBuilder(
                        future: DataPrefetch().fetchClassPupils(selected_class, _teacherController.teacher.first.school),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            pupils = snapshot.data!;
                            return DropdownSearch(
                            compareFn: (a, b) => true,
                            items: (String filter, b) async {
                              return [
                                  ... snapshot.data!
                                      .expand((pupil) => pupil.intake)
                                      .toSet()
                                      .toList()
                              ];
                            },
                            selectedItem: '',
                            onChanged: (value) {
                              setState(()=>selected_year = value);
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Select Year',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade400)
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            popupProps: const PopupProps.menu(
                              fit: FlexFit.loose,
                            ),
                          );
                          } else {
                            return Container();
                          }
                        }
                      ),
                    )
                    ),
                  ],
                )
              ),
      /*Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('collabo')
              .where('class', isEqualTo: selected_class)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              var doc = snapshot.data!.docs.first;
              String teacherId = doc.get('teacherid');
              List<dynamic> teachers = doc.get('teachers') ?? [];
              String currentTeacherId = _teacherController.teacher.first.uid;

              // If already accepted, hide the button
              if (teachers.contains(currentTeacherId)) {
                return Container();
              }

              // If the current teacher is the same as teacherid, show Request button
              if (teacherId == currentTeacherId) {
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Request teacher collaboration for ${_myClassesController.myclasses.where((c) => c.uid == selected_class).first.name}',
                        style: GoogleFonts.gabarito(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        CommonMethods().requestCollabos(selected_class, currentTeacherId);
                      },
                      icon: Icon(Icons.arrow_forward),
                    )
                  ],
                );
              }

              // If another teacher is viewing the request
              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      teachers.contains(currentTeacherId) ? 'Cancel teacher collaboration' : 'Accept teacher collaboration for ${selected_class.isNotEmpty?_myClassesController.myclasses.where((c) => c.uid == selected_class).first.name:''}',
                      style: GoogleFonts.gabarito(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  teachers.contains(currentTeacherId)
                      ? IconButton(
                    onPressed: () {
                      CommonMethods().cancelCollabo(doc.id, currentTeacherId);
                    },
                    icon: Icon(Icons.cancel, color: Colors.red),
                  )
                      : IconButton(
                    onPressed: () {
                      List newTeachers = List.from(teachers);
                      newTeachers.add(currentTeacherId);
                      CommonMethods().acceptCollabo(doc.id, newTeachers);
                    },
                    icon: Icon(Icons.done, color: Colors.green),
                  )
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),*/
      Container(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ... pupils.where((p)=>p.classid.contains(selected_class) && p.intake.contains(selected_year)).map((p)=> ListTile(
                      leading: Container(
                        child: CircleAvatar(
                          backgroundColor: Karas.primary,
                          radius: 16,
                            child: Icon(Icons.person, )
                        ),
                      ),
                      onTap: (){
                        Get.to(()=>GenerateForPupil(classid: selected_class, year: selected_year, pupil: p), transition: Transition.fade);
                      },
                      title: Text('${p.firstname} ${p.lastname}', style: GoogleFonts.gabarito(),),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Karas.primary,),
                    ))
                  ],
                ),
              )
            ],
          ),
      ),
    );
  }
}
