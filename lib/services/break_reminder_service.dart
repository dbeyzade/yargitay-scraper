import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class BreakReminderService {
  BreakReminderService._();

  static final BreakReminderService instance = BreakReminderService._();

  static const coffeeImageAssetPath = 'assets/images/coffee_break.png';

  static const _firstReminderDelay = Duration(hours: 1);
  static const _fourHourMark = Duration(hours: 4);

  // Random interval candidates after the first reminder.
  static const List<Duration> _randomIntervals = <Duration>[
    Duration(hours: 1),
    Duration(hours: 1, minutes: 45),
    Duration(hours: 2), // 1 saat 60 dakika
    Duration(hours: 2, minutes: 30),
    Duration(hours: 3),
  ];

  final Random _random = Random();

  GlobalKey<NavigatorState>? _navigatorKey;
  DateTime? _startedAt;

  Timer? _coffeeTimer;
  Timer? _fourHourTimer;

  bool _dialogShowing = false;
  bool _started = false;

  void init({required GlobalKey<NavigatorState> navigatorKey}) {
    _navigatorKey = navigatorKey;
  }

  void start() {
    if (_started) return;
    _started = true;

    _startedAt = DateTime.now();

    _scheduleFourHourWarning();
    _scheduleCoffeeReminder(_firstReminderDelay);
  }

  void dispose() {
    _coffeeTimer?.cancel();
    _fourHourTimer?.cancel();
    _coffeeTimer = null;
    _fourHourTimer = null;
    _started = false;
    _dialogShowing = false;
    _startedAt = null;
  }

  void _scheduleFourHourWarning() {
    _fourHourTimer?.cancel();
    _fourHourTimer = Timer(_fourHourMark, () {
      _coffeeTimer?.cancel();
      _coffeeTimer = null;
      _showReminderDialog(
        title: 'Çok çalıştınız çok yoruldunuz kendinize zaman ayırın.',
        isFourHourWarning: true,
      );
    });
  }

  void _scheduleCoffeeReminder(Duration delay) {
    _coffeeTimer?.cancel();
    _coffeeTimer = Timer(delay, () {
      _showReminderDialog(
        title: 'Kahve Molası vermek istermisiniz,duyu ve algılarınız için bu önemlidir .',
        isFourHourWarning: false,
      );
    });
  }

  Future<void> _showReminderDialog({required String title, required bool isFourHourWarning}) async {
    if (_dialogShowing) return;

    final navigatorKey = _navigatorKey;
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    // If we already passed 4h, always show the 4h warning.
    final startedAt = _startedAt;
    if (!isFourHourWarning && startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed >= _fourHourMark) {
        _fourHourTimer?.cancel();
        _showReminderDialog(
          title: 'Çok çalıştınız çok yoruldunuz kendinize zaman ayırın.',
          isFourHourWarning: true,
        );
        return;
      }
    }

    _dialogShowing = true;

    final shouldLock = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final textStyle = Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.25,
            );

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220).withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      coffeeImageAssetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) {
                        return Container(
                          color: Colors.white.withOpacity(0.06),
                          alignment: Alignment.center,
                          child: Text(
                            'Görsel yüklenemedi',
                            style: Theme.of(c).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.70),
                                  fontSize: 12,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: textStyle?.copyWith(
                    color: Colors.white.withOpacity(0.90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        foregroundColor: Colors.white.withOpacity(0.85),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Hayır'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Evet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    _dialogShowing = false;

    if (shouldLock == true) {
      await _lockScreen();
      return;
    }

    // User chose to continue working.
    if (!isFourHourWarning) {
      final next = _randomIntervals[_random.nextInt(_randomIntervals.length)];
      _scheduleCoffeeReminder(next);
    }
  }

  Future<void> _lockScreen() async {
    if (!Platform.isMacOS) return;

    // Try the standard macOS lock shortcut: Control + Command + Q
    try {
      final result = await Process.run(
        'osascript',
        <String>[
          '-e',
          'tell application "System Events" to keystroke "q" using {control down, command down}'
        ],
      );
      if (result.exitCode == 0) return;
    } catch (_) {
      // ignore
    }

    // Fallback: put display to sleep.
    try {
      await Process.run('pmset', <String>['displaysleepnow']);
    } catch (_) {
      // ignore
    }
  }
}
