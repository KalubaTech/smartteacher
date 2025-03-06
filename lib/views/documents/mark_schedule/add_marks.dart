import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/my_subjects_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/pupil_model.dart';

class AddMarks extends StatefulWidget {
  AddMarks({super.key});

  @override
  State<AddMarks> createState() => _AddMarksState();
}

class _AddMarksState extends State<AddMarks> {
  MyClassesController _myClassesController = Get.find();

  MySubjectsController _mySubjectsController = Get.find();

  TeacherController _teacherController = Get.find();

  var classname = ''.obs;

  var intake = ''.obs;

  var subjectname = ''.obs;

  var selected_pupil = <PupilModel>[].obs;
  var test = 'add new'.obs;
  var marks = ''.obs;

  TextEditingController _searchTechController = TextEditingController();
  TextEditingController _marksController = TextEditingController();
  TextEditingController _newassessmentController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _marksController.addListener((){
      marks.value = _marksController.text;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Marks', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
              ),
              child: Row(
                children: [
                  Expanded(
                      child: SizedBox(
                        height: 40,
                        child: DropdownSearch<String>(
                          items: (a,b)=> [
                            ..._myClassesController.myclasses.value.map((c)=>c.name).toList()
                          ],
                          selectedItem: classname.value,
                          onChanged: (value) {
                            if (value != null) {
                              classname.value = value;
                            }
                          },
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                          ),
                          popupProps: const PopupProps.menu(fit: FlexFit.loose),
                        ),
                      )
                  ),
                  SizedBox(width: 10,),
                  SizedBox(
                      width: 100,
                      height: 40,
                      child: DropdownSearch<String>(
                        items: (a,b)=> [
                          //...s.data!.map((c)=>c.intake).toSet().toList()
                          ...List.generate(20, (i)=>(DateTime.now().year-i).toString()).toList()
                        ],
                        selectedItem: intake.value,
                        onChanged: (value) {
                          if (value != null) {
                            intake.value = value;
                          }
                        },
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Intake',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                        ),
                        popupProps: const PopupProps.menu(fit: FlexFit.loose),
                      )
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    ()=> Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20
                      ),
                      child: classname.value.isNotEmpty?
                      FutureBuilder(
                        future: DataPrefetch().fetchMySubjects(_teacherController.teacher.first.uid, _myClassesController.myclasses.value.where((cls)=>cls.name.toLowerCase()==classname.value.toLowerCase()).first.uid, _teacherController.teacher.first.school),
                        builder: (context, snapshot) {
                          return DropdownSearch<String>(
                            items: (a,b)=> [
                              ...snapshot.data!.map((mysubject)=>mysubject.subject.name).toList()
                            ],
                            selectedItem: subjectname.value,
                            onChanged: (value) {
                              if (value != null) {
                                subjectname.value = value;
                              }
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey)
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            popupProps: const PopupProps.menu(fit: FlexFit.loose),
                          );
                        }
                      ):DropdownSearch<String>(
                        items: (a,b)=> [

                        ],
                        selectedItem: subjectname.value,
                        onChanged: (value) {
                          if (value != null) {
                            subjectname.value = value;
                          }
                        },
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey)
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                          ),
                        ),
                        popupProps: const PopupProps.menu(fit: FlexFit.loose),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: 120,
                    height: 40,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('assessment_types').where('school', isEqualTo: _teacherController.teacher.first.school).snapshots(),
                      builder: (context, snapshot) {
                        return DropdownSearch<String>(
                          items: (a,b)=> [
                            'Add new',
                            ...snapshot.data!.docs.map((doc)=>doc.get('assessment')).toList()
                          ],
                          selectedItem: test.value.toLowerCase()=='add new'?'':test.value,
                          onChanged: (value) {
                            if (value != null) {
                              //print(value);
                              if(value.toLowerCase()=='add new'){
                                  Get.bottomSheet(
                                      Container(
                                        height: 250,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20)
                                          )
                                        ),
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20
                                        ),
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            Text('Add assessment', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),),
                                            SizedBox(height: 20,),
                                            Kalutext(
                                                controller: _newassessmentController,
                                              hintText: 'E.g. Test 1 / Mock exam',
                                            ),
                                            SizedBox(height: 20,),
                                            ElevatedButton(
                                                onPressed: (){
                                                  FirebaseFirestore.instance
                                                      .collection('assessment_types')
                                                      .add({'assessment':_newassessmentController.text, 'school':_teacherController.teacher.first.school});
                                                      Fluttertoast.showToast(msg: 'Added successfully');
                                                      Get.back();
                                                },
                                                child: Text('Save')
                                            )
                                          ],
                                        ),
                                      )
                                  );
                              }else{
                                test.value = value;
                              }
                            }
                          },
                          decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: 'Assessment',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                            ),
                          ),
                          popupProps: const PopupProps.menu(fit: FlexFit.loose),
                        );
                      }
                    )
                ),
                SizedBox(width: 20,)
              ],
            ),
            SizedBox(height: 10,),
            Container(
              height: 45,
              padding: EdgeInsets.symmetric(
                  horizontal: 20
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pupil', style: TextStyle(fontSize: 12, color: Colors.grey),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(()=> Text(selected_pupil.value.isNotEmpty?'${selected_pupil.value.first.firstname} ${selected_pupil.value.first.lastname}':'Select pupil', style: GoogleFonts.gabarito(fontSize: 16),)),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: (){
                          Get.bottomSheet(
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10,),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text('Pupils', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20),),
                                  ),
                                  SizedBox(height: 10,),
                                  Expanded(
                                      child: Container(
                                        child: ListView(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20
                                          ),
                                          shrinkWrap: true,
                                          children: [
                                            Kalutext(
                                                controller: _searchTechController,
                                              hintText: 'Search Pupil',
                                            ),
                                            FutureBuilder(
                                                future: DataPrefetch().fetchPupils(''
                                                    '${classname.value.toLowerCase()!='select class'?_teacherController.teacher.first.school:''}'
                                                    ''),
                                                
                                                //_myClassesController.myclasses.value.where((cls)=>cls.name.toLowerCase()==classname.value.toLowerCase()).first.uid
                                                builder: (c,s){
                                                  return s.hasData?
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          ...
                                                          s.data!.where((pupil)=>pupil.intake.contains(intake.value))
                                                              .toList().map((pupil) {
                                                           // s.data!.where((pupil)=>pupil.intake==intake.value).toList();
                                                            //print(pupils.value.length);
                                                            return InkWell(
                                                              onTap: (){
                                                                selected_pupil.value.clear();
                                                                selected_pupil.value.add(pupil);
                                                                setState(()=>{});
                                                                Get.back();
                                                              },
                                                              child: Container(
                                                                width: double.infinity,
                                                                 padding: EdgeInsets.symmetric(
                                                                   horizontal: 8,
                                                                   vertical: 8
                                                                 ),
                                                                  child: Text('${pupil.firstname} ${pupil.lastname}', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.w500),)
                                                              ),
                                                            );
                                                          })
                                                        ],
                                                      )
                                                      : Container();
                                                }
                                            )
                                          ],
                                        ),
                                      )
                                  )
                                ],
                              ),
                            ),
                            backgroundColor: Colors.white
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey
                            )
                          ),
                          child: Row(
                            children: [
                              Text(' Change', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),),
                              SizedBox(width: 8,),
                              Icon(Icons.arrow_drop_down_circle, color: Colors.green,)
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Divider(color: Colors.grey.shade100,),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marks:', style: GoogleFonts.gabarito(),),
                  SizedBox(width: 10,),
                  Container(
                    width: 100,
                    child: Kalutext(
                        controller: _marksController, 
                        borderRadius: BorderRadius.circular(4),
                        hintText: '---',
                        isNumber: true,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    ()=> marks.value.isNotEmpty?ElevatedButton(
                        onPressed: (){
                            Map<String, dynamic> data = {
                              'class':_myClassesController.myclasses.value.where((cls)=>cls.name == classname.value).first.uid,
                              'subject':subjectname.value,
                              'assessment':test.value,
                              'pupil':selected_pupil.first.uid,
                              'marks':_marksController.text,
                              'teacher':_teacherController.teacher.value.first.uid,
                              'year': intake.value
                            };
                            FirebaseFirestore.instance.collection('results').add(data).then((d){
                              _marksController.clear();
                            });
                        },
                        child: Text('Save')
                    ):Container(),
                  )
                ],
              ),
            ),
            Divider(),
            Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('     Preview', style: GoogleFonts.gabarito(color: Colors.grey),),
                      Expanded(
                        child: Obx(
                            ()=>classname.value.isNotEmpty ? StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('results')
                                .where('teacher', isEqualTo: _teacherController.teacher.first.uid)
                                .where('subject', isEqualTo: subjectname.value)
                                .where('assessment', isEqualTo: test.value)
                                .where(
                              'class',
                              isEqualTo: _myClassesController.myclasses.value
                                  .where((cls) => cls.name == classname.value)
                                  .first
                                  .uid,
                            )
                                .orderBy('marks', descending: true) // Order by highest marks
                            .snapshots(),
                            builder: (context, snapshot) {
                              return snapshot.hasData && snapshot.data!.docs.isNotEmpty
                                  ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: {
                                    0: FixedColumnWidth(40),
                                    2: FixedColumnWidth(60),
                                    3: FixedColumnWidth(60),
                                  },
                                  children: [
                                    TableRow(children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Text(
                                          'SN',
                                          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Text(
                                          'Pupil',
                                          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Text(
                                          'Marks',
                                          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Text(
                                          'Action',
                                          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ]),
                                    ...
                                    List.generate(snapshot.data!.size, (i){
                                      var doc = snapshot.data!.docs[i];
                                      return TableRow(children: [
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Text('${i+1}'),
                                        ),
                                        FutureBuilder(
                                            future: DataPrefetch().fetchPupil(doc.get('pupil')),
                                            builder: (context, s) {
                                              return s.hasData
                                                  ? Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 8),
                                                child: Text(
                                                    '${s.data!.firstname} ${s.data!.lastname}'),
                                              )
                                                  : Text('');
                                            }),
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Text('${doc.get('marks')}'),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                onTap: () {
                                                  FirebaseFirestore.instance
                                                      .collection('results')
                                                      .doc(doc.id)
                                                      .delete();
                                                  Fluttertoast.showToast(msg: 'Deleted');
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ]);
                                    })
                                  ],
                                ),
                              )
                                  : Container();
                            },
                          ):Container(),
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
  }
}
