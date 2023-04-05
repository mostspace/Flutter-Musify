import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:musify/style/app_colors.dart';

Color primaryColor =
    Color(Hive.box('settings').get('accentColor', defaultValue: 0xFFF08080));

MaterialColor primarySwatch = getPrimarySwatch(primaryColor);

ColorScheme colorScheme = ColorScheme.fromSwatch(primarySwatch: primarySwatch);

final commonProperties = ThemeData(
  colorScheme: colorScheme.harmonized(),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  useMaterial3: true,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: colorScheme.background.withAlpha(50),
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    contentPadding: const EdgeInsets.only(
      left: 18,
      right: 20,
      top: 14,
      bottom: 14,
    ),
  ),
);

ThemeData getAppDarkTheme() {
  return commonProperties.copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    canvasColor: const Color(0xFF121212),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    appBarTheme: ThemeData.dark().appBarTheme.copyWith(
      backgroundColor: const Color(0xFF121212),
      iconTheme: IconThemeData(color: colorScheme.primary),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
      elevation: 0,
    ),
    bottomSheetTheme: ThemeData.dark()
        .bottomSheetTheme
        .copyWith(backgroundColor: const Color(0xFF121212)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    cardTheme: ThemeData.dark().cardTheme.copyWith(
      color: const Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2.3,
    ),
    listTileTheme:
        ThemeData.dark().listTileTheme.copyWith(textColor: colorScheme.primary),
    switchTheme: ThemeData.dark()
        .switchTheme
        .copyWith(trackColor: MaterialStateProperty.all(colorScheme.primary)),
    iconTheme:  ThemeData.dark().iconTheme.copyWith(color:  Colors.white),
    hintColor: Colors.white,
    bottomAppBarTheme: ThemeData.dark()
        .bottomAppBarTheme
        .copyWith(color: const Color(0xFF151515)),
  );
}

ThemeData getAppLightTheme() {
  return commonProperties.copyWith(
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
    bottomSheetTheme: ThemeData.light().bottomSheetTheme.copyWith(backgroundColor: Colors.white),
    appBarTheme: ThemeData.light().appBarTheme.copyWith(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: colorScheme.primary),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    cardTheme: ThemeData.light().cardTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2.3,
    ),
    listTileTheme: ThemeData.light().listTileTheme.copyWith(
      selectedColor: colorScheme.primary.withOpacity(0.4),
      textColor: colorScheme.primary,
    ),
    switchTheme: ThemeData.light().switchTheme.copyWith(
      trackColor: MaterialStateProperty.all(colorScheme.primary),
    ),
    iconTheme:  ThemeData.light().iconTheme.copyWith(color: Color(0xFF151515)),
    hintColor: const Color(0xFF151515),
    bottomAppBarTheme: ThemeData.light()
        .bottomAppBarTheme
        .copyWith(color: Colors.white),
  );
}
