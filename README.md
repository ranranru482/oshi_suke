# 推しスケ (oshi_suke)

推し活・作品関連スケジュール管理アプリの Flutter MVP。
コラボカフェ、ポップアップ、一番くじ、予約販売、ライブ、円盤発売など、
推し関連の **予約開始・締切・開催期間** を見逃さないためのアプリです。

## 機能

- 5タブの BottomNavigation (ホーム / マイ作品 / カレンダー / 検索 / ブックマーク)
- 締切間近・開催中・近日開始の自動抽出
- 作品お気に入り、イベントブックマーク
- カレンダーで日付ごとのイベント表示
- カテゴリ・地域・通販有無での検索フィルタ
- 通知設定 (UI のみ、本実装は次フェーズ)

## 技術構成

- Flutter 3.41 / Dart 3.11
- 状態管理: Riverpod
- 主要パッケージ: `table_calendar`, `intl`, `url_launcher`, `http`
- 対応プラットフォーム: Android / iOS (Web は将来対応)

## データソース (3 段フォールバック)

```
[1] Remote URL  ──失敗→  [2] バンドル asset  ──失敗→  [3] mock データ
   (差し替え可能)            (常に同梱)               (最終フォールバック)
```

| 段 | 場所 | 用途 |
|---|---|---|
| Remote | `lib/config/remote_data_config.dart` の `baseUrl` で指定 | 本番データ。ストア審査なしで即時更新 |
| Asset | `assets/data/works.json` / `events.json` | アプリ同梱のフォールバック |
| Mock | `lib/data/mock_works.dart` / `mock_events.dart` | 最終セーフネット |

外部に公開するファイルは [`public_data/`](./public_data/) にあります。

## クイックスタート

```bash
flutter pub get
flutter run                  # 既定では asset → mock のみで動く
```

ログには取得元が以下のように表示されます。

```
[Asset/works]  OK   8件 3ms  ← assets/data/works.json
[Asset/events] OK   14件 5ms ← assets/data/events.json
```

## 外部 JSON で運用する

1. [`public_data/works.json`](./public_data/works.json) と
   [`public_data/events.json`](./public_data/events.json) を編集
2. 同期スクリプトで asset 側にも反映:
   ```bash
   dart run tool/sync_data.dart
   ```
3. `public_data/` の中身を任意のホスティング先 (GitHub Pages / Firebase Hosting /
   GCS / S3 / 自前サーバ) にアップロード
4. [`lib/config/remote_data_config.dart`](./lib/config/remote_data_config.dart) の
   `baseUrl` を **1か所だけ** 書き換える:
   ```dart
   static const String? baseUrl = 'https://your-name.github.io/oshi_suke/public_data';
   ```
5. `flutter run` で起動。ログに以下が出れば Remote 取得成功:
   ```
   [Remote/works]  OK   8件 245ms  ← https://your-name.github.io/oshi_suke/public_data/works.json
   [Remote/events] OK   14件 312ms ← https://your-name.github.io/oshi_suke/public_data/events.json
   ```

詳細手順は以下を参照:

- **[`docs/github_pages_setup.md`](./docs/github_pages_setup.md) — GitHub Pages 公開手順 (最短 10〜15 分)** ← 初めての人はここから
- [`docs/json_format.md`](./docs/json_format.md) — JSON フォーマット仕様 / 編集ルール / ホスティング比較
- [`public_data/README.md`](./public_data/README.md) — 公開フォルダの運用ガイド

## GitHub Pages 公開手順 (最短)

このリポジトリを GitHub に push して `public_data/` を GitHub Pages から配信するまでの最短手順です。

```bash
# 1) リポジトリを GitHub に push
git init && git add . && git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-name/oshi_suke.git
git push -u origin main
```

```
# 2) GitHub の Settings → Pages
#    Source = Deploy from a branch
#    Branch = main / (root)
#    Save
```

```dart
// 3) lib/config/remote_data_config.dart を 1 行だけ書き換え
static const String? baseUrl =
    'https://your-name.github.io/oshi_suke/public_data';
```

```bash
# 4) 起動して動作確認
flutter run
# ログに [Remote/works] OK / [Remote/events] OK が出れば成功
```

URL を `…/oshi_suke/works.json` のように短くしたい場合は、
同梱の [`.github/workflows/deploy-data.yml`](./.github/workflows/deploy-data.yml) を使う方式
([詳細は § 7](./docs/github_pages_setup.md#7-任意-github-actions-で-public_data-だけ配信する))
に切り替え可能。

つまずいたら → [`docs/github_pages_setup.md` § 6 トラブルシューティング](./docs/github_pages_setup.md#6-トラブルシューティング)

## プロジェクト構成

```
oshi_suke/
├─ lib/
│  ├─ app.dart                      # MaterialApp ルート、Bottom Navigation
│  ├─ main.dart                     # エントリーポイント
│  ├─ config/
│  │  └─ remote_data_config.dart    # 外部 URL / タイムアウト設定
│  ├─ data/
│  │  ├─ mock_works.dart            # 最終フォールバック (作品)
│  │  └─ mock_events.dart           # 最終フォールバック (イベント)
│  ├─ models/                       # Work, OshiEvent, Category, EventStatus
│  ├─ providers/                    # Riverpod プロバイダ
│  ├─ repositories/
│  │  ├─ work_repository.dart       # 抽象インターフェース
│  │  ├─ event_repository.dart
│  │  ├─ json_asset_*_repository.dart  # assets 経由
│  │  ├─ remote_json_*_repository.dart # 外部 URL 経由
│  │  └─ json_parsers.dart          # 共通パーサ
│  ├─ services/                     # ステータス自動判定 / 通知設定
│  ├─ theme/app_theme.dart          # アプリテーマ
│  ├─ views/                        # 各画面 (home, works, calendar, search, …)
│  └─ widgets/                      # 共通 UI
├─ assets/data/                     # アプリにバンドルするフォールバック JSON
├─ public_data/                     # 外部公開用スナップショット (アップロード元)
├─ docs/json_format.md              # JSON 仕様書
├─ tool/sync_data.dart              # public_data ⇄ assets/data 同期
└─ test/                            # 単体テスト
```

## テストとビルド

```bash
flutter analyze                # 静的解析
flutter test                   # 全単体テスト
flutter build apk --debug      # Android デバッグ APK
flutter build apk --release    # Android リリース APK

# JSON のシンタックス + 同期チェック (CI 推奨)
dart run tool/sync_data.dart --check
```

## 将来実装予定

- [ ] 公式サイト RSS / API / スクレイピング による自動収集
- [ ] AI による作品名ゆれ判定・キャラ名抽出・予約締切日抽出
- [ ] Firebase Cloud Messaging によるプッシュ通知
- [ ] Google カレンダー連携
- [ ] プレミアム会員 / 広告非表示 / アフィリエイト連携
