import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_youtube_downloader/flutter_youtube_downloader.dart';
import 'package:get/get.dart' as GetX;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:instagram_public_api/models/instaApi.dart';
import 'package:instagram_public_api/models/instaData.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:rate_my_app/rate_my_app.dart';
import 'package:reelsdownloader/getxcontrollers/youtubevideoinfocontroller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../config.dart';
import '../constants/colorconstants.dart';
import '../constants/fontconstants.dart';
import '../constants/stringconstants.dart';
import '../dbhelpers/DownloadedVidDBHelper.dart';
import '../downloadtests/downloadtester.dart';
import '../models/Downloaded_Video_Model.dart';
import '../models/OwnerDetails.dart';
import '../models/channelmodels.dart';
import '../models/video_model.dart';
import '../screens/sharablewidgets/deletevideo.dart';
import 'downloadcontroller.dart';

class ClipboardController extends GetX.GetxController {
  final InAppReview inAppReview = InAppReview.instance;
  int showdownload = 0;
  String clipboarddata = '';
  TextEditingController linkfieldcontroller = TextEditingController();
  final DownloadController downloadController =
      GetX.Get.put(DownloadController());
  YoutubeVideoInfoController youtubeVideoInfoController =
      GetX.Get.put(YoutubeVideoInfoController());
  String? extractedlink = '';
  String? currentvideotitle = '';
  String? currentvideothumbnaillink = '';
  String? currentyoutubechannelthumbnaillink = '';
  String? currentytchanneltitle = '';
  String? currentvideoid = '';
  String? currentytchanneldescription = '';
  static const _baseUrl = 'www.googleapis.com';
  String? _localPath;
  bool? _permissionReady;
  bool? _isLoading;
  ReceivePort _port = ReceivePort();
  int? downloadno = 0;
  List<DownloadedVideo> tasklist = [];
  List<String> downloadpressedlist = [];
  int count = 0;
  DownloadedVidDatabaseHelper downloadedVidDatabaseHelper =
      DownloadedVidDatabaseHelper();
  List<TaskInfo> taskss = [];
  final FirebaseAnalytics _analytics = FirebaseAnalytics();
  String currentparsestring = defaultparsestring;
  String finalparsestring = defaultparsestring;

  Future sendAnalyticsEvent({String? eventName, String? clickevent}) async {
    await _analytics.logEvent(
      name: '${eventName}',
      parameters: <String, dynamic>{'clickEvent': "User has clicked"},
    );
  }

  void savevidtogallery(String filepath) async {
    /* GallerySaver.saveVideo(filepath).then((value) => {
      print("saved")
    });*/
  }

  initializeparsestrings() async {
    final prefs = await SharedPreferences.getInstance();
    String parseval = "parsekey";
    String lastrefreshval = "Last refresh date";
    String loadtimeval = "loadtime";
    int loadtimes;
    String datetoday = DateFormat.yMMMd('en_US').format(DateTime.now());
    String fetchedkey = defaultparsestring;
    String lastrefreshdate;

    if (prefs.getInt(loadtimeval) == null) {
      prefs.setString(lastrefreshval, datetoday);
      try {
        fetchedkey = await FirebaseFirestore.instance
            .collection('ParseKey')
            .doc('parsedata')
            .get()
            .then((value) {
          return value.data()!['key']; // Access your after your get the data
        });
//        print("fetch key from firestore"+fetchedkey);
      } catch (err) {
        fetchedkey = defaultparsestring;
      }
      prefs.setString(parseval, fetchedkey);
      //    print("Fetched key is "+fetchedkey);
    } else {
      lastrefreshdate = prefs.getString(lastrefreshval)!;
      if (lastrefreshdate != datetoday) {
        try {
          fetchedkey = await FirebaseFirestore.instance
              .collection('ParseKey')
              .doc('parsedata')
              .get()
              .then((value) {
            return value.data()!['key']; // Access your after your get the data
          });
          print("fetch key from firestore" + fetchedkey);
        } catch (err) {
          fetchedkey = defaultparsestring;
        }
        prefs.setString(parseval, fetchedkey);
        lastrefreshdate = datetoday;
      }
    }
    if (prefs.getInt(loadtimeval) == null) {
      prefs.setInt(loadtimeval, 1);
    } else {
      loadtimes = prefs.getInt(loadtimeval)!;
      prefs.setInt(loadtimeval, loadtimes++);
    }
/*    fetchedkey=await FirebaseFirestore.instance
        .collection('ParseKey')
        .doc('parsedata')
        .get()
        .then((value) {
      return value.data()!['key'];});
    print("Fetchedkey is:"+fetchedkey);
    */
    setfinalparsestring(fetchedkey);
  }

