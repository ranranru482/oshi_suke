# 推しスケ JSON フォーマット仕様 / 更新手順

> このドキュメントは、推しスケアプリの作品 / イベント情報を保持する 2 つの JSON
> ファイル `works.json` と `events.json` の **書式・更新方法・公開手順** を、
> 開発者でなくても安全に編集できるようにまとめたものです。
>
> **対象読者**: コンテンツ更新担当 (運用) / フロントエンド開発者

---

## 0. 3行サマリー

- **作品**は `works.json`、**イベント / 商品**は `events.json` で管理する
- 日付はすべて **ISO8601 (例: `"2026-05-01"`)** で書く
- 書き換えたら 1) アプリにバンドル (assets) 2) 外部 URL に公開 のどちらかで反映する

---

## 1. ファイル構成

| 役割 | パス | サイズ目安 | 形式 |
|---|---|---|---|
| 公開用スナップショット | `public_data/works.json` `public_data/events.json` | 数百〜数千件 | JSON 配列 |
| アプリ同梱フォールバック | `assets/data/works.json` `assets/data/events.json` | 同上 | JSON 配列 |
| リモート設定 | `lib/config/remote_data_config.dart` | 1ファイル | Dart |
| 同期スクリプト | `tool/sync_data.dart` | 1ファイル | Dart |
| ドキュメント | `docs/json_format.md` (本ファイル) | — | Markdown |

> 編集時は `public_data/` を Single Source of Truth として使い、
> `dart run tool/sync_data.dart` で `assets/data/` に反映します。
> 詳細は [`public_data/README.md`](../public_data/README.md) 参照。

---

## 2. データ取得の優先順位

アプリ起動時、Repository は以下の順でデータを取りにいきます。

```
[1] Remote URL (RemoteDataConfig.worksJsonUrl / eventsJsonUrl)
       │ (取得失敗 / タイムアウト / JSON不正)
       ▼
[2] バンドル asset (assets/data/works.json / events.json)
       │ (asset未登録 / JSON不正 / パース成功0件)
       ▼
[3] mock (lib/data/mock_works.dart / mock_events.dart)
```

- **Remote URL を `null` にすると** [1] をスキップして [2] から始まります
- **JSON 内の 1 件だけ壊れても**、`events.json` はその行だけスキップして残りを生かします (`works.json` は厳密)
- **タイムアウト** はデフォルト 6 秒 ([RemoteDataConfig.networkTimeout](../lib/config/remote_data_config.dart))

---

## 3. `works.json`

### 3.1 スキーマ

| フィールド | 型 | 必須 | デフォルト | 説明 |
|---|---|---|---|---|
| `id` | string | ✅ | — | 作品の一意 ID。`w_` プレフィックス推奨 (例: `"w_kimetsu"`) |
| `title` | string | ✅ | — | 作品の正式タイトル |
| `aliases` | string[] | | `[]` | 別名 / 略称 / 英題。検索ヒット用 |
| `genre` | string | | `"その他"` | ジャンル (`"アニメ / 漫画"` `"ゲーム"` `"舞台"` 等、自由文字列) |
| `officialUrl` | string \| null | | `null` | 公式サイト URL |
| `imageUrl` | string \| null | | `null` | 作品画像 URL (MVP 未使用) |
| `isFavorite` | bool | | `false` | 起動直後にお気に入り扱いするか |
| `notificationEnabled` | bool | | `true` | 通知の初期 ON/OFF |

### 3.2 サンプル

```json
[
  {
    "id": "w_kimetsu",
    "title": "鬼滅の刃",
    "aliases": ["Kimetsu no Yaiba", "Demon Slayer"],
    "genre": "アニメ / 漫画",
    "officialUrl": "https://kimetsu.com/",
    "imageUrl": null,
    "isFavorite": true,
    "notificationEnabled": true
  },
  {
    "id": "w_genshin",
    "title": "原神",
    "aliases": ["Genshin Impact"],
    "genre": "ゲーム"
  }
]
```

> 2 件目のように、必須以外のフィールドは省略可能です。

---

## 4. `events.json`

### 4.1 スキーマ

