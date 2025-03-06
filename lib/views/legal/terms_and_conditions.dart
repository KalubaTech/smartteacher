import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsPage extends StatelessWidget {
  
  WebViewController controller = WebViewController();
  @override
  Widget build(BuildContext context) {
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(Karas.background);
    controller.loadRequest(Uri.parse('https://kalootech.com/terms_conditions/smart_teacher.html'));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Terms and Conditions', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
} 