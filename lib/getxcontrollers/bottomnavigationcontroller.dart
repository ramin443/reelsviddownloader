
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BottomNavigationController extends GetxController {
  int currentindex = 0;

  setindex(int index) {
    currentindex = index;
    update();
  }
  addclipboardlistener(){
  }
}
