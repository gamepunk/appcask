# frozen_string_literal: true

require "test_helper"

class TestAppcask < Minitest::Test
  def setup
    @appcask = AppCask
  end

  # Test filename sanitization
  def test_sanitize_filename
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App/Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App\\Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App:Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App*Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, 'App"Name')
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App<Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App>Name")
    assert_equal "App_Name", @appcask.send(:sanitize_filename, "App|Name")
    assert_equal "AppName",  @appcask.send(:sanitize_filename, "  AppName  ")
  end

  # Test image format detection
  def test_detect_png
    png_header = "\x89PNG\r\n\x1A\n".b + "fake content"
    assert_equal "png", @appcask.send(:detect_image_extension, png_header)
  end

  def test_detect_jpg
    jpg_header = "\xFF\xD8".b + "fake content"
    assert_equal "jpg", @appcask.send(:detect_image_extension, jpg_header)
  end

  def test_detect_gif
    gif_header = "GIF89a"
    assert_equal "gif", @appcask.send(:detect_image_extension, gif_header)
  end

  def test_detect_webp
    webp_header = "RIFF1234WEBP"
    assert_equal "webp", @appcask.send(:detect_image_extension, webp_header)
  end

  def test_detect_unknown_defaults_to_jpg
    unknown = "unknown format"
    assert_equal "jpg", @appcask.send(:detect_image_extension, unknown)
  end

  # Test index validation
  def test_valid_index_within_range
    assert @appcask.send(:valid_index?, 0, 10)
    assert @appcask.send(:valid_index?, 5, 10)
    assert @appcask.send(:valid_index?, 9, 10)
  end

  def test_valid_index_out_of_range
    refute @appcask.send(:valid_index?, -1, 10)
    refute @appcask.send(:valid_index?, 10, 10)
    refute @appcask.send(:valid_index?, 100, 10)
  end

  # Test constants
  def test_icon_sizes_constant
    assert_kind_of Hash, AppCask::ICON_SIZES
    assert_equal 4, AppCask::ICON_SIZES.size

    AppCask::ICON_SIZES.each do |_key, value|
      assert_kind_of Hash, value
      assert value.key?(:display)
      assert value.key?(:key)
    end
  end

  def test_countries_constant
    assert_kind_of Hash, AppCask::COUNTRIES
    assert AppCask::COUNTRIES.key?('us')
    assert AppCask::COUNTRIES.key?('cn')
    assert AppCask::COUNTRIES.key?('jp')

    AppCask::COUNTRIES.each do |code, name|
      assert_equal 2, code.length
      assert_kind_of String, name
    end
  end

  def test_download_modes_constant
    assert_kind_of Hash, AppCask::DOWNLOAD_MODES
    assert_equal 4, AppCask::DOWNLOAD_MODES.size

    AppCask::DOWNLOAD_MODES.each do |_key, value|
      assert value.key?(:name)
      assert value.key?(:method)
      assert_kind_of Symbol, value[:method]
    end
  end

  # Test unique filename generation
  def test_get_unique_filename
    require 'tmpdir'
    require 'fileutils'

    Dir.mktmpdir do |dir|
      original = File.join(dir, "test.png")

      # File does not exist yet
      assert_equal original, @appcask.send(:get_unique_filename, original)

      # Create the first file
      FileUtils.touch(original)

      # Should append _1
      expected = File.join(dir, "test_1.png")
      assert_equal expected, @appcask.send(:get_unique_filename, original)

      # Create the second file
      FileUtils.touch(expected)

      # Should append _2
      expected2 = File.join(dir, "test_2.png")
      assert_equal expected2, @appcask.send(:get_unique_filename, original)
    end
  end

  # Test app info JSON generation
  def test_generate_app_info_json
    mock_app = {
      'trackCensoredName' => 'Test App',
      'trackId' => 123456,
      'bundleId' => 'com.test.app',
      'artistName' => 'Test Developer',
      'artistId' => 789,
      'version' => '1.0.0',
      'fileSizeBytes' => 10_485_760,
      'minimumOsVersion' => '14.0',
      'price' => 0,
      'formattedPrice' => 'Free',
      'currency' => 'USD',
      'averageUserRating' => 4.5,
      'userRatingCount' => 1000,
      'primaryGenreName' => 'Utilities',
      'genres' => ['Utilities', 'Productivity'],
      'releaseDate' => '2024-01-01',
      'currentVersionReleaseDate' => '2024-06-01',
      'contentAdvisoryRating' => '4+',
      'description' => 'A test application',
      'releaseNotes' => 'Bug fixes',
      'trackViewUrl' => 'https://apps.apple.com/app/test/id123456',
      'sellerUrl' => 'https://test.com',
      'screenshotUrls' => [],
      'ipadScreenshotUrls' => []
    }

    result = @appcask.send(:generate_app_info_json, mock_app)

    assert_kind_of Hash, result
    assert_equal 'Test App', result[:basic][:name]
    assert_equal 123456, result[:basic][:app_id]
    assert_equal '1.0.0', result[:version][:current_version]
    assert_equal 10.0, result[:version][:file_size_mb]
    assert_equal 4.5, result[:ratings][:average_rating]
  end

  # Test app directory creation
  def test_create_app_directory
    mock_app = {
      'trackCensoredName' => 'Test/App:Name'
    }

    dir = @appcask.send(:create_app_directory, mock_app)

    assert Dir.exist?(dir)
    assert dir.include?('AppCask Downloads')
    assert dir.include?('Test_App_Name')

    # Cleanup
    FileUtils.rm_rf(dir.split('Test_App_Name')[0])
  end
end
