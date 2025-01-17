import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../shared/utils/media_utils.dart';
import '../../shared/secure_storage.dart';
import '../../shared/ui/colors.dart';
import '../api.dart';
import '/src/api/push_notifications/push_notifications_api.dart';
import 'models/models.dart';
import 'models/push_message_data.dart';

const String channelId = 'sama_messages_channel_id';
const String channelName = 'Sama messages';
const String channelDescription = 'Sama messages will be received here';

class PushNotificationsManager {
  static final PushNotificationsManager _instance =
      PushNotificationsManager._internal();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  PushNotificationsManager._internal() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  static PushNotificationsManager get instance => _instance;

  Function(String? payload)? onNotificationClicked;

  init() async {
    log('[PushNotificationsManager][init]');
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    flutterLocalNotificationsPlugin.cancelAll();

    await firebaseMessaging.requestPermission(
        alert: true, badge: true, sound: true);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        print(
            '[onDidReceiveNotificationResponse] payload: ${notificationResponse.payload}');
        var data = notificationResponse.payload;
        if (data != null) {
          if (onNotificationClicked != null) {
            onNotificationClicked?.call(data);
          }
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    firebaseMessaging.onTokenRefresh.listen((newToken) {
      _subscribePlatform(newToken);
    });

    //Foreground messages
    FirebaseMessaging.onMessage.listen((remoteMessage) {
      print('[onMessage] message: ${remoteMessage.data}');
      showNotification(PushMessageData.fromJson(remoteMessage.data));
    });

    // app is in pause state
    FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
      print('[onMessageOpenedApp] remoteMessage: $remoteMessage');
      onNotificationClicked?.call(jsonEncode(remoteMessage.data));
    });

    //for data messages
    flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((details) {
      String? payload = details!.notificationResponse?.payload;
      print("getNotificationAppLaunchDetails, payload: $payload");
      if (payload != null) {
        onNotificationClicked?.call(payload);
      }
    });

    //for notification messages
    FirebaseMessaging.instance.getInitialMessage().then((remoteMessage) {
      print("getInitialMessage, message: ${remoteMessage?.data}");
      if (remoteMessage?.data != null) {
        onNotificationClicked?.call(jsonEncode(remoteMessage?.data));
      }
    });
  }

  subscribe() {
    if (Platform.isAndroid || Platform.isIOS) {
      FirebaseMessaging.instance.getToken().then((token) {
        print('[getToken] token: $token');
        _subscribePlatform(token);
      }).catchError((onError) {
        print('[getToken] onError: $onError');
      });
    }
  }

  _subscribePlatform(String? token) async {
    print('[subscribe] token: $token');

    if (await SecureStorage.instance.getSubscriptionToken() == token) {
      print('[subscribe] skip subscription for same token');
      return;
    }

    String platform = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : '';

    String? deviceId = (await SecureStorage.instance.getLocalUser())?.deviceId;
    if (deviceId == null) {
      print('[subscribe] skip subscription for unregistered user');
      return;
    }
    print('[subscribe] subscription');

    createSubscription(platform, deviceId, token!).then((subscription) {
      print('[subscribe] subscription SUCCESS');
      SecureStorage.instance.saveSubscriptionToken(token);
    }).catchError((error) {
      print('[subscribe] subscription ERROR: $error');
    });
  }

  Future<void> unsubscribe() {
    return SecureStorage.instance.getLocalUser().then((user) {
      String? deviceId = user?.deviceId;
      if (deviceId != null) {
        return deleteSubscription(deviceId).whenComplete(() {
          FirebaseMessaging.instance.deleteToken();
        });
      }
      return Future.value();
    }).catchError((onError) {
      print('[unsubscribe] ERROR: $onError');
    });
  }

  Future<dynamic> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print(
        '[onDidReceiveLocalNotification] id: $id , title: $title, body: $body, payload: $payload');
    return Future.value();
  }
}

showNotificationIfAppPaused(PushMessageData data) {
  if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
    showNotification(data);
  }
}

showNotification(PushMessageData data) async {
  print('[showNotification] message: $data');
  if (data.cid == null) return;

  Future<NotificationDetails> buildNotificationDetails(
    int? badge,
    String threadIdentifier,
  ) async {
    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      badgeNumber: badge,
      threadIdentifier: threadIdentifier,
    );

    ByteArrayAndroidBitmap? bitmap;
    StyleInformation? styleInformation;
    if (data.firstAttachmentUrl != null) {
      var imageData = await loadImageBytesByUrl(data.firstAttachmentUrl!);
      //TODO RP temp solution while no attachment_type
      var isImage = await checkIfImageBytes(imageData);

      if (isImage) {
        bitmap =
            ByteArrayAndroidBitmap.fromBase64String(base64Encode(imageData));
      } else {
        var bytes = await getVideoThumbnailBytesByUrl(data.firstAttachmentUrl!);
        bitmap = ByteArrayAndroidBitmap.fromBase64String(base64Encode(bytes!));
      }

      styleInformation = BigPictureStyleInformation(
        bitmap,
        hideExpandedLargeIcon: true,
        contentTitle: data.title,
        htmlFormatContentTitle: true,
        summaryText: '${isImage ? 'Image' : 'Video'} attachment',
        htmlFormatSummaryText: true,
      );
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: bitmap,
      showWhen: true,
      color: slateBlue,
      styleInformation: styleInformation,
    );

    return NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails);
  }

  // var badge = int.tryParse(data['badge'].toString());
  // var threadId = data['ios_thread_id'] ?? data['cid'] ?? 'ios_thread_id';

  FlutterLocalNotificationsPlugin().show(
    data.cid.hashCode,
    data.title ?? "Sama",
    data.body?.isNotEmpty == true
        ? data.body
        : data.firstAttachmentFileId != null || data.firstAttachmentUrl != null
            ? 'Media attachment'
            : 'message',
    await buildNotificationDetails(0, 'threadId'),
    payload: jsonEncode(data),
  );
}

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('[onBackgroundMessage] message: ${message.data}}');

  showNotification(PushMessageData.fromJson(message.data));
  // if (!Platform.isIOS) {
  //   updateBadgeCount(int.tryParse(message.data['badge'].toString()));
  // }
  return Future.value();
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  log('[notificationTapBackground] payload: ${notificationResponse.payload}');
}
