import 'package:finalapp/bindings/general_bindings.dart';
import 'package:finalapp/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'features/dashboard/screens/dashboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: GeneralBindings(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const dashboard() //const Scaffold(backgroundColor: TColors.primary,body: Center(child: CircularProgressIndicator(color: Colors.white)),),
    );
  }
}
