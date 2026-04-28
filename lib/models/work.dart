import 'package:flutter/foundation.dart';

/// 作品モデル。
@immutable
class Work {
  const Work({
    required this.id,
    required this.title,
    this.aliases = const [],
    required this.genre,
    this.officialUrl,
    this.imageUrl,
    this.isFavorite = false,
    this.notificationEnabled = true,
  });

  final String id;
  final String title;
  final List<String> aliases;
  final String genre;
  final String? officialUrl;
  final String? imageUrl;
  final bool isFavorite;
  final bool notificationEnabled;

  Work copyWith({
    String? id,
    String? title,
    List<String>? aliases,
    String? genre,
    String? officialUrl,
    String? imageUrl,
    bool? isFavorite,
    bool? notificationEnabled,
  }) {
    return Work(
      id: id ?? this.id,
      title: title ?? this.title,
      aliases: aliases ?? this.aliases,
      genre: genre ?? this.genre,
      officialUrl: officialUrl ?? this.officialUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      title: json['title'] as String,
      aliases:
          (json['aliases'] as List?)?.whereType<String>().toList() ?? const [],
      genre: json['genre'] as String? ?? 'その他',
      officialUrl: json['officialUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'aliases': aliases,
      'genre': genre,
      'officialUrl': officialUrl,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'notificationEnabled': notificationEnabled,
    };
  }
}
