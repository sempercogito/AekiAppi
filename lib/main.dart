import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/scan_screen.dart';
import 'screens/unsupported_platform_screen.dart';
import 'services/scooter_service.dart';

/// Returns true—all platforms are supported via [universal_ble]
/// (Android, iOS, macOS, Linux, Windows, Web)
bool get _isBleSupported => true;

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
        home: _isBleSupported
            ? const ScanScreen()
            : const UnsupportedPlatformScreen(),
      ),
    );
  }
}
