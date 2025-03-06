import 'package:get/get.dart';
import 'package:smart_teacher/models/my_subscription.dart';

class MySubscriptionController extends GetxController{
  var my_subscription = <MySubscription>[].obs;

  MySubscription? getCurrentSub(){
    MySubscription? activeSub;
    if(my_subscription.value.isNotEmpty){
      activeSub = my_subscription.value.where((s)=>s.isActive).firstOrNull;
    }

    return activeSub;
  }
}