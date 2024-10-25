import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mary_cruz_app/core/models/question_model.dart';
import 'package:mary_cruz_app/core/models/response_model.dart';

class SurveyItem extends StatefulWidget {
  final int questionIndex;
  final Question question;
  final Function(String, ResponseQuestionModel) onSelectedOption;
  final Function(String) isSelected;

  const SurveyItem({
    super.key,
    required this.questionIndex,
    required this.question,
    required this.onSelectedOption,
    required this.isSelected,
  });

  @override
  State<SurveyItem> createState() => _SurveyItemState();
}

class _SurveyItemState extends State<SurveyItem> {
  String selectedOption = '';

  get isSelected => widget.isSelected;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    print("${widget.question.title}  $isSelected");
    selectedOption = isSelected(widget.question.id);

    print("selectedOption $selectedOption");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  "${widget.questionIndex}.",
                  style: Theme.of(context).textTheme.titleMedium!,
                  softWrap: true, // Asegura que el texto se envuelva
                  overflow: TextOverflow
                      .visible, // Si prefieres que se muestre todo el texto
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              // O usa Flexible aquí si prefieres
              child: Text(
                widget.question.title,
                style: Theme.of(context).textTheme.titleMedium!,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            Icon(Icons.favorite,
                color: Theme.of(context).colorScheme.primary, size: 29),
          ],
        ),
        const Divider(),
        Column(
          children: widget.question.responses
              .map(
                (option) => RadioListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.title,
                      style: Theme.of(context).textTheme.bodyMedium),
                  value: option.title,
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value.toString();
                    });

                    widget.onSelectedOption(widget.question.id, option);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
