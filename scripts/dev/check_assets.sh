#!/bin/bash

# アセット検証スクリプト
# 必要なアセットが配置されているかチェックします

set -e

ASSETS_DIR="/workspaces/05_poc-godot/assets"
MISSING_COUNT=0
FOUND_COUNT=0

echo "=================================="
echo "  Asset Verification Script"
echo "=================================="
echo ""

# ファイル存在チェック関数
check_file() {
    local file_path="$1"
    local description="$2"

    if [ -f "$file_path" ]; then
        echo "✅ $description"
        ((FOUND_COUNT++))
    else
        echo "❌ $description"
        echo "   Missing: $file_path"
        ((MISSING_COUNT++))
    fi
}

# プレイヤーアセット
echo "📦 Player Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/characters/player/player_idle_48x48_4f.png" "Player Idle (192×48)"
check_file "$ASSETS_DIR/characters/player/player_walk_48x48_4f.png" "Player Walk (192×48)"
check_file "$ASSETS_DIR/characters/player/player_hit_48x48_2f.png" "Player Hit (96×48)"
check_file "$ASSETS_DIR/characters/player/player_frames.tres" "Player SpriteFrames"
echo ""

# 敵アセット
echo "👾 Enemy Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/characters/enemies/basic_enemy_idle_32x32_4f.png" "Basic Enemy (128×32)"
check_file "$ASSETS_DIR/characters/enemies/basic_enemy_frames.tres" "Basic Enemy SpriteFrames"
check_file "$ASSETS_DIR/characters/enemies/strong_enemy_idle_40x40_4f.png" "Strong Enemy (160×40)"
check_file "$ASSETS_DIR/characters/enemies/strong_enemy_frames.tres" "Strong Enemy SpriteFrames"
check_file "$ASSETS_DIR/characters/enemies/fast_enemy_idle_28x28_4f.png" "Fast Enemy (112×28)"
check_file "$ASSETS_DIR/characters/enemies/fast_enemy_frames.tres" "Fast Enemy SpriteFrames"
check_file "$ASSETS_DIR/characters/enemies/heavy_enemy_idle_56x56_4f.png" "Heavy Enemy (224×56)"
check_file "$ASSETS_DIR/characters/enemies/heavy_enemy_frames.tres" "Heavy Enemy SpriteFrames"
echo ""

# ボスアセット
echo "🦖 Boss Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/characters/bosses/tank_boss_idle_96x96_6f.png" "Tank Boss (576×96)"
check_file "$ASSETS_DIR/characters/bosses/tank_boss_frames.tres" "Tank Boss SpriteFrames"
check_file "$ASSETS_DIR/characters/bosses/sniper_boss_idle_80x80_6f.png" "Sniper Boss (480×80)"
check_file "$ASSETS_DIR/characters/bosses/sniper_boss_frames.tres" "Sniper Boss SpriteFrames"
check_file "$ASSETS_DIR/characters/bosses/swarm_boss_idle_88x88_6f.png" "Swarm Boss (528×88)"
check_file "$ASSETS_DIR/characters/bosses/swarm_boss_frames.tres" "Swarm Boss SpriteFrames"
echo ""

# 武器・発射物アセット
echo "🔫 Weapon Projectile Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/weapons/projectiles/straight_shot_projectile_16x16.png" "Straight Shot (16×16)"
check_file "$ASSETS_DIR/weapons/projectiles/area_blast_projectile_24x24_4f.png" "Area Blast (96×24)"
check_file "$ASSETS_DIR/weapons/projectiles/homing_missile_projectile_20x20_4f.png" "Homing Missile (80×20)"
check_file "$ASSETS_DIR/weapons/projectiles/laser_beam_projectile_8x32.png" "Laser Beam (8×32)"
check_file "$ASSETS_DIR/weapons/projectiles/lightning_projectile_16x48_4f.png" "Lightning (64×48)"
check_file "$ASSETS_DIR/weapons/projectiles/orbital_projectile_20x20_4f.png" "Orbital (80×20)"
echo ""

# アイテムアセット
echo "💎 Item Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/items/exp_orb_small_12x12_4f.png" "EXP Orb Small (48×12)"
check_file "$ASSETS_DIR/items/exp_orb_medium_16x16_4f.png" "EXP Orb Medium (64×16)"
check_file "$ASSETS_DIR/items/exp_orb_large_20x20_4f.png" "EXP Orb Large (80×20)"
check_file "$ASSETS_DIR/items/powerup_item_24x24_4f.png" "Powerup Item (96×24)"
check_file "$ASSETS_DIR/items/magnet_item_24x24_4f.png" "Magnet Item (96×24)"
echo ""

# エフェクトアセット
echo "✨ Effect Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/effects/explosion_effect_64x64_6f.png" "Explosion Effect (384×64)"
check_file "$ASSETS_DIR/effects/muzzle_flash_effect_32x32_6f.png" "Muzzle Flash (192×32)"
check_file "$ASSETS_DIR/effects/level_up_effect_96x96_6f.png" "Level Up Effect (576×96)"
check_file "$ASSETS_DIR/effects/hit_spark_effect_24x24_4f.png" "Hit Spark (96×24)"
check_file "$ASSETS_DIR/effects/powerup_aura_effect_64x64_4f.png" "Powerup Aura (256×64)"
echo ""

# パーティクルアセット
echo "🎆 Particle Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/effects/particles/spark_small_particle_8x8.png" "Spark Small (8×8)"
check_file "$ASSETS_DIR/effects/particles/spark_medium_particle_12x12.png" "Spark Medium (12×12)"
check_file "$ASSETS_DIR/effects/particles/smoke_particle_16x16.png" "Smoke (16×16)"
check_file "$ASSETS_DIR/effects/particles/glow_particle_32x32.png" "Glow (32×32)"
check_file "$ASSETS_DIR/effects/particles/trail_particle_8x8.png" "Trail (8×8)"
echo ""

