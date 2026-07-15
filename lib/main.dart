import 'package:flutter/material.dart';

import 'app/app.dart';
import 'di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is optional here — social sign-in uses the native Google/Apple
  // SDKs and the backend REST API, so we avoid a hard dependency on Firebase
  // configuration files. If you wire up Firebase Auth, initialise it here:
  //
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await configureDependencies();
  runApp(const LoginSystemApp());
}
