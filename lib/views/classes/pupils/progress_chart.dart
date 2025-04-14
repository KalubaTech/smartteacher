import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';

import '../../../controllers/my_school_controller.dart';
import '../../../models/class_model.dart';
import '../../../models/pupil_model.dart';

class ProgressChart extends StatelessWidget {
  PupilModel pupil;
  ClassModel classModel;

  ProgressChart({required this.pupil, required this.classModel});

  var term = ''.obs;

  
  MySchoolController _mySchoolController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  SizedBox(
                    height: 30,
                    width: 100,
                    child: Obx(
                          () => FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('assessment_types')
                            .where('school', isEqualTo: _mySchoolController.myschool.value.uid)
                            .orderBy('assessment')
                            .get(),
                        builder: (context, s) {
                          // Default to an empty list if data is null
                          List<String> assessmentList = (s.data?.docs ?? [])
                              .map((i) => i.get('assessment') as String)
                              .toList();

                          return DropdownSearch(
                            decoratorProps: DropDownDecoratorProps(
                              baseStyle: GoogleFonts.gabarito(fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 1),
                              ),
                            ),
                            popupProps: PopupProps.menu(fit: FlexFit.loose),
                            compareFn: (a, b) => a == b,
                            items: (x, c) => assessmentList, // If null, it will be an empty list
                            selectedItem: term.value.isEmpty
                                ? (assessmentList.isNotEmpty ? assessmentList.first : "")
                                : term.value,
                            onChanged: (value) {
                              if (value != null) {
                                term.value = value;
                              }
                            },
                          );
                        },
                      ),
                    ),

                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Card(
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Obx(()=>FutureBuilder(
                        future: FirebaseFirestore.instance.collection('results').where('assessment', isEqualTo: term.value).where('class', isEqualTo: classModel.uid).where('pupil', isEqualTo: pupil.uid).get(),
                        builder: (context, s) {
                          return s.hasData? SfCartesianChart(
                              palette: [
                                Colors.orange
                              ],
                              // Initialize category axis
                              primaryXAxis: CategoryAxis(),
                              series: <LineSeries<DocumentSnapshot, String>>[
                                LineSeries<DocumentSnapshot, String>(
                                  // Bind data source
                                  dataSource:  <DocumentSnapshot>[
                                    ...s.data!.docs
                                  ],
                                  xValueMapper: (DocumentSnapshot sales, _) => sales.get('subject').substring(0,3),
                                  yValueMapper: (DocumentSnapshot sales, _) => int.parse(sales.get('marks')),
                                )
                              ]
                          ) : Center(child: CircularProgressIndicator(),);
                        }
                    )),
                  )
              ),
            ),
          ],
        )
    );
  }

}



class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}