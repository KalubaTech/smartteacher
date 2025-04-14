import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/parrent_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smart_teacher/views/chat/chat.dart';

import '../../controllers/my_school_controller.dart';

class ViewParent extends StatelessWidget {
  final ParentModel parent;
  ViewParent({required this.parent});

  final MySchoolController _mySchoolController = Get.find();
  final TeacherController _teacherController = Get.find();

  final selectedChildren = [].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Karas.background,
        title: Text('Parent View', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500)),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                            SizedBox(height: 2),
                            Text('${parent.fullname}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Get.to(() => TeacherChatScreen(parent: parent), transition: Transition.fade);
                            },
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('chats')
                                  .where('school', isEqualTo: _mySchoolController.myschool.value.uid)
                                  .where('parent', isEqualTo: parent.uid)
                                  .where('receiver', isEqualTo: _teacherController.teacher.value.first.uid)
                                  .where('isRead', isEqualTo: false)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? badges.Badge(
                                  showBadge: snapshot.data!.docs.isNotEmpty,
                                  badgeContent: Text('${snapshot.data!.size}', style: TextStyle(color: Colors.white)),
                                  child: Image.asset('assets/chat.png'),
                                )
                                    : Container();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('  Children', style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.w500)),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      TextEditingController _searchController = TextEditingController();
                      _searchController.text = parent.fullname.split(' ').last;

                      RxList<QueryDocumentSnapshot> allPupils = RxList<QueryDocumentSnapshot>();
                      RxList<QueryDocumentSnapshot> filteredPupils = RxList<QueryDocumentSnapshot>();

                      Get.bottomSheet(
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              SizedBox(height: 50),
                              Container(
                                width: 60,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Select child',
                                  style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(height: 1, color: Colors.grey.shade300, width: double.infinity),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  controller: _searchController,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    hintText: 'Search',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                  ),
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      filteredPupils.assignAll(allPupils);
                                    } else {
                                      filteredPupils.assignAll(allPupils.where((pupil) =>
                                      pupil['firstname'].toString().toLowerCase().contains(value.toLowerCase()) ||
                                          pupil['lastname'].toString().toLowerCase().contains(value.toLowerCase())));
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('pupils')
                                      .where('school', isEqualTo: _mySchoolController.myschool.value.uid)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Center(child: Text('Error loading pupils'));
                                    }
                                    if (snapshot.hasData) {
                                      allPupils.assignAll(snapshot.data!.docs);
                                      if (filteredPupils.isEmpty) {
                                        filteredPupils.assignAll(allPupils);
                                      }

                                      return Obx(
                                            () => ListView(
                                          padding: EdgeInsets.symmetric(vertical: 0),
                                          children: [
                                            ...filteredPupils.map((e) => Obx(
                                                  () => CheckboxListTile(
                                                value: selectedChildren.contains(e.id),
                                                onChanged: (value) {
                                                  if (selectedChildren.contains(e.id)) {
                                                    selectedChildren.remove(e.id);
                                                  } else {
                                                    selectedChildren.add(e.id);
                                                  }
                                                },
                                                title: Text(
                                                  '${e.get('firstname')} ${e.get('lastname')}',
                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ))
                                          ],
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        for (var child in selectedChildren) {
                                          await FirebaseFirestore.instance.collection('parent-child').add({
                                            'parent': parent.uid,
                                            'child': child,
                                            'school': _mySchoolController.myschool.value.uid,
                                          });
                                        }
                                        Get.back();
                                      },
                                      child: Text('Save'),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        backgroundColor: Colors.white,
                        isScrollControlled: true,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Karas.primary, width: 2),
                      ),
                      child: Row(
                        children: [
                          Text('Add', style: GoogleFonts.gabarito(fontSize: 14, fontWeight: FontWeight.w500, color: Karas.primary)),
                          SizedBox(width: 10),
                          Icon(Icons.add, color: Karas.primary),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Builder(
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('parent-child')
                          .where('parent', isEqualTo: parent.uid)
                          .where('school', isEqualTo: _mySchoolController.myschool.value.uid)
                          .snapshots(),
                      builder: (context, s) {
                        if (s.hasData) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            for (var doc in s.data!.docs) {
                              final childId = doc.get('child');
                              if (!selectedChildren.contains(childId)) {
                                selectedChildren.add(childId);
                              }
                            }
                          });

                          return ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                            itemCount: s.data!.docs.length,
                            itemBuilder: (c, i) {
                              final doc = s.data!.docs[i];
                              return ListTile(
                                title: FutureBuilder(
                                  future: FirebaseFirestore.instance.collection('pupils').doc(doc.get('child')).get(),
                                  builder: (context, ss) {
                                    return ss.hasData && ss.data!.exists
                                        ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${ss.data!.get('firstname')} ${ss.data!.get('lastname')}', style: TextStyle(fontWeight: FontWeight.w400)),
                                        InkWell(
                                          onTap: () {
                                            FirebaseFirestore.instance.collection('parent-child').doc(doc.id).delete();
                                            selectedChildren.remove(doc.get('child'));
                                          },
                                          child: Icon(Icons.delete, color: Colors.red),
                                        )
                                      ],
                                    )
                                        : Container();
                                  },
                                ),
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
