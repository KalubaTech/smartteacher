import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils//colors.dart';

class Kalubtn extends StatelessWidget {

  String label;
  double? borderRadius;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;
  Function() onclick;
  double? height;
  double? width;
  double? elevation;
  TextStyle? labelStyle;
  Icon? icon;


  Kalubtn({
    required this.label,
    required this.onclick,
    this.icon,
    this.borderRadius,
    this.backgroundColor,
    this.width,
    this.height,
    this.elevation,
    this.padding,
    this.labelStyle
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onclick,
      borderRadius: BorderRadius.circular(borderRadius??8),
      child: Container(
        width: width??double.infinity,
        height: height??35,
        padding: padding??EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor??Karas.primary,
          borderRadius: BorderRadius.circular(borderRadius??8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: elevation??0,
              blurRadius: elevation??0
            )
          ]
        ),
        child: icon!=null?Center(child: icon,):Center(child: Text('${label}', style: labelStyle??TextStyle(color: Colors.white),)),
      ),
    );
  }
}
