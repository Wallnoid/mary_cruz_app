import 'dart:math';

import 'package:flutter/material.dart';

class GameLogic {
  final String hiddenCard = 'lib/assets/logo2.png';
  List<String>? cardsImg;
  String level = '';

  late List<String> card_list = [];
  late List<bool> isEnabled = [
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    true /*, true, true, true,true, true, true, true, true, true, true*/
  ];

  var axiCount = 0;
  var cardCount = 0;
  List<Map<int, String>> matchCheck = [];

  void initGame(BuildContext context) {
    cardCount = 9; //16;
    axiCount = 3; //4;
    card_list = [
      'lib/assets/candidato1.png',
      'lib/assets/candidato2.png',
      'lib/assets/candidato3.png',
      'lib/assets/candidato4.png',
      'lib/assets/logo2.png',
      'lib/assets/candidato1.png',
      'lib/assets/candidato2.png',
      'lib/assets/candidato3.png',
      'lib/assets/candidato4.png',
      /*'lib/assets/logo2.png',
        'lib/assets/logo2.png',
        'lib/assets/logo2.png',
        'lib/assets/logo3.png',
        'lib/assets/logo3.png',
        'lib/assets/logo3.png',
        'lib/assets/logo3.png',*/
    ];

    isEnabled = [
      true,
      true,
      true,
      true,
      false,
      true,
      true,
      true,
      true /*, true, true, true,true, true, true, true, true, true, true*/
    ];

    //card_list.shuffle();

    int fixedPosition = 4;
    String fixedElement = card_list[fixedPosition];

    // Crear una nueva lista sin el elemento fijo
    List<String> remainingCards = [
      ...card_list.sublist(0, fixedPosition),
      ...card_list.sublist(fixedPosition + 1),
    ];

    // Mezclar el resto de la lista
    remainingCards.shuffle(Random());

    // Volver a insertar el elemento fijo en su posición
    List<String> shuffledList = [
      ...remainingCards.sublist(0, fixedPosition),
      fixedElement,
      ...remainingCards.sublist(fixedPosition),
    ];

    card_list = shuffledList;

    cardsImg = List<String>.generate(cardCount, (index) {
      return hiddenCard;
    });
  }
}
