import 'package:mary_cruz_app/core/models/investigation_model.dart';

class CandidatesModel {
  final String id;
  final String name;
  final String phrase;
  final String role;
  final String imageAvatarSmall;
  final String imageAvatarBig;
  final String urlVideo;
  final String resumen;
  final String? facebook;
  final String? instagram;
  final String? tiktok;
  final bool visibleAcademico;
  final bool visibleExperiencia;
  final bool visibleInvestigaciones;
  final List<String> academicFormation;
  final List<String> workExperience;
  final List<InvestigationModel>? investigations;

  CandidatesModel({
    required this.id,
    required this.name,
    required this.phrase,
    required this.imageAvatarSmall,
    required this.urlVideo,
    this.facebook,
    this.instagram,
    this.tiktok,
    required this.visibleAcademico,
    required this.visibleExperiencia,
    required this.visibleInvestigaciones,
    required this.role,
    required this.academicFormation,
    required this.workExperience,
    required this.investigations,
    required this.imageAvatarBig,
    required this.resumen,
  });

  factory CandidatesModel.fromJson(Map<String, dynamic> json) {
    return CandidatesModel(
      id: json['id'],
      name: json['name'],
      phrase: json['phrase'],
      imageAvatarSmall: json['image_avatar_small'],
      imageAvatarBig: json['image_avatar_big'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      role: json['role'],
      resumen: json['resumen'],
      visibleAcademico: json['visible_academico'],
      visibleExperiencia: json['visible_experiencia'],
      visibleInvestigaciones: json['visible_investigacion'],
      academicFormation: List<String>.from(json['academicformation']),
      workExperience: List<String>.from(json['workexperience']),
      investigations: List<InvestigationModel>.from(
        json['investigations'].map(
          (x) => InvestigationModel.fromJson(x),
        ),
      ),
      urlVideo: json['url_video'],
    );
  }

  factory CandidatesModel.fromJsonToFilterProposals(Map<String, dynamic> json) {
    return CandidatesModel(
      id: json['id'] ?? '',
      name: json['name'],
      resumen: json['resumen']?? '',
      phrase: json['phrase'],
      imageAvatarSmall: json['image'],
      role: json['role'],
      academicFormation: [],
      workExperience: [],
      investigations: [],
      urlVideo: '',
      visibleAcademico:  json['visible_academico'],
      visibleExperiencia: json['visible_experiencia'],
      visibleInvestigaciones: json['visible_investigacion'],
      imageAvatarBig: json['image_avatar_big'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phrase': phrase,
      'role': role,
      'image': imageAvatarSmall,
      'url_video': urlVideo,
      'facebook': facebook,
      'instagram': instagram,
      'tiktok': tiktok,
      'academicformation': academicFormation,
      'workexperience': workExperience,
      'investigations': investigations?.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CandidatesModel(id: $id, name: $name, phrase: $phrase, role: $role, image: $imageAvatarSmall, urlVideo: $urlVideo, facebook: $facebook, instagram: $instagram, tiktok: $tiktok, academicFormation: $academicFormation, workExperience: $workExperience, investigations: $investigations)';
  }
}
