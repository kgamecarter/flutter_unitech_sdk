import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unitech_sdk/app_management_ctrl.dart';
import 'package:unitech_sdk/clock_ctrl.dart';
import 'package:unitech_sdk/scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Scanner
  bool _scannerEnabled = true;
  bool _scan2KeyEnabled = true;
  final List<String> _scannedData = [];
  StreamSubscription? _scanSubscription;

  // App Management
  final TextEditingController _apkPathController = TextEditingController();
  final TextEditingController _pkgNameController = TextEditingController();
  final TextEditingController _cmdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _apkPathController.dispose();
    _pkgNameController.dispose();
    _cmdController.dispose();
    super.dispose();
  }

  void _initScanner() {
    Scanner.scannerReceiver.start();
    _scanSubscription = Scanner.scannerReceiver.messages.listen((event) {
      setState(() {
        _scannedData.insert(0, "${DateTime.now()}: ${event.data.toString()}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Unitech SDK Example'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Scanner',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SwitchListTile(
              title: const Text('Enable Scanner'),
              value: _scannerEnabled,
              onChanged: (value) {
                Scanner.enableScanner(value);
                setState(() {
                  _scannerEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Enable Scan2Key'),
              value: _scan2KeyEnabled,
              onChanged: (value) {
                Scanner.enableScan2Key(value);
                setState(() {
                  _scan2KeyEnabled = value;
                });
              },
            ),
            const Text('Scanned Data:'),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: _scannedData.isEmpty
                  ? const Center(child: Text("No data scanned yet"))
                  : ListView.builder(
                      itemCount: _scannedData.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(_scannedData[index]),
                        dense: true,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _scannedData.clear();
                });
              },
              child: const Text("Clear Scanned Data"),
            ),
            const Divider(),
            const Text('Clock Control',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => ClockCtrl.setTimeMode(1),
                  child: const Text('Set Time Mode 1'),
                ),
                ElevatedButton(
                  onPressed: () => ClockCtrl.setTimeMode(0),
                  child: const Text('Set Time Mode 0'),
                ),
                ElevatedButton(
                  onPressed: () => ClockCtrl.setDateTime(DateTime.now()),
                  child: const Text('Sync Time Now'),
                ),
              ],
            ),
            const Divider(),
            const Text('App Management',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _apkPathController,
              decoration: const InputDecoration(
                labelText: 'APK Path',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pkgNameController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_apkPathController.text.isNotEmpty &&
                    _pkgNameController.text.isNotEmpty) {
                  AppManagementCtrl.installApp(
                    _apkPathController.text,
                    _pkgNameController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Install command sent")),
                  );
                }
              },
              child: const Text('Install App'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cmdController,
              decoration: const InputDecoration(
                labelText: 'System Command',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_cmdController.text.isNotEmpty) {
                  AppManagementCtrl.runSysCmd(_cmdController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Command sent")),
                  );
                }
              },
              child: const Text('Run Command'),
            ),
          ],
        ),
      ),
    );
  }
}
