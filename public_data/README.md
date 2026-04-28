# public_data/

このフォルダの中身は **アプリにバンドルしません**。
代わりに **外部 URL に静的ホスティングして、アプリから HTTP 取得する** ための「公開用スナップショット」です。

```
このフォルダ                            アプリ起動時の取得順
─────────────────                     ────────────────────────────
public_data/works.json    ───upload→  [1] Remote URL (RemoteDataConfig.baseUrl)
public_data/events.json                       │ 失敗
                                              ▼
assets/data/works.json    ─bundled→   [2] アプリ内 asset (フォールバック)
assets/data/events.json                       │ 失敗
                                              ▼
lib/data/mock_*.dart      ─compiled→  [3] コード内 mock (最終フォールバック)
```

> 詳細仕様は [`docs/json_format.md`](../docs/json_format.md) を参照。

---

## 1. このフォルダの目的

| | `assets/data/` | `public_data/` (このフォルダ) |
|---|---|---|
| 用途 | アプリにバンドルされる **フォールバック** | 外部URLに公開する **本番データ** |
| 配信 | アプリビルドに同梱 | GitHub Pages / Firebase Hosting / GCS / S3 など |
| 反映タイミング | 次回ストアアップデート時 | アップロード後すぐ (キャッシュ次第) |
| 編集頻度 | リリース時のみ | 任意のタイミング (週次等) |

---

## 2. 編集ワークフロー

### 推奨: `public_data/` を Single Source of Truth にする

1. **ここ (`public_data/`) の JSON を編集する**
2. シンタックスチェック:
   ```bash
   python -m json.tool public_data/works.json > /dev/null
   python -m json.tool public_data/events.json > /dev/null
   ```
3. アプリ内バンドルにも反映 (= `assets/data/` にコピー):
   ```bash
   dart run tool/sync_data.dart
   ```
4. テスト:
   ```bash
   flutter test
   ```
5. 外部URLにアップロード (本ファイル §3 を参照)
6. (必要なら) アプリも再ビルドしてストアに提出

> `tool/sync_data.dart` は `public_data/*.json` を `assets/data/*.json` に **上書きコピー** します。逆方向 (`--reverse`) でも実行可能。

---

## 3. 外部URLへの公開手順

> **GitHub Pages を使う場合は専用ガイドを用意してあります**: [`docs/github_pages_setup.md`](../docs/github_pages_setup.md)
>
> 同一リポジトリでルート公開する最短パターン (10〜15 分)、
> GitHub Actions で URL を短くするパターン、
> データ専用リポジトリで完全分離するパターン、
> CORS / 404 / JSON 構文エラーなどのトラブルシューティングまで網羅しています。

ここでは「同一リポジトリ + ルート公開」の最短手順だけ転記します。

### A. GitHub Pages (同一リポジトリ + ルート公開・推奨)

1. このプロジェクト全体を GitHub に push
2. リポジトリの `Settings → Pages → Source = Deploy from a branch / main / (root)` で有効化
3. 数分後、以下の URL でアクセスできるようになる:
   ```
   https://your-name.github.io/oshi_suke/public_data/works.json
   https://your-name.github.io/oshi_suke/public_data/events.json
   ```
4. アプリ側の [`lib/config/remote_data_config.dart`](../lib/config/remote_data_config.dart) で **`baseUrl` の1か所だけ書き換える**:
   ```dart
   static const String? baseUrl =
       'https://your-name.github.io/oshi_suke/public_data';
   ```
5. `flutter run` で起動し、ログに `[Remote/...] OK ...` が出れば成功

### B. Firebase Hosting

```bash
firebase init hosting        # public ディレクトリは "public" のまま
cp public_data/*.json public/
firebase deploy --only hosting
# → https://your-project.web.app/works.json
```

### C. Cloud Storage (GCS / S3)

- バケットを **public read** に
- `Content-Type: application/json; charset=utf-8` を付ける
- 推奨 `Cache-Control: public, max-age=300`

```bash
# GCS の例
gcloud storage cp public_data/*.json gs://your-bucket/oshi-suke/ \
  --content-type=application/json \
  --cache-control="public, max-age=300"
```

---

## 4. Git で管理するべき？

**Yes**。このフォルダは「公開用スナップショットの真実の源」なので、リポジトリで履歴管理してください。
誰が何をいつ追加/変更/削除したかが追えるようになります。

---

## 5. 注意

- **`assets/data/` と内容が一致している必要は必ずしもありません** が、フォールバックの体験を保つために
  「リリースされている `public_data/` の最新版」と「同じ内容を `assets/data/` に焼き込む」運用を推奨します。
  そのためのヘルパが `tool/sync_data.dart` です。
- ファイルは **UTF-8 (BOM なし) で保存** してください。
- 配信先の `Content-Type` が `application/json` であることを確認してください
  (古い設定だと `text/plain` で配信され、文字化けする場合があります)。
