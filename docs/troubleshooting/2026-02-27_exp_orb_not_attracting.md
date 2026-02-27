# 経験値オーブが吸引されない問題

**日付:** 2026-02-27
**影響範囲:** 経験値オーブシステム
**重要度:** 高（ゲームプレイに直接影響）

---

## 問題

### 症状
- 全ての経験値オーブは視覚的に表示される
- 全ての経験値オーブはドロップされる
- **約50%の経験値オーブはプレイヤーに吸引されない**
- 吸引されたオーブは正常に経験値を付与する
- 吸引されないオーブは触れても何も起こらない

### ユーザー影響
プレイヤーが経験値を獲得できず、ゲームの進行が困難になる。

---

## 再現手順

### 入力/状況
1. ゲームを開始する
2. 敵を倒して経験値オーブをドロップさせる
3. プレイヤーをオーブに近づける

### 再現率
**約50%** - 新規作成されたオーブは正常に動作するが、プールから再利用されたオーブの一部が動作しない

---

## 原因

### 技術的原因
オブジェクトプールから再利用された経験値オーブの`_process()`が無効化されたままになっていた。

### 根本原因（設計レベル）
1. **物理エンジンとの競合によるタイミング問題**
   - `PoolManager.spawn_exp_orb()`内で`orb.initialize()`を直接呼び出していた
   - `initialize()`内で`set_process(true)`を呼んでも、その後の物理フレーム処理で上書きされていた
   - `reparent()`による親ノード変更が物理フレーム中に発生し、`process_mode`がリセットされた

2. **`set_deferred()`と直接呼び出しの混在**
   - コリジョン設定は`set_deferred()`で実行していたが、`initialize()`自体は直接呼び出していた
   - この非対称性により、一部のプロパティが正しく設定されなかった

3. **デバッグの難しさ**
   - オーブは視覚的に表示されるため、一見正常に見える
   - `monitoring`や`monitorable`は有効なので、コリジョンは検出される
   - しかし`_process()`が無効なため、`target_player`が設定されても追尾しない

### 診断プロセス
1. デバッグログで全オーブの状態を確認
2. `Process enabled: 0` を発見 - 全てのオーブの`_process()`が無効
3. `initialize()`の呼び出しタイミングを調査
4. `reparent()`と`set_process()`の実行順序が問題と特定

---

## 根本対策

### 実装した修正

#### 1. `initialize()`を`call_deferred()`で呼び出し
**[pool_manager.gd:343-348]**
```gdscript
# 経験値オーブの初期化（deferredで呼び出して物理エンジンとの競合を回避）
if orb.has_method("initialize"):
	# call_deferredでinitializeを呼び出す（reparent後の物理フレームと競合しないように）
	orb.call_deferred("initialize", position, exp_value)
```

**理由:**
- `reparent()`の後の物理フレーム処理が完了してから`initialize()`を実行
- これにより`set_process(true)`が上書きされない

#### 2. コリジョン設定を全て`set_deferred()`で統一
**[exp_orb.gd:78-87]**
```gdscript
# コリジョン設定を確実に有効化（物理フレーム中の可能性があるためdeferred使用）
set_deferred("monitoring", true)
set_deferred("monitorable", true)

# CollisionShape2Dを有効化（deferredで実行）
if collision_shape != null:
	collision_shape.set_deferred("disabled", false)
```

**理由:**
- 物理フレーム中のコリジョン設定変更を回避
- Godot 4.3の物理エンジンの制限に対応

#### 3. シーンファイルで初期状態を無効に設定
**[exp_orb.tscn:8-17]**
```
[node name="ExpOrb" type="Area2D"]
collision_layer = 4
collision_mask = 1
monitoring = false  # 初期状態は無効
monitorable = false  # 初期状態は無効
script = ExtResource("1_exp_orb")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
disabled = true  # 初期状態は無効
shape = SubResource("CircleShape2D_1")
```

**理由:**
- `_ready()`内での`set_deferred()`呼び出しによるエラーを回避
- プール管理の初期状態を明確化

---

## 再発防止

### 1. ガード/アサート

デバッグモード用の状態チェッカーを追加（今回は削除したが、必要に応じて再追加可能）:

```gdscript
# exp_orb_debug.gd（参考実装）
func _check_orbs() -> void:
	var active_orbs = PoolManager.active_exp_orbs
	var process_enabled_count = 0

	for orb in active_orbs:
		if orb.process_mode == Node.PROCESS_MODE_PAUSABLE:
			process_enabled_count += 1

	assert(process_enabled_count == active_orbs.size(),
		"Some orbs have disabled process mode: %d/%d" % [process_enabled_count, active_orbs.size()])
```

### 2. 設計ルール

#### ルール1: プール管理オブジェクトの初期化は全て`call_deferred()`で行う
```gdscript
# ❌ 悪い例
orb.initialize(position, value)

# ✅ 良い例
orb.call_deferred("initialize", position, value)
```

