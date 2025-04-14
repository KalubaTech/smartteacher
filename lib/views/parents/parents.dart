import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/parents/view_parent.dart';
import '../../controllers/my_school_controller.dart';
import '../../models/parrent_model.dart';

class Parents extends StatefulWidget {
  const Parents({super.key});

  @override
  State<Parents> createState() => _ParentsState();
}

class _ParentsState extends State<Parents> {
  MySchoolController _mySchoolController = Get.find();
  TextEditingController _searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Karas.background,
        title: Text('Parents', style: GoogleFonts.gabarito(fontWeight: FontWeight.w500)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController _fullnameController = TextEditingController();
          TextEditingController _phoneController = TextEditingController();
          TextEditingController _emailController = TextEditingController();

          RxBool isFormValid = false.obs;

          void validateForm() {
            isFormValid.value = _fullnameController.text.trim().isNotEmpty &&
                _phoneController.text.trim().isNotEmpty &&
                _emailController.text.trim().isNotEmpty;
          }

          Get.bottomSheet(
            StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
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
                        child: Text(
                          'Add Parent / Guardian',
                          style: GoogleFonts.gabarito(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          children: [
                            TextField(
                              controller: _fullnameController,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Full Name',
                                hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                errorStyle: TextStyle(fontSize: 12),
                              ),
                              onChanged: (value) => setState(validateForm),
                            ),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Phone',
                                hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                errorStyle: TextStyle(fontSize: 12),
                              ),
                              onChanged: (value) => setState(validateForm),
                            ),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                errorStyle: TextStyle(fontSize: 12),
                              ),
                              onChanged: (value) => setState(validateForm),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Obx(
                                  () => ElevatedButton(
                                onPressed: isFormValid.value
                                    ? () async {
                                  var emailValidation = ValidationBuilder()
                                      .email()
                                      .build()
                                      .call(_emailController.text);

                                  if (emailValidation != null) {
                                    Get.snackbar('Warning!', emailValidation);
                                    return;
                                  }

                                  var emailExists = await FirebaseFirestore.instance
                                      .collection('parents')
                                      .where('email', isEqualTo: _emailController.text.trim())
                                      .get();

                                  if (emailExists.docs.isNotEmpty) {
                                    Get.snackbar('Warning!', 'Parent with this email already exists');
                                  } else {
                                    Get.back();
                                    await FirebaseFirestore.instance.collection('parents').add({
                                      'fullname': _fullnameController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'photo': ''
                                    });
                                  }
                                }
                                    : null,
                                child: Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
            backgroundColor: Colors.white,
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery.value = '';
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                searchQuery.value = value.toLowerCase();
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parents')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading parents'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No parents found'));
                }

                return Obx(() {
                  var filteredParents = snapshot.data!.docs.where((parent) {
                    if (searchQuery.value.isEmpty) return true;
                    return parent['fullname'].toString().toLowerCase().contains(searchQuery.value) ||
                        parent['email'].toString().toLowerCase().contains(searchQuery.value) ||
                        parent['phone'].toString().toLowerCase().contains(searchQuery.value);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredParents.length,
                    itemBuilder: (context, index) {
                      var parent = filteredParents[index];
                      return ListTile(
                        leading: CircleAvatar(
                            child: parent.get('photo')!=''?Container():Icon(Icons.person),
                            backgroundImage: NetworkImage(parent.get('photo')),
                        ),
                        title: Text(
                          parent['fullname'],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          parent['email'],
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            ParentModel parentModel = ParentModel(
                                uid: parent.id,
                                fullname: parent['fullname'],
                                phone: parent['phone'],
                                email: parent['email'],
                                photo: parent['photo']
                            );

                            Get.to(
                                    () => ViewParent(parent: parentModel),
                                transition: Transition.fade
                            );
                          },
                          icon: Icon(Icons.arrow_forward),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}