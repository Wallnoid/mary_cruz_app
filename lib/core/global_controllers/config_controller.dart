import 'package:get/get.dart';
import 'package:mary_cruz_app/core/supabase/supabase_instance.dart';
import 'package:mary_cruz_app/core/utils/cellphone_info.dart';
import 'package:mary_cruz_app/core/utils/cellphone_token.dart';

class ConfigController extends GetxController {
  var currentSurvey = "".obs;
  var isCompletedSurvey = false.obs;
  var currentVersion = "".obs;
  var currentVersionIos = "".obs;
  var phraseGame = "".obs;
  var msgGame = "".obs;


  getCurrentSurvey() async {
    try {
      final data = await supabase
          .from('configuraciones')
          .select()
          .eq('key', 'currentSurvey')
          .single();

      print(data);

      currentSurvey.value = data['value'];
    } catch (e) {
      print("Error al obtener la encuesta $e");
      currentSurvey.value = "";
    }
  }

  isCompletedSurveyF() async {
    try {
      var deviceId = await getDeviceId();
      final data = await supabase.rpc('verificar_usuario_y_encuesta', params: {
        'dispositivo_id': deviceId,
        'encuesta_id': currentSurvey.value
      });

      print(data.toString());
      print("deviceId" + deviceId.toString());


      isCompletedSurvey.value = data;
    } catch (e) {
      print("Error al obtener las opciones del menú $e");
      currentSurvey.value = "";
    }
  }


  saveUpdUser () async {
    try {
      var deviceId = await getDeviceId();
      var tokenPhone = await getToken();

      //print(" tokenPhone " + tokenPhone.toString());
      
      final response = await supabase
        .from('usuarios') // Reemplaza con el nombre de tu tabla
        .select()
        .eq('id_dispositivo', deviceId);

      

      //print(" updateResponse " + (response.length.toString()));

      if(response.length > 0){
         await supabase
        .from('usuarios') // Reemplaza con el nombre de tu tabla
        .update({"token_user": tokenPhone})
        .eq('id_dispositivo', deviceId);
      }else{
        await supabase
        .from('usuarios') // Reemplaza con el nombre de tu tabla
        .insert({"token_user": tokenPhone,'id_dispositivo': deviceId});

      }

    } catch (e) {
      //print("Error al obtener las opciones del menú $e");
    }
  }

  getCurrentVersion() async {
    try {
      var data = await supabase
          .from('configuraciones')
          .select()
          .eq('key', 'currentVersion')
          .single();

      currentVersion.value = data['value'];
    } catch (e) {
      print("Error al obtener la version $e");
      currentVersion.value = '';
    }
  }


    getCurrentVersionIos() async {
    try {
      var data = await supabase
          .from('configuraciones')
          .select()
          .eq('key', 'currentVersionIos')
          .single();

      currentVersionIos.value = data['value'];
    } catch (e) {
      print("Error al obtener la version $e");
      currentVersionIos.value = '';
    }
  }


  getPhraseGeneral() async {
    try {
      var data = await supabase
          .from('configuraciones')
          .select()
          .eq('key', 'phraseGeneral')
          .single();

      phraseGame.value = data['value'];
    } catch (e) {
      print("Error al obtener la version $e");
      phraseGame.value = '';
    }
  }

    getMsgPlayGeneral() async {
    try {
      var data = await supabase
          .from('configuraciones')
          .select()
          .eq('key', 'msgPlayGeneral')
          .single();

      msgGame.value = data['value'];
    } catch (e) {
      print("Error al obtener la version $e");
      msgGame.value = '';
    }
  }


}
