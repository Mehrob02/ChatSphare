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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
       return  windows;
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

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWdmq7Ow8AoDIs3NPV9byEtyktdztMqPU',
    appId: '1:945299288871:web:21dcfaed6022471fefef02',
    messagingSenderId: '945299288871',
    projectId: 'chatsphere-bbc53',
    authDomain: 'chatsphere-bbc53.firebaseapp.com',
    storageBucket: 'chatsphere-bbc53.appspot.com',
    measurementId: 'G-6SKSVVZE9G',
  );

  

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB0yEshySGjdrGvsfmB73BG_0mlfOr4BFc',
    appId: '1:945299288871:android:4060943c09c1de3aefef02',
    messagingSenderId: '945299288871',
    projectId: 'chatsphere-bbc53',
    storageBucket: 'chatsphere-bbc53.appspot.com',
  );
static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0yEshySGjdrGvsfmB73BG_0mlfOr4BFc',
    appId: '1:945299288871:android:4060943c09c1de3aefef02',
    messagingSenderId: '945299288871',
    projectId: 'chatsphere-bbc53',
    storageBucket: 'chatsphere-bbc53.appspot.com',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMhDpAZxuzZyvfymwuh_pU_9C_06YWpn4',
    appId: '1:945299288871:ios:c98fbebb53a1ea34efef02',
    messagingSenderId: '945299288871',
    projectId: 'chatsphere-bbc53',
    storageBucket: 'chatsphere-bbc53.appspot.com',
    iosBundleId: 'com.example.chatsphere',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDMhDpAZxuzZyvfymwuh_pU_9C_06YWpn4',
    appId: '1:945299288871:ios:c98fbebb53a1ea34efef02',
    messagingSenderId: '945299288871',
    projectId: 'chatsphere-bbc53',
    storageBucket: 'chatsphere-bbc53.appspot.com',
    iosBundleId: 'com.example.chatsphere',
  );

}