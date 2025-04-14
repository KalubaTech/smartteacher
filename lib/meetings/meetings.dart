import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/meetings/create_meeting.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';

import '../controllers/timetable_controller.dart';

class Meetings extends StatelessWidget {
  Meetings({super.key});

  TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Meeting Rooms', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
        backgroundColor: Karas.background,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Get.to(()=>CreateMeetingPage());
          },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('meetings').where('school', isEqualTo: _teacherController.teacher.first.school).snapshots(),
          builder: (context, snapshot) {
            return snapshot.hasData ?
             ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10
                ),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (c,i){
                    final doc = snapshot.data!.docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final scheduledDateTime = (data['scheduled_datetime'] as Timestamp).toDate();
                    final isUpcoming = scheduledDateTime.isAfter(DateTime.now());
                    final initiator = data['initiator'];

                    return Card(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 20
                                ),
                                  child: Text('Upcoming', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),)
                              ),
                              PopupMenuButton(
                                  position: PopupMenuPosition.under,
                                  itemBuilder: (c)=>[
                                    PopupMenuItem(
                                      onTap: (){
                                        FirebaseFirestore.instance.collection('meetings').doc(doc.id).delete();
                                      },
                                        enabled: initiator == _teacherController.teacher.first.uid,
                                        child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red,),
                                        SizedBox(width: 10,),
                                        Text('Delete'),
                                      ],
                                    ))
                                  ]
                              )
                            ],
                          ),
                          ListTile(
                            subtitle: Text(
                              DateFormat().format(scheduledDateTime),
                              style: GoogleFonts.gabarito(
                                color: Colors.grey[600],
                              ), 
                            ),
                            leading: Icon(Icons.meeting_room, color: Colors.grey,),
                            title: Text('${snapshot.data!.docs[i].get('subject').toString().toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold),),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12
                            ),
                            trailing: InkWell(
                                onTap: (){
                                  CommonMethods().joinMeeting(
                                      subject: snapshot.data!.docs[i].get('subject').toString(),
                                      room: '${snapshot.data!.docs[i].get('room')}',
                                      userDisplayName: '${_teacherController.teacher.first.firstname}',
                                      userAvatarURL: '${_teacherController.teacher.first.photo}'
                                  );
                                },
                                child: Icon(Icons.video_call, color: Colors.red,size: 40,)
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              )
            : Container();
          }
        )
      ),
    );
  }
}
