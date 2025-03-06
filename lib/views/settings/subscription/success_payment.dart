import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/views/page_anchor.dart';
import 'package:get/get.dart';

class SuccessPayment extends StatelessWidget {
  SuccessPayment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 30
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green,size: 60,),
            SizedBox(height: 20,),
            Text('Your subscription was successful!', textAlign: TextAlign.center, style: GoogleFonts.gabarito(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            ElevatedButton(
                onPressed: (){
                    Get.offAll(()=>PageAnchor(), transition: Transition.fade);
                },
                child: Text('Go to Dashboard'))
          ],
        ),
      ),
    );
  }
}
