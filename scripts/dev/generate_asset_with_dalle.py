#!/usr/bin/env python3
"""
OpenAI DALL-E 3 API を使用してゲームアセットを自動生成

必要な環境変数:
    OPENAI_API_KEY: OpenAI APIキー

使用例:
    # 単一アセット生成
    python3 generate_asset_with_dalle.py --asset player_idle

    # カスタムプロンプト
    python3 generate_asset_with_dalle.py --prompt "32x32 pixel art slime" --output slime.png

    # バッチ生成（設定ファイル使用）
    python3 generate_asset_with_dalle.py --batch assets_config.json

必要なライブラリ:
    pip install openai pillow requests
"""

import os
import sys
import json
import argparse
import time
from pathlib import Path
from typing import Optional, Dict, Any

try:
    from openai import OpenAI
    import requests
    from PIL import Image
    from io import BytesIO
except ImportError as e:
    print(f"❌ Error: Required library not installed: {e}")
    print("\nPlease install required libraries:")
    print("  pip install openai pillow requests")
    sys.exit(1)


# プロンプト定義（dalle-prompts.mdから抽出）
PROMPTS = {
    # Player
    "player_idle": {
        "prompt": "Create a 48x48 sprite for a 2D game. Super-deformed (SD) minimal character based on a rounded capsule body. STRICTLY front view / straight-on (orthographic), perfectly symmetrical pose, looking directly at the camera. (This is the master design for all other motions.) Extremely thick black outline. Flat 2D anime cel shading. Vector-like clean shapes. No gradients. No textures. No stitches. No decorations. No eye highlights. Eyes are solid black oval dots. Very small straight mouth. Body uses 3 pastel color blocks: off-white base, soft pink on upper left, mint green on lower right. Background must be fully transparent (RGBA with alpha channel). No background color. Clean, readable silhouette at 48x48.",
        "output": "assets/characters/player/player_idle_single.png",
        "frames": 4,
        "final_output": "assets/characters/player/player_idle_48x48_4f.png"
    },

    "player_walk": {
        "prompt": "Create a 48x48 sprite for a 2D game. BASED ON the exact same character design as player_idle (same proportions, same color-block layout, same face placement, same outline thickness). Keep the SAME strict front view / straight-on angle (do NOT rotate the character, do NOT change perspective). Only add motion via subtle vertical bob and slight squash/stretch across frames to suggest walking. Extremely thick black outline. Flat 2D anime cel shading. No gradients. No textures. No stitches. No decorations. No eye highlights. Solid black oval eyes, tiny straight mouth. 3 pastel color blocks: off-white, soft pink, mint green. Background must be fully transparent (RGBA with alpha channel). No background color.",
        "output": "assets/characters/player/player_walk_single.png",
        "frames": 4,
        "final_output": "assets/characters/player/player_walk_48x48_4f.png"
    },

    "player_hit": {
        "prompt": "Create a 48x48 sprite for a 2D game. BASED ON the exact same character design as player_idle (same proportions, same color-block layout, same face placement, same outline thickness). Keep the SAME strict front view / straight-on angle (do NOT rotate the character, do NOT change perspective). Hit motion: quick squash and slight recoil while preserving the design. Optional brief white flash overlay on one frame. Extremely thick black outline. Flat 2D anime cel shading. No gradients. No textures. No stitches. No decorations. No eye highlights. Solid black oval eyes, tiny straight mouth. 3 pastel color blocks: off-white, soft pink, mint green. Background must be fully transparent (RGBA with alpha channel). No background color.",
        "output": "assets/characters/player/player_hit_single.png",
        "frames": 2,
        "final_output": "assets/characters/player/player_hit_48x48_2f.png"
    },


    # Enemies
    "basic_enemy": {
        "prompt": "Create a 32x32 pixel art sprite of a small slime monster, viewed from top-down perspective, facing upward. The slime should be green with a simple cute design. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it suitable for a vampire survivors-style enemy that appears in large numbers.",
        "output": "assets/characters/enemies/basic_enemy_single.png",
        "frames": 4,
        "final_output": "assets/characters/enemies/basic_enemy_idle_32x32_4f.png"
    },
    "strong_enemy": {
        "prompt": "Create a 40x40 pixel art sprite of a skeleton warrior, viewed from top-down perspective, facing upward. The skeleton should hold a sword and shield, with white bones and dark armor accents. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look tougher than basic enemies.",
        "output": "assets/characters/enemies/strong_enemy_single.png",
        "frames": 4,
        "final_output": "assets/characters/enemies/strong_enemy_idle_40x40_4f.png"
    },
    "fast_enemy": {
        "prompt": "Create a 28x28 pixel art sprite of a small bat creature, viewed from top-down perspective, facing upward. The bat should have spread wings suggesting fast movement, with purple and black colors. Use a 12-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look agile and fast.",
        "output": "assets/characters/enemies/fast_enemy_single.png",
        "frames": 4,
        "final_output": "assets/characters/enemies/fast_enemy_idle_28x28_4f.png"
    },
    "heavy_enemy": {
        "prompt": "Create a 56x56 pixel art sprite of a large orc warrior, viewed from top-down perspective, facing upward. The orc should be bulky and intimidating, with green skin and heavy armor. Use a 16-color palette. Transparent background, PNG format. Single sprite, no animation frames. Make it look slow but powerful.",
        "output": "assets/characters/enemies/heavy_enemy_single.png",
        "frames": 4,
        "final_output": "assets/characters/enemies/heavy_enemy_idle_56x56_4f.png"
    },

    # Bosses
    "tank_boss": {
        "prompt": "Create a 96x96 pixel art sprite of a massive stone golem boss, viewed from top-down perspective, facing upward. The golem should be heavily armored with rocky texture, glowing red eyes, and intimidating presence. Use a 20-color palette with gray, brown, and red accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a final boss that takes many hits.",
        "output": "assets/characters/bosses/tank_boss_single.png",
        "frames": 6,
        "final_output": "assets/characters/bosses/tank_boss_idle_96x96_6f.png"
    },
    "sniper_boss": {
        "prompt": "Create an 80x80 pixel art sprite of a dark archer boss, viewed from top-down perspective, facing upward. The archer should hold a glowing magical bow, wear a dark hooded cloak, and have a mysterious presence. Use a 20-color palette with dark purple, black, and cyan accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a ranged boss enemy.",
        "output": "assets/characters/bosses/sniper_boss_single.png",
        "frames": 6,
        "final_output": "assets/characters/bosses/sniper_boss_idle_80x80_6f.png"
    },
    "swarm_boss": {
        "prompt": "Create an 88x88 pixel art sprite of a necromancer boss surrounded by swirling dark energy and small skulls, viewed from top-down perspective, facing upward. The necromancer should wear dark robes and hold a staff. Use a 20-color palette with dark green, black, and white accents. Transparent background, PNG format. Single sprite, no animation frames. Make it look like a boss that summons minions.",
        "output": "assets/characters/bosses/swarm_boss_single.png",
        "frames": 6,
        "final_output": "assets/characters/bosses/swarm_boss_idle_88x88_6f.png"
    },

    # Projectiles
    "straight_shot": {
        "prompt": "Create a 16x16 pixel art sprite of a simple energy projectile, viewed from top-down perspective, pointing upward. The projectile should be a glowing blue/cyan energy orb or bolt. Use an 8-color palette. Transparent background, PNG format. Single sprite, suitable for rapid-fire weapon.",
        "output": "assets/weapons/projectiles/straight_shot_projectile_16x16.png",
        "frames": 0,  # No sprite sheet needed
        "final_output": None
    },
    "area_blast": {
        "prompt": "Create a 24x24 pixel art sprite of an explosive fireball projectile, viewed from top-down perspective. The fireball should be orange and yellow with a swirling pattern. Use a 12-color palette. Transparent background, PNG format. Single sprite. Make it look like it will explode on impact.",
        "output": "assets/weapons/projectiles/area_blast_single.png",
        "frames": 4,
        "final_output": "assets/weapons/projectiles/area_blast_projectile_24x24_4f.png"
    },

    # Items
    "exp_orb_small": {
        "prompt": "Create a 12x12 pixel art sprite of a small glowing experience orb, viewed from top-down perspective. The orb should be bright yellow or gold with a gentle glow. Use an 8-color palette. Transparent background, PNG format. Single sprite. Make it small and collectible.",
        "output": "assets/items/exp_orb_small_single.png",
        "frames": 4,
        "final_output": "assets/items/exp_orb_small_12x12_4f.png"
    },
    "exp_orb_medium": {
        "prompt": "Create a 16x16 pixel art sprite of a medium glowing experience orb, viewed from top-down perspective. The orb should be bright green with a stronger glow than the small version. Use a 10-color palette. Transparent background, PNG format. Single sprite. Make it more valuable-looking than the small orb.",
        "output": "assets/items/exp_orb_medium_single.png",
        "frames": 4,
        "final_output": "assets/items/exp_orb_medium_16x16_4f.png"
    },
}


