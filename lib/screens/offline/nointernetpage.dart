import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight=MediaQuery.of(context).size.height;
    double screenWidth=MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text("You’re not connected to the Internet",style: TextStyle(
            //    fontSize: 18,
              fontSize: screenWidth*0.04379,
                fontFamily: proximanovabold,
                color: blackthemedcolor
              ),),
            ),
            Container(
              child: Text("Please connect to the internet and retry.",style: TextStyle(
             //     fontSize: 14,
               fontSize: screenWidth*0.03406,
                  fontFamily: proximanovaregular,
                  color: blackthemedcolor
              ),),
            ),
            Container(
              margin: EdgeInsets.only(
          //        top: 16
            top: screenWidth*0.03892
              ),
              child: Image.asset("assets/images/5356680.jpg",width: screenWidth*0.919,),
            )
          ],
        ),
      ),

    );
  }
}
