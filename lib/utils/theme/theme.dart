import 'package:finalapp/utils/theme/custom.themes/appbar_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/bottom_sheet_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/checkbox_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/chip_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/elevated_button_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/outlined_button_theme.dart';
import 'package:finalapp/utils/theme/custom.themes/text_feild_theme.dart';
import 'package:flutter/material.dart';

import 'custom.themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckBoxThemeData.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFeildTheme.lightInputDecorationTheme,
  );
}