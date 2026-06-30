#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

POSTS_DIR = File.expand_path('../_posts', __dir__)

updated = []
Dir.glob(File.join(POSTS_DIR, '*')).each do |path|
  next unless File.file?(path)
  content = File.read(path)
  if content =~ /\A---\s*\n(.*?\n?)^---\s*\n/m
    fm_raw = $1
    fm = YAML.load(fm_raw) || {}
    tags = fm['tags'] || fm['tag']
    next unless tags
    tags_arr = tags.is_a?(Array) ? tags : [tags]
    new_tags = tags_arr.map { |t| t.to_s.downcase }
    if new_tags != tags_arr
      fm['tags'] = new_tags
      # backup
      File.write(path + '.bak', content) unless File.exist?(path + '.bak')
      # rebuild front matter (simple YAML dump)
      new_fm = YAML.dump(fm)
      # YAML.dump adds --- header; ensure proper delimiters
      new_content = "---\n" + new_fm + "---\n" + content.sub(/\A---\s*\n(.*?\n?)^---\s*\n/m, '')
      File.write(path, new_content)
      updated << path
      puts "Updated tags in: #{File.basename(path)}"
    end
  end
end

if updated.empty?
  puts "No tags needed lowercasing."
else
  puts "Lowercased tags in #{updated.size} files. Backups saved with .bak suffix."
end
