import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AnalyticsEventController extends GetxController {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();


  Future sendAnalyticsEvent(
      {String? eventName, String? clickevent}) async {
    await _analytics.logEvent(
      name: '${eventName}',
      parameters: <String, dynamic>{
        'clickEvent': "User has clicked"
      },
    );
  }

  void reg_settingstap() async {
    String datenow = DateFormat.yMMMMd('en_US').format(DateTime.now());
    var collectionRef = FirebaseFirestore.instance.collection('Settings Tap');
    var doc = await collectionRef.doc(datenow).get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection('Settings Tap')
          .doc(datenow)
          .update({"Number of Taps": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection('Settings Tap')
          .doc(datenow)
          .update({"Number of Taps": "1"});
    }
  }

  void reg_downloadsnavtap() async {
    String datenow = DateFormat.yMMMMd('en_US').format(DateTime.now());
    var collectionRef =
        FirebaseFirestore.instance.collection("Downloads Nav Tap");
    var doc = await collectionRef.doc(datenow).get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Downloads Nav Tap")
          .doc(datenow)
          .update({"Number of Taps": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Downloads Nav Tap")
          .doc(datenow)
          .set({"Number of Taps": "1"});
    }
  }

  void reg_ratetap() async {
    String datenow = DateFormat.yMMMMd('en_US').format(DateTime.now());
    var collectionRef =
    FirebaseFirestore.instance.collection("Rate Tap");
    var doc = await collectionRef.doc(datenow).get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Rate Tap")
          .doc(datenow)
          .update({"Number of Taps": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Rate Tap")
          .doc(datenow)
          .set({"Number of Taps": "1"});
    }
  }

  void reg_openvideotap() async {
    String datenow = DateFormat.yMMMMd('en_US').format(DateTime.now());
    var collectionRef =
    FirebaseFirestore.instance.collection("Open Video Tap");
    var doc = await collectionRef.doc(datenow).get();
    if (doc.exists) {
      await FirebaseFirestore.instance
          .collection("Open Video Tap")
          .doc(datenow)
          .update({"Number of Taps": FieldValue.increment(1)});
    } else {
      await FirebaseFirestore.instance
          .collection("Open Video Tap")
          .doc(datenow)
          .set({"Number of Taps": "1"});
    }
  }
}
