class Todo {
  final int id;
  final String judul;
  final bool selesai;
  final String userId;

  Todo({
    required this.id,
    required this.judul,
    required this.selesai,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      judul: json['judul'] ?? '',
      selesai: json['selesai'] == true,
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': judul,
      'selesai': selesai,
      'user_id': userId,
    };
  }
}
