# PrimeTap (Merge Tap Game)

Flutterで完結する、軽量なマージ系タップゲームアプリです。

## 特徴
- **タップアクション**: キャラクターをタップしてポイントを獲得。インタラクティブな揺れアニメーション。
- **成長と解放**: ポイントを貯めて新しいキャラクターを解放。キャラクターが成長する演出。
- **強化システム**: アイテムを消費して1タップあたりのポイントをアップグレード。
- **記録と統計**: 日次記録（タップ数、速度、ポイント）をカレンダーとグラフ（日・月・年）で可視化。
- **完全ローカル動作**: インターネット接続なしでプレイ可能。接続時のみ下部にバナー広告を表示。

## 技術スタック
- **Framework**: Flutter
- **Storage**: shared_preferences (完全ローカル保存)
- **Charts**: fl_chart
- **Calendar**: table_calendar
- **Ads**: google_mobile_ads (AdMob)

## 開発者向け
詳細な仕様やファイル構成については [DELIVERABLES.md](./DELIVERABLES.md) を参照してください。

### 実行方法
```bash
flutter pub get
flutter run
```
