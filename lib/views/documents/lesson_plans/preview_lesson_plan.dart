import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/components/ListTiles/image_leading_tile.dart';
import 'package:smart_teacher/helpers/pdf_helper.dart';
import 'package:smart_teacher/models/marks_model.dart';
import 'package:smart_teacher/views/documents/mark_schedule/add_marks.dart';
import '../../../components/kalutext.dart';
import '../../../controllers/my_classes_controller.dart';
import '../../../controllers/my_subjects_controller.dart';
import '../../../controllers/my_subscription_controller.dart';
import '../../../controllers/teacher_controller.dart';
import '../../../helpers/data_prefetch.dart';
import '../../../models/lesson_plan_model.dart';
import '../../../models/pupil_model.dart';
import '../../../services/ads_service.dart';
import '../../../utils/colors.dart';
import '../../settings/subscription/subscription.dart';
import 'add_lesson_plan.dart';


class PreviewLessonPlan extends StatefulWidget {
  LessonPlan lessonPlan;
  String? uid;
  PreviewLessonPlan({required this.lessonPlan, this.uid});

  @override
  State<PreviewLessonPlan> createState() => _PreviewLessonPlanState();
}

class _PreviewLessonPlanState extends State<PreviewLessonPlan> {
  MyClassesController _myClassesController = Get.find();

  MySubjectsController _mySubjectsController = Get.find();

  TeacherController _teacherController = Get.find();

  var classname = ''.obs;

  var intake = ''.obs;

  var subjectname = ''.obs;

  var selected_pupil = <PupilModel>[].obs;

  var test = 'add new'.obs;

  var marks = ''.obs;

  TextEditingController _ev = TextEditingController();

  TextEditingController _searchTechController = TextEditingController();

  TextEditingController _marksController = TextEditingController();

  TextEditingController _newassessmentController = TextEditingController();

  List<MarksModel>pupilsmarks=[];

