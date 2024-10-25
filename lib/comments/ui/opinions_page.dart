import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mary_cruz_app/comments/ui/widgets/age_custom_text_field.dart';
import 'package:mary_cruz_app/comments/ui/widgets/loading_dialog/loading_dialog.dart';
import 'package:mary_cruz_app/comments/controllers/loading_dialog_controller.dart';
import 'package:mary_cruz_app/comments/ui/widgets/terms_conditions_dialog.dart';
import 'package:mary_cruz_app/core/errors/failures.dart';
import 'package:mary_cruz_app/core/ui/components/custom_appbar.dart';
import 'package:mary_cruz_app/core/ui/components/custom_forms/custom_text_field.dart';
import '../../core/data/faculties_datasource.dart';
import '../../core/data/users_datasource.dart';
import '../../core/enums/sidebar.dart';
import '../../core/models/user_model.dart';
import '../../core/ui/components/custom_forms/custom_text_area.dart';
import '../../core/ui/components/custom_forms/dropdown.dart';
import '../../core/ui/components/sidebar.dart';
import '../../core/utils/cellphone_info.dart';
import '../../core/utils/cellphone_token.dart';
import '../controllers/opinions_controller.dart';

class OpinionsPage extends StatefulWidget {
  const OpinionsPage({
    super.key,
  });

  @override
  OpinionsPageState createState() => OpinionsPageState();
}

class OpinionsPageState extends State<OpinionsPage> {
  UserModel? userData;
  bool isLoading = true;
  bool userNotFound = false;
  OpinionsController opinionsController =
      Get.put(OpinionsController(), permanent: true);
  LoadingDialogController loadingDialogController =
      Get.put(LoadingDialogController(), permanent: true);

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  List<DropdownData> facultyData = [];

  List<DropdownData> personTypeData = [
    DropdownData(value: 'ESTUDIANTE', display: 'Estudiante'),
    DropdownData(value: 'ADMINISTRATIVO', display: 'Administrativo'),
    DropdownData(value: 'DOCENTE', display: 'Docente'),
  ];

  List<DropdownData> genreData = [
    DropdownData(value: 'M', display: 'Masculino'),
    DropdownData(value: 'F', display: 'Femenino'),
    DropdownData(value: 'O', display: 'Otro'),
  ];

  //controllers
  final facultyController = TextEditingController();
  final personTypeController = TextEditingController();
  final genreController = TextEditingController();
  final ageController = TextEditingController();
  final commentController = TextEditingController();

  ValueNotifier<String> statusNotifier = ValueNotifier<String>("Guardando...");

