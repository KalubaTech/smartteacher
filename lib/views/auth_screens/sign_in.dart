import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:smart_teacher/views/auth_screens/sign_up.dart';
import 'package:get/get.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        height: 60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Don\'t have an account?', style: TextStyle(color: Colors.grey),),
            InkWell(
              onTap: (){
                Get.to(()=>SignUp());
              },
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      ),
        title: Container(
          child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        ),
        headerExpandedHeight: 0.25,
        headerWidget: Container(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),),
                Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),)
              ],
            ),
          ),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/teacher.jpg'),
                  fit: BoxFit.cover
              ),
              color: Karas.primary.withOpacity(0.4)
          ),
        ),
        body: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 40,),
                Kalutext(
                  controller: _emailController,
                  labelText: '  Email',
                  labelTextStyle: TextStyle(
                    color: Karas.primary
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                      color: Karas.primary
                  ),
                ),
                SizedBox(height: 20,),
                Kalutext(
                  controller: _passwordController,
                  labelText: '  Password',
                  showEye: true,
                  isObscured: true,
                  labelTextStyle: TextStyle(
                      color: Karas.primary
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Karas.primary
                  ),
                ),
                SizedBox(height: 30,),
                TextButton(
                    onPressed: (){

                    },
                    child: Text('Forgot Password?', style: TextStyle(color: Karas.primary),)
                ),
                SizedBox(height: 30,),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20
                  ),
                  child: Kalubtn(
                    label: 'SIGN IN',
                    onclick: ()async{
                      bool isTrue = await AuthHelper().signIn(_emailController.text, _passwordController.text);
                      if(isTrue){
                        //go to dashboard
                      }else{
                        //display an error message
                      }
                    },
                    height: 45,
                    borderRadius: 40,
                  ),
                )
              ],
            ),
          )

        ]
    );
  }
}