| フィールド | 型 | 必須 | デフォルト | 説明 |
|---|---|---|---|---|
| `id` | string | ✅ | — | イベントの一意 ID。`e_` プレフィックス推奨 |
| `workId` | string | ✅ | — | 関連する作品の `id` (works.json と一致させる) |
| `workTitle` | string | ✅ | — | 表示用の作品名 (workId と整合させる) |
| `title` | string | ✅ | — | イベント / 商品名 |
| `category` | enum string | | `"other"` | 4.3 のカテゴリ一覧から選ぶ |
| `description` | string | | `""` | 概要文 (ネタバレ・公式本文の丸写しは避ける) |
| `startDate` | ISO8601 \| null | | `null` | 開催開始日 |
| `endDate` | ISO8601 \| null | | `null` | 開催終了日 |
| `reservationStartDate` | ISO8601 \| null | | `null` | 予約開始日 |
| `reservationEndDate` | ISO8601 \| null | | `null` | 予約締切日 |
| `releaseDate` | ISO8601 \| null | | `null` | 発売日 (グッズ・円盤など) |
| `location` | string \| null | | `null` | 場所 / 都道府県・市区町村 |
| `shopName` | string \| null | | `null` | 店舗・運営会社 |
| `officialUrl` | string \| null | | `null` | 公式サイト URL (詳細はここに飛ばす) |
| `imageUrl` | string \| null | | `null` | 画像 URL (MVP 未使用) |
| `price` | number \| null | | `null` | 価格 (円。整数推奨) |
| `hasOnlineShop` | bool | | `false` | 通販あり |
| `hasPhysicalEvent` | bool | | `false` | 現地開催 / 実店舗あり |
| `source` | string \| null | | `null` | 情報ソース (`"manual"` `"twitter"` 等の任意タグ) |
| `isOfficial` | bool | | `true` | 公式情報か (false = ファン情報・噂) |
| `tags` | string[] | | `[]` | 検索 / フィルタ用タグ (例: `["渋谷", "描き下ろし"]`) |
| `isBookmarked` | bool | | `false` | 起動直後にブックマーク扱いするか |
| `createdAt` | ISO8601 | | `DateTime.now()` | 情報追加日時 (「今日の新着」抽出に使用) |

### 4.2 サンプル

```json
[
  {
    "id": "e_kimetsu_cafe",
    "workId": "w_kimetsu",
    "workTitle": "鬼滅の刃",
    "title": "鬼滅の刃 × コラボカフェ 渋谷",
    "category": "cafe",
    "description": "原作描き下ろしビジュアルを使用したコラボメニュー＆限定グッズが登場。",
    "startDate": "2026-04-19",
    "endDate": "2026-05-17",
    "reservationStartDate": "2026-04-05",
    "reservationEndDate": "2026-05-24",
    "releaseDate": null,
    "location": "東京都渋谷区",
    "shopName": "コラボカフェSHIBUYA",
    "officialUrl": "https://example.com/kimetsu-cafe",
    "price": null,
    "hasOnlineShop": false,
    "hasPhysicalEvent": true,
    "source": "manual",
    "isOfficial": true,
    "tags": ["渋谷", "描き下ろし"],
    "isBookmarked": false,
    "createdAt": "2026-03-27T00:00:00"
  },
  {
    "id": "e_oshinoko_bluray",
    "workId": "w_oshinoko",
    "workTitle": "推しの子",
    "title": "【推しの子】第2期 Blu-ray BOX 発売",
    "category": "bluRay",
    "reservationStartDate": "2026-03-27",
    "reservationEndDate": "2026-06-05",
    "releaseDate": "2026-06-10",
    "shopName": "アニプレックス",
    "officialUrl": "https://example.com/oshinoko-bd",
    "price": 28800,
    "hasOnlineShop": true,
    "tags": ["Blu-ray", "受注生産"],
    "createdAt": "2026-03-17T00:00:00"
  }
]
```

### 4.3 カテゴリ一覧 (`category`)

`category` は **必ず以下のいずれかを文字列で指定** してください (大文字小文字の違いに注意)。
未知の値は自動的に `"other"` 扱いになります。

