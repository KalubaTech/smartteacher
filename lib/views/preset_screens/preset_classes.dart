import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/page_anchor.dart';
import 'package:smart_teacher/views/preset_screens/preset_timetable.dart';

class PresetClasses extends StatelessWidget {
  final String schoolid;
  PresetClasses({required this.schoolid});

  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _newSubjectController = TextEditingController();

  TeacherController _teacherController = Get.find();

  var classes = <Map<String, List<String>>>[].obs;
  var classs = ''.obs;
  String selectedClass = '';
  //String selectedSubject = '';

  TextEditingController _newClassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async{
                Get.defaultDialog(
                  title: '',
                  content: Container(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20,),
                        Text('Setting up your classes...', style: GoogleFonts.gabarito(fontSize: 14, fontWeight: FontWeight.w600),)
                      ],
                    ),
                  ),
                  barrierDismissible: false
                );
                List<Map<String, dynamic>> subjectMaps = []; // List to store maps for each subject

                for (var cl in classes) {
                  String className = cl.keys.first; // Get the class name
                  List<String> subjects = cl[className]!; // Get the list of subjects for the class

                  var classObj = await DataPrefetch().getClassesBySchool(schoolid);

                  var classid = classObj.where((clss)=>clss.name==className).first.uid;

                  FirebaseFirestore.instance.collection('teacher_class').add({'teacher':_teacherController.teacher.first.uid, 'class':classid});

                  for (var subject in subjects) {

                    var subjectobj = await DataPrefetch().fetchClassSubjects(schoolid);

                    var subjectid = subjectobj.where((sub)=>sub.name==subject).first.uid;

                    var data = {
                      'class': classid, // Class name
                      'subject': subjectid, // Subject name
                      'teacher': _teacherController.teacher.first.uid, // Teacher ID
                    };
                    subjectMaps.add(data); // Add the map to the list

                    FirebaseFirestore.instance.collection('teacher_subject_class').add(data);
                  }
                }

                // Print or use the subjectMaps list as needed
                //print(subjectMaps);
                

                DataPrefetch().fetchAllMySubjects(_teacherController.teacher.first.uid, schoolid);

                //Get.offAll(()=>PageAnchor(), transition: Transition.fade);

                Get.to(()=>PresetTimetable(), transition: Transition.fade);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              // Background image container
              Container(
                alignment: Alignment.topCenter,
                width: double.maxFinite,
                height: 250,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/teacher.jpg'),
                  ),
                ),
              ),
              // Bottom black bar
              Positioned(
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black12,
                        Colors.black54,
                        Colors.black54,
                        Colors.black,
                        Colors.black,
                      ],
                    ),
                  ),
                  height: 250,
                  width: screenWidth,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Your Classes',
                            style: GoogleFonts.gabarito(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.offAll(()=>PageAnchor(), transition: Transition.fade);
                            },
                            child: Text('Skip'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('classes')
                                .where('school', isEqualTo: schoolid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              return SizedBox(
                                height: 40,
                                child: DropdownSearch(
                                  compareFn: (a, b) => true,
                                  items: (String filter, b) async {
                                    if (snapshot.data!.docs.isNotEmpty) {
                                      return [
                                        'Add new',
                                        ...snapshot.data!.docs
                                            .map((d) => d.get('name'))
                                            .toList(),
                                      ];
                                    } else {
                                      return ['Add new'];
                                    }
                                  },
                                  selectedItem: '',
                                  onChanged: (value) {
                                    if (value != null) {
                                      if (value == 'Add new') {
                                        // Handle 'Add new' selection
                                        Get.defaultDialog(
                                          title:
                                          'Add new class',
                                          titleStyle:
                                          GoogleFonts.gabarito(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          content:
                                          Container(
                                            padding: EdgeInsets
                                                .symmetric(
                                              horizontal:
                                              10,
                                            ),
                                            child:
                                            Column(
                                              children: [
                                                Kalutext(
                                                  controller:
                                                  _newClassController,
                                                  hintText:
                                                  'New class',
                                                  border:
                                                  Border.all(),
                                                ),
                                                SizedBox(
                                                    height: 20),
                                                ElevatedButton(
                                                  onPressed:
                                                      () {
                                                    FirebaseFirestore
                                                        .instance
                                                        .collection('classes')
                                                        .add({'name':_newClassController.text, 'school':schoolid});
                                                    Get.back();
                                                    selectedClass =
                                                        _newClassController.text;
                                                  },
                                                  child: Text(
                                                      'Save'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      classs.value = value;
                                    }
                                  },
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: 'Select Class',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade400)
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                    ),
                                  ),
                                  popupProps: const PopupProps.menu(
                                    fit: FlexFit.loose,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (classs.value.isNotEmpty) {
                              var data = {
                                classs.value: <String>[], // Initialize an empty list for subjects
                              };
                              classes.value.add(data); // Add the new class to the list
                              classes.refresh(); // Refresh the UI
                            } else {
                              Get.snackbar('Error', 'Please select a class first');
                            }
                          },
                          child: Icon(Icons.add, size: 25),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                          () => ListView(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shrinkWrap: true,
                        children: [
                          ...classes.value.map((obj) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Dismissible(
                                onDismissed: (e) => false,
                                confirmDismiss: (e) async => false,
                                key: Key(obj.keys.first),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                                color: Colors.white,
                                                border: BorderDirectional(
                                                  top: BorderSide(
                                                      color: Colors.grey.shade400),
                                                  end: BorderSide(
                                                      color: Colors.grey.shade400),
                                                  start: BorderSide(
                                                      color: Colors.grey.shade400),
                                                ),
                                              ),
                                              child: Text(
                                                obj.keys.first,
                                                style: GoogleFonts.gabarito(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                          ),
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(8),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Subject:',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                InkWell(
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                  onTap: () {
                                                    var selectedSubject = '';
                                                    Get.bottomSheet(
                                                      Container(
                                                        height: 200,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: 8,
                                                              width: 40,
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius:
                                                                BorderRadius.circular(10),
                                                              ),
                                                            ),
                                                            SizedBox(height: 10),
                                                            Expanded(
                                                              child: Container(
                                                                width: double.infinity,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius.only(
                                                                    topRight:
                                                                    Radius.circular(20),
                                                                    topLeft:
                                                                    Radius.circular(20),
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(height: 20),
                                                                    Container(
                                                                      padding: EdgeInsets.all(20),
                                                                      child: SizedBox(
                                                                        height: 40,
                                                                        child: StreamBuilder(
                                                                          stream: FirebaseFirestore
                                                                              .instance
                                                                              .collection('subjects')
                                                                              .where('school',
                                                                              isEqualTo: schoolid)
                                                                              .snapshots(),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            return DropdownSearch<
                                                                                String>(
                                                                              compareFn: (a, b) =>
                                                                              true,
                                                                              items: (String filter,
                                                                                  b) async {
                                                                                if (snapshot.data!
                                                                                    .docs.isNotEmpty) {
                                                                                  return [
                                                                                    'Add new',
                                                                                    ...snapshot.data!.docs
                                                                                        .map((d) =>
                                                                                        d.get('name'))
                                                                                        .toList(),
                                                                                  ];
                                                                                } else {
                                                                                  return ['Add new'];
                                                                                }
                                                                              },
                                                                              selectedItem: '',
                                                                              onChanged: (value) {
                                                                                if (value != null) {
                                                                                  if (value ==
                                                                                      'Add new') {
                                                                                    Get.defaultDialog(
                                                                                      title:
                                                                                      'Add new subject',
                                                                                      titleStyle:
                                                                                      GoogleFonts.gabarito(
                                                                                        fontSize: 16,
                                                                                        fontWeight:
                                                                                        FontWeight.bold,
                                                                                      ),
                                                                                      content:
                                                                                      Container(
                                                                                        padding: EdgeInsets
                                                                                            .symmetric(
                                                                                          horizontal:
                                                                                          10,
                                                                                        ),
                                                                                        child:
                                                                                        Column(
                                                                                          children: [
                                                                                            Kalutext(
                                                                                              controller:
                                                                                              _newSubjectController,
                                                                                              hintText:
                                                                                              'New subject',
                                                                                              border:
                                                                                              Border.all(),
                                                                                            ),
                                                                                            SizedBox(
                                                                                                height: 20),
                                                                                            ElevatedButton(
                                                                                              onPressed:
                                                                                                  () {
                                                                                                FirebaseFirestore
                                                                                                    .instance
                                                                                                    .collection('subjects')
                                                                                                    .add({'name':_newSubjectController.text, 'school':schoolid});
                                                                                                Get.back();
                                                                                                selectedSubject =
                                                                                                    _newSubjectController.text;
                                                                                              },
                                                                                              child: Text(
                                                                                                  'Save'),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  } else {
                                                                                    selectedSubject =
                                                                                        value;
                                                                                  }
                                                                                }
                                                                              },
                                                                              decoratorProps:
                                                                              DropDownDecoratorProps(
                                                                                decoration:
                                                                                InputDecoration(
                                                                                  labelText:
                                                                                  'Select subject',
                                                                                  border:
                                                                                  OutlineInputBorder(
                                                                                    borderRadius:
                                                                                    BorderRadius.circular(8),
                                                                                  ),
                                                                                  contentPadding:
                                                                                  const EdgeInsets
                                                                                      .symmetric(
                                                                                    horizontal: 10,
                                                                                    vertical: 6,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              popupProps:
                                                                              const PopupProps
                                                                                  .menu(
                                                                                fit: FlexFit.loose,
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 20),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment.end,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          onPressed: () {
                                                                            if (selectedSubject
                                                                                .isNotEmpty) {
                                                                              addSubjectToClass(
                                                                                  obj.keys.first,
                                                                                  selectedSubject);
                                                                              Get.back();
                                                                            }
                                                                          },
                                                                          child: Text('Save'),
                                                                        ),
                                                                        SizedBox(width: 20),
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
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey),
                                                      borderRadius:
                                                      BorderRadius.circular(20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          spreadRadius: 0.5,
                                                          blurRadius: 0.5,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'Add',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Karas.primary,
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 6),
                                            ...obj.values.first.map((v) => Text(v)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to add a subject to a class
  void addSubjectToClass(String className, String subject) {
    var classData = classes.firstWhere(
          (c) => c.containsKey(className),
      orElse: () => {},
    );

    if (classData.isNotEmpty) {
      classData[className]!.add(subject);
      classes.refresh();
    } else {
      print('Class not found');
    }
  }
}