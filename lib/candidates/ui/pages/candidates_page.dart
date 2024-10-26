import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/candidates/provider/candidates_controller.dart';
import 'package:mary_cruz_app/candidates/ui/widgets/candidate_card.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/main.dart';

import 'package:http/http.dart' as http;

class CandidatesPage extends StatefulWidget {
  const CandidatesPage({super.key});

  @override
  State<CandidatesPage> createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  bool conection = true;

  CandidatesController controller =
      Get.put(CandidatesController(), permanent: true);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getCandidates();
    });
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
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (!controller.isLoading.value && controller.error.value) {
        return const Scaffold(
          appBar: CustomAppbar(
            title: 'Candidatos',
          ),
          drawer: GlobalSidebar(
            selectedIndex: SideBar.candidates,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error de conexión',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text('Inténtelo más tarde.')
                ],
              ),
            ),
          ),
        );
      }
      return SafeArea(
        child: Scaffold(
          appBar: const CustomAppbar(
            title: 'Candidatos',
          ),
          drawer: const GlobalSidebar(
            selectedIndex: SideBar.candidates,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Image.asset(
                    'lib/assets/unidos.png',
                    width: 200,
                    height: 150,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        //const SizedBox(height: 20),
                        //const SizedBox(height: 20),
                  
                        Column(
                          children: List<Widget>.from(
                            controller.candidates.map(
                              (x) => CandidateCard(
                                candidate: x,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