| 値 (JSON) | 表示ラベル | アイコン | 主な用途 |
|---|---|---|---|
| `"cafe"` | コラボカフェ | ☕ | コラボカフェ |
| `"goods"` | 新作グッズ | 🛍️ | 一般販売の新作グッズ |
| `"popupStore"` | ポップアップ | 🏬 | ポップアップストア |
| `"exhibition"` | 展示会 | 🖼️ | 原画展・記念展 |
| `"lottery"` | 一番くじ | 🎲 | 一番くじ |
| `"preorder"` | 予約販売 | 📦 | 期間限定予約販売 |
| `"madeToOrder"` | 受注生産 | ⚙️ | 受注生産フィギュア等 |
| `"live"` | ライブ | 🎵 | コンサート・ライブ |
| `"stage"` | 舞台 | 🎭 | 舞台・朗読劇 |
| `"streaming"` | 配信開始 | 📺 | アニメ配信開始 |
| `"bluRay"` | 円盤発売 | 💿 | Blu-ray / DVD |
| `"campaign"` | キャンペーン | 📣 | コンビニ・コラボキャンペーン |
| `"other"` | その他 | 📁 | どれにも当てはまらないもの |

> ⚠️ `"BluRay"` `"blu_ray"` `"bluray"` は無効。**必ず `"bluRay"` (camelCase)** で書いてください。

### 4.4 ステータス自動判定

`events.json` 側でステータスを書く必要はありません。
日付フィールドからアプリが自動で次のステータスを算出します
([lib/services/event_status_service.dart](../lib/services/event_status_service.dart))。

| ステータス | 表示 | 判定条件 |
|---|---|---|
| `active` | 開催中 | `startDate ≤ today ≤ endDate` |
| `deadlineSoon` | 締切間近 | 予約締切まで **7日以内** |
| `reservationOpen` | 予約受付中 | `reservationStartDate ≤ today ≤ reservationEndDate` |
| `upcoming` | 近日開始 | 開催 / 発売まで **30日以内** |
| `reservationBefore` | 予約受付前 | 予約開始がまだ未来 |
| `ended` | 終了 | すべての期日が過去 |

---

## 5. 日付フォーマット (ISO8601)

**必ず ISO8601 文字列で書きます。** タイムゾーン情報なしの「日付のみ」が推奨です。

| 形式 | 例 | 推奨度 | 備考 |
|---|---|---|---|
| 日付のみ | `"2026-05-01"` | ★★★ | 最も簡潔。`createdAt` 以外はこれで十分 |
| 日付 + 時刻 | `"2026-05-01T00:00:00"` | ★★ | `createdAt` でこちらを使うと並び順が安定 |
| ISO8601 + Z | `"2026-05-01T00:00:00Z"` | ★ | UTC として扱われる。タイムゾーンを意識しない場合は避ける |
| 日本式 | `"2026/05/01"` | ❌ | パース不可。**使用禁止** |
| Unix秒 | `1748736000` | ❌ | パース不可 |

> **時刻を書くなら必ず `T` で区切る** (`"2026-05-01 00:00:00"` のように半角スペースで区切ると DateTime.parse でエラーになる場合があります)

### 5.1 日付を書かない (null) ケース

- 開催期間がないグッズ → `startDate / endDate` を `null`
- 予約不要のキャンペーン → `reservationStartDate / reservationEndDate` を `null`
- 予約だけで開催はない → `startDate / endDate` を `null`、`releaseDate` を埋める

---

## 6. よくあるミスと対処

### 6.1 JSON 構文エラー

| ミス | 例 | 修正 |
|---|---|---|
| 末尾カンマ | `[{...},]` | `[{...}]` カンマを消す |
| シングルクォート | `'id': 'a'` | `"id": "a"` ダブルクォートに直す |
| キーをクォートしない | `{ id: "a" }` | `{ "id": "a" }` |
| 全角クォート | `“id”` | `"id"` 半角に直す |
| `null` を `"null"` | `"price": "null"` | `"price": null` クォート無し |

### 6.2 値の型ミス

| ミス | 例 | 修正 |
|---|---|---|
| 価格に「円」 | `"price": "1000円"` | `"price": 1000` |
| bool が文字列 | `"isOfficial": "true"` | `"isOfficial": true` |
| 配列が空文字 | `"tags": ""` | `"tags": []` または項目を省略 |
| URL が空文字 | `"officialUrl": ""` | `"officialUrl": null` または項目を省略 |

### 6.3 関連 / 整合性ミス