**理由:** `reparent()`後の物理フレーム処理との競合を回避

#### ルール2: 物理プロパティの変更は全て`set_deferred()`で行う
```gdscript
# ❌ 悪い例
monitoring = true
collision_shape.disabled = false

# ✅ 良い例
set_deferred("monitoring", true)
collision_shape.set_deferred("disabled", false)
```

**理由:** 物理フレーム中のプロパティ変更を回避

#### ルール3: プール管理オブジェクトの初期状態はシーンファイルで定義する
- コードで動的に初期化するのではなく、シーンファイルで初期状態を定義
- `_ready()`内での`set_deferred()`呼び出しを避ける

#### ルール4: デバッグログは段階的に詳細化する
```gdscript
# レベル1: 基本的な呼び出しログ
print("[ExpOrb] initialize() called")

# レベル2: パラメータログ
print("[ExpOrb] initialize() - pos: %v, value: %d" % [pos, value])

# レベル3: 状態確認ログ
print("[ExpOrb] After set - monitoring=%s, process=%s" % [monitoring, is_processing()])
```

### 3. テスト戦略

#### 自動テスト項目（将来実装）
1. **プール再利用テスト**
   - オーブを複数回スポーン→返却→再スポーン
   - 各回で`is_processing()`がtrueであることを確認

2. **物理フレーム同期テスト**
   - `_physics_process()`内でオーブをスポーン
   - 次のフレームで状態を確認

3. **コリジョン検出テスト**
   - プレイヤーをオーブの吸引範囲に移動
   - `start_attraction()`が呼ばれることを確認

#### 手動テスト項目
1. 長時間プレイテスト（10分以上）
2. 大量のオーブ生成テスト（50個以上同時）
3. プール上限到達テスト（LRU動作確認）

---

## 学び

### 今後の設計原則

#### 1. オブジェクトプールとGodotの物理エンジンの相性問題
Godotの物理エンジンは、ノードの追加・削除・移動を特定のタイミング（物理フレーム）で処理する。オブジェクトプールでノードを再利用する場合、以下を考慮する必要がある:

- **`reparent()`は物理フレームに影響する**
  - 親ノード変更後、次の物理フレームまでプロパティがリセットされる可能性がある
  - 初期化は`call_deferred()`で遅延実行する

- **物理プロパティの変更は全て`set_deferred()`を使う**
  - `monitoring`, `monitorable`, `collision_layer`, `collision_mask`
  - `CollisionShape2D.disabled`
  - これらは物理フレーム中に変更できない

#### 2. 非対称性を避ける
- 一部は`set_deferred()`、一部は直接呼び出し、という混在は避ける
- 統一されたパターンを使う（今回は全て`call_deferred()`/`set_deferred()`に統一）

#### 3. デバッグ情報の重要性
- 視覚的に正常に見えても、内部状態は異常である可能性がある
- 定期的な状態チェックログを実装する（本番では無効化）
- `is_processing()`, `monitoring`, `monitorable`などの状態を全て確認する

#### 4. シーンファイルとコードの責任分離
- シーンファイル: 初期状態の定義
- コード: 実行時の状態変更
- この分離により、`_ready()`内での複雑な初期化を避けられる

#### 5. Godotのバージョン固有の問題
- Godot 4.3では`call_deferred()`内から`set_deferred()`を呼ぶと警告が出る
- この警告は機能に影響しないが、将来のバージョンで修正される可能性がある
- バージョンアップ時は再テストが必要

### 類似の問題が起きる可能性のある箇所
1. **弾丸プール** - 同様の`reparent()`とコリジョン設定を使用
2. **敵プール** - 同様のプール管理パターン
3. **任意のArea2D/RigidBody2D/CharacterBody2Dのプール管理**

### 推奨される予防策
1. 全てのプール管理オブジェクトに対して同じパターンを適用
2. 定期的なデバッグログによる状態監視（開発中のみ）
3. プール管理のベースクラス/インターフェースの導入を検討

---

## 参考情報

### 関連ファイル
- [autoload/pool_manager.gd:282-364](autoload/pool_manager.gd#L282-L364) - 経験値オーブのスポーン処理
- [scripts/items/exp_orb.gd:61-93](scripts/items/exp_orb.gd#L61-L93) - オーブの初期化とリセット
- [scenes/items/exp_orb.tscn](scenes/items/exp_orb.tscn) - オーブシーンの初期設定

### Godot公式ドキュメント
- [Object.call_deferred()](https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-call-deferred)
- [Object.set_deferred()](https://docs.godotengine.org/en/stable/classes/class_object.html#class-object-method-set-deferred)
- [Node.reparent()](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-reparent)
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html)

### 関連する既知の問題
- Godot Issue #XXXXX - "Can't change monitoring state while flushing queries" warning
- Godot Pull Request #XXXXX - Physics frame timing improvements

---

**最終更新:** 2026-02-27
**作成者:** Claude (with Human guidance)
**レビュー状態:** 初版
