import 'dart:convert';

class Amiibo {
  final String head;
  final String tail;
  final String name;
  final String gameSeries;
  final String image;
  final String type;
  final String character;
  final String amiiboSeries;
  final Map<String, String>? release;

  Amiibo({
    required this.head,
    required this.tail,
    required this.name,
    required this.gameSeries,
    required this.image,
    required this.type,
    required this.character,
    required this.amiiboSeries,
    required this.release,
  });

  String get id => '$head$tail';

  factory Amiibo.fromJson(Map<String, dynamic> json) {
    final releaseMap = json['release'] as Map<String, dynamic>?;
    return Amiibo(
      head: json['head'] ?? '',
      tail: json['tail'] ?? '',
      name: json['name'] ?? '',
      gameSeries: json['gameSeries'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? '',
      character: json['character'] ?? '',
      amiiboSeries: json['amiiboSeries'] ?? '',
      release: releaseMap == null
          ? null
          : releaseMap.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'head': head,
      'tail': tail,
      'name': name,
      'gameSeries': gameSeries,
      'image': image,
      'type': type,
      'character': character,
      'amiiboSeries': amiiboSeries,
      'release': release,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory Amiibo.fromJsonString(String jsonString) {
    return Amiibo.fromJson(jsonDecode(jsonString));
  }
}
