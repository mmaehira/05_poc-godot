#!/usr/bin/env python3
"""
DALL-E生成画像をピクセルアート風に変換
"""

from PIL import Image
import sys

def convert_to_pixel_art(input_path, output_path, target_size=48, num_frames=4, palette_colors=16):
    """
    画像をピクセルアート風に変換

    Args:
        input_path: 入力画像パス
        output_path: 出力画像パス
        target_size: 目標サイズ（高さ）
        num_frames: フレーム数
        palette_colors: パレット色数
    """
    print(f"Converting: {input_path}")

    # 画像を読み込み
    img = Image.open(input_path)
    print(f"  Original size: {img.size}")
    print(f"  Original mode: {img.mode}")

    # RGBAに変換
    if img.mode != 'RGBA':
        # 透明度がない場合、暗い部分を透明化
        img = img.convert('RGB')
        # 画像の明るさベースで透明度を作成
        from PIL import ImageMath
        # Lモード（グレースケール）に変換
        gray = img.convert('L')
        # 閾値より暗いピクセルを透明に
        threshold = 30
        alpha = gray.point(lambda p: 0 if p < threshold else 255)
        img = img.convert('RGBA')
        img.putalpha(alpha)
        print(f"  Added alpha channel (threshold={threshold})")

    # ダウンサンプリング
    # スプライトシートの場合、幅はtarget_size * num_framesになる
    new_width = target_size * num_frames
    new_height = target_size
    img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    print(f"  Resized to: {img_resized.size}")

    # 色の量子化（パレット削減）
    # RGBを分離して量子化
    if palette_colors < 256:
        # Pモードに変換（パレット付き）
        img_rgb = img_resized.convert('RGB')
        img_palette = img_rgb.quantize(colors=palette_colors, method=Image.Quantize.MEDIANCUT)
        img_palette = img_palette.convert('RGBA')

        # 元のアルファチャンネルを復元
        alpha = img_resized.split()[3]
        img_palette.putalpha(alpha)
        img_resized = img_palette
        print(f"  Quantized to {palette_colors} colors")

    # 保存
    img_resized.save(output_path)
    print(f"  ✅ Saved: {output_path}")

    # 統計情報
    pixels = list(img_resized.getdata())
    opaque = [p for p in pixels if p[3] > 128]
    transparent = len(pixels) - len(opaque)
    print(f"  Opaque pixels: {len(opaque)}/{len(pixels)} ({100*len(opaque)/len(pixels):.1f}%)")
    print(f"  Transparent pixels: {transparent}/{len(pixels)} ({100*transparent/len(pixels):.1f}%)")

    return img_resized


if __name__ == "__main__":
    base_path = "/workspaces/05_poc-godot/assets/characters/player"

    # Player Idle
    convert_to_pixel_art(
        f"{base_path}/player_idle_single.png",
        f"{base_path}/player_idle_48x48_4f.png",
        target_size=48,
        num_frames=4,
        palette_colors=16
    )

    # Player Walk
    convert_to_pixel_art(
        f"{base_path}/player_walk_single.png",
        f"{base_path}/player_walk_48x48_4f.png",
        target_size=48,
        num_frames=4,
        palette_colors=16
    )

    # Player Hit
    convert_to_pixel_art(
        f"{base_path}/player_hit_single.png",
        f"{base_path}/player_hit_48x48_2f.png",
        target_size=48,
        num_frames=2,
        palette_colors=16
    )

    print("\n🎉 All conversions complete!")
