class Sugguestion {
  final int id;
  final String sugguestionType;
  final String sugguestionText;
  final int countLikes;
  final String createdAt;

  Sugguestion({
    required this.id,
    required this.sugguestionText,
    required this.sugguestionType,
    required this.countLikes,
    required this.createdAt,
  });
  factory Sugguestion.fromJson(Map<String, dynamic> json) {
    return Sugguestion(
        id: json['id'],
        sugguestionText: json['sugguestion_text'],
        sugguestionType: json['sugguestion_type'],
        countLikes: json['count_likes'],
        createdAt: json['created_at']);
  }
}