class DALLEAssetGenerator:
    """DALL-E 3を使用してアセットを生成"""

    def __init__(self, api_key: Optional[str] = None):
        """
        初期化

        Args:
            api_key: OpenAI APIキー（Noneの場合は環境変数から取得）
        """
        self.api_key = api_key or os.getenv("OPENAI_API_KEY")

        if not self.api_key:
            raise ValueError(
                "OpenAI API key not found. "
                "Set OPENAI_API_KEY environment variable or pass api_key parameter."
            )

        self.client = OpenAI(api_key=self.api_key)
        self.base_dir = Path("/workspaces/05_poc-godot")

    def generate_image(
        self,
        prompt: str,
        output_path: str,
        size: str = "1024x1024",
        quality: str = "standard",
        style: str = "vivid"
    ) -> bool:
        """
        DALL-E 3で画像を生成

        Args:
            prompt: 生成プロンプト
            output_path: 出力パス
            size: 画像サイズ（1024x1024, 1792x1024, 1024x1792）
            quality: 品質（standard, hd）
            style: スタイル（vivid, natural）

        Returns:
            成功したかどうか
        """
        try:
            print(f"🎨 Generating image with DALL-E 3...")
            print(f"   Prompt: {prompt[:80]}...")
            print(f"   Size: {size}")
            print(f"   Quality: {quality}")
            print()

            # DALL-E 3 API呼び出し
            response = self.client.images.generate(
                model="dall-e-3",
                prompt=prompt,
                size=size,
                quality=quality,
                style=style,
                n=1
            )

            # 画像URLを取得
            image_url = response.data[0].url
            print(f"✅ Image generated successfully!")
            print(f"   URL: {image_url[:60]}...")
            print()

            # 画像をダウンロード
            print(f"⬇️  Downloading image...")
            img_response = requests.get(image_url, timeout=30)
            img_response.raise_for_status()

            # 画像を保存
            output_file = self.base_dir / output_path
            output_file.parent.mkdir(parents=True, exist_ok=True)

            with open(output_file, 'wb') as f:
                f.write(img_response.content)

            print(f"✅ Image saved: {output_file}")
            print()

            return True

        except Exception as e:
            print(f"❌ Error generating image: {e}")
            return False

    def generate_asset(
        self,
        asset_name: str,
        auto_create_sprite_sheet: bool = True
    ) -> bool:
        """
        定義済みアセットを生成

        Args:
            asset_name: アセット名（PROMPTS辞書のキー）
            auto_create_sprite_sheet: スプライトシートを自動生成するか

        Returns:
            成功したかどうか
        """
        if asset_name not in PROMPTS:
            print(f"❌ Error: Unknown asset '{asset_name}'")
            print(f"Available assets: {', '.join(PROMPTS.keys())}")
            return False

        config = PROMPTS[asset_name]

        print("=" * 70)
        print(f"  Generating Asset: {asset_name}")
        print("=" * 70)
        print()

        # 画像生成
        success = self.generate_image(
            prompt=config["prompt"],
            output_path=config["output"]
        )

        if not success:
            return False

        # スプライトシート作成
        if auto_create_sprite_sheet and config["frames"] > 0 and config["final_output"]:
            print(f"🔧 Creating sprite sheet ({config['frames']} frames)...")
            success = self._create_sprite_sheet(
                input_path=config["output"],
                output_path=config["final_output"],
                num_frames=config["frames"]
            )

            if success:
                print(f"✅ Sprite sheet created: {config['final_output']}")
            else:
                print(f"⚠️  Sprite sheet creation failed, but single frame is available")

        print()
        print("=" * 70)
        print("  Generation Complete!")
        print("=" * 70)

        return True

    def _create_sprite_sheet(
        self,
        input_path: str,
        output_path: str,
        num_frames: int
    ) -> bool:
        """
        スプライトシート作成（内部メソッド）

        Args:
            input_path: 入力画像パス
            output_path: 出力パス
            num_frames: フレーム数

        Returns:
            成功したかどうか
        """
        try:
            input_file = self.base_dir / input_path
            output_file = self.base_dir / output_path

            # 画像読み込み
            frame = Image.open(input_file)
            if frame.mode != "RGBA":
                frame = frame.convert("RGBA")

            width, height = frame.size

            # スプライトシート作成
            sheet_width = width * num_frames
            sprite_sheet = Image.new("RGBA", (sheet_width, height), (0, 0, 0, 0))

            for i in range(num_frames):
                sprite_sheet.paste(frame, (width * i, 0))

            # 保存
            output_file.parent.mkdir(parents=True, exist_ok=True)
            sprite_sheet.save(output_file, "PNG")

            return True

        except Exception as e:
            print(f"❌ Error creating sprite sheet: {e}")
            return False

    def generate_batch(self, assets: list, delay: int = 5) -> Dict[str, bool]:
        """
        複数アセットをバッチ生成

        Args:
            assets: アセット名のリスト
            delay: 各生成間の待機時間（秒）

        Returns:
            {asset_name: success} の辞書
        """
        results = {}

        print("=" * 70)
        print(f"  Batch Generation: {len(assets)} assets")
        print("=" * 70)
        print()

        for i, asset_name in enumerate(assets, 1):
            print(f"[{i}/{len(assets)}] {asset_name}")
            results[asset_name] = self.generate_asset(asset_name)

            # レート制限対策
            if i < len(assets):
                print(f"⏳ Waiting {delay} seconds before next generation...")
                print()
                time.sleep(delay)

        # サマリー
        success_count = sum(results.values())
        print()
        print("=" * 70)
        print("  Batch Generation Complete!")
        print("=" * 70)
        print(f"✅ Success: {success_count}/{len(assets)}")
        print(f"❌ Failed: {len(assets) - success_count}/{len(assets)}")

        return results


