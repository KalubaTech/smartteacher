import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:smart_teacher/components/kalubtn.dart';
import 'package:smart_teacher/components/kalutext.dart';
import 'package:smart_teacher/helpers/auth_helper.dart';
import 'package:smart_teacher/models/teacher_model.dart';
import 'package:smart_teacher/utils/colors.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/views/auth_screens/sign_in.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  TextEditingController _firstController = TextEditingController();
  TextEditingController _lastController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  Future<bool>signUp()async{
    try{
      TeacherModel teacherModel = TeacherModel(
          uid: '',
          firstname: _firstController.text,
          lastname: _lastController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          photo: '',
          school: ''
      );

      AuthHelper().signUp(teacher: teacherModel);
      
      return true;
    }catch(e){
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
        backgroundColor: Colors.white,
        appBarColor: Karas.primary,

        bottomSheet: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 30),
          width: double.infinity,
          height: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Already have an account?', style: TextStyle(color: Colors.grey),),
              InkWell(
                onTap: (){
                  Get.to(()=>SignIn());
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              )
            ],
          ),
        ),
        title: Container(
          child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
        ),
        headerExpandedHeight: 0.25,
        headerWidget: Container(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Your', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),),
                Text('Account!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),)
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
                  controller: _firstController,
                  labelText: '  First Name',
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
                  controller: _lastController,
                  labelText: '  Last Name',
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
                controller: _phoneController,
                labelText: '  Phone Number',
                isNumber: true,
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
                SizedBox(height: 20,),
                Kalutext(
                  controller: _confirmPasswordController,
                  labelText: '  Confirm Password',
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
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20
                  ),
                  child: Kalubtn(
                    label: 'REGISTER',
                    onclick: ()async{
                      await signUp();
                    },
                    height: 45,
                    borderRadius: 40,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 80,)
        ]
    );
  }
}
