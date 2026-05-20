import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Diese App ist nur für Web konfiguriert.');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDANW8wnEyI1YHLIXlZ-90YlNsyjGOBSVE',
    appId: '1:912101123222:web:39d5ab7cfcde12686c8eb7',
    messagingSenderId: '912101123222',
    projectId: 'goldpriceapp-63d52',
    authDomain: 'goldpriceapp-63d52.firebaseapp.com',
    storageBucket: 'goldpriceapp-63d52.firebasestorage.app',
    measurementId: 'G-XJQ93HJLK3',
  );
}
