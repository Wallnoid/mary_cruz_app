import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mary_cruz_app/core/errors/failures.dart';

import '../../../news/models/news_model.dart';
import '../../../proposals/models/proposal_model.dart';
import '../../data/users_datasource.dart';
import '../../data/votes_datasource.dart';
import '../../models/user_model.dart';
import '../../models/vote_model.dart';
import '../../utils/cellphone_info.dart';

class HeartsScore extends StatefulWidget {
  final NewsModel? news;
  final ProposalModel? proposal;

  const HeartsScore({
    super.key,
    this.news,
    this.proposal,
  });

  @override
  State<HeartsScore> createState() => _HeartsScoreState();
}

class _HeartsScoreState extends State<HeartsScore> {
  late double _randomRating;
  late int _randomVotes;

  Future<void> onSaveNewsVote({required int rate}) async{
    print('Guardando voto de noticia');
    try{
      String deviceInfo = await getDeviceId();
      final UserModel user = await UsersDataSource().getUserData(idDispositivo: deviceInfo);
      final VoteNewsModel vote = VoteNewsModel(
        idUsuario: user.id ?? '',
        idNoticia: widget.news?.id ?? '',
        puntuacion: rate,
        createdAt: DateTime.now(),
      );
      await VotesDataSource().saveNewsVote(voteNews: vote);
    }catch(e){
      print(e);
      throw e;
    }
  }

  Future<void> onSaveProposalVote({required int rate}) async{
    try{
      String deviceInfo = await getDeviceId();
      final UserModel user = await UsersDataSource().getUserData(idDispositivo: deviceInfo);
      print(user.id);
      print(widget.proposal?.id);
      final VoteProposalModel vote = VoteProposalModel(
        idUsuario: user.id ?? '',
        idPropuesta: widget.proposal?.id ?? '',
        puntuacion: rate,
        createdAt: DateTime.now(),
      );
      await VotesDataSource().saveProposalVote(voteProposals: vote);
    }catch(e){
      print(e);
      throw e;
    }


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


    _generateRandomRatingAndVotes();
  }

  void _generateRandomRatingAndVotes() {
    final List<double> possibleRatings = [4, 4.5, 5];
    _randomRating = possibleRatings[Random().nextInt(possibleRatings.length)];

    _randomVotes = 15 + Random().nextInt(186);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (var i = 0; i < _randomRating.floor(); i++)
              Icon(
                Icons.favorite,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            if (_randomRating == 4.5)
              Stack(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.5, // Muestra solo la mitad del corazón
                      child: Icon(
                        Icons.favorite,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            for (var i = _randomRating.floor() + (_randomRating == 4.5 ? 1 : 0); i < 5; i++)
              Icon(
                Icons.favorite_border,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '(${(_randomRating / 5 * 100).toStringAsFixed(1)}%)', // Mostrar el porcentaje de rating
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  minimumSize: Size(80, 32),
                ),
                onPressed: _showRatingDialog,
                child: Text(
                  'Calificar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showRatingDialog() async {
    int tempRating = 0; // Ahora inicializado en 0 para que siempre empiece en 0
    bool _isLoading = false;
    String? _errorMessage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: widget.proposal != null
              ? Text('Califica esta propuesta', style: Theme.of(context).textTheme.titleMedium)
              : Text('Califica esta noticia' , style: Theme.of(context).textTheme.titleMedium),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < tempRating
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            iconSize: 40,
                            onPressed: () {
                              setState(() {
                                tempRating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Cancelar',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : () async {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });

                              try {
                                if (widget.news != null) {
                                  await onSaveNewsVote(rate: tempRating);
                                } else {
                                  await onSaveProposalVote(rate: tempRating);
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Voto guardado con éxito'), backgroundColor: Theme.of(context).colorScheme.primary)
                                );
                              } catch (e) {
                                if(e is DuplicateFailure){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.errorMessage), backgroundColor: Colors.red)
                                  );
                                }
                                setState(() {
                                  _isLoading = false;
                                  _errorMessage = (e as DuplicateFailure).errorMessage;
                                });
                              }
                            },
                            child: Text(
                              'Guardar',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


}
