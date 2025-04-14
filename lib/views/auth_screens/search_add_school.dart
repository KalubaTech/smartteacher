import 'dart:async';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/models/school_model.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/utils/colors.dart';

import '../../controllers/schools_controoler.dart';
import '../../controllers/teacher_controller.dart';
import '../preset_screens/preset_classes.dart';

class SelectSchoolPage extends StatelessWidget {
  final SchoolsController _schoolsController = Get.find();
  final TeacherController _teacherController = Get.find();
  final TextEditingController _schoolSearchController = TextEditingController();

  final _schools = <DocumentSnapshot>[].obs;
  Timer? _debounce;

  final String selectedDistrict;
  final String selectedProvince;


  SelectSchoolPage({required this.selectedDistrict, required this.selectedProvince});

  String schoolType = '';

  @override
  Widget build(BuildContext context) {
    print(_teacherController.teacher.first.school);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select School in $selectedDistrict',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Karas.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextField
            Container(
              height: 40,
              child: TextField(
                controller: _schoolSearchController,
                cursorHeight: 20,
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: (value) {
                  _onSearchChanged();
                },
              ),
            ),
            SizedBox(height: 20),
            // Search Results ListView
            Expanded(
              child: Obx(
                    () => _schools.isEmpty
                    ? Center(child: Text('No schools found'))
                    : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0
                      ),
                  itemCount: _schools.length,
                  itemBuilder: (context, index) {
                    var school = _schools[index];
                    return Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10
                            ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(school.get('name'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)
                                  ),
                                  Container(
                                    child: Icon(Icons.chevron_right_rounded,),
                                  )
                                ],
                              )
                          ),
                          onTap: () async{
                                           /*     selectedSchool.value = [
                              SchoolModel(
                                uid: _schools[index].id,
                                name: school['name'],
                                district: school['district'],
                                province: school['province'],
                              )
                            ];
                            _schoolSearchController.text = school['name'];
                            Get.back(result: selectedSchool.value.first); // Return selected school*/
                              Get.defaultDialog(
                                title: '',
                                content: Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              );
                              print('HERE IS ID, ${school}');
                              _teacherController.teacher.value.first.school = school.id;

                              _teacherController.update();
                              await FirebaseFirestore.instance
                                  .collection('teachers')
                                  .doc(_teacherController.teacher.first.uid)
                                  .update({'school': school.id});
                              Get.to(() => PresetClasses(schoolid: school.id));

                          },
                        ),
                        SizedBox(height: 4,)
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            // Add New School Button
            ElevatedButton(
              onPressed: () {
                _showAddSchoolBottomSheet(context);
              },
              child: Text('Add New School'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
    });
  }

  void _performSearch() async {
    String searchText = _schoolSearchController.text.trim();
    if (searchText.isEmpty) {
      _schools.value = [];
      return;
    }

    try {
      // Fetch all schools in the selected district
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('schools')
          .where('district', isEqualTo: selectedDistrict)
          .where('province', isEqualTo: selectedProvince)
          .get();

      // Convert search text to lowercase for case-insensitive comparison
      String searchTextLower = searchText.toLowerCase();

      // Filter results on the client side
      List<DocumentSnapshot> filteredSchools = snapshot.docs.where((doc) {
        String schoolName = doc['name'].toString().toLowerCase();
        return schoolName.contains(searchTextLower);
      }).toList();

      // Update the observable list with filtered results
      _schools.value = filteredSchools;
    } catch (e) {
      print("Error fetching schools: $e");
    }
  }

  void _showAddSchoolBottomSheet(BuildContext context) {
    final TextEditingController _newschool = TextEditingController();
    _newschool.text = _schoolSearchController.text;

    Get.bottomSheet(
      Container(
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Container(
          width: 45,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Add your school',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Kalutext(
                    controller: _newschool,
                    hintText: 'Enter School Name',
                    labelText: 'School name:',
                    border: Border.all(),
                  ),
                  SizedBox(height: 10),
                  DropdownSearch(
                    onChanged: (value) {
                      schoolType = value;
                    },
                    popupProps: PopupProps.menu(fit: FlexFit.loose),
                    compareFn: (a,b)=>true,
                    items: (x,c)=>[
                      'Primary',
                      'Secondary',
                      'College',
                      'University',
                      'Vocational',
                      'Technical',
                      'Other'
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_newschool.text.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection('schools')
                                .add({
                              'district': selectedDistrict,
                              'province': selectedProvince,
                              'name': _newschool.text,
                              'type': schoolType
                            }).then((v) async{ 
                              Fluttertoast.showToast(msg: 'Added successfully!');
                              /*_onSearchChanged();
                              Get.back();*/
                              _teacherController.teacher.value.first.school = v.id;

                              _teacherController.update();
                              await FirebaseFirestore.instance
                                  .collection('teachers')
                                  .doc(_teacherController.teacher.first.uid)
                                  .update({'school': v.id});
                              Get.to(() => PresetClasses(schoolid: v.id));
                            });
                          }
                        },
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}