import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/classes/view_class.dart';

class ClasspupilsAddListtile extends StatelessWidget {
  
  ClassModel classModel;
  ClasspupilsAddListtile({required this.classModel});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: Colors.grey.shade100)
        )
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Karas.primary.withOpacity(0.1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset('assets/class.png'),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
              child: InkWell(
                onTap: ()=>Get.to(()=>ViewClass(classModel: classModel,)),
                child: Container(
                  child: Text('Class ${classModel.name}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                ),
              )
          ),
        ],
      ),
    );
  }
}
