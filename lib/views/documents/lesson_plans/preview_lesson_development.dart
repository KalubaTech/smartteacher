import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviewLessonDevelopment extends StatelessWidget {
  List items;
  PreviewLessonDevelopment({required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Lesson Development', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24),),
      ),
      body: Container(
        child: Column(
          children: [
            Container(),
            Expanded(
                child: Container(
                  child: Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Text('TIME', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text('STEPS OR CONTENT', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text('TEACHER\'S ACTIVITY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text('LEARNER\'S ACTIVITY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            child: Text('ORG/METHOD', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),),
                          ),
                        ]
                      ),
                      ...
                          items.map((item){
                            return TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text('${item['time']}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${item['title']}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
                                        ...item['steps'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['teachers'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['learners'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...item['methods'].map((step)=>Text('- ${step}', style: TextStyle(fontSize: 7)))
                                      ],
                                    ),
                                  ),
                                ]
                            );
                          })
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}
