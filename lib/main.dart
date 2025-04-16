import 'package:droplet/pages/login/login.dart';
import 'package:droplet/pages/main/mainpage.dart';
import 'package:droplet/pages/splash/splash.dart';
import 'package:droplet/themes/theme_provider.dart';
import 'package:droplet/utils/api.dart';
import 'package:droplet/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize(DropletConfig.onesignalAppId);
  OneSignal.Notifications.requestPermission(true);

  runApp(
    ChangeNotifierProvider(create: ((context) => API()), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Droplet',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: themeProvider.lightScheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: themeProvider.darkScheme,
            ),
            themeMode: themeProvider.themeMode,
            home: const SplashPage(),
            routes: {
              '/main': (context) => const MainPage(),
              '/login': (context) => const LoginPage(),
            },
          );
        },
      ),
    );
  }
}
