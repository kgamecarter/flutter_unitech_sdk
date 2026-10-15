import 'package:flutter/material.dart';
import 'package:unitech_sdk/unitech_sdk.dart';

import 'demo_view_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.sdk});

  final UnitechSdk? sdk;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DemoViewModel _viewModel;
  final _apkPath = TextEditingController();
  final _packageName = TextEditingController();
  final _command = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = DemoViewModel(sdk: widget.sdk ?? UnitechSdk());
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _apkPath.dispose();
    _packageName.dispose();
    _command.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Unitech SDK Example')),
          body: Column(
            children: [
              if (_viewModel.busy) const LinearProgressIndicator(),
              if (_viewModel.message != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(_viewModel.message!),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('Scanner',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SwitchListTile(
                      title: const Text('Enable Scanner'),
                      value: _viewModel.scannerEnabled,
                      onChanged:
                          _viewModel.busy ? null : _viewModel.setScannerEnabled,
                    ),
                    SwitchListTile(
                      title: const Text('Enable Scan2Key'),
                      value: _viewModel.scan2KeyEnabled,
                      onChanged: _viewModel.busy
                          ? null
                          : _viewModel.setScan2KeyEnabled,
                    ),
                    const Text('Scanned Data:'),
                    Container(
                      height: 150,
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: _viewModel.scans.isEmpty
                          ? const Center(child: Text('No data scanned yet'))
                          : ListView.builder(
                              itemCount: _viewModel.scans.length,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(_viewModel.scans[index]),
                                dense: true,
                              ),
                            ),
                    ),
                    ElevatedButton(
                      onPressed: _viewModel.clearScans,
                      child: const Text('Clear Scanned Data'),
                    ),
                    const Divider(),
                    const Text('Clock Control',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: _viewModel.busy
                              ? null
                              : () => _viewModel.setTimeMode(1),
                          child: const Text('Set Time Mode 1'),
                        ),
                        ElevatedButton(
                          onPressed: _viewModel.busy
                              ? null
                              : () => _viewModel.setTimeMode(0),
                          child: const Text('Set Time Mode 0'),
                        ),
                        ElevatedButton(
                          onPressed:
                              _viewModel.busy ? null : _viewModel.syncTime,
                          child: const Text('Sync Time Now'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text('App Management',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apkPath,
                      decoration: const InputDecoration(
                          labelText: 'APK Path', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _packageName,
                      decoration: const InputDecoration(
                          labelText: 'Package Name',
                          border: OutlineInputBorder()),
                    ),
                    ElevatedButton(
                      onPressed: _viewModel.busy
                          ? null
                          : () => _viewModel.installApp(
                              _apkPath.text, _packageName.text),
                      child: const Text('Install App'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _command,
                      decoration: const InputDecoration(
                          labelText: 'System Command',
                          border: OutlineInputBorder()),
                    ),
                    ElevatedButton(
                      onPressed: _viewModel.busy
                          ? null
                          : () => _viewModel.runCommand(_command.text),
                      child: const Text('Run Command'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
