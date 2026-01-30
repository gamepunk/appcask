# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-01-29

### 🎉 Initial Release

#### 🆕 Download Modes
- ✨ **Icon Download** - 4 sizes available (60x60 to 1024x1024)
- 📸 **Screenshot Download** - Batch download for iPhone and iPad screenshots
- 📝 **App Info Export** - 3 formats (TXT/JSON/Markdown)
- 📦 **Full Package Download** - One-click download of all resources

#### 📋 App Info Fields
- Basic Info: Name, ID, Bundle ID, Developer
- Version Info: Version number, file size, system requirements, supported devices
- Rating Data: Average rating, number of ratings
- Price Info: Price, currency
- Category Info: Primary category, all categories
- Content Info: App description, version update notes
- Link Info: App Store link, developer website

#### 🌍 More Regions
New support added for:
- 🇹🇼 Taiwan (tw)
- 🇬🇧 United Kingdom (gb)
- 🇩🇪 Germany (de)
- 🇫🇷 France (fr)

## [0.2.0] - 2026-01-30

- Fix: include bin/appcask in gem package
- Add: improved CLI UX and error messages
- Add: full app info export (txt/json/markdown)
- Improve: screenshot & icon download stability

## [0.3.0] - 2026-01-30

### 🏗️ Refactoring
- Rename module from `Appcask` to `AppCask` for better naming convention
- Use `require_relative` instead of `require` for internal dependencies

## [0.4.0] - 2026-01-30

### 🔒 Security
- Add SSL certificate verification (`OpenSSL::SSL::VERIFY_PEER`)

### 🎨 UI Improvements  
- Fix region selection display format (one region per line for better readability)

### 📚 Documentation
- Update Ruby version requirement in README
