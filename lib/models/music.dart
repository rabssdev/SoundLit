class Music {
  int? id;
  String title;
  String tempo;
  String fileName;

  Music({
    this.id,
    required this.title,
    required this.tempo,
    required this.fileName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'tempo': tempo,
      'fileName': fileName,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      id: map['id'],
      title: map['title'],
      tempo: map['tempo'],
      fileName: map['fileName'],
    );
  }
}
