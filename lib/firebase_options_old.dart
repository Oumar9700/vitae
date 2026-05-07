// FICHIER GÉNÉRÉ PAR: flutterfire configure
// Remplace ce fichier avec la vraie configuration Firebase
// Commande: flutterfire configure --project=TON-PROJET-ID
//
// Pour configurer Firebase:
// 1. Installe FlutterFire CLI: dart pub global activate flutterfire_cli
// 2. Crée un projet sur https://console.firebase.google.com
// 3. Lance: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      default: throw UnsupportedError('DefaultFirebaseOptions non supporté pour cette plateforme');
    }
  }

  // ⚠️ REMPLACE CES VALEURS PAR TES VRAIES CREDENTIALS FIREBASE
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-vitae-project',
    storageBucket: 'your-vitae-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-vitae-project',
    storageBucket: 'your-vitae-project.appspot.com',
    iosBundleId: 'com.vitae.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-vitae-project',
    storageBucket: 'your-vitae-project.appspot.com',
    authDomain: 'your-vitae-project.firebaseapp.com',
  );
}