| ミス | 影響 | 対処 |
|---|---|---|
| `workId` が works.json に存在しない | 「マイ作品」絞り込みでヒットしない | works.json に該当 id を追加するか、表記を一致させる |
| `workTitle` が works.json と違う | カードの作品名表示がブレる | 一致させる |
| `id` が他イベントと重複 | 後勝ちで上書きされる可能性 | 接頭辞 + ユニーク文字列で衝突回避 |
| `category` のスペル違い | `other` 扱いになる | 4.3 の表からコピペする |
| `startDate > endDate` | ステータス算出が不安定 | 入れ替える |

### 6.4 文字エンコーディング

- ファイルは **必ず UTF-8 (BOM なし) で保存** してください
- VSCode の場合: 右下のステータスバー → 「UTF-8」をクリック → "Save with Encoding" → "UTF-8"
- メモ帳 (Windows) は BOM 付きで保存しがち → VSCode / Notepad++ / メモ帳++ を推奨

### 6.5 検証方法

JSON を書き換えたら、コミット前に必ずバリデートしてください。

```bash
# 1. JSON 構文チェック (どの OS でも動く)
python -m json.tool assets/data/events.json > /dev/null

# 2. アプリでパースが通るか確認
flutter test test/json_repository_test.dart

# 3. 実機・エミュレータで起動確認
flutter run
```

---

## 7. JSON 更新フロー

ユースケースは2パターンあります。

### 7.1 アプリにバンドルする (= asset 経由)

**長所**: オフラインでも動く / 確実 / リリースのたびに最新化
**短所**: 反映には新ビルド + ストア審査が必要

1. `assets/data/works.json` または `assets/data/events.json` を編集
2. `python -m json.tool ...` でバリデート
3. `flutter test` で全テストが通ることを確認
4. `flutter build apk --release` (or `appbundle`) で再ビルド
5. ストアに提出

### 7.2 外部 URL に置く (= remote 経由)

**長所**: ストア審査なしで即時反映 / 何度でも更新可能
**短所**: ネット接続が必要 / サーバの可用性が必要

#### A. GitHub Pages を使う場合 (無料・推奨)

```bash
# 1. 公開用リポジトリを作る (例: https://github.com/your-org/oshi-suke-data)
# 2. リポジトリ直下に works.json と events.json を置く
git clone https://github.com/your-org/oshi-suke-data.git
cd oshi-suke-data
cp /path/to/works.json .
cp /path/to/events.json .
git add . && git commit -m "Update data" && git push
```

GitHub の `Settings → Pages` で `main` ブランチを公開対象にすると、
URL は次のようになります:

```
https://your-org.github.io/oshi-suke-data/works.json
https://your-org.github.io/oshi-suke-data/events.json
```

> ⚠️ ファイルが UTF-8 で配信されることを確認してください。
> 念のため `.github/workflows/` で Content-Type ヘッダの検証を回しておくと安心です。

#### B. Firebase Hosting

```bash
# 1. プロジェクトを初期化
firebase init hosting   # public ディレクトリは "public" のまま

# 2. JSON を置いてデプロイ
cp works.json events.json public/
firebase deploy --only hosting
```

URL は `https://your-project.web.app/works.json` のようになります。

#### C. Cloud Storage (GCS / S3)

- バケットを **public read** に設定
- オブジェクトの `Content-Type` を `application/json; charset=utf-8` に設定
- `Cache-Control: public, max-age=300` 程度を推奨 (短すぎると料金、長すぎると更新が遅延)

```bash
# GCS の例
gcloud storage cp works.json gs://your-bucket/oshi-suke/ \
  --content-type=application/json \
  --cache-control="public, max-age=300"
```

#### D. 自前サーバ (任意の HTTP/HTTPS)

要件:
- `https://` (HTTP は Android 9+ で原則ブロック)
- `Content-Type: application/json` を返す
- CORS は気にしなくて OK (Flutter Web 以外はブラウザ経由ではないため)

---

## 8. `remote_data_config.dart` の設定方法

[lib/config/remote_data_config.dart](../lib/config/remote_data_config.dart) を開いて URL を埋めるだけで Remote 取得が有効になります。

### 8.1 現状 (Remote 無効)