  String getClassid(){
    var classid = _myClassesController.myclasses.where((c)=>c.name==widget.lessonPlan.grade).first.uid;

    return classid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
        child: Row(
          children: [
            GetBuilder<MySubscriptionController>(
                builder: (mysub) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (mysub.getCurrentSub()!=null&&mysub.getCurrentSub()!.isActive)?
                      ElevatedButton(onPressed: (){
                        PdfHelper().generateLessonPlanPdf(widget.lessonPlan);
                      }, child: Text('to PDF')) :
                      ElevatedButton(
                          onPressed: (){
                            //PdfHelper().generateClassListPdf(pupils.value, classname.value, intake.value, pupils.where((p)=>p.gender=='m').length, pupils.where((p)=>p.gender=='f').length);
                            //Get.to(()=>Subscription(), transition: Transition.fade);

                            printPdf(){
                              PdfHelper().generateLessonPlanPdf(widget.lessonPlan);
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
            SizedBox(width: 10,),
            ElevatedButton(onPressed: (){
              Get.bottomSheet(
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20
                    ),
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)
                      )
                    ),
                    child: ListView(
                      children: [
                        Text('Evaluation', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                        Divider(color: Colors.grey.shade100,),
                        SizedBox(height: 20,),
                        TextField(
                          controller: _ev,
                          decoration: InputDecoration(
                            hintText: 'Evaluation...',
                            hintStyle: TextStyle(
                              fontSize: 12
                            )
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                                onPressed: ()async{
                                  await FirebaseFirestore.instance.collection('lesson_plans').doc(widget.uid).update({'evaluation':_ev.text});
                                  Fluttertoast.showToast(msg: 'Save succefully!');
                                  Get.back();
                                },
                                child: Text('Save')
                            ),

                          ],
                        )
                      ],
                    ),
                  )
              );
            }, child: Text('Evaluate')),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('${widget.lessonPlan.topic}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: [
            SizedBox(height: 20,),
              Container(
                alignment: Alignment.center,
                child: Text('LESSON PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 20,),
              Container(
                child: Table(
                  children: [
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('NAME:     ${_teacherController.teacher.first.firstname}', style: TextStyle(fontSize: 9),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('DATE:     ${widget.lessonPlan.date.split(' ').first}', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance.collection('schools').doc(_teacherController.teacher.value.first.school).snapshots(),
                              builder: (context, s) {
                                return Text('SCHOOL:     ${s.hasData&&s.data!.exists?s.data!.get('name'):''}', style: TextStyle(fontSize: 9),);
                              }
                            ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('TIME:     ${widget.lessonPlan.time}', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('SUBJECT:     ${widget.lessonPlan.subject}', style: TextStyle(fontSize: 9),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('DURATION:     ${widget.lessonPlan.duration}', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('GRADE:     ${widget.lessonPlan.grade}', style: TextStyle(fontSize: 9),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('No. of Pupils: ', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('TOPIC:     ${widget.lessonPlan.topic}', style: TextStyle(fontSize: 9),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('Expected (Boys: ${widget.lessonPlan.expBoys}, Girls: ${widget.lessonPlan.expGirls})', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                    TableRow(
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text('SUB-TOPIC:     ${widget.lessonPlan.subtopic}', style: TextStyle(fontSize: 9),),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: Text('Actual (Boys: ${widget.lessonPlan.actBoys.isEmpty?'_____ ':widget.lessonPlan.actBoys} , Girls: ${widget.lessonPlan.actGirls==''?'_____':widget.lessonPlan.actGirls})', style: TextStyle(fontSize: 9),),
                        )
                      ]
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pre-requisite Knowledge', style: TextStyle(fontSize: 11),),
                    SizedBox(height: 4,),
                    Text('${widget.lessonPlan.preRequisiteKnowledge}',  style: TextStyle(fontSize: 9))
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LESSON OBJECTIVES: By the end of the lesson P.S.B.A.T', style: TextStyle(fontSize: 10),),
                    SizedBox(height: 4,),
                    Table(
                      columnWidths: {
                        0:FixedColumnWidth(10)
                      },
                      children: [
                        ...List.generate(widget.lessonPlan.objectives.length, (i)=>
                            TableRow(
                              children: [
                                Text('-', style: TextStyle(fontSize: 9)),
                                Text('${widget.lessonPlan.objectives[i]}',  style: TextStyle(fontSize: 9))
                              ]
                            )
                        )
                      ],
                    ),

                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RATIONALE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text('Content:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                        Text('  ${widget.lessonPlan.ratContent}', style: TextStyle(fontSize: 10),),
                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text('Value:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                        Text('  ${widget.lessonPlan.ratValue}', style: TextStyle(fontSize: 10),),
                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text('Position:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                        Text('  ${widget.lessonPlan.ratPosition}', style: TextStyle(fontSize: 10),),
                      ],
                    ),
                    SizedBox(height: 4,),
                    Row(
                      children: [
                        Text('Strategy:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                        Text('  ${widget.lessonPlan.ratStrategy}', style: TextStyle(fontSize: 10),),
                      ],
                    ),
                    SizedBox(height: 6,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TEACHING AND LEARNING RESOURCES: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(height: 4,),
                    Text('${widget.lessonPlan.teachingLearningResources}', style: TextStyle(fontSize: 10),),
                    SizedBox(height: 6,),
                    Text('REFERENCES: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(10)
                      },
                      children: [
                        ...widget.lessonPlan.references.map((ref)=>TableRow(
                          children: [
                            Text('-'),
                            Text(ref, style: TextStyle(fontSize: 10),)
                          ]
                        ))
                      ],
                    ),
                    Text('LESSON DEVELOPMENT: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    SizedBox(height: 4,),
                    Container(
                      child: Table(
                        border: TableBorder.all(),
                        children: [
                          TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text('TIME', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text('STEPS OR CONTENT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text('TEACHER\'S ACTIVITY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text('LEARNER\'S ACTIVITY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Text('ORG/METHOD', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                                ),
                              ]
                          ),
                          ...
                          widget.lessonPlan.lessonDevelopment.map((item){
                            return TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text('${item['time']}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${item['title']}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
                                        ...item['steps'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['teachers'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['learners'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['methods'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                ]
                            );
                          })
                        ],
                      ),
                    ),
                    SizedBox(height: 4,),
                    Text('CONCLUSION: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    Text('${widget.lessonPlan.conclusion}', style: TextStyle(fontSize: 10),),
                    SizedBox(height: 4,),
                    Text('FOLLOWUP EXERCISE: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    Text('${widget.lessonPlan.exercise}', style: TextStyle(fontSize: 10),),
                    SizedBox(height: 4,),
                    Text('EVALUATION: ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    Text('${widget.lessonPlan.evaluation}', style: TextStyle(fontSize: 10),),

                  ],
                ),
              ),
            SizedBox(height: 100,)
          ],
        ),
      )
    );
  }
}
