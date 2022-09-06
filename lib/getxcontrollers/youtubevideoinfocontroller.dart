import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart'as GetX;
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


import '../config.dart';
import '../models/channelmodels.dart';
import '../models/video_model.dart';
import '../models/videomodels.dart';


class YoutubeVideoInfoController extends GetxController{
  //
  static const CHANNEL_ID = 'UCaayLD9i5x4MmIoVZxXSv_g';
  static const VIDEO_ID = 'ru_5PA8cwkE';
  static const _baseUrl = 'www.googleapis.com';

  static Future<ChannelInfo> getChannelInfo(String? channelid) async {
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
    print("Channel thumbnal");
    print(channelInfo.items![0].snippet!.thumbnails!.high!.url);
    return channelInfo;
  }

   Future<int> getvideoinfo(String videoid) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'id': VIDEO_ID,
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
    print(response.body);
    Videos videos=Videos.fromJson(jsonDecode(response.body));
 //   clipboardController.updatevideoinfo(videos.videos![0].video!.title,
   //     videos.videos![0].video!.thumbnails!.maxres!.url);
    print(videos.kind);
    print(videos.videos![0].video!.title);
    print(videos.videos![0].video!.description);
    print(videos.videos![0].video!.thumbnails!.maxres!.url);
    print(videos.videos![0].video!.channelTitle);
    print(videos.videos![0].video!.channelId);
    //   getChannelInfo(videos.videos![0].video!.channelId);

    // return channelInfo;
    return 0;
  }

  static Future<VideosList> getVideosList(
      {String? playListId, String? pageToken}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playListId!,
      'maxResults': '8',
      'pageToken': pageToken!,
      'key': Constants.API_KEY,
    };
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Response response = await http.get(uri, headers: headers);
    // print(response.body);
    VideosList videosList = videosListFromJson(response.body);
    return videosList;
  }
}