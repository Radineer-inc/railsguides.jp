#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 1. Unzip archive.zip (downloaded from Google Translator Toolkit)
# 2. Change file extensions to appropriate ones (Ex: .txt -> .md)
# 3. Copy the files to './guides/source/' dir to generate HTMLs.

require 'fileutils'
ARCHIVE_NAME="archive.zip"
`rm -rf archive/`
`unzip #{ARCHIVE_NAME}`

# Correct wrong file extensions in GTT
Dir.glob("./archive/ja/**") do |filename|
  new_name = filename.gsub(".txt", "").gsub(/\.(erb|yaml)\.md/, "#{$1}")
  puts "Rename: #{filename}\t->\t#{new_name}"
  FileUtils.mv(filename, new_name) unless filename == new_name
  FileUtils.cp(new_name, "./source/")
end

# Replace special characters with white spaces in *.md files
# to correct some of forcedly squeezed white spaces by GTT,
# which causes layout break when generating HTML files.
Dir.glob("./source/**.md") do |filename|
  text    = File.read(filename)
  revised = text.gsub("　", "    ").gsub(/\[W(\d)\]/) {' ' * $1.to_i}
  revised.gsub!(/\[BR\]/, "\n")  # GTT replaces '\n' with ' '
  revised.gsub!(/(\r\n)/, "\n")  # GTT uses CR＋LF but should be LF
  revised.gsub!(/\[DLF\]\n/, "") # Delete new line (LF) after this tag
  revised.gsub!(/\[DLF\]/, "")   # Delete invalid DLF tags left
  File.write(filename, revised)
end
