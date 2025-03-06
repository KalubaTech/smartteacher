import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
//import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:smart_teacher/controllers/my_school_controller.dart';
import 'package:smart_teacher/controllers/schools_controoler.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/models/marks_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smart_teacher/views/ebooks/pdf_reader.dart';
import 'package:smart_teacher/models/lesson_plan_model.dart';
import 'data_prefetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PdfHelper{

  Future<void> generateClassListPdf(
      List<PupilModel> students, String classname, String intake, int males, int females) async {
    final pdf = pw.Document();

    // Get controllers
    TeacherController _teacherController = Get.find();
    MySchoolController _myschoolController = Get.find();

    // Load the coat of arms image
    pw.Image? image1;
    try {
      final img = await rootBundle.load('assets/coatofarms.png');
      final imageBytes = img.buffer.asUint8List();
      image1 = pw.Image(pw.MemoryImage(imageBytes));
    } catch (e) {
      print("Error loading image: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        footer: (f)=>pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('page ${f.pageNumber}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Text('SmartTeacher', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
            ]
        ),
        build: (pw.Context context) {
          return [
            pw.Stack(
              children: [
                // Main Content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Image (Coat of Arms)
                    if (image1 != null)
                      pw.Container(
                        alignment: pw.Alignment.center,
                        height: 80,
                        child: image1,
                      ),
                    // School Header
                    pw.Container(
                      width: double.infinity,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text("Ministry of Education",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text("${_myschoolController.myschool.value.name}",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Class Information
                    pw.Row(
                      children: [
                        pw.Text('Class: $classname', style: pw.TextStyle(fontSize: 10)),
                        pw.Spacer(),
                        pw.Text('Year: $intake', style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(width: 20),
                        pw.Text('Male: $males', style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(width: 20),
                        pw.Text('Female: $females', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    // Table
                    pw.Table.fromTextArray(
                      headers: ['SN.', 'NAME', 'GENDER'],
                      headerAlignment: pw.Alignment.centerLeft,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      columnWidths: {
                        0: pw.FixedColumnWidth(40),  // SN column width
                        1: pw.FlexColumnWidth(),     // Name column takes remaining space
                        2: pw.FixedColumnWidth(65),  // Gender column width
                      },
                      cellStyle: pw.TextStyle(fontSize: 12,), // Set font size for table content
                      data: List.generate(
                        students.length,
                            (index) => [
                          index + 1,
                          '${students[index].firstname} ${students[index].lastname}',
                          students[index].gender == 'f' ? 'Female' : 'Male',
                        ],
                      ),
                    ),

                  ],
                ),

                // Footer at the bottom
              ],
            )
          ];
        },
      ),
    );

    // Request storage permission for Android 10+
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {

      // Use public Documents folder
      Directory targetDir = Directory("/storage/emulated/0/Documents/Smart Teacher/Class Lists/${intake}/${classname}");

      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final file = File("${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: ${file.path}");
      Get.defaultDialog(
        content: Container(
          child: Column(
            children: [
              CircleAvatar(child: Icon(Icons.download_done)),
              SizedBox(height: 10,),
              Text('Saved to documents'),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: (){
                    Get.back();
                    Get.to(()=>PdfReader(path: file.path,));
                  },
                  child: Text('Open')
              )
            ],
          ),
        ),
        title: ''
      );
    } else {
      print("Storage permission denied");
    }
  }

  Future<int> getPupilPosition(String pupilId, String test, String classname, String intake) async {
    var totalsSnapshot = await FirebaseFirestore.instance
        .collection('results')
        .where('assessment', isEqualTo: test)
        .where('class', isEqualTo: classname)
        .where('year', isEqualTo: intake)
        .get();

    // Step 1: Group results by pupil and calculate total marks
    Map<String, int> pupilTotals = {};


    print("PUPIL ID ${pupilId}");

    for (var doc in totalsSnapshot.docs) {
      String pupil = doc.get('pupil'); // Assuming 'pupilId' uniquely identifies each student
      int marks = int.parse(doc.get('marks'));

      print(pupil);

      pupilTotals[pupil] = (pupilTotals[pupil] ?? 0) + marks;
    }

    // Step 2: Sort pupils by total marks in descending order
    var sortedPupils = pupilTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Highest first

    // Step 3: Find the position of the specific pupil
    for (int i = 0; i < sortedPupils.length; i++) {
      //print("PUPIL ID: ${i + 1} = "+sortedPupils[i].key);
      if (sortedPupils[i].key == pupilId) {

        return i + 1; // Position is 1-based
      }
    }

    print(sortedPupils);
    return -1; // Return -1 if the pupil is not found
  }


  Future<void> generateMarkSchedulePdf(
      String classname, List<MarksModel> marks, String test, String subject, String intake) async {
    final pdf = pw.Document();

    // Get controllers
    TeacherController _teacherController = Get.find();
    MySchoolController _myschoolController = Get.find();

    var position = 0;
    
    var totals = await FirebaseFirestore.instance.collection('results').where('test', isEqualTo: test).where('class', isEqualTo: classname).where('year', isEqualTo: intake).get();

    // Load the coat of arms image
    pw.Image? image1;
    try {
      final img = await rootBundle.load('assets/coatofarms.png');
      final imageBytes = img.buffer.asUint8List();
      image1 = pw.Image(pw.MemoryImage(imageBytes));
    } catch (e) {
      print("Error loading image: $e");
    }

    // ✅ Fetch pupil names before generating the table
    List<String> pupilNames = [];
    for (var mark in marks) {
      var pupilData = await DataPrefetch().fetchPupil(mark.pupil);
      pupilNames.add("${pupilData.firstname} ${pupilData.lastname}");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        footer: (f)=>pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('page ${f.pageNumber}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Text('SmartTeacher', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
            ]
        ),
        build: (pw.Context context) {
          return [
            pw.Stack(
              children: [
                // Main Content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Image (Coat of Arms)
                    if (image1 != null)
                      pw.Container(
                        alignment: pw.Alignment.center,
                        height: 80,
                        child: image1,
                      ),

                    // School Header
                    pw.Container(
                      width: double.infinity,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text("Ministry of Education",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text("${_myschoolController.myschool.value.name}",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text("Grade ${classname} ${subject} ${test} Results",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Table
                    pw.Table.fromTextArray(
                      headers: ['SN.', 'NAME', 'MARKS'],
                      headerAlignment: pw.Alignment.centerLeft,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      cellStyle: pw.TextStyle(fontSize: 12,), // Set font size for table content
                      columnWidths: {
                        0: pw.FixedColumnWidth(40),  // SN column width
                        1: pw.FlexColumnWidth(),     // Name column takes remaining space
                        2: pw.FixedColumnWidth(65),  // Marks column width
                      },
                      data: List.generate(
                        marks.length,
                            (index) => [
                          index + 1,
                          pupilNames[index], // ✅ Now we use the fetched name
                          marks[index].marks,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          ];
        },
      ),
    );

    // Request storage permission for Android 10+
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      Directory targetDir = Directory("/storage/emulated/0/Documents/Smart Teacher/Mark Schedules/${intake}/${classname}/${subject}/${test}");

      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final file = File("${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: ${file.path}");
      Get.defaultDialog(
          content: Column(
            children: [
              CircleAvatar(child: Icon(Icons.download_done)),
              SizedBox(height: 10),
              Text('Saved to documents'),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => PdfReader(path: file.path));
                  },
                  child: Text('Open'))
            ],
          ),
          title: ''
      );
    } else {
      print("Storage permission denied");
    }
  }

  Future<void> generateReportFormPdf(PupilModel pupil,
      String classname, List<Map> marks, String test, String intake) async {
    final pdf = pw.Document();

    // Get controllers
    TeacherController _teacherController = Get.find();
    MySchoolController _myschoolController = Get.find();
    MyClassesController _myClassesController = Get.find();

    String classn = _myClassesController.myclasses.where((mc)=>mc.uid==classname).first.name;
    int totalMarks = marks.fold(0, (sum, item) => sum + (int.parse(item['marks']) as int));

    int position = await getPupilPosition(pupil.uid, test, classname, intake);

    // Load the coat of arms image
    pw.Image? image1;
    try {
      final img = await rootBundle.load('assets/coatofarms.png');
      final imageBytes = img.buffer.asUint8List();
      image1 = pw.Image(pw.MemoryImage(imageBytes));
    } catch (e) {
      print("Error loading image: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        footer: (f)=>pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              //pw.Text('page ${f.pageNumber}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              pw.Text('SmartTeacher', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
            ]
        ),
        build: (pw.Context context) {
          return [
            pw.Stack(
              children: [
                // Main Content
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Image (Coat of Arms)
                    if (image1 != null)
                      pw.Container(
                        alignment: pw.Alignment.center,
                        height: 80,
                        child: image1,
                      ),

                    // School Header
                    pw.Container(
                      width: double.infinity,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text("Ministry of Education",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text("${_myschoolController.myschool.value.name}",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 8),
                          pw.Text("Grade ${classn} ${test} Results",
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),
                    pw.Row(
                      children: [
                        pw.Text('PUPIL:    ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${pupil.firstname} ${pupil.lastname}'.toUpperCase()),
                        pw.Spacer(),
                        pw.Text('Position in class: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${position}'),
                      ]
                    ),
                    pw.SizedBox(height: 8),
                    // Table
                    pw.Table.fromTextArray(
                      headers: ['SN.', 'SUBJECT', 'MARKS'],
                      headerAlignment: pw.Alignment.centerLeft,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
                      cellStyle: pw.TextStyle(fontSize: 12,), // Set font size for table content
                      columnWidths: {
                        0: pw.FixedColumnWidth(40),  // SN column width
                        1: pw.FlexColumnWidth(),     // Name column takes remaining space
                        2: pw.FixedColumnWidth(65),  // Marks column width
                      },
                      data: List.generate(
                        marks.length,
                            (index) => [
                          index + 1,
                          marks[index]['subject'],
                              marks[index]['marks'],
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('Total score:  ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('${totalMarks}') 

                      ]
                    ),
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text('Average:  ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('${totalMarks/marks.length}') 

                        ]
                    )
                  ],
                ),
              ],
            )
          ];
        },
      ),
    );

    // Request storage permission for Android 10+
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      Directory targetDir = Directory("/storage/emulated/0/Documents/Smart Teacher/Report Forms/${classn}/${intake}${pupil.firstname} ${pupil.lastname}/${test}");

      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final file = File("${targetDir.path}/report_form_${DateTime.now().microsecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: ${file.path}");
      Get.defaultDialog(
          content: Column(
            children: [
              CircleAvatar(child: Icon(Icons.download_done)),
              SizedBox(height: 10),
              Text('Saved to documents'),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => PdfReader(path: file.path));
                  },
                  child: Text('Open'))
            ],
          ),
          title: ''
      );
    } else {
      print("Storage permission denied");
    }
  }

  Future<void> generateLessonPlanPdf(LessonPlan lessonPlan) async {
    final pdf = pw.Document();

    // Get controllers
    TeacherController _teacherController = Get.find();
    MySchoolController _myschoolController = Get.find();

    var schoolData = await FirebaseFirestore.instance.collection('schools').doc(_teacherController.teacher.value.first.school).get();


    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.portrait,
        footer: (f)=>pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('page ${f.pageNumber}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            pw.Text('SmartTeacher', style: pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
          ]
        ),
        build: (pw.Context context) {
          return [
            pw.Container(
                width: double.infinity,
                child: pw.ListView(
                children: [
                pw.SizedBox(height: 20,),
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('LESSON PLAN', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
            ),
            pw.SizedBox(height: 20,),
            pw.Container(
              child: pw.Table(
                children: [
                  pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('NAME:     ${_teacherController.teacher.first.firstname}', style: pw.TextStyle(fontSize: 9),),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('DATE:     ${lessonPlan.date.split(' ').first}', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                  pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: pw.Text('SCHOOL:     ${schoolData.get('name')}', style: pw.TextStyle(fontSize: 9),)
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('TIME:     ${lessonPlan.time}', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                  pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('SUBJECT:     ${lessonPlan.subject}', style: pw.TextStyle(fontSize: 9),),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('DURATION:     ${lessonPlan.duration}', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                  pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('GRADE:     ${lessonPlan.grade}', style: pw.TextStyle(fontSize: 9),),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('No. of Pupils: ', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                  pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('TOPIC:     ${lessonPlan.topic}', style: pw.TextStyle(fontSize: 9),),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('Expected (Boys: ${lessonPlan.expBoys}, Girls: ${lessonPlan.expGirls})', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                  pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('SUB-TOPIC:     ${lessonPlan.subtopic}', style: pw.TextStyle(fontSize: 9),),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('Actual (Boys: ${lessonPlan.actBoys.isEmpty?'_____ ':lessonPlan.actBoys} , Girls: ${lessonPlan.actGirls==''?'_____':lessonPlan.actGirls})', style: pw.TextStyle(fontSize: 9),),
                        )
                      ]
                  ),
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Pre-requisite Knowledge', style: pw.TextStyle(fontSize: 11),),
                  pw.SizedBox(height: 4,),
                  pw.Text('${lessonPlan.preRequisiteKnowledge}',  style: pw.TextStyle(fontSize: 9))
                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('LESSON OBJECTIVES: By the end of the lesson P.S.B.A.T', style: pw.TextStyle(fontSize: 10),),
                  pw.SizedBox(height: 4,),
                  ...List.generate(lessonPlan.objectives.length, (i)=>
                      pw.Row(
                          children: [
                            pw.Text('-  ', style: pw.TextStyle(fontSize: 9)),
                            pw.Text('${lessonPlan.objectives[i]}',  style: pw.TextStyle(fontSize: 9))
                          ]
                      )
                  )

                ],
              ),
            ),
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('RATIONALE:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  pw.SizedBox(height: 4,),
                  pw.Row(
                    children: [
                      pw.Text('Content:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                      pw.Text('  ${lessonPlan.ratContent}', style: pw.TextStyle(fontSize: 10),),
                    ],
                  ),
                  pw.SizedBox(height: 4,),
                  pw.Row(
                    children: [
                      pw.Text('Value:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                      pw.Text('  ${lessonPlan.ratValue}', style: pw.TextStyle(fontSize: 10),),
                    ],
                  ),
                  pw.SizedBox(height: 4,),
                  pw.Row(
                    children: [
                      pw.Text('Position:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                      pw.Text('  ${lessonPlan.ratPosition}', style: pw.TextStyle(fontSize: 10),),
                    ],
                  ),
                  pw.SizedBox(height: 4,),
                  pw.Row(
                    children: [
                      pw.Text('Strategy:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                      pw.Text('  ${lessonPlan.ratStrategy}', style: pw.TextStyle(fontSize: 10),),
                    ],
                  ),
                  pw.SizedBox(height: 6,),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TEACHING AND LEARNING RESOURCES: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                    ],
                  ),
                  pw.SizedBox(height: 4,),
                  pw.Text('${lessonPlan.teachingLearningResources}', style: pw.TextStyle(fontSize: 10),),
                  pw.SizedBox(height: 10,),
                  pw.Text('REFERENCES: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  ...lessonPlan.references.map((ref)=>pw.Row(
                      children: [
                        pw.Text('-  '),
                        pw.Text(ref, style: pw.TextStyle(fontSize: 10),)
                      ]
                  )),
                  pw.SizedBox(height: 10),
                  pw.Text('LESSON DEVELOPMENT: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  pw.SizedBox(height: 4,),
                  pw.Container(
                    child: pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: pw.Text('TIME', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: pw.Text('STEPS OR CONTENT', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: pw.Text('TEACHER\'S ACTIVITY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: pw.Text('LEARNER\'S ACTIVITY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: pw.Text('ORG/METHOD', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),),
                              ),
                            ]
                        ),
                        ...
                        lessonPlan.lessonDevelopment.map((item){
                          return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: pw.Text('${item['time']}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('${item['title']}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                                      ...item['steps'].map((step)=>pw.Text('- ${step}', style: pw.TextStyle(fontSize: 7)))
                                    ],
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      ...item['teachers'].map((step)=>pw.Text('- ${step}', style: pw.TextStyle(fontSize: 7)))
                                    ],
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      ...item['learners'].map((step)=>pw.Text('- ${step}', style: pw.TextStyle(fontSize: 7)))
                                    ],
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      ...item['methods'].map((step)=>pw.Text('- ${step}', style: pw.TextStyle(fontSize: 7)))
                                    ],
                                  ),
                                ),
                              ]
                          );
                        })
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4,),
                  pw.Text('CONCLUSION: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  pw.Text('${lessonPlan.conclusion}', style: pw.TextStyle(fontSize: 10),),
                  pw.SizedBox(height: 4,),
                  pw.Text('FOLLOWUP EXERCISE: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  pw.Text('${lessonPlan.exercise}', style: pw.TextStyle(fontSize: 10),),
                  pw.SizedBox(height: 4,),
                  pw.Text('EVALUATION: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),),
                  pw.Text('${lessonPlan.evaluation}', style: pw.TextStyle(fontSize: 10),),

                ],
              ),
            ),
            pw.SizedBox(height: 100,)
          ],
          ))];
        },
      ),
    );

    // Request storage permission for Android 10+
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      Directory targetDir = Directory("/storage/emulated/0/Documents/Smart Teacher/Lesson Plans/${lessonPlan.grade}/${lessonPlan.subject}");

      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final file = File("${targetDir.path}/${lessonPlan.date.split(' ').first.replaceAll('-', '_')}.pdf");
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: ${file.path}");
      Get.defaultDialog(
          content: Column(
            children: [
              CircleAvatar(child: Icon(Icons.download_done)),
              SizedBox(height: 10),
              Text('Saved to documents'),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => PdfReader(path: file.path));
                  },
                  child: Text('Open'))
            ],
          ),
          title: ''
      );
    } else {
      print("Storage permission denied");
    }
  }

