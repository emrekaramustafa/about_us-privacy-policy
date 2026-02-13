import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Locale, TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Notification Service
/// Manages eye exercise reminder notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service.
  /// Açılışta çağrılmıyor; kullanıcı bildirime "Hayır" dediyse iOS'ta çökme olmaması için
  /// sadece bildirim ayarları / hatırlatıcı açıldığında lazy-initialize edilir.
  /// İzin reddedilmiş olsa bile hata fırlatmaz, _initialized sadece başarıda true olur.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      } catch (e) {
        tz.setLocalLocation(tz.UTC);
      }

      // Create Android notification channel
      const androidChannel = AndroidNotificationChannel(
        'eye_exercises',
        'Göz Egzersizleri',
        description: 'Günlük göz egzersizi hatırlatıcıları',
        importance: Importance.defaultImportance,
      );

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.createNotificationChannel(androidChannel);
      }

      _initialized = true;
    } catch (e, st) {
      // İzin reddedildi veya plugin hatası: uygulama kapanmasın, sadece logla
      debugPrint('NotificationService.initialize error: $e');
      debugPrint('$st');
      _initialized = false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    // Android 13+ requires runtime permission
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS permissions are requested in initialization
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Get notification time (default: 16:30)
  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notification_hour') ?? 16;
    final minute = prefs.getInt('notification_minute') ?? 30;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Set notification time (08:00 - 22:30)
  Future<void> setNotificationTime(TimeOfDay time) async {
    // Validate time range
    if (time.hour < 8 || (time.hour == 22 && time.minute > 30) || time.hour > 22) {
      throw Exception('Bildirim saati 08:00 - 22:30 arasında olmalıdır');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
    
    await scheduleDailyReminder();
  }

  /// Get user's selected profile
  Future<String?> getSelectedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_profile');
  }

  /// Set user's selected profile
  Future<void> setSelectedProfile(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_profile', profile);
    await scheduleDailyReminder();
  }

  /// Check if exercise was completed today
  Future<bool> wasExerciseCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompletedDate = prefs.getString('last_exercise_date');
    if (lastCompletedDate == null) return false;
    
    final lastDate = DateTime.parse(lastCompletedDate);
    final today = DateTime.now();
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }

  /// Mark exercise as completed today
  Future<void> markExerciseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('last_exercise_date', now.toIso8601String());
    
    // Save exercise history (for motivation notifications)
    final history = prefs.getStringList('exercise_history') ?? [];
    history.add(now.toIso8601String());
    // Keep only last 30 days
    if (history.length > 30) {
      history.removeRange(0, history.length - 30);
    }
    await prefs.setStringList('exercise_history', history);
    
    // Cancel today's notification if not sent yet
    await _notifications.cancel(1);
  }

  /// Get exercise count in last 7 days
  Future<int> getExerciseCountLast7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('exercise_history') ?? [];
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    int count = 0;
    for (final dateStr in history) {
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(sevenDaysAgo)) {
          count++;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }
    return count;
  }

  /// Check if motivation notification should be sent
  Future<bool> shouldSendMotivationNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMotivationDate = prefs.getString('last_motivation_date');
    
    // Check if we sent motivation notification this week
    if (lastMotivationDate != null) {
      final lastDate = DateTime.parse(lastMotivationDate);
      final now = DateTime.now();
      final daysSince = now.difference(lastDate).inDays;
      if (daysSince < 7) {
        return false; // Already sent this week
      }
    }
    
    // Check if user completed at least 3 exercises in last 7 days
    final count = await getExerciseCountLast7Days();
    return count >= 3;
  }

  /// Schedule motivation notification (weekly, max 1)
  Future<void> scheduleMotivationNotification() async {
    if (!_initialized) await initialize();
    
    final enabled = await areNotificationsEnabled();
    if (!enabled) return;

    final shouldSend = await shouldSendMotivationNotification();
    if (!shouldSend) return;

    final profile = await getSelectedProfile() ?? 'adult';
    final time = await getNotificationTime();
    
    // Schedule for tomorrow at notification time
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(const Duration(days: 1));

    // Cancel existing motivation notification
    await _notifications.cancel(2);

    await _scheduleNotification(tomorrow, profile, type: 'motivation');
    
    // Mark as sent
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_motivation_date', DateTime.now().toIso8601String());
  }

  /// Check if exercise was missed yesterday
  Future<bool> wasExerciseMissedYesterday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompletedDate = prefs.getString('last_exercise_date');
    if (lastCompletedDate == null) return true;
    
    final lastDate = DateTime.parse(lastCompletedDate);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return lastDate.year != yesterday.year ||
           lastDate.month != yesterday.month ||
           lastDate.day != yesterday.day;
  }

  /// Schedule missed/soft reminder notification (next day morning, no pressure)
  Future<void> scheduleMissedReminder() async {
    if (!_initialized) await initialize();
    
    final enabled = await areNotificationsEnabled();
    if (!enabled) return;

    // Only schedule if exercise was missed yesterday
    final wasMissed = await wasExerciseMissedYesterday();
    if (!wasMissed) return;

    // Check if we already sent missed reminder today
    final prefs = await SharedPreferences.getInstance();
    final lastMissedDate = prefs.getString('last_missed_reminder_date');
    if (lastMissedDate != null) {
      final lastDate = DateTime.parse(lastMissedDate);
      final today = DateTime.now();
      if (lastDate.year == today.year &&
          lastDate.month == today.month &&
          lastDate.day == today.day) {
        return; // Already sent today
      }
    }

    final profile = await getSelectedProfile() ?? 'adult';
    final time = await getNotificationTime();
    
    // Schedule for tomorrow morning (1 hour after notification time, or 9:00 if earlier)
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour < 9 ? 9 : time.hour + 1,
      time.minute,
    ).add(const Duration(days: 1));

    // Cancel existing missed reminder notification
    await _notifications.cancel(3);

    await _scheduleNotification(tomorrow, profile, type: 'missed');
    
    // Mark as sent
    await prefs.setString('last_missed_reminder_date', DateTime.now().toIso8601String());
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder() async {
    if (!_initialized) await initialize();
    
    final enabled = await areNotificationsEnabled();
    if (!enabled) {
      await cancelAllNotifications();
      return;
    }

    final time = await getNotificationTime();
    final profile = await getSelectedProfile() ?? 'adult';

    // Cancel existing notification
    await _notifications.cancel(1);

    // Check if exercise was already completed today
    final wasCompleted = await wasExerciseCompletedToday();
    
    // If exercise was completed today, don't schedule notification
    if (wasCompleted) {
      // Schedule for tomorrow instead
      final now = tz.TZDateTime.now(tz.local);
      final tomorrow = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      ).add(const Duration(days: 1));
      
      await _scheduleNotification(tomorrow, profile, type: 'daily');
    } else {
      // Schedule for today or tomorrow based on current time
      final scheduledTime = _nextInstanceOfTime(time.hour, time.minute);
      await _scheduleNotification(scheduledTime, profile, type: 'daily');
    }
    
    // Check and schedule motivation notification if needed
    await scheduleMotivationNotification();
    
    // Check and schedule missed reminder if needed (soft, no pressure)
    await scheduleMissedReminder();
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification(tz.TZDateTime scheduledDate, String profile, {String type = 'daily'}) async {
    // Get notification content (localized) based on profile and type
    final (title, body) = await _getNotificationContent(profile, type: type);

    // Schedule notification
    final notificationBody = body.isEmpty ? title : body;
    final notificationId = type == 'motivation' ? 2 : (type == 'missed' ? 3 : 1);
    await _notifications.zonedSchedule(
      notificationId,
      title,
      notificationBody,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eye_exercises',
          'Göz Egzersizleri',
          channelDescription: 'Günlük göz egzersizi hatırlatıcıları',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static const String _localeKey = 'app_locale';

  /// Get notification content (localized) based on profile and type
  Future<(String, String)> _getNotificationContent(String profile, {String type = 'daily'}) async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    final locale = Locale(localeCode);
    AppLocalizations l10n;
    try {
      l10n = await AppLocalizations.delegate.load(locale);
    } catch (_) {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    }
    final length = type == 'daily' ? 14 : 12;
    final index = DateTime.now().millisecondsSinceEpoch % length;
    return _getNotificationMessage(l10n, type, index);
  }

  /// Map (type, index) to (title, body) from l10n
  (String, String) _getNotificationMessage(AppLocalizations l10n, String type, int index) {
    switch (type) {
      case 'daily':
        switch (index) {
          case 0: return (l10n.notifDaily1Title, l10n.notifDaily1Body);
          case 1: return (l10n.notifDaily2Title, l10n.notifDaily2Body);
          case 2: return (l10n.notifDaily3Title, l10n.notifDaily3Body);
          case 3: return (l10n.notifDaily4Title, l10n.notifDaily4Body);
          case 4: return (l10n.notifDaily5Title, l10n.notifDaily5Body);
          case 5: return (l10n.notifDaily6Title, l10n.notifDaily6Body);
          case 6: return (l10n.notifDaily7Title, l10n.notifDaily7Body);
          case 7: return (l10n.notifDaily8Title, l10n.notifDaily8Body);
          case 8: return (l10n.notifDaily9Title, l10n.notifDaily9Body);
          case 9: return (l10n.notifDaily10Title, l10n.notifDaily10Body);
          case 10: return (l10n.notifDaily11Title, l10n.notifDaily11Body);
          case 11: return (l10n.notifDaily12Title, l10n.notifDaily12Body);
          case 12: return (l10n.notifDaily13Title, l10n.notifDaily13Body);
          case 13: return (l10n.notifDaily14Title, l10n.notifDaily14Body);
          default: return (l10n.notifDefaultTitle, l10n.notifDefaultBody);
        }
      case 'missed':
        switch (index) {
          case 0: return (l10n.notifMissed1Title, l10n.notifMissed1Body);
          case 1: return (l10n.notifMissed2Title, l10n.notifMissed2Body);
          case 2: return (l10n.notifMissed3Title, l10n.notifMissed3Body);
          case 3: return (l10n.notifMissed4Title, l10n.notifMissed4Body);
          case 4: return (l10n.notifMissed5Title, l10n.notifMissed5Body);
          case 5: return (l10n.notifMissed6Title, l10n.notifMissed6Body);
          case 6: return (l10n.notifMissed7Title, l10n.notifMissed7Body);
          case 7: return (l10n.notifMissed8Title, l10n.notifMissed8Body);
          case 8: return (l10n.notifMissed9Title, l10n.notifMissed9Body);
          case 9: return (l10n.notifMissed10Title, l10n.notifMissed10Body);
          case 10: return (l10n.notifMissed11Title, l10n.notifMissed11Body);
          case 11: return (l10n.notifMissed12Title, l10n.notifMissed12Body);
          default: return (l10n.notifDefaultTitle, l10n.notifDefaultBody);
        }
      case 'motivation':
        switch (index) {
          case 0: return (l10n.notifMotivation1Title, l10n.notifMotivation1Body);
          case 1: return (l10n.notifMotivation2Title, l10n.notifMotivation2Body);
          case 2: return (l10n.notifMotivation3Title, l10n.notifMotivation3Body);
          case 3: return (l10n.notifMotivation4Title, l10n.notifMotivation4Body);
          case 4: return (l10n.notifMotivation5Title, l10n.notifMotivation5Body);
          case 5: return (l10n.notifMotivation6Title, l10n.notifMotivation6Body);
          case 6: return (l10n.notifMotivation7Title, l10n.notifMotivation7Body);
          case 7: return (l10n.notifMotivation8Title, l10n.notifMotivation8Body);
          case 8: return (l10n.notifMotivation9Title, l10n.notifMotivation9Body);
          case 9: return (l10n.notifMotivation10Title, l10n.notifMotivation10Body);
          case 10: return (l10n.notifMotivation11Title, l10n.notifMotivation11Body);
          case 11: return (l10n.notifMotivation12Title, l10n.notifMotivation12Body);
          default: return (l10n.notifDefaultTitle, l10n.notifDefaultBody);
        }
      default:
        return (l10n.notifDefaultTitle, l10n.notifDefaultBody);
    }
  }

  /// Calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to exercise info page when notification is tapped
    // This will be handled by the app router
  }

  /// Get notification permission status
  Future<bool> checkPermissionStatus() async {
    if (!_initialized) await initialize();

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }

    // For iOS, check if we can schedule notifications
    return true;
  }
}
