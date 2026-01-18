import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (e) {
      // Fallback to UTC if timezone not found
      tz.setLocalLocation(tz.UTC);
    }

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'eye_exercises',
      'Göz Egzersizleri',
      description: 'Günlük göz egzersizi hatırlatıcıları',
      importance: Importance.defaultImportance,
    );

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
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

    // Create notification channel for Android
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(androidChannel);
    }

    _initialized = true;
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
    // Get notification content based on profile and type
    final (title, body) = _getNotificationContent(profile, type: type);

    // Schedule notification
    // Use title as body if body is empty (for single-line messages)
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

  /// Get notification content based on profile and type
  (String, String) _getNotificationContent(String profile, {String type = 'daily'}) {
    final messages = _getNotificationMessages(profile, type);
    if (messages.isEmpty) {
      return ('👁️ Göz Egzersizi', 'Günlük egzersizlerinizi yapmayı unutmayın');
    }
    
    // Randomly select a message
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    final selected = messages[random];
    // If body is empty, use title as both
    return (selected.$1, selected.$2.isEmpty ? selected.$1 : selected.$2);
  }

  /// Get notification messages based on profile and type
  List<(String, String)> _getNotificationMessages(String profile, String type) {
    if (type == 'daily') {
      return _getDailyReminderMessages();
    } else if (type == 'missed') {
      return _getMissedReminderMessages();
    } else if (type == 'motivation') {
      return _getMotivationMessages();
    }
    return _getDailyReminderMessages();
  }

  /// Daily reminder messages (14 adet)
  List<(String, String)> _getDailyReminderMessages() {
    return [
      ('👁️ Gözlerin bugün küçük bir mola istiyor', ''),
      ('👀 Ekrandan kısa bir ara vermek ister misin?', ''),
      ('✨ 1 dakikalık göz egzersiziyle rahatla', ''),
      ('🌿 Gözlerini dinlendirme zamanı', ''),
      ('💆‍♂️ Bugünkü göz egzersizin hazır', ''),
      ('🧘‍♀️ Kısa bir mola, daha net bir bakış', ''),
      ('👁️ Günlük göz egzersizini yapmak ister misin?', ''),
      ('🔄 Odağını yenilemek için iyi bir an', ''),
      ('🌙 Günün yorgunluğunu gözlerinden atalım', ''),
      ('💡 Gözlerini rahatlatmak için 1 dakika yeter', ''),
      ('👀 Göz sağlığın için küçük bir adım', ''),
      ('🌱 Bugün de gözlerine iyi bak', ''),
      ('⏱️ Sadece 1–2 dakikan var mı?', ''),
      ('😊 Gözlerin sana teşekkür edecek', ''),
    ];
  }

  /// Missed/Soft reminder messages (12 adet)
  List<(String, String)> _getMissedReminderMessages() {
    return [
      ('🌱 Sorun değil, hazır olduğunda buradayız', ''),
      ('😊 Bugün de gözlerine bakabilirsin', ''),
      ('👁️ Egzersizler seni bekliyor', ''),
      ('🌿 Küçük bir mola hâlâ mümkün', ''),
      ('🧘‍♂️ Ne zaman istersen başla', ''),
      ('👀 Gözlerini dinlendirmek için geç değil', ''),
      ('🌙 Sakin bir an yakaladığında açabilirsin', ''),
      ('💚 Kendine ayıracağın kısa bir an', ''),
      ('👁️ Bugün atladıysan yarın devam edebilirsin', ''),
      ('🌱 Göz egzersizleri her zaman burada', ''),
      ('😊 Hazır olduğunda seni bekliyoruz', ''),
      ('✨ Küçük adımlar da yeterli', ''),
    ];
  }

  /// Motivation/Appreciation messages (12 adet)
  List<(String, String)> _getMotivationMessages() {
    return [
      ('👏 Bu hafta gözlerine iyi baktın', ''),
      ('🌟 Harika gidiyorsun, devam etmek ister misin?', ''),
      ('👁️ Göz egzersizlerinde güzel bir rutin oluşturdun', ''),
      ('💚 Kendine ayırdığın bu zaman çok değerli', ''),
      ('🧘‍♀️ Düzenli molalar fark yaratır', ''),
      ('🌿 Gözlerine gösterdiğin özen için tebrikler', ''),
      ('😊 Küçük alışkanlıklar büyük rahatlama sağlar', ''),
      ('👀 Odağını korumak için güzel bir adım', ''),
      ('✨ İstikrarlı devam ediyorsun', ''),
      ('💡 Göz sağlığına yatırım yapıyorsun', ''),
      ('🌱 Bugüne kadar çok iyi geldin', ''),
      ('👏 Devam etmek ister misin?', ''),
    ];
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
