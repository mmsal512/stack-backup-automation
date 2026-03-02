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
  <br/>
  <b>حل نسخ احتياطي تلقائي للسيرفر مع تخزين سحابي وإشعارات فورية عبر تلجرام</b>
</p>

<p align="center">
  <a href="#-english-documentation">📖 English</a> •
  <a href="#-التوثيق-بالعربية">📖 عربي</a>
</p>

---

# 📖 English Documentation

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

1. ⏳ You receive a Telegram notification: *"Backup started..."*
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

<br/>
<br/>

<div dir="rtl">

# 📖 التوثيق بالعربية

## 📋 جدول المحتويات

- [نظرة عامة](#-نظرة-عامة)
- [البنية المعمارية](#-البنية-المعمارية)
- [المميزات](#-المميزات)
- [المتطلبات الأساسية](#-المتطلبات-الأساسية)
- [دليل الإعداد](#-دليل-الإعداد)
  - [الخطوة 1: إنشاء بريد إلكتروني مخصص للنسخ الاحتياطي](#الخطوة-1-إنشاء-بريد-إلكتروني-مخصص-للنسخ-الاحتياطي)
  - [الخطوة 2: تثبيت الأدوات المطلوبة](#الخطوة-2-تثبيت-الأدوات-المطلوبة)
  - [الخطوة 3: إعداد Rclone مع Google Drive](#الخطوة-3-إعداد-rclone-مع-google-drive)
  - [الخطوة 4: إنشاء بوت تلجرام](#الخطوة-4-إنشاء-بوت-تلجرام)
  - [الخطوة 5: الحصول على معرف المحادثة Chat ID](#الخطوة-5-الحصول-على-معرف-المحادثة-chat-id)
  - [الخطوة 6: إعداد سكربت النسخ الاحتياطي](#الخطوة-6-إعداد-سكربت-النسخ-الاحتياطي)
  - [الخطوة 7: اختبار السكربت](#الخطوة-7-اختبار-السكربت)
  - [الخطوة 8: إعداد مهمة Cron للأتمتة](#الخطوة-8-إعداد-مهمة-cron-للأتمتة)
- [أمثلة على جداول Cron](#-أمثلة-على-جداول-cron)
- [استكشاف الأخطاء وإصلاحها](#-استكشاف-الأخطاء-وإصلاحها)
- [ملاحظات أمنية](#-ملاحظات-أمنية)

---

## 🔍 نظرة عامة

**Stack Backup Automation** هو سكربت Bash جاهز للإنتاج مصمم لمهندسي DevOps الذين يحتاجون حل نسخ احتياطي موثوق وتلقائي لمشاريع سيرفراتهم. يقوم السكربت بالتالي:

1. **الضغط** — يضغط مجلد المشروع المستهدف في ملف `.tar.gz`
2. **الرفع السحابي** — ينقل الأرشيف إلى Google Drive باستخدام `rclone`
3. **الإشعارات** — يرسل تنبيهات فورية عبر تلجرام عند بدء النسخ، نجاحه أو فشله
4. **التنظيف** — يحذف الملفات المؤقتة تلقائياً بعد الرفع

---

## 🏗️ البنية المعمارية

</div>

```
┌──────────────────────────────────────────────────────────────────┐
│                     (VPS) سيرفر لينكس                            │
│                                                                  │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │  مهمة Cron  │───▶│  stack-backup.sh │───▶│  tar -czf       │  │
│  │  (المجدول)  │    │  (السكربت)      │    │  (الضغط)        │  │
│  └─────────────┘    └────────┬────────┘    └────────┬────────┘  │
│                              │                       │           │
│                              ▼                       ▼           │
│                    ┌─────────────────┐    ┌─────────────────┐   │
│                    │  Telegram API   │    │    Rclone       │   │
│                    │  (الإشعارات)   │    │  (المزامنة)     │   │
│                    └────────┬────────┘    └────────┬────────┘   │
│                              │                       │           │
└──────────────────────────────┼───────────────────────┼───────────┘
                               │                       │
                               ▼                       ▼
                     ┌─────────────────┐    ┌─────────────────┐
                     │  بوت تلجرام    │    │  Google Drive    │
                     │  📱 التنبيهات   │    │  ☁️ التخزين     │
                     └─────────────────┘    └─────────────────┘
```

<div dir="rtl">

---

## ✨ المميزات

</div>

| الميزة | الوصف |
|--------|-------|
| 🗜️ **ضغط ذكي** | يستخدم `tar` مع gzip لإنشاء أرشيفات مضغوطة مع طوابع زمنية |
| ☁️ **نسخ احتياطي سحابي** | رفع مباشر إلى Google Drive عبر `rclone` |
| 📱 **تنبيهات تلجرام** | إشعارات فورية عند بدء النسخ، نجاحه أو فشله |
| 📊 **تقارير الحالة** | تتضمن اسم الملف، حجمه، والوجهة في الإشعارات |
| 🧹 **تنظيف تلقائي** | يحذف الملفات المؤقتة بعد الرفع الناجح |
| ⏰ **جاهز لـ Cron** | مصمم للجدولة مع cron للأتمتة الكاملة |
| 🔒 **آمن** | يدعم التشغيل بصلاحيات مرتفعة للمجلدات المحمية |

<div dir="rtl">

---

## 📦 المتطلبات الأساسية

- **سيرفر لينكس** (Ubuntu/Debian/CentOS)
- **صلاحيات Root أو sudo**
- **حساب Google** (لتخزين Google Drive)
- **حساب تلجرام** (للإشعارات)
- **اتصال إنترنت** على السيرفر

---

## 🚀 دليل الإعداد

### الخطوة 1: إنشاء بريد إلكتروني مخصص للنسخ الاحتياطي

> 💡 **أفضل ممارسة**: استخدم حساب Google مخصص للنسخ الاحتياطي لفصله عن حسابك الشخصي.

1. اذهب إلى [accounts.google.com](https://accounts.google.com)
2. اضغط على **"إنشاء حساب"**
3. أدخل البيانات لحساب النسخ الاحتياطي:
   - **الاسم**: `Server Backup` (أو اسم تفضله)
   - **البريد الإلكتروني**: مثلاً `my-server-backup@gmail.com`
   - **كلمة المرور**: استخدم كلمة مرور قوية وفريدة
4. أكمل الإعداد و**فعّل المصادقة الثنائية (2FA)** لأمان إضافي

> ⚠️ **مهم**: احفظ هذه البيانات بشكل آمن — ستحتاجها لإعداد `rclone`.

---

### الخطوة 2: تثبيت الأدوات المطلوبة

#### تثبيت `rclone`

</div>

```bash
# تثبيت rclone باستخدام السكربت الرسمي
curl https://rclone.org/install.sh | sudo bash
```

<div dir="rtl">

التحقق من التثبيت:

</div>

```bash
rclone version
```

<div dir="rtl">

#### تثبيت `curl` (إذا لم يكن مثبتاً)

</div>

```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y curl

# CentOS/RHEL
sudo yum install -y curl
```

<div dir="rtl">

---

### الخطوة 3: إعداد Rclone مع Google Drive

هذه هي الخطوة الأساسية التي تربط سيرفرك بـ Google Drive.

</div>

```bash
rclone config
```

<div dir="rtl">

اتبع الإعداد التفاعلي:

</div>

```
n) New remote
name> gdrive
Storage> drive
client_id> (اتركه فارغاً، اضغط Enter)
client_secret> (اتركه فارغاً، اضغط Enter)
scope> 1    # وصول كامل لجميع الملفات
root_folder_id> (اتركه فارغاً، اضغط Enter)
service_account_file> (اتركه فارغاً، اضغط Enter)
```

<div dir="rtl">

#### 🖥️ التفويض (للسيرفرات بدون متصفح)

بما أن معظم السيرفرات لا تحتوي على متصفح، ستحتاج للتفويض من جهازك المحلي:

1. عندما يُسأل `Use auto config?`، اختر **`n`** (لا):

</div>

```
Use auto config?
n) No
y) Yes
n/y> n
```

<div dir="rtl">

2. سيظهر لك رابط مثل:

</div>

```
Please go to the following link: https://accounts.google.com/o/oauth2/auth?...
```

<div dir="rtl">

3. **على جهازك المحلي** (الذي يحتوي على متصفح):

</div>

```bash
# ثبت rclone محلياً إذا لم يكن مثبتاً
# ثم نفذ:
rclone authorize "drive"
```

<div dir="rtl">

4. ستفتح نافذة متصفح — **سجل الدخول بحساب Google الاحتياطي** الذي أنشأته في الخطوة 1
5. امنح الأذونات المطلوبة
6. انسخ توكن التفويض الذي يظهر في الطرفية
7. **الصق التوكن** في سيرفرك عند الطلب

8. أكمل الإعداد:

</div>

```
Configure this as a team drive?
y/n> n

y) Yes this is OK
e) Edit this remote
d) Delete this remote
y/e/d> y
```

<div dir="rtl">

#### ✅ التحقق من اتصال Rclone

</div>

```bash
# عرض محتويات Google Drive
rclone lsd gdrive:

# إنشاء مجلد النسخ الاحتياطي
rclone mkdir gdrive:Backup_Server
```

<div dir="rtl">

---

### الخطوة 4: إنشاء بوت تلجرام

1. افتح تلجرام وابحث عن **[@BotFather](https://t.me/BotFather)**
2. أرسل الأمر:

</div>

```
/newbot
```

<div dir="rtl">

3. اتبع التعليمات:
   - **اسم البوت**: `Server Backup Bot` (الاسم الظاهر)
   - **اسم المستخدم**: `my_server_backup_bot` (يجب أن ينتهي بـ `bot`)
4. سيعطيك **BotFather** **توكن API** مثل:

</div>

```
123456789:ABCdefGHIjklMNOpqrsTUVwxyz
```

<div dir="rtl">

5. **احفظ هذا التوكن** — ستحتاجه لإعداد السكربت

> 🔐 **أمان**: لا تشارك توكن البوت أبداً علنياً!

---

### الخطوة 5: الحصول على معرف المحادثة (Chat ID)

1. افتح محادثة مع البوت الجديد على تلجرام
2. أرسل أي رسالة للبوت (مثلاً `/start` أو `hello`)
3. افتح هذا الرابط في متصفحك (استبدل `YOUR_BOT_TOKEN` بتوكن البوت):

</div>

```
https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
```

<div dir="rtl">

4. ابحث عن كائن `"chat"` في استجابة JSON:

</div>

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

<div dir="rtl">

5. **انسخ قيمة `id`** — هذا هو **معرف المحادثة (Chat ID)**

> 💡 **نصيحة**: إذا كانت النتيجة فارغة، أرسل رسالة أخرى للبوت ثم أعد تحميل الرابط.

---

### الخطوة 6: إعداد سكربت النسخ الاحتياطي

1. **انسخ المستودع** على سيرفرك:

</div>

```bash
git clone https://github.com/YOUR_USERNAME/stack-backup-automation.git
cd stack-backup-automation
```

<div dir="rtl">

2. **عدّل السكربت** بالقيم الفعلية:

</div>

```bash
nano stack-backup.sh
```

<div dir="rtl">

3. **حدّث متغيرات الإعداد** في أعلى الملف:

</div>

```bash
# ================= إعدادات تليجرام =================
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"      # ← الصق توكن البوت هنا
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"          # ← الصق معرف المحادثة هنا

# ================= إعدادات المسارات =================
SOURCE_DIR="/home/your-user/my-stack"    # ← مسار المجلد المراد نسخه
```

<div dir="rtl">

4. **اجعله قابلاً للتنفيذ**:

</div>

```bash
chmod +x stack-backup.sh
```

<div dir="rtl">

---

### الخطوة 7: اختبار السكربت

شغّل السكربت يدوياً للتأكد من أن كل شيء يعمل:

</div>

```bash
sudo ./stack-backup.sh
```

<div dir="rtl">

**السلوك المتوقع:**

1. ⏳ تستقبل إشعار تلجرام: *"بدأ ضغط ورفع النسخة الاحتياطية..."*
2. يضغط السكربت المجلد
3. يُرفع الأرشيف إلى Google Drive
4. ✅ تستقبل إشعار نجاح مع اسم الملف وحجمه
5. يُحذف الملف المؤقت

**التحقق على Google Drive:**

</div>

```bash
rclone ls gdrive:Backup_Server
```

<div dir="rtl">

---

### الخطوة 8: إعداد مهمة Cron للأتمتة

هذه هي الخطوة الأخيرة لجعل النسخ الاحتياطي تلقائياً بالكامل.

#### فتح محرر crontab:

</div>

```bash
sudo crontab -e
```

<div dir="rtl">

> 💡 **لماذا `sudo crontab`؟** لأن السكربت يستخدم `sudo tar` للوصول إلى المجلدات المحمية. استخدام crontab الخاص بـ root يضمن تشغيله بالصلاحيات اللازمة.

#### أضف جدول النسخ الاحتياطي:

</div>

```bash
# ╔══════════════════════════════════════════════════════════════╗
# ║        أتمتة النسخ الاحتياطي - مهمة Cron                    ║
# ║  تعمل يومياً الساعة 3:00 صباحاً بتوقيت السيرفر              ║
# ╚══════════════════════════════════════════════════════════════╝

0 3 * * * /path/to/stack-backup-automation/stack-backup.sh >> /var/log/stack-backup.log 2>&1
```

<div dir="rtl">

#### فهم صيغة Cron:

</div>

```
┌───────────── الدقيقة (0-59)
│ ┌─────────── الساعة (0-23)
│ │ ┌───────── يوم الشهر (1-31)
│ │ │ ┌─────── الشهر (1-12)
│ │ │ │ ┌───── يوم الأسبوع (0-7, 0 و 7 = الأحد)
│ │ │ │ │
│ │ │ │ │
0 3 * * *   /path/to/stack-backup.sh >> /var/log/stack-backup.log 2>&1
│ │ │ │ │              │                         │
│ │ │ │ │              │                         └── توجيه المخرجات لملف السجل
│ │ │ │ │              └── المسار الكامل للسكربت
│ │ │ │ └── كل أيام الأسبوع
│ │ │ └── كل الأشهر
│ │ └── كل يوم
│ └── في الساعة 3 (3:00 صباحاً)
└── في الدقيقة 0
```

<div dir="rtl">

#### التحقق من حفظ مهمة Cron:

</div>

```bash
sudo crontab -l
```

<div dir="rtl">

---

## 📅 أمثلة على جداول Cron

</div>

| الجدول | تعبير Cron | الوصف |
|--------|-----------|-------|
| 🌅 يومياً الساعة 3 صباحاً | `0 3 * * *` | الأفضل لمعظم الحالات |
| 🌙 كل 12 ساعة | `0 */12 * * *` | للمشاريع الحرجة |
| 📅 أسبوعياً (الأحد 2 صباحاً) | `0 2 * * 0` | للمشاريع الأقل نشاطاً |
| 📆 شهرياً (اليوم الأول منتصف الليل) | `0 0 1 * *` | لأغراض الأرشفة |
| ⏱️ كل 6 ساعات | `0 */6 * * *` | للأنظمة عالية الأولوية |

<div dir="rtl">

---

## 🔧 استكشاف الأخطاء وإصلاحها

</div>

<details>
<summary><b>❌ فشل Rclone في الرفع</b></summary>

<div dir="rtl">

- تحقق من إعداد rclone:
</div>

```bash
rclone config show gdrive
```
<div dir="rtl">

- اختبر الاتصال:
</div>

```bash
rclone lsd gdrive:
```
<div dir="rtl">

- أعد التفويض إذا انتهت صلاحية التوكن:
</div>

```bash
rclone config reconnect gdrive:
```
</details>

<details>
<summary><b>📵 إشعارات تلجرام لا تعمل</b></summary>

<div dir="rtl">

- تحقق من توكن البوت:
</div>

```bash
curl "https://api.telegram.org/botYOUR_TOKEN/getMe"
```
<div dir="rtl">

- اختبر إرسال رسالة يدوياً:
</div>

```bash
curl -s -X POST "https://api.telegram.org/botYOUR_TOKEN/sendMessage" \
  -d chat_id="YOUR_CHAT_ID" \
  -d text="رسالة تجريبية"
```
<div dir="rtl">

- تأكد أنك بدأت محادثة مع البوت أولاً
</div>
</details>

<details>
<summary><b>⏰ مهمة Cron لا تعمل</b></summary>

<div dir="rtl">

- تحقق من سجلات cron:
</div>

```bash
grep CRON /var/log/syslog
```
<div dir="rtl">

- تحقق من أن خدمة cron تعمل:
</div>

```bash
sudo systemctl status cron
```
<div dir="rtl">

- تأكد أن مسار السكربت مطلق (ليس نسبياً)
- تأكد أن السكربت لديه صلاحيات التنفيذ:
</div>

```bash
chmod +x /path/to/stack-backup.sh
```
</details>

<details>
<summary><b>🗜️ فشل الضغط</b></summary>

<div dir="rtl">

- تحقق من المساحة المتاحة:
</div>

```bash
df -h /tmp
```
<div dir="rtl">

- تحقق من وجود المجلد المصدر:
</div>

```bash
ls -la /home/your-user/my-stack
```
<div dir="rtl">

- تحقق من صلاحيات sudo
</div>
</details>

<div dir="rtl">

---

## 🔒 ملاحظات أمنية

> ⚠️ **ممارسات أمنية مهمة للاستخدام في بيئة الإنتاج:**

- **لا ترفع بيانات الاعتماد أبداً** — أبقِ `BOT_TOKEN` و `CHAT_ID` خارج نظام التحكم بالإصدارات
- **استخدم متغيرات البيئة** — فكر في استيراد البيانات من ملف `.env`:

</div>

```bash
source /etc/stack-backup/.env
```

<div dir="rtl">

- **قيّد صلاحيات الملف** — حدد من يمكنه قراءة السكربت:

</div>

```bash
chmod 700 stack-backup.sh
```

<div dir="rtl">

- **استخدم حساب Google مخصص** — لا تستخدم حسابك الشخصي للنسخ الاحتياطي
- **فعّل المصادقة الثنائية (2FA)** — على حسابي Google و Telegram
- **جدد التوكنات دورياً** — أعد توليد توكن بوت تلجرام عبر BotFather بشكل دوري

---

## 📁 هيكل المشروع

</div>

```
stack-backup-automation/
├── stack-backup.sh     # سكربت النسخ الاحتياطي الرئيسي
└── README.md           # التوثيق (أنت هنا)
```

---

<p align="center">
  <b>👨‍💻 Mohammed — DevOps Engineer</b>
</p>

<p align="center">
  <b>Made with ❤️ for reliable server backups</b>
  <br/>
  <b>صُنع بـ ❤️ لنسخ احتياطي موثوق للسيرفرات</b>
</p>

<p align="center">
  <i>⭐ Star this repo if you found it useful!</i>
  <br/>
  <i>⭐ أضف نجمة للمستودع إذا وجدته مفيداً!</i>
</p>
