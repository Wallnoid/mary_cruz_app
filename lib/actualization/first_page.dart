import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/candidates/ui/pages/candidates_page.dart';
//import 'package:launch_review/launch_review.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/home/ui/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

const String appVersionLocal = "0.0.1"; // Version actual de la app local

openStore() {
  //LaunchReview.launch(androidAppId: 'com.mary.cruz.uta', iOSAppId: '');
  openApkPure('com.mary.cruz.uta');

}

void openApkPure(String packageName) async {
  final url = 'https://marycruzuta.com/apk/marycruzapp.apk';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'No se pudo abrir $url';
  }
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );



    var connectivityResult = resultConnectivity();
        

    if (connectivityResult == ConnectivityResult.mobile || 
          connectivityResult == ConnectivityResult.wifi) {

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await _checkAppVersion(
                context); // Verificar la versión después de la construcción
          });
    }
  }


  resultConnectivity()async{
    return await (Connectivity().checkConnectivity());
  }

  Future<void> _checkAppVersion(BuildContext context) async {
    String appVersionServerConfiguraciones = _recoveryInfoServer();
    if (appVersionLocal != appVersionServerConfiguraciones) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const DialogMostrar(
              Icons.assignment_returned,
              "Actualización de App",
              "Para seguir utilizando la app, debe descargar la actualización.",
              openStore);
        },
      );
    }
  }

  String _recoveryInfoServer() {
    ConfigController configController =
        Get.put(ConfigController(), permanent: true);
    return configController.currentVersionIos.value;
  }

  @override
  Widget build(BuildContext context) {
    
    return  const CandidatesPage(); //HomePage(); // Renderiza el HomePage sin lógica de verificación en el build
  }
}

class DialogMostrar extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const DialogMostrar(this.icon, this.title, this.message, this.onConfirm,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: const Text('Actualizar'),
        ),
      ],
    );
  }
}
