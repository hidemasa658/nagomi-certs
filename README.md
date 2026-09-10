# なごみ株式会社 admin 電子証明書 配布

**用途:** `nagomi-admin.duckdns.org` にアクセスするための クライアント証明書 (mTLS)

## ダウンロード

このリポジトリの `nagomi-certs.7z` をダウンロードして 解凍。

## 解凍手順

### iPad
1. **Safari で raw ダウンロード**: `nagomi-certs.7z` を タップ → 「ダウンロード」
2. **iZip または 7-Zip** アプリで 開く (App Store)
3. **zip パスワード** 入力 → 解凍
4. **`keiei-ipad.p12`** をタップ → 設定 → プロファイル → インストール
5. **プロファイルパスワード**: `PASSWORD.txt` 参照

### PC (Mac)
1. `nagomi-certs.7z` をダウンロード
2. **The Unarchiver** or **Keka** で 解凍 (パスワード入力)
3. **`keiei-pc.p12`** を ダブルクリック → キーチェーンに追加

### PC (Windows)
1. `nagomi-certs.7z` を ダウンロード
2. **7-Zip** を右クリックメニューから 使用 → 解凍
3. **`keiei-pc.p12`** をダブルクリック → 証明書インポート ウィザード

## 使い方

証明書 インストール後:
- ブラウザで https://nagomi-admin.duckdns.org/gallery/nagomi-corp/ を開く
- 証明書選択ダイアログで 使用する 証明書を選択

## 注意

- **zip パスワードは 別途 共有される** (Signal / LINE / メール等)
- **紛失/漏洩 時は 即 連絡**
- 端末ごとに 別 証明書、追加発行可能
