import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/utils/colors.dart';
import '../../controllers/my_school_controller.dart';
import 'package:get/get.dart';

import '../../models/parrent_model.dart';

class TeacherChatScreen extends StatefulWidget {
  final ParentModel parent;

  TeacherChatScreen({required this.parent});

  @override
  _TeacherChatScreenState createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  TextEditingController _messageController = TextEditingController();
  int _messageLineCount = 1;
  final ScrollController _scrollController = ScrollController();

  MySchoolController _mySchoolController = Get.find();
  TeacherController _teacherController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        foregroundColor: Colors.white,
        actions: [
          InkWell(
              onTap: (){
                CommonMethods().addVideoCall(
                    _teacherController.teacher.first.uid,
                    _teacherController.teacher.first.firstname,
                    _teacherController.teacher.first.photo,
                    widget.parent.uid,
                    widget.parent.fullname,
                    widget.parent.photo,
                    'parents'
                );
              },
              child: Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                  color: Karas.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Color(0x84D0E7EC)
                  )
              ),
              child: Icon(Icons.video_call, color: Colors.white,size: 30,)
          )
          )
        ],
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('${widget.parent.photo}'),
            ),
            SizedBox(width: 4),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  topLeft: Radius.circular(20))),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: [
                                    SizedBox(height: 50),
                                    Text('${widget.parent.fullname}',
                                        style: GoogleFonts.aboreto(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Text('Parent',
                                        style: GoogleFonts.gabarito(
                                            fontSize: 13, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                height: 90,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Children:'),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 30,
                                      child: FutureBuilder(
                                        future: FirebaseFirestore.instance
                                            .collection('parent-child')
                                            .where('parent',
                                            isEqualTo: widget.parent.uid)
                                            .get(),
                                        builder: (context, s) {
                                          return s.hasData
                                              ? ListView(
                                            shrinkWrap: true,
                                            scrollDirection:
                                            Axis.horizontal,
                                            children: [
                                              ...s.data!.docs.map((item) =>
                                                  FutureBuilder(
                                                    future: FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                        'pupils')
                                                        .doc(item.get(
                                                        'child'))
                                                        .get(),
                                                    builder:
                                                        (context, ss) {
                                                      return ss.hasData
                                                          ? Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                          8,
                                                          vertical:
                                                          4,
                                                        ),
                                                        margin: EdgeInsets
                                                            .only(
                                                            right:
                                                            10),
                                                        decoration:
                                                        BoxDecoration(
                                                          color: Karas
                                                              .primary,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                        ),
                                                        child: Center(
                                                            child: Text(
                                                                '${ss.data!.get('firstname')} ${ss.data!.get('lastname')}',
                                                                style: TextStyle(
                                                                    color: Colors.white))),
                                                      )
                                                          : Container();
                                                    },
                                                  ))
                                            ],
                                          )
                                              : Container();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          left: (Get.width / 2) - 64,
                          top: -60,
                          child: CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage:
                              NetworkImage('${widget.parent.photo}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.parent.fullname}',
                      style: GoogleFonts.gabarito(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    Text('Parent', style: GoogleFonts.gabarito(fontSize: 14, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Karas.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('parent', isEqualTo: widget.parent.uid)
                    .where('teacher',
                    isEqualTo: _teacherController.teacher.value.first.uid)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var messages = snapshot.data!.docs;
                  List<Widget> messageWidgets = [];
                  DateTime? currentDate;

                  for (var i = 0; i < messages.length; i++) {
               /*     var message = messages[i];
                    var messageDate =
                    (message['timestamp'] as Timestamp).toDate();
                    var messageDateFormatted = DateTime(
                        messageDate.year, messageDate.month, messageDate.day);*/

                    var message = messages[i];
                    var messageDate = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    var messageDateFormatted = DateTime(
                        messageDate.year,
                        messageDate.month,
                        messageDate.day
                    );

                    // Add date chip if it's a new day
                    if (currentDate == null ||
                        currentDate != messageDateFormatted) {
                      currentDate = messageDateFormatted;
                      messageWidgets.add(
                        DateChip(
                          date: messageDateFormatted,
                          color: Color(0x558AD3D5),
                        ),
                      );
                    }

                    bool isMe =
                        message['sender'] == _teacherController.teacher.value.first.uid;

                    messageWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: isMe
                            ? InkWell(
                          onLongPress: () {
                            Get.defaultDialog(
                              title: '${message['message']}',
                              titlePadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              titleStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              content: Container(
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit, size: 20),
                                      title: Text('Edit'),
                                      onTap: () {
                                        Get.back();
                                        TextEditingController
                                        _editController =
                                        TextEditingController();
                                        _editController.text =
                                        message['message'];
                                        Get.bottomSheet(
                                          Container(
                                            width: double.infinity,
                                            child: Column(
                                              children: [
                                                SizedBox(height: 20),
                                                Container(
                                                  width: 60,
                                                  height: 10,
                                                  decoration:
                                                  BoxDecoration(
                                                    color: Colors
                                                        .grey.shade400,
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(20),
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Expanded(
                                                  child: Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey
                                                            .shade400,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          20),
                                                    ),
                                                    margin:
                                                    EdgeInsets.all(10),
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                    child: TextField(
                                                      controller:
                                                      _editController,
                                                      keyboardType:
                                                      TextInputType
                                                          .text,
                                                      decoration:
                                                      InputDecoration(
                                                        border:
                                                        InputBorder
                                                            .none,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                              'chats')
                                                              .doc(message
                                                              .id)
                                                              .update({
                                                            'message':
                                                            _editController
                                                                .text
                                                                .trim()
                                                          });
                                                          Get.back();
                                                        },
                                                        child:
                                                        Text('Save'),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.delete,
                                          size: 20),
                                      title: Text('Delete'),
                                      onTap: () {
                                        Get.back();
                                        FirebaseFirestore.instance
                                            .collection('chats')
                                            .doc(message.id)
                                            .delete();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: BubbleSpecialOne(
                            text: message['message'],
                            color: Karas.primary,
                            isSender: true,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : BubbleSpecialThree(
                          text: message['message'],
                          color: Color(0xFF63838D),
                          tail: true,
                          isSender: false,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    children: messageWidgets,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 150.0,
                        ),
                        child: TextField(
                          controller: _messageController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Type a message',
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            final newLineCount =
                                '\n'.allMatches(text).length + 1;
                            if (newLineCount != _messageLineCount) {
                              setState(() {
                                _messageLineCount = newLineCount.clamp(1, 10);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.send, color: Karas.primary),
                      onPressed: () async {
                        if (_messageController.text.trim().isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('chats')
                              .add({
                            'parent': widget.parent.uid,
                            'school': _mySchoolController.myschool.value.uid,
                            'teacher': _teacherController.teacher.value.first.uid,
                            'sender': _teacherController.teacher.value.first.uid,
                            'receiver': widget.parent.uid,
                            'message': _messageController.text.trim(),
                            'timestamp': FieldValue.serverTimestamp(),
                            'read': false,
                          });

                          var daa = await FirebaseFirestore.instance.collection('parents').doc(widget.parent.uid).get();
                          var token = daa.get('token');

                          CommonMethods().sendFCM(token, 'New message: ${_messageController.text.trim()}', '${_messageController.text.trim()}');

                          _messageController.clear();
                          setState(() => _messageLineCount = 1);
                          _scrollToBottom();

                        }

                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}