# UIアセット
echo "🖼️  UI Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/ui/buttons/button_small_128x48.png" "Button Small (128×48)"
check_file "$ASSETS_DIR/ui/buttons/button_medium_192x64.png" "Button Medium (192×64)"
check_file "$ASSETS_DIR/ui/buttons/button_large_256x80.png" "Button Large (256×80)"
check_file "$ASSETS_DIR/ui/panels/panel_small_256x192.png" "Panel Small (256×192)"
check_file "$ASSETS_DIR/ui/panels/panel_medium_512x384.png" "Panel Medium (512×384)"
check_file "$ASSETS_DIR/ui/panels/panel_large_768x576.png" "Panel Large (768×576)"
check_file "$ASSETS_DIR/ui/gauges/hp_gauge_bg_256x32.png" "HP Gauge BG (256×32)"
check_file "$ASSETS_DIR/ui/gauges/hp_gauge_fg_248x24.png" "HP Gauge FG (248×24)"
check_file "$ASSETS_DIR/ui/gauges/exp_gauge_bg_512x16.png" "EXP Gauge BG (512×16)"
check_file "$ASSETS_DIR/ui/gauges/exp_gauge_fg_504x12.png" "EXP Gauge FG (504×12)"
check_file "$ASSETS_DIR/ui/gauges/boss_hp_bg_768x48.png" "Boss HP BG (768×48)"
check_file "$ASSETS_DIR/ui/gauges/boss_hp_fg_752x36.png" "Boss HP FG (752×36)"
check_file "$ASSETS_DIR/ui/icons/icon_frame_64x64.png" "Icon Frame (64×64)"
check_file "$ASSETS_DIR/ui/misc/combo_bg_256x96.png" "Combo BG (256×96)"
check_file "$ASSETS_DIR/ui/misc/skill_cooldown_circle_80x80.png" "Skill Cooldown Circle (80×80)"
echo ""

# 環境アセット
echo "🌍 Environment Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/environment/tileset_ground_32x32.png" "Ground Tileset (512×512 or smaller)"
check_file "$ASSETS_DIR/environment/tileset_wall_32x32.png" "Wall Tileset (256×256 or smaller)"
check_file "$ASSETS_DIR/environment/decoration_atlas_256x256.png" "Decoration Atlas (256×256)"
check_file "$ASSETS_DIR/environment/tileset_main.tres" "Main TileSet Resource"
echo ""

# オーディオアセット - BGM
echo "🎵 BGM Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/audio/bgm/bgm_title_120.ogg" "BGM Title (120 BPM)"
check_file "$ASSETS_DIR/audio/bgm/bgm_gameplay_140.ogg" "BGM Gameplay (140 BPM)"
check_file "$ASSETS_DIR/audio/bgm/bgm_boss_160.ogg" "BGM Boss (160 BPM)"
echo ""

# オーディオアセット - SE
echo "🔊 SE Assets"
echo "----------------------------"
check_file "$ASSETS_DIR/audio/se/se_shoot_01.ogg" "SE Shoot 01"
check_file "$ASSETS_DIR/audio/se/se_shoot_02.ogg" "SE Shoot 02"
check_file "$ASSETS_DIR/audio/se/se_shoot_03.ogg" "SE Shoot 03"
check_file "$ASSETS_DIR/audio/se/se_explosion_small.ogg" "SE Explosion Small"
check_file "$ASSETS_DIR/audio/se/se_explosion_large.ogg" "SE Explosion Large"
check_file "$ASSETS_DIR/audio/se/se_hit_player.ogg" "SE Hit Player"
check_file "$ASSETS_DIR/audio/se/se_pickup_exp.ogg" "SE Pickup EXP"
check_file "$ASSETS_DIR/audio/se/se_levelup.ogg" "SE Level Up"
check_file "$ASSETS_DIR/audio/se/se_powerup.ogg" "SE Powerup"
check_file "$ASSETS_DIR/audio/se/se_skill_activate.ogg" "SE Skill Activate"
check_file "$ASSETS_DIR/audio/se/se_ui_select.ogg" "SE UI Select"
check_file "$ASSETS_DIR/audio/se/se_ui_confirm.ogg" "SE UI Confirm"
check_file "$ASSETS_DIR/audio/se/se_boss_warning.ogg" "SE Boss Warning"
echo ""

# サマリー表示
echo "=================================="
echo "  Summary"
echo "=================================="
TOTAL=$((FOUND_COUNT + MISSING_COUNT))
echo "Total Assets: $TOTAL"
echo "✅ Found: $FOUND_COUNT"
echo "❌ Missing: $MISSING_COUNT"
echo ""

if [ $MISSING_COUNT -eq 0 ]; then
    echo "🎉 All assets are present!"
    exit 0
else
    COMPLETION_RATE=$((FOUND_COUNT * 100 / TOTAL))
    echo "📊 Completion Rate: $COMPLETION_RATE%"
    echo ""
    echo "⚠️  $MISSING_COUNT asset(s) are missing."
    echo "Please check the README.md files in each asset directory for generation instructions."
    echo ""
    echo "Quick start:"
    echo "  1. Open docs/dalle-prompts.md"
    echo "  2. Copy prompts for missing assets"
    echo "  3. Generate images with ChatGPT Plus (DALL-E)"
    echo "  4. Place images in appropriate directories"
    echo "  5. Run this script again to verify"
    exit 1
fi
