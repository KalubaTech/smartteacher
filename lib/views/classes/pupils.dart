import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/models/class_model.dart';
import '../../components/kalubtn.dart';
import '../../components/kalutext.dart';
import '../../helpers/common_methods.dart';
import '../../helpers/data_prefetch.dart';
import '../../utils/colors.dart';

class Pupils extends StatelessWidget {
  ClassModel classModel;
  Pupils({required this.classModel});

  var gender = 'm'.obs;
  var intake = '2025'.obs;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: (){
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
        child: Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: DataPrefetch().fetchPupils(classModel.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            var pupils = snapshot.data!;
            return Obx(() {
              // Filter pupils based on selected gender and intake
              var filteredPupils = pupils.where((pupil) {
                bool matchesGender =
                gender.value == 'm' ? pupil.gender == 'm' : pupil.gender == 'f';
                bool matchesIntake = pupil.intake == intake.value;
                return matchesGender && matchesIntake;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Container(
                      color: Karas.primary,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  ' Gender:',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                SizedBox(width: 10),
                                Obx(
                                      () => DropdownButton(
                                    alignment: AlignmentDirectional.centerStart,
                                    value: gender.value,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text('Male'),
                                        value: 'm',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Female'),
                                        value: 'f',
                                      ),
                                    ],
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                    onChanged: (value) {
                                      gender.value = value!;
                                    },
                                    dropdownColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '    Intake:',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                SizedBox(width: 10),
                                Obx(
                                      () => DropdownButton(
                                    value: intake.value,
                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                    items: List.generate(8, (i) {
                                      int cYear = DateTime.now().year;
                                      return DropdownMenuItem(
                                        child: Text('${cYear - i}'),
                                        value: '${cYear - i}',
                                      );
                                    }),
                                    onChanged: (value) {
                                      intake.value = value!;
                                    },
                                    dropdownColor: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredPupils.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var pupil = filteredPupils[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Karas.primary.withOpacity(0.2),
                            radius: 16,
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            '${pupil.firstname} ${pupil.lastname}',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            });
          } else {
            return Center(child: Text('No Pupils Found'));
          }
        },
      ),
    );
  }
}
