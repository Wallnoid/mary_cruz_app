import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsDialog extends StatefulWidget {
  final Function onAccept;
  final Function onReject;

  const TermsConditionsDialog({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  _TermsConditionsDialogState createState() => _TermsConditionsDialogState();
}

class _TermsConditionsDialogState extends State<TermsConditionsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).primaryColor,
              size: 100,
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  'Para continuar, debes confirmar que tienes al menos 18 años y aceptar nuestros:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(
                        'https://drive.google.com/file/d/1dsvCwmLiYSv3qRY5E67yQDOFHaUgSPBu/view?usp=share_link'); // Reemplaza con tu URL
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'No se pudo abrir $url';
                    }
                  },
                  child: Text(
                    'Términos y Condiciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue, // Color para parecer un enlace
                      decoration: TextDecoration.underline, // Subrayado para parecer un enlace
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      widget.onReject();
                    },
                    child: Text(
                      'Cancelar',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  )),
                  SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      widget.onAccept();
                    },
                    child: Text(
                      'Confirmar',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
