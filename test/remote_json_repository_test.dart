import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:oshi_suke/models/category.dart';
import 'package:oshi_suke/models/oshi_event.dart';
import 'package:oshi_suke/models/work.dart';
import 'package:oshi_suke/repositories/event_repository.dart';
import 'package:oshi_suke/repositories/remote_json_event_repository.dart';
import 'package:oshi_suke/repositories/remote_json_work_repository.dart';
import 'package:oshi_suke/repositories/work_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final url = Uri.parse('https://example.test/works.json');
  final eventsUrl = Uri.parse('https://example.test/events.json');

  group('RemoteJsonWorkRepository', () {
    test('returns parsed works on HTTP 200', () async {
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: _NeverCalledWorkFallback(),
        client: MockClient((req) async {
          expect(req.url, url);
          expect(req.headers['Accept'], contains('json'));
          return http.Response(
            '[{"id":"a","title":"Aタイトル","genre":"アニメ"}]',
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final works = await repo.fetchAll();
      expect(works, hasLength(1));
      expect(works.single.id, 'a');
      expect(works.single.title, 'Aタイトル');
    });

    test('falls back when HTTP returns non-200', () async {
      final fallback = _StubWorkFallback([
        const Work(id: 'fb', title: 'Fallback', genre: 'x'),
      ]);
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: fallback,
        client: MockClient((req) async => http.Response('oops', 500)),
      );
      final works = await repo.fetchAll();
      expect(works.single.id, 'fb');
      expect(fallback.callCount, 1);
    });

    test('falls back on network error', () async {
      final fallback = _StubWorkFallback([
        const Work(id: 'fb', title: 'Fallback', genre: 'x'),
      ]);
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: fallback,
        client: MockClient((req) async {
          throw const _FakeNetworkError('no network');
        }),
      );
      final works = await repo.fetchAll();
      expect(works.single.id, 'fb');
    });

    test('falls back when JSON is malformed', () async {
      final fallback = _StubWorkFallback([
        const Work(id: 'fb', title: 'Fallback', genre: 'x'),
      ]);
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: fallback,
        client: MockClient((req) async => http.Response('not json', 200)),
      );
      final works = await repo.fetchAll();
      expect(works.single.id, 'fb');
    });

    test('falls back on timeout', () async {
      final fallback = _StubWorkFallback([
        const Work(id: 'fb', title: 'Fallback', genre: 'x'),
      ]);
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: fallback,
        timeout: const Duration(milliseconds: 50),
        client: MockClient((req) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('[]', 200);
        }),
      );
      final works = await repo.fetchAll();
      expect(works.single.id, 'fb');
    });

    test('decodes UTF-8 body even without charset header', () async {
      const jsonStr =
          '[{"id":"x","title":"日本語タイトル","genre":"漫画"}]';
      final repo = RemoteJsonWorkRepository(
        url: url,
        fallback: _NeverCalledWorkFallback(),
        client: MockClient((req) async {
          // Content-Type に charset を付けず、UTF-8 バイト列で返す
          return http.Response.bytes(
            utf8.encode(jsonStr),
            200,
            headers: const {'content-type': 'application/json'},
          );
        }),
      );
      final works = await repo.fetchAll();
      expect(works.single.title, '日本語タイトル');
      expect(works.single.genre, '漫画');
    });
  });

  group('RemoteJsonEventRepository', () {
    test('returns parsed events on HTTP 200 with ISO dates', () async {
      final repo = RemoteJsonEventRepository(
        url: eventsUrl,
        fallback: _NeverCalledEventFallback(),
        client: MockClient((req) async => http.Response(
              '''
[
  {
    "id": "e1",
    "workId": "w1",
    "workTitle": "作品",
    "title": "イベント",
    "category": "cafe",
    "startDate": "2026-05-01",
    "endDate": "2026-05-31",
    "createdAt": "2026-04-01T00:00:00"
  }
]
''',
              200,
              headers: const {'content-type': 'application/json; charset=utf-8'},
            )),
      );
      final events = await repo.fetchAll();
      expect(events.single.id, 'e1');
      expect(events.single.startDate, DateTime(2026, 5, 1));
    });

    test('falls back when HTTP returns 404', () async {
      final fallback = _StubEventFallback([_dummyEvent()]);
      final repo = RemoteJsonEventRepository(
        url: eventsUrl,
        fallback: fallback,
        client: MockClient((req) async => http.Response('not found', 404)),
      );
      final events = await repo.fetchAll();
      expect(events.single.id, 'fb_event');
      expect(fallback.callCount, 1);
    });

    test('falls back when remote JSON has zero valid items', () async {
      final fallback = _StubEventFallback([_dummyEvent()]);
      final repo = RemoteJsonEventRepository(
        url: eventsUrl,
        fallback: fallback,
        client: MockClient((req) async => http.Response('[]', 200)),
      );
      final events = await repo.fetchAll();
      expect(events.single.id, 'fb_event');
    });
  });
}

OshiEvent _dummyEvent() => OshiEvent(
      id: 'fb_event',
      workId: 'w',
      workTitle: '作品',
      title: 'fb',
      category: OshiCategory.cafe,
      createdAt: DateTime(2026, 4, 1),
    );

class _NeverCalledWorkFallback implements WorkRepository {
  @override
  Future<List<Work>> fetchAll() async {
    fail('fallback should not be called when remote succeeds');
  }
}

class _NeverCalledEventFallback implements EventRepository {
  @override
  Future<List<OshiEvent>> fetchAll() async {
    fail('fallback should not be called when remote succeeds');
  }
}

class _StubWorkFallback implements WorkRepository {
  _StubWorkFallback(this.items);
  final List<Work> items;
  int callCount = 0;
  @override
  Future<List<Work>> fetchAll() async {
    callCount++;
    return items;
  }
}

class _StubEventFallback implements EventRepository {
  _StubEventFallback(this.items);
  final List<OshiEvent> items;
  int callCount = 0;
  @override
  Future<List<OshiEvent>> fetchAll() async {
    callCount++;
    return items;
  }
}

class _FakeNetworkError implements Exception {
  const _FakeNetworkError(this.message);
  final String message;
  @override
  String toString() => 'FakeNetworkError: $message';
}
