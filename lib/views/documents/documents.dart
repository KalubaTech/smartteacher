import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class Documents extends StatelessWidget {
  const Documents({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:  FloatingActionButton(
        backgroundColor: Karas.danger,
        onPressed: () {

        },
        child: Icon(Icons.add, color: Colors.white,),
        //params
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/empty-folder.png'),
      ),
    );
  }
}