def main():
    """メイン関数"""
    parser = argparse.ArgumentParser(
        description="Generate game assets using OpenAI DALL-E 3 API"
    )

    parser.add_argument(
        "--asset",
        help="Asset name to generate (e.g., player_idle, basic_enemy)"
    )
    parser.add_argument(
        "--prompt",
        help="Custom prompt for generation"
    )
    parser.add_argument(
        "--output",
        help="Output file path (required with --prompt)"
    )
    parser.add_argument(
        "--batch",
        help="Batch generation from JSON file or comma-separated list"
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List all available asset names"
    )
    parser.add_argument(
        "--no-sprite-sheet",
        action="store_true",
        help="Do not create sprite sheet automatically"
    )
    parser.add_argument(
        "--delay",
        type=int,
        default=5,
        help="Delay between batch generations (seconds, default: 5)"
    )

    args = parser.parse_args()

    # List available assets
    if args.list:
        print("Available assets:")
        for name in sorted(PROMPTS.keys()):
            config = PROMPTS[name]
            frames = f"{config['frames']}f" if config['frames'] > 0 else "static"
            print(f"  - {name:<20} ({frames})")
        return

    # Initialize generator
    try:
        generator = DALLEAssetGenerator()
    except ValueError as e:
        print(f"❌ Error: {e}")
        print()
        print("To set your API key:")
        print("  export OPENAI_API_KEY='your-api-key-here'")
        sys.exit(1)

    # Single asset generation
    if args.asset:
        success = generator.generate_asset(
            args.asset,
            auto_create_sprite_sheet=not args.no_sprite_sheet
        )
        sys.exit(0 if success else 1)

    # Custom prompt
    if args.prompt:
        if not args.output:
            print("❌ Error: --output is required with --prompt")
            sys.exit(1)

        success = generator.generate_image(args.prompt, args.output)
        sys.exit(0 if success else 1)

    # Batch generation
    if args.batch:
        # Check if it's a JSON file
        if args.batch.endswith('.json'):
            try:
                with open(args.batch) as f:
                    batch_config = json.load(f)
                assets = batch_config.get("assets", [])
            except Exception as e:
                print(f"❌ Error loading batch file: {e}")
                sys.exit(1)
        else:
            # Comma-separated list
            assets = [a.strip() for a in args.batch.split(',')]

        results = generator.generate_batch(assets, delay=args.delay)

        # Exit with error if any failed
        sys.exit(0 if all(results.values()) else 1)

    # No arguments provided
    parser.print_help()
    sys.exit(1)


if __name__ == "__main__":
    main()