/*
  Future<void> generateLessonPlanPdf(LessonPlan lessonPlan) async {
    final pdf = pw.Document();

    // Get controllers
    TeacherController _teacherController = Get.find();
    MySchoolController _myschoolController = Get.find();

    var schoolData = await FirebaseFirestore.instance.collection('schools').doc(_teacherController.teacher.value.first.school).get();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'LESSON PLAN',
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                // Lesson Plan Table
                pw.Table(
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('NAME: ${_teacherController.teacher.first.firstname}', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('DATE: ${lessonPlan.date.split(' ').first}', style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('SCHOOL: ${schoolData.get('name')}', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('TIME: ${lessonPlan.time}', style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('SUBJECT: ${lessonPlan.subject}', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('DURATION: ${lessonPlan.duration}', style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('GRADE: ${lessonPlan.grade}', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('No. of Pupils:', style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('TOPIC: ${lessonPlan.topic}', style: pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: pw.Text('Expected (Boys: ${lessonPlan.expBoys}, Girls: ${lessonPlan.expGirls})', style: pw.TextStyle(fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                // Pre-requisite Knowledge
                pw.Text('Pre-requisite Knowledge', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${lessonPlan.preRequisiteKnowledge}', style: pw.TextStyle(fontSize: 9)),

                pw.SizedBox(height: 10),
                // Lesson Objectives
                pw.Text('LESSON OBJECTIVES: By the end of the lesson P.S.B.A.T', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                ...lessonPlan.objectives.map((obj) => pw.Bullet(text: obj, style: pw.TextStyle(fontSize: 9))),

                pw.SizedBox(height: 10),
                // Lesson Development Table
                pw.Text('LESSON DEVELOPMENT:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('TIME', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('STEPS OR CONTENT', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('TEACHER\'S ACTIVITY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('LEARNER\'S ACTIVITY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: pw.Text('ORG/METHOD', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...lessonPlan.lessonDevelopment.map(
                          (item) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: pw.Text('${item['time']}', style: pw.TextStyle(fontSize: 7)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: pw.Text('${item['steps']}', style: pw.TextStyle(fontSize: 7)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: pw.Text('${item['teacherActivity']}', style: pw.TextStyle(fontSize: 7)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: pw.Text('${item['learnerActivity']}', style: pw.TextStyle(fontSize: 7)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: pw.Text('${item['method']}', style: pw.TextStyle(fontSize: 7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save or Share PDF
    // Request storage permission for Android 10+
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      Directory targetDir = Directory("/storage/emulated/0/Documents");

      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final file = File("${targetDir.path}/class_list_${lessonPlan.grade}.pdf");
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: ${file.path}");
      Get.defaultDialog(
          content: Column(
            children: [
              CircleAvatar(child: Icon(Icons.download_done)),
              SizedBox(height: 10),
              Text('Saved to documents'),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => PdfReader(path: file.path));
                  },
                  child: Text('Open'))
            ],
          ),
          title: ''
      );
    } else {
      print("Storage permission denied");
    }
  }
*/

}