#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

POSTS_DIR = File.expand_path('../_posts', __dir__)
TAG_DIR = File.expand_path('../tag', __dir__)

def read_front_matter(path)
  content = File.read(path)
  if content =~ /\A---\s*\n(.*?\n?)^---\s*\n/m
    YAML.load($1) || {}
  else
    {}
  end
end

tags = {}
Dir.glob(File.join(POSTS_DIR, '*')).each do |f|
  next unless File.file?(f)
  fm = read_front_matter(f)
  t = fm['tags'] || fm['tag'] || []
  t = [t] unless t.is_a?(Array)
  t.each { |tag| tags[tag.to_s] = true }
end

if tags.empty?
  puts "No tags found in _posts. Nothing to do."
  exit 0
end

puts "Found tags: #{tags.keys.join(', ')}"

tags.keys.each do |tag|
  safe_tag = tag.to_s
  dir = File.join(TAG_DIR, safe_tag)
  FileUtils.mkdir_p(dir)
  file = File.join(dir, 'index.html')
  content = <<~PAGE
    ---
    layout: tag_page
    title: "Posts tagged with: #{tag}"
    tag: #{tag}
    permalink: /tag/#{safe_tag}/
    ---

  PAGE
  File.write(file, content)
  puts "Wrote #{file}"
end

puts "Done. Run 'jekyll build' or 'bundle exec jekyll serve' to regenerate site." 
