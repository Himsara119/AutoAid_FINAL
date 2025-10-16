import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/features/auth/screens/forget_password_screen.dart';
import 'package:finalapp/features/auth/screens/login_screen.dart';
import 'package:finalapp/features/auth/screens/signup_screen.dart';
import 'package:finalapp/features/dashboard/screens/dashboard_screen.dart';
import 'package:finalapp/features/documents/screens/doc_detail_screen.dart';
import 'package:finalapp/features/documents/screens/replace_doc_screen.dart';
import 'package:finalapp/features/notifications/screens/notifications_screen.dart';
import 'package:finalapp/features/profile/screens/profile_edit_screen.dart';
import 'package:finalapp/features/reports/screens/report_builder_screen.dart';
import 'package:finalapp/features/reports/screens/report_preview_screen.dart';
import 'package:finalapp/features/services/presentation/add_service_screen.dart';
import 'package:finalapp/features/services/presentation/edit_service_screen.dart';
import 'package:finalapp/features/vehicles/tabs/documents_tab.dart';
import 'package:finalapp/features/vehicles/tabs/overview_tab.dart';
import 'package:finalapp/features/vehicles/tabs/reports_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../utils/validators/exceptions.dart';
import '../../features/documents/screens/upload_doc_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();


  ///Variables
  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  ///Called from main.dart on app launch
  @override
  void onReady() {
    ///Remove the native splash screen
    FlutterNativeSplash.remove();

    ///Redirect to the appropriate screen
    screenRedirect();
  }

  screenRedirect() async {
    ///Local Storage
    deviceStorage.writeIfNull('IsFirstTime', true);

    ///Check if it's the first time launching the app
    deviceStorage.read('IsFirstTime') != true
        ? Get.offAll(() => const ConditionReportScreen())
        : Get.offAll(const ConditionReportScreen());
  }


  ///-------------------- Email & Password Sign-In--------------------------------------


  /// [EmailAuthentication] - REGISTER
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Create user account
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      final user = cred.user ?? _auth.currentUser;
      if (user != null) {
        final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }

        // Optionally store user info in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return cred;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }
}




