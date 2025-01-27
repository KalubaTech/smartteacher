import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/utils/colors.dart';

import '../../services/auth_service.dart';
import '../../services/local_auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  var _isLoading = false.obs;

  final LocalAuthService _localAuthService = LocalAuthService();

  void _authenticate() async {
    bool isAuthenticated = await _localAuthService.authenticateWithBiometrics("Authenticate to access this feature");
    if (isAuthenticated) {
      // Authentication successful
      AuthHelper().signInWithFingerPrint(GetStorage().read('user'));
    } else {
      // Authentication failed

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/smarteacherlogo.png', width: 90,),
                SizedBox(height: 20,),
                Text('SMART TEACHER', style: GoogleFonts.luckiestGuy(fontSize: 28, fontWeight: FontWeight.normal),)
              ],
            ),
            SizedBox(height: 80,),
            Container(
              width: 200,
              child: InkWell(
                onTap: () async {
                  _isLoading.value = true;
                  final user = await _authService.signInWithGoogle();
                  if (user != null) {
                    // print('Signed in as: ${user.displayName}');
                    TeacherModel _teacher = TeacherModel(
                      uid: user!.uid,
                      firstname: user!.displayName??'',
                      lastname: '',
                      email: user!.email??'',
                      phone: user!.phoneNumber??'',
                      password: '',
                      photo: '${user!.photoURL}',
                      school: ''
                    );

                    AuthHelper().signUp(teacher: _teacher);
                  } else {
                    print('Sign-in failed or canceled');
                  }
                },
                child: (GetStorage().hasData('user')) &&
                  GetStorage().hasData('biometrics')&&
                  GetStorage().read('biometrics')==true?Container(
                ):Container(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png'),
                      SizedBox(width: 10,),
                      Text('Sign in with google', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            FutureBuilder(
              future: LocalAuthService().isBiometricAvailable(),
              builder: (context, sn) {
                return sn.hasData?
                (
                    GetStorage().hasData('user') &&
                    sn.data!) &&
                    GetStorage().hasData('biometrics')&&
                    GetStorage().read('biometrics')==true?
                    IconButton(
                        onPressed: (){
                          _authenticate();
                        },
                        icon: Icon(Icons.fingerprint, size: 60,),
                    ):
                    Container():
                    Container();
              }
            ),
            Obx(
              ()=> _isLoading.value?CircularProgressIndicator(
                color: Karas.primary,

              ):Container()
            ),

          ],
        ),
      ),
    );
  }
}
