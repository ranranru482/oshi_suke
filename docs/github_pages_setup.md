# GitHub Pages で `public_data/` を公開する手順

このドキュメントは、推しスケアプリの `public_data/works.json` と
`public_data/events.json` を **GitHub Pages にホスティングして、アプリから HTTP 取得する**
までを最短経路でまとめたものです。

> **対象**: GitHub アカウントを持っていて、`flutter run` ができる人
> **所要時間**: 10〜15分

---

## 0. 全体像

```
┌────────────────────────────┐                ┌──────────────────────────┐
│   GitHub リポジトリ          │   git push     │  GitHub Pages (静的配信)  │
│                            │ ────────────→  │                          │
│  oshi_suke/                │                │  https://your-name.github│
│   ├─ lib/                  │                │  .io/oshi_suke/...       │
│   ├─ public_data/          │   Pages 配信    │                          │
│   │   ├─ works.json   ─────┼────────────────→ /public_data/works.json  │
│   │   └─ events.json  ─────┼────────────────→ /public_data/events.json │
│   └─ ...                   │                │                          │
└────────────────────────────┘                └────────────┬─────────────┘
                                                            │ HTTP GET
                                                            ▼
                                              ┌──────────────────────────┐
                                              │  推しスケアプリ            │
                                              │  (Flutter Mobile / Web)   │
                                              │  RemoteDataConfig.baseUrl │
                                              └──────────────────────────┘
```

3 つのパターンから選べますが、**最初は § 2 の「同一リポジトリ + ルート公開」が最も簡単**です。

| 方式 | URL 形式 | 設定難易度 | 備考 |
|---|---|---|---|
| § 2. 同一リポジトリ + ルート公開 | `…/oshi_suke/public_data/works.json` | ★ | 設定 1 クリック。最初はこれで OK |
| § 7. GitHub Actions で `public_data/` だけ配信 | `…/oshi_suke/works.json` | ★★ | URL を短くしたい人向け |
| § 8. データ専用リポジトリ | `…/oshi-suke-data/works.json` | ★★ | アプリ本体と分離したい人向け |

---

## 1. GitHub リポジトリの想定構成

GitHub に push する状態のディレクトリ構成は次のようになります。

```
oshi_suke/                     ← リポジトリのルート (ここを GitHub に push)
├─ .github/
│  └─ workflows/
│     └─ deploy-data.yml       ← (任意) § 7 で使う workflow
├─ android/
├─ assets/
│  └─ data/
│     ├─ works.json            ← アプリ同梱 (フォールバック)
│     └─ events.json
├─ docs/
│  ├─ json_format.md
│  └─ github_pages_setup.md    ← 本ファイル
├─ ios/
├─ lib/
├─ public_data/                ← ここが GitHub Pages 公開対象
│  ├─ README.md
│  ├─ works.json               ← 公開する JSON (本番)
│  └─ events.json              ← 公開する JSON (本番)
├─ test/
├─ tool/
│  └─ sync_data.dart
├─ pubspec.yaml
└─ README.md
```

> リポジトリ名は `oshi_suke` でも `my-oshi-app` でも何でも OK。
> 以降の URL 例では `oshi_suke` を使います。

---

## 2. 公開手順 (推奨: 同一リポジトリ + ルート公開)

### Step 1. リポジトリを GitHub に push

ローカルに git 履歴がない場合:

```bash
cd "F:/アプリ開発/oshi_suke"
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-name/oshi_suke.git
git push -u origin main
```

> **`your-name`** はあなたの GitHub アカウント名 / 組織名に置き換えてください。

### Step 2. GitHub Pages を有効化

ブラウザで GitHub の該当リポジトリを開き、

1. **Settings** タブをクリック
2. 左メニューの **Pages**
3. **Build and deployment** セクション:
   - **Source**: `Deploy from a branch`
   - **Branch**: `main` / **`/(root)`**
4. **Save**

数分待つと、ページ上部に
> Your site is live at `https://your-name.github.io/oshi_suke/`

