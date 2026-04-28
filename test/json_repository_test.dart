import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oshi_suke/models/category.dart';
import 'package:oshi_suke/models/oshi_event.dart';
import 'package:oshi_suke/models/work.dart';
import 'package:oshi_suke/repositories/json_asset_event_repository.dart';
import 'package:oshi_suke/repositories/json_asset_work_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Work.fromJson / toJson', () {
    test('roundtrip preserves all fields', () {
      const w = Work(
        id: 'w_test',
        title: 'テスト作品',
        aliases: ['Test', 'TEST'],
        genre: 'アニメ',
        officialUrl: 'https://example.com',
        imageUrl: null,
        isFavorite: true,
        notificationEnabled: false,
      );
      final restored = Work.fromJson(w.toJson());
      expect(restored.id, w.id);
      expect(restored.title, w.title);
      expect(restored.aliases, w.aliases);
      expect(restored.genre, w.genre);
      expect(restored.officialUrl, w.officialUrl);
      expect(restored.isFavorite, w.isFavorite);
      expect(restored.notificationEnabled, w.notificationEnabled);
    });
  });

  group('OshiEvent.fromJson / toJson', () {
    test('roundtrip with ISO8601 dates preserves all fields', () {
      final e = OshiEvent(
        id: 'e_test',
        workId: 'w_test',
        workTitle: 'テスト作品',
        title: 'テストイベント',
        category: OshiCategory.cafe,
        description: '説明',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 31),
        reservationStartDate: DateTime(2026, 4, 15),
        reservationEndDate: DateTime(2026, 4, 30),
        releaseDate: DateTime(2026, 6, 1),
        location: '東京',
        shopName: 'Shop',
        officialUrl: 'https://example.com',
        price: 1500,
        hasOnlineShop: true,
        hasPhysicalEvent: true,
        source: 'manual',
        isOfficial: true,
        tags: const ['新作'],
        isBookmarked: true,
        createdAt: DateTime(2026, 4, 1),
      );
      final restored = OshiEvent.fromJson(e.toJson());
      expect(restored.id, e.id);
      expect(restored.workId, e.workId);
      expect(restored.title, e.title);
      expect(restored.category, e.category);
      expect(restored.startDate, e.startDate);
      expect(restored.endDate, e.endDate);
      expect(restored.reservationStartDate, e.reservationStartDate);
      expect(restored.reservationEndDate, e.reservationEndDate);
      expect(restored.releaseDate, e.releaseDate);
      expect(restored.price, e.price);
      expect(restored.tags, e.tags);
      expect(restored.isBookmarked, e.isBookmarked);
      expect(restored.createdAt, e.createdAt);
    });

    test('handles null dates and unknown category gracefully', () {
      final restored = OshiEvent.fromJson(<String, dynamic>{
        'id': 'x',
        'workId': 'y',
        'workTitle': 'z',
        'title': 't',
        'category': 'this_is_not_a_real_category',
        'createdAt': '2026-04-26T00:00:00',
      });
      expect(restored.category, OshiCategory.other);
      expect(restored.startDate, isNull);
      expect(restored.tags, isEmpty);
      expect(restored.isOfficial, isTrue);
    });
  });

  group('JsonAssetWorkRepository', () {
    test('falls back to mock when asset is missing', () async {
      final repo = JsonAssetWorkRepository(
        bundle: _MissingAssetBundle(),
        assetPath: 'assets/data/works.json',
      );
      final works = await repo.fetchAll();
      expect(works, isNotEmpty,
          reason: 'mockWorks にフォールバックして空でない一覧が返るべき');
    });

    test('parses a synthetic JSON list', () async {
      final repo = JsonAssetWorkRepository(
        bundle: _InMemoryBundle({
          'assets/data/works.json':
              '[{"id":"a","title":"Aタイトル","genre":"テスト"}]',
        }),
      );
      final works = await repo.fetchAll();
      expect(works, hasLength(1));
      expect(works.single.title, 'Aタイトル');
    });
  });

  group('JsonAssetEventRepository', () {
    test('falls back to mock when asset is missing', () async {
      final repo = JsonAssetEventRepository(
        bundle: _MissingAssetBundle(),
      );
      final events = await repo.fetchAll();
      expect(events, isNotEmpty);
    });

    test('parses a synthetic JSON list with ISO dates', () async {
      final repo = JsonAssetEventRepository(
        bundle: _InMemoryBundle({
          'assets/data/events.json': '''
[
  {
    "id": "e1",
    "workId": "w1",
    "workTitle": "作品",
    "title": "イベント",
    "category": "cafe",
    "startDate": "2026-05-01",
    "endDate": "2026-05-31",
    "reservationEndDate": "2026-04-30",
    "createdAt": "2026-04-01T00:00:00"
  }
]
'''
        }),
      );
      final events = await repo.fetchAll();
      expect(events, hasLength(1));
      expect(events.single.startDate, DateTime(2026, 5, 1));
      expect(events.single.reservationEndDate, DateTime(2026, 4, 30));
    });
  });
}

/// テスト用: 常に asset 取得失敗を返す bundle。
class _MissingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('asset not found: $key');
  }
}

/// テスト用: メモリ上の文字列 asset を返す bundle。
class _InMemoryBundle extends CachingAssetBundle {
  _InMemoryBundle(this._strings);
  final Map<String, String> _strings;

  @override
  Future<ByteData> load(String key) async {
    final s = _strings[key];
    if (s == null) {
      throw FlutterError('not found: $key');
    }
    final bytes = Uint8List.fromList(s.codeUnits);
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final s = _strings[key];
    if (s == null) throw FlutterError('not found: $key');
    return s;
  }
}
