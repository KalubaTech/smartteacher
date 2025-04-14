import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/views/legal/privacy_policy.dart';
import 'package:smart_teacher/views/legal/terms_and_conditions.dart';
import 'package:url_launcher_android/url_launcher_android.dart';
import 'package:get/get.dart';
import '../../components/kalubtn.dart';
import '../../utils/colors.dart';


class AboutUs extends StatelessWidget {
  AboutUs({super.key});

  // Replace 'PHONE_NUMBER' with the target number in international format without '+' or '00'.
  final String phoneNumber = "260973232553";
  TeacherController _teacherController = Get.find();

  var launcher = UrlLauncherAndroid();


  Future<void> openWhatsApp() async {
    final String message = "Hello! smart teacher ${_teacherController.teacher.first.firstname} here!";
    final  whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";


    if (await launcher.canLaunch(whatsappUrl)) {
      //await launcher.launchUrl(whatsappUrl);
    } else {
      throw "Could not launch WhatsApp";
    }
  }

  final String recipient = "helpdesk@kalootech.com";
  final String subject = "Smart Teacher Client - query";

/*  Future<void> sendEmail() async {
    final String recipient = "helpdesk@kalootech.com";
    final String subject = "Smart Teacher Client - query";
    final String message = "Hello! smart teacher ${_teacherController.teacher.first.firstname} here!";

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': subject,
        'body': message,
      },
    );

    try {
      await launcher.launchUrl(emailUri);
    } catch (e) {
      print("Error launching email: $e");
    }
  }*/
  Future<void> makePhoneCall(String phoneNumber) async {
    final callUri = 'tel:$phoneNumber';

    try {
      ///await launcher.launchUrl(callUri, );
    } catch (e) {
      print("Error making phone call: $e");
    }
  }
  Future<void> launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);

  /*  if (await canLaunchUrl(uri)) {
      await launchInBrowser(url);
    } else {
      throw 'Could not launch $url';
    }*/
  }

  Future<void> openFacebookProfile(String profileId) async {
    final Uri fbAppUri = Uri.parse("fb://profile/$profileId"); // For the Facebook app
    final Uri fbWebUri = Uri.parse("https://www.facebook.com/$profileId"); // For web browser

    try {
/*      if (await launchUrl(fbAppUri)) {
        await launchUrl(fbAppUri);
      } else {
        await launchUrl(fbWebUri); // Open in a browser if the app is not installed
      }*/
    } catch (e) {
      print("Error opening Facebook: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      headerExpandedHeight: 0.22,
        alwaysShowTitle: true,
        alwaysShowLeadingAndAction: true,
        title: Container(
          child: Text('About Us'),
        ),
        headerWidget: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40,),
                Text('Informations', style: GoogleFonts.gabarito(fontSize: 28, fontWeight: FontWeight.bold),)
            ],
          ),
        ),
        body: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/kalootech_logo.png', width: 40,),
                    SizedBox(
                      width: 30,
                    ),
                    Text('KALOO TECHNOLOGIES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ],
                ),
                SizedBox(height: 20,),
                Divider(),
                SizedBox(height: 40,),
                Text('Contact us', style: TextStyle(fontSize: 22),),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: (){
                        makePhoneCall('260973232553');
                      },
                        child: Icon(Ionicons.call, size: 40,color: Colors.green,)
                    ),
                    SizedBox(width: 30,),
                    InkWell(
                      onTap: (){
                        openFacebookProfile('chakanga.kaluba');
                      },
                        child: Icon(Ionicons.logo_facebook, size: 40,color: Colors.blueAccent,)
                    ),
                    SizedBox(width: 30,),
                    InkWell(
                      onTap: (){
                        //sendEmail();
                      },
                        child: Icon(Ionicons.mail, size: 40,color: Colors.deepOrange,)
                    ),
                    SizedBox(width: 30,),
                    InkWell(
                      onTap: (){
                        openWhatsApp();
                      },
                        child: Icon(Ionicons.logo_whatsapp, size: 40,color: Colors.green,)
                    ),

                  ],
                ),
                SizedBox(height: 20,),
                ListTile(
                  onTap: (){

                  },
                  leading: Icon(Icons.phone),
                  title: Text('0973 232 553'),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('helpdesk@kalootech.com'),
                ),
              ],
            ),
          ),
          Divider(),
          SizedBox(height: 20,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 20,),
                    Text('SMART TEACHER', style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: Kalubtn(
                          label: 'Privacy Policy',
                          onclick: (){
                            Get.to(()=>PrivacyPolicy(), transition: Transition.fade);
                            ///launchInBrowser('https://kalootech.com/privacy_policy.php');
                          },
                        backgroundColor: Karas.danger,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Expanded(
                      child: Kalubtn(
                          label: 'Terms & Conditions',
                          labelStyle: TextStyle(),
                          onclick: (){
                            //launchInBrowser('https://kalootech.com/terms_conditions.php');
                            Get.to(()=>TermsAndConditionsPage(), transition: Transition.fade);
                          }
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]
    );
  }
}
