import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../downloadtests/downloadtester.dart';
import '../models/Downloaded_Video_Model.dart';
import 'clipboardcontroller.dart';

class DownloadFunctionsController extends GetxController{
  ReceivePort _port = ReceivePort();
  int? downloadno = 0;
  List<DownloadedVideo> tasklist = [];
  List<TaskInfo> taskss = [];
  bool? _permissionReady;
  String? _localPath;
  String downloadurl= "https://scontent-frt3-2.cdninstagram.com/v/t50.2886-16/306319420_144924584895309_6474685811091451597_n.mp4?_nc_ht=scontent-frt3-2.cdninstagram.com&_nc_cat=109&_nc_ohc=cV5zIkitoBwAX-IrApj&edm=APfKNqwBAAAA&ccb=7-5&oe=6320153E&oh=00_AT_0Y0CkYBjjszSkRKtaw-MG3soHZnLMzeYlY3KPkFIbXw&_nc_sid=74f7ba";
  void unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
  downloadcurrentvideo() {
    loadtasks();
    initializedownload(downloadurl!, "currentvideotitle"!);
  }

  initializedownload(String downloadlink, String tracktitle) {
    print("Download link here"
        +downloadlink
        +"\n");
    unbindBackgroundIsolate();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
//    _isLoading = true;
    _permissionReady = false;
    prepare(downloadlink, tracktitle);
    //  requestDownload(downloadlink);
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

  Future<void> _retryRequestPermission() async {
    final hasGranted = await _checkPermission();

    if (hasGranted) {
      await _prepareSaveDir();
    }
    _permissionReady = hasGranted;
    update();
  }
  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
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

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory(
    )
        : await getApplicationDocumentsDirectory(
    );
    return directory!.path;
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
  Future<Null> prepare(String downloadlink, String tracktitle) async {
    final tasks = await FlutterDownloader.loadTasks();
    _permissionReady = await _checkPermission();

    if (_permissionReady!) {
      await _prepareSaveDir();
      requestDownload(downloadlink, tracktitle);
    }
//    _isLoading = false;
    update();
  }
  void requestDownload(String downloadlink, String tracktitle) async {
    setdownloadno();
    final taskId = await FlutterDownloader.enqueue(
        url: downloadlink,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath!,
        fileName: "tracktitle",
        showNotification: true,
        openFileFromNotification: true);
   // updateListView();
    loadtasks();
  }
  setdownloadno() {
    downloadno = downloadno! + 1;
    update();
  }

}