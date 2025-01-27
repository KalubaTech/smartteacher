import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/components/ListTiles/classpupils_add_listtile.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/views/classes/add_class.dart';
import '../../utils/colors.dart';

class Classes extends StatelessWidget {
  const Classes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Classes'),
        backgroundColor: Karas.primary,
        foregroundColor: Colors.white,
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
            child: ListView(
              padding: EdgeInsets.all(18),
              children: [
                ...myClasses.map((cls)=>ClasspupilsAddListtile(classModel: cls))
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
