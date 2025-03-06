import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/controllers/teacher_controller.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/helpers/data_prefetch.dart';
import 'package:smart_teacher/views/settings/subscription/success_payment.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../utils/colors.dart';

class WebViewer extends StatelessWidget {
  double amount;
  String plan;
  WebViewer({required this.amount, required this.plan});

  final WebViewController controller = WebViewController();


  @override
  Widget build(BuildContext context) {
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(Karas.background);
    //controller.loadRequest(Uri.parse('https://www.youtube.com/'));

    TeacherController _teacherController = Get.find();

    FirebaseFirestore _fs = FirebaseFirestore.instance;

    controller.loadRequest(Uri.parse('https://kalootech.com/pay?amount=${amount}&email=${_teacherController.teacher.value.first.email}&phone=${_teacherController.teacher.value.first.phone}'),);

    void updateProgress(int progress) {
      lprogress.value = progress.toDouble();
      progressV.value = progress.toDouble();
    }

    controller.addJavaScriptChannel('Response', onMessageReceived: (JavaScriptMessage message){
       
           switch(message.message){
             case '0':
               Fluttertoast.showToast(msg: 'Payment was not completed, window closed.');
               break;
             case '1':
                var data = {
                  'plan':'${plan}',
                  'amount':'${amount}',
                  'dateTime':'${DateTime.now()}',
                  'isActive':true,
                  'expiry_date':'${DateTime.now().add(Duration(days: CommonMethods().planDays(plan)))}',
                  'teacher':'${_teacherController.teacher.first.uid}'
                };
                FirebaseFirestore.instance.collection('current_subscription').where('teacher', isEqualTo: _teacherController.teacher.first.uid).
                get().then((g){
                  if(g.docs.isNotEmpty){
                    for(var doc in g.docs){
                      FirebaseFirestore.instance.collection('current_subscription').doc(doc.id).update({'isActive':false});
                    }
                  }
                  FirebaseFirestore.instance.collection('current_subscription').add(data).then((d){
                    DataPrefetch().fetchMySubscription(_teacherController.teacher.first.uid);
                  });

                });

                Get.offAll(()=>SuccessPayment(), transition: Transition.fade);
           }
    });

    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          updateProgress(progress);
        },
        onPageStarted: (String url) {
          // Page started
        },
        onPageFinished: (String url) {
          // Page finished
        },
        onHttpError: (HttpResponseError error) {
          // HTTP error
        },
        onWebResourceError: (WebResourceError error) {
          // Web resource error
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    final webViewKey = GlobalKey();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => progressV.value < 100 ?
              AnimatedBuilder(
                animation: lprogress,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    minHeight: 2,
                    value: lprogress.value / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      lprogress.value > 50 ? Colors.green : Karas.secondary,
                    ),
                  );
                },
              ): Container(),
            ),
            Expanded(
              child: WebViewWidget(
                key: webViewKey,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }


  final ValueNotifier<double> lprogress = ValueNotifier<double>(0.0);

  var progressV = 0.0.obs;
}
