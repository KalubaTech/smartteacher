import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radial_progress/radial_progress.dart';
import 'package:smart_teacher/controllers/my_subscription_controller.dart';
import 'package:smart_teacher/controllers/subscription_plans_controller.dart';
import 'package:get/get.dart';
import 'package:smart_teacher/helpers/common_methods.dart';
import 'package:smart_teacher/models/my_subscription.dart';
import 'package:smart_teacher/models/subscription_model.dart';
import 'package:smart_teacher/utils/colors.dart';

import 'lenco_webview.dart';

class Subscription extends StatelessWidget {
  Subscription({super.key});

  SubscriptionPlansController _subscriptionPlansController = Get.find();

  @override
  Widget build(BuildContext context) {
    List<SubscriptionModel>subscriptionPlans = _subscriptionPlansController.sub_plans;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Subscription', style: GoogleFonts.gabarito(fontSize: 24, fontWeight: FontWeight.bold),),
      ),
      body: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: [
              GetBuilder<MySubscriptionController>(
              builder: (mysubscriptionController) {
                MySubscription? activeSub = mysubscriptionController.getCurrentSub();

                return activeSub!=null?
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, // 135deg corresponds to top-left to bottom-right
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xC27EDAA4), // #4f8c6a at 0%
                          Color(0xFF65D3A9), // #65d3a9 at 64%
                          Color(0xFF65D3A9), // #65d3a9 at 64%
                          Color(0xFF1AE8CF), // #27d1bd at 66%
                          Color(0xFF6BC67A), // #6bc67a at 100%
                        ],
                        stops: [0.0, 0.64, 0.64, 0.66, 1.0], // Corresponding stops for the colors
                      )
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20
                  ),
                  child: Column(
                    children: [
                      Text('Your Current Package', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('${activeSub.plan.capitalize}',style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 12),),
                                SizedBox(height: 10,),
                                Text('ZMW ${activeSub.amount}',style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 18),),
                                Text('Exp. ${activeSub.expiry_date.toString().split('.').first}',style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 12),),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Container(
                                child: RadialProgressWidget(
                                  percent: ((CommonMethods().calculateRamainingDays(DateTime.now(), activeSub.expiry_date))/CommonMethods().planDays(activeSub.plan)),
                                  diameter: 80,
                                  bgLineColor: Colors.grey.withOpacity(0.2),
                                  progressLineWidth: 10,
                                  startAngle: StartAngle.top,
                                  progressLineColors: const [
                                    Colors.red,
                                    Color(0xffe64306),
                                    Color(0xffdf8207),
                                    Color(0xff9cc004),
                                    Colors.green,
                                  ],
                                  centerChild: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${CommonMethods().calculateRamainingDays(DateTime.now(), activeSub.expiry_date)}',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('days', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.7)),)
                                    ],
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ],
                  ),
                ):Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        // 135deg corresponds to top-left to bottom-right
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xC27EDAA4), // #4f8c6a at 0%
                          Color(0xFF65D3A9), // #65d3a9 at 64%
                          Color(0xFF65D3A9), // #65d3a9 at 64%
                          Color(0xFF1AE8CF), // #27d1bd at 66%
                          Color(0xFF6BC67A), // #6bc67a at 100%
                        ],
                        stops: [
                          0.0,
                          0.64,
                          0.64,
                          0.66,
                          1.0
                        ], // Corresponding stops for the colors
                      ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text('You need an active subscription to generate documents without showing Ads', textAlign: TextAlign.center, style: GoogleFonts.gabarito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),),
                );
              }
            ),
            Container(
                child: Text('Renew your subscription', style: GoogleFonts.gabarito(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.black),),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            ),

            ...subscriptionPlans.map((plan){
              return Card(
                color: Colors.grey.shade100,
                child: InkWell(
                  onTap: ()=>Get.to(()=>WebViewer(amount: double.parse(plan.amount), plan: '${plan.plan}',), transition: Transition.fade),
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          child: Center(
                            child: GetBuilder<MySubscriptionController>(
                              builder: (mysubcontroller) {
                                return Icon(Icons.check_circle, color: mysubcontroller.my_subscription.value.contains(plan) ? Karas.primary : Colors.grey.shade400,);
                              }
                            ),
                          ),
                        ),
                        Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${plan.plan.capitalize}'),
                                  Text('ZMW ${plan.amount.capitalize}', style: GoogleFonts.gabarito(fontWeight: FontWeight.bold, fontSize: 20),),
                                  Text('${plan.description.capitalize}'),
                                ],
                              ),
                            )
                        ),
                        Icon(Icons.arrow_forward_ios),
                        SizedBox(width: 10,)
                      ],
                    ),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
