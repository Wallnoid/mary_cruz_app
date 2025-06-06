

import 'package:mary_cruz_app/challenges/models/challenge_model.dart';
import 'package:mary_cruz_app/news/models/news_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/failures.dart';
import '../../core/models/user_model.dart';
import '../../core/supabase/supabase_instance.dart';

class ChallengesDataSource{

  Future<List<ChallengeModel>> getAllChallenges() async {
    try {
      final response = await supabase.from('retos').select();
      print('Response: $response');
      final List<ChallengeModel> challenges = response.map<ChallengeModel>((data) => ChallengeModel.fromJson(data)).toList();
      return challenges;
    } catch (e) {
      print('Error al obtener retos: $e');
      throw Exception('Error al obtener retos');
    }
  }

  Future<void> saveChallengeUser({required ChallengeUserModel challenge}) async {
    try{
      final response = await supabase.from('reto_usuario').insert(challenge.toJson());
    }catch(e){
      if(e is PostgrestException){
        if(e.code == 'P0001'){
          throw DuplicateFailure(errorMessage: e.message);
        }
      }
      print('Error al guardar reto: $e');
      throw ServerFailure(errorMessage: 'Error en servidor al guardar reto');
    }
  }


}