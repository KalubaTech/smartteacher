import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/pdf_helper.dart';
import 'package:smart_teacher/models/marks_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';

import '../../../controllers/my_subscription_controller.dart';
import '../../../services/ads_service.dart';

class GenerateForPupil extends StatefulWidget {
  String classid;
  String year;
  PupilModel pupil;


  GenerateForPupil({required this.classid, required this.year, required this.pupil});

  @override
  State<GenerateForPupil> createState() => _GenerateForPupilState();
}

class _GenerateForPupilState extends State<GenerateForPupil> {

  TeacherController _teacherController = Get.find();
  String selectedAssessment = '';

  List<Map>marks=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.pupil.firstname} ${widget.pupil.lastname}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20),),
      ),
      body: Container(
        child: Column( 
          children: [
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey.shade300,
                )
              ),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore
                          .instance.collection('assessment_types')
                          .where('school', isEqualTo: _teacherController.teacher.first.school).orderBy('assessment')
                          .snapshots(),
                      builder: (context, snapshot) {
                        return SizedBox(
                          height: 40,
                          child: DropdownSearch(
                            compareFn: (a, b) => b == a,
                            items: (String filter, b) async {
                              return [
                                //... _myClassesController.myclasses.map((cls)=>cls.name)
                                ...
                                snapshot.data!.docs.map((doc)=>doc.get('assessment')).toList()
                              ];
                            },
                            selectedItem: '',
                            onChanged: (value) {
                              setState(() {
                               // selected_class = _myClassesController.myclasses.where((cl)=>cl.name==value).first.uid;
                                selectedAssessment = value;
                              });
                        
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'Assessment Type',
                                filled: true,
                                fillColor: Colors.grey.shade100,
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
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10
                  ),
                  child: StreamBuilder(
                      stream: FirebaseFirestore
                          .instance.collection('results')
                          .where('assessment', isEqualTo: selectedAssessment)
                          .where('class', isEqualTo: widget.classid)
                          .where('pupil', isEqualTo: widget.pupil.uid)
                          .orderBy('marks', descending: true)
                          .snapshots(),
                      builder: (c,s){
                        if (s.hasData) {
                          marks = s.data!.docs.map((doc)=>{'subject':doc.get('subject'), 'marks':doc.get('marks')}).toList();
                          return Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade200
                              ),
                              columnWidths: {
                                0: FixedColumnWidth(40),
                                2: FixedColumnWidth(70),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('SN', style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('SUBJECT', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('MARKS', style: TextStyle(fontWeight: FontWeight.bold)),
                                    )
                                  ]
                                ),
                                ... List.generate(s.data!.docs.length, (i){
                                  var doc = s.data!.docs[i];
                                  return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('${i + 1}', textAlign: TextAlign.center,),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('${doc.get('subject')}'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('${doc.get('marks')}'),
                                        ),
                                      ]
                                  );
                                })
                              ],
                            ),
                          ),
                        );
                        } else {
                          return Container();
                        }
                      }
                  ),
                )
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    ElevatedButton(
                        onPressed: (){

                          PdfHelper().generateReportFormPdf(widget.pupil, widget.classid, marks, selectedAssessment, widget.year);
                        },
                        child: GetBuilder<MySubscriptionController>(
                            builder: (mysub) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  (mysub.getCurrentSub()!=null&&mysub.getCurrentSub()!.isActive)?
                                  ElevatedButton(
                                    onPressed: (){
                                      PdfHelper().generateReportFormPdf(widget.pupil, widget.classid, marks, selectedAssessment, widget.year);
                                    },
                                    child: Text('PDF'),
                                  ) :
                                  ElevatedButton(
                                      onPressed: ()async{

                                        void  printPdf(){
                                          PdfHelper().generateReportFormPdf(widget.pupil, widget.classid, marks, selectedAssessment, widget.year);
                                        }
                                        //Get.to(()=>Subscription(), transition: Transition.fade);
                                        AdsService().showRewarded(context, printPdf);

                                        //
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
                    )
                ],
              ),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
