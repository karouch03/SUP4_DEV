import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmmw3Yd-VHjWucqxZKEopMDcDCuC3NIt8',
    appId: '1:605509919090:web:76c00d812534bb02ec3deb',
    messagingSenderId: '605509919090',
    projectId: 'sup4-dev-dc494',
    authDomain: 'sup4-dev-dc494.firebaseapp.com',
    storageBucket: 'sup4-dev-dc494.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // Optionnel
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmmw3Yd-VHjWucqxZKEopMDcDCuC3NIt8',
    appId: '1:605509919090:android:76c00d812534bb02ec3deb',
    messagingSenderId: '605509919090',
    projectId: 'sup4-dev-dc494',
    storageBucket: 'sup4-dev-dc494.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmmw3Yd-VHjWucqxZKEopMDcDCuC3NIt8',
    appId: '1:605509919090:ios:76c00d812534bb02ec3deb',
    messagingSenderId: '605509919090',
    projectId: 'sup4-dev-dc494',
    storageBucket: 'sup4-dev-dc494.firebasestorage.app',
    androidClientId:
        '605509919090-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosClientId:
        '605509919090-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.sup4Dev',
  );
}
