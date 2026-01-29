# AppCask 快速入门指南

## 欢迎使用 AppCask! 🎉

AppCask 是一个强大的命令行工具，可以帮你下载 App Store 应用的各种资源。

## 5分钟快速上手

### 1️⃣ 安装

```bash
gem install appcask
```

### 2️⃣ 第一次使用

最简单的方式 - 直接运行:

```bash
appcask
```

然后按照提示操作即可！

### 3️⃣ 快速搜索

如果你知道要找什么应用:

```bash
appcask "Instagram"
```

### 4️⃣ 选择下载内容

运行后，你会看到 4 个选项:

```
[1] 图标          - 下载应用图标（4种尺寸）
[2] 截图          - 下载应用截图（iPhone和iPad）
[3] 简介信息      - 导出应用详细信息
[4] 完整包        - 一次下载所有内容
```

推荐新手选择 **[4] 完整包**，一次获取所有资源！

## 常用场景

### 场景1: 我想要应用的高清图标

```bash
appcask "应用名称"
# 选择 [1] 图标
# 选择 [3] 1024x1024
```

### 场景2: 我需要应用的所有截图

```bash
appcask "应用名称"
# 选择 [2] 截图
# 选择 all (下载所有设备的截图)
```

### 场景3: 我要做应用分析，需要详细信息

```bash
appcask "应用名称"
# 选择 [3] 简介信息
# 会生成 3 个文件: TXT, JSON, Markdown
```

### 场景4: 我什么都要！

```bash
appcask "应用名称"
# 选择 [4] 完整包
# 一次性下载图标、截图、信息
```

## 下载的文件在哪里？

默认保存位置:

```
~/Desktop/AppCask Downloads/应用名称/
```

目录结构:

```
Instagram/
├── icons/              # 所有尺寸的图标
├── screenshots/        # 按设备分类的截图
│   ├── iPhone/
│   └── iPad/
├── app_info.txt       # 文本格式信息
├── app_info.json      # JSON格式信息
└── README.md          # Markdown格式文档
```

## 搜索其他国家的 App Store

AppCask 支持 9 个国家/地区:

```bash
# 搜索中国区
appcask "微信" cn

# 搜索日本区
appcask "Line" jp

# 搜索韩国区
appcask "KakaoTalk" kr
```

支持的区域代码:
- `us` - 🇺🇸 美国
- `cn` - 🇨🇳 中国
- `jp` - 🇯🇵 日本
- `kr` - 🇰🇷 韩国
- `hk` - 🇭🇰 香港
- `tw` - 🇹🇼 台湾
- `gb` - 🇬🇧 英国
- `de` - 🇩🇪 德国
- `fr` - 🇫🇷 法国

## 快捷键

- **回车** - 使用默认选项
- **q** - 退出当前步骤
- **Ctrl+C** - 安全退出程序

## 实用技巧

### 技巧1: 批量下载

创建一个文本文件 `apps.txt`:

```
Instagram
Twitter
Facebook
TikTok
```

然后运行:

```bash
while read app; do
  appcask "$app"
  sleep 2
done < apps.txt
```

### 技巧2: 只看不下载

想看看有哪些信息但不下载？按 `q` 随时退出！

### 技巧3: macOS 用户专属

下载完成后，选择 `y` 直接打开文件夹:

```
是否打开文件夹? (y/n): y
```

## 遇到问题？

### 问题1: 找不到应用

✅ 解决方法:
- 检查拼写
- 尝试用英文名搜索
- 切换不同区域

### 问题2: 网络超时

✅ 解决方法:
- 检查网络连接
- 使用 VPN
- 稍后重试

### 问题3: 下载失败

✅ 解决方法:

```bash
DEBUG=1 appcask "应用名称"
```

这会显示详细的错误信息，方便排查问题。

## 下一步

### 了解更多功能

查看完整文档:

```bash
# 如果安装了 gem
gem help appcask
```

或访问 GitHub 仓库查看 README.md

### 升级到最新版

```bash
gem update appcask
```

### 分享你的使用经验

觉得好用？给项目点个 Star ⭐

有问题？提交 Issue 📝

有建议？发起 Pull Request 🚀

## 最后

享受使用 AppCask！如有任何问题，欢迎反馈。

Happy downloading! 🎊
