import 'package:admob_easy/ads/services/banner_ad.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:smart_teacher/components/ListTiles/image_leading_tile.dart';
import 'package:smart_teacher/helpers/pdf_helper.dart';
import 'package:smart_teacher/models/marks_model.dart';
import 'package:smart_teacher/views/documents/lesson_plans/edit_lesson_plan.dart';
import 'package:smart_teacher/views/documents/lesson_plans/preview_lesson_plan.dart';
import 'package:smart_teacher/views/documents/lesson_plans/reproduce_lesson_plan.dart';
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
import 'add_lesson_plan.dart';


class LessonPlans extends StatefulWidget {
  LessonPlans({super.key});

  @override
  State<LessonPlans> createState() => _LessonPlansState();
}

class _LessonPlansState extends State<LessonPlans> {
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

  var selectedYear = 2025.obs;
  var selectedClasses = [].obs;
  var selectedSubjects = [].obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AdsService().loadRewarded(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Lesson Plans', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
        actions: [
          IconButton(
              onPressed: (){
                Get.defaultDialog(
                  title: 'Filter',
                  titleStyle: GoogleFonts.gabarito(fontSize: 22),
                  titlePadding: EdgeInsets.only(top: 18),
                  content: Obx(
                        () => Container(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        shrinkWrap: true,
                        children: [
                          // Filter by Year
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                  child: Text(
                                    'By year',
                                    style: GoogleFonts.gabarito(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  children: List.generate(7, (i) {
                                    int year = DateTime.now().year - i;

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(22),
                                      onTap: () {
                                         selectedYear.value = year;
                                        selectedYear.refresh(); // Force UI update
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: selectedYear.value == year ? Karas.primary : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text('$year', style: TextStyle(fontSize: 13)),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          // Filter by Class
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                  child: Text(
                                    'By class',
                                    style: GoogleFonts.gabarito(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  children: _myClassesController.myclasses.value.map((item) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(22),
                                      onTap: () {
                                        if (selectedClasses.contains(item)) {
                                          selectedClasses.remove(item);
                                        } else {
                                          selectedClasses.add(item);
                                        }
                                        selectedClasses.refresh(); // Force UI update
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: selectedClasses.contains(item) ? Karas.primary : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(item.name, style: TextStyle(fontSize: 13)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          // Filter by Subject
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                  child: Text(
                                    'By subject',
                                    style: GoogleFonts.gabarito(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  children: _mySubjectsController.mysubjects.value.map((item) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(22),
                                      onTap: () {
                                        if (selectedSubjects.contains(item.subject.name)) {
                                          selectedSubjects.remove(item.subject.name);
                                        } else {
                                          selectedSubjects.add(item.subject.name);
                                        }
                                        selectedSubjects.refresh(); // Force UI update
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: selectedSubjects.contains(item.subject.name) ? Karas.primary : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(item.subject.name, style: TextStyle(fontSize: 13)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  confirm: ElevatedButton(onPressed: () {
                    Get.back();
                    setState((){});
                  }, child: Text('OK')),
                  onConfirm: ()=>Get.back(),
                  backgroundColor: Colors.white,
                );

              },
              icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Column(
        children: [
          GetBuilder<MySubscriptionController>(
              builder: (c){
                return c.getCurrentSub()!=null?c.getCurrentSub()!.isActive?Container():Container(margin: EdgeInsets.only(bottom: 10),child: AdMobEasyBanner()):SlideInDown(child: Container(margin: EdgeInsets.only(bottom: 10),child: AdMobEasyBanner()));
              }
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('lesson_plans')
                  .where('teacher', isEqualTo: _teacherController.teacher.first.uid)
                  .where('year', isEqualTo: selectedYear.value.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData&&
                snapshot.data!.docs.isNotEmpty) {
                  var filteredData = snapshot.data!.docs.where((doc){
                    return selectedSubjects.isEmpty || selectedSubjects.contains(doc.get('subject'))
                        || selectedClasses.isEmpty || selectedClasses.contains(doc.get('grade'));
                  }).toList();

                  return Container(
                  child: GroupedListView<dynamic, String>(
                    elements: filteredData,
                    groupBy: (element) => element['subject'].split(' ').first,
                    groupSeparatorBuilder: (String groupByValue) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(groupByValue, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    itemBuilder: (context, dynamic element) {
                      var lessonplan = LessonPlan.fromMap(element.data());

                      return ImageLeadingTile(
                        iconPath: 'assets/plan.png',
                        title: '${lessonplan.date.split(' ').first} ${lessonplan.time}',
                        subtitle: '${lessonplan.grade} | ${lessonplan.subject} | ${lessonplan.topic}',
                        ontap: (){
                          Get.to(()=>PreviewLessonPlan(lessonPlan: lessonplan, uid:element.id), transition: Transition.fade);
                        },
                        onlongpress: (){
                          Get.defaultDialog(
                            title: 'Action',
                            content: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20,),
                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: (){
                                          FirebaseFirestore.instance
                                              .collection('lesson_plans')
                                              .where('teacher', isEqualTo: lessonplan.teacher)
                                              .where('date', isEqualTo: lessonplan.date)
                                              .get()
                                              .then((d){
                                                   var id = d.docs.first.id;
                                                   FirebaseFirestore.instance
                                                       .collection('lesson_plans')
                                                   .doc(id).delete();
                                    
                                                   Fluttertoast.showToast(msg: 'Deleted successfully');
                                              });
                                        },
                                        child: Text('Delete')
                                    ),
                                  ),
                                  SizedBox(width: 20,),
                                  Expanded(child: ElevatedButton(
                                      onPressed: (){
                                        Get.to(()=>EditLessonPlan(lessonplan, element.id));
                                      },
                                      child: Text('Edit')
                                  )),
                                  SizedBox(width: 20,),
                                ],
                              ),
                            )
                          );
                        },
                        trailing:  PopupMenuButton(
                            itemBuilder: (c)=>[
                              PopupMenuItem(
                                onTap: (){
                                  Get.to(()=>EditLessonPlan(lessonplan, element.id));
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
                                  Get.to(()=>ReproduceLessonPlan(lessonplan, element.id));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 10,),
                                    SizedBox(width: 10,),
                                    Text('Re-produce'),
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
                                            FirebaseFirestore
                                                .instance
                                                .collection('lesson_plans')
                                                .doc(element.id)
                                                .delete();
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
                                            Text('Are you sure you want to delete this lesson plan?', style: TextStyle(fontSize: 16, color: Colors.red),textAlign: TextAlign.center,)
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
                    itemComparator: (item1, item2) => item1['subject'].compareTo(item2['subject']), // optional
                    useStickyGroupSeparators: true, // optional
                    floatingHeader: true, // optional
                    order: GroupedListOrder.ASC, // optional

                  ),
                );
                } else {
                  return Container(
                    width: double.infinity,
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/emptold.png'),
                      ],
                    ),
                  );
                }
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
             Get.to(()=>AddLessonPlan(), transition: Transition.fade);
          },
          child: Icon(Icons.add),
      ),
    );
  }
}
