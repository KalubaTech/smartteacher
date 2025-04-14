import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/utils/colors.dart';

class AdminControlPanel extends StatelessWidget {
  const AdminControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Karas.background,
        title: Text('Admin Control Panel', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
      ),
      body: Container(),
    );
  }
}
