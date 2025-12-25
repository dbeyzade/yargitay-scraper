import 'package:flutter/material.dart';

import 'home_screen_backup.dart' as backup;

/// Restores the older (stable) dashboard UI from `home_screen_backup.dart`.
/// Keeps existing routes/imports that reference `HomeScreen` intact.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const backup.HomeScreen();
  }
}