  void setfinalparsestring(String finparse) async {
    finalparsestring = finparse;
    print(finalparsestring);
    update();
  }

  void initallprefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "Last refresh date", DateFormat.yMMMd('en_US').format(DateTime.now()));
  }

  setdownloadno() {
    downloadno = downloadno! + 1;
    update();
  }

  savevideotogallery(String path, String filename) async {
    String savePath = path + Platform.pathSeparator + filename + ".mp4";
    final result = await ImageGallerySaver.saveFile(savePath);
    print(result);
  }

  requestreview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  updateinstainfo(String? title, String? videoid, String? thumbnailink) {
    currentvideotitle = title;
    splitandgetvideoid(videoid!);
    currentvideothumbnaillink = thumbnailink;
    update();
  }

  updatechannelinfo(
      {String? title, String? description, String? thumbnailink}) {
    currentytchanneltitle = title;
    currentyoutubechannelthumbnaillink = thumbnailink;
    currentytchanneldescription = description;
    update();
  }

  checkyoutubestatus() {
    if (linkfieldcontroller.text.contains("insta")) {
      showdownload = 2;
      downloadController.sethasvalidlink();
      update();
    }
    if (!linkfieldcontroller.text.contains("insta")) {
      showdownload = 0;
      downloadController.setnovalidlink();
      update();
    }
  }

  getreelsvideodata(String link) async {
    getinstavideoinfo(link);
    downloadReels(link);
    getpostownerdetails(link);
    getreelsthumbnail(link);
    update();
  }

  addclipboardtextlistener() async {
    linkfieldcontroller.addListener(() async {
      if (linkfieldcontroller.text.contains("insta")) {
        showdownload = 1;
        downloadController.sethasvalidlink();
        print("firsttimestamp");
        getreelsvideodata(linkfieldcontroller.text);
        update();
      }

      if (1 > 0) {
        setclipboarddata();
      }
      if (linkfieldcontroller.text == "") {
        downloadController.setnovalidlink();
        update();
      }

      if (linkfieldcontroller.text != "") {}
    });
  }

  emptyeverything(BuildContext context) {
    extractedlink = "";
    showdownload = 0;
    clipboarddata = '';
    linkfieldcontroller.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    update();
  }

  void splitandgetvideoid(String videolink) async {
    try {
      var linkEdit = videolink.replaceAll(" ", "").split("/");
      var videoid = linkEdit[4];
      currentvideoid = videoid;
      update();
      print("Video id: ");
      print(videoid);
    } catch (err) {
      print("Linking error");
    }
  }

  Future<void> extractinstalink(String instalink) async {
    try {
      var linkEdit = instalink.replaceAll(" ", "").split("/");
      /*   var downloadURL = await http.get(Uri.parse(
          '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
              "/?__a=1&__d=dis"));*/
      var downloadURL = await http.get(
          Uri.parse("https://www.instagram.com/p/Ch656GRoyuO/?__a=1&__d=dis"));
      var data = json.decode('${downloadURL.body}');
      var graphql = data['graphql'];
      var shortcodeMedia = graphql['shortcode_media'];
      var videoUrl = shortcodeMedia['video_url'];
      extractedlink = videoUrl;
      print(extractedlink);
      update();
      //  return videoUrl;
    } on PlatformException {
      showdownload = 3;
      //  link = 'Failed to Extract YouTube Video Link.';
      print('failed to extract');
      update();
    }
  }

  Future<void> extractYoutubeLink(String youtubelink) async {
    String? link;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //    print("tried");
      link =
          await (FlutterYoutubeDownloader.extractYoutubeLink(youtubelink, 18));

      getvideoinfo(youtubelink.substring(youtubelink.length - 11));
      extractedlink = link;
      print(extractedlink);
      update();
    } on PlatformException {
      showdownload = 3;
      link = 'Failed to Extract Reels Video Link.';
      print('failed to extract');
    }
    update();
  }

  setclipboarddata() {
    FlutterClipboard.paste().then((value) {
      // Do what ever you want with the value.
      clipboarddata = value;
      update();
    });
  }

  pastetoclipboard() {
    FlutterClipboard.paste().then((value) {
      // Do what ever you want with the value.
      linkfieldcontroller.text = value;
      clipboarddata = value;
      if (value.contains("instagram")) {
        showdownload = 1;
      }
      update();
    });
    //  testigpostdetails();
  }

  emptytextfield(BuildContext context) {
    linkfieldcontroller.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    showdownload = 0;
    update();
  }

  Future<int> getinstavideocaption(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1&__d=dis"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var edgemediatocaption = shortcodeMedia['edge_media_to_caption'];
    var edges = edgemediatocaption['edges'][0];
    var node = edges['node'];
    var caption = node['text'];
    print(caption);
    return 0;
  }

  getinstavideothumbnail(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1&__d=dis"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    //   var videoUrl = shortcodeMedia['video_url'];
    // var postdata = shortcodeMedia['owner'];
    var thumbnaildata = shortcodeMedia['thumbnail_src'];
    print("thumbnailpic" + thumbnaildata.toString());
  }

  Future<int> getvideoinfo(String videoid) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'id': videoid,
      'key': Constants.API_KEY,
    };
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/videos',
      parameters,
    );
    Response response = await http.get(uri, headers: headers);
    //  print(response.body);
    Videos videos = Videos.fromJson(jsonDecode(response.body));
    if (videos.videos!.length == 0) {
      showdownload = 3;
    }
    if (videos.videos!.length != 0) {
      //     updatevideoinfo(videos.videos![0].video!.title,
      //       videos.videos![0].video!.thumbnails!.thumbnailsDefault!.url);
      getChannelInfo(videos.videos![0].video!.channelId);
    }

    update();
    //   print(videos.kind);
    // print(videos.videos![0].video!.thumbnails!.maxres!.url);
    //   getChannelInfo(videos.videos![0].video!.channelId);

    // return channelInfo;
    return 0;
  }

  Future<ChannelInfo> getChannelInfo(String? channelid) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'id': channelid!,
      'key': Constants.API_KEY,
    };
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Response response = await http.get(uri, headers: headers);
    // print(response.body);
    ChannelInfo channelInfo = ChannelInfo.fromJson(jsonDecode(response.body));
    updatechannelinfo(
        thumbnailink: channelInfo.items![0].snippet!.thumbnails!.high!.url,
        title: channelInfo.items![0].snippet!.title,
        description: channelInfo.items![0].snippet!.description);
    showdownload = 2;
    update();
    //  print("Channel thumbnal");
    //print(channelInfo.items![0].snippet!.thumbnails!.high!.url);
    return channelInfo;
  }

  emptyall() {
    taskss.clear();
    taskss = [];
    update();
  }

  loadtasks() async {
    taskss.clear();
    taskss = [];
    List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
    taskss.addAll(tasks!.map((document) => TaskInfo(
          taskId: document.taskId,
          status: document.status,
          progress: document.progress,
          name: document.filename,
          link: document.url,
          filepath: document.savedDir,
        )));
    update();
    //   for(int i=0;i<=taskss.length-1;i++){
    //   print("Download name:"+taskss[i].name.toString());
    // }
    //  tasks[0].savedDir
  }

  initializedownload(String downloadlink, String tracktitle, String curvidid) {
    print("Download link here" + downloadlink + "\n");
    unbindBackgroundIsolate();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    _isLoading = true;
    _permissionReady = false;
    prepare(downloadlink, tracktitle, curvidid);
    //  requestDownload(downloadlink);
  }

  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    if (downloadno == 0) {
      _port.listen((dynamic data) {
        if (debug) {
          print('UI Isolate Callback: $data');
        }
        String id = data[0];
        DownloadTaskStatus status = data[1];
        int progress = data[2];
        loadtasks();
        if (progress == 100) {
          loadtasks();
          update();
        }
        if (taskss.isNotEmpty) {
          final task = taskss!.firstWhere((task) => task.taskId == id);
          task.status = status;
          task.progress = progress;
          loadtasks();
          update();
        }
      });
    }
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();

    if (hasGranted) {
      await _prepareSaveDir();
    }
    _permissionReady = hasGranted;
    update();
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());

    final savedDir = Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<Null> prepare(
      String downloadlink, String tracktitle, String curvidid) async {
    final tasks = await FlutterDownloader.loadTasks();
    _permissionReady = await _checkPermission();

    if (_permissionReady!) {
      await _prepareSaveDir();
      requestDownload(downloadlink, tracktitle, curvidid);
    }
    _isLoading = false;
    update();
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void requestDownload(
      String downloadlink, String tracktitle, String curvidid) async {
    setdownloadno();
    print("Current videoid");
    print(curvidid);
    String filename = currentvideoid! + "mp4";
    String vid = "Cijaz0FOyn-";
    print(currentvideoid);
    final taskId = await FlutterDownloader.enqueue(
        url: downloadlink,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath!,
        fileName: "Newfilename",
        showNotification: true,
        openFileFromNotification: true);
    downloadpressedlist.add(currentvideoid!);
    _save(DownloadedVideo(
        currentvideotitle,
        currentvideothumbnaillink,
        currentyoutubechannelthumbnaillink,
        currentytchanneltitle,
        currentytchanneldescription,
        taskId,
        _localPath!));
    //   savevideotogallery(_localPath.toString(), tracktitle.substring(0, 17));
    // savevidtogallery(_localPath.toString());
    updateListView();
    loadtasks();
  }

  void _save(DownloadedVideo downloadedVideo) async {
    int result;
    if (downloadedVideo.id != null) {
      // Case 1: Update operation
      result =
          await downloadedVidDatabaseHelper.updateDownload(downloadedVideo);
    } else {
      // Case 2: Insert Operation
      result =
          await downloadedVidDatabaseHelper.insertDownload(downloadedVideo);
    }

    if (result != 0) {
      // Success
      print('Download saved succesfully');
    } else {
      // Failure
      print('Problem Saving Download');
    }
  }

  void deletefromdb(int id) async {
    int result = await downloadedVidDatabaseHelper.deleteDownload(id);
    if (result != 0) {
      print("Deleted succesfully");
    } else {
      print("Delete unsuccesful");
    }
  }

  void updateListView() {
    final Future<Database> dbFuture =
        downloadedVidDatabaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<DownloadedVideo>> noteListFuture =
          downloadedVidDatabaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        this.tasklist = noteList;
        this.count = noteList.length;
        update();
      });
    });
