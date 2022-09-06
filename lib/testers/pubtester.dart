import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_youtube_downloader/flutter_youtube_downloader.dart';

class MyDownloadTest extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyDownloadTest> {
  String? _extractedLink = 'Loading...';
  String customlink='https://www.youtube.com/watch?v=HBKVfN056bk';
  String? youTube_link = "https://www.youtube.com/watch?v=HBKVfN056bk";

  @override
  void initState() {
    super.initState();
    extractYoutubeLink();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> extractYoutubeLink() async {
    String? link;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      link = await (FlutterYoutubeDownloader.extractYoutubeLink(
          youTube_link!, 18));
    } on PlatformException {
      link = 'Failed to Extract YouTube Video Link.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _extractedLink = link;
      print(_extractedLink);
    });
  }

  Future<void> downloadVideo() async {
    final result = await FlutterYoutubeDownloader.downloadVideo(
        youTube_link!, "Video Title goes Here", 18);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Youtube Link Downloader example app'),
        ),
        body: Center(
          child: Text('Extracted Link : $_extractedLink\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: downloadVideo,
          child: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }
}