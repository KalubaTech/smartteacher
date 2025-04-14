import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/province_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/auth_screens/search_add_school.dart';
import 'package:smart_teacher/views/preset_screens/preset_classes.dart';
import '../../components/kalubtn.dart';
import '../../models/school_model.dart';

class ProRegister extends StatelessWidget {
  ProRegister({super.key});

  final TeacherController _teacherController = Get.find();
  final selectedProvince = <ProvinceModel>[].obs;
  final selectedDistrict = ''.obs;
  final selectedSchool = <SchoolModel>[].obs;

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      appBarColor: Karas.primary,
      title: Text('Select Your School'),
      headerExpandedHeight: 0.2,
      headerWidget: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/library.jpg'), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Karas.primary.withOpacity(0.8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Congrats!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('${_teacherController.teacher.first.firstname}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
      body: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Where do you teach?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
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
                    items: (i,r)=> provinces.map((province) => province.province).toList(),
                    selectedItem: selectedProvince.isNotEmpty ? selectedProvince.first.province : null,
                    onChanged: (item) {
                      var selected = provinces.firstWhere((p) => p.province == item);
                      selectedProvince.value = [selected];
                      selectedDistrict.value = ''; // Clear district selection on province change
                      selectedSchool.value.clear(); // Clear school selection on province change
                    },
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              // District Dropdown
              Obx(
                    () => selectedProvince.isNotEmpty
                    ? DropdownSearch<String>(
                  items: (i,r)=> selectedProvince.first.districts.map((d) => d.toString()).toList(),
                  selectedItem: selectedDistrict.value.isNotEmpty ? selectedDistrict.value : null,
                  onChanged: (item) {
                    selectedDistrict.value = item ?? '';
                    // Navigate to SelectSchoolPage
                    Get.to(() => SelectSchoolPage(selectedDistrict: selectedDistrict.value, selectedProvince: selectedProvince.value.first.province,))?.then((selectedSchool) {
                      if (selectedSchool != null) {
                        this.selectedSchool.value = [selectedSchool];
                      }
                    });
                  },
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                  ),
                )
                    : Container(),
              ),
              SizedBox(height: 40),
              // Save Button
              /*Obx(
                    () => selectedSchool.value.isNotEmpty
                    ? Kalubtn(
                  label: 'Save',
                  onclick: () async {
                    _teacherController.teacher.value.first.school = selectedSchool.value.first.uid;
                    _teacherController.update();
                    await FirebaseFirestore.instance
                        .collection('teachers')
                        .doc(_teacherController.teacher.first.uid)
                        .update({'school': selectedSchool.value.first.uid});
                    Get.to(() => PresetClasses(schoolid: selectedSchool.value.first.uid));
                  },
                  borderRadius: 40,
                  height: 45,
                  backgroundColor: Karas.danger,
                )
                    : Kalubtn(
                  label: 'Save',
                  onclick: () {},
                  borderRadius: 40,
                  height: 45,
                  backgroundColor: Colors.grey.withValues(alpha: 0.4),
                ),
              ),*/
            ],
          ),
        ),
      ],
    );
  }
}