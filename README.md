<p align="center">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" />
  <img src="https://img.shields.io/badge/Cloud-Google%20Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white" />
  <img src="https://img.shields.io/badge/Tool-Rclone-3B82F6?style=for-the-badge&logo=rclone&logoColor=white" />
  <img src="https://img.shields.io/badge/Notify-Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" />
  <img src="https://img.shields.io/badge/Cron-Automated-FF6B6B?style=for-the-badge&logo=clockify&logoColor=white" />
</p>

<h1 align="center">🗄️ Stack Backup Automation</h1>

<p align="center">
  <b>Automated server backup solution with cloud storage & instant Telegram notifications</b>
</p>

<p align="center">
  <i>A lightweight Bash script that compresses your project directory, uploads it to Google Drive via <code>rclone</code>, and sends real-time status notifications through a Telegram bot.</i>
</p>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Setup Guide](#-setup-guide)
  - [Step 1: Create a Dedicated Email for Backup](#step-1-create-a-dedicated-email-for-backup)
  - [Step 2: Install Required Tools](#step-2-install-required-tools)
  - [Step 3: Configure Rclone with Google Drive](#step-3-configure-rclone-with-google-drive)
  - [Step 4: Create a Telegram Bot](#step-4-create-a-telegram-bot)
  - [Step 5: Get Your Telegram Chat ID](#step-5-get-your-telegram-chat-id)
  - [Step 6: Configure the Backup Script](#step-6-configure-the-backup-script)
  - [Step 7: Test the Script](#step-7-test-the-script)
  - [Step 8: Setup Cron Job for Automation](#step-8-setup-cron-job-for-automation)
- [Cron Schedule Examples](#-cron-schedule-examples)
- [Troubleshooting](#-troubleshooting)
- [Security Notes](#-security-notes)
- [Author](#-author)

---

## 🔍 Overview

**Stack Backup Automation** is a production-ready Bash script designed for DevOps engineers who need a reliable, automated backup solution for their server projects. The script handles:

1. **Compression** — Archives the target project directory into a `.tar.gz` file
2. **Cloud Upload** — Transfers the archive to Google Drive using `rclone`
3. **Notifications** — Sends real-time Telegram alerts on backup start, success, or failure
4. **Cleanup** — Automatically removes temporary local files after upload

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Linux Server (VPS)                        │
│                                                                  │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  Cron Job   │───▶│  stack-backup.sh │───▶│  tar -czf       │  │
│  │  (Scheduler)│    │  (Main Script)   │    │  (Compression)  │  │
│  └─────────────┘    └────────┬────────┘    └────────┬────────┘  │
│                              │                       │           │
│                              ▼                       ▼           │
│                    ┌─────────────────┐    ┌─────────────────┐   │
│                    │  Telegram API   │    │    Rclone       │   │
│                    │  (Notifications)│    │  (Cloud Sync)   │   │
│                    └────────┬────────┘    └────────┬────────┘   │
│                              │                       │           │
└──────────────────────────────┼───────────────────────┼───────────┘
                               │                       │
                               ▼                       ▼
                     ┌─────────────────┐    ┌─────────────────┐
                     │  Telegram Bot   │    │  Google Drive    │
                     │  📱 Alerts      │    │  ☁️ Storage      │
                     └─────────────────┘    └─────────────────┘
```

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🗜️ **Smart Compression** | Uses `tar` with gzip to create compact archives with timestamps |
| ☁️ **Cloud Backup** | Uploads directly to Google Drive via `rclone` |
| 📱 **Telegram Alerts** | Real-time notifications for backup start, success & failure |
| 📊 **Status Reports** | Includes file name, size, and destination in notifications |
| 🧹 **Auto Cleanup** | Removes temporary files after successful upload |
| ⏰ **Cron Ready** | Designed to be scheduled with cron for full automation |
| 🔒 **Secure** | Supports running with elevated privileges for protected directories |

---

## 📦 Prerequisites

- **Linux Server** (Ubuntu/Debian/CentOS)
- **Root or sudo access**
- **Google Account** (for Google Drive storage)
- **Telegram Account** (for notifications)
- **Internet connection** on the server

---

## 🚀 Setup Guide

### Step 1: Create a Dedicated Email for Backup

> 💡 **Best Practice**: Use a dedicated Google account for server backups to separate it from your personal account.

1. Go to [accounts.google.com](https://accounts.google.com)
2. Click **"Create account"**
3. Fill in the details for your backup account:
   - **Name**: `Server Backup` (or your preferred name)
   - **Email**: e.g., `my-server-backup@gmail.com`
   - **Password**: Use a strong, unique password
4. Complete the setup and **enable 2FA** (Two-Factor Authentication) for extra security

> ⚠️ **Important**: Save these credentials securely — you'll need them to configure `rclone`.

---

### Step 2: Install Required Tools

#### Install `rclone`

```bash
# Install rclone using the official script
curl https://rclone.org/install.sh | sudo bash
```

Verify installation:

```bash
rclone version
```

#### Install `curl` (if not already installed)

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y curl

# CentOS/RHEL
sudo yum install -y curl
```

---

### Step 3: Configure Rclone with Google Drive

This is the core step that connects your server to Google Drive.

```bash
rclone config
```

Follow the interactive setup:

```
n) New remote
name> gdrive
Storage> drive
client_id> (leave blank, press Enter)
client_secret> (leave blank, press Enter)
scope> 1    # Full access to all files
root_folder_id> (leave blank, press Enter)
service_account_file> (leave blank, press Enter)
```

#### 🖥️ Authorization (for headless servers without a browser)

Since most servers don't have a browser, you'll need to authorize on your local machine:

1. When prompted `Use auto config?`, select **`n`** (No):

```
Use auto config?
n) No
y) Yes
n/y> n
```

2. You'll see a URL like:

```
Please go to the following link: https://accounts.google.com/o/oauth2/auth?...
```

3. **On your local machine** (with a browser):

```bash
# Install rclone locally if not already installed
# Then run:
rclone authorize "drive"
```

4. A browser window will open — **sign in with the backup Google account** you created in Step 1
5. Grant the requested permissions
6. Copy the authorization token that appears in your terminal
7. **Paste the token back** on your server when prompted

8. Continue the configuration:

```
Configure this as a team drive?
y/n> n

y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

#### ✅ Verify Rclone Connection

```bash
# List contents of your Google Drive
rclone lsd gdrive:

# Create the backup folder
rclone mkdir gdrive:Backup_Server
```

---

### Step 4: Create a Telegram Bot

1. Open Telegram and search for **[@BotFather](https://t.me/BotFather)**
2. Send the command:
   ```
   /newbot
   ```
3. Follow the prompts:
   - **Bot Name**: `Server Backup Bot` (display name)
   - **Bot Username**: `my_server_backup_bot` (must end with `bot`)
4. **BotFather** will give you an **API Token** like:
   ```
   123456789:ABCdefGHIjklMNOpqrsTUVwxyz
   ```
5. **Save this token** — you'll need it for the script configuration

> 🔐 **Security**: Never share your bot token publicly!

---

### Step 5: Get Your Telegram Chat ID

1. Open a chat with your newly created bot on Telegram
2. Send any message to the bot (e.g., `/start` or `hello`)
3. Open this URL in your browser (replace `YOUR_BOT_TOKEN`):

```
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

4. Look for the `"chat"` object in the JSON response:

```json
{
  "ok": true,
  "result": [
    {
      "message": {
        "chat": {
          "id": 123456789,
          "type": "private"
        }
      }
    }
  ]
}
```

5. **Copy the `id` value** — this is your **Chat ID**

> 💡 **Tip**: If the result is empty, send another message to the bot and refresh the URL.

---

### Step 6: Configure the Backup Script

1. **Clone the repository** on your server:

```bash
git clone https://github.com/YOUR_USERNAME/stack-backup-automation.git
cd stack-backup-automation
```

2. **Edit the script** with your actual values:

```bash
nano stack-backup.sh
```

3. **Update the configuration variables** at the top of the file:

```bash
# ================= Telegram Settings =================
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"      # ← Paste your bot token here
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"          # ← Paste your chat ID here

# ================= Path Settings =================
SOURCE_DIR="/home/your-user/my-stack"    # ← Path to the directory you want to backup
```

4. **Make it executable**:

```bash
chmod +x stack-backup.sh
```

---

### Step 7: Test the Script

Run the script manually to verify everything works:

```bash
sudo ./stack-backup.sh
```

**Expected behavior:**
1. ⏳ You receive a Telegram notification: *"بدأ ضغط ورفع النسخة الاحتياطية..."*
2. The script compresses the directory
3. The archive uploads to Google Drive
4. ✅ You receive a success notification with file name and size
5. The temporary file is removed

**Verify on Google Drive:**

```bash
rclone ls gdrive:Backup_Server
```

---

### Step 8: Setup Cron Job for Automation

This is the final step to make your backups fully automated.

#### Open the crontab editor:

```bash
sudo crontab -e
```

> 💡 **Why `sudo crontab`?** Because the script uses `sudo tar` to access protected directories. Using root's crontab ensures it runs with the necessary permissions.

#### Add the backup schedule:

```bash
# ╔══════════════════════════════════════════════════════════════╗
# ║            Stack Backup Automation - Cron Job                ║
# ║  Runs daily at 3:00 AM server time                          ║
# ╚══════════════════════════════════════════════════════════════╝

0 3 * * * /path/to/stack-backup-automation/stack-backup.sh >> /var/log/stack-backup.log 2>&1
```

#### Understanding the Cron Syntax:

```
┌───────────── Minute (0-59)
│ ┌─────────── Hour (0-23)
│ │ ┌───────── Day of Month (1-31)
│ │ │ ┌─────── Month (1-12)
│ │ │ │ ┌───── Day of Week (0-7, 0 & 7 = Sunday)
│ │ │ │ │
│ │ │ │ │
0 3 * * *   /path/to/stack-backup.sh >> /var/log/stack-backup.log 2>&1
│ │ │ │ │              │                         │
│ │ │ │ │              │                         └── Redirect output to log file
│ │ │ │ │              └── Full path to the script
│ │ │ │ └── Every day of the week
│ │ │ └── Every month
│ │ └── Every day
│ └── At hour 3 (3:00 AM)
└── At minute 0
```

#### Verify the cron job is saved:

```bash
sudo crontab -l
```

---

## 📅 Cron Schedule Examples

| Schedule | Cron Expression | Description |
|----------|----------------|-------------|
| 🌅 Daily at 3 AM | `0 3 * * *` | Best for most use cases |
| 🌙 Every 12 Hours | `0 */12 * * *` | For critical projects |
| 📅 Weekly (Sunday 2 AM) | `0 2 * * 0` | For less active projects |
| 📆 Monthly (1st at midnight) | `0 0 1 * *` | For archival purposes |
| ⏱️ Every 6 Hours | `0 */6 * * *` | For high-priority systems |

---

## 🔧 Troubleshooting

<details>
<summary><b>❌ Rclone fails to upload</b></summary>

- Verify rclone configuration:
  ```bash
  rclone config show gdrive
  ```
- Test connectivity:
  ```bash
  rclone lsd gdrive:
  ```
- Re-authorize if token expired:
  ```bash
  rclone config reconnect gdrive:
  ```
</details>

<details>
<summary><b>📵 Telegram notifications not working</b></summary>

- Verify bot token:
  ```bash
  curl "https://api.telegram.org/botYOUR_TOKEN/getMe"
  ```
- Test sending a message manually:
  ```bash
  curl -s -X POST "https://api.telegram.org/botYOUR_TOKEN/sendMessage" \
    -d chat_id="YOUR_CHAT_ID" \
    -d text="Test message"
  ```
- Make sure you've started a conversation with the bot first
</details>

<details>
<summary><b>⏰ Cron job not executing</b></summary>

- Check cron logs:
  ```bash
  grep CRON /var/log/syslog
  ```
- Verify cron service is running:
  ```bash
  sudo systemctl status cron
  ```
- Make sure the script path is absolute (not relative)
- Ensure the script has execute permissions:
  ```bash
  chmod +x /path/to/stack-backup.sh
  ```
</details>

<details>
<summary><b>🗜️ Compression fails</b></summary>

- Check available disk space:
  ```bash
  df -h /tmp
  ```
- Verify the source directory exists:
  ```bash
  ls -la /home/your-user/my-stack
  ```
- Check sudo permissions
</details>

---

## 🔒 Security Notes

> ⚠️ **Important security practices for production use:**

- **Never commit credentials** — Keep `BOT_TOKEN` and `CHAT_ID` out of version control
- **Use environment variables** — Consider sourcing credentials from a `.env` file:
  ```bash
  source /etc/stack-backup/.env
  ```
- **Restrict file permissions** — Limit who can read the script:
  ```bash
  chmod 700 stack-backup.sh
  ```
- **Use a dedicated Google account** — Don't use your personal account for server backups
- **Enable 2FA** — On both Google and Telegram accounts
- **Rotate tokens** — Periodically regenerate your Telegram bot token via BotFather

---

## 📁 Project Structure

```
stack-backup-automation/
├── stack-backup.sh     # Main backup script
└── README.md           # Documentation (you are here)
```

---

## 👨‍💻 Author

**Mohammed** — DevOps Engineer

---

<p align="center">
  <b>Made with ❤️ for reliable server backups</b>
</p>

<p align="center">
  <i>⭐ Star this repo if you found it useful!</i>
</p>
