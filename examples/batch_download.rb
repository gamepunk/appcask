#!/usr/bin/env ruby
# AppCask batch download example
# Usage: ruby examples/batch_download.rb

require 'appcask'

# Define the list of apps to download
apps = [
  { name: 'Instagram', region: 'us', description: 'Social media app' },
  { name: 'Twitter',   region: 'us', description: 'Microblogging platform' },
  { name: 'WeChat',    region: 'cn', description: 'Instant messaging app' },
  { name: 'LINE',      region: 'jp', description: 'Messaging app popular in Japan' },
  { name: 'KakaoTalk', region: 'kr', description: 'Messaging app popular in Korea' }
]

puts '=' * 50
puts 'AppCask Batch Download Script'
puts '=' * 50
puts "\nPreparing to download resources for #{apps.size} apps...\n\n"

apps.each_with_index do |app, index|
  puts "\n[#{index + 1}/#{apps.size}] Processing: #{app[:name]} (#{app[:description]})"
  puts '-' * 50

  # Set command-line arguments
  ARGV.clear
  ARGV << app[:name] << app[:region]

  begin
    # Run AppCask
    AppCask.main
    puts "✅ #{app[:name]} downloaded successfully."
  rescue StandardError => e
    puts "❌ Failed to download #{app[:name]}: #{e.message}"
  end

  # Pause to avoid sending requests too frequently
  sleep 2 unless index == apps.size - 1
end

puts "\n" + '=' * 50
puts 'Batch download completed!'
puts '=' * 50