import 'package:flutter/material.dart';
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

  Future<void> _registerSlave() async {
    if (_formKey.currentState!.validate()) {
      try {
        String slaveId = DateTime.now().millisecondsSinceEpoch.toString();
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Slave Name'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
                onChanged: (value) => _slaveName = value,
              ),
              SizedBox(height: 24),
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