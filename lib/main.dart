import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui/threat_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("SHIELDGUARD: SYSTEM INITIALIZING...");
  runApp(const ShieldGuardApp());
}

class ShieldGuardApp extends StatelessWidget {
  const ShieldGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShieldGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const ThreatDashboard(),
    );
  }
}
