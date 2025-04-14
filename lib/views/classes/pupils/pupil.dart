import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/classes/pupils/progress_chart.dart';


class Pupil extends StatelessWidget {
  final PupilModel pupil;
  final ClassModel classModel;
  const Pupil({required this.pupil, required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Karas.background,
        centerTitle: false,
        title: Text('${pupil.firstname} ${pupil.lastname}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w600),),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
           Container(
             width: double.infinity,
             margin: EdgeInsets.all(20),
             padding: EdgeInsets.all(18),
             decoration: BoxDecoration(
               color: Karas.primary,
               borderRadius: BorderRadius.circular(10),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text('Gender: ${pupil.gender == 'm'?'Male':'Female'}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w600, color: Colors.white),),
                 Text('Guardian: Mr. Chakanga', style: GoogleFonts.gabarito(fontWeight: FontWeight.w600, color: Colors.white),),
                 Text('Class: ${classModel.name}', style: GoogleFonts.gabarito(fontWeight: FontWeight.w600, color: Colors.white),),
               ],
             ),
           ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 18
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Performance', style: GoogleFonts.adamina(fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(height: 10,),
                  Container(
                    height: 250,
                      child: ProgressChart(pupil: pupil, classModel: classModel)
                  ),
                  SizedBox(height: 10,),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(4),
                      height: 90,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Assessment Performance', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
                                    SizedBox(height: 8,),
                                    Row(
                                      children: [
                                        Text('ID:  ', style: TextStyle(color: Colors.grey, fontSize: 11),),
                                        Text('HomeWork2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('SUBMITTED ON:  ', style: TextStyle(color: Colors.grey, fontSize: 11),),
                                        Text('30 Mar 2025', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          ),
                          Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8)
                            ),
                            width: 80,
                            child: Center(child: Text('A+', style: GoogleFonts.abyssinicaSil(fontWeight: FontWeight.bold, fontSize: 30),)),
                          )
                        ],
                      ),
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
