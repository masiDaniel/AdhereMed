import 'package:flutter/material.dart';
import 'package:version_0/services/local_notification_service.dart';
import 'package:version_0/views/Doctors/Doctors_view.dart';
import 'package:version_0/views/patients/bottom_nav_bar.dart';
import 'package:version_0/views/patients/home_page.dart';
import 'package:version_0/views/Shared_pages/landing_page.dart';
import 'package:version_0/views/Doctors/prescription_form.dart';
import 'package:version_0/views/profile_page.dart';
import 'package:version_0/views/Shared_pages/sign_in.dart';
import 'package:version_0/views/Shared_pages/sign_up.dart';
import 'package:version_0/views/Doctors/doctor_sign_up.dart';
import 'package:version_0/views/Shared_pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize(); // Initialize the notifications
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdhereMed',
      initialRoute: '/',
      routes: {
        '/': (context) => const splashScreen(),
        '/home': (context) => HomePage(),
        '/signuppage': (context) => const SignUpPage(),
        '/loginpage': (context) => LogInPage(),
        '/profile': (context) => const UserProfilePage(),
        '/prescriptionform': (context) => PrescriptionFormPage(),
        '/landingpage': (context) => const landingPage(),
        '/doctorspage': (context) => const DoctorsPage(),
        '/doctorSignUp': (context) => const doctorSignUpPage(),
        '/mainnavpage': (context) => const MainNavigationPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
