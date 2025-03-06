
import 'package:admob_easy/ads/admob_easy.dart';
import 'package:flutter/cupertino.dart';

import '../helpers/pdf_helper.dart';

class AdsService{
  void loadRewarded(BuildContext context){
    AdmobEasy.instance.createRewardedAd(context); // To load rewarded ad
    //AdmobEasy.instance.showRewardedAd(context);
  }

/*  showRewarded(context, pupils, classname, intake)async{
    await AdmobEasy.instance.showRewardedAd(
        context,
        onUserEarnedReward: (awv,rewardedItem){
          print(rewardedItem.amount);

          PdfHelper().generateClassListPdf(pupils.value, classname.value, intake.value, pupils.where((p)=>p.gender=='m').length, pupils.where((p)=>p.gender=='f').length);

        }
    );
  }*/
  void showRewarded(BuildContext context, void Function() printPdf) async {
    await AdmobEasy.instance.showRewardedAd(
      context,
      onUserEarnedReward: (awv, rewardedItem) {
        print(rewardedItem.amount);
        printPdf();  // Call the function passed as a parameter
      },
    );
  }

}