import 'package:flutter/material.dart';

import 'app_info.dart';
import 'data/fav_store.dart';
import 'data/jap_store.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JapStore.instance.load();
  await FavStore.instance.load();
  runApp(const ShivDarshanApp());
}

class ShivDarshanApp extends StatefulWidget {
  const ShivDarshanApp({super.key});

  @override
  State<ShivDarshanApp> createState() => _ShivDarshanAppState();
}

class _ShivDarshanAppState extends State<ShivDarshanApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ऐप पीछे जाते या बंद होते समय जाप तुरंत सेव करें,
  // और वापस खुलने पर तारीख के हिसाब से स्क्रीन ताज़ा करें।
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      JapStore.instance.refresh();
    } else {
      JapStore.instance.flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
