import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mary_cruz_app/core/global_controllers/config_controller.dart';
import 'package:mary_cruz_app/play/pages/game_logic.dart';
import 'package:mary_cruz_app/play/pages/widgets/board.dart';

import 'package:http/http.dart' as http;


class Game extends StatefulWidget {
  Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final GameLogic _game = GameLogic();

  var levelForCardCount = 0;
  var tries = 0;
  var score = 0;
  var axisNumber = 4;
  late Timer timer;
  int startTime = 60;
  String level = '';
  var complete = 0;

  String phraseGeneralShow = '"Unidos lo haremos posible"';
  String msgGeneralGame = "";


  void startTimer(BuildContext context) {
    if (startTime == 0) {}
    const oneSecond = Duration(seconds: 1);
    timer = Timer.periodic(oneSecond, (timer) {
      if (startTime == 0) {
        timer.cancel();
        _showDialog(context, 'Juego Finalizado', 'Tu puntuación fue de: $score');
      } else {
        if(mounted){
          setState(() {
            startTime--;
          });

        }else{
          timer.cancel();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

      SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Cambia el color aquí
        statusBarIconBrightness: Brightness.dark,
      ),
    );


    startTimer(context);
    msgGeneralGame = "Tu puntuación fue de: $score";

    getInfoPhrase();
   
  }


  getInfoPhrase()async{
     bool isConnected = await checkConnectivity();

    if (isConnected) {

      ConfigController configController =
        Get.put(ConfigController(), permanent: true);


      await configController.getPhraseGeneral();
      await configController.getMsgPlayGeneral();

      phraseGeneralShow = configController.phraseGame.value;
      msgGeneralGame = configController.msgGame.value;
    }
  }


  Future<bool> checkConnectivity() async {
    List connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.length == 0) {
      return false;
    }

    if(connectivityResult[0] == ConnectivityResult.mobile ||
        connectivityResult[0] == ConnectivityResult.wifi){
          return await checkNet();
      }

    return false;
  } 


  Future<bool> checkNet()async{
   try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    return response.statusCode == 200; // Comprobamos si la respuesta fue exitosa
  } catch (e) {
    return false; // Si hay un error en la petición
  }
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _game.initGame(context);
  }




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width+MediaQuery.of(context).size.width/2.5;


    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: 
          Padding(
            padding:  EdgeInsets.only(bottom: ScreenUtil().setHeight(5)),
            child: Text(
                          phraseGeneralShow,
                          style:
                              Theme.of(context).textTheme.displayMedium!.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                        ),
          ),
    
      //backgroundColor: Color(0xFFF05454),
      body: Padding(
        padding: const EdgeInsets.only(top:  12.0),
        child: Column(
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              board('Tiempo', '$startTime'),
              board('Puntuación', '$score'),
              board('Movimientos', '$tries')
            ],
          ),
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: GridView.builder(
                itemCount: _game.cardsImg!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _game.axiCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                ),
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap:  _game.isEnabled[index] ?() {
                        setState(() {
                          tries++;
            
                          _game.cardsImg![index] = _game.card_list[index];
        
                          if(_game.matchCheck.isEmpty){
                            _game.matchCheck.add({index: _game.card_list[index]});
                          }else{
                            if(!_game.matchCheck[0].keys.toString().contains("("+index.toString()+")")  ){
                              _game.matchCheck.add({index: _game.card_list[index]});
                            }
                          }
            
                          
                          if (_game.matchCheck.length == 2) {
        
        
                            if (_game.matchCheck[0].values.first ==
                                _game.matchCheck[1].values.first) {
                              score += 100;
                              complete += 1;
        
                              _game.isEnabled[
                                int.parse(
                                _game.matchCheck[0].keys.toString().replaceAll("(", "").replaceAll(")", ""))] = false;
        
                              _game.isEnabled[
                                int.parse(
                                _game.matchCheck[1].keys.toString().replaceAll("(", "").replaceAll(")", ""))] = false;
        
            
                              _game.matchCheck.clear();
                              if (complete * 2 == (_game.cardCount - 1)) {
                                //_game.isEnabled = [true, true, true, true, true, true,true, true, true, true, true, true,true, true, true, true, true, true, true];
                                  _game.isEnabled = [true, true, true, true, false, true,true, true, true /*, true, true, true,true, true, true, true, true, true, true*/];
        
                                _showDialog(context, 'Ganaste', 
                                    'Tu puntuación fue de: $score \n$msgGeneralGame'); 
                                timer.cancel();
                              }
                            } else {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                setState(() {
                                  if(_game.matchCheck.length>=1){
                                      _game.cardsImg![_game.matchCheck[0].keys
                                      .first] = _game.hiddenCard;
                                  
                                  }

                                  if(_game.matchCheck.length>=2){                                  
                                    _game.cardsImg![_game.matchCheck[1].keys
                                      .first] = _game.hiddenCard;
                                  }
            
                                  _game.matchCheck.clear();
                                });
                              });
                            }
                          }
                        });
            
                        // _game.matchCheck
                      }:null,
                      child: Container(
                         decoration: BoxDecoration(
                              shape: BoxShape.circle, // Forma circular
                              border: Border.all(
                                color: _game.isEnabled[index] ? Colors.black : Theme.of(context).primaryColor, // Color de la línea
                                width: _game.isEnabled[index] ? 1 : 4, // Grosor del borde
                              ),
                            ),
                          child: Center(
                                child: CircleAvatar(
                                  radius: 60.0, // Ajusta el tamaño del avatar
                                  backgroundColor: Color(0xFFE2E4E3), // Color de fondo
                                  child: ClipOval(
                                    child: Image.asset(
                                      _game.cardsImg![index], // URL de la imagen
                                      width: ScreenUtil().setWidth(110),
                                      height: ScreenUtil().setHeight(180),
                                      fit: BoxFit.contain, // Ajuste de la imagen
                                    ),
                                  ),
                                ),
                              ),


                        /*decoration: BoxDecoration(
                          border: Border.all(
                            color: _game.isEnabled[index] ? Colors.black : Theme.of(context).primaryColor, // Color de la línea
                            width: _game.isEnabled[index] ? 1 : 3, // Grosor de la línea
                          ),
                            //color:  _game.isEnabled[index] ? Colors.white : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                                image: AssetImage(_game.cardsImg![index]),
                                fit: BoxFit.cover)),*/
                      ));
                }),
          ),



        ]),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String info) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(info),
            actions: <Widget>[
              TextButton(
                child:  Text('Regresar a pantalla principal', style: TextStyle(fontSize: ScreenUtil().setSp(14)),),
                onPressed: () {
                  // Navigator.of(context).pop();
                  //Navigator.pushNamed(context, 'home');
                  Navigator.pushNamed(context, '/');
                },
              )
            ],
          );
        });
  }


  
}
