import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeCustomTextField extends StatefulWidget {
  final RegExp regex;
  final TextInputType inputType;
  final double fontSize;
  final double radius;
  final TextEditingController valueController;
  final bool enabled;

  const AgeCustomTextField({
    super.key,
    required this.regex,
    required this.inputType,
    required this.fontSize,
    required this.radius,
    required this.valueController,
    required this.enabled,
  });

  @override
  State<AgeCustomTextField> createState() => _AgeCustomTextFieldState();
}

class _AgeCustomTextFieldState extends State<AgeCustomTextField> {
  get regex => widget.regex;
  get inputType => widget.inputType;
  get fontSize => widget.fontSize;
  get radius => widget.radius;
  get valueController => widget.valueController;
  get enabled => widget.enabled;

  // Elimina el método dispose()

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      enabled: enabled ? true : false,
      cursorColor: const Color(0xff58534C),
      style: GoogleFonts.roboto(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 2, left: 8, right: 8),
        filled: true,
        fillColor: const Color(0xFFF2EFEF),
        hintText: '',
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: inputType,
      controller: valueController,
      onChanged: (value) {
        // Solo permitir números usando una expresión regular
        final newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
        if (newValue != value) {
          valueController.text = newValue;
          valueController.selection = TextSelection.fromPosition(
            TextPosition(offset: valueController.text.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        final int? intValue = int.tryParse(value);
        if (intValue == null || intValue < 16 || intValue > 80) {
          return 'Ingresa una edad entre 16 y 80';
        }
        return null;
      },
    );
  }
}
