import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:exportasystem/controllers/userController.dart';
import 'package:exportasystem/services/googledriveService.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exportasystem/const/hashedPassword.dart';
import 'package:exportasystem/helper/databaseHelper.dart';
import 'package:exportasystem/models/userModel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:exportasystem/repository/authService.dart';
import 'package:exportasystem/repository/authRepository.dart';
import 'package:exportasystem/middleware/exceptions.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var avatarUrl = "".obs;
  final GoogleDriveService _driveService = GoogleDriveService();
  final UserController _userController = UserController();
  UserModel? _currentUser;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserRepository _userRepo = UserRepository();

  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  Future<bool> registerWithEmailAndFirebase({
    required String name,
    required String email,
    required String lastname,
    required String password,
    required String number,
  }) async {
    try {
      User? firebaseUser = await _authService.registerWithEmail(email, password);

      if (firebaseUser == null) {
        throw Exception("Falha ao criar usuário no Firebase.");
      }

      UserModel newUser = UserModel(
        firebaseUid: firebaseUser.uid, 
        name: name,
        email: email,
        password: hashPassword(password), 
        lastname: lastname,
        number: number,
        isGoogleUser: false,
      );


      UserModel syncedUser = await _userRepo.syncUser(newUser);

      await saveUserSession(syncedUser);
      return true;

    } on FirebaseAuthException catch (e) {
      throw Exceptions.fromCode(e.code);
    } catch (e) {
      print("❌ Erro no registerWithEmailAndFirebase: $e");
      rethrow;
    }
  }


  Future<bool> loginWithEmailAndPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final hashedPassword = hashPassword(password);

    try {
      await _authService.signInWithEmail(email, password);
      final user = await getUserByEmail(email);
      
      if (user != null) {
        if (user.password == hashedPassword) {
          await saveUserSession(user);
          print('✅ Usuário logado via Firebase e sessão local salva: ${user.toMap()}');
          return true;
        }
      }
      
      print("❌ Senha local incorreta ou usuário não encontrado localmente.");
      return false;

    } on FirebaseAuthException catch (e) {
      print("❌ Erro de login do Firebase: ${e.code}");
      throw Exceptions.fromCode(e.code);
    } catch (e) {
      print("❌ Erro no loginWithEmailAndPassword: $e");
      return false;
    }
  }


  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('⚠️ Login com Google cancelado pelo usuário.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        
  
        UserModel? localUser = await _userRepo.findByFirebaseUid(firebaseUser.uid);

        if(localUser == null) {
          // 2. Se não existe, cria um novo modelo
          localUser = UserModel(
            firebaseUid: firebaseUser.uid,
            name: firebaseUser.displayName ?? "Usuário Google",
            email: firebaseUser.email ?? "Sem Email",
            password: null, // Usuário do Google não tem senha local
            avatarUrl: firebaseUser.photoURL,
            isGoogleUser: true,
          );
        }

        UserModel syncedUser = await _userRepo.syncUser(localUser);

        await saveUserSession(syncedUser);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('❌ Erro ao fazer login com o Google: $e');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<void> setUserPassword(String email, String newPassword) async {
    final db = await database;
    final hashedPassword = hashPassword(newPassword);

    final user = await getUserByEmail(email);
    if (user == null) {
      print("❌ Usuário não encontrado.");
      return;
    }

    await db.update(
      'users',
      {
        'password': hashedPassword,
        'isGoogleUser': 0,
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGoogleUser', false);
    
    print("✅ Senha definida com sucesso!");
  }

  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', user.id.toString()); 
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('firebaseUid', user.firebaseUid ?? '');
    await prefs.setBool('isGoogleUser', user.isGoogleUser);
    
    if (user.avatarUrl != null) {
      await prefs.setString('avatarUrl', user.avatarUrl!);
      avatarUrl.value = user.avatarUrl!;
    }

    print('💾 Sessão salva: ${user.toMap()}');
  }

  Future<UserModel?> getUserFromSession() async {
    final prefs = await SharedPreferences.getInstance();

    final userIdString = prefs.getString('userId'); 
    final userName = prefs.getString('userName');
    final userEmail = prefs.getString('userEmail');
    final firebaseUid = prefs.getString('firebaseUid');
    final isGoogleUser = prefs.getBool('isGoogleUser') ?? false;
     final avatarUrlStored = prefs.getString('avatarUrl') ?? "";

    if (userIdString == null || userName == null || userEmail == null) {
      print("⚠️ Nenhum usuário encontrado na sessão.");
      return null;
    }

    final int? userId = int.tryParse(userIdString);

    if (userId == null) {
      print("❌ Erro: userId inválido na sessão.");
      return null;
    }

    print('🔄 Sessão carregada: userId: $userId, userName: $userName, userEmail: $userEmail,avatarUrl: $avatarUrlStored');

    avatarUrl.value = avatarUrlStored;
    _currentUser = UserModel(
      id: userId, 
      firebaseUid: firebaseUid,
      name: userName,
      email: userEmail,
      avatarUrl: avatarUrlStored,
      isGoogleUser: isGoogleUser,
    );
    return _currentUser;
  }

  Future<void> checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("🗑️ Sessão apagada!");
  }

  // ========================
  //  🔹 LOGOUT
  // ========================
  Future<void> logout() async {
    await clearSession();
    await _auth.signOut();
    await _googleSignIn.signOut();
    print('🚪 Usuário deslogado');
    Get.offAllNamed('/login');
  }


   Future<void> selectAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        // 🔄 Faz upload para Google Drive
        String? imageUrl = await _driveService.uploadImageToDrive(file);

        if (imageUrl != null && _currentUser != null) {
          await updateUserAvatarInDB(_currentUser!.id!, imageUrl);
          print("✅ Foto de perfil salva no Google Drive e no banco: $imageUrl");

          // 🔄 Atualiza a UI automaticamente
          avatarUrl.value = imageUrl;
        }
      }
    } catch (e) {
      print("❌ Erro ao selecionar e enviar foto: $e");
    }
  }

  Future<void> updateUserAvatarInDB(int userId, String newAvatarUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarUrl', newAvatarUrl);

      // 🔄 Atualiza a UI globalmente com GetX
      avatarUrl.value = newAvatarUrl;

      final db = await database;
      final rowsUpdated = await db.update(
        'users',
        {'avatarUrl': newAvatarUrl},
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (rowsUpdated > 0) {
        print("✅ Avatar atualizado no banco!");
      } else {
        print("⚠️ Nenhum avatar atualizado. O usuário pode não existir.");
      }
    } catch (e) {
      print("❌ Erro ao atualizar avatar no banco: $e");
    }
  }

  @override
  void onClose() {
    print("✅ AuthController fechado. Limpando controladores...");
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}