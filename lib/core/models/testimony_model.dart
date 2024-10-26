class TestimonyModel {
  final String name;
  final String? description;
  final String urlVideo;
  final bool isVisble;

  TestimonyModel(
      {required this.name,
      this.description,
      required this.urlVideo,
      required this.isVisble});

  factory TestimonyModel.fromJson(Map<String, dynamic> json) {
    return TestimonyModel(
      name: json['name'],
      description: json['description'],
      urlVideo: json['url_video'],
      isVisble: json['is_visible'],
    );
  }
}
