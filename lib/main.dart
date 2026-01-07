import 'package:flutter/material.dart';
import 'package:khel_hisab/provider/theme_provider.dart';
import 'package:khel_hisab/screen/homescreen.dart';
import 'package:khel_hisab/theme/theme.dart';
import 'package:khel_hisab/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Khel Hisab',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: SplashScreen(),
    );
  }
}
