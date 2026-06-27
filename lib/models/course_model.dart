class CourseModel {
  final int? id;
  final String title;
  final String body;
  final int userId;

  CourseModel({
    this.id,
    required this.title,
    required this.body,
    this.userId = 1,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  CourseModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
    );
  }
}