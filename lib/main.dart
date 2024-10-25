import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/core/config/routes/global_route_get.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/core/global_controllers/sidebar_controller.dart';
import 'package:mary_cruz_app/core/theme/theme_data/global_theme_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isConnected = await checkConnectivity();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Cambia el color aquí
      statusBarIconBrightness: Brightness.dark,
    ),
  );



  if (isConnected) {
    // Internet is available, initialize Firebase
    //firebase
    await Firebase.initializeApp(); // Initialize Firebase
    await initFcm();
    // firebase

    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.get('SUPABASE_URL'),
      anonKey: dotenv.get('SUPABASE_ANON_KEY'),
    );
  } else {
    // Handle offline scenario
    //print('No internet connection. Firebase will not be initialized.');
  }

  SidebarController controller = Get.put(SidebarController(), permanent: true);
  ConfigController configController =
      Get.put(ConfigController(), permanent: true);

  await configController.getCurrentVersion();
  await configController.getCurrentVersionIos();

  await controller.getSidebarOptions();
  await configController.getCurrentSurvey();
  await configController.isCompletedSurveyF();

  HttpOverrides.global = MyHttpOverrides();

  runApp(const MyApp());
}

Future<bool> checkConnectivity() async {
  List connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult.length == 0) {
    return false;
  }

  if (connectivityResult[0] == ConnectivityResult.mobile ||
      connectivityResult[0] == ConnectivityResult.wifi) {
    return await checkNet();
  }

  return false;
}

Future<bool> checkNet() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    return response.statusCode ==
        200; // Comprobamos si la respuesta fue exitosa
  } catch (e) {
    return false; // Si hay un error en la petición
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> createNotificationChannels() async {
  const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
    'partido_notificaciones',
    'notificaciones',
    description: 'Notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(callChannel);
}

Future<void> _showNotificationWithImage(
    RemoteNotification notification, String imageUrl) async {
  final ByteData imageData =
      await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
  final Uint8List bytess = imageData.buffer.asUint8List();
  final AndroidBitmap<Object> largeIcon = ByteArrayAndroidBitmap(bytess);

  BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
    largeIcon, // Usar NetworkImage para cargar desde una URL
    largeIcon: largeIcon, // Icono grande
    contentTitle: notification.title,
    summaryText: notification.body,
    htmlFormatContent: true,
    htmlFormatTitle: true,
  );

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'partido_notificaciones', 'notificaciones', importance: Importance.max,
    //'channel.id', 'channel.name',importance: Importance.max,
    priority: Priority.max,
    channelShowBadge: true,
    enableVibration: true,
    enableLights: true,
    showWhen: true,
    styleInformation: bigPictureStyleInformation,
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    notification.title,
    notification.body,
    platformChannelSpecifics,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the background message
  //print("Handling a background message: ${message.messageId}");
  // You can also show a local notification here if desired
}

Future<void> initFcm() async {
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings(); // ios
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    RemoteNotification? notification = message?.notification;
    AndroidNotification? android = message?.notification?.android;

    if (notification != null && android != null) {
      if (message!.data.isNotEmpty) {
        String imageUrl = message.data['image'];
        _showNotificationWithImage(notification, imageUrl);
      } else {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
            'partido_notificaciones', 'notificaciones',
            importance: Importance.max,
            //'channel.id', 'channel.name',importance: Importance.max,
            priority: Priority.max,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
            showWhen: true,
          )),
          payload: json.encode(message.data),
        );
      }
    }
  });

  createNotificationChannels();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        builder: (context, child) => GetMaterialApp(
              title: 'Mary Cruz App',
              themeMode: ThemeMode.light,
              theme: GlobalThemeData.lightThemeData,
              darkTheme: GlobalThemeData.darkThemeData,
              debugShowCheckedModeBanner: false,
              getPages: GlobalRouteGet.routes,
              initialRoute: GlobalRouteGet.initialRoute,
            ));
  }
}
