// slave_management.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/firestore_service.dart';
import '../models/slave_model.dart';

class SlaveManagement extends StatefulWidget {
  @override
  _SlaveManagementState createState() => _SlaveManagementState();
}

class _SlaveManagementState extends State<SlaveManagement> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  String _slaveName = '';
  String _slaveId = '';
  bool _isScanning = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        setState(() {
          _slaveId = scanData.code!;
          _isScanning = false;
        });
        controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _registerSlave() async {
    if (_formKey.currentState!.validate()) {
      try {
        String slaveId = _slaveId.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : _slaveId;

        Slave slave = Slave(
          id: slaveId,
          name: _slaveName,
          isActive: false,
          lastSeen: DateTime.now(),
        );

        await _firestoreService.registerSlave(slave);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Slave registered successfully\nID: $slaveId')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering slave: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register New Slave')),
      body: _isScanning
          ? QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      )
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Slave Name'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
                onChanged: (value) => _slaveName = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Slave ID (Optional)',
                  hintText: 'Leave empty for auto-generated ID',
                ),
                initialValue: _slaveId,  // Fixed: changed 'value' to 'initialValue'
                onChanged: (value) => setState(() => _slaveId = value),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isScanning = true),
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Scan QR Code'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _registerSlave,
                child: Text('Register Slave'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}