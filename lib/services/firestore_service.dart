import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import '../models/slave_model.dart';
import '../services/auth_service.dart';
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get current master's ID
  String? get currentMasterId => _authService.getCurrentUser()?.uid;

  // Modified Content Operations
  Future<void> addContent(Content content) async {
    if (currentMasterId == null) throw Exception('Not authenticated');

    final contentWithMaster = content.toMap()..addAll({
      'masterId': currentMasterId,
    });

    await _firestore.collection('content').doc(content.id).set(contentWithMaster);
  }

  Stream<List<Content>> getContentForSlave(String slaveId) {
    if (currentMasterId == null) throw Exception('Not authenticated');

    return _firestore
        .collection('content')
        .where('masterId', isEqualTo: currentMasterId)
        .where('slaveId', isEqualTo: slaveId)
        .orderBy('sequence')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Content.fromMap(doc.data()))
        .toList());
  }

  // Modified Slave Operations
  Future<void> registerSlave(Slave slave) async {
    if (currentMasterId == null) throw Exception('Not authenticated');

    final slaveWithMaster = slave.toMap()..addAll({
      'masterId': currentMasterId,
    });

    await _firestore.collection('slaves').doc(slave.id).set(slaveWithMaster);
  }
  Future<void> deleteContent(String contentId) async {
    if (currentMasterId == null) throw Exception('Not authenticated');
    await _firestore.collection('content').doc(contentId).delete();
  }

  Future<void> updateContentDuration(String contentId, int newDuration) async {
    if (currentMasterId == null) throw Exception('Not authenticated');
    await _firestore.collection('content').doc(contentId).update({
      'displayDuration': newDuration,
    });
  }

  Stream<List<Slave>> getSlaves() {
    if (currentMasterId == null) throw Exception('Not authenticated');

    return _firestore
        .collection('slaves')
        .where('masterId', isEqualTo: currentMasterId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Slave.fromMap(doc.data()))
        .toList());
  }
}