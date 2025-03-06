import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/schools_controoler.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/province_model.dart';
import 'package:smart_teacher/models/school_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/page_anchor.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:smart_teacher/views/preset_screens/preset_classes.dart';

class ProRegister extends StatelessWidget {
  ProRegister({super.key});

  TeacherController _teacherController = Get.find();

  TextEditingController _schoolController = TextEditingController();
  SchoolsController _schoolsController = Get.find();

  var selectedProvince = <ProvinceModel>[].obs;

  var imagepath = ''.obs;
  var selectedSchool = <SchoolModel>[].obs;
  var selectedDistrict = ''.obs;
  
  TextEditingController _newschool = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return DraggableHome(
      appBarColor: Karas.primary,
        title: Container(
          child: Text('Select Your School', style: GoogleFonts.gabarito(color: Colors.black, fontWeight: FontWeight.bold),),
        ),
        headerWidget: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/library.jpg'), fit: BoxFit.cover)
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Karas.primary.withOpacity(0.8)
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Congrats!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                Text('${_teacherController.teacher.first.firstname}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),),
              ],
            ),
          ),
        ),
        body: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(' Where do you teach?', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),),
                SizedBox(height: 20,),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        // Province Dropdown
                        FutureBuilder<List<ProvinceModel>>(
                          future: DataPrefetch().fetchProvinces(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(color: Karas.primary));
                            }
                            if (snapshot.hasError) {
                              return Text("Error loading provinces");
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text("No provinces available");
                            }

                            var provinces = snapshot.data!;
                            return DropdownSearch<String>(
                              key: Key('province-dropdown'),
                              items: (x, y) => provinces.map((province) => province.province).toList(),
                              selectedItem: selectedProvince.isNotEmpty ? selectedProvince.first.province : null,
                              onChanged: (item) {
                                var selected = provinces.firstWhere((p) => p.province == item);
                                selectedProvince.value = [selected];
                                selectedDistrict.value = ''; // Clear district selection on province change
                                selectedSchool.value.clear(); // Clear school selection on province change
                                print('Selected province: $item');
                              },
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                  labelText: 'Province',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              popupProps: PopupProps.menu(
                                fit: FlexFit.loose,
                                constraints: BoxConstraints(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        // District Dropdown
                        Obx(
                              () => selectedProvince.isNotEmpty
                              ? DropdownSearch<String>(
                            key: Key('district-dropdown'),
                            items: (x, y) => selectedProvince.first.districts.map((d) => d.toString()).toList(),
                            selectedItem: selectedDistrict.value.isNotEmpty ? selectedDistrict.value : null,
                            onChanged: (item) {
                              selectedDistrict.value = item ?? '';
                              selectedSchool.value.clear(); // Clear school selection on district change
                              print('Selected district: $item');
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: 'District',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              fit: FlexFit.loose,
                              constraints: BoxConstraints(),
                            ),
                          )
                              : Container(),
                        ),
                        SizedBox(height: 20),
                        // School Dropdown
                        Obx(
                            ()=> FutureBuilder<List<SchoolModel>>(
                            future: selectedDistrict.value.isNotEmpty
                                ? DataPrefetch().fetchSchoolsByDistrict(selectedDistrict.value)
                                : Future.value([]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator(color: Karas.primary));
                              }
                              if (snapshot.hasError) {
                                return Text("Error loading schools");
                              }
                              if (selectedDistrict.value.isEmpty) {
                                return Text("Select province and district");
                              }

                              var schools = snapshot.data!;
                              return DropdownSearch<String>(
                                key: Key('school-dropdown'),
                                items: (x, y) => [
                                  'Add new',
                                  ...
                                  schools.map((school) => school.name).toList()
                                ],
                                selectedItem: selectedSchool.isNotEmpty ? selectedSchool.first.name : null,
                                onChanged: (item) {
                                  if(item=='Add new'){
                                    Get.bottomSheet(
                                      Container(
                                        height: 240,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 45,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                            ),
                                            SizedBox(height: 8,),
                                            Expanded(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(20),
                                                        topLeft: Radius.circular(20)
                                                    )
                                                ),
                                                child: ListView(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20
                                                  ),
                                                  children: [
                                                    SizedBox(height: 20,),
                                                    Text('Add your school', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
                                                    SizedBox(height: 20,),
                                                    Kalutext(
                                                        controller: _newschool,
                                                        hintText: 'Enter School Name',
                                                        labelText: 'School name:',
                                                        border: Border.all(),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        ElevatedButton(
                                                            onPressed: (){
                                                              _newschool.text.isNotEmpty?
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection('schools')
                                                                  .add({'district':selectedDistrict.value, 'province':selectedProvince.value.first.province, 'name':_newschool.text}).then((v){
                                                                    selectedSchool.value.add(SchoolModel(uid: v.id, name: _newschool.text, district: selectedDistrict.value, province: ''));
                                                                    selectedSchool.refresh();
                                                                    Fluttertoast.showToast(msg: 'Added successfully!');
                                                                    Get.back();
                                                              })
                                                              :null;
                                                            },
                                                            child: Text('Save')
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    );
                                  }else{
                                    var selected = schools.firstWhere((school) => school.name == item);
                                    selectedSchool.value = [selected];
                                    print('Selected school: ${selected.uid}');
                                  }
                                },
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText: 'School',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  fit: FlexFit.loose,
                                  constraints: BoxConstraints(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                ),
                SizedBox(height: 40,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(
                    ()=>selectedSchool.value.isNotEmpty?
                      Kalubtn(
                        label: 'Save',
                        onclick: ()async{
                          _teacherController.teacher.value.first.school = selectedSchool.value.first.uid;
                          _teacherController.update();
                          await FirebaseFirestore.instance.collection('teachers').doc(_teacherController.teacher.first.uid)
                              .update({'school':selectedSchool.value.first.uid});
                          Get.to(()=>PresetClasses(schoolid: selectedSchool.value.first.uid));
                          //Get.offAll(()=>PageAnchor());
                        },
                      borderRadius: 40,
                      height: 45,
                      backgroundColor: Karas.danger,
                    ):
                      Kalubtn(
                      label: 'Save',
                      onclick: (){
                      },
                      borderRadius: 40,
                      height: 45,
                      backgroundColor: Colors.grey.withOpacity(0.4),
                    ),
                  ),
                )
              ],
            ),
          )
        ]
    );
  }
}
