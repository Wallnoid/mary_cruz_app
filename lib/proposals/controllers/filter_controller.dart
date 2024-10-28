import 'package:get/get.dart';
import 'package:mary_cruz_app/core/models/candidates_model.dart';
import '../../core/models/faculties_model.dart';
import '../models/proposed_approach_model.dart';

class FilterController extends GetxController {
  var facultades = <FacultyModel>[].obs;
  var enfoques = <ProposedApproachModel>[].obs;
  var candidatos = <CandidatesModel>[].obs;


  void setFacultades(List<FacultyModel> newFacultades) {
    facultades.assignAll(newFacultades);
  }

  void setCandidatos(List<CandidatesModel> newCandidato) {
    candidatos.assignAll(newCandidato);
  }

  void setEnfoques(List<ProposedApproachModel> newEnfoques) {
    enfoques.assignAll(newEnfoques);

    void addFaculty(FacultyModel faculty) {
      facultades.add(faculty);
    }

    void addEnfoque(ProposedApproachModel enfoque) {
      enfoques.add(enfoque);
    }

  void addCandidato(CandidatesModel candidato) {
      candidatos.add(candidato);
    }
  }

  List<FacultyModel> getFacultades() {
    return facultades;
  }

   String getFacultadesString() {
    String valFacu = "";
    for(FacultyModel facu in facultades){
      valFacu +=" "+facu.siglas;
    }
    return valFacu;
  }


  List<ProposedApproachModel> getEnfoques() {
    return enfoques;
  }

   List<CandidatesModel> getCandidatos() {
    return candidatos;
  }


   String getEnfoquesString() {
    String valEnfoque = "";
    for(ProposedApproachModel enfo in enfoques){
      valEnfoque +=" "+enfo.titulo;
    }
    return valEnfoque;

   }


   bool hasInfo(){
    //return (facultades.length + enfoques.length + candidatos.length) >0 ? true : false;
    return ( enfoques.length + candidatos.length) >0 ? true : false;

   }

    void eraseInfo(){
      facultades.clear();
      enfoques.clear();
      candidatos.clear();
   }
    

}
