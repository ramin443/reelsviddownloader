import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:reelsdownloader/testers/extractcontroller.dart';

class TestScreen extends StatelessWidget {
   TestScreen({Key? key}) : super(key: key);
   List<String> links=[
     "https://www.instagram.com/reel/Cd8VehKK5il/?igshid=YmMyMTA2M2Y=",
     "https://www.instagram.com/reel/CeQ_uG4qJQk/?igshid=YmMyMTA2M2Y=",
     "https://www.instagram.com/reel/CebS1Yfhm4b/?igshid=YmMyMTA2M2Y=",
     "https://www.instagram.com/reel/CeXkcYJJLTN/?igshid=YmMyMTA2M2Y=",
     "https://www.instagram.com/reel/CeLbD0NDPPz/?igshid=YmMyMTA2M2Y="
   ];
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExtractTest>(
        init: ExtractTest(),
        builder: (linkcontroller){
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(onPressed: (){
         //     linkcontroller.downloadReels(links[0]);
           linkcontroller.fbparsetest("https://fb.watch/dFdBnOjWtH/");
            }, icon: Icon(CupertinoIcons.plus_circle_fill,
              color: Colors.black,
              size: 24,))
          ],
        ),
      );});
    }
  }
