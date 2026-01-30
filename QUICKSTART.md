# AppCask Quick Start Guide

## 🎉 Welcome to AppCask!

AppCask is a powerful command-line tool that helps you download various resources from App Store applications.

## Get Started in 5 Minutes

### 1️⃣ Installation

```bash
gem install appcask
```

### 2️⃣ First Time Use

The simplest way - just run:

```bash
appcask
```

Then follow the prompts!

### 3️⃣ Quick Search

If you know what app you're looking for:

```bash
appcask "Instagram"
```

### 4️⃣ Select Download Content

After running, you'll see 4 options:

```
[1] Icons       - Download app icons (4 sizes)
[2] Screenshots - Download app screenshots (iPhone and iPad)
[3] App Info    - Export detailed app information
[4] Full Package - Download everything at once
```

We recommend beginners choose **[4] Full Package** to get all resources in one go!

## Common Use Cases

### Scenario 1: I want high-resolution app icons

```bash
appcask "App Name"
# Select [1] Icons
# Select [3] 1024x1024
```

### Scenario 2: I need all screenshots of the app

```bash
appcask "App Name"
# Select [2] Screenshots
# Select all (download screenshots for all devices)
```

### Scenario 3: I need detailed info for app analysis

```bash
appcask "App Name"
# Select [3] App Info
# Generates 3 files: TXT, JSON, Markdown
```

### Scenario 4: I want everything!

```bash
appcask "App Name"
# Select [4] Full Package
# Download icons, screenshots, and info in one go
```

## Where Are Downloaded Files Saved?

Default save location:

```
~/Desktop/AppCask Downloads/App Name/
```

Directory structure:

```
Instagram/
├── icons/              # Icons in all sizes
├── screenshots/        # Screenshots organized by device
│   ├── iPhone/
│   └── iPad/
├── app_info.txt       # Text format info
├── app_info.json      # JSON format info
└── README.md          # Markdown format documentation
```

## Search App Stores in Other Countries

AppCask supports 9 countries/regions:

```bash
# Search China region
appcask "WeChat" cn

# Search Japan region
appcask "Line" jp

# Search Korea region
appcask "KakaoTalk" kr
```

Supported region codes:
- `us` - 🇺🇸 United States
- `cn` - 🇨🇳 China
- `jp` - 🇯🇵 Japan
- `kr` - 🇰🇷 Korea
- `hk` - 🇭🇰 Hong Kong
- `tw` - 🇹🇼 Taiwan
- `gb` - 🇬🇧 United Kingdom
- `de` - 🇩🇪 Germany
- `fr` - 🇫🇷 France

## Shortcuts

- **Enter** - Use default option
- **q** - Exit current step
- **Ctrl+C** - Safely exit the program

## Useful Tips

### Tip 1: Batch Download

Create a text file `apps.txt`:

```
Instagram
Twitter
Facebook
TikTok
```

Then run:

```bash
while read app; do
  appcask "$app"
  sleep 2
done < apps.txt
```

### Tip 2: Preview Only, No Download

Want to see what information is available without downloading? Press `q` to exit anytime!

### Tip 3: macOS Exclusive

After download completes, select `y` to open the folder directly:

```
Open folder? (y/n): y
```

## Having Issues?

### Issue 1: Can't find the app

✅ Solutions:
- Check spelling
- Try searching with the English name
- Switch to different regions

### Issue 2: Network timeout

✅ Solutions:
- Check network connection
- Use VPN
- Try again later

### Issue 3: Download failed

✅ Solutions:

```bash
DEBUG=1 appcask "App Name"
```

This will display detailed error messages for troubleshooting.

## What's Next?

### Learn More Features

Check full documentation:

```bash
# If you have the gem installed
gem help appcask
```

Or visit the GitHub repository to view README.md

### Upgrade to Latest Version

```bash
gem update appcask
```

### Share Your Experience

⭐ Find it helpful? Give the project a Star

📝 Have questions? Submit an Issue

🚀Have suggestions? Open a Pull Request

## Lastly

Enjoy using AppCask! If you have any questions, feedback is always welcome.

🎊 Happy downloading!
