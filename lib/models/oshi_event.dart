import 'package:flutter/foundation.dart';

import 'category.dart';

/// イベント/商品モデル。
@immutable
class OshiEvent {
  const OshiEvent({
    required this.id,
    required this.workId,
    required this.workTitle,
    required this.title,
    required this.category,
    this.description = '',
    this.startDate,
    this.endDate,
    this.reservationStartDate,
    this.reservationEndDate,
    this.releaseDate,
    this.location,
    this.shopName,
    this.officialUrl,
    this.imageUrl,
    this.price,
    this.hasOnlineShop = false,
    this.hasPhysicalEvent = false,
    this.source,
    this.isOfficial = true,
    this.tags = const [],
    this.isBookmarked = false,
    required this.createdAt,
  });

  final String id;
  final String workId;
  final String workTitle;
  final String title;
  final OshiCategory category;
  final String description;

  /// 開催開始日
  final DateTime? startDate;

  /// 開催終了日
  final DateTime? endDate;

  /// 予約開始日
  final DateTime? reservationStartDate;

  /// 予約締切日
  final DateTime? reservationEndDate;

  /// 発売日（円盤・グッズなど）
  final DateTime? releaseDate;

  final String? location;
  final String? shopName;
  final String? officialUrl;
  final String? imageUrl;
  final int? price;
  final bool hasOnlineShop;
  final bool hasPhysicalEvent;

  /// 情報ソース。MVPでは "manual" 等。
  final String? source;
  final bool isOfficial;
  final List<String> tags;
  final bool isBookmarked;
  final DateTime createdAt;

  OshiEvent copyWith({
    String? id,
    String? workId,
    String? workTitle,
    String? title,
    OshiCategory? category,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? reservationStartDate,
    DateTime? reservationEndDate,
    DateTime? releaseDate,
    String? location,
    String? shopName,
    String? officialUrl,
    String? imageUrl,
    int? price,
    bool? hasOnlineShop,
    bool? hasPhysicalEvent,
    String? source,
    bool? isOfficial,
    List<String>? tags,
    bool? isBookmarked,
    DateTime? createdAt,
  }) {
    return OshiEvent(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      workTitle: workTitle ?? this.workTitle,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reservationStartDate: reservationStartDate ?? this.reservationStartDate,
      reservationEndDate: reservationEndDate ?? this.reservationEndDate,
      releaseDate: releaseDate ?? this.releaseDate,
      location: location ?? this.location,
      shopName: shopName ?? this.shopName,
      officialUrl: officialUrl ?? this.officialUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      hasOnlineShop: hasOnlineShop ?? this.hasOnlineShop,
      hasPhysicalEvent: hasPhysicalEvent ?? this.hasPhysicalEvent,
      source: source ?? this.source,
      isOfficial: isOfficial ?? this.isOfficial,
      tags: tags ?? this.tags,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OshiEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String key) {
      final v = json[key];
      if (v == null) return null;
      if (v is! String || v.isEmpty) return null;
      return DateTime.tryParse(v);
    }

    return OshiEvent(
      id: json['id'] as String,
      workId: json['workId'] as String,
      workTitle: json['workTitle'] as String,
      title: json['title'] as String,
      category: OshiCategoryX.parse(json['category'] as String? ?? 'other'),
      description: json['description'] as String? ?? '',
      startDate: parseDate('startDate'),
      endDate: parseDate('endDate'),
      reservationStartDate: parseDate('reservationStartDate'),
      reservationEndDate: parseDate('reservationEndDate'),
      releaseDate: parseDate('releaseDate'),
      location: json['location'] as String?,
      shopName: json['shopName'] as String?,
      officialUrl: json['officialUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toInt(),
      hasOnlineShop: json['hasOnlineShop'] as bool? ?? false,
      hasPhysicalEvent: json['hasPhysicalEvent'] as bool? ?? false,
      source: json['source'] as String?,
      isOfficial: json['isOfficial'] as bool? ?? true,
      tags: (json['tags'] as List?)?.whereType<String>().toList() ?? const [],
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      createdAt:
          parseDate('createdAt') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workId': workId,
      'workTitle': workTitle,
      'title': title,
      'category': category.name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reservationStartDate': reservationStartDate?.toIso8601String(),
      'reservationEndDate': reservationEndDate?.toIso8601String(),
      'releaseDate': releaseDate?.toIso8601String(),
      'location': location,
      'shopName': shopName,
      'officialUrl': officialUrl,
      'imageUrl': imageUrl,
      'price': price,
      'hasOnlineShop': hasOnlineShop,
      'hasPhysicalEvent': hasPhysicalEvent,
      'source': source,
      'isOfficial': isOfficial,
      'tags': tags,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
