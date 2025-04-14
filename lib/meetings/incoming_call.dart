import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ripple_animation/ripple_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/common_methods.dart';

class IncomingCall extends StatelessWidget {
  var snapshot;
  IncomingCall({this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/call_background.jpg'),
              fit: BoxFit.cover
          ),
        ),
        child: Column(
          children: [
            Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Incoming Call...', style: TextStyle(color: Colors.white),),
                      Text('${snapshot.data!.docs.first.get('callerName')}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
                      SizedBox(height: 40,),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('video_call').where('status', isEqualTo: 'talking').snapshots(),
                          builder: (context, snaps) {
                            if(snaps.hasData && snaps.data!.docs.isNotEmpty){

                            }
                            return RipplesAnimation(
                                size: 60,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundImage: NetworkImage('${snapshot.data!.docs.first.get('callerPhoto')}'),
                                )
                            );
                          }
                      )
                    ],
                  ),
                )
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Image.asset('assets/decline-call.png'),
                    onTap: (){
                      CommonMethods().endCall(snapshot.data!.docs.first.id);
                    },
                  ),
                  SizedBox(width: 40,),
                  InkWell(
                      onTap: (){

                        CommonMethods().joinMeeting(
                            room: '${snapshot.data!.docs.first.get('callerId')}_${snapshot.data!.docs.first.get('calleeId')}',
                            userDisplayName: '${snapshot.data!.docs.first.get('calleeName')}',
                            userAvatarURL: '${snapshot.data!.docs.first.get('calleePhoto')}',
                            audioMuted: false
                        );
                        CommonMethods().answerCall(snapshot.data!.docs.first.id);
                      },
                      child: Image.asset('assets/answer-phone.png')
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
