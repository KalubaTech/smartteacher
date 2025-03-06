import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/views/timetable/add_timetable.dart';
import '../../utils/colors.dart';
import 'package:flutter_timetable/flutter_timetable.dart' as ttable;

class Timetable extends StatefulWidget {
  const Timetable({super.key});

  @override
  State<Timetable> createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  final controller = TimetableController(
    start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7)),
    initialColumns: 3,
    cellHeight: 100.0,
    startHour: 0,
    endHour: 23,
  );

  TeacherController _teacherController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.jumpTo(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Timetable',
          style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: () {
          Get.to(() => AddTimetable(), transition: Transition.fade);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('timetable')
            .where('teacher', isEqualTo: _teacherController.teacher.first.uid)
            .snapshots(),
        builder: (c, s) {
          if (s.hasData && s.data!.docs.isNotEmpty) {
            // Parse Firestore data into Timetable items
            final timetableItems = s.data!.docs.expand<TimetableItem<String>>((doc) {
              final data = doc.data();
              final startTime = DateFormat("HH:mm").parse(data['starttime']);
              final stopTime = DateFormat("HH:mm").parse(data['stoptime']);
              final day = data['day'];

              // Calculate the correct start date for the week based on the day provided
              final today = DateUtils.dateOnly(DateTime.now());
              final dayOffset = _dayToOffset(day);
              final startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Start of the week (Monday)
              final eventDate = startOfWeek.add(Duration(days: dayOffset)); // Exact day of the event

              // Generate recurring events for the next 7 weeks (adjust as needed)
              return List.generate(7, (weekOffset) {
                final startDateTime = eventDate.add(
                  Duration(
                    days: weekOffset * 7, // Add weeks to the event date
                    hours: startTime.hour,
                    minutes: startTime.minute,
                  ),
                );
                final endDateTime = eventDate.add(
                  Duration(
                    days: weekOffset * 7, // Add weeks to the event date
                    hours: stopTime.hour,
                    minutes: stopTime.minute,
                  ),
                );

                return TimetableItem(
                  startDateTime,
                  endDateTime,
                  data: '${doc.id},${data['class']} - ${data['subject']}',
                );
              });
            }).toList();

            return Container(
              child: ttable.Timetable<String>(
                controller: controller,
                items: timetableItems,
                cellBuilder: (datetime) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 0.2),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat("MM/d/yyyy\nha").format(datetime),
                      style: TextStyle(
                        color: Color(0xff000000 + (0x002222 * datetime.hour) + (0x110000 * datetime.day)).withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                cornerBuilder: (datetime) => Container(
                  color: Colors.accents[datetime.day % Colors.accents.length],
                  child: Center(child: Text("${datetime.year}")),
                ),
                headerCellBuilder: (datetime) {
                  final color = Colors.primaries[datetime.day % Colors.accents.length];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: color, width: 2)),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat("E\nMMM d").format(datetime),
                        style: TextStyle(
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                hourLabelBuilder: (time) {
                  final hour = time.hour == 12 ? 12 : time.hour % 12;
                  final period = time.hour < 12 ? "am" : "pm";
                  final isCurrentHour = time.hour == DateTime.now().hour;
                  return Text(
                    "$hour$period",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
                itemBuilder: (item) => InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onLongPress: () {
                    Get.defaultDialog(
                      title: 'Action',
                      content: Container(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore
                                    .instance.collection('timetable')
                                    .doc(item.data!.split(',').first)
                                    .delete();
                                Get.back();
                              },
                              child: Text('Delete'),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${item.data!.split(',').last}' ?? "",
                            style: GoogleFonts.gabarito(fontSize: 14),
                          ),
                          Text(
                            '${item.duration.inHours} Hour period\n${item.start.hour < 10 ? '0${item.start.hour}' : item.start.hour}:${item.start.minute < 10 ? '0${item.start.minute}' : item.start.minute} - ${item.end.hour < 10 ? '0${item.end.hour}' : item.end.hour}:${item.end.minute < 10 ? '0${item.end.minute}' : item.end.minute}' ?? "",
                            style: GoogleFonts.gabarito(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                nowIndicatorColor: Colors.red,
                snapToDay: true,
              ),
            );
          } else {
            return Center(
              child: Image.asset('assets/empty-folder.png'),
            );
          }
        },
      ),
    );
  }

  /// Helper function to convert day strings to offsets
  int _dayToOffset(String day) {
    const dayOffsets = {
      'Monday': 0,
      'Tuesday': 1,
      'Wednesday': 2,
      'Thursday': 3,
      'Friday': 4,
      'Saturday': 5,
      'Sunday': 6,
    };
    return dayOffsets[day] ?? 0;
  }
}