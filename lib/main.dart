import 'package:exportasystem/screens/homeScreen.dart';
import 'package:exportasystem/screens/loginScreen.dart';
import 'package:exportasystem/screens/registerScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';


import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAOsrsvTBvXmHW84syWiTeHo4WlDK0yp34",
        authDomain: "esportasystem.firebaseseapp.com",
        projectId: "esportasystem",
        storageBucket: "esportasystem.appspot.com",
        messagingSenderId: "864187300572",
        appId: "1-864187300572:web:abcdef123456",
        measurementId: "G-864187300572",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚀 2. TROQUE MaterialApp POR GetMaterialApp
    return GetMaterialApp(
      title: 'Exporta System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),

      // Suas rotas continuam iguais
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}