```dart
class RemoteDataConfig {
  static const String? worksJsonUrl = null;
  static const String? eventsJsonUrl = null;
  static const Duration networkTimeout = Duration(seconds: 6);
  static const String userAgent = 'OshiSuke/1.0 (Flutter; +https://example.com)';
}
```

`null` のままだと Remote をスキップして asset → mock の順でフォールバック。

### 8.2 Remote 有効化

```dart
class RemoteDataConfig {
  static const String? worksJsonUrl =
      'https://your-org.github.io/oshi-suke-data/works.json';
  static const String? eventsJsonUrl =
      'https://your-org.github.io/oshi-suke-data/events.json';
  static const Duration networkTimeout = Duration(seconds: 6);
  static const String userAgent = 'OshiSuke/1.0 (Flutter; +https://example.com)';
}
```

### 8.3 タイムアウトの調整

- 国内 GitHub Pages / Firebase Hosting: 4〜6 秒で十分
- 海外オリジンや低速回線想定: 10〜15 秒
- これを超えるとフォールバック扱いになります

### 8.4 反映確認

```bash
flutter run
# ログに以下が出れば Remote 取得成功:
#   [RemoteJsonWorkRepository] https://... から N 件取得成功
#   [RemoteJsonEventRepository] https://... から N 件取得成功
#
# fallback 時はこちら:
#   [RemoteJsonWorkRepository] ... 取得失敗。fallback へ委譲: ...
```

---

## 9. テスト方法

| 目的 | コマンド |
|---|---|
| JSON シンタックス検証 | `python -m json.tool assets/data/events.json > /dev/null` |
| パーサ往復テスト | `flutter test test/json_repository_test.dart` |
| Remote リポジトリ (MockClient) | `flutter test test/remote_json_repository_test.dart` |
| 全テスト | `flutter test` |
| 静的解析 | `flutter analyze` |
| デバッグ APK ビルド | `flutter build apk --debug` |

---

## 10. トラブルシューティング

### Q. アプリの一覧が空 / 仮データのまま
- `flutter logs` (or `flutter run` のコンソール) を確認
  - `[JsonAssetEventRepository] ... 読み込みに失敗` → JSON 構文不正の可能性大
  - `[RemoteJsonEventRepository] ... 取得失敗` → URL 到達不可・タイムアウト
- `python -m json.tool` で JSON を検証

### Q. 一部の作品だけ表示されない
- `events.json` 側の `workId` が `works.json` の `id` と完全一致しているか確認
- 表記ゆれ (全角・半角・スペース) もチェック

### Q. 締切間近に出てこない
- `reservationEndDate` が ISO8601 で書かれているか
- 「7日以内 = `today + 7日`」までの判定。未来日付すぎると出ない

### Q. Android 9+ で Remote 取得が失敗する
- HTTP (非 SSL) は原則拒否。**`https://` で配信する**
- それでもダメな場合は `android/app/src/main/res/xml/network_security_config.xml` で許可

### Q. iOS で Remote 取得が失敗する
- ATS (App Transport Security) で HTTP がブロックされる
- `ios/Runner/Info.plist` で `NSAllowsArbitraryLoads` を許可するか、HTTPS に統一

### Q. JSON を更新したのに反映されない (asset 経由)
- `flutter clean && flutter pub get && flutter run` を実行
- アプリのキャッシュではなく、ビルドキャッシュのほうが疑わしい

### Q. JSON を更新したのに反映されない (remote 経由)
- ホスティング側のキャッシュ (CDN) を確認
- `Cache-Control: max-age=300` を超える間は古いまま
- Cloud Storage の場合は `gsutil setmeta -h "Cache-Control:no-cache" ...` で即時無効化可能

---

## 付録 A. 完成形ミニマル例

最小限のフィールドだけで動く `events.json`:

```json
[
  {
    "id": "e_min",
    "workId": "w_kimetsu",
    "workTitle": "鬼滅の刃",
    "title": "テストイベント",
    "category": "cafe",
    "createdAt": "2026-04-26"
  }
]
```

これだけで「予約受付前」 (期日全部 null = `ended` 扱いではあるが) として表示されます。
動作確認用に最小スキーマで JSON を組み立てたいときに便利。

---

## 付録 B. 仕様変更履歴

| 日付 | 変更内容 |
|---|---|
| 2026-04-27 | 初版 (MVP リリース時点の仕様) |