と表示されます。

### Step 3. JSON URL を確認

ブラウザで以下にアクセスして、JSON が表示されれば成功:

```
https://your-name.github.io/oshi_suke/public_data/works.json
https://your-name.github.io/oshi_suke/public_data/events.json
```

**404** が出る場合:
- まだ Pages のビルドが走っていない (5分ほど待つ)
- Branch / フォルダ設定を再確認
- ファイルが本当に push されているか `git ls-files | grep public_data` で確認

---

## 3. URL の例

| 用途 | URL |
|---|---|
| Pages トップ | `https://your-name.github.io/oshi_suke/` |
| works.json | `https://your-name.github.io/oshi_suke/public_data/works.json` |
| events.json | `https://your-name.github.io/oshi_suke/public_data/events.json` |
| **`baseUrl` に設定する値** | **`https://your-name.github.io/oshi_suke/public_data`** |

> `baseUrl` に `/public_data` までを含めると、アプリ側のパス指定 (`worksPath = '/works.json'`)
> と組み合わさって正しい URL になります。

### 別の URL パターンの例

| シナリオ | リポジトリ名 | baseUrl |
|---|---|---|
| 個人アカウント・推し記録用 | `oshi-data` | `https://your-name.github.io/oshi-data/public_data` |
| 組織アカウント | (org: `oshi-team`) | `https://oshi-team.github.io/oshi_suke/public_data` |
| 専用ドメイン (CNAME) | — | `https://data.oshi-suke.example.com/public_data` |
| § 7 の Actions 経由 | `oshi_suke` | `https://your-name.github.io/oshi_suke` |
| § 8 の専用リポジトリ | `oshi-suke-data` | `https://your-name.github.io/oshi-suke-data` |

---

## 4. アプリ側の設定 (`lib/config/remote_data_config.dart`)

公開された URL を **`baseUrl` の 1 行だけ** 書き換えます。

```dart
class RemoteDataConfig {
  // before
  // static const String? baseUrl = null;

  // after  ── GitHub Pages のルート公開を使う場合
  static const String? baseUrl =
      'https://your-name.github.io/oshi_suke/public_data';

  static const String worksPath = '/works.json';
  static const String eventsPath = '/events.json';

  static const Duration networkTimeout = Duration(seconds: 6);
  static const String userAgent = 'OshiSuke/1.0 (Flutter; +https://example.com)';
}
```

書き換え後、`worksJsonUrl` と `eventsJsonUrl` は自動で

```
https://your-name.github.io/oshi_suke/public_data/works.json
https://your-name.github.io/oshi_suke/public_data/events.json
```

になります (末尾スラッシュ有無は内部で正規化されます)。

> **末尾にスラッシュは不要 (あっても OK)**:
> `…/public_data` でも `…/public_data/` でもどちらでも動きます。

---

## 5. 動作確認手順

### 5.1 ブラウザでの直接確認

まず GitHub Pages 側で JSON が読めることを確認します。

```
https://your-name.github.io/oshi_suke/public_data/works.json
```

- ✅ ブラウザに JSON 配列が表示される
- ✅ 開発者ツール → Network → Headers で:
  - `Content-Type: application/json; charset=utf-8`
  - `Status: 200`
  - `Access-Control-Allow-Origin: *` (Web から読む場合のみ重要)

### 5.2 アプリでの確認

```bash
flutter run
```

成功時のコンソールログ:

```
[Remote/works]  OK   8件 245ms ← https://your-name.github.io/oshi_suke/public_data/works.json
[Remote/events] OK   14件 312ms ← https://your-name.github.io/oshi_suke/public_data/events.json
```

`OK` が出れば Remote 取得成功です。
ホーム画面で締切間近・開催中などのカードが表示されることも確認してください。

### 5.3 失敗時のログ

```
[Remote/works] FAIL 5012ms ← https://… (reason: TimeoutException after 0:00:06.000000: Future not completed)
[Remote/works] → fallback (asset/mock) へ委譲
[Asset/works]  OK   8件 4ms ← assets/data/works.json
```

