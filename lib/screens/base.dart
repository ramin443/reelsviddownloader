import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reelsdownloader/screens/pages/downloads.dart';
import 'package:reelsdownloader/screens/pages/home.dart';
import 'package:reelsdownloader/screens/pages/settings.dart' as Settings;

import '../getxcontrollers/bottomnavigationcontroller.dart';
import '../getxcontrollers/clipboardcontroller.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
import '../models/OwnerDetails.dart';
import 'offline/nointernetpage.dart';
class Base extends StatelessWidget {
  final BottomNavigationController bottomNavigationController =
      Get.put(BottomNavigationController());
  final ClipboardController clipboardController =
      Get.put(ClipboardController());
  final Connectivity connectivity = Connectivity();

  List pages = [Home(), Downloads(), Settings.Settings()];

  reflectdownloads() async {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('Downloads');
      var doc = await collectionRef.doc(DateFormat.yMMMMd('en_US').format(DateTime.now())).get();
      if(doc.exists){
        await FirebaseFirestore.instance.collection("Downloads").doc(
            DateFormat.yMMMMd('en_US').format(DateTime.now())
        ).update({"numberofdownloads":FieldValue.increment(1)});
      }else{
        await FirebaseFirestore.instance.collection("Downloads").doc(
            DateFormat.yMMMMd('en_US').format(DateTime.now())
        ).set({"numberofdownloads":1});
      }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GetBuilder(
        initState: (v) {
          clipboardController.addclipboardtextlistener();
        },
        init: BottomNavigationController(),
        builder: (bottomnavigation) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: false,
              actions: [

                //      IconButton(
                //       onPressed: ()async{
                //         clipboardController.showrateappdialog(context);
                //      getpostownerdetails("https://www.instagram.com/p/CRvk2HsA2hw/");
                //    getinstavideoinfo("https://www.instagram.com/p/CRvk2HsA2hw/");
                //  downloadReels("https://www.instagram.com/p/CRvk2HsA2hw/");
                //getreelsthumbnail("https://www.instagram.com/p/CRvk2HsA2hw/");
                //         FacebookPost postdata=await FacebookData.postFromUrl("https://www.facebook.com/5min.crafts/videos/698153117639878/");
                //       print("PostURL: "+postdata.postUrl.toString());
                //         await Firebase.initializeApp();
                //       await FirebaseFirestore.instance.collection("TestTransmisssion").add(
                //         {"data":"test succesful"});
                //   }, icon: Icon(CupertinoIcons.plus,color: Colors.black87,))
              ],
              leading: Container(
                  margin: EdgeInsets.only(
//                left: 8,top: 8
                    left: screenWidth * 0.01946, top: screenWidth * 0.01946,
                  ),
                  child: SvgPicture.asset(
                    "assets/images/Reels logo SVG.svg",
                    //   height: 42,width: 42,
                    height: screenWidth * 0.1021,
                    width: screenWidth * 0.1021,
                  )),
              title: Container(
                child: Text(
                  "Reels Video\nDownloader",
                  style: TextStyle(
                      fontFamily: proximanovaregular,
                      color: blackthemedcolor,
                      //        fontSize: 18
                      fontSize: screenWidth * 0.04379),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: bottomNavigationController.currentindex,
              selectedItemColor: royalbluethemedcolor,
              unselectedItemColor: greythemedcolor,
              backgroundColor: Color(0xfff5f5f5),
              onTap: (index) {
                bottomNavigationController.setindex(index);
              },
              selectedLabelStyle: TextStyle(
                  fontFamily: proximanovaregular,
                  fontSize: screenWidth * 0.03041
                //    fontSize: 12.5
              ),
              unselectedLabelStyle: TextStyle(
                  fontFamily: proximanovaregular,
                  fontSize: screenWidth * 0.03041
                //    fontSize: 12.5
              ),
              items: [
                BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.home,
                      //   size: 24,
                      size: screenWidth * 0.0583,
                    ),

                    label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.download,
                      //    size: 24,
                      size: screenWidth * 0.0583,
                    ),

                    label: "Downloads",
                ),
                BottomNavigationBarItem(
                    icon: Icon(
                      FeatherIcons.settings,
                      //   size: 24,
                      size: screenWidth * 0.0583,
                    ),
                    label: "Settings"),
              ],
            ),
            body: StreamBuilder(
                stream: connectivity.onConnectivityChanged,
                builder: (context, snaps) {
                  return snaps.data == ConnectivityResult.none
                      ? NoInternet()
                      : pages[bottomNavigationController.currentindex];
                }),
          );
        });
  }

  getreelsthumbnail(String link) async {
    var linkEdit = link.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1"));
    var data = json.decode(downloadURL.body);
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var videoUrl = shortcodeMedia['thumbnail_src'];
    print("Thumbnail" + videoUrl);
  }

  Future<String> downloadReels(String link) async {
    var linkEdit = link.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1"));
    var data = json.decode(downloadURL.body);
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var videoUrl = shortcodeMedia['video_url'];
    print(videoUrl);
    return videoUrl; // return download link
  }

  getpostownerdetails(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var postdata = shortcodeMedia['owner'];
    print("Showurl" + postdata.toString());
    ReelsOwner reelsOwner = ReelsOwner.fromJson(postdata);
    print("Reels Owner name" + reelsOwner.fullname.toString());
  }

  Future<int> getinstavideoinfo(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var edgemediatocaption = shortcodeMedia['edge_media_to_caption'];
    var edges = edgemediatocaption['edges'][0];
    var node = edges['node'];
    var caption = node['text'];
    print("Caption is:" + caption);
    return 0;
  }
}
