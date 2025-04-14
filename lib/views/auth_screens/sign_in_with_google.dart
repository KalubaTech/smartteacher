import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/auth_screens/sign_up_with_password.dart';
import 'package:smart_teacher/views/legal/terms_and_conditions.dart';
import 'package:smart_teacher/views/page_anchor.dart';

import '../../services/auth_service.dart';
import '../../services/local_auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  var _isLoading = false.obs;

  final LocalAuthService _localAuthService = LocalAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(''), backgroundColor: Colors.white,),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/smarteacherlogo.png', width: 100,),
                SizedBox(height: 20,),
                Text('SMART TEACHER', style: GoogleFonts.luckiestGuy(fontSize: 28, fontWeight: FontWeight.normal),)
              ],
            ),
            SizedBox(height: 40,),
            Divider(color: Colors.grey.shade100,),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20
              ),
              child: (GetStorage().hasData('user')) &&
                GetStorage().hasData('biometrics')&&
                GetStorage().read('biometrics')==true?Container(
              ):Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    /*                Kalutext(
                          controller:  _emailController,
                          hintText: 'Enter your email...',
                          labelText: 'Email:',

                        ),
                        SizedBox(height: 10,),
                        Kalutext(
                            controller:  _passwordController,
                          hintText: 'Enter your password...',
                          labelText: 'Password:',
                        ),
                        SizedBox(height: 20),
                        Kalubtn(
                            height: 45,
                            label: 'SIGN IN',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            onclick: ()async{
                              if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){
                                _isLoading.value = true;
                                Timer(Duration(seconds: 3), ()=>_isLoading.value = false);

                                var teacher = await AuthHelper().loginWithEmailAndPassword( _emailController.text, _passwordController.text);
                                if(teacher.uid == ''){
                                  Fluttertoast.showToast(msg: 'Failed to Register user');
                                }else{
                                  Get.offAll(()=>PageAnchor(), transition: Transition.fade);
                                }
                              }
                            }
                        ),
                        SizedBox(height: 20),
                        Text('OR', style: TextStyle(fontWeight: FontWeight.bold),),*/
                    SizedBox(height: 10,),
                    InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () async {
                        _isLoading.value = true;
                        Timer(Duration(seconds: 3),()=>_isLoading.value=false);
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
                              school: '',
                              isAdmin: false
                          );

                          AuthHelper().signUp(teacher: _teacher);
                        } else {
                          print('Sign-in failed or canceled');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google.png'),
                          SizedBox(width: 10,),
                          Text('Sign in with google', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    SizedBox(height: 40,),
                    Column(
                      children: [
                        Text('By signing in, you agree to the', style: TextStyle(fontSize: 12),),
                        TextButton(onPressed: (){
                          Get.to(()=>TermsAndConditionsPage(), transition: Transition.fade);
                        }, child: Text('Terms & conditions', style: TextStyle(color: Karas.primary),))
                      ],
                    )
                    /*      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('If you don\'t have an account, ', style: TextStyle(fontSize: 12),),
                            InkWell(
                                onTap: (){
                                    Get.to(()=>SignUpWithPassword(), transition: Transition.fade);
                                },
                                child: Text('REGISTER.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Karas.primary, decoration: TextDecoration.underline, decorationColor: Karas.primary, decorationThickness: 2,),)
                            )
                          ],
                        )*/
                  ],
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
              ()=> _isLoading.value ?
              Center(
                child: CircularProgressIndicator(
                  color: Karas.primary,
                ),
              ):Container()
            ),
          ],
        ),
      ),
    );
  }
}
