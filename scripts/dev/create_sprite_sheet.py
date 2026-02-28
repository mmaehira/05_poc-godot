#!/usr/bin/env python3
"""
スプライトシート作成スクリプト

DALL-Eで生成した単一フレームを複数回複製して、
横並びのスプライトシートを作成します。

使用例:
    # 4フレームのスプライトシート作成
    python3 create_sprite_sheet.py player_idle_single.png player_idle_48x48_4f.png 4

    # 6フレームのスプライトシート作成
    python3 create_sprite_sheet.py tank_boss_single.png tank_boss_idle_96x96_6f.png 6

必要なライブラリ:
    pip install Pillow
"""

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("❌ Error: Pillow library is not installed.")
    print("Please install it with: pip install Pillow")
    sys.exit(1)


def create_sprite_sheet(input_path: str, output_path: str, num_frames: int):
    """
    単一フレーム画像から横並びのスプライトシートを作成

    Args:
        input_path: 入力画像パス（単一フレーム）
        output_path: 出力画像パス（スプライトシート）
        num_frames: フレーム数
    """
    input_file = Path(input_path)
    output_file = Path(output_path)

    # 入力ファイル確認
    if not input_file.exists():
        print(f"❌ Error: Input file not found: {input_path}")
        sys.exit(1)

    # 画像読み込み
    try:
        frame = Image.open(input_file)
    except Exception as e:
        print(f"❌ Error: Failed to open image: {e}")
        sys.exit(1)

    # 画像情報
    width, height = frame.size
    mode = frame.mode

    print(f"📖 Input: {input_file.name}")
    print(f"   Size: {width}×{height}")
    print(f"   Mode: {mode}")
    print(f"   Frames: {num_frames}")
    print()

    # RGBAモードに変換（透過対応）
    if mode != "RGBA":
        print(f"⚠️  Converting from {mode} to RGBA...")
        frame = frame.convert("RGBA")

    # スプライトシート作成
    sheet_width = width * num_frames
    sheet_height = height

    print(f"📝 Creating sprite sheet...")
    print(f"   Output Size: {sheet_width}×{sheet_height}")

    sprite_sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

    # フレームを横並びに配置
    for i in range(num_frames):
        x_offset = width * i
        sprite_sheet.paste(frame, (x_offset, 0))
        print(f"   Frame {i+1}/{num_frames}: x={x_offset}")

    # 出力ディレクトリ作成
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # 保存
    try:
        sprite_sheet.save(output_file, "PNG")
        print()
        print(f"✅ Sprite sheet created successfully!")
        print(f"   Output: {output_file}")
        print(f"   Size: {sheet_width}×{sheet_height}")
    except Exception as e:
        print(f"❌ Error: Failed to save sprite sheet: {e}")
        sys.exit(1)


def main():
    """メイン関数"""
    if len(sys.argv) != 4:
        print("Usage: python3 create_sprite_sheet.py <input_image> <output_image> <num_frames>")
        print()
        print("Examples:")
        print("  python3 create_sprite_sheet.py player_idle.png player_idle_48x48_4f.png 4")
        print("  python3 create_sprite_sheet.py tank_boss.png tank_boss_idle_96x96_6f.png 6")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    try:
        num_frames = int(sys.argv[3])
        if num_frames < 1:
            raise ValueError("Number of frames must be at least 1")
    except ValueError as e:
        print(f"❌ Error: Invalid number of frames: {sys.argv[3]}")
        print(f"   {e}")
        sys.exit(1)

    print("=" * 60)
    print("  Sprite Sheet Creator")
    print("=" * 60)
    print()

    create_sprite_sheet(input_path, output_path, num_frames)


if __name__ == "__main__":
    main()
