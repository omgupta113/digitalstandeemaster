import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/slave_model.dart';
import 'upload_content.dart';
import 'slave_management.dart';
import 'login_screen.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Signage Master Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Slave>>(
        stream: _firestoreService.getSlaves(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Slave> slaves = snapshot.data!;

          return ListView.builder(
            itemCount: slaves.length,
            itemBuilder: (context, index) {
              Slave slave = slaves[index];
              return ListTile(
                title: Text(slave.name),
                subtitle: Text('ID: ${slave.id}'),
                trailing: Icon(
                  slave.isActive ? Icons.check_circle : Icons.error,
                  color: slave.isActive ? Colors.green : Colors.red,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadContent(slaveId: slave.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SlaveManagement()),
        ),
        child: Icon(Icons.add),
        tooltip: 'Add New Slave',
      ),
    );
  }
}