# ガチャバリスティック（UEFN / Verse）

Fortnite のゲーム制作ツール「UEFN」で個人制作し、公開した対戦マップ「GACHA BALLISTIC」の Verse コードです。

## ゲーム概要
4対4のサーチ＆デストロイです。攻撃側は爆弾を設置して爆破を、守備側はその阻止か解除を狙います。武器は、キルや爆弾の設置などで稼いだゴールドを使ってガチャで手に入れます。

## 実装のポイント
- **ラウンドをまたいで状態を保つ**：UEFN のラウンド機能はラウンドごとに変数を初期化するため、ラウンド数・勝利数・所持ゴールドなどをプレイヤーごとの保存データに持たせています。
- **途中退出への対応**：退出した人をチームの残り人数に反映し、片方のチームが0人になったら試合を終えます。
- **爆弾設置後の勝敗判定**：設置後は、攻撃側が全滅しても、爆弾が解除されるまでは勝敗を決めません。

## ファイル構成
| ファイル | 役割 |
| --- | --- |
| `game_flow_device.verse` | 試合進行の中心（ラウンドの開始・終了、勝敗判定、攻守交代、ゴールドの配布） |
| `waiting_players_device.verse` | ロビーでの待機、開始人数の投票、チーム分け |
| `game_result.verse` | 試合結果画面の表示と、通算成績の保存 |
| `gacha_device.verse` | ガチャ（ゴールドの管理、抽選、アイテムの付与） |
| `gold_item_generator_device.verse` | ゴールドになるコインをマップに出現させる |
| `ballistic_tracking_device.verse` | 爆弾の位置をマップに表示する |
| `link_bombs_and_ballistics_device.verse` | 爆弾の爆発に合わせて、周りの爆発物も爆発させる |
| `round_ui_device.verse` | ラウンド中の表示（残り人数・勝利数・制限時間） |
| `display_stats_device.verse` | ロビーの看板に通算成績を表示する |
| `player_stat.verse` / `player_stat_manager.verse` | 保存データの定義と読み書き |

**本番では使っていないファイル**
- `save_preset_device.verse` / `select_preset_device.verse`：武器プリセットの保存と選択（完成済み）
- `shop_ui_device.verse` / `shop_datas.verse`：ラウンド前の購入フェーズ用のショップ（完成済み）
- `weapons_select_device.verse`：ゴールドでの武器の購入・返却
- `rating_system.verse`：レート計算（未実装）
- `debug_*.verse` / `test_device.verse`：動作確認用

## 開発環境
UEFN / Verse / Git（Verse のファイルのみ管理）
