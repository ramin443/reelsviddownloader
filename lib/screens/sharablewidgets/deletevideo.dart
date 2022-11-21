import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import '../../constants/colorconstants.dart';
import '../../constants/fontconstants.dart';
import '../../dbhelpers/DownloadedVidDBHelper.dart';
import '../../getxcontrollers/clipboardcontroller.dart';

class DeleteVideo extends StatelessWidget {
  final String? taskid;
  final int? index;
  final ClipboardController clipboardController=Get.put(ClipboardController());
  DownloadedVidDatabaseHelper downloadedVidDatabaseHelper=DownloadedVidDatabaseHelper();
  DeleteVideo({@required this.taskid,@required this.index});
  @override
  Widget build(BuildContext context) {
    double screenwidth=MediaQuery.of(context).size.width;
   return Material(
        child:
        ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child:Container(
              width: screenwidth*0.7615,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Text("Are you sure you want to delete\n"
                        "this video?",style: TextStyle(
                        fontFamily: proximanovabold,
                        color: blackthemedcolor,
                        fontSize: screenwidth*0.0401
                    ),),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      //       top: 14,bottom:11
                        top: screenwidth*0.0316,bottom:screenwidth*0.0267
                    ),
                    child: Image.asset("assets/images/cautionalert.jpg",
                      width: screenwidth*0.4987,),
                  ),
                  Container(
                    child: Text("Please keep in mind that the video will be deleted\n"
                      "  and you will have to copy the link and paste again\n"
                        "if you want to download it again.",style: TextStyle(
                        fontFamily: proximanovaregular,
                        color: greythemedcolor,
                        fontSize: screenwidth*0.03041
                    ),),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      //      top: 14
                        top: screenwidth*0.0340,
                 //       bottom: 8
                        bottom: screenwidth*0.01946

                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(onTap: (){
                          Navigator.pop(context);

                        }, child: Container(
                          child: Text("Back",
                            style: TextStyle(
                                fontFamily: proximanovaregular,
                                color: blackthemedcolor,
                                //       fontSize: 14.5
                                fontSize: screenwidth*0.0352
                            ),),
                        )),
                        GestureDetector(onTap: ()async{
                          await FlutterDownloader.remove(taskId: taskid.toString(),
                          shouldDeleteContent: true
                          );
                          clipboardController.
                          deletefromdb(index!);
                          clipboardController.updateListView();
                          clipboardController.updateListView();
                          Navigator.pop(context);
                        }, child: Container(
                          padding: EdgeInsets.symmetric(
//                              horizontal: 14,vertical: 5
                              horizontal: screenwidth*0.03406,vertical: screenwidth*0.01216
                          ),
                          decoration: BoxDecoration(
                              color: Color(0xffFF0000).withOpacity(0.67),
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                              boxShadow: [BoxShadow(color: Color(0xffFF0000).withOpacity(0.48),
                                  offset: Offset(0,3),blurRadius: 10)]
                          ),
                          child: Text("Delete",
                            style: TextStyle(
                                fontFamily: proximanovaregular,
                                color: Colors.white,
                                //       fontSize: 14.5
                                fontSize: screenwidth*0.0352
                            ),),
                        ))
                      ],
                    ),
                  )
                ],
              ),
            )));
  }
  void _delete(int id) async {
    int result = await downloadedVidDatabaseHelper.deleteDownload(id);
    if (result != 0) {
      print("Deleted succesfully");
    } else {
      print("Delete unsuccesful");
    }
  }
}
