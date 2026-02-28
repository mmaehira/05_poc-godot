#!/bin/bash
# Claude Code Notification Hook
# 入力待ち・処理完了時にデスクトップ通知 + ntfy.sh でスマホ通知を送信する

set -euo pipefail

# stdinからJSONを読み取る
INPUT=$(cat)

# イベント種別を判定
HOOK_EVENT=$(echo "$INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//' || echo "unknown")

if [ "$HOOK_EVENT" = "Stop" ]; then
  # Stop イベント: 処理完了通知
  TITLE="Claude Code - 処理完了"
  MESSAGE="処理が完了しました。結果を確認してください。"
else
  # Notification イベント: 入力待ち通知
  MESSAGE=$(echo "$INPUT" | grep -o '"notification_message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//' || echo "")
  NOTIFICATION_TYPE=$(echo "$INPUT" | grep -o '"notification_type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"//;s/"$//' || echo "unknown")

  if [ -z "$MESSAGE" ]; then
    MESSAGE="Claude Codeが入力を待っています"
  fi

  case "$NOTIFICATION_TYPE" in
    permission_prompt)
      TITLE="Claude Code - 権限確認"
      ;;
    idle_prompt)
      TITLE="Claude Code - 入力待ち"
      ;;
    *)
      TITLE="Claude Code - 通知"
      ;;
  esac
fi

# --- ntfy.sh スマホ通知 ---
# .envからNTFY_TOPICを読み込む
ENV_FILE="${CLAUDE_PROJECT_DIR:-.}/.env"
NTFY_TOPIC=""
if [ -f "$ENV_FILE" ]; then
  NTFY_TOPIC=$(grep -E '^NTFY_TOPIC=' "$ENV_FILE" | sed "s/^NTFY_TOPIC=//;s/^['\"]//;s/['\"]$//" || true)
fi

if [ -n "$NTFY_TOPIC" ]; then
  curl -s \
    -H "Title: ${TITLE}" \
    -H "Priority: high" \
    -H "Tags: computer,bell" \
    -H "Content-Type: text/plain; charset=utf-8" \
    -d "${MESSAGE}" \
    "https://ntfy.sh/${NTFY_TOPIC}" > /dev/null 2>&1 &
fi

# --- Windows デスクトップ通知 ---
# PowerShell balloon tip（依存モジュール不要）
powershell.exe -NoProfile -Command "
  Add-Type -AssemblyName System.Windows.Forms
  \$balloon = New-Object System.Windows.Forms.NotifyIcon
  \$balloon.Icon = [System.Drawing.SystemIcons]::Information
  \$balloon.BalloonTipTitle = '${TITLE}'
  \$balloon.BalloonTipText = '${MESSAGE}'
  \$balloon.BalloonTipIcon = 'Info'
  \$balloon.Visible = \$true
  \$balloon.ShowBalloonTip(10000)
  Start-Sleep -Seconds 2
  \$balloon.Dispose()
" > /dev/null 2>&1 &

# hookの終了コード0で処理続行
exit 0
