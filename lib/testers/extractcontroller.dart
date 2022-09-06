import 'package:facebook_video_download/data/facebookData.dart';
import 'package:facebook_video_download/data/facebookPost.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';

import 'package:http/http.dart';

class ExtractTest extends GetxController{
  String? extractedlink = '';
  int showdownload = 0;

  parsefb()async{
    print("Response here");
    FacebookPost data = await FacebookData.postFromUrl(
        "https://fb.watch/dFdBnOjWtH/");
    print("HDURL"+data.videoHdUrl.toString());
    print(data.videoMp3Url);
    print(data.videoSdUrl);

  }

  downloadReels(String link) async {
    try {
      var linkEdit = link.replaceAll(" ", "").split("/");
      print('${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' + "/?__a=1");
      var downloadURL = await http.get(Uri.parse('${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' + "/?__a=1"));
      var data = json.decode(downloadURL.body);
      var graphql = data['graphql'];
      var shortcodeMedia = graphql['shortcode_media'];
      var videoUrl = shortcodeMedia['video_url'];
      extractedlink=videoUrl;
      showdownload=2;
      update();
      print(extractedlink);
      //   return videoUrl;
      //    print("tried");


    } on PlatformException {
      showdownload=3;

      link = 'Failed to Extract Instagram Video Link.';
      print('failed to extract');
    }
    update();
// return download link
  }
  void fbparsetest(String profileUrl)async{
    String _temporaryData = '', _patternStart = '', _patternEnd = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    http.Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document;
    _response = await _client.get(Uri.parse('$profileUrl'));
    _document = parse(_response.body);
    _document = _document.querySelectorAll('body');
    _temporaryData = _document[0].text;
    print("temporary data:\n");
    print(_temporaryData);
    _temporaryData = _temporaryData.trim();
    _patternStart = 'permalinkURL:"';
    _patternEnd = '/"}],1],';
    _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
    _endInx = _temporaryData.indexOf(_patternEnd) + 1;
    _postData['postUrl'] =
    _temporaryData.substring(_startInx, _endInx) != "null"
        ? _temporaryData.substring(_startInx, _endInx)
        : _postData['postUrl']!;

    _patternStart = ',sd_src:';
    _patternEnd = '",hd_tag:';
    _startInx =
        _temporaryData.indexOf(_patternStart) + _patternStart.length + 1;
    _endInx = _temporaryData.indexOf(_patternEnd);
    _postData['videoSdUrl'] =
    _temporaryData.substring(_startInx, _endInx) != "null"
        ? _temporaryData.substring(_startInx, _endInx)
        : _postData['videoSdUrl']!;

    _patternStart = ',hd_src:"';
    _patternEnd = '",sd_src:';
    _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
    _endInx = _temporaryData.indexOf(_patternEnd);
    _postData['videoHdUrl'] =
    _temporaryData.substring(_startInx, _endInx) != 'null'
        ? _temporaryData.substring(_startInx, _endInx)
        : _postData['videoSdUrl']!;

  }
}