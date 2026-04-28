import 'package:flutter/material.dart';

/// 推し関連イベント・商品のカテゴリ。
enum OshiCategory {
  cafe,
  goods,
  popupStore,
  exhibition,
  lottery,
  preorder,
  madeToOrder,
  live,
  stage,
  streaming,
  bluRay,
  campaign,
  other,
}

extension OshiCategoryX on OshiCategory {
  /// 文字列(enum.name) → OshiCategory。未知の値は other にフォールバック。
  static OshiCategory parse(String value) {
    for (final c in OshiCategory.values) {
      if (c.name == value) return c;
    }
    return OshiCategory.other;
  }

  String get label {
    switch (this) {
      case OshiCategory.cafe:
        return 'コラボカフェ';
      case OshiCategory.goods:
        return '新作グッズ';
      case OshiCategory.popupStore:
        return 'ポップアップ';
      case OshiCategory.exhibition:
        return '展示会';
      case OshiCategory.lottery:
        return '一番くじ';
      case OshiCategory.preorder:
        return '予約販売';
      case OshiCategory.madeToOrder:
        return '受注生産';
      case OshiCategory.live:
        return 'ライブ';
      case OshiCategory.stage:
        return '舞台';
      case OshiCategory.streaming:
        return '配信開始';
      case OshiCategory.bluRay:
        return '円盤発売';
      case OshiCategory.campaign:
        return 'キャンペーン';
      case OshiCategory.other:
        return 'その他';
    }
  }

  IconData get icon {
    switch (this) {
      case OshiCategory.cafe:
        return Icons.local_cafe_outlined;
      case OshiCategory.goods:
        return Icons.shopping_bag_outlined;
      case OshiCategory.popupStore:
        return Icons.storefront_outlined;
      case OshiCategory.exhibition:
        return Icons.museum_outlined;
      case OshiCategory.lottery:
        return Icons.casino_outlined;
      case OshiCategory.preorder:
        return Icons.event_available_outlined;
      case OshiCategory.madeToOrder:
        return Icons.precision_manufacturing_outlined;
      case OshiCategory.live:
        return Icons.music_note_outlined;
      case OshiCategory.stage:
        return Icons.theater_comedy_outlined;
      case OshiCategory.streaming:
        return Icons.live_tv_outlined;
      case OshiCategory.bluRay:
        return Icons.album_outlined;
      case OshiCategory.campaign:
        return Icons.campaign_outlined;
      case OshiCategory.other:
        return Icons.category_outlined;
    }
  }
}
