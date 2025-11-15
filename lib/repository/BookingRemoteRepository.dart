
import 'package:exportasystem/models/BookingModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingRemoteRepository {
  final _fs = FirebaseFirestore.instance;

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('FirebaseAuth.currentUser == null (usuário não autenticado).');
    }
    return user.uid;
  }


  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('users').doc(_uid).collection('bookings');

  Future<String> create(Booking b) async {
    final doc = await _col.add(b.toFirestore(_uid));
    return doc.id;
  }

  Future<void> upsert(Booking b) async {
    if (b.remoteId == null) {
    
      final id = await create(b);
      
      await _col.doc(id).set(
        {'updatedAt': b.updatedAt.millisecondsSinceEpoch},
        SetOptions(merge: true),
      );
      return;
    }

    await _col.doc(b.remoteId).set(b.toFirestore(_uid), SetOptions(merge: true));
  }

  Future<void> deleteRemote(String remoteId) async {
   
    await _col.doc(remoteId).set(
      {'deleted': true, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      SetOptions(merge: true),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAll() {
    
    return _col.orderBy('updatedAt', descending: true).snapshots();
  }

  Future<List<Booking>> fetchAllOnce() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => Booking.fromFirestore(d.data(), remoteId: d.id))
        .toList();
  }
}