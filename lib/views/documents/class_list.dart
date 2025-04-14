import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/my_school_controller.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/helpers/pdf_helper.dart';
import 'package:smart_teacher/services/ads_service.dart';
import 'package:smart_teacher/views/settings/subscription/subscription.dart';

import '../../models/pupil_model.dart';

class ClassList extends StatefulWidget {
  ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  var classname = 'Select Class'.obs;

  var intake = ''.obs;

  MyClassesController _myClassesController = Get.find();
  TeacherController _teacherController = Get.find();

  var pupils = <PupilModel>[].obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //AdsService().loadRewarded(context);
  }

  @override
  Widget build(BuildContext context) {
    AdsService().loadRewarded(context);
    intake.value = '${DateTime.now().year}';


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Class List', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      body: GetBuilder<MySchoolController>(
        builder: (mysubController) {
          return Container(
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
                Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      children: [
                        Container(
                          child: Obx(
                        ()=> classname.value.toLowerCase()!='select class'?FutureBuilder(
                                future: DataPrefetch().fetchPupils(''
                                    '${classname.value.toLowerCase()!='select class'?_teacherController.teacher.first.school:''}'
                                    ''),
                                builder: (c,s){
                                  if (s.hasData&&s.data!.isNotEmpty) {

                                    var filtersByClass = s.data!.where((pupil){
                                      var classid =
                                      _myClassesController.myclasses.value.where((cls)=>cls.name.toLowerCase()==classname.value.toLowerCase()).first.uid;
                                      return pupil.classid.contains(classid);
                                    });

                                    pupils.value = filtersByClass.toList();

                                    return SlideInUp(
                                    child: Obx(
                                      ()=> Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8
                                              ),
                                              child: Row(
                                                children: [
                                                  Text('Class: ${classname}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500, color: Colors.grey),),
                                                  Spacer(),
                                                  Text('Total: ${filtersByClass.where((b)=>b.intake.contains(intake.value)).length}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500, color: Colors.grey),),
                                                  SizedBox(width: 20,),
                                                  Row(
                                                    children: [
                                                      Text('Male: ${s.data!.where((b)=>b.intake.contains(intake.value)&&b.gender=='m').length}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500, color: Colors.grey)),
                                                      SizedBox(width:20,),
                                                      Text('Female: ${s.data!.where((b)=>b.intake.contains(intake.value)&&b.gender=='f').length}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500, color: Colors.grey)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Table(
                                              columnWidths: {
                                                0: FixedColumnWidth(40.0), // Set a smaller width for SN column
                                                2: FixedColumnWidth(70.0),
                                              },
                                              border: TableBorder.all(color: Colors.black),  // Border for the table cells
                                              children: [
                                                TableRow(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('SN', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500),),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Name', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500)),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text('Gender', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500)),
                                                      ),
                                                    ]
                                                ),
                                                ... List.generate(filtersByClass.where((pupil)=>pupil.intake.contains(intake.value)).length, (i) {
                                                  var pupil = filtersByClass.where((pupil)=>pupil.intake.contains(intake.value)).toList()[i];
                                                  return TableRow(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text('${i+1}'),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text('${pupil.firstname} ${pupil.lastname}'),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text('${pupil.gender=='f'?'Female':'Male'}'),
                                                          ),
                                                        ]
                                                    );
                                                })

                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                  } else {
                                    return Container();
                                  }
                                }
                            ):Container(),
                          ),
                        )
                      ],
                    )
                )
              ],
            ),
          );
        }
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 20
        ),
        width: double.infinity,
        height: 80,
        child: GetBuilder<MySubscriptionController>(
          builder: (mysub) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (mysub.getCurrentSub()!=null&&mysub.getCurrentSub()!.isActive)?
                ElevatedButton(
                    onPressed: (){
                      PdfHelper().generateClassListPdf(pupils.value, classname.value, intake.value, pupils.where((p)=>p.gender=='m').length, pupils.where((p)=>p.gender=='f').length);
                    },
                    child: Text('PDF'),
                ) :
                ElevatedButton(
                    onPressed: ()async{

                      void  printPdf(){
                        PdfHelper().generateClassListPdf(pupils.value, classname.value, intake.value, pupils.where((p)=>p.gender=='m').length, pupils.where((p)=>p.gender=='f').length);
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
      ),
    );
  }
}
