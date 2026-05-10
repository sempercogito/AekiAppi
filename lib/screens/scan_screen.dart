import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_ble/universal_ble.dart';

import '../services/scooter_service.dart';
import 'home_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<BleDevice> _discovered = [];
  bool _isScanning = false;
  StreamSubscription<BleDevice>? _scanSubscription;

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _discovered.clear();
      _isScanning = true;
    });

    final service = context.read<ScooterService>();
    _scanSubscription = service.scanForScooters().listen(
      (bleDevice) {
        if (!_discovered.any((d) => d.deviceId == bleDevice.deviceId)) {
          setState(() => _discovered.add(bleDevice));
        }
      },
      onDone: () async {
        await service.stopScan();
        if (mounted) setState(() => _isScanning = false);
      },
      onError: (_) async {
        await service.stopScan();
        if (mounted) setState(() => _isScanning = false);
      },
    );
  }

  Future<void> _stopScan() async {
    final service = context.read<ScooterService>();
    await _scanSubscription?.cancel();
    await service.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectTo(BleDevice bleDevice) async {
    await _stopScan();
    if (!mounted) return;

    final service = context.read<ScooterService>();
    await service.connect(bleDevice);
    if (!mounted) return;

    if (service.isConnected) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (service.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(service.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AekiAppi'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.electric_scooter,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Find your Äike scooter',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure Bluetooth is enabled and the scooter is nearby.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (_isScanning)
            const LinearProgressIndicator()
          else
            const SizedBox(height: 4),
          Expanded(
            child: _discovered.isEmpty
                ? Center(
                    child: Text(
                      _isScanning
                          ? 'Scanning…'
                          : 'No scooters found.\nTap Scan to search.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _discovered.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final bleDevice = _discovered[index];
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(
                          bleDevice.name?.isNotEmpty ?? false
                              ? bleDevice.name!
                              : 'Äike',
                        ),
                        subtitle: Text(bleDevice.deviceId),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _connectTo(bleDevice),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isScanning ? _stopScan : _startScan,
        icon: Icon(_isScanning ? Icons.stop : Icons.search),
        label: Text(_isScanning ? 'Stop' : 'Scan'),
      ),
    );
  }
}
