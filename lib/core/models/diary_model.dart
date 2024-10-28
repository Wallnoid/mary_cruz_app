class DiaryModel {
  final String? id;
  final String title;
  final String description;
  final DateTime date;
  final String initTime;
  final String endTime;
  final String place;
  final bool isVisible;

  DiaryModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.initTime,
    required this.endTime,
    required this.place,
    required this.isVisible,
  });

  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    return DiaryModel(
      id: json['id'],
      title: json['title'],
      description: json['descripcion'],
      place: json['place'],
      date: DateTime.parse(json['date']),
      initTime: json['init_time'],
      endTime: json['end_time'],
      isVisible: json['active'],
    );
  }

  @override
  String toString() {
    return 'DiaryModel{title: $title, description: $description, date: $date, initTime: $initTime, endTime: $endTime, place: $place}';
  }
}
