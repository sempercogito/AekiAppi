import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/scan_screen.dart';
import 'services/scooter_service.dart';

void main() {
  runApp(const AekiAppi());
}

class AekiAppi extends StatelessWidget {
  const AekiAppi({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScooterService(),
      child: MaterialApp(
        title: 'AekiAppi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B1B2F),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const ScanScreen(),
      ),
    );
  }
}
