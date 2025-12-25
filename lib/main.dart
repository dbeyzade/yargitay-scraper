import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'services/break_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  Intl.defaultLocale = 'tr_TR';
  
  await Supabase.initialize(
    url: 'https://wievkhwncqmlfkdcjggp.supabase.co',
    anonKey: 'sb_publishable_h2jo1LhixnoO_TR8ye4MvQ_My2tsk1m',
  );
  
  runApp(const AvukatPortalApp());
}

final supabase = Supabase.instance.client;

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AvukatPortalApp extends StatefulWidget {
  const AvukatPortalApp({super.key});

  @override
  State<AvukatPortalApp> createState() => _AvukatPortalAppState();
}

class _AvukatPortalAppState extends State<AvukatPortalApp> {
  @override
  void initState() {
    super.initState();

    BreakReminderService.instance.init(navigatorKey: appNavigatorKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BreakReminderService.instance.start();
    });
  }

  @override
  void dispose() {
    BreakReminderService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Avukat Portal - Müvekkil Yönetim Sistemi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