//    for(int i=0;i<=tasklist.length-1;i++){
    //    print("Video length"+tasklist.length.toString());
    //  print("Video image: "+tasklist[i].videothumbnailurl.toString());
    //   }
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
              tasklist.length.toString() + " files",
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

  Widget downloadedvideolist(
    BuildContext context,
  ) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenwidth * 0.0535),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tasklist.length,
          itemBuilder: (context, index) {
            return downloadedvidcard(
                context,
                DownloadedVideo(
                    this.tasklist[index].videotitle,
                    this.tasklist[index].videothumbnailurl,
                    this.tasklist[index].channelthumbnailurl,
                    this.tasklist[index].channeltitle,
                    this.tasklist[index].channeldescription,
                    this.tasklist[index].taskid,
                    this.tasklist[index].filepath),
                index);
          }),
    );
  }

  Widget downloadedvidcard(
      BuildContext context, DownloadedVideo? downloadedvideo, int? index) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
        top: screenWidth * 0.05720,
      ),
      decoration: BoxDecoration(
          color: Color(0xfff5f5f5),
          borderRadius: BorderRadius.all(Radius.circular(11)),
          border:
              Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1)),
      width: screenWidth * 0.915,
      padding: EdgeInsets.all(
          //      16
          screenWidth * 0.0389),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipOval(
                child: Container(
                  //       height: 67, width: 67,
                  height: screenWidth * 0.1630, width: screenWidth * 0.1630,
                  decoration: BoxDecoration(
                    color: royalbluethemedcolor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: downloadedvideo!.videothumbnailurl.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                height: screenWidth * 0.1630,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: screenWidth * 0.63,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  //          right: 5
                                  right: screenWidth * 0.01216),
                              width: screenWidth * 0.46,
                              child: Text(
                                downloadedvideo!.videotitle.toString(),
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily: proximanovaregular,
                                    color: blackthemedcolor,
                                    //    fontSize: 14.5
                                    fontSize: screenWidth * 0.03527),
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => SimpleDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                              ),
                                              children: [
                                                DeleteVideo(
                                                    index: this
                                                        .tasklist[index!]
                                                        .id,
                                                    taskid: taskss[
                                                            taskss.length -
                                                                1 -
                                                                index]
                                                        .taskId),
                                              ]));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
