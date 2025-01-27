import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_teacher/components/containers/home_grid_item_container.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/services/auth_service.dart';
import 'package:smart_teacher/services/local_auth_service.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/classes/classes.dart';
import 'package:smart_teacher/views/documents/documents.dart';
import 'package:smart_teacher/views/ebooks/ebooks.dart';
import 'package:smart_teacher/views/timetable/timetable.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  TeacherController _teacherController = Get.find();

  void allowBiometrics()async{
    bool hasBiometrics = await LocalAuthService().isBiometricAvailable();
    var isBioSwitchedOn = false.obs;
    //GetStorage().remove('biometrics');

    if((!GetStorage().hasData('biometrics'))){
      if(hasBiometrics&&(GetStorage().read('biometrics')==false||GetStorage().read('biometrics')==null)){
        Get.defaultDialog(
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Text('Allow unlocking with Fingerprint next time you log in.'),
                  SizedBox(height: 20,),
                  Obx(
                    ()=> Switch(
                      value: isBioSwitchedOn.value,
                      onChanged: (value){
                        GetStorage().write('biometrics', value);
                        isBioSwitchedOn.value = value!;
                      },
                      activeColor: Karas.primary,
                    ),
                  )
                ],
              ),
            ),
            title: 'Biometrics',
            radius: 10
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    allowBiometrics();
    return DraggableHome(
        backgroundColor: Colors.white,
        appBarColor: Karas.primary.withOpacity(0.8),
        title: Container(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedNetworkImage(
                  width: 30,
                  height: 30,
                  imageUrl: '${_teacherController.teacher.first.photo}',
                  errorWidget: (e,x,r)=>CircleAvatar(
                      child: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_teacherController.teacher.first.firstname}', style: GoogleFonts.passionOne(fontSize: 19, color: Karas.background),)
                    ],
                  )
              )
            ],
          ),
        ),
        headerWidget: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageUrl: '${_teacherController.teacher.first.photo}',
                        errorWidget: (e,x,r)=>CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teacher'),
                      Text('${_teacherController.teacher.first.firstname}', style: GoogleFonts.passionOne(
                        fontSize: 24
                      ),)
                    ],
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: ()async{
                        await AuthService().signOut();
                      },
                      icon: Icon(Icons.logout)
                  )
                ],
              ),
            ],
          ),
        ),
        headerExpandedHeight: 0.14,
        body: [
          GridView(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                HomeGridItemContainer(
                    icon: 'assets/class.png',
                    label: 'My Classes',
                    backgroundColor: Karas.primary.withOpacity(0.3),
                    onclick:(){
                      Get.to(()=>Classes(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/ebook.png',
                    label: 'eBooks',
                    backgroundColor: Karas.info.withOpacity(0.3),
                    onclick:(){
                      Get.to(()=>Ebooks(), transition: Transition.fade);
                    }
                ), 
                HomeGridItemContainer(
                    icon: 'assets/schedule.png',
                    label: 'My Timetable',
                    backgroundColor: Karas.danger.withOpacity(0.3),
                    onclick:(){
                      Get.to(()=>Timetable(), transition: Transition.fade);
                    }
                ),
                HomeGridItemContainer(
                    icon: 'assets/stamp.png',
                    label: 'Document File',
                    backgroundColor: Karas.secondary.withOpacity(0.3),
                    onclick:(){
                      Get.to(()=>Documents(), transition: Transition.fade);
                    }
                ),
              ],
          )
        ]
    );
  }
}
