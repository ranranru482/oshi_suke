// 推しスケのデータ同期スクリプト。
//
// 使い方:
//   dart run tool/sync_data.dart            # public_data → assets (デフォルト)
//   dart run tool/sync_data.dart --reverse  # assets → public_data
//   dart run tool/sync_data.dart --check    # 差分があれば終了コード 1 (CI で使う)
//
// 目的:
//   - public_data/*.json (外部公開用) と assets/data/*.json (アプリバンドル用) は
//     同じ内容にしておくのが理想。
//   - 手動コピー忘れを防ぐためのヘルパ。
//
// このスクリプトは Flutter SDK ではなく素の Dart で動くため、CI でも軽快に実行可能。

import 'dart:convert';
import 'dart:io';

const _publicDir = 'public_data';
const _assetDir = 'assets/data';
const _files = ['works.json', 'events.json'];

Future<void> main(List<String> args) async {
  final reverse = args.contains('--reverse');
  final checkOnly = args.contains('--check');

  // 実行ディレクトリの妥当性を軽く検証
  if (!Directory(_publicDir).existsSync() ||
      !Directory(_assetDir).existsSync()) {
    stderr.writeln(
        '✗ プロジェクトルートで実行してください ($_publicDir / $_assetDir が見つかりません)');
    exit(2);
  }

  final from = reverse ? _assetDir : _publicDir;
  final to = reverse ? _publicDir : _assetDir;

  stdout.writeln('=== 推しスケデータ同期 ===');
  stdout.writeln('  source : $from');
  stdout.writeln('  target : $to');
  stdout.writeln('  mode   : ${checkOnly ? "check" : "sync"}');
  stdout.writeln('');

  var hasDiff = false;

  for (final name in _files) {
    final src = File('$from/$name');
    final dst = File('$to/$name');

    if (!src.existsSync()) {
      stderr.writeln('✗ $name : source が存在しません: ${src.path}');
      exit(1);
    }

    final raw = src.readAsStringSync();

    // JSON シンタックスを軽くバリデート
    try {
      final decoded = json.decode(raw);
      if (decoded is! List) {
        stderr.writeln('✗ $name : JSON ルートが List ではありません');
        exit(1);
      }
      stdout.writeln('  ✓ $name : ${decoded.length} 件 / ${raw.length} bytes');
    } on FormatException catch (e) {
      stderr.writeln('✗ $name : JSON 構文エラー: $e');
      exit(1);
    }

    final dstRaw = dst.existsSync() ? dst.readAsStringSync() : '';
    if (dstRaw == raw) {
      stdout.writeln('    → 既に同一なのでスキップ');
      continue;
    }

    hasDiff = true;
    if (checkOnly) {
      stdout.writeln('    △ 差分あり (--check のためコピーしない)');
    } else {
      dst.parent.createSync(recursive: true);
      dst.writeAsStringSync(raw);
      stdout.writeln('    → コピー完了 → ${dst.path}');
    }
  }

  stdout.writeln('');
  if (checkOnly && hasDiff) {
    stderr.writeln('✗ 差分が検出されました。`dart run tool/sync_data.dart` で同期してください。');
    exit(1);
  }

  stdout.writeln('完了。');
}
