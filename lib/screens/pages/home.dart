import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
import '../../getxcontrollers/bottomnavigationcontroller.dart';
import '../../getxcontrollers/clipboardcontroller.dart';
import '../../getxcontrollers/downloadcontroller.dart';
import '../downloadwidgets/error_box.dart';
import '../downloadwidgets/fetchingdownloadinfo.dart';
import '../sharablewidgets/downloadinstruction1.dart';
import '../sharablewidgets/rateus.dart';
class Home extends StatelessWidget {
  final ClipboardController clipboardController =
      Get.put(ClipboardController());
  final DownloadController downloadController = Get.put(DownloadController());

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return GetBuilder(
        initState: (v) {
          //      Services.getvideoinfo();
        },
        init: DownloadController(),
        builder: (downloadcontroller) {
          return GetBuilder<ClipboardController>(
              initState: (v) {},
              init: ClipboardController(),
              builder: (clipboardcontroller) {
                return GetBuilder(
                    initState: (v) {
                      clipboardController.updateListView();
                      clipboardcontroller.initializeparsestrings();
                      clipboardController.loadtasks();

                    },
                    init: BottomNavigationController(),
                    builder: (bottomnavigation) {
                      return SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            width: screenwidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      //          top: 29,bottom: 18
                                      top: screenwidth * 0.07055,
                                      bottom: screenwidth * 0.0437),
                                  padding: EdgeInsets.only(
                                      //        left: 15
                                      left: screenwidth * 0.0364963),
                                  //    height: 41,
                                  height: screenwidth * 0.09975,
                                  width: screenwidth * 0.906,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(11)),
                                      border: Border.all(
                                          color: Color(0xff707070)
                                              .withOpacity(0.2),
                                          width: 1),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.13),
                                            blurRadius: 10,
                                            offset: Offset(0, 3))
                                      ]),
                                  child: TextField(
                                    onChanged: (v) {
                                      clipboardController.checkyoutubestatus();
                                    },
                                    controller:
                                        clipboardController.linkfieldcontroller,
                                    cursorColor: Colors.black.withOpacity(0.7),
                                    style: TextStyle(
                                        color: Colors.black,
                                        //      fontSize: 15,
                                        fontSize: screenwidth * 0.0364963,
                                        fontFamily: proximanovaregular),
                                    decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            clipboardController
                                                .emptytextfield(context);
                                          },
                                          child: Icon(
                                            CupertinoIcons.xmark,
                                            color: Colors.black87,
                                            //      size: 17,
                                            size: screenwidth * 0.04136,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        hintText:
                                            "Paste Instagram Reels video link here",
                                        hintStyle: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.43),
                                            //   fontSize: 15,
                                            fontSize: screenwidth * 0.0364963,
                                            fontFamily: proximanovaregular)),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          clipboardController
                                              .emptyeverything(context);
                                          FlutterClipboard.paste()
                                              .then((value) {
                                            clipboardController
                                                .pastetoclipboard();
                                          });
                                        },
                                        child: Container(
                                            //  width: 119,
                                            width: screenwidth * 0.2895,
                                            padding: EdgeInsets.symmetric(
                                                //           vertical: 9),
                                                vertical: screenwidth * 0.0218),
                                            decoration: BoxDecoration(
                                                color: royalbluethemedcolor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(14)),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.13),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 10)
                                                ]),
                                            child: Center(
                                              child: Text("Paste Link",
                                                  style: TextStyle(
                                                      //        fontSize: 16,
                                                      fontSize:
                                                          screenwidth * 0.0389,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          proximanovaregular)),
                                            ))),
                                    GestureDetector(
                                        onTap: () {
                                          if(clipboardController.showdownload == 2 &&
                                              clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status!=
                                                  DownloadTaskStatus.running &&
                                              clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status!=
                                              DownloadTaskStatus.complete
                                         )
                                          {
                                            clipboardcontroller.downloadcurrentvideo();
                                          }
                                        },
                                        child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            //      width: 111,
                                            width: screenwidth * 0.2700,
                                            margin: EdgeInsets.only(
                                                //        left: 60
                                                left: screenwidth * 0.1459),
                                            padding: EdgeInsets.symmetric(
                                                //      vertical: 9
                                                vertical: screenwidth * 0.0218),
                                            decoration: BoxDecoration(
                                                color:
                                                clipboardcontroller.taskss.length==0?
                                                royalbluethemedcolor
                                                    .withOpacity(0.41):
                                                clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].name
                      ==clipboardcontroller.currentvideotitle &&
                                                clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status==
                                                    DownloadTaskStatus.complete?
                                                royalbluethemedcolor
                                                    .withOpacity(0.41):
                                                clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].name
                                                    ==clipboardcontroller.currentvideotitle &&
                                                clipboardcontroller.taskss[clipboardcontroller.taskss.length-1].status==
                                                        DownloadTaskStatus.running?
                                                    royalbluethemedcolor
                                                        .withOpacity(0.41):
                                                clipboardController
                                                            .showdownload ==
                                                        2
                                                    ? royalbluethemedcolor
                                                    : royalbluethemedcolor
                                                        .withOpacity(0.41),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(14)),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.13),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 10)
                                                ]),
                                            child: Center(
                                                child: Text(
                                              "Download",
                                              style: TextStyle(
                                                  //      fontSize: 16,
                                                  fontSize:
                                                      screenwidth * 0.0389,
                                                  color: Colors.white,
                                                  fontFamily:
                                                      proximanovaregular),
                                            )))),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      clipboardController.showdownload == 3?
                                          ErrorBox():
                                      clipboardController.showdownload == 1
                                          ? FetchingDownloadsInfo()
                                          : clipboardController.showdownload ==
                                                  2
                                              ? clipboardcontroller.homepagedownloadvideo(context)
                                              //     CurrentDownloadInfo(
                                              //         thumbnailimagelink: clipboardcontroller.currentvideothumbnaillink,
                                              //   videotitle: clipboardcontroller.currentvideotitle,
                                              //     channelimage: clipboardcontroller.currentyoutubechannelthumbnaillink,
                                              //       channeltitle: clipboardcontroller.currentytchanneltitle,
                                              //         channeldescription: clipboardcontroller.currentytchanneldescription,
                                              //           extracteddownloadlink: clipboardcontroller.extractedlink,
                                              //           )
                                              : nolinkpasted(context),
                                    ]),
                                DownloadInstructionOne(),
                                RateUs()
                              ],
                            ),
                          ));
                    });
              });
        });
  }

  emptycode() {}

  Widget nolinkpasted(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      //    margin: EdgeInsets.only(top: 25,bottom: 31),
      margin: EdgeInsets.only(
          top: screenwidth * 0.05720, bottom: screenwidth * 0.0709),
      width: screenwidth * 0.837,
      decoration: BoxDecoration(
        color: Color(0xffFAFAFA).withOpacity(0.52),
        borderRadius: BorderRadius.all(Radius.circular(11)),
        border: Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1),
      ),
      padding: EdgeInsets.all(
//          14
          screenwidth * 0.0340),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(
              "Copy link from a Instagram Reels Video\n& start downloading",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: proximanovaregular,
                  color: blackthemedcolor,
                  //    fontSize: 16
                  fontSize: screenwidth * 0.0366),
            ),
          ),
          Container(
            child: Image.asset(
              "assets/images/Saly-1@3x.png",
              width: screenwidth * 0.49427,
            ),
          ),
        ],
      ),
    );
  }

  Widget downloadbutton(
      BuildContext context, String downloadlink, String title) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        clipboardController.initializedownload(downloadlink, title);
      },
      child: Container(
        //      height: 30,
        //    height: screenWidth * 0.0729,
        //  width: screenWidth * 0.3849,
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 13.5),
        decoration: BoxDecoration(
            color: royalbluethemedcolor,
            borderRadius: BorderRadius.all(Radius.circular(7)),
            boxShadow: [
              BoxShadow(
                  color: Color(0xff0062FF).withOpacity(0.28),
                  blurRadius: 10,
                  offset: Offset(0, 3)),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.download,
              //      size: 20,
              size: screenWidth * 0.0466,
              color: Colors.white,
            ),
            Container(
              margin: EdgeInsets.only(left: 12),
              child: Text(
                "Download",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: proximanovaregular,
                    color: Colors.white,
                    //    fontSize: 14.5
                    fontSize: screenWidth * 0.0352),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget qualitybox(BuildContext context, String quality) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      //      height: 30,
      height: screenWidth * 0.0729,
      width: screenWidth * 0.3849,
      decoration: BoxDecoration(
          color: royalbluethemedcolor,
          borderRadius: BorderRadius.all(Radius.circular(7)),
          boxShadow: [
            BoxShadow(
                color: Color(0xff0062FF).withOpacity(0.28),
                blurRadius: 10,
                offset: Offset(0, 3)),
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            FeatherIcons.download,
            //      size: 20,
            size: screenWidth * 0.0466,
            color: Colors.white,
          ),
          Container(
            child: Text(
              quality,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: proximanovaregular,
                  color: Colors.white,
                  //    fontSize: 14.5
                  fontSize: screenWidth * 0.0352),
            ),
          ),
          Container(
            child: Text(
              "Download",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: proximanovaregular,
                  color: Colors.white,
                  //    fontSize: 14.5
                  fontSize: screenWidth * 0.0352),
            ),
          ),
        ],
      ),
    );
  }
}