→ アプリは fallback で動作するので **クラッシュはしない** ことを確認しましょう。

---

## 6. トラブルシューティング

### ❌ ブラウザで 404 / `https://…/public_data/works.json` が見えない

| チェック | 対処 |
|---|---|
| ファイルが push されているか | `git ls-files | grep public_data` で確認 |
| GitHub Pages が有効か | Settings → Pages で `Your site is live at …` が出ているか |
| Branch / フォルダ設定 | `main` ブランチ・`/(root)` になっているか |
| ビルドが走ったか | Actions タブで `pages-build-deployment` が緑か |
| 待ち時間 | 初回反映に 5〜10 分かかることがある |
| URL のタイポ | アカウント名・リポジトリ名・大文字小文字 |

### ❌ アプリで `[Remote/...] FAIL`

| 原因 | ログの reason | 対処 |
|---|---|---|
| URL タイポ | `HTTP 404` | baseUrl の値を再確認 |
| ホスト名違い | `Failed host lookup` | `your-name.github.io` のスペル確認 |
| HTTPS 証明書 | `HandshakeException` | GitHub Pages は問題ないはず。プロキシ環境を確認 |
| タイムアウト | `TimeoutException` | 回線が遅い → `RemoteDataConfig.networkTimeout` を 12 秒等に伸ばす |
| Android で HTTP | `cleartextNotPermitted` | GitHub Pages は HTTPS 強制なのでこれは出ないはず。出たら HTTPS で配信されているか確認 |
| JSON 構文不正 | `FormatException: Unexpected character` | `docs/json_format.md` § 6 を見て直す |
| パース 0件 | `events JSON から1件もパースできませんでした` | カテゴリのスペル違いで全件 skip された可能性。§ 4.3 のカテゴリ表を確認 |

### ❌ CORS エラーが出る (Flutter Web 限定)

| 状況 | 対処 |
|---|---|
| GitHub Pages から取得 | GitHub Pages は静的ファイルに対し `Access-Control-Allow-Origin: *` を自動付与。**設定不要** |
| 別ドメインで配信 | サーバ側で `Access-Control-Allow-Origin: *` ヘッダを付ける必要あり |
| Mobile (Android/iOS) | **CORS は関係なし**。ブラウザのセキュリティ機構なので、ネイティブHTTP には影響しない |

### ❌ JSON 形式エラー

事前にローカルで検証してから push する習慣をつけると安全です。

```bash
# 1) シンタックスチェック
python -m json.tool public_data/works.json > /dev/null
python -m json.tool public_data/events.json > /dev/null

# 2) アプリでの差分確認
dart run tool/sync_data.dart --check

# 3) 実際にパースしてテスト
flutter test test/json_repository_test.dart
```

### ❌ JSON を更新したのに古いまま反映される

GitHub Pages は **Fastly CDN によるキャッシュ** を持っています (10 分程度)。

| 強制更新 | 方法 |
|---|---|
| クエリパラメータでバスト | `worksPath = '/works.json?v=20260428'` のようにバージョンを付ける |
| 待つ | 10〜15 分後に再取得 |
| Actions の場合 | workflow_dispatch で再デプロイ |

### ❌ 個別の作品/イベントが出ない

- `events.json` の `workId` が `works.json` の `id` と一致しているか
- カテゴリ名のスペル違い (`"BluRay"` × → `"bluRay"` ○)
- 詳細は [`docs/json_format.md`](./json_format.md) § 6.3

---

## 7. (任意) GitHub Actions で `public_data/` だけ配信する

URL を `…/oshi_suke/works.json` のように短くしたい場合は、
[`.github/workflows/deploy-data.yml`](../.github/workflows/deploy-data.yml) を使います。
このリポジトリには既に同梱済みなので、以下の手順だけで切り替え可能です。

### 切り替え手順

