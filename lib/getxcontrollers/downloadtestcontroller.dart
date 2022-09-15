import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DownloadController extends GetxController{
  void initializedownload(String downloadlink)async{

    await FirebaseFirestore.instance.collection("newones").doc('Iker').set(
        {
          "":"",
          "":""
        });
  }

}