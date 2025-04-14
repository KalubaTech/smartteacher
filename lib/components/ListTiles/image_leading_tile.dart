import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageLeadingTile extends StatelessWidget {
  String title;
  String?subtitle;
  String? iconPath;
  Function()?ontap;
  Function()?onlongpress;
  Widget?trailing;
  bool? active;
  ImageLeadingTile({required this.title, this.subtitle, this.iconPath, this.ontap, this.active, this.onlongpress, this.trailing});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onlongpress??(){},
      onTap: ontap??(){},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: BorderDirectional(bottom: BorderSide(color: Colors.grey.shade100))
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconPath!=null?
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(iconPath!),
                ),
                SizedBox(width: 14,),
              ],
            ):Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$title', style: GoogleFonts.gabarito(fontSize: 18, color: active!=null&&active==false?Colors.grey:Colors.black),),
                  subtitle!=null?Text('${subtitle!}', overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 12),)
                      :Container()
                ],
              ),
            ),
            trailing??Container()
          ],
        ),
      ),
    );
  }
}
