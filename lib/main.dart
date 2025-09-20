import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:safarsathi_app/firebase_options.dart';
import 'package:safarsathi_app/providers/theme_provider.dart';
import 'package:safarsathi_app/theme/theme.dart';
import 'screens/login_screen.dart';
import 'services/trip_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  final tripService = TripService();
  await tripService.start();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'SafarSathi',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getIsDarkTheme ? darkTheme : lightTheme,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
