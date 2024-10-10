import 'package:flutter/material.dart';
import 'package:mary_cruz_app/core/entities/question.dart';

class SurveyItem extends StatefulWidget {
  final int questionIndex;
  final Question question;

  const SurveyItem({
    super.key,
    required this.questionIndex,
    required this.question,
  });

  @override
  State<SurveyItem> createState() => _SurveyItemState();
}

class _SurveyItemState extends State<SurveyItem> {
  String selectedOption = '';

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
