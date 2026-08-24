import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the Aspect Navigator Firebase Project:
/// Project ID: `flowing-garage-481412-p2`
class DefaultFirebaseOptions {
  static const String projectId = 'flowing-garage-481412-p2';

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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:web:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    authDomain: '$projectId.firebaseapp.com',
    storageBucket: '$projectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:android:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:ios:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
    iosBundleId: 'com.aspect.chumleynavigator',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:ios:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
    iosBundleId: 'com.aspect.chumleynavigator',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:web:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemoDummyApiKeyFlowingGarage481412',
    appId: '1:100000000000:web:flowinggarage481412',
    messagingSenderId: '100000000000',
    projectId: projectId,
    storageBucket: '$projectId.appspot.com',
  );
}
