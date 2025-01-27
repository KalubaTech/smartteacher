import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/classes_controller.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';



class AddClass extends StatefulWidget {
  AddClass({super.key});

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  TextEditingController _classNameController = TextEditingController();

  ClassesController _classesController = Get.find();
  TeacherController _teacherController = Get.find();
  MyClassesController myClassesController = Get.find();

  var selectedClasses = <ClassModel>[].obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_classesController.classes.value = [ClassModel(uid: '1', name: 'a2'),ClassModel(uid: '1', name: 'b3'),ClassModel(uid: '1', name: 'C1')];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Class', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),),
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10
                ),
                decoration: BoxDecoration(
                  color: Karas.primary.withOpacity(0.1),
                  border: Border.all(
                    color: Karas.primary.withOpacity(0.2)
                  )
                ),
                child: Text('Add the classes you teach',
                  style: TextStyle(
                    color: Karas.primary,
                    fontWeight: FontWeight.w500
                  ),)
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    child:  Kalutext(
                      controller: _classNameController,
                      hintText: 'Class name',
                      border: Border.all(
                          color: Karas.primary.withOpacity(0.1)
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Karas.primary.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(10)
                    ),

                  ),
                  SizedBox(height: 30,),
                  Kalubtn(
                      label: 'Add',
                      borderRadius: 20,
                      height: 40,
                      backgroundColor: Karas.primary.withOpacity(0.4),
                      onclick: ()async{
                        await FirebaseFirestore.instance.collection('classes')
                            .add({
                                'name':_classNameController.text,
                                'school':_teacherController.teacher.first.school
                              }).then((data){
                                myClassesController.myclasses.value.add(ClassModel(uid: data.id, name: _classNameController.text, school: _teacherController.teacher.first.school));
                                myClassesController.update();
                                FirebaseFirestore.instance.collection('teacher_class')
                                    .add({
                                  'class':data.id,
                                  'teacher':_teacherController.teacher.first.uid
                                });
                        });
                        _classNameController.clear();

                      }),
                  ],
              ),
            ),
            SizedBox(height: 24,),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance.
                  collection('classes').
                  where('school', isEqualTo: _teacherController.teacher.first.school).
                  snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.hasData&&
                        snapshot.data!.docs.isNotEmpty?
                        GetBuilder<MyClassesController>(
                          builder: (myClassesController) {
                            List<ClassModel> classModel = myClassesController.myclasses.value;
                            return ListView(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20
                              ),
                              children: [
                                Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Karas.primary.withOpacity(0.1),
                                        border: Border.all(
                                            color: Karas.primary.withOpacity(0.2)
                                        ),
                                        gradient: LinearGradient(
                                            colors: [
                                              Karas.primary.withOpacity(0.9),
                                              Karas.primary.withOpacity(0.2),
                                            ]
                                        )
                                    ),
                                    child: Text('OR ADD FROM LIST',
                                      style: TextStyle(
                                          color: Karas.primary,
                                          fontWeight: FontWeight.w500
                                      ),)
                                ),
                                ... snapshot.data!.docs.map((cls)=>
                                    CheckboxListTile(
                                        value: classModel.map((c)=>c.name.toLowerCase()).toList().contains(cls.get('name').toLowerCase()),
                                        title: Text('${cls.get('name')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                        activeColor: Karas.primary,
                                        onChanged: (value) async {
                                          var clss = ClassModel(uid: cls.id, name: cls.get('name'), school: cls.get('school'));
                                          if(!classModel.map((c)=>c.name.toLowerCase()).toList().contains(cls.get('name').toLowerCase())){
                                            myClassesController.myclasses.add(clss);
                                            FirebaseFirestore.instance.collection('teacher_class')
                                                .add({
                                              'class':clss.uid,
                                              'teacher':_teacherController.teacher.first.uid
                                            });
                                          }else{
                                            myClassesController.myclasses.value.removeWhere((i)=>i.name.toLowerCase()==clss.name.toLowerCase());
                                            var data = await FirebaseFirestore.instance.collection('teacher_class')
                                            .where('class',isEqualTo: clss.uid).
                                            where('teacher', isEqualTo: _teacherController.teacher.first.uid)
                                               .get();
                                            FirebaseFirestore.instance.
                                            collection('teacher_class').
                                            doc(data.docs.first.id).delete();
                                          }
                                          myClassesController.update();
                                        }
                                    )
                                )
                              ],
                            );
                          }
                        ):
                    Container(
                      child: Text('not found!'),
                    );
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
