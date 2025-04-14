import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/models/class_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/classes/pupils.dart';
import 'package:smart_teacher/views/classes/subjects.dart';

import '../../helpers/data_prefetch.dart';
import 'package:get/get.dart';

class ViewClass extends StatelessWidget {
  ClassModel classModel;
  ViewClass({required this.classModel});

  var gender = 'm'.obs;
  var intake = '2025'.obs;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Karas.primary.withOpacity(0.1),
          title: Text(
            'Class: ${classModel.name}',
            style: GoogleFonts.gabarito(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.subject), text: 'My Subjects'),
              Tab(icon: Icon(Icons.group), text: 'Pupils'),
            ],
            labelColor: Karas.secondary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Karas.secondary,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
        body: TabBarView(
          children: [
            Subjects(classModel: classModel),
            Pupils(classModel: classModel)
          ],
        ),
      ),
    );
  }
}
