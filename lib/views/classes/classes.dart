import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/ListTiles/classpupils_add_listtile.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/views/classes/add_class.dart';
import 'package:smart_teacher/views/classes/view_class.dart';
import '../../utils/colors.dart';

class Classes extends StatelessWidget {
  Classes({super.key});


  TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Classes', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: () {
          Get.to(()=>AddClass(), transition: Transition.fadeIn);
        },
        child: Icon(Icons.add, color: Colors.white,),
        //params
      ),
      backgroundColor: Colors.white,
      body: GetBuilder<MyClassesController>(
        builder: (myClassesController) {
          List<ClassModel> myClasses = myClassesController.myclasses.value;
          return myClasses.isNotEmpty?
          Container(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              padding: EdgeInsets.all(6),
              children: [
                ...myClasses.map((cls)=>
                    Card(
                      child: InkWell(
                        onTap: (){
                          Get.to(()=>ViewClass(classModel: cls), transition: Transition.fade);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                colors: [
                                  Karas.primary.withValues(alpha: 0.4),
                                  Color(0xff05d180),
                                ]
                            )
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(child: Container()),
                                  PopupMenuButton(
                                      itemBuilder: (c)=>[
                                        PopupMenuItem(
                                          onTap: (){
                                            TextEditingController _clsNameController = TextEditingController();

                                            _clsNameController.text = cls.name;
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
                                                                            child: Text('Edit class', style: GoogleFonts.gabarito(fontSize: 18, fontWeight: FontWeight.bold),),
                                                                          ),
                                                                          Divider(height: 8,),
                                                                          SizedBox(
                                                                            height: 10,
                                                                          ),
                                                                          Container(
                                                                            child: Kalutext(
                                                                              controller: _clsNameController,
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
                                                                                      myClassesController.myclasses.value.where((cc)=>cc.uid == cls.uid).first.name = _clsNameController.text;
                                                                                      myClassesController.update();

                                                                                      FirebaseFirestore
                                                                                          .instance
                                                                                          .collection('classes')
                                                                                          .doc(cls.uid)
                                                                                          .update({'name': _clsNameController.text});

                                                                                      Fluttertoast.showToast(msg: 'Class name updated!');

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
                                                barrierColor: Colors.black.withOpacity(0.2)
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
                                                    style: ButtonStyle(
                                                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                                                    ),
                                                    onPressed: ()async{
                                                      myClassesController.myclasses.value.removeWhere((cc)=>cc.uid == cls.uid);
                                                      myClassesController.update();
                                                      //FirebaseFirestore.instance.collection('teacher_class').doc(cls.uid).
                                                      var doc = await FirebaseFirestore.instance.collection('teacher_class')
                                                          .where('class', isEqualTo: cls.uid)
                                                          .where('teacher', isEqualTo: _teacherController.teacher.first.uid).get();

                                                      if(doc.docs.isNotEmpty){
                                                        FirebaseFirestore.instance.collection('teacher_class').doc(doc.docs.first.id).delete();
                                                        Fluttertoast.showToast(msg: 'Class removed successfully!');
                                                      }
                                                      Get.back();
                                                    },
                                                    child: Text('Confirm', style: TextStyle(color: Colors.white),)
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
                                                      Text('Are you sure you want to remove ${cls.name} from my classes?', style: TextStyle(fontSize: 16, color: Colors.red),)
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
                                  )
                                ],
                              ),
                              SizedBox(height: 0,),
                              Expanded(
                                  child: Center(
                                    child: Image.asset('assets/class.png'),
                                  )
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10
                                ),
                                child: Text(cls.name, style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                )
              ],
            ),
          ):
          Center(
            child: Image.asset('assets/empty-folder.png'),
          );
        }
      ),
    );
  }
}
