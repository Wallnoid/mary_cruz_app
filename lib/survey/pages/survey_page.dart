import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/core/enums/sidebar.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/core/ui/components/custom_charge_alert.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/sidebar.dart';
import 'package:mary_cruz_app/core/utils/cellphone_info.dart';
import 'package:mary_cruz_app/survey/components/survey_item.dart';
import 'package:mary_cruz_app/survey/controllers/survey_controller.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  SurveyController controller = Get.put(SurveyController(), permanent: true);
  ConfigController configController = Get.find();
  String idDevice = '';
  bool canSend = false;
  String selectedOption = '';

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    controller.getQuestions();
    controller.getSurveyName();
    // Código de inicialización
    getDeviceIdN();
  }

  send() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const CustomChargeAlert(
              message: 'Enviando respuestas...',
            ));

    bool respond = await controller.sendAnswers(idDevice);

    Navigator.of(context).pop();
    if (respond) {
      Get.offNamed('/candidates');

      return;
    }
  }

  getDeviceIdN() async {
    idDevice = await getDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SafeArea(
        child: Scaffold(
          floatingActionButton: !configController.isCompletedSurvey.value
              ? FloatingActionButton(
                  onPressed: () {
                    send();
                  },
                  child: const Icon(Icons.send),
                )
              : null,
          appBar: CustomAppbar(
            title: 'Encuestas',
          ),
          drawer: const GlobalSidebar(
            selectedIndex: SideBar.survey,
          ),
          body: !configController.isCompletedSurvey.value
              ? SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text('Queremos saber\ntu Opinión!',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                  )),
                          const SizedBox(height: 15),
                          Text.rich(
                            TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.normal,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                              text:
                                  'Contesta las siguientes preguntas de la encuesta "',
                              children: <TextSpan>[
                                TextSpan(
                                  text: controller.surveyName.value,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                const TextSpan(
                                  text: '" para ayudarnos a mejorar!',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),
                          controller.questions.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Column(
                                  // Usa Column o ListView para mostrar los widgets
                                  children: controller.questions
                                      .map<Widget>((question) {
                                    int index =
                                        controller.questions.indexOf(question);
                                    return SurveyItem(
                                      question: question,
                                      questionIndex: index + 1,
                                      onSelectedOption: controller.addAnswer,
                                      isSelected: controller.getNameAnswer,
                                    );
                                  }).toList(),
                                ),
                        ],
                      )))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Tus respuestas han sido enviadas con éxito!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.tertiary,
                                )),
                        const SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.favorite,
                          color: Theme.of(context).colorScheme.primary,
                          size: 50,
                        )
                      ],
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
