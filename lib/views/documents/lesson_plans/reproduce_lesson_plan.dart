import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/controllers/my_classes_controller.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/my_subjects_controller.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/models/lesson_plan_model.dart';
import 'package:smart_teacher/models/pupil_model.dart';
import 'package:smart_teacher/models/timetable_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/documents/lesson_plans/preview_lesson_development.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ReproduceLessonPlan extends StatefulWidget {
  final LessonPlan lessonPlanItem; // Use to prefill
  final String uid;
  ReproduceLessonPlan(this.lessonPlanItem, this.uid);

  @override
  State<ReproduceLessonPlan> createState() => _ReproduceLessonPlanState();
}

class _ReproduceLessonPlanState extends State<ReproduceLessonPlan> {
  DateTime? _selectedDate;

  Future<void> _openCalendarPopup() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Default to today if no date is selected
      firstDate: DateTime(2000), // Earliest selectable date
      lastDate: DateTime(2100), // Latest selectable date
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    } else {
      return;
    }
  }

  bool isLoading = false;

  MyClassesController _myClassesController = Get.find();
  TeacherController _teacherController = Get.find();

  TextEditingController _objectiveController = TextEditingController();
  TextEditingController _topicController = TextEditingController();
  TextEditingController _subtopicController = TextEditingController();
  TextEditingController _prerequisiteKnowldgeController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _valueController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  TextEditingController _strategyController = TextEditingController();
  TextEditingController _teachlearnController = TextEditingController();
  TextEditingController _referenceController = TextEditingController();
  TextEditingController _stepsPointController = TextEditingController();
  TextEditingController _stepsTitleController = TextEditingController();
  TextEditingController _teacherActivityPointController = TextEditingController();
  TextEditingController _learnersActivityPointController = TextEditingController();
  TextEditingController _methodsActivityPointController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _conclusionController = TextEditingController();
  TextEditingController _exerciseController = TextEditingController();
  var objectives = [].obs;
  var stepsContents = [].obs;
  var learnersActivityContents = [].obs;
  var teachersActivityContents = [].obs;
  var methodsContents = [].obs;
  var lesson_development_items = [].obs;

  var title = ''.obs;
  var references = [].obs;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  var seletedTimetable = TimetableModel(
      classname: '',
      subject: '',
      duration: '',
      day: '',
      starttime: '',
      stoptime: '').obs;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _prefillFormData();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening(TextEditingController tec) async {
    await _speechToText.listen(onResult:(result)=>_onSpeechResult(result,tec) );
    setState(() {});
  }

  /// the platform returns recognized words.
  void _onSpeechResult(result,TextEditingController tec) {
    setState(() {
      _lastWords = result.recognizedWords;
      tec.text = _lastWords;
    });
  }

  void _prefillFormData() {
    // Prefill form fields using lessonPlanItem
    _topicController.text = widget.lessonPlanItem.topic;
    _subtopicController.text = widget.lessonPlanItem.subtopic;
    _prerequisiteKnowldgeController.text = widget.lessonPlanItem.preRequisiteKnowledge;
    _contentController.text = widget.lessonPlanItem.ratContent;
    _valueController.text = widget.lessonPlanItem.ratValue;
    _positionController.text = widget.lessonPlanItem.ratPosition;
    _strategyController.text = widget.lessonPlanItem.ratStrategy;
    _teachlearnController.text = widget.lessonPlanItem.teachingLearningResources;
    _conclusionController.text = widget.lessonPlanItem.conclusion;
    _exerciseController.text = widget.lessonPlanItem.exercise;

    objectives.value = widget.lessonPlanItem.objectives;
    references.value = widget.lessonPlanItem.references;
    lesson_development_items.value = widget.lessonPlanItem.lessonDevelopment;

    // Prefill selected timetable
    seletedTimetable.value = TimetableModel(
      classname: widget.lessonPlanItem.grade,
      subject: widget.lessonPlanItem.subject,
      duration: widget.lessonPlanItem.duration,
      day: '', // Add day if available
      starttime: widget.lessonPlanItem.time,
      stoptime: '', // Add stop time if available
    );

    // Prefill date
    if (widget.lessonPlanItem.date != null) {
      try {
        // Parse the date string using the correct format
        _selectedDate = DateFormat('yyyy-M-d').parse(widget.lessonPlanItem.date!);
      } catch (e) {
        print("Error parsing date: $e");
        // Fallback to the current date if parsing fails
        _selectedDate = DateTime.now();
      }
    }
  }

  void _updateLessonPlan() async {
    // Validate required fields
    if (_topicController.text.isEmpty ||
        _subtopicController.text.isEmpty ||
        _prerequisiteKnowldgeController.text.isEmpty ||
        objectives.isEmpty ||
        _contentController.text.isEmpty ||
        _valueController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _strategyController.text.isEmpty ||
        _teachlearnController.text.isEmpty ||
        references.isEmpty ||
        lesson_development_items.isEmpty ||
        _conclusionController.text.isEmpty ||
        _exerciseController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare data for updating
      Map<String, dynamic> data = {
        'subject': seletedTimetable.value.subject,
        'grade': seletedTimetable.value.classname,
        'topic': _topicController.text,
        'subtopic': _subtopicController.text,
        'time': seletedTimetable.value.starttime,
        'duration': seletedTimetable.value.duration,
        'pre_requisite_knowledge': _prerequisiteKnowldgeController.text,
        'objectives': objectives.value,
        'rat_content': _contentController.text,
        'rat_value': _valueController.text,
        'rat_position': _positionController.text,
        'rat_strategy': _strategyController.text,
        'teaching_and_learning_resources': _teachlearnController.text,
        'references': references.value,
        'lesson_development': lesson_development_items.value,
        'conclusion': _conclusionController.text,
        'exercise': _exerciseController.text,
        'teacher': _teacherController.teacher.value.first.uid,
        'year': '${_selectedDate!.year}',
        'date': '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
      };

      // Update the lesson plan in Firestore
      await FirebaseFirestore.instance
          .collection('lesson_plans')
          .doc(widget.uid) // Use the existing document ID
          .update(data);

      // Show success message
      Fluttertoast.showToast(
        msg: "Lesson plan updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Navigate back or perform other actions
      Get.back();
    } catch (e) {
      // Handle errors
      Fluttertoast.showToast(
        msg: "Failed to update lesson plan: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Re-Produce Lesson Plan', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 10),
            Container(
              height: 45,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject / Class / Start time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                        seletedTimetable.value.day.isNotEmpty
                            ? '${seletedTimetable.value.subject} / ${seletedTimetable.value.classname} / ${seletedTimetable.value.starttime}'
                            : 'Select from timetable',
                        style: GoogleFonts.gabarito(fontSize: 16),
                      ),),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Get.bottomSheet(
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text('Timetable', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20)),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Container(
                                      child: ListView(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        shrinkWrap: true,
                                        children: [
                                          StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('timetable')
                                                .where('teacher', isEqualTo: _teacherController.teacher.first.uid)
                                                .snapshots(),
                                            builder: (c, s) {
                                              return s.hasData && s.data!.docs.isNotEmpty
                                                  ? Table(
                                                columnWidths: {
                                                  1: FixedColumnWidth(45),
                                                  2: FixedColumnWidth(60),
                                                  3: FixedColumnWidth(50),
                                                  4: FixedColumnWidth(60),
                                                  5: FixedColumnWidth(30),
                                                },
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: Text('Subject', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: Text('Class', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: Text('Day', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: Text('Start', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                        child: Text('Duration', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                                      ),
                                                      Text('')
                                                    ],
                                                  ),
                                                  ...s.data!.docs.map((doc) {
                                                    // Define the two times
                                                    TimeOfDay startTime = TimeOfDay(hour: int.parse(doc.get('starttime').split(':').first), minute: int.parse(doc.get('starttime').split(':').last));
                                                    TimeOfDay endTime = TimeOfDay(hour: int.parse(doc.get('stoptime').split(':').first), minute: int.parse(doc.get('stoptime').split(':').last));

                                                    // Convert the times to DateTime objects
                                                    DateTime startDateTime = DateTime(2024, 1, 1, startTime.hour, startTime.minute);
                                                    DateTime endDateTime = DateTime(2024, 1, 1, endTime.hour, endTime.minute);

                                                    // Calculate the difference
                                                    Duration difference = endDateTime.difference(startDateTime);
                                                    return TableRow(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          child: Text('${doc.get('subject')}', style: TextStyle(fontSize: 11)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          child: Text('${doc.get('class')}', style: TextStyle(fontSize: 11)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          child: Text('${doc.get('day')}', style: TextStyle(fontSize: 11)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          child: Text('${doc.get('starttime')}', style: TextStyle(fontSize: 11)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                          child: Text('${CommonMethods().formatDuration(difference)}', style: TextStyle(fontSize: 11)),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                                          child: InkWell(
                                                            onTap: () {
                                                              seletedTimetable.value = TimetableModel(
                                                                classname: '${doc.get('class')}',
                                                                subject: '${doc.get('subject')}',
                                                                duration: CommonMethods().formatDuration(difference),
                                                                day: '${doc.get('day')}',
                                                                starttime: '${doc.get('starttime')}',
                                                                stoptime: '${doc.get('stoptime')}',
                                                              );
                                                              Get.back();
                                                            },
                                                            child: CircleAvatar(
                                                              radius: 12,
                                                              child: Icon(Icons.add),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ],
                                              )
                                                  : Container();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              color: Colors.white,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Text(' Change', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_drop_down_circle, color: Colors.green),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('TOPIC:', style: GoogleFonts.gabarito()),
                    ],
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: Kalutext(
                        controller: _topicController,
                        borderRadius: BorderRadius.circular(4),
                        hintText: 'Type lesson topic...',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    child: Icon(Icons.mic, color: Colors.blue),
                    onTap: () async {
                      _startListening(_topicController);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SUB TOPIC:', style: GoogleFonts.gabarito()),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: Kalutext(
                        controller: _subtopicController,
                        borderRadius: BorderRadius.circular(4),
                        hintText: 'Type lesson sub topic...',
                      ),
                    ),
                  ),
                  InkWell(
                    child: Icon(Icons.mic, color: Colors.blue),
                    onTap: () async {
                      _startListening(_subtopicController);
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pre-requisite knowledge:', style: GoogleFonts.gabarito()),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _prerequisiteKnowldgeController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Pre-requisite knowledge',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_prerequisiteKnowldgeController);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade200),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LESSON OBJECTIVES: By the end of the lesson P.S.B.A.T', style: GoogleFonts.gabarito()),
                  SizedBox(height: 10),
                  Obx(() => Table(
                    columnWidths: {
                      0: FixedColumnWidth(30),
                      2: FixedColumnWidth(25),
                    },
                    children: [
                      ...List.generate(objectives.length, (i) => TableRow(
                        children: [
                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${objectives[i]}.', style: TextStyle(fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () {
                              objectives.value.removeAt(i);
                              setState(() {});
                            },
                            child: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ],
                      )),
                    ],
                  )),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _objectiveController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Objective item ...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          objectives.value.add(_objectiveController.text);
                          setState(() {
                            _objectiveController.clear();
                          });
                        },
                        icon: Icon(Icons.add, color: Colors.green),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_objectiveController);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RATIONALE:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Content: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: TextField(
                                controller: _contentController,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Content...',
                                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              child: Icon(Icons.mic, color: Colors.blue),
                              onTap: () async {
                                _startListening(_contentController);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Value: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: TextField(
                                controller: _valueController,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Value...',
                                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              child: Icon(Icons.mic, color: Colors.blue),
                              onTap: () async {
                                _startListening(_valueController);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Position: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: TextField(
                                controller: _positionController,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Position...',
                                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              child: Icon(Icons.mic, color: Colors.blue),
                              onTap: () async {
                                _startListening(_positionController);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Strategy: ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: TextField(
                                controller: _strategyController,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: 'Strategy...',
                                  hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                maxLines: 1,
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              child: Icon(Icons.mic, color: Colors.blue),
                              onTap: () async {
                                _startListening(_strategyController);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TEACHING AND LEARNING RESOURCES: ', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _teachlearnController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Teaching and learning resources...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_teachlearnController);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('REFERENCES: ', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Obx(() => Table(
                    columnWidths: {
                      0: FixedColumnWidth(30),
                      2: FixedColumnWidth(25),
                    },
                    children: [
                      ...List.generate(references.length, (i) => TableRow(
                        children: [
                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${references[i]}.', style: TextStyle(fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () {
                              references.value.removeAt(i);
                              setState(() {});
                            },
                            child: Icon(Icons.remove_circle, color: Colors.red),
                          ),
                        ],
                      )),
                    ],
                  )),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _referenceController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Reference item ...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          references.value.add(_referenceController.text);
                          setState(() {
                            _referenceController.clear();
                          });
                        },
                        icon: Icon(Icons.add, color: Colors.green),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_referenceController);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey.shade100),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LESSON DEVELOPMENT: ', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                            () => lesson_development_items.value.isNotEmpty
                            ? ElevatedButton(
                          onPressed: () {
                            Get.to(
                                  () => PreviewLessonDevelopment(items: lesson_development_items.value),
                              transition: Transition.fade,
                            );
                          },
                          child: Text('Preview'),
                        )
                            : Container(),
                      ),
                      IconButton(
                        onPressed: () {
                          Get.bottomSheet(
                            StatefulBuilder(
                              builder: (context, state) {
                                return Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Container(
                                        child: Text('LESSON DEVELOPMENT', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20)),
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                      Divider(color: Colors.grey.shade100),
                                      Expanded(
                                        child: ListView(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          children: [
                                            Text('TIME', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _timeController,
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.grey.shade100,
                                                      filled: true,
                                                      hintText: 'Time...',
                                                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                InkWell(
                                                  child: Icon(Icons.mic, color: Colors.blue),
                                                  onTap: () async {
                                                    _startListening(_timeController);
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            Text('STEPS OR CONTENT', style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(height: 10),
                                            Text('Title (e.g. Introduction, Demonstration, etc.)', style: TextStyle(fontWeight: FontWeight.w400)),
                                            DropdownSearch(
                                              compareFn: (a, b) => a == b,
                                              selectedItem: title.value,
                                              items: (x, y) => [
                                                'INTRODUCTION',
                                                'DEMONSTRATION',
                                                'CONCLUSION'
                                              ],
                                              onChanged: (value) {
                                                title.value = value;
                                              },
                                              popupProps: PopupProps.menu(fit: FlexFit.loose),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              color: Colors.grey.shade100,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Obx(() => Table(
                                                    columnWidths: {
                                                      0: FixedColumnWidth(30),
                                                      2: FixedColumnWidth(25),
                                                    },
                                                    children: [
                                                      ...List.generate(stepsContents.length, (i) => TableRow(
                                                        children: [
                                                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text('${stepsContents[i]}.', style: TextStyle(fontWeight: FontWeight.w500)),
                                                          InkWell(
                                                            onTap: () {
                                                              stepsContents.removeAt(i);
                                                            },
                                                            child: Icon(Icons.remove_circle, color: Colors.red),
                                                          ),
                                                        ],
                                                      )),
                                                    ],
                                                  )),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor: Colors.black,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _stepsPointController,
                                                          decoration: InputDecoration(
                                                            fillColor: Colors.grey.shade100,
                                                            filled: true,
                                                            hintText: '',
                                                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          stepsContents.add(_stepsPointController.text);
                                                          _stepsPointController.clear();
                                                        },
                                                        icon: Icon(Icons.add, color: Colors.green),
                                                      ),
                                                      SizedBox(width: 10),
                                                      InkWell(
                                                        child: Icon(Icons.mic, color: Colors.blue),
                                                        onTap: () async {
                                                          _startListening(_stepsPointController);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),
                                                  Text('TEACHER\'S ACTIVITY', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                  Obx(() => Table(
                                                    columnWidths: {
                                                      0: FixedColumnWidth(30),
                                                      2: FixedColumnWidth(25),
                                                    },
                                                    children: [
                                                      ...List.generate(teachersActivityContents.length, (i) => TableRow(
                                                        children: [
                                                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text('${teachersActivityContents[i]}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          InkWell(
                                                            onTap: () {
                                                              teachersActivityContents.removeAt(i);
                                                            },
                                                            child: Icon(Icons.remove_circle, color: Colors.red),
                                                          ),
                                                        ],
                                                      )),
                                                    ],
                                                  )),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor: Colors.black,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _teacherActivityPointController,
                                                          decoration: InputDecoration(
                                                            fillColor: Colors.grey.shade100,
                                                            filled: true,
                                                            hintText: '',
                                                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          teachersActivityContents.add(_teacherActivityPointController.text);
                                                          _teacherActivityPointController.clear();
                                                        },
                                                        icon: Icon(Icons.add, color: Colors.green),
                                                      ),
                                                      SizedBox(width: 10),
                                                      InkWell(
                                                        child: Icon(Icons.mic, color: Colors.blue),
                                                        onTap: () async {
                                                          _startListening(_teacherActivityPointController);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),
                                                  Text('LEARNER\'S ACTIVITY', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                  Obx(() => Table(
                                                    columnWidths: {
                                                      0: FixedColumnWidth(30),
                                                      2: FixedColumnWidth(25),
                                                    },
                                                    children: [
                                                      ...List.generate(learnersActivityContents.length, (i) => TableRow(
                                                        children: [
                                                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text('${learnersActivityContents[i]}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          InkWell(
                                                            onTap: () {
                                                              learnersActivityContents.removeAt(i);
                                                            },
                                                            child: Icon(Icons.remove_circle, color: Colors.red),
                                                          ),
                                                        ],
                                                      )),
                                                    ],
                                                  )),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor: Colors.black,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _learnersActivityPointController,
                                                          decoration: InputDecoration(
                                                            fillColor: Colors.grey.shade100,
                                                            filled: true,
                                                            hintText: '',
                                                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          learnersActivityContents.add(_learnersActivityPointController.text);
                                                          _learnersActivityPointController.clear();
                                                        },
                                                        icon: Icon(Icons.add, color: Colors.green),
                                                      ),
                                                      SizedBox(width: 10),
                                                      InkWell(
                                                        child: Icon(Icons.mic, color: Colors.blue),
                                                        onTap: () async {
                                                          _startListening(_learnersActivityPointController);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 15),
                                                  Text('ORG/METHOD', style: TextStyle(fontWeight: FontWeight.bold)),
                                                  SizedBox(height: 10),
                                                  Obx(() => Table(
                                                    columnWidths: {
                                                      0: FixedColumnWidth(30),
                                                      2: FixedColumnWidth(25),
                                                    },
                                                    children: [
                                                      ...List.generate(methodsContents.length, (i) => TableRow(
                                                        children: [
                                                          Text('${CommonMethods().toRomanNumerals(i + 1)}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          Text('${methodsContents[i]}.', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          InkWell(
                                                            onTap: () {
                                                              methodsContents.removeAt(i);
                                                            },
                                                            child: Icon(Icons.remove_circle, color: Colors.red),
                                                          ),
                                                        ],
                                                      )),
                                                    ],
                                                  )),
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 4,
                                                        backgroundColor: Colors.black,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _methodsActivityPointController,
                                                          decoration: InputDecoration(
                                                            fillColor: Colors.grey.shade100,
                                                            filled: true,
                                                            hintText: '',
                                                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          methodsContents.add(_methodsActivityPointController.text);
                                                          _methodsActivityPointController.clear();
                                                        },
                                                        icon: Icon(Icons.add, color: Colors.green),
                                                      ),
                                                      SizedBox(width: 10),
                                                      InkWell(
                                                        child: Icon(Icons.mic, color: Colors.blue),
                                                        onTap: () async {
                                                          _startListening(_methodsActivityPointController);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    var item = {
                                                      'title': title.value,
                                                      'time': _timeController.text,
                                                      'steps': stepsContents.value,
                                                      'teachers': teachersActivityContents.value,
                                                      'learners': learnersActivityContents.value,
                                                      'methods': methodsContents.value,
                                                    };

                                                    lesson_development_items.value.add(item);
                                                    setState(() {
                                                      title.value = '';
                                                      _timeController.text = '';
                                                      stepsContents.value = [];
                                                      teachersActivityContents.value = [];
                                                      learnersActivityContents.value = [];
                                                      methodsContents.value = [];
                                                    });
                                                    Get.back();
                                                  },
                                                  child: Text('Add'),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            backgroundColor: Colors.white,
                          );
                        },
                        icon: Icon(Icons.add, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade100),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONCLUSION: ', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _conclusionController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Conclusion...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_conclusionController);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('FOLLOWUP EXERCISE/HOMEWORK: ', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _exerciseController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: 'Exercise / Homework...',
                            hintStyle: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        child: Icon(Icons.mic, color: Colors.blue),
                        onTap: () async {
                          _startListening(_exerciseController);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                  onPressed: () async {
                    // Validate required fields
                    /*if (
                        _topicController.text.isEmpty ||
                        _subtopicController.text.isEmpty ||
                        _prerequisiteKnowldgeController.text.isEmpty ||
                        objectives.isEmpty ||
                        _contentController.text.isEmpty ||
                        _valueController.text.isEmpty ||
                        _positionController.text.isEmpty ||
                        _strategyController.text.isEmpty ||
                        _teachlearnController.text.isEmpty ||
                        references.isEmpty ||
                        lesson_development_items.isEmpty ||
                        _conclusionController.text.isEmpty ||
                        _exerciseController.text.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Please fill all required fields",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }*/

                    setState(() {
                      isLoading = true;
                    });

                    try {
                      // Fetch pupils for the selected class
                      var classid = _myClassesController.myclasses
                          .firstWhere((cls) => cls.name == seletedTimetable.value.classname)
                          .uid;
                      var pupils = await DataPrefetch().fetchPupils(classid);

                      await _openCalendarPopup();

                      // Prepare data for saving
                      Map<String, dynamic> data = {
                        'subject': seletedTimetable.value.subject,
                        'grade': seletedTimetable.value.classname,
                        'topic': _topicController.text,
                        'subtopic': _subtopicController.text,
                        'time': seletedTimetable.value.starttime,
                        'duration': seletedTimetable.value.duration,
                        'exp_boys': '${pupils.where((pupil) => pupil.gender == 'm').length}',
                        'exp_girls': '${pupils.where((pupil) => pupil.gender == 'f').length}',
                        'act_boys': '', // You can update this later if needed
                        'act_girls': '', // You can update this later if needed
                        'date': '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}', // Add current date
                        'pre_requisite_knowledge': _prerequisiteKnowldgeController.text,
                        'objectives': objectives.value,
                        'rat_content': _contentController.text,
                        'rat_value': _valueController.text,
                        'rat_position': _positionController.text,
                        'rat_strategy': _strategyController.text,
                        'teaching_and_learning_resources': _teachlearnController.text,
                        'references': references.value,
                        'lesson_development': lesson_development_items.value,
                        'conclusion': _conclusionController.text,
                        'exercise': _exerciseController.text,
                        'evaluation': '', // You can update this later if needed
                        'teacher': _teacherController.teacher.value.first.uid,
                        'year': '${_selectedDate!.year}'
                      };

                      // Convert data to LessonPlan model
                      LessonPlan lessonPlan = LessonPlan.fromMap(data);

                      // Save the lesson plan
                      await CommonMethods().saveLessonPlan(data);

                      // Show success message
                      Fluttertoast.showToast(
                        msg: "Lesson plan saved successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );

                      // Clear form fields after saving
                      _topicController.clear();
                      _subtopicController.clear();
                      _prerequisiteKnowldgeController.clear();
                      _contentController.clear();
                      _valueController.clear();
                      _positionController.clear();
                      _strategyController.clear();
                      _teachlearnController.clear();
                      _referenceController.clear();
                      _stepsPointController.clear();
                      _stepsTitleController.clear();
                      _teacherActivityPointController.clear();
                      _learnersActivityPointController.clear();
                      _methodsActivityPointController.clear();
                      _timeController.clear();
                      _conclusionController.clear();
                      _exerciseController.clear();
                      objectives.clear();
                      stepsContents.clear();
                      learnersActivityContents.clear();
                      teachersActivityContents.clear();
                      methodsContents.clear();
                      lesson_development_items.clear();
                      references.clear();
                    } catch (e) {
                      // Handle errors
                      Fluttertoast.showToast(
                        msg: "Failed to save lesson plan: $e",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text('SAVE')
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}