  // Errores
  String? facultyError;
  String? personTypeError;
  String? genreError;
  String? ageError;
  String? commentError;
  String? nameError;
  String? emailError;
  bool isError = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    getFacultyData();
    if (facultyData.isNotEmpty) {
      facultyController.text = facultyData[0].value;
    }
    _loadUserData();
    personTypeController.text = personTypeData[0].value;
    genreController.text = genreData[0].value;
  }

  void getFacultyData() async {
    try {
      final facultiesData = await FacultiesDataSource().getAllFaculties();
      setState(() {
        facultyData = facultiesData
            .map((faculty) => DropdownData(
                value: faculty.id.toString(), display: faculty.nombre))
            .toList();

        if (facultyData.isNotEmpty) {
          facultyController.text = facultyData[0].value;
        }
      });
    } catch (e) {
      print('Error al obtener las facultades');
      setState(() {
        isError = true;
      });
    }
  }

  void validateInputs() {
    setState(() {
      facultyError =
          facultyController.text.isEmpty ? 'Facultad es requerida' : null;
      personTypeError = personTypeController.text.isEmpty
          ? 'Tipo de persona es requerido'
          : null;
      genreError = genreController.text.isEmpty ? 'Género es requerido' : null;
      ageError = ageController.text.isEmpty
          ? 'Edad es requerida'
          : !RegExp(r'^(1[6-9]|[2-7][0-9]|80)$').hasMatch(ageController.text)
              ? 'Ingrese una edad entre 16 y 80 años'
              : null;
      commentError =
          commentController.text.isEmpty ? 'Comentario es requerido' : null;
    });
  }

  void validateUserInfo() {
    setState(() {
      emailError = emailController.text.isEmpty
          ? 'Correo es requerido'
          : !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(emailController.text)
              ? 'Ingrese un correo válido'
              : null;
    });
  }

  onSaveCommentWithoutPersonalInfo() async {
    loadingDialogController.isLoading(true);
    validateInputs();
    String deviceInfo = await getDeviceId();
    String userToken = await getToken();
    if (facultyError == null &&
        personTypeError == null &&
        genreError == null &&
        ageError == null &&
        commentError == null) {
      try {
        showLoadingDialog(context, statusNotifier);
        statusNotifier.value = 'Enviando Comentario...';
        await UsersDataSource().addUser(
            user: UserAndCommentModel(
          facultad: facultyController.text,
          tipoUsuario: personTypeController.text,
          genero: genreController.text,
          edad: int.parse(ageController.text),
          idDispositivo: deviceInfo,
          email: 'ANONYMOUS',
          tokenUser: userToken,
          opinion: commentController.text,
        ));
        print('El comentario ha sido enviado!');
        statusNotifier.value = 'Comentario enviado!';
        loadingDialogController.isLoading(false);
        print(LoadingDialogController().isProcessing);
      } on ServerFailure catch (e) {
        print('Error al enviar el comentario');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, corrija los errores en el formulario'),
      ));
    }
  }

  onSaveCommentWithPersonalInfo() async {
    loadingDialogController.isLoading(true);
    validateUserInfo();
    commentError =
        commentController.text.isEmpty ? 'Comentario es requerido' : null;
    if (nameError == null && emailError == null && commentError == null) {
      showLoadingDialog(context, statusNotifier);
      try {
        statusNotifier.value = 'Enviando Comentario...';
        String deviceInfo = await getDeviceId();
        String userToken = await getToken();
        statusNotifier.value = 'Enviando Comentario...';
        await UsersDataSource().addUser(
            user: UserAndCommentModel(
          facultad: facultyController.text,
          tipoUsuario: personTypeController.text,
          genero: genreController.text,
          edad: int.parse(ageController.text),
          idDispositivo: deviceInfo,
          email: emailController.text,
          tokenUser: userToken,
          opinion: commentController.text,
        ));
        if (!userNotFound) {
          final newInfoUser = userData?.copyWith(email: emailController.text);
          await UsersDataSource().updateUser(user: newInfoUser!);
        }
        print('El comentario ha sido enviado!');
        statusNotifier.value = 'Comentario enviado!';
        loadingDialogController.isLoading(false);
      } on ServerFailure catch (e) {
        //Cambiar Dialogo de acuerdo al error
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, corrija los errores en el formulario'),
      ));
    }
  }

  void showTermConditionsDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return TermsConditionsDialog(
          onAccept: () {
            if (opinionsController.personalDataOptionSelected.value == 'SI') {
              onSaveCommentWithPersonalInfo();
            } else {
              onSaveCommentWithoutPersonalInfo();
            }
          },
          onReject: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void showLoadingDialog(
      BuildContext context, ValueNotifier<String> statusNotifier) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CommentsLoadingDialog(
            statusNotifier: statusNotifier,
            onAccept: () {
              _loadUserData();
            },
            onReject: () {});
      },
    );
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String deviceInfo = await getDeviceId();
      final data =
          await UsersDataSource().getUserDataToComments(idDispositivo: deviceInfo);
      setState(() {
        userData = data;
        ageController.text = data.edad.toString();
      });
    } on NotFoundFailure catch (e) {
      setState(() {
        userNotFound = true;
      });
    } on ServerFailure catch (e) {
      print('Error del servidor: ${e.errorMessage}');
    } catch (e) {
      print('Error inesperado: $e');
    } finally {
      setState(() {
        isLoading = false; // Finalizamos la carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isLoading && isError) {
      return const Scaffold(
        appBar: CustomAppbar(
          title: 'Dinos, ¿qué piensas?',
        ),
        drawer: GlobalSidebar(
          selectedIndex: SideBar.opinions,
        ),
        body: Center(
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
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinos, ¿qué piensas?'),
      ),
      drawer: const GlobalSidebar(
        selectedIndex: SideBar.opinions,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            child: Column(children: [
              Dropdown(
                label: 'Facultad',
                getData: facultyData,
                value: '1',
                height: 50.0,
                expanded: true,
                onSelected: (String newValue) {
                  print('Nuevo valor seleccionado: $newValue');
                  facultyController.text = newValue;
                },
                enabled: userNotFound ? true : false,
              ),
              if (facultyError != null)
                Text(facultyError!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              Dropdown(
                label: 'Soy',
                getData: personTypeData,
                value: 'ESTUDIANTE',
                height: 50.0,
                expanded: true,
                onSelected: (String newValue) {
                  personTypeController.text = newValue;
                  print('Nuevo valor seleccionado: $newValue');
                },
                enabled: userNotFound ? true : false,
              ),
              if (personTypeError != null)
                Text(personTypeError!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Dropdown(
                      label: 'Género',
                      getData: genreData,
                      value: 'M',
                      height: 50.0,
                      expanded: true,
                      onSelected: (String newValue) {
                        genreController.text = newValue;
                        print('Nuevo valor seleccionado: $newValue');
                      },
                      enabled: userNotFound ? true : false,
                    ),
                  ),
                ],
              ),
              if (genreError != null)
                Text(genreError!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              InputColumn(
                  textField: AgeCustomTextField(
                    regex: RegExp(r'^\d+$'),
                    inputType: TextInputType.number,
                    fontSize: 14,
                    radius: 8,
                    valueController: ageController,
                    enabled: userNotFound ? true : false,
                  ),
                  title: 'Edad'),
              if (ageError != null)
                Text(ageError!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              CustomTextArea(
                  controller: commentController, label: 'Comentario'),
              if (commentError != null)
                Text(commentError!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              Column(
                children: [
                  Text(
                      'Desea registrar su correo electrónico para recibir noticias y temas de su interés? ',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Si'),
                          leading: Radio(
                            value: personalDataOptions[0],
                            groupValue: opinionsController
                                .personalDataOptionSelected.value,
                            onChanged: (value) {
                              opinionsController
                                  .changePersonalDataOption(value.toString());
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('No'),
                          leading: Radio(
                            value: personalDataOptions[1],
                            groupValue: opinionsController
                                .personalDataOptionSelected.value,
                            onChanged: (value) {
                              opinionsController
                                  .changePersonalDataOption(value.toString());
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Visibility(
                  visible:
                      opinionsController.personalDataOptionSelected.value ==
                          'SI',
                  child: Container(
                    child: Column(
                      children: [
                        InputColumn(
                            textField: CustomTextField(
                              regex: RegExp(r'^\d+$'),
                              inputType: TextInputType.text,
                              fontSize: 14,
                              radius: 8,
                              valueController: emailController,
                              enabled: true,
                            ),
                            title: 'Email'),
                        if (emailError != null)
                          Text(emailError!,
                              style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () async {
                      showTermConditionsDialog();
                    },
                    child: Text(
                      'GUARDAR',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  )),
                ],
              ),
            ]),
          ),
        );
      }),
    );
  }
}

class InputColumn extends StatelessWidget {
  final Widget textField;
  final String title;

  const InputColumn({super.key, required this.textField, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        textField,
      ],
    );
  }
}
