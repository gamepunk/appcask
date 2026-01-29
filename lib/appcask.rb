# frozen_string_literal: true

require 'appcask/version'
require 'net/https'
require 'open-uri'
require 'json'
require 'fileutils'

module AppCask
  class Error < StandardError; end

  ICON_SIZES = {
    '0' => { display: '60x60', key: 'artworkUrl60' },
    '1' => { display: '100x100', key: 'artworkUrl100' },
    '2' => { display: '512x512', key: 'artworkUrl512' },
    '3' => { display: '1024x1024', key: 'artworkUrl512' }
  }.freeze

  SCREENSHOT_DEVICES = {
    'iphone' => 'iPhone screenshots',
    'ipad' => 'iPad screenshots'
  }.freeze

  COUNTRIES = {
    'us' => 'United States',
    'cn' => 'China',
    'jp' => 'Japan',
    'kr' => 'South Korea',
    'hk' => 'Hong Kong',
    'tw' => 'Taiwan',
    'gb' => 'United Kingdom',
    'de' => 'Germany',
    'fr' => 'France'
  }.freeze

  DOWNLOAD_MODES = {
    '1' => { name: 'Icon Only', method: :download_icon },
    '2' => { name: 'Screenshots Only', method: :download_screenshots },
    '3' => { name: 'Description Only', method: :download_description },
    '4' => { name: 'All Assets', method: :download_all }
  }.freeze

  class << self
    def main
      begin
        get
      rescue Interrupt
        puts "\n\n👋 Goodbye!"
        exit 0
      rescue StandardError => e
        warn "\n❌ Error: #{e.message}"
        warn e.backtrace if ENV['DEBUG']
        exit 1
      end
    end

    def get
      show_banner

      app_name = get_app_name
      country = get_country

      puts "\n🔍 Searching for \"#{app_name}\"..."

      results = search_app(app_name, country)

      if results.nil? || results['resultCount'].to_i.zero?
        warn "❌ No apps found for \"#{app_name}\"."
        return
      end

      selected_app = select_app(results)
      return unless selected_app

      mode = select_download_mode
      return unless mode

      send(mode[:method], selected_app, country)
    end

    private

    def show_banner
      puts <<~BANNER
          ▄▖    ▄▖    ▌
          ▌▌▛▌▛▌▌ ▀▌▛▘▙▘
          ▛▌▙▌▙▌▙▖█▌▄▌▛▖
            ▌ ▌
          
          v#{AppCask::VERSION}
      BANNER
    end

    def get_app_name
      if ARGV.count.positive?
        ARGV[0]
      else
        print '📱 Enter the app name to search: '
        $stdin.gets.chomp.strip
      end
    end

    def get_country
      return ARGV[1] if ARGV.count > 1 && COUNTRIES.key?(ARGV[1])

      puts "\n🌍 Select App Store region:"
      COUNTRIES.each_slice(3) do |slice|
        puts "  " + slice.map { |code, name| "#{code.ljust(4)}- #{name}" }.join("    ")
      end
      print "Choose one (default: us): "

      input = $stdin.gets.chomp.strip.downcase
      input.empty? ? 'us' : (COUNTRIES.key?(input) ? input : 'us')
    end
    def search_app(app_name, country)
      url = URI('https://itunes.apple.com/search')
      params = {
        term: app_name,
        country: country,
        media: 'software',
        entity: 'software',
        limit: '20'
      }

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 10

      request = Net::HTTP::Post.new(url)
      request.set_form_data(params)

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        warn "❌ Search failed: HTTP #{response.code}"
        return nil
      end

      json = JSON.parse(response.body)

      if json['resultCount'].zero?
        warn '😕 No apps found. Please try a different keyword.'
        return nil
      end

      json

    rescue JSON::ParserError => e
      warn "❌ Failed to parse response: #{e.message}"
      nil
    rescue Net::OpenTimeout, Net::ReadTimeout
      warn '❌ Network timeout. Please check your connection.'
      nil
    rescue StandardError => e
      warn "❌ Search error: #{e.message}"
      nil
    end

    def select_app(results)
      puts "\n📋 Found #{results['resultCount']} result(s):\n\n"

      results['results'].each_with_index do |item, index|
        developer = item['artistName'] || 'Unknown Developer'
        price     = item['formattedPrice'] || item['price']
        version   = item['version'] || 'N/A'
        rating    = item['averageUserRating'] ? "⭐ #{item['averageUserRating'].round(1)}" : 'No Rating'

        puts "  [#{index}] #{item['trackCensoredName']}"
        puts "      Developer: #{developer} | Version: #{version}"
        puts "      Price: #{price} | Rating: #{rating}"
        puts
      end

      print "Select an app (0-#{results['resultCount'] - 1}, or press q to quit): "
      input = $stdin.gets.chomp.strip

      return nil if input.downcase == 'q'

      index = input.to_i

      unless valid_index?(index, results['resultCount'])
        warn "❌ Invalid selection."
        return nil
      end

      selected = results['results'][index]
      puts "\n✅ Selected: #{selected['trackCensoredName']}"
      selected
    end

    def select_download_mode
      puts "\n📦 Select download content:\n"
      DOWNLOAD_MODES.each do |key, value|
        puts "  [#{key}] #{value[:name]}"
      end

      print "\nChoose an option (1-4): "
      input = $stdin.gets.chomp.strip

      unless DOWNLOAD_MODES.key?(input)
        warn "❌ Invalid selection."
        return nil
      end

      DOWNLOAD_MODES[input]
    end

    def download_icon(app_info, country)
      puts "\n🎨 Downloading app icon\n"

      size_info = select_icon_size
      return unless size_info

      artwork_url = app_info[size_info[:key]]

      unless artwork_url
        puts "❌ This app does not provide an icon at the selected size."
        return
      end

      # If 1024x1024 is selected, replace 512 with 1024 in the URL
      if size_info[:display].include?('1024')
        artwork_url = artwork_url.gsub('512x512', '1024x1024')
      end

      puts "\n⬇️  Downloading icon..."

      download_dir = create_app_directory(app_info, 'icons')
      file_name = "icon-#{size_info[:display].split(' ').first}"

      download_image(artwork_url, download_dir, file_name)
    end

    def download_screenshots(app_info, country)
      puts "\n📸 Downloading app screenshots\n"

      iphone_urls = app_info['screenshotUrls'] || []
      ipad_urls   = app_info['ipadScreenshotUrls'] || []

      if iphone_urls.empty? && ipad_urls.empty?
        puts "❌ This app does not provide any screenshots."
        return
      end

      puts "Available screenshots:"
      puts "  iPhone: #{iphone_urls.count}" unless iphone_urls.empty?
      puts "  iPad:   #{ipad_urls.count}"   unless ipad_urls.empty?

      print "\nWhich device screenshots would you like to download? (iphone/ipad/all, default: all): "
      device = $stdin.gets.chomp.strip.downcase
      device = 'all' if device.empty?

      download_dir = create_app_directory(app_info, 'screenshots')

      case device
      when 'iphone'
        download_screenshot_set(iphone_urls, download_dir, 'iPhone')
      when 'ipad'
        download_screenshot_set(ipad_urls, download_dir, 'iPad')
      else
        download_screenshot_set(iphone_urls, download_dir, 'iPhone') unless iphone_urls.empty?
        download_screenshot_set(ipad_urls, download_dir, 'iPad')     unless ipad_urls.empty?
      end
    end

    def download_description(app_info, country)
      puts "\n📝 Saving app information\n"

      download_dir = create_app_directory(app_info, 'info')

      # Generate detailed text information
      info_text = generate_app_info_text(app_info)

      # Generate JSON data
      info_json = generate_app_info_json(app_info)

      # Save as TXT
      txt_file = File.join(download_dir, "app_info.txt")
      File.open(txt_file, 'w:UTF-8') { |f| f.write(info_text) }

      # Save as JSON
      json_file = File.join(download_dir, "app_info.json")
      File.open(json_file, 'w:UTF-8') { |f| f.write(JSON.pretty_generate(info_json)) }

      # Save as Markdown
      md_file = File.join(download_dir, "README.md")
      md_text = generate_app_info_markdown(app_info)
      File.open(md_file, 'w:UTF-8') { |f| f.write(md_text) }

      puts "✨ App information saved successfully!"
      puts "📁 Directory: #{download_dir}"
      puts "   - app_info.txt  (Plain text)"
      puts "   - app_info.json (JSON format)"
      puts "   - README.md     (Markdown format)"

      # On macOS, ask whether to open the directory
      if RUBY_PLATFORM.include?('darwin')
        print "\nOpen the folder now? (y/n): "
        response = $stdin.gets.chomp.strip.downcase
        system("open '#{download_dir}'") if response == 'y'
      end
    end

    def download_all(app_info, country)
      puts "\n📦 Downloading full package (icons + screenshots + app info)\n"

      base_dir = create_app_directory(app_info)

      # 1. Download all icon sizes
      puts "\n[1/3] 📥 Downloading icons..."
      icon_dir = File.join(base_dir, 'icons')
      FileUtils.mkdir_p(icon_dir)

      ICON_SIZES.each do |_key, size_info|
        artwork_url = app_info[size_info[:key]]
        next unless artwork_url

        url =
          if size_info[:display].include?('1024')
            artwork_url.gsub('512x512', '1024x1024')
          else
            artwork_url
          end

        filename = "icon-#{size_info[:display].split(' ').first}"
        download_image(url, icon_dir, filename, silent: true)
      end

      # 2. Download all screenshots
      puts "\n[2/3] 📥 Downloading screenshots..."
      screenshot_dir = File.join(base_dir, 'screenshots')
      FileUtils.mkdir_p(screenshot_dir)

      iphone_urls = app_info['screenshotUrls'] || []
      ipad_urls   = app_info['ipadScreenshotUrls'] || []

      download_screenshot_set(iphone_urls, screenshot_dir, 'iPhone', silent: true) unless iphone_urls.empty?
      download_screenshot_set(ipad_urls, screenshot_dir, 'iPad', silent: true)   unless ipad_urls.empty?

      # 3. Save app information
      puts "\n[3/3] 📥 Saving app information..."

      info_text = generate_app_info_text(app_info)
      info_json = generate_app_info_json(app_info)
      info_md   = generate_app_info_markdown(app_info)

      File.open(File.join(base_dir, 'app_info.txt'), 'w:UTF-8')  { |f| f.write(info_text) }
      File.open(File.join(base_dir, 'app_info.json'), 'w:UTF-8') { |f| f.write(JSON.pretty_generate(info_json)) }
      File.open(File.join(base_dir, 'README.md'), 'w:UTF-8')    { |f| f.write(info_md) }

      puts "\n✨ Download completed!"
      puts "📁 All files saved to: #{base_dir}"

      puts "\nDirectory structure:"
      puts "  ├── icons/           (App icons)"
      puts "  ├── screenshots/     (App screenshots)"
      puts "  ├── app_info.txt     (Plain text)"
      puts "  ├── app_info.json    (JSON format)"
      puts "  └── README.md        (Markdown)"

      # Statistics
      files = Dir.glob(File.join(base_dir, '**', '*')).select { |f| File.file?(f) }
      total_files = files.count
      total_size  = (files.sum { |f| File.size(f) } / 1024.0 / 1024.0).round(2)

      puts "\n📊 Summary: #{total_files} files, total size #{total_size} MB"

      # On macOS, ask whether to open the directory
      if RUBY_PLATFORM.include?('darwin')
        print "\nOpen the folder now? (y/n): "
        response = $stdin.gets.chomp.strip.downcase
        system("open '#{base_dir}'") if response == 'y'
      end
    end

    def select_icon_size
      puts "\n📐 Select icon size:\n"
      ICON_SIZES.each { |key, value| puts "  [#{key}] #{value[:display]}" }

      print "\nSelect (0-3, default: 2): "
      input = $stdin.gets.chomp.strip
      input = '2' if input.empty?

      unless ICON_SIZES.key?(input)
        warn "❌ Invalid selection."
        return nil
      end

      ICON_SIZES[input]
    end

    def download_screenshot_set(urls, base_dir, device_name, silent: false)
      return if urls.empty?

      puts "\nDownloading #{device_name} screenshots (#{urls.count})..." unless silent

      device_dir = File.join(base_dir, device_name)
      FileUtils.mkdir_p(device_dir)

      urls.each_with_index do |url, index|
        filename = "screenshot-#{device_name}-#{index + 1}"
        download_image(url, device_dir, filename, silent: silent)
      end

      puts "\n✅ #{device_name} screenshots downloaded" unless silent
    end

    def download_image(url, dir, basename, silent: false)
      uri = URI(url)

      URI.open(uri, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |image|
        content = image.read
        ext = detect_image_extension(content)

        filename = File.join(dir, "#{basename}.#{ext}")
        filename = get_unique_filename(filename)

        File.open(filename, 'wb') { |f| f.write(content) }

        unless silent
          file_size = (File.size(filename) / 1024.0).round(2)
          puts "\n✅ Saved: #{File.basename(filename)} (#{file_size} KB)"
        end
      end
    rescue StandardError => e
      warn "❌ Download failed: #{e.message}" unless silent
    end

    def generate_app_info_text(app_info)
      <<~INFO
    ===================================================
                    APPLICATION DETAILS
    ===================================================

    [Basic Information]
    App Name: #{app_info['trackCensoredName']}
    App ID: #{app_info['trackId']}
    Bundle ID: #{app_info['bundleId']}
    Developer: #{app_info['artistName']}
    Developer ID: #{app_info['artistId']}

    [Version Information]
    Current Version: #{app_info['version']}
    File Size: #{(app_info['fileSizeBytes'].to_i / 1024.0 / 1024.0).round(2)} MB
    Minimum OS Requirement: iOS #{app_info['minimumOsVersion']}
    Supported Devices: #{app_info['supportedDevices']&.join(', ') || 'N/A'}

    [Pricing & Ratings]
    Price: #{app_info['formattedPrice'] || app_info['price']}
    Currency: #{app_info['currency']}
    Rating: #{app_info['averageUserRating'] || 'N/A'} (#{app_info['userRatingCount'] || 0} ratings)

    [Categories]
    Primary Category: #{app_info['primaryGenreName']}
    All Categories: #{app_info['genres']&.join(', ')}

    [Release Information]
    First Released: #{app_info['releaseDate']}
    Last Updated: #{app_info['currentVersionReleaseDate']}
    Content Rating: #{app_info['contentAdvisoryRating']}

    [Description]
    #{app_info['description']}

    [Release Notes]
    #{app_info['releaseNotes'] || 'No release notes provided.'}

    [Developer Information]
    Developer Website: #{app_info['sellerUrl']}

    [Store Link]
    App Store: #{app_info['trackViewUrl']}

    ===================================================
    Exported At: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
    ===================================================
  INFO
    end

    def generate_app_info_json(app_info)
      {
        basic: {
          name: app_info['trackCensoredName'],
          app_id: app_info['trackId'],
          bundle_id: app_info['bundleId'],
          developer: app_info['artistName'],
          developer_id: app_info['artistId']
        },
        version: {
          current_version: app_info['version'],
          file_size_bytes: app_info['fileSizeBytes'],
          file_size_mb: (app_info['fileSizeBytes'].to_i / 1024.0 / 1024.0).round(2),
          minimum_os_version: app_info['minimumOsVersion'],
          supported_devices: app_info['supportedDevices']
        },
        pricing: {
          price: app_info['price'],
          formatted_price: app_info['formattedPrice'],
          currency: app_info['currency']
        },
        ratings: {
          average_rating: app_info['averageUserRating'],
          rating_count: app_info['userRatingCount'],
          rating_count_current_version: app_info['userRatingCountForCurrentVersion']
        },
        categories: {
          primary_genre: app_info['primaryGenreName'],
          all_genres: app_info['genres']
        },
        release: {
          release_date: app_info['releaseDate'],
          current_version_release_date: app_info['currentVersionReleaseDate'],
          content_rating: app_info['contentAdvisoryRating']
        },
        description: app_info['description'],
        release_notes: app_info['releaseNotes'],
        urls: {
          app_store: app_info['trackViewUrl'],
          developer_website: app_info['sellerUrl']
        },
        screenshots: {
          iphone: app_info['screenshotUrls'],
          ipad: app_info['ipadScreenshotUrls']
        },
        exported_at: Time.now.iso8601
      }
    end

    def generate_app_info_markdown(app_info)
      <<~MARKDOWN
    # #{app_info['trackCensoredName']}

    > Developer: #{app_info['artistName']}

    ![Rating](https://img.shields.io/badge/Rating-#{app_info['averageUserRating'] || 'N/A'}-blue)
    ![Version](https://img.shields.io/badge/Version-#{app_info['version']}-green)
    ![Price](https://img.shields.io/badge/Price-#{(app_info['formattedPrice'] || app_info['price']).gsub('-', '--')}-orange)

    ## 📱 Basic Information

    | Item | Value |
    |------|-------|
    | App ID | #{app_info['trackId']} |
    | Bundle ID | #{app_info['bundleId']} |
    | Developer | #{app_info['artistName']} |
    | Primary Category | #{app_info['primaryGenreName']} |
    | Content Rating | #{app_info['contentAdvisoryRating']} |

    ## 📊 Version Information

    - **Current Version**: #{app_info['version']}
    - **File Size**: #{(app_info['fileSizeBytes'].to_i / 1024.0 / 1024.0).round(2)} MB
    - **Minimum OS**: iOS #{app_info['minimumOsVersion']}
    - **Release Date**: #{app_info['currentVersionReleaseDate']}

    ## ⭐ Ratings

    - **Average Rating**: #{app_info['averageUserRating'] || 'N/A'} / 5.0
    - **Total Ratings**: #{app_info['userRatingCount'] || 0}

    ## 📝 Description

    #{app_info['description']}

    ## 🆕 What's New

    #{app_info['releaseNotes'] || 'No release notes provided.'}

    ## 🔗 Links

    - [App Store](#{app_info['trackViewUrl']})
    - [Developer Website](#{app_info['sellerUrl']})

    ---

    *Exported at: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}*
  MARKDOWN
    end

    def detect_image_extension(content)
      return 'png' if content[0..7] == "\x89PNG\r\n\x1A\n".b
      return 'jpg' if content[0..1] == "\xFF\xD8".b
      return 'gif' if content[0..2] == "GIF".b
      return 'webp' if content[8..11] == "WEBP".b
      'jpg'
    end

    def sanitize_filename(filename)
      filename.gsub(/[\/\\:*?"<>|]/, '_').strip
    end

    def create_app_directory(app_info, subdir = nil)
      app_name = sanitize_filename(app_info['trackCensoredName'])

      desktop = File.join(Dir.home, 'Desktop')
      if Dir.exist?(desktop)
        base_dir = File.join(desktop, 'AppCask Downloads', app_name)
      else
        base_dir = File.join(Dir.pwd, 'AppCask Downloads', app_name)
      end

      final_dir = subdir ? File.join(base_dir, subdir) : base_dir
      FileUtils.mkdir_p(final_dir)
      final_dir
    end

    def get_unique_filename(filename)
      return filename unless File.exist?(filename)

      dir = File.dirname(filename)
      basename = File.basename(filename, '.*')
      ext = File.extname(filename)

      counter = 1
      loop do
        new_filename = File.join(dir, "#{basename}_#{counter}#{ext}")
        return new_filename unless File.exist?(new_filename)
        counter += 1
      end
    end

    def valid_index?(index, max)
      index >= 0 && index < max
    end
  end
end