1. GitHub の Settings → Pages → **Source** を `GitHub Actions` に変更
2. `git push` すると workflow が走り、`public_data/` の中身だけが配信される
3. URL 例:
   ```
   https://your-name.github.io/oshi_suke/works.json
   https://your-name.github.io/oshi_suke/events.json
   ```
4. `RemoteDataConfig.baseUrl` を更新:
   ```dart
   static const String? baseUrl = 'https://your-name.github.io/oshi_suke';
   ```

### Workflow の中身 (要約)

```yaml
on:
  push:
    branches: [main]
    paths: ['public_data/**']
permissions:
  pages: write
  id-token: write
jobs:
  deploy:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v4
      - uses: actions/upload-pages-artifact@v3
        with: { path: public_data }
      - uses: actions/deploy-pages@v4
```

`public_data/**` への push でだけ走るので、コード変更時に余計なデプロイが走りません。

---

## 8. (任意) データ専用リポジトリで配信する

アプリ本体のリポジトリと分けたい場合のオプションです。

```bash
# 1) 新リポジトリを作る (例: oshi-suke-data)
# 2) public_data/ の中身だけを丸ごとコピー
mkdir oshi-suke-data && cd oshi-suke-data
cp /path/to/oshi_suke/public_data/*.json .
git init && git add . && git commit -m "Initial data"
git remote add origin https://github.com/your-name/oshi-suke-data.git
git push -u origin main
# 3) GitHub Settings → Pages → main / (root) で有効化
# 4) URL:
#    https://your-name.github.io/oshi-suke-data/works.json
#    https://your-name.github.io/oshi-suke-data/events.json
# 5) baseUrl を設定:
#    static const String? baseUrl = 'https://your-name.github.io/oshi-suke-data';
```

**メリット**:
- アプリの公開リポジトリと分離されるので、データ更新で不要なビルドが走らない
- データ更新権限を別チームに渡せる
- 将来 CMS から書き戻すなどの自動化が組みやすい

**デメリット**:
- 同期管理が増える (`tool/sync_data.dart` だけでは追いきれない)

---

## 9. 通常の更新フロー (Pages 公開後)

```
1. public_data/works.json or events.json を編集
2. python -m json.tool public_data/works.json > /dev/null  ← 構文チェック
3. dart run tool/sync_data.dart                            ← assets/data にも反映
4. flutter test                                             ← 全テスト緑を確認
5. git add public_data assets/data
   git commit -m "Update data: 鬼滅の刃 新コラボカフェを追加"
   git push
6. (10分以内に) Pages 反映 → アプリの次回起動時に新データが届く
```

---

## 10. (参考) ローカル開発との切り替え

開発中は Remote を **無効化** して動作確認したい時もあります。

| 状態 | `baseUrl` | 取得元 |
|---|---|---|
| 開発中・Remote 無効 | `null` | asset (常に同梱の JSON) |
| 本番・Remote 有効 | `'https://your-name.github.io/oshi_suke/public_data'` | Remote → 失敗時 asset → 失敗時 mock |
| 別環境 (staging 等) | `'https://your-name.github.io/oshi-suke-staging/public_data'` | 同上 |

将来的に `--dart-define` を使った環境切替への移行も簡単です:

```dart
static const String? baseUrl =
    String.fromEnvironment('OSHISUKE_BASE_URL').isEmpty
        ? null
        : String.fromEnvironment('OSHISUKE_BASE_URL');
```

```bash
flutter run --dart-define=OSHISUKE_BASE_URL=https://your-name.github.io/oshi_suke/public_data
```

---

## 付録: チートシート

```bash
# 公開
git add public_data && git commit -m "Update data" && git push

# ローカル検証
python -m json.tool public_data/works.json > /dev/null
python -m json.tool public_data/events.json > /dev/null
dart run tool/sync_data.dart --check
flutter test

# Remote 動作確認
flutter run                            # ログに [Remote/...] OK が出れば成功
curl -I https://your-name.github.io/oshi_suke/public_data/works.json
# → HTTP/2 200 / content-type: application/json; charset=utf-8
```
