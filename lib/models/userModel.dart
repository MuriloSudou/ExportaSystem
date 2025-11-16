import 'package:exportasystem/const/hashedPassword.dart';

class UserModel {
  final int? id;
  final String? firebaseUid;
  final String name;
  final String email;
  final String? password;
  final bool isGoogleUser;
  final String? avatarUrl;
  final String? number;
  final String? lastname;
  final String role;
  final String? classId;

  UserModel({
    this.id,
    this.firebaseUid,
    required this.name,
    required this.email,
    this.password,
    required this.isGoogleUser,
    this.avatarUrl,
    this.number,
    this.lastname,
    this.role = 'student', 
    this.classId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'password': password,
      'isGoogleUser': isGoogleUser ? 1 : 0,
      'avatarUrl': avatarUrl,
      'number': number,
      'lastname': lastname,
      'role': role, 
      'classId': classId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firebaseUid: map['firebaseUid'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      isGoogleUser: map['isGoogleUser'] == 1,
      avatarUrl: map['avatarUrl'],
      number: map['number'],
      lastname: map['lastname'],
      role: map['role'] ?? 'student',
      classId: map['classId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'isGoogleUser': isGoogleUser,
      'avatarUrl': avatarUrl,
      'number': number,
      'lastname': lastname,
      'role': role,
      'classId': classId,
    };
  }

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> map) {
    return UserModel(
      id: null,
      firebaseUid: uid,
      name: map['name'],
      email: map['email'],
      password: null,
      isGoogleUser: map['isGoogleUser'] ?? false,
      avatarUrl: map['avatarUrl'],
      number: map['number'],
      lastname: map['lastname'],
      role: map['role'] ?? 'student',
      classId: map['classId'],
    );
  }

  UserModel copyWith({
    int? id,
    String? firebaseUid,
    String? name,
    String? email,
    String? password,
    String? avatarUrl,
    String? lastname,
    String? number,
    bool? isGoogleUser,
    String? role,
    String? classId,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastname: lastname ?? this.lastname,
      number: number ?? this.number,
      isGoogleUser: isGoogleUser ?? this.isGoogleUser,
      role: role ?? this.role,
      classId: classId ?? this.classId,
    );
  }
}