import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exportasystem/helper/databaseHelper.dart';
import 'package:exportasystem/models/userModel.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final _col = FirebaseFirestore.instance.collection('users');
  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ---------- FIRESTORE ----------
  Future<void> upsertFirestore(UserModel u) async {
    // Garante que o firebaseUid não seja nulo antes de chamar o doc()
    if (u.firebaseUid == null || u.firebaseUid!.isEmpty) {
      print("❌ Erro: Tentativa de salvar no Firestore sem firebaseUid.");
      return;
    }
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
          await db.query('users', where: 'firebaseUid = ?', whereArgs: [uid], limit: 1); 
      if (res.isEmpty) return null;
      return UserModel.fromMap(res.first);
    }

  
   Future<UserModel> upsertLocal (UserModel user) async {
      if (kIsWeb) return user;
      try {
        final db = await _db;
        
        // Tenta encontrar o usuário pelo firebaseUid OU pelo email
        List<Map<String, dynamic>> res = [];
        if (user.firebaseUid != null && user.firebaseUid!.isNotEmpty) {
           res = await db.query('users',
              where: 'firebaseUid = ?', whereArgs: [user.firebaseUid], limit: 1);
        } else {
           res = await db.query('users',
              where: 'email = ?', whereArgs: [user.email], limit: 1);
        }


        if (res.isEmpty) {
            // Se NÃO existe, insere e pega o novo ID
            final newId = await db.insert('users', user.toMap());
            print("✅ Usuário INSERIDO localmente com ID: $newId");
            return user.copyWith(id: newId); // Retorna o usuário com o novo ID
        } else {
            // Se JÁ existe, atualiza
            final existingId = res.first['id'] as int;
            await db.update('users', user.toMap(),
                where: 'id = ?', whereArgs: [existingId]);
            print("✅ Usuário ATUALIZADO localmente (ID: $existingId)");
            return user.copyWith(id: existingId); // Retorna o usuário com o ID existente
        }
      } catch (e) {
        print('❌ Erro ao salvar localmente (upsertLocal): $e');
        rethrow;
      }
    }
    
  // ---------- SYNC ----------
  /// Garante o usuário em ambos os lados e retorna o modelo consolidado local.
  Future<UserModel> syncUser(UserModel base) async {
    
    if (base.firebaseUid == null) {
      return await upsertLocal(base);
    }

    // 1. Busca no Firestore
    final remote = await getFromFirestore(base.firebaseUid!);

    // 2. Mescla os dados (dados do Firebase têm prioridade, exceto senha)
    final merged = (remote == null)
        ? base // Se é a primeira vez (registro), usa o 'base' (que tem a senha)
        : base.copyWith(
            name: remote.name,
            email: remote.email,
            avatarUrl: remote.avatarUrl,
            isGoogleUser: remote.isGoogleUser,
            role: remote.role,
            classId: remote.classId,
            password: base.password, // Mantém a senha local (se houver)
          );

    // 3. Salva no Firestore (sem a senha)
    await upsertFirestore(merged);
    
    // 4. Salva no SQLite (com senha) e RETORNA o modelo com o ID local
    return await upsertLocal(merged);
  }
}