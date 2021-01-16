import 'dart:convert';
import 'dart:io';

import 'package:fluffychat/app_config.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:famedlysdk/famedlysdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluffychat/components/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/l10n_en.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unified_push/unified_push.dart';
import 'package:http/http.dart' as http;

import '../components/matrix.dart';
import '../config/setting_keys.dart';
import 'famedlysdk_store.dart';
import 'matrix_locals.dart';

abstract class FirebaseController {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static BuildContext context;

  static Future<void> setupFirebase(
      MatrixState matrix, String clientName) async {
    if (!PlatformInfos.isMobile) return;
    if (Platform.isIOS) iOS_Permission();

    Function goToRoom = (dynamic message) async {
      try {
        String roomId;
        if (message is String && message[0] == '{') {
          message = json.decode(message);
        }
        if (message is String) {
          roomId = message;
        } else if (message is Map) {
          roomId = (message['notification'] ??
              message['data'] ??
              message)['room_id'];
        }
        if (roomId?.isEmpty ?? true) throw ('Bad roomId');
        await matrix.widget.apl.currentState
            .pushNamedAndRemoveUntilIsFirst('/rooms/${roomId}');
      } catch (_) {
        await FlushbarHelper.createError(message: 'Failed to open chat...')
            .show(context);
        rethrow;
      }
    };

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notifications_icon');
    var initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: (i, a, b, c) {
      return null;
    });
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: goToRoom);

    String fcmToken;
    try {
      fcmToken = await _firebaseMessaging.getToken();
    } catch (_) {
      fcmToken = null;
    }
    if (fcmToken?.isEmpty ?? true) {
      await setupUnifiedPush(matrix, clientName);
      return;
    }
    await setupPusher(
        matrix, clientName, AppConfig.pushNotificationsGatewayUrl, fcmToken);

    _firebaseMessaging.configure(
      onMessage: _onMessage,
      onBackgroundMessage: _onMessage,
      onResume: goToRoom,
      onLaunch: goToRoom,
    );
    Logs().i('[Push] Firebase initialized');
  }

  static Future<void> setupPusher(MatrixState matrix, String clientName,
      String gatewayUrl, String token) async {
    final client = matrix.client;
    final pushers = await client.requestPushers().catchError((e) {
      Logs().w('[Push] Unable to request pushers', e);
      return <Pusher>[];
    });
    final currentPushers = pushers.where((pusher) => pusher.pushkey == token);
    if (currentPushers.length == 1 &&
        currentPushers.first.kind == 'http' &&
        currentPushers.first.appId == AppConfig.pushNotificationsAppId &&
        currentPushers.first.appDisplayName == clientName &&
        currentPushers.first.deviceDisplayName == client.deviceName &&
        currentPushers.first.lang == 'en' &&
        currentPushers.first.data.url.toString() == gatewayUrl &&
        currentPushers.first.data.format ==
            AppConfig.pushNotificationsPusherFormat) {
      Logs().i('[Push] Pusher already set');
    } else {
      if (currentPushers.isNotEmpty) {
        for (final currentPusher in currentPushers) {
          currentPusher.pushkey = token;
          currentPusher.kind = null;
          await client
              .setPusher(
            currentPusher,
            append: true,
          )
              .catchError((e) {
            Logs().w('[Push] Failed to remove old pusher', e);
          });
          Logs().i('[Push] Remove legacy pusher for this device');
        }
      }
      await client
          .setPusher(
        Pusher(
          token,
          AppConfig.pushNotificationsAppId,
          clientName,
          client.deviceName,
          'en',
          PusherData(
            url: Uri.parse(gatewayUrl),
            format: AppConfig.pushNotificationsPusherFormat,
          ),
          kind: 'http',
        ),
        append: false,
      )
          .catchError((e, s) {
        Logs().e('[Push] Unable to set pushers', e, s);
        return [];
      });
    }
  }

  static Future<void> onUnifiedPushMessage(String payload) async {
    try {
      final data = json.decode(payload);
      await _showDefaultNotification(data);
    } catch (e, s) {
      Logs().e('[Push] Failed to display message', e, s);
    }
  }

  static Future<void> setupUnifiedPush(
      MatrixState matrix, String clientName) async {
    final onUpdate = () async {
      if (UnifiedPush.registered) {
        var endpoint =
            'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify';
        try {
          final url = Uri.parse(UnifiedPush.endpoint)
              .replace(
                path: '/_matrix/push/v1/notify',
                query: '',
              )
              .toString()
              .split('?')
              .first;
          final res = json.decode(utf8.decode((await http.get(url)).bodyBytes));
          if (res['gateway'] == 'matrix') {
            endpoint = url;
          }
        } catch (e) {
          Logs().i('[Push] No self-hosted unified push gateway present: ' +
              UnifiedPush.endpoint);
        }
        Logs().i('[Push] UnifiedPush using endpoint ' + endpoint);
        await setupPusher(matrix, clientName, endpoint, UnifiedPush.endpoint);
        return;
      }
      final distributors = await UnifiedPush.distributors;
      if (distributors.isEmpty) {
        // unified push failed, show no google services error
        final storeItem = await matrix.store.getItem(SettingKeys.showNoGoogle);
        final configOptionMissing = storeItem == null || storeItem.isEmpty;
        if (configOptionMissing || (!configOptionMissing && storeItem == '1')) {
          await FlushbarHelper.createError(
            message: L10n.of(context).noGoogleServicesWarning,
            duration: Duration(seconds: 15),
          ).show(context);
          if (configOptionMissing) {
            await matrix.store.setItem(SettingKeys.showNoGoogle, '0');
          }
        }
        return;
      }
      await UnifiedPush.register(distributors.first);
    };

    await UnifiedPush.initialize(onUpdate, onUnifiedPushMessage);
  }

  static Future<dynamic> _onMessage(Map<String, dynamic> message) async {
    try {
      final data = message['notification'] ?? message['data'] ?? message;
      final String roomId = data['room_id'];
      final String eventId = data['event_id'];
      final int unread = data
          .tryGet<Map<String, dynamic>>(
              'counts', json.decode(data.tryGet<String>('counts', '{}')))
          .tryGet<int>('unread');
      if ((roomId?.isEmpty ?? true) ||
          (eventId?.isEmpty ?? true) ||
          unread == 0) {
        await _flutterLocalNotificationsPlugin.cancelAll();
        return null;
      }
      if (context != null && Matrix.of(context).activeRoomId == roomId) {
        Logs().i('[Push] New clearing push');
        return null;
      }
      Logs().i('[Push] New message received');
      // FIXME unable to init without context currently https://github.com/flutter/flutter/issues/67092
      // Locked on EN until issue resolved
      final i18n = context == null ? L10nEn() : L10n.of(context);

      // Get the client
      Client client;
      var tempClient = false;
      try {
        client = Matrix.of(context).client;
      } catch (_) {
        client = null;
      }
      if (client == null) {
        tempClient = true;
        final platform = kIsWeb ? 'Web' : Platform.operatingSystem;
        final clientName = 'FluffyChat $platform';
        client = Client(clientName, databaseBuilder: getDatabase)..init();
        Logs().i('[Push] Use a temp client');
        await client.onLoginStateChanged.stream
            .firstWhere((l) => l == LoginState.logged)
            .timeout(
              Duration(seconds: 5),
            );
      }

      // Get the room
      var room = client.getRoomById(roomId);
      if (room == null) {
        Logs().i('[Push] Wait for the room');
        await client.onRoomUpdate.stream
            .where((u) => u.id == roomId)
            .first
            .timeout(Duration(seconds: 5));
        Logs().i('[Push] Room found');
        room = client.getRoomById(roomId);
        if (room == null) return null;
      }

      // Get the event
      var event = await client.database.getEventById(client.id, eventId, room);
      if (event == null) {
        Logs().i('[Push] Wait for the event');
        final eventUpdate = await client.onEvent.stream
            .where((u) => u.content['event_id'] == eventId)
            .first
            .timeout(Duration(seconds: 5));
        Logs().i('[Push] Event found');
        event = Event.fromJson(eventUpdate.content, room);
        if (room == null) return null;
      }

      // Count all unread events
      var unreadEvents = 0;
      client.rooms
          .forEach((Room room) => unreadEvents += room.notificationCount);

      // Calculate title
      final title = unread > 1
          ? i18n.unreadMessagesInChats(
              unreadEvents.toString(), unread.toString())
          : i18n.unreadMessages(unreadEvents.toString());

      // Calculate the body
      final body = event.getLocalizedBody(
        MatrixLocals(i18n),
        withSenderNamePrefix: true,
        hideReply: true,
      );

      // The person object for the android message style notification
      final person = Person(
        name: room.getLocalizedDisplayname(MatrixLocals(i18n)),
        icon: room.avatar == null
            ? null
            : BitmapFilePathAndroidIcon(
                await downloadAndSaveAvatar(
                  room.avatar,
                  client,
                  width: 126,
                  height: 126,
                ),
              ),
      );

      // Show notification
      var androidPlatformChannelSpecifics = _getAndroidNotificationDetails(
        styleInformation: MessagingStyleInformation(
          person,
          conversationTitle: title,
          messages: [
            Message(
              body,
              event.originServerTs,
              person,
            )
          ],
        ),
        ticker: i18n.newMessageInFluffyChat,
      );
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      await _flutterLocalNotificationsPlugin.show(
          0,
          room.getLocalizedDisplayname(MatrixLocals(i18n)),
          body,
          platformChannelSpecifics,
          payload: roomId);

      if (tempClient) {
        await client.dispose();
        client = null;
        Logs().i('[Push] Temp client disposed');
      }
    } catch (e, s) {
      Logs().e('[Push] Error while processing notification', e, s);
      await _showDefaultNotification(message);
    }
    return null;
  }

  static Future<dynamic> _showDefaultNotification(
      Map<String, dynamic> message) async {
    try {
      var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      // Init notifications framework
      var initializationSettingsAndroid =
          AndroidInitializationSettings('notifications_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // FIXME unable to init without context currently https://github.com/flutter/flutter/issues/67092
      // Locked on en for now
      //final l10n = L10n(Platform.localeName);
      final l10n = L10nEn();

      // Notification data and matrix data
      Map<String, dynamic> data =
          message['notification'] ?? message['data'] ?? message;
      String eventID = data['event_id'];
      String roomID = data['room_id'];
      final unread = data
          .tryGet<Map<String, dynamic>>(
              'counts', json.decode(data.tryGet<String>('counts', '{}')))
          .tryGet<int>('unread', 1);
      await flutterLocalNotificationsPlugin.cancelAll();
      if (unread == 0 || roomID == null || eventID == null) {
        return;
      }

      // Display notification
      var androidPlatformChannelSpecifics = _getAndroidNotificationDetails();
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      final title = l10n.unreadChats(unread.toString());
      await flutterLocalNotificationsPlugin.show(
          1, title, l10n.openAppToReadMessages, platformChannelSpecifics,
          payload: roomID);
    } catch (e, s) {
      Logs().e('[Push] Error while processing background notification', e, s);
    }
    return Future<void>.value();
  }

  static Future<String> downloadAndSaveAvatar(Uri content, Client client,
      {int width, int height}) async {
    final thumbnail = width == null && height == null ? false : true;
    final tempDirectory = (await getTemporaryDirectory()).path;
    final prefix = thumbnail ? 'thumbnail' : '';
    var file =
        File('$tempDirectory/${prefix}_${content.toString().split("/").last}');

    if (!file.existsSync()) {
      final url = thumbnail
          ? content.getThumbnail(client, width: width, height: height)
          : content.getDownloadLink(client);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
    }

    return file.path;
  }

  static void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      Logs().i('Settings registered: $settings');
    });
  }

  static AndroidNotificationDetails _getAndroidNotificationDetails(
      {MessagingStyleInformation styleInformation, String ticker}) {
    final color =
        context != null ? Theme.of(context).primaryColor : Color(0xFF5625BA);

    return AndroidNotificationDetails(
      AppConfig.pushNotificationsChannelId,
      AppConfig.pushNotificationsChannelName,
      AppConfig.pushNotificationsChannelDescription,
      styleInformation: styleInformation,
      importance: Importance.max,
      priority: Priority.high,
      ticker: ticker,
      color: color,
    );
  }
}
