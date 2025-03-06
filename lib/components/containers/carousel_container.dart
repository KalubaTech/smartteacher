import 'package:flutter/material.dart';
import 'package:smart_teacher/utils/colors.dart';

class CarouselContainer extends StatelessWidget {
  String backImage;
  Widget child;
  CarouselContainer({required this.backImage, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 1,
                spreadRadius: 1
              )
            ]
        ),
        child: Stack(
          children: [
            Positioned(
                left: 10,
                top: 10,
                child: Image.asset(backImage, width: 60,)),
            child
          ],
        )
    );
  }
}
