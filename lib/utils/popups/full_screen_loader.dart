import 'package:finalapp/utils/constants/colors.dart';
import 'package:finalapp/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../common/widgets/loaders/animation_loader.dart';

///A utility class for managing a full screen loading dialog
class TFullScreenLoader {
  ///open a full screen loadinf dailog with a given ext and animation
  ///this method doesn't return anything
  ///
  /// parameters
  /// - text : the text to be displayed in the loading dialog
  /// - animation : the lottie animation to be shown
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!, // use Get.overlaycontext for overlay dialogs
      barrierDismissible: false, // the dialog can't be dismissed by tapping outside it
      builder: (_) => PopScope(
              canPop: false, // disable popping with the back button
              child: Container(
                color: TColors.white,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 250, width: 200,), // adjust as needed
                    TAnimationLoaderWidget(text: text, animation: animation),
                  ],
                ),
              )
          ),
    );
  }

  ///stop the currently open loading dialog
  ///this method doesn't return anything
  static stopLoading() {
    Navigator
        .of(Get.overlayContext!)
        .pop(); //Close the dialog using the navigator
  }
}