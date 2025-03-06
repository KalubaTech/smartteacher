import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:smart_teacher/views/auth_screens/pro_register.dart';
import 'package:smart_teacher/views/auth_screens/sign_in_with_google.dart';

import '../../services/auth_service.dart';
import '../../services/local_auth_service.dart';

class SignUpWithPassword extends StatefulWidget {
  @override
  State<SignUpWithPassword> createState() => _SignUpWithPasswordState();
}

class _SignUpWithPasswordState extends State<SignUpWithPassword> {
  final AuthService _authService = AuthService();

  var _isLoading = false.obs;

  final LocalAuthService _localAuthService = LocalAuthService();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _nameController = TextEditingController();

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

  var emailExists = false.obs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.addListener(()async{
      var data = await FirebaseFirestore.instance.collection('teachers').where('email', isEqualTo: _emailController.text).get();

      if(data.docs.isNotEmpty){
        emailExists.value = true;
      }else{
        emailExists.value = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(''), backgroundColor: Colors.white,),
      body: Container(
        width: double.infinity,
        child: ListView(
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
                  GetStorage().hasData('biometrics') &&
                  GetStorage().read('biometrics')==true?
              Container():
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Kalutext(
                      controller:  _nameController,
                      hintText: 'Enter your name...',
                      labelText: 'Name:',

                    ),
                    SizedBox(height: 10,),
                    Obx(
                      ()=> Kalutext(
                        controller:  _emailController,
                        hintText: 'Enter your email...',
                        labelText: 'Email:',
                        errorText: emailExists.value?'Email already taken':'',
                      ),
                    ),
                    Kalutext(
                      controller:  _passwordController,
                      hintText: 'Enter your password...',
                      labelText: 'Password:',
                      isObscured: true,
                    ),
                    SizedBox(height: 20),
                    Kalubtn(
                        height: 45,
                        label: 'REGISTER',
                        backgroundColor: emailExists.value

                            ?Colors.grey.shade100:Karas.primary,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        onclick: ()async{
                         if(_nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){
                           _isLoading.value = true;
                           Timer(Duration(seconds: 3), ()=>_isLoading.value = false);

                           var teacher = await AuthHelper().registerWithEmailAndPassword(_nameController.text, _emailController.text, _passwordController.text);
                           if(teacher.uid == ''){
                             Fluttertoast.showToast(msg: 'Failed to Register user');
                           }else{
                             //AuthHelper().signUp(teacher: teacher);
                             Get.offAll(()=>ProRegister(), transition: Transition.fade);
                           }
                         }
                        }
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('If you already have an account, ', style: TextStyle(fontSize: 12),),
                        InkWell(
                            onTap: (){
                                Get.to(()=>LoginScreen(), transition: Transition.fade);
                            },
                            child: Text('LOGIN.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Karas.primary, decoration: TextDecoration.underline, decorationColor: Karas.primary, decorationThickness: 2,),)
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
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
