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
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Karas.primary.withOpacity(0.1),
            child: Icon(Icons.group, color: Karas.primary,),
          ),
          SizedBox(width: 10,),
          Expanded(
              child: InkWell(
                onTap: ()=>Get.to(()=>ViewClass(classModel: classModel,)),
                child: Container(
                  child: Text('${classModel.name}'),
                ),
              )
          ),
          PopupMenuButton(
              icon: Icon(Icons.add),
              color: Colors.white,
              position: PopupMenuPosition.under,
              itemBuilder: (c){
                return [
                  PopupMenuItem(
                      child: Text('Add pupils'),
                    onTap: (){
                      TextEditingController _pupilFName = TextEditingController();
                      TextEditingController _pupilLName = TextEditingController();
                      var gender = 'm'.obs;
                      var intake = '${DateTime.now().year}'.obs;
                        Get.bottomSheet(
                            Container(
                              height: 320,
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20)
                                        )
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20
                                        ),
                                        child: Column(
                                          children: [
                                            Text('Add pupil to ${classModel.name}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),),
                                            Expanded(
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: [
                                                  SizedBox(height: 20,),
                                                  Kalutext(controller: _pupilFName, hintText: 'First Name',),
                                                  Kalutext(controller: _pupilLName, hintText: 'Last Name',),
                                                  Row(
                                                    children: [
                                                      Expanded(child: Row(
                                                        children: [
                                                          Text('    Gender:'),
                                                          SizedBox(width: 10,),
                                                          Obx(
                                                              ()=> DropdownButton(
                                                                value: gender.value,
                                                                items: [
                                                                  DropdownMenuItem(child: Text('Male'), value: 'm',),
                                                                  DropdownMenuItem(child: Text('Female'),value: 'f',)
                                                                ],
                                                                onChanged: (value){
                                                                  gender.value = value!;
                                                                }
                                                            ),
                                                          ),
                                                        ],
                                                      ),),

                                                      Expanded(child: Row(
                                                        children: [
                                                          Text('    Intake:'),
                                                          SizedBox(width: 10,),
                                                          Obx(
                                                              ()=> DropdownButton(
                                                                value: intake.value,
                                                                items: List.generate(8, (i){
                                                                  int cYear = DateTime.now().year;
                                                                  return DropdownMenuItem(child: Text('${cYear-i}'), value: '${cYear-i}',);
                                                                }),
                                                                onChanged: (value){
                                                                  intake.value = value!;
                                                                }
                                                            ),
                                                          ),
                                                        ],
                                                      ),),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            Kalubtn(
                                                label: 'Add',
                                                onclick: (){
                                                  CommonMethods().addPupil(_pupilFName.text, _pupilLName.text, gender.value, intake.value, classModel.uid);
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                        );
                    },
                  ),
                  PopupMenuItem(child: Text('Add subjects')),
                ];
              },
          )
        ],
      ),
    );
  }
}
