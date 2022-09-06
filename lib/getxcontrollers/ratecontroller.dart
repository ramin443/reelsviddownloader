import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

class RatingController extends GetxController{
  final InAppReview inAppReview = InAppReview.instance;

  onreviewboxtapped()async{
    inAppReview.openStoreListing();
    update();
  }
  requestreview()async{
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }
}