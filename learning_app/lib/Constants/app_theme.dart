import 'package:flutter/material.dart';
import 'package:learning_app/Constants/app_color.dart';

enum AppTheme {
  lightTheme,
  darkTheme,
}

class AppThemes {
  // Light Theme

  static final appThemeData = {
    AppTheme.lightTheme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto', // Global font family
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F7F8), // Background color
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF3B3A3A), // Icon and text color
        elevation: 4,
        titleTextStyle: TextStyle(
            color: Color(0xFF3B3A3A),
            fontSize: 24,
            fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Color(0xFF3B3A3A)),
        surfaceTintColor: Colors.transparent, // Disable surface tint
        shadowColor: Color.fromARGB(97, 0, 0, 0), // Add shadow color
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white, // Tab label color
        unselectedLabelColor: Color(0xFF767872),
        // Unselected label color
        indicator: BoxDecoration(
          color: AppColors.purple,
          border: Border(
            bottom: BorderSide(
              color: Colors.transparent, // Indicator color
              width: 0,
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Color(0xFF3B3A3A),
            fontSize: 32,
            fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Color(0xFF3B3A3A),
            fontSize: 28,
            fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Color(0xFF3B3A3A), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF767872), fontSize: 14),
        titleMedium: TextStyle(
            color: Color(0xFF3B3A3A),
            fontSize: 18,
            fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: Color(0xFF767872), fontSize: 16),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF7B16FF), // Primary button color
        disabledColor: Color(0xFF3B3A3A), // Disabled button
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF7B16FF),
          disabledForegroundColor: const Color(0xFF3B3A3A).withOpacity(0.38),
          disabledBackgroundColor:
              const Color(0xFF3B3A3A).withOpacity(0.12), // Disabled color
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7B16FF),
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFFB7D9EE), // Default card color
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
      dividerColor: const Color(0xFFDDDDDD), // Divider color
      iconTheme: const IconThemeData(color: Color(0xFF3B3A3A), size: 24),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.green, // Progress bar
        circularTrackColor: Color(0xFFD9EDEB),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFB7D9EE),
        disabledColor: Color(0xFFDDDDDD),
        selectedColor: Color(0xFF7B16FF),
        secondarySelectedColor: Color(0xFF7B16FF),
        padding: EdgeInsets.all(8),
        labelStyle: TextStyle(color: Color(0xFF3B3A3A)),
        secondaryLabelStyle: TextStyle(color: Colors.white),
        brightness: Brightness.light,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFFFFFFFF),
        titleTextStyle: TextStyle(
            color: Color(0xFF3B3A3A),
            fontSize: 20,
            fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: Color(0xFF3B3A3A), fontSize: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color.fromARGB(255, 123, 22, 255),
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(
          color: Color.fromARGB(255, 123, 22, 255),
        ),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        elevation: 8,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFDDDDDD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF7B16FF)),
        ),
        labelStyle: TextStyle(color: Color(0xFF3B3A3A)),
        hintStyle: TextStyle(color: Color(0xFF767872)),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
            color: Color(0xFF7B16FF),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        textStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),

    //Dark theme
    AppTheme.darkTheme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto', // Global font family
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF11130E), // Default color for containers
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF11130E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF292C31),
        foregroundColor: Colors.white,
        elevation: 4,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent, // Disable surface tint
        shadowColor: Color.fromARGB(97, 0, 0, 0), // Add shadow color
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.white, // Tab label color
        unselectedLabelColor: Color(0xFF767872),
        // Unselected label color
        indicator: BoxDecoration(
          color: AppColors.purple,
          border: Border(
            bottom: BorderSide(
              color: Colors.transparent, // Indicator color
              width: 0,
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF727984), fontSize: 14),
        titleMedium: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: Color(0xFF727984), fontSize: 16),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF8E59FF),
        disabledColor: Color(0xFF9DA096),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF8E59FF),
          disabledForegroundColor: const Color(0xFF9DA096).withOpacity(0.38),
          disabledBackgroundColor: const Color(0xFF9DA096).withOpacity(0.12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF8E59FF),
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFF292C31),
        elevation: 4,
        margin: EdgeInsets.all(8),
      ),
      dividerColor: const Color(0xFF343434),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF8E59FF),
        circularTrackColor: Color(0xFF292C31),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF292C31),
        disabledColor: Color(0xFF343434),
        selectedColor: Color(0xFF8E59FF),
        secondarySelectedColor: Color(0xFF8E59FF),
        padding: EdgeInsets.all(8),
        labelStyle: TextStyle(color: Colors.white),
        secondaryLabelStyle: TextStyle(color: Colors.black),
        brightness: Brightness.dark,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFF292C31),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF292C31),
        selectedItemColor: Color.fromARGB(255, 142, 89, 255),
        unselectedItemColor: Color(0xFF9DA096),
        selectedLabelStyle: TextStyle(
          color: Color.fromARGB(255, 142, 89, 255),
        ),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        elevation: 8,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF292C31),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF343434)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF343434)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF8E59FF)),
        ),
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Color(0xFF727984)),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
            color: Color(0xFF8E59FF),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        textStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  };
}
