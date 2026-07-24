# frozen_string_literal: true

require "cfpropertylist"
require "icns"
require "mini_magick"
require "fileutils"

module AppCask
  class LocalApp
    APPS_DIR = "/Applications"
    OUTPUT_BASE = File.join(Dir.home, "Desktop", "AppCask Downloads", "Local Apps")

    class << self
      def fetch_all
        puts "\nFetching local app icons..."
        puts "Source: #{APPS_DIR}"
        puts "Output: #{OUTPUT_BASE}\n\n"

        FileUtils.mkdir_p(OUTPUT_BASE)

        apps = Dir.glob(File.join(APPS_DIR, "*.app"))
        total = apps.count
        success = 0
        skipped = 0

        apps.each_with_index do |app_path, index|
          app_name = File.basename(app_path, ".app")
          print "\r[#{index + 1}/#{total}] Processing: #{app_name.ljust(30)}"

          result = extract_icon(app_path)
          if result
            success += 1
          else
            skipped += 1
          end
        end

        puts "\n\n#{"=" * 50}"
        puts "Done!"
        puts "  Total apps: #{total}"
        puts "  Extracted: #{success}"
        puts "  Skipped: #{skipped}"
        puts "  Output: #{OUTPUT_BASE}"
        puts "=" * 50

        # Open folder on macOS
        return unless RUBY_PLATFORM.include?("darwin")

        print "\nOpen the folder? (y/n): "
        response = $stdin.gets
        system("open '#{OUTPUT_BASE}'") if response&.strip&.downcase == "y"
      end

      private

      def extract_icon(app_path)
        # 1. Read Info.plist
        plist_path = File.join(app_path, "Contents", "Info.plist")
        return nil unless File.exist?(plist_path)

        plist = CFPropertyList::List.new(file: plist_path)
        info = CFPropertyList.native_types(plist.value)

        # 2. Get icon file name
        icon_name = info["CFBundleTypeIconFile"] || info["CFBundleIconFile"] || info["CFBundleIconName"]
        return nil unless icon_name

        icon_name += ".icns" unless icon_name.end_with?(".icns")

        # 3. Find .icns file
        icns_path = File.join(app_path, "Contents", "Resources", icon_name)
        return nil unless File.exist?(icns_path)

        # 4. Parse .icns and extract largest PNG
        reader = Icns::Reader.new(icns_path)

        # Priority: 1024 → 512 → 256 → 128
        [1024, 512, 256, 128].each do |size|
          data = reader.image(size: size)
          next unless data
          next unless png?(data)

          # 5. Save as 512x512 PNG
          output_path = output_path(app_path)
          save_as_512(data, size, output_path)
          return output_path
        end

        nil
      rescue StandardError
        nil
      end

      def png?(data)
        png_magic = [0x89, 0x50, 0x4e, 0x47].pack("C4")
        data[0..3] == png_magic
      end

      def save_as_512(data, original_size, output_path)
        if original_size == 512
          # Direct write
          File.write(output_path, data)
        else
          # Need to resize - use mini_magick
          resize_with_mini_magick(data, output_path)
        end
      end

      def resize_with_mini_magick(data, output_path)
        # Write to temp file, resize, then save
        tmp_input = File.join(Dir.tmpdir, "appcask_input_#{Process.pid}.png")
        tmp_output = File.join(Dir.tmpdir, "appcask_output_#{Process.pid}.png")

        File.write(tmp_input, data)

        image = MiniMagick::Image.new(tmp_input)
        image.resize "512x512"
        image.format "png"
        image.write(tmp_output)

        FileUtils.cp(tmp_output, output_path)
      ensure
        FileUtils.rm_f(tmp_input) if tmp_input
        FileUtils.rm_f(tmp_output) if tmp_output
      end

      def output_path(app_path)
        app_name = File.basename(app_path, ".app")
        filename = "#{sanitize_app_name(app_name)}.png"
        File.join(OUTPUT_BASE, filename)
      end

      def sanitize_app_name(name)
        # Keep Chinese characters, convert to lowercase, replace spaces with hyphens
        name.downcase.gsub(/\s+/, "-").gsub(/[^a-z0-9\u4e00-\u9fff-]/, "").gsub(/^-|-$/, "")
      end
    end
  end
end
