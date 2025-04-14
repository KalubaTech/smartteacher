import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyChildren extends StatelessWidget {
  MyChildren({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Children', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),),
      ),
      body: Container(),
    );
  }
}
