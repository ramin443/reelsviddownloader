import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../constants/colorconstants.dart';
import '../constants/fontconstants.dart';
import 'bottomnavigationcontroller.dart';

class DownloadController extends GetxController {
  bool hasvalidlink = false;
  final BottomNavigationController bottomNavigationController =
      Get.put(BottomNavigationController());

  sethasvalidlink() {
    hasvalidlink = true;
    update();

  }
  setnovalidlink() {
    hasvalidlink = false;
    update();
  }

  Widget topdownloadrow(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
//      top: 22
          top: screenwidth * 0.0462),
      padding: EdgeInsets.symmetric(
//      horizontal: 21
          horizontal: screenwidth * 0.05109),
      width: screenwidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            child: Text(
              "All Downloads",
              style: TextStyle(
                  fontFamily: proximanovabold,
                  color: blackthemedcolor,
                  //   fontSize: 19
                  fontSize: screenwidth * 0.0462),
            ),
          ),
          Container(
            child: Text(
              "0 files",
              style: TextStyle(
                  fontFamily: proximanovaregular,
                  color: blackthemedcolor,
                  //   fontSize: 14
                  fontSize: screenwidth * 0.0340),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptydownloads(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/nodownloads.svg",
              width: screenwidth * 0.669,
            ),
            Container(
              child: Text(
                "No downloads yet",
                style: TextStyle(
                    fontFamily: proximanovaregular,
                    color: blackthemedcolor,
                    fontSize: screenwidth * 0.05109),
              ),
            ),
            Container(
              child: Text(
                "Copy and paste link to see download options",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: proximanovaregular,
                    color: greythemedcolor,
                    //      fontSize: 12.5
                    fontSize: screenwidth * 0.03041),
              ),
            ),
            GestureDetector(
                onTap: () {
                  bottomNavigationController.setindex(0);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      //          top: 21
                      top: screenwidth * 0.05109),
                  padding: EdgeInsets.symmetric(
//           vertical: 6,horizontal: 14
                      vertical: screenwidth * 0.0145,
                      horizontal: screenwidth * 0.03406),
                  decoration: BoxDecoration(
                    color: royalbluethemedcolor,
                    borderRadius: BorderRadius.all(Radius.circular(31)),
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(
                        fontFamily: proximanovaregular,
                        color: Colors.white,
                        //        fontSize: 15.5
                        fontSize: screenwidth * 0.0377),
                  ),
                ))
          ]),
    );
  }
}
