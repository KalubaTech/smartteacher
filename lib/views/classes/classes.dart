import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/ListTiles/classpupils_add_listtile.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/views/classes/add_class.dart';
import 'package:smart_teacher/views/classes/view_class.dart';
import '../../utils/colors.dart';

class Classes extends StatelessWidget {
  const Classes({super.key});

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
              padding: EdgeInsets.all(18),
              children: [
                ...myClasses.map((cls)=>
                    Card(
                      child: InkWell(
                        onTap: (){
                          Get.to(()=>ViewClass(classModel: cls), transition: Transition.fade);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
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