//                              vertical: 5,horizontal: 12
                                      vertical: screenWidth * 0.01216,
                                      horizontal: screenWidth * 0.02919),
                                  decoration: BoxDecoration(
                                      color: redthemedcolor,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color(0xffFF0000)
                                                .withOpacity(0.48),
                                            blurRadius: 10,
                                            offset: Offset(0, 3))
                                      ]),
                                  child: Center(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontFamily: proximanovaregular,
                                          color: Colors.white,
                                          //           fontSize: 12.5
                                          fontSize: screenWidth * 0.0304),
                                    ),
                                  ),
                                ))
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(
//     top:12
                top: screenWidth * 0.0391),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    //    height: 45,width: 45,
                    height: screenWidth * 0.1094, width: screenWidth * 0.1094,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: greythemedcolor,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: downloadedvideo.channelthumbnailurl.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        //       left: 12
                        left: screenWidth * 0.0291),
                    //    height: 45,
                    height: screenWidth * 0.1094,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            downloadedvideo!.channeltitle.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: proximanovabold,
                                color: blackthemedcolor,
                                //    fontSize: 14.5
                                fontSize: screenWidth * 0.0352),
                          ),
                        ),
                        Container(
                          child: Text(
                            downloadedvideo!.channeldescription.toString(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: proximanovaregular,
                                color: blackthemedcolor,
                                //    fontSize: 14.5
                                fontSize: screenWidth * 0.0352),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(
//      top: 16
                  top: screenWidth * 0.0389),
              child: taskss.length != 0
                  ? taskss[taskss.length - 1 - index!].status ==
                          DownloadTaskStatus.complete
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await FlutterDownloader.open(
                                    taskId: taskss[taskss.length - 1 - index!]
                                        .taskId
                                        .toString());
                              },
                              child: Container(
//width:108,height:27,
                                width: screenWidth * 0.262,
                                height: screenWidth * 0.0656,
                                decoration: BoxDecoration(
                                    color: royalbluethemedcolor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xff0062FF)
                                              .withOpacity(0.28),
                                          offset: Offset(0, 3),
                                          blurRadius: 10)
                                    ]),
                                child: Center(
                                  child: Text(
                                    "Open Video",
                                    style: TextStyle(
                                        fontFamily: proximanovaregular,
                                        color: Colors.white,
                                        //      fontSize: 13
                                        fontSize: screenWidth * 0.03163),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
//                      top: 12,bottom: 10
                                  top: screenWidth * 0.0291,
                                  bottom: screenWidth * 0.0243),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      taskss[taskss.length - 1 - index]
                                                  .status ==
                                              DownloadTaskStatus.canceled
                                          ? "Download cancelled"
                                          : taskss[taskss.length - 1 - index]
                                                      .progress! <
                                                  100
                                              ? "Downloading...   " +
                                                  taskss[taskss.length -
                                                          index -
                                                          1]
                                                      .progress
                                                      .toString() +
                                                  " %"
                                              : "Download Successful",
                                      style: TextStyle(
                                          fontFamily: proximanovaregular,
                                          color: Colors.black87,
                                          fontSize: screenWidth * 0.0316),
                                    ),
                                  ),
                                  taskss[taskss.length - 1 - index].status ==
                                          DownloadTaskStatus.canceled
                                      ? GestureDetector(
                                          onTap: () async {
                                            await FlutterDownloader.retry(
                                                taskId: taskss[
                                                        taskss.length.toInt() -
                                                            1]
                                                    .taskId!);
                                            loadtasks();
                                          },
                                          child: Icon(
                                            CupertinoIcons
                                                .refresh_circled_solid,
                                            color: Colors.redAccent
                                                .withOpacity(0.80),
                                            //      size: 24,
                                            size: screenWidth * 0.0583,
                                          ))
                                      : taskss[taskss.length - index - 1]
                                                  .progress! <
                                              100
                                          ? GestureDetector(
                                              onTap: () async {
                                                await FlutterDownloader.cancel(
                                                    taskId: taskss[
                                                            taskss.length -
                                                                1 -
                                                                index]
                                                        .taskId!);
                                              },
                                              child: Icon(
                                                CupertinoIcons
                                                    .xmark_circle_fill,
                                                color: Colors.redAccent
                                                    .withOpacity(0.80),
                                                //      size: 24,
                                                size: screenWidth * 0.0583,
                                              ))
                                          : Icon(
                                              CupertinoIcons
                                                  .checkmark_alt_circle_fill,
                                              color: Color(0xff00C6B0),
                                              //      size: 24,
                                              size: screenWidth * 0.0583,
                                            ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  //        bottom: 12.5
                                  bottom: screenWidth * 0.03041),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Color(0xff707070).withOpacity(0.24),
                                    color: taskss[taskss.length - 1 - index]
                                                .progress ==
                                            100
                                        ? Color(0xff00C6B0)
                                        : royalbluethemedcolor,
                                    value: taskss[taskss.length - 1 - index]
                                            .progress! /
                                        100,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                  : SizedBox(
                      height: 0,
                    ))
        ],
      ),
    );
  }

  showrateappdialog(BuildContext context) async {
    RateMyApp rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 2, // Show rate popup on first day of install.
      minLaunches:
          5, // Show rate popup after 5 launches of app after minDays is passed.
    );
    rateMyApp.showRateDialog(context);
  }

  Widget homepagedownloadvideo(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
          top: screenwidth * 0.05720, bottom: screenwidth * 0.0709),
      padding: EdgeInsets.all(
//    15
          screenwidth * 0.03649),
      width: screenwidth * 0.915,
      decoration: BoxDecoration(
          color: Color(0xfff5f5f5),
          borderRadius: BorderRadius.all(Radius.circular(11)),
          border:
              Border.all(color: Color(0xff707070).withOpacity(0.2), width: 1)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(11)),
                  child: Container(
                    //    height: 67,width: 67,
                    height: screenwidth * 0.1630,
                    width: screenwidth * 0.1630,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                        color: royalbluethemedcolor),
                    child: CachedNetworkImage(
                      imageUrl: currentvideothumbnaillink!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  margin: EdgeInsets.only(
                      //          left: 14
                      left: screenwidth * 0.034063),
                  //   height: 67,
                  height: screenwidth * 0.1630,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          currentvideotitle!,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          style: TextStyle(
                              fontFamily: proximanovaregular,
                              color: blackthemedcolor,
                              //    fontSize: 14.5
                              fontSize: screenwidth * 0.03527),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          //channelinfo
          Container(
            margin: EdgeInsets.only(
//     top:12
                top: screenwidth * 0.0391),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    //    height: 45,width: 45,
                    height: screenwidth * 0.1094,
                    width: screenwidth * 0.1094,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: greythemedcolor,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: currentyoutubechannelthumbnaillink!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        //       left: 12
                        left: screenwidth * 0.0291),
                    //    height: 45,
                    height: screenwidth * 0.1094,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            currentytchanneltitle!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: proximanovabold,
                                color: blackthemedcolor,
                                //    fontSize: 14.5
                                fontSize: screenwidth * 0.0352),
                          ),
                        ),
                        Container(
                          child: Text(
                            currentytchanneldescription!,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: proximanovaregular,
                                color: blackthemedcolor,
                                //    fontSize: 14.5
                                fontSize: screenwidth * 0.0352),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          //quality options
          currentvideotitle == null
              ? SizedBox(
                  height: 0,
                )
              : Container(
                  margin: EdgeInsets.only(top: 20),
                  child: downloadpressedlist.isNotEmpty &&
                          currentvideotitle != null &&
                          taskss.isNotEmpty &&
                          downloadpressedlist[downloadpressedlist.length - 1] ==
                              currentvideoid &&
                          taskss[taskss.length - 1].status ==
                              DownloadTaskStatus.running
                      ? Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  //                top: 12,bottom: 10
                                  top: screenwidth * 0.0291,
                                  bottom: screenwidth * 0.0243),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      taskss[taskss.length - 1].status ==
                                              DownloadTaskStatus.canceled
                                          ? "Download cancelled"
                                          : taskss[taskss.length - 1]
                                                      .progress! <
                                                  100
                                              ? "Downloading..  " +
                                                  taskss[taskss.length - 1]
                                                      .progress!
                                                      .toString() +
                                                  " %"
                                              : "Download Successful",
                                      style: TextStyle(
                                          fontFamily: proximanovaregular,
                                          color: Colors.black87,
                                          //             fontSize: 13
                                          fontSize: screenwidth * 0.0316),
                                    ),
                                  ),
                                  taskss[taskss.length - 1].status ==
                                          DownloadTaskStatus.canceled
                                      ? GestureDetector(
                                          onTap: () async {
                                            await FlutterDownloader.retry(
                                                taskId: taskss[
                                                        taskss.length.toInt() -
                                                            1]
                                                    .taskId!);
                                            loadtasks();
                                          },
                                          child: Icon(
                                            CupertinoIcons
                                                .refresh_circled_solid,
                                            color: Colors.redAccent
                                                .withOpacity(0.80),
                                            //      size: 24,
                                            size: screenwidth * 0.0583,
                                          ))
                                      : taskss[taskss.length - 1].progress! <
                                              100
                                          ? GestureDetector(
                                              onTap: () async {
                                                await FlutterDownloader.cancel(
                                                    taskId: taskss[taskss.length
                                                                .toInt() -
                                                            1]
                                                        .taskId!);
                                              },
                                              child: Icon(
                                                CupertinoIcons
                                                    .xmark_circle_fill,
                                                color: Colors.redAccent
                                                    .withOpacity(0.80),
                                                //      size: 24,
                                                size: screenwidth * 0.0583,
                                              ))
                                          : Icon(
                                              CupertinoIcons
                                                  .checkmark_alt_circle_fill,
                                              color: Color(0xff00C6B0),
                                              //        size: 24,
                                              size: screenwidth * 0.0583,
                                            ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  //        bottom: 12.5
                                  bottom: screenwidth * 0.03041),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                child: Container(
                                  width: screenwidth,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        Color(0xff707070).withOpacity(0.24),
                                    color: taskss[taskss.length - 1].progress ==
                                            100
                                        ? Color(0xff00C6B0)
                                        : royalbluethemedcolor,
                                    value: taskss[taskss.length - 1].progress! /
                                        100,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : downloadpressedlist.isNotEmpty &&
                              taskss.isNotEmpty &&
                              downloadpressedlist[
                                      downloadpressedlist.length - 1] ==
                                  currentvideoid &&
                              taskss[taskss.length - 1].status ==
                                  DownloadTaskStatus.complete
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await FlutterDownloader.open(
                                        taskId: taskss[taskss.length - 1]
                                            .taskId
                                            .toString());
                                  },
                                  child: Container(
//width:108,height:27,
                                    width: screenwidth * 0.262,
                                    height: screenwidth * 0.0656,
                                    decoration: BoxDecoration(
                                        color: royalbluethemedcolor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0xff0062FF)
                                                  .withOpacity(0.28),
                                              offset: Offset(0, 3),
                                              blurRadius: 10)
                                        ]),
                                    child: Center(
                                      child: Text(
                                        "Open Video",
                                        style: TextStyle(
                                            fontFamily: proximanovaregular,
                                            color: Colors.white,
                                            //      fontSize: 13
                                            fontSize: screenwidth * 0.03163),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                downloadbutton(
                                    context, extractedlink!, currentvideotitle!)
                                //         qualitybox(context, '360p'),
                                //       qualitybox(context, '720p')
                              ],
                            ))
        ],
      ),
    );
  }

  downloadcurrentvideo() {
    loadtasks();
    initializedownload(extractedlink!, currentvideotitle!, currentvideoid!);
  }

  reflectdownloads() async {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('Downloads');
    var doc = await collectionRef
        .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
        .get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Downloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .update({"numberofdownloads": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Downloads")
          .doc(DateFormat.yMMMMd('en_US').format(DateTime.now()))
          .set({"numberofdownloads": 1});
    }
  }

  Widget downloadbutton(
      BuildContext context, String downloadlink, String title) {
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        reflectdownloads();
        initializedownload(downloadlink, title, currentvideoid!);
        loadtasks();
      },
      child: Container(
        //      height: 30,
        //    height: screenWidth * 0.0729,
        //  width: screenWidth * 0.3849,
        padding: EdgeInsets.symmetric(
//            vertical: 6, horizontal: 13.5
            vertical: screenWidth * 0.0145,
            horizontal: screenWidth * 0.0328),
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
              margin: EdgeInsets.only(
                  //        left: 12
                  left: screenWidth * 0.0291),
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

  downloadReels(String link) async {
    try {
      var linkEdit = link.replaceAll(" ", "").split("/");
      var downloadURL = await http.get(Uri.parse(
          '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
              "/?__a=1&__d=dis"));
      var data = json.decode(downloadURL.body);
      var graphql = data['graphql'];
      var shortcodeMedia = graphql['shortcode_media'];
      var videoUrl = shortcodeMedia['video_url'];
      extractedlink = videoUrl;
      showdownload = 2;
      update();
      print(videoUrl);
      //   return videoUrl;
      //    print("tried");

    } on PlatformException {
      showdownload = 3;

      link = 'Failed to Extract Instagram Video Link.';
      print('failed to extract');
    }
    update();
// return download link
  }

  getpostownerdetails(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1&__d=dis"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var postdata = shortcodeMedia['owner'];
    print("Showurl" + postdata.toString());
    ReelsOwner reelsOwner = ReelsOwner.fromJson(postdata);
    print("Reels Owner name" + reelsOwner.fullname.toString());
    currentyoutubechannelthumbnaillink = reelsOwner.profilepicurl.toString();
    currentytchanneltitle = reelsOwner.username.toString();
    currentytchanneldescription = reelsOwner.fullname.toString();
    showdownload = 2;
    update();
  }

  getreelsthumbnail(String link) async {
    var linkEdit = link.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1&__d=dis"));
    var data = json.decode(downloadURL.body);
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var thumbnailUrl = shortcodeMedia['thumbnail_src'];
    //   print("Thumbnail"+thumbnailUrl);
    currentvideothumbnaillink = thumbnailUrl;
    showdownload = 2;
    update();
  }

  Future<int> getinstavideoinfo(String instalink) async {
    var linkEdit = instalink.replaceAll(" ", "").split("/");
    var downloadURL = await http.get(Uri.parse(
        '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
            "/?__a=1&__d=dis"));
    var data = json.decode('${downloadURL.body}');
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var edgemediatocaption = shortcodeMedia['edge_media_to_caption'];
    var edges = edgemediatocaption['edges'][0];
    var node = edges['node'];
    var caption = node['text'];
    currentvideotitle = caption;
    splitandgetvideoid(instalink);
    showdownload = 2;
    update();
    return 0;
  }

  void testservice() async {
    await FirebaseFirestore.instance
        .collection("test")
        .add({"test": "succesful"});
  }

  void testigpostdetails() async {
    final List<InstaPost> post = await FlutterInsta().getPostData(
        "https://www.instagram.com/reel/Chj0NvjJV2B/?igshid=YmMyMTA2M2Y=");
    for (int i = 0; i < post.length; i++) {
      print(post[i].dimensions);
      print(post[i].displayURL); //post download url
      print(post[i].postType);
      print(post[i].thumbnailDimensions);
      print(post[i].thumbnailUrl);
      print(post[i].user.followers);
      print(post[i].user.isPrivate);
      print(post[i].user.isVerified);
      print(post[i].user.posts);
      print(post[i].user.profilePicURL);
      print(post[i].user.username);
      print(post[i].videoDuration);
    }
  }

  Future<void> extractinstatest(String instalink) async {
    try {
      var linkEdit = instalink.replaceAll(" ", "").split("/");
      var downloadURL = await http.get(Uri.parse(
          "https://www.instagram.com/reel/Cijaz0FOyn-/?__a=1&__d=dis"));
      var data = json.decode('${downloadURL.body}');
      var graphql = data['items'];
      //     var shortcodeMedia = graphql['taken_at'];
      //   var videoUrl = shortcodeMedia['text'];
      extractedlink = graphql;
      print("Caption extracted:\n");
      print(graphql);
      update();
      //  return videoUrl;
    } on PlatformException {
      showdownload = 3;
      //  link = 'Failed to Extract YouTube Video Link.';
      print('failed to extract');
      update();
    }
  }
}

class TaskInfo {
  late final String? name;
  late final String? link;
  late final String? filepath;
  late String? taskId;
  late int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  TaskInfo(
      {this.name,
      this.link,
      this.filepath,
      this.taskId,
      this.progress,
      this.status});
}

class _ItemHolder {
  final String? name;
  final TaskInfo? task;

  _ItemHolder({this.name, this.task});
}
