import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exportasystem/database/databaseHelper.dart';
import 'package:exportasystem/models/userModel.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final _col = FirebaseFirestore.instance.collection('users');
  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ---------- FIRESTORE ----------
  Future<void> upsertFirestore(UserModel u) async {
    await _col.doc(u.firebaseUid).set(u.toFirestore(), SetOptions(merge: true));
  }

  Future<UserModel?> getFromFirestore(String uid) async {
    final snap = await _col.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromFirestore(uid, snap.data()!);
  }

  // ---------- SQLITE ----------
  Future<UserModel?> findByFirebaseUid(String uid) async {
      if (kIsWeb) return null;
      final db = await _db;
      final res =
          await db.query('users', where: 'firebaseUid = ?', whereArgs: [uid]); 
      if (res.isEmpty) return null;
      return UserModel.fromMap(res.first);
    }

   Future<void> upsertLocal (UserModel user) async {
      if (kIsWeb) return;
      try {
        final db = await _db;
        final res = await db.query('users',
            where: 'firebaseUid = ?', whereArgs: [user.firebaseUid], limit: 1);

        if (res.isEmpty) {
            await db.insert('users', user.toMap());
          } else {
            await db.update('users', user.toMap(),
                where: 'firebaseUid = ?', whereArgs: [user.firebaseUid]);
          }
      } catch (e) {
        print('Erro ao salvar localmente: $e');
      }
    }
  // ---------- SYNC ----------
  /// Garante o usuário em ambos os lados e retorna o modelo consolidado local.
  Future<UserModel> syncUser(UserModel base) async {
    if (base.firebaseUid == null) {
      await upsertLocal(base);
      return base;
    }

    final remote = await getFromFirestore(base.firebaseUid!);

    final merged = (remote == null)
        ? base
        : base.copyWith(
            name: remote.name,
            email: remote.email,
            avatarUrl: remote.avatarUrl,
            isGoogleUser: remote.isGoogleUser,
            role: remote.role,
            classId: remote.classId,
          );

    await upsertFirestore(merged);
    await upsertLocal(merged);
    return merged;
  }
}
