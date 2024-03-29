// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtQx7NZWTB-8BiLr5NaYUQOPLbahev9t8',
    appId: '1:951067472722:android:6ef7d47a240f2ed9e2808b',
    messagingSenderId: '951067472722',
    projectId: 'we-chat-75459',
    storageBucket: 'we-chat-75459.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbai88-a1F9NDvQ1CjCJBY6Up6M72moxU',
    appId: '1:951067472722:ios:8cff9caa6bcb7d49e2808b',
    messagingSenderId: '951067472722',
    projectId: 'we-chat-75459',
    storageBucket: 'we-chat-75459.appspot.com',
    androidClientId: '951067472722-lde0iv3j3qbq1s2hta8msptjdpuuhmpd.apps.googleusercontent.com',
    iosClientId: '951067472722-g95tltuqffsl779rlj3lsp0u9u6240or.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterWeChat',
  );
}
