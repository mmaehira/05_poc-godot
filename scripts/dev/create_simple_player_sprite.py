#!/usr/bin/env python3
"""
シンプルなプレイヤースプライトを生成
ピクセルアートスタイルの幾何学図形
"""

from PIL import Image, ImageDraw

def create_player_sprite(size=48):
    """プレイヤースプライトを作成（三角形の船型）"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 中心点
    cx, cy = size // 2, size // 2

    # 三角形の頂点（上向き）
    points = [
        (cx, cy - size//3),           # 上の先端
        (cx - size//4, cy + size//3), # 左下
        (cx + size//4, cy + size//3), # 右下
    ]

    # 本体（青）
    draw.polygon(points, fill=(76, 153, 255, 255))

    # 輪郭（白）
    draw.line(points + [points[0]], fill=(255, 255, 255, 255), width=2)

    # コックピット（明るい青）
    cockpit_y = cy - size//8
    draw.ellipse([cx-4, cockpit_y-4, cx+4, cockpit_y+4], fill=(153, 204, 255, 255))

    return img

def create_sprite_sheet(sprite, num_frames):
    """スプライトシートを作成"""
    size = sprite.size[0]
    sheet = Image.new('RGBA', (size * num_frames, size), (0, 0, 0, 0))

    for i in range(num_frames):
        sheet.paste(sprite, (size * i, 0))

    return sheet

# Player Idle（4フレーム）
idle_sprite = create_player_sprite(48)
idle_sheet = create_sprite_sheet(idle_sprite, 4)
idle_sheet.save('/workspaces/05_poc-godot/assets/characters/player/player_idle_48x48_4f.png')
print("✅ Created: player_idle_48x48_4f.png")

# Player Walk（4フレーム - わずかに傾ける）
walk_frames = []
for i in range(4):
    img = create_player_sprite(48)
    # 左右に少し傾ける
    angle = 5 if i % 2 == 0 else -5
    rotated = img.rotate(angle, expand=False, fillcolor=(0, 0, 0, 0))
    walk_frames.append(rotated)

walk_sheet = Image.new('RGBA', (48 * 4, 48), (0, 0, 0, 0))
for i, frame in enumerate(walk_frames):
    walk_sheet.paste(frame, (48 * i, 0))
walk_sheet.save('/workspaces/05_poc-godot/assets/characters/player/player_walk_48x48_4f.png')
print("✅ Created: player_walk_48x48_4f.png")

# Player Hit（2フレーム - 赤く点滅）
hit_sprite = Image.new('RGBA', (48, 48), (0, 0, 0, 0))
draw = ImageDraw.Draw(hit_sprite)
cx, cy = 24, 24
points = [(cx, cy - 16), (cx - 12, cy + 16), (cx + 12, cy + 16)]
draw.polygon(points, fill=(255, 76, 76, 255))  # 赤
draw.line(points + [points[0]], fill=(255, 255, 255, 255), width=2)

hit_sheet = create_sprite_sheet(hit_sprite, 2)
hit_sheet.save('/workspaces/05_poc-godot/assets/characters/player/player_hit_48x48_2f.png')
print("✅ Created: player_hit_48x48_2f.png")

print("\n🎉 All player sprites created successfully!")
