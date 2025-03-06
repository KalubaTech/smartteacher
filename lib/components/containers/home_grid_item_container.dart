import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/utils/colors.dart';

class HomeGridItemContainer extends StatelessWidget {
  String icon;
  String label;
  Color backgroundColor;
  Function()? onclick;
  HomeGridItemContainer({required this.icon, required this.label, this.onclick, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onclick??(){},
      child: Card(
        color: Karas.primary.withOpacity(0.00),
        shadowColor: Colors.black,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: this.backgroundColor,
            padding: EdgeInsets.symmetric(
              vertical: 10
            ),
            child: Column(
              children: [
                Expanded(
                    child: Image.asset(icon, width: 90,)
                ),
                Text(label, style: GoogleFonts.passionOne(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
