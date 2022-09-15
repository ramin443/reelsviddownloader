
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:isolate';
import 'dart:ui'; // You need to import these 2 libraries besides another libraries to work with this code

final ReceivePort _port = ReceivePort();


class TestDownloadPage extends StatefulWidget {
  const TestDownloadPage({Key? key}) : super(key: key);

  @override
  _TestDownloadPageState createState() => _TestDownloadPageState();
}


class _TestDownloadPageState extends State<TestDownloadPage> {
  String downloadurl= 'https://download.samplelib.com/mp4/sample-5s.mp4';
  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }


  void _download(String url) async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [IconButton(onPressed: ()async{
          final status = await Permission.storage.request();

          if(status.isGranted) {
            final externalDir = await getExternalStorageDirectory();

            final id = await FlutterDownloader.enqueue(
              url: downloadurl,
              savedDir: externalDir!.path,
              showNotification: true,
              openFileFromNotification: true,
            );
          } else {
            print('Permission Denied');
          }        }, icon: Icon(CupertinoIcons.add_circled_solid,
        color: Colors.black,
          size: 24,
        ))],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

          ],
        ),
      ),
    );
  }
}
