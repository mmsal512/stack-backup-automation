#!/bin/bash
# ================================================================
#  Stack Backup Automation Script
#  Automated backup for project directories to Google Drive
#  with Telegram bot notifications
# ================================================================

# ================= Telegram Settings =================
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# ================= Path Settings =================
SOURCE_DIR="/home/your-user/my-stack"
DATE=$(date +"%Y-%m-%d_%H-%M")
FILE_NAME="Backup_$DATE.tar.gz"
BACKUP_PATH="/tmp/$FILE_NAME"

# 1. Send start notification
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="⏳ بدأ ضغط ورفع النسخة الاحتياطية لـ (my-stack) إلى Google Drive..." > /dev/null

# 2. Compress the entire directory with sudo privileges
sudo tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

# 3. Upload to Google Drive using rclone
if rclone copy "$BACKUP_PATH" gdrive:Backup_Server -P; then
    # Calculate file size for the report
    FILE_SIZE=$(du -sh "$BACKUP_PATH" | cut -f1)
    # Success notification
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="✅ تم الرفع بنجاح!
📦 اسم الملف: $FILE_NAME
📏 الحجم: $FILE_SIZE
☁️ الموقع: Google Drive (Backup_Server)" > /dev/null
else
    # Failure notification
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="❌ فشل الرفع! يرجى فحص اتصال السيرفر بـ Google Drive." > /dev/null
fi

# 4. Cleanup temporary file
rm -f "$BACKUP_PATH"
