import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/data/users_datasource.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/cellphone_info.dart';
import '../../data/challenges_datasource.dart';
import '../../models/challenge_model.dart';
import '../../../core/errors/failures.dart';

class StepperDialog extends StatefulWidget {
  const StepperDialog({super.key});

  @override
  _StepperDialogState createState() => _StepperDialogState();
}

class _StepperDialogState extends State<StepperDialog> {
  int _currentStep = 0;

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // Llaves para los formularios
  final _infoFormKey = GlobalKey<FormState>();
  final _urlFormKey = GlobalKey<FormState>();

  String? _errorMessage; // Variable para almacenar el error

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> onSaveChallenge() async {
    try {
      String deviceInfo = await getDeviceId();
      final UserModel user =
          await UsersDataSource().getUserData(idDispositivo: deviceInfo);
      final ChallengeUserModel challengeUser = ChallengeUserModel(
        idUsuario: user.id ?? '',
        nombre: _nameController.text,
        telefono: _phoneController.text,
        dataUrL: _urlController.text,
        createdAt: DateTime.now(),
      );
      await ChallengesDataSource().saveChallengeUser(challenge: challengeUser);

      // Si el formulario se envía correctamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Formulario enviado correctamente'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      Navigator.of(context).pop(); // Cerrar el diálogo
    } catch (e) {
      if (e is DuplicateFailure) {
        setState(() {
          _errorMessage = e.errorMessage; // Actualizar el mensaje de error
        });
      } else {
        // En caso de un error no controlado
        setState(() {
          _errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.9, // Tamaño del diálogo
      height: MediaQuery.of(context).size.height * 0.7, // Tamaño del diálogo
      child: Column(
        children: [
          if (_errorMessage != null) // Mostrar mensaje de error si existe
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorMessage!,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepTapped: null, // Deshabilitar el avance al tocar
              onStepContinue: () {
                // Valida los formularios en cada paso antes de continuar
                if (_currentStep == 1) {
                  if (_infoFormKey.currentState!.validate()) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                } else if (_currentStep == 2) {
                  if (_urlFormKey.currentState!.validate()) {
                    onSaveChallenge(); // Guardar el reto
                  }
                } else {
                  setState(() {
                    _currentStep += 1;
                  });
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: details.onStepContinue,
                      child: Text(
                        _currentStep == 2 ? 'Finalizar' : 'Siguiente',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón de "Cancelar"
                    if (_currentStep != 0)
                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        child: Text('Atrás'),
                      ),
                  ],
                );
              },
              steps: [
                // Paso 1
                Step(
                  title: Text('Cómo cumplir los retos?'),
                  content: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instrucciones para Compartir tu Video:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '1. ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: 'Sube tu video a Google Drive. ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Asegúrate de que el archivo esté en formato compatible y que no exceda el límite de tamaño permitido.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '2. ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: 'Ajusta la configuración de privacidad: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Haz clic derecho en el video, selecciona "Compartir", y en "Obtener enlace", cambia la opción a "Cualquier persona con el enlace" para que no sea público.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '3. ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: 'Especifica el acceso: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'En la sección "Compartir con personas y grupos", introduce el correo: ',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextSpan(
                                    text: 'marycruzuta@gmail.com',
                                    style: TextStyle(
                                      color: Colors.blue, // Cambia el color si lo deseas
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launchUrl(Uri.parse('mailto:marycruzuta@gmail.com'));
                                      },
                                  ),
                                  TextSpan(
                                    text:
                                    ' del destinatario que deseas que tenga acceso al video. Asegúrate de configurar el permiso como "Puede ver" para que solo pueda visualizarlo, sin posibilidad de editar.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '4. ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                text: 'Envía la invitación: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Haz clic en "Enviar" para compartir el enlace de forma segura.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Listo! Tu video estará accesible solo para el correo seleccionado.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                // Paso 2 - Formulario de información
                Step(
                  title: Text('Tu Información'),
                  content: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Form(
                      key: _infoFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller:
                                _nameController, // Controlador del nombre
                            decoration: InputDecoration(labelText: 'Nombre'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller:
                                _phoneController, // Controlador del teléfono
                            keyboardType:
                                TextInputType.phone, // Teclado numérico
                            decoration: InputDecoration(
                                labelText: 'Número de teléfono'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu número de teléfono';
                              } else if (value.length != 10) {
                                return 'El número de teléfono debe tener 10 dígitos';
                              } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'El número de teléfono solo debe contener dígitos';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                // Paso 3 - Formulario del enlace
                Step(
                  title: Text('Tu Link'),
                  content: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Form(
                      key: _urlFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller:
                                _urlController, // Controlador del enlace
                            decoration:
                                InputDecoration(labelText: 'Url Google Drive'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el link';
                              } else if (!RegExp(
                                      r'^(https?:\/\/)?([a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+.*)$')
                                  .hasMatch(value)) {
                                return 'Por favor ingresa un URL válido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  isActive: _currentStep >= 2,
                  state:
                      _currentStep == 2 ? StepState.editing : StepState.indexed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
