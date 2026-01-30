# AppCask - App Store Resources Downloader

<div align="center">

![Version](https://img.shields.io/badge/version-0.4.0-blue.svg)
![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.2.0-red.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

An all-in-one command-line tool for downloading resources of iOS App Store apps
**Icons • Screenshots • App Description • One-click Packaging**

[Features](#-features) • [Installation](#-installation) • [Usage Guide](#-usage-guide) • [Examples](#-usage-examples)

</div>

---

## ✨ Features

### 🎨 Icon Download
- Supports four sizes: 60x60, 100x100, 512x512, 1024x1024
- Auto-detect image formats (PNG/JPG/GIF/WEBP)
- Intelligent file naming

### 📸 Screenshot Download
- iPhone screenshots
- iPad screenshots
- Batch download all screenshots
- Automatic organization and saving

### 📝 Export App Information
- **TXT format** - Human-readable text
- **JSON format** - Structured data
- **Markdown format** - Elegant documentation

Included information:
- Basic information (name, developer, Bundle ID)
- Version information (current version, file size, system requirements)
- Rating statistics (average rating, number of ratings)
- Pricing information
- App description
- Version update notes
- Related links

### 📦 One-click Full Package
Download all resources for the app, including:
- Icons in all sizes
- Screenshots for all devices
- Complete app information (in 3 formats)

### 🌍 Multiregion Support
- 🇺🇸 United States (US)
- 🇨🇳 China (CN)
- 🇯🇵 Japan (JP)
- 🇰🇷 Korea (KR)
- 🇭🇰 Hong Kong (HK)
- 🇹🇼 Taiwan (TW)
- 🇬🇧 United Kingdom (GB)
- 🇩🇪 Germany (DE)
- 🇫🇷 France (FR)

---

## 📦 Installation

```bash
gem install appcask
```

Or from source:

```bash
git clone https://github.com/yourusername/appcask.git
cd appcask
bundle install
rake build
gem install pkg/appcask-1.0.0.gem
```

---

## 🚀 Quick Start

```bash
# Interactive mode
appcask

# Quick search
appcask "Instagram"

# Specify region
appcask "WeChat" cn
```

### Full Demo

```
$ appcask "Twitter"

╔═══════════════════════════════════════════╗
║      AppCask - App Resources Downloader  ║
║              v1.0.0                       ║
╚═══════════════════════════════════════════╝

🔍 Searching for "Twitter"...

📋 Found 3 results:

  [0] X
      Developer: X Corp. | Version: 10.31
      Price: Free | Rating: ⭐ 4.2

Please choose (0-2, or press q to quit): 0

✅ Selected: X

📦 Choose content to download:
  [1] Icon
  [2] Screenshots
  [3] Description
  [4] Full package (Icons + Screenshots + Description)

Please choose (1-4): 4

✨ Download complete!
📁 ~/Desktop/AppCask Downloads/X
📊 Stats: 15 files, total size 8.45 MB
```

---

## 📖 Usage Examples

### Download Only Icons

```bash
appcask "Instagram"
# Choose: [1] Icons → [3] 1024x1024
```

### Download All Screenshots

```bash
appcask "Honor of Kings" cn
# Choose: [2] Screenshots → all
```

### Export App Information

```bash
appcask "Notion"
# Choose: [3] Description
# Output: TXT + JSON + Markdown
```

### Batch Download

```ruby
#!/usr/bin/env ruby

apps = ['Instagram', 'Twitter', 'Facebook']

apps.each do |app|
  system("appcask '#{app}'")
  sleep 2
end
```

---

## 📂 File Structure

```
AppCask Downloads/
└── Instagram/
    ├── icons/
    │   ├── icon-60x60.png
    │   ├── icon-100x100.png
    │   ├── icon-512x512.png
    │   └── icon-1024x1024.png
    ├── screenshots/
    │   ├── iPhone/
    │   └── iPad/
    ├── app_info.txt
    ├── app_info.json
    └── README.md
```

---

## 🔧 Advanced Features

### Debug Mode

```bash
DEBUG=1 appcask "AppName"
```

### Quick Operations

- **Enter** - Default option
- **q** - Quit
- **Ctrl+C** - Interrupt

---

## 🐛 Troubleshooting

**Q: Can't find the app?**
A: Check spelling and try switching regions

**Q: Icon size is wrong?**
A: Some apps do not support 1024x1024

**Q: Network timeout?**
A: Check network, use VPN

**Q: Where are files saved?**
A: `~/Desktop/AppCask Downloads/`

---

## 🎯 Roadmap

- [ ] macOS App Store support
- [ ] App reviews download
- [ ] Batch download mode
- [ ] Web interface

---

## 📄 License

MIT License

---

## 📮 Contact

- GitHub: [@yourusername](https://github.com/yourusername)
- Issues: [Feedback issues](https://github.com/yourusername/appcask/issues)

---

<div align="center">

**Made with ❤️ and Ruby**

</div>
