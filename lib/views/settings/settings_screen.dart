import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/services/alarm_service.dart';
import 'package:smart_teacher/views/settings/about_us.dart';
import 'package:smart_teacher/views/settings/subscription/subscription.dart';

import '../../controllers/teacher_controller.dart';
import '../../services/local_auth_service.dart';
import '../../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var isBioSwitchedOn = false.obs;

  Future<bool> allowBiometrics()async{
    bool hasBiometrics = await LocalAuthService().isBiometricAvailable();

    //GetStorage().remove('biometrics');

    if((!GetStorage().hasData('biometrics'))){
      if(hasBiometrics&&(GetStorage().read('biometrics')==false||GetStorage().read('biometrics')==null)){
        return false;
      }
      return false;
    }else{
      return true;
    }
  }

  TeacherController _teacherController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.gabarito(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Fingerprint'),
              subtitle: Text('Allow to sign in with fingerprint', style: TextStyle(fontSize: 10, color: Colors.grey),),
              trailing:
                FutureBuilder(
                  future: allowBiometrics(),
                  builder: (context, s) {
                    if (s.hasData) {
                      
                      return Switch(
                        value: isBioSwitchedOn.value,
                        onChanged: (value){
                          isBioSwitchedOn.value = value;
                          if(value){
                            GetStorage().write('biometrics', value);
                          }
                          setState(() {

                          });
                        },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                    } else {
                      return Container(width: 20, height: 20,);
                    }
                  }
                ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade100,
            ),
            ListTile(
              onTap: (){
                Get.to(()=>Subscription(), transition: Transition.fade);
              },
              leading: Icon(Icons.subscriptions),
              title: Text('Subscription'),
              subtitle: Text('Make payment now or change subscription plan', style: TextStyle(fontSize: 10, color: Colors.grey),),
              trailing: Icon(Icons.chevron_right),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade100,
            ),
            ListTile(
              onTap: (){
                //Get.to(()=>Subscription(), transition: Transition.fade);
                Get.to(()=>AboutUs(), transition: Transition.fade);
              },
              leading: Icon(Icons.question_mark_rounded),
              title: Text('About'),
              trailing: Icon(Icons.chevron_right),
            ),
            Divider(color: Colors.grey.shade200,),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                 style: ButtonStyle(
                   backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200)
                 ),
                  onPressed: (){
                    //AlarmService().setAlarm('Time for Class', TimeOfDay(hour: 10, minute: 09));
                    Get.bottomSheet(
                        Container(
                          child: Column(
                            children: [
                              Container(
                                height: 8,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                              ),
                              SizedBox(height: 10,),
                              Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20)
                                      )
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 20,),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Text('WARNING!', style: GoogleFonts.gabarito(fontSize: 28, fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 10,),
                                        Divider(color: Colors.grey.shade200,),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10
                                          ),
                                          child: Text('This action is irreversible. Ensure you back up any important data before deleting your account.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),),
                                        ),
                                        Divider(color: Colors.grey.shade100,),
                                        SizedBox(height: 20,),
                                        Container(
                                          child: Row(
                                            children: [
                                              SizedBox(width: 20,),
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: ()async{
                                                      Get.defaultDialog(
                                                        title: 'Please wait...!',
                                                        content: Container(
                                                          child: Column(
                                                            children: [
                                                              SizedBox(height: 40,),
                                                              CircularProgressIndicator(),
                                                              SizedBox(height: 20,),
                                                              Text('Deleting your account...', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),)
                                                            ],
                                                          ),
                                                        ),
                                                        barrierDismissible: false
                                                      );
                                                      await CommonMethods().deleteUser(_teacherController.teacher.first.uid);
                                                    }, child: Text('CONFIRM')
                                                ),
                                              ),
                                              SizedBox(width: 20,),
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: (){
                                                      Get.back();
                                                    }, child: Text('CANCEL')
                                                ),
                                              ),
                                              SizedBox(width: 20,),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              )
                            ],
                          ),
                        )
                    );
                  },
                  child: Text('Delete Account?', style: TextStyle(color: Colors.red),)
              ),
            )
         /*   ElevatedButton(
                onPressed: (){
                  AlarmService().setAlarm('Time for Class', TimeOfDay(hour: 10, minute: 09));
                },
                child: Text('Set alarm'))*/
          ], 
        ),
      ),
    );
  }
}
