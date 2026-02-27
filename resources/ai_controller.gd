class_name AIController extends Resource

## AIControllerクラス（基底クラス）
##
## 責務:
## - AI行動パターンの抽象定義
##
## 注意:
## - これはResourceクラス（Nodeではない）
## - 具体的な実装はサブクラスで行う

## AI行動を計算
##
## @param enemy: 敵ノード
## @param player: プレイヤーノード
## @param delta: デルタタイム
## @return: 移動方向（正規化されたVector2）
func calculate_direction(enemy: Node, player: Node, delta: float) -> Vector2:
	push_error("AIController.calculate_direction() must be overridden")
	return Vector2.ZERO
