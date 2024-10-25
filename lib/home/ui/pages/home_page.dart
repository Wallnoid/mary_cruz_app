import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/home/provider/diary_controller.dart';
import 'package:mary_cruz_app/home/ui/widgets/section_per_month.dart';
import 'package:mary_cruz_app/main.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DiaryController diaryController = Get.put(DiaryController(), permanent: true);

  bool conection = true;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    verificateConection();

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });

    diaryController.getDiary();
  }

  void verificateConection() async {
    conection = await checkConnectivity();

    if (conection) {
      _isAndroidPermissionGranted();
      _requestPermissions();
      initNotifications();
    }
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

  void _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.length == 0) {
      conection = false;
    } else {
      if (result[0] == ConnectivityResult.mobile ||
          result[0] == ConnectivityResult.wifi) {
        conection = await checkNet();
      } else {
        conection = false;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  resultConnectivity() async {
    return await (Connectivity().checkConnectivity());
  }

  initNotifications() async {
    ConfigController configController =
        Get.put(ConfigController(), permanent: true);
    await configController.saveUpdUser();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      configController.saveUpdUser();
    });
  }

  bool _notificationsEnabled = false;

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (diaryController.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!diaryController.isLoading.value && diaryController.error.value) {
        return const Scaffold(
          appBar: CustomAppbar(
            title: 'Agenda'//'Home',
          ),
          drawer: GlobalSidebar(
            selectedIndex: SideBar.agenda//SideBar.home,
          ),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Image.asset(
                      'lib/assets/logo2.png',
                      width: 200,
                      height: 150,
                    ),*/
                Text(
                  'Error de conexión',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('Inténtelo más tarde.')
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await diaryController.getDiary();
        },
        child: SafeArea(
          child: Scaffold(
              appBar: const CustomAppbar(
                title: "Agenda", /*'Home',*/
              ),
              drawer: const GlobalSidebar(
                selectedIndex: SideBar.agenda //SideBar.home,
              ),
              body: Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 0, bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'lib/assets/logo2.png',
                      width: 200,
                      height: 150,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Agenda',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.primary,
                      height: 0.1,
                      thickness: 1.5,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: diaryController.sectionsPerMonth.length,
                        itemBuilder: (context, index) {
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 25),
                            child: SectionPerMonth(
                              sectionPerMonth:
                                  diaryController.sectionsPerMonth[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )),
        ),
      );
    });
  }
}
