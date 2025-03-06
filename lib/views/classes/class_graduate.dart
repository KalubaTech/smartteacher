import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/utils/colors.dart';

class ClassGraduate extends StatefulWidget {

  ClassModel classModel;
  List<PupilModel>pupils;
  int intake;



  ClassGraduate({required this.classModel, required this.intake, required this.pupils});

  @override
  State<ClassGraduate> createState() => _ClassGraduateState();
}

class _ClassGraduateState extends State<ClassGraduate> {
  List<PupilModel> selectedPupils = [];
  List<PupilModel> filteredPupils = [];

  String newclass = '';

  TextEditingController _searchField = TextEditingController();

  MyClassesController _myClassesController = Get.find();
  bool isRegistering = false;

  bool isAll = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchField.addListener((){
      setState(() {
        _searchField.text.isNotEmpty?
        filteredPupils = widget.pupils.where((s)=>'${s.firstname} ${s.lastname}'.toLowerCase().contains(_searchField.text.toLowerCase())).toList()
        : filteredPupils = widget.pupils;
      });
    });

    selectedPupils = widget.pupils;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Class Graduate - ${widget.classModel.name}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: _searchField,
                        decoration: InputDecoration(
                          hintText: 'Search pupil',
                          hintStyle: TextStyle(
                            color: Colors.grey
                          )
                        ),
                      )
                  ),
                  SizedBox(
                    child: Checkbox(
                        value: isAll,
                        onChanged: (v){
                          setState(() {
                            if(selectedPupils.length == filteredPupils.length){
                              selectedPupils = [];
                              isAll = false;
                            }else{
                              selectedPupils = filteredPupils;
                              isAll = true;
                            }
                          });
                        }
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: filteredPupils.length,
                  itemBuilder: (c,i){
                    var pupil = widget.pupils[i];
                    return CheckboxListTile(
                        value: selectedPupils.contains(pupil),
                        title: Text('${pupil.firstname} ${pupil.lastname}'),
                        subtitle: Text(pupil.gender=='m'?'Male':'Female', style: TextStyle(color: Colors.grey, fontSize: 12),),
                        onChanged: (value){
                          setState(() {

                            if(selectedPupils.contains(pupil)){
                              selectedPupils.remove(pupil);
                            }else{
                              selectedPupils.addIf(!selectedPupils.contains(pupil),pupil);
                            }
                            if(selectedPupils.length == widget.pupils.length){
                              isAll = true;
                            }else{
                              isAll = false;
                            }

                          });
                        }
                    );
                  }
              ),
            ),
            Container(
              color: Colors.grey.shade100,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('New class:  ', style: GoogleFonts.gabarito(fontSize: 13, fontWeight: FontWeight.bold),),
                    Container(
                      width: 100,
                      height: 38,
                      child: DropdownSearch(
                        compareFn: (a,b)=>true,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose
                        ),
                        items: (x,y)=>[
                          ..._myClassesController.myclasses.value
                          .map((e) => e.name.toString())
                          .where((name) => name != widget.classModel.name)
                          .toList()
                        ],
                        onChanged: (value){
                          setState(() {
                            newclass = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      child: selectedPupils.isNotEmpty&&newclass.isNotEmpty?
                      ElevatedButton(
                          onPressed: (){
                            Get.defaultDialog(
                              title: 'Confirm',
                              titlePadding: EdgeInsets.only(top: 20),
                              titleStyle: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),
                              backgroundColor: Colors.white,
                              content: StatefulBuilder(
                                builder: (context, setInnerState) {
                                  return Column(
                                    children: [
                                      Container(
                                        child: Text(
                                          'Registering ${selectedPupils.length} pupils to $newclass',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      isRegistering
                                          ? Container(
                                        child: LoadingAnimationWidget.inkDrop(
                                          color: Colors.green,
                                          size: 40,
                                        ),
                                      )
                                          : ElevatedButton(
                                        onPressed: () async {
                                          setInnerState(() {
                                            isRegistering = true;
                                          });

                                          for (var pupil in selectedPupils) {
                                            String classid = _myClassesController
                                                .myclasses.value
                                                .where((e) => e.name == newclass)
                                                .first
                                                .uid;

                                            List newclasses = [...pupil.classid, classid];

                                            await FirebaseFirestore.instance
                                                .collection('pupils')
                                                .doc(pupil.uid)
                                                .update({'class': newclasses});
                                          }

                                          setInnerState(() {
                                            isRegistering = false;
                                          });

                                          Fluttertoast.showToast(msg: 'Successful!');
                                          Get.back();
                                        },
                                        child: Text('Continue'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                          child: Text('Migrate')
                      ):
                      ElevatedButton(
                          onPressed: (){
                          
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200),
                          ),
                          child: Text('Migrate',style: TextStyle(
                            color: Colors.grey
                          ),)
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
