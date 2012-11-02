#!/usr/bin/env ruby

# Beta 1

# Config
config = {
	# the name of dir where images being downloaded
	:images_dir => "images",

	# whether to overwrite downloaded images
	:overwrite => false,

	# may warning if images has more than defined
	:max_image => 25,

	# whether make archive (.tar) file from downloaded dir
	:archive => false,

	# downloader, using pure ruby (0) or wget (1)
	:downloader => 0
}

# =================================================
# !!! Do not modify below !!!!
# Unless you understand
# =================================================

# TODO:
# - first time using script, generating folder, config, etc - BETA
# - sorts folder into their respective categories, eg: /a for anime and manga - ALPHA
# - set warning for more than x images
# - better history
# - using full ruby code to download files instead using wget - DONE

require "fileutils"
require 'open-uri'
require 'nokogiri'

puts "---+--------------------------".gsub('-',' ')
puts "--+----+++-+----+++---++------".gsub('-',' ')
puts "-+-+--+----+-------+-+--+-----".gsub('-',' ')
puts "++++  +----+++--++++-+--+-----".gsub('-',' ')
puts "---+---+++-+--+-++++-+--+-----".gsub('-',' ')

# 4chan categories
categories = {
	"a" => "anime and manga",
	"b" => "random",
	"c" => "anime/cute",
	"d" => "hentai/alternative",
	"e" => "ecchi",
	"f" => "flash",
	"g" => "technology",
	"gif" => "animated gif",
	"h" => "hentai",
	"hr" => "high resolution",
	"k" => "weapons",
	"m" => "mecha",
	"o" => "auto",
	"p" => "photo",
	"r" => "request",
	"s" => "sexy beautiful women",
	"t" => "torrent",
	"u" => "yuri",
	"v" => "video games",
	"vg" => "video games general",
	"w" => "anime/wallpaper",
	"wg" => "wallpaper/general",
	"i" => "oekaki",
	"ic" => "artwork/critique",
	"r9k" => "robot9001",
	"cm" => "cute/male",
	"hm" => "handsome men",
	"y" => "yaoi",
	"3" => "3d",
	"adv" => "advice",
	"an" => "animal and nature",
	"cgl" => "cosplay and egl",
	"ck" => "food and cook",
	"co" => "comic and cartoon",
	"diy" => "do-it-yourself",
	"fa" => "",
	"fit" => "",
	"hc" => "",
	"int" => "",
	"jp" => "",
	"lit" => "",
	"mlp" => "",
	"mu" => "",
	"n" => "",
	"po" => "",
	"pol" => "",
	"sci" => "",
	"soc" => "",
	"sp" => "",
	"tg" => "",
	"toy" => "",
	"trv" => "",
	"tv" => "",
	"vp" => "",
	"wsg" => "",
	"x" => "",
	"rs" => ""
}
history = "history.txt"

# Checking for first time
puts "Initializing"

# checking for image destination folder
if File.exist?(config[:images_dir])
	categories.each do |cat,desc|
		unless File.exist?(File.join(config[:images_dir],cat))
			puts "Creating folder /#{cat} (#{desc}) in #{config[:images_dir]}"
			Dir.mkdir(File.join(config[:images_dir],cat))
		end
	end
else
	Dir.mkdir(config[:images_dir])
	categories.each do |cat,desc|
		puts "Creating folder /#{cat} (#{desc}) in #{config[:images_dir]}"
		Dir.mkdir(File.join(config[:images_dir],cat))
	end
end

# making history
unless File.exist?(history)
	puts "Creating #{history}"
	FileUtils.touch history
end


# parsing history file
history_txt = File.open(history).read
histories = history_txt.split("\n")
if histories.size > 0
	h_last = histories.last.split(':::')
	puts "Last url is #{h_last.last}\nat #{Time.at(h_last.first.to_i).strftime('%e %B %Y %H:%M:%S')}"
end

print "Put 4chan url: "

input = gets.chomp.downcase

if input == ""
	if histories.size > 0
		puts "Attempting redownload previous url..."
		h_last = histories.last.split(':::')
		input = h_last.last
	else
		puts "No history found"
	end
else
	File.open(history,'a') {|f| f.write "#{Time.now.to_i}:::#{input}\n"}
end

# category, where the file belong
category = input.split('/')[3]

# thread_id, name of the folder based on thread id
thread_id = input.gsub(/^.*\//,'')


if File.exist?(File.join(config[:images_dir],category,thread_id))
	puts "Warning! Thread #{thread_id} already downloaded!"
else
	puts "Creating new dir..."
	print "Dir name (default: #{thread_id}/): "
	t = gets.chomp.downcase
	if t != ""
		thread_id = "#{thread_id}_#{t}"
	end
	FileUtils.mkdir(File.join(config[:images_dir],category,thread_id))
	puts "Directory #{thread_id} created"
end

puts "crawling `#{input}`"
doc = Nokogiri::HTML(open(input))
images = doc.css('a.fileThumb')

puts "Got #{images.size} #{images.size > 1 ? 'images' : 'image'}"
puts "Saving images to #{File.join(config[:images_dir],category,thread_id)}"
num = 1
images.each do |image|
	img = "http:" + image.attr('href').downcase

	filename = img.gsub(/^.*\//,'')
	# TODO check if file already exist in thread, pass this if exist! - DONE
	if File.exist?(File.join(config[:images_dir],category,thread_id,filename))
		puts "File #{filename} exist, skipping..."
	else
		print "[#{num}/#{images.size}] Downloading #{filename}..."

		case config[:downloader]
		when 1
			# using wget
			system("wget --quiet \"#{img}\" -P '#{File.join(config[:images_dir],category,thread_id)}'")
		else
			# pure ruby download
			File.open(File.join(config[:images_dir],category,thread_id,filename),'wb') do |save_file|
				open(img,'rb') do |read_file|
					save_file.write(read_file.read)
				end
			end
		end
		puts "done!"
	end
	num += 1
end

puts "Files are saved in dir `#{File.join(config[:images_dir],category,thread_id)}`"

if config[:archive] == true
	puts "Archiving #{thread_id}..."
	system("tar -cvf #{thread_id}.tar #{File.join(config[:images_dir],category,thread_id)}")
end

puts "Done!"