import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/helpers/pdf_helper.dart';
import 'package:smart_teacher/models/marks_model.dart';
import 'package:smart_teacher/views/documents/mark_schedule/add_marks.dart';
import '../../../components/kalutext.dart';
import '../../../controllers/my_classes_controller.dart';
import '../../../controllers/my_subjects_controller.dart';
import '../../../controllers/my_subscription_controller.dart';
import '../../../controllers/teacher_controller.dart';
import '../../../helpers/data_prefetch.dart';
import '../../../models/pupil_model.dart';
import '../../../services/ads_service.dart';
import '../../../utils/colors.dart';
import '../../settings/subscription/subscription.dart';


class MarkSchedule extends StatefulWidget {
  MarkSchedule({super.key});

  @override
  State<MarkSchedule> createState() => _MarkScheduleState();
}

class _MarkScheduleState extends State<MarkSchedule> {
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

  List<MarksModel>pupilsmarks=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //AdsService().loadRewarded(context);
  }

  @override
  Widget build(BuildContext context) {
    AdsService().loadRewarded(context);
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 80,
        child: GetBuilder<MySubscriptionController>(
          builder: (mysub) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (mysub.getCurrentSub()!=null&&mysub.getCurrentSub()!.isActive)?
                ElevatedButton(onPressed: (){
                  PdfHelper().generateMarkSchedulePdf(classname.value, pupilsmarks, test.value, subjectname.value, intake.value);
                }, child: Text('to PDF')) :
                ElevatedButton(
                    onPressed: (){
                      //PdfHelper().generateClassListPdf(pupils.value, classname.value, intake.value, pupils.where((p)=>p.gender=='m').length, pupils.where((p)=>p.gender=='f').length);
                      //Get.to(()=>Subscription(), transition: Transition.fade);

                      printPdf(){
                        PdfHelper().generateMarkSchedulePdf(classname.value, pupilsmarks, test.value, subjectname.value, intake.value);
                      }
                      AdsService().showRewarded(context, printPdf);
                    },
                    child: Row(
                      children: [
                        Text('PDF'),
                        SizedBox(width: 10,),
                        Icon(Icons.workspace_premium, color: Colors.orange,),
                      ],
                    )
                )
              ],
            );
          }
      ),
      ),
      appBar: AppBar(
        title: Text('Mark Schedule', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(15),
              padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20
              ),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300)
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
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
                                  labelText: 'Year',
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
                        ),
                        SizedBox(width: 10,),
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
                       ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                                ()=> Container(
                              height: 40,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0
                              ),
                              child: classname.value.isNotEmpty?
                              FutureBuilder(
                                  future: DataPrefetch().fetchMySubjects(_teacherController.teacher.first.uid, _myClassesController.myclasses.value.where((cls)=>cls.name.toLowerCase()==classname.value.toLowerCase()).first.uid, _teacherController.teacher.first.school),
                                  builder: (context, snapshot) {
                                    return snapshot.hasData&&snapshot.data!.isNotEmpty?
                                    DropdownSearch<String>(
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
                                    ):Container();
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
                        SizedBox(width: 10,),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Divider(color: Colors.grey.shade100,),
            Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('     Preview', style: GoogleFonts.gabarito(color: Karas.primary, fontWeight: FontWeight.bold, ),),
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
                                    List.generate(snapshot.data!.docs.length, (i){
                                      var doc = snapshot.data!.docs[i];
                                      var pupilmarks = MarksModel(pupil: doc.get('pupil'), marks: doc.get('marks'));

                                      print(pupilmarks.pupil);
                                      pupilsmarks.add(pupilmarks);
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              ),
                                              InkWell(
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 18,
                                                ),
                                                onTap: () {

                                                  TextEditingController _marksController = TextEditingController();

                                                  _marksController.text = doc.get('marks');

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
                                                                                  child: Text('Edit marks', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                                                                                ),
                                                                                Divider(height: 8,),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Container(
                                                                                  child: Kalutext(
                                                                                    controller: _marksController,
                                                                                    backgroundColor: Colors.white,
                                                                                    isNumber: true,
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


                                                                                            FirebaseFirestore.instance
                                                                                                .collection('results')
                                                                                                .doc(doc.id)
                                                                                                .update({'marks': _marksController.text});
                                                                                            Fluttertoast.showToast(msg: 'Updated!');

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
                                              ),
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
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: () {
          Get.to(()=>AddMarks(), transition: Transition.fadeIn);
        },
        child: Icon(Icons.add, color: Colors.white,),
        //params
      ),
    );
  }
}
