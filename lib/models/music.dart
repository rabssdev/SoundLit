class Music {
  int? id;
  String title;
  String tempo;

  Music({
    this.id,
    required this.title,
    required this.tempo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'tempo': tempo,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      id: map['id'],
      title: map['title'],
      tempo: map['tempo'],
    );
  }
}
