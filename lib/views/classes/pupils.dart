import 'package:animate_do/animate_do.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/views/classes/class_graduate.dart';
import '../../components/kalubtn.dart';
import '../../components/kalutext.dart';
import '../../helpers/common_methods.dart';
import '../../helpers/data_prefetch.dart';
import '../../utils/colors.dart';

class Pupils extends StatelessWidget {
  ClassModel classModel;
  Pupils({required this.classModel});

  var gender = 'a'.obs; // Default to 'All'
  var intake = ''.obs;

  TeacherController _teacherController = Get.find();

  var pupilsList = <PupilModel>[].obs;

  @override
  Widget build(BuildContext context) {
    intake.value = '${DateTime.now().year}';
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Add pupil to ${classModel.name}',
                              style: GoogleFonts.gabarito(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  SizedBox(height: 20),
                                  Kalutext(
                                    controller: _pupilFName,
                                    hintText: 'First Name',
                                  ),
                                  Kalutext(
                                    controller: _pupilLName,
                                    hintText: 'Last Name',
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('    Gender:'),
                                            SizedBox(width: 10),
                                            Obx(
                                                  () => DropdownButton(
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
                                                onChanged: (value) {
                                                  gender.value = value!;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('    Intake:'),
                                            SizedBox(width: 10),
                                            Obx(
                                                  () => DropdownButton(
                                                value: intake.value,
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Kalubtn(
                              label: 'Add',
                              onclick: () {
                                CommonMethods().addPupil(
                                  _pupilFName.text,
                                  _pupilLName.text,
                                  gender.value,
                                  intake.value,
                                  classModel.uid,
                                  _teacherController.teacher.first.school,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 80,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(
                      () => ClassGraduate(
                    classModel: classModel,
                    intake: int.parse(intake.value),
                    pupils: pupilsList.value,
                  ),
                  transition: Transition.fade,
                );
              },
              child: Image.asset(
                'assets/share.png',
                width: 40,
              ),
            )
          ],
        ),
      ),
      body: FutureBuilder(
        future: DataPrefetch().fetchPupils(_teacherController.teacher.first.school),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            var pupils = snapshot.data!;

            var filtePupils = pupils.where((p) {
              return p.classid.map((i) => i.toString()).toList().contains(classModel.uid);
            }).toList();

            return Obx(() {
              // Filter pupils based on selected gender and intake
              var filteredPupils = filtePupils.where((pupil) {
                bool matchesGender = gender.value == 'a' || pupil.gender == gender.value;
                bool matchesIntake = pupil.intake.contains(intake.value);
                return matchesGender && matchesIntake;
              }).toList();

              pupilsList.value = filtePupils;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Container(
                      color: Karas.primary.withOpacity(0.2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  ' Gender:',
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                                SizedBox(width: 10),
                                Obx(
                                      () => DropdownButton(
                                    alignment: AlignmentDirectional.centerStart,
                                    value: gender.value,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text('All'),
                                        value: 'a',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Male'),
                                        value: 'm',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Female'),
                                        value: 'f',
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    onChanged: (value) {
                                      gender.value = value!;
                                    },
                                    dropdownColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  '    Year:',
                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 30,
                                    child: DropdownSearch<String>(
                                      items: (a,b)=>pupils.expand((p) => p.intake).toList().map((s)=>s.toString()).toSet().toList(),
                                      selectedItem: intake.value,
                                      onChanged: (value) {
                                        // Update the reactive variable after the build process
                                        Future.microtask(() {
                                          intake.value = value!;
                                        });
                                      },
                                      compareFn: (x, y) => x == y,
                                      popupProps: PopupProps.menu(
                                        fit: FlexFit.loose,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
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
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            radius: 16,
                            child: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            '${pupil.firstname} ${pupil.lastname}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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