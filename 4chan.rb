# 4chan downloader using ruby
# developed and tested on ubuntu

require "fileutils"
require "nokogiri"
require "open-uri"

# CONFIG

IMAGES_DIR = "images"
DEBUG = false
archive = false


# ============================
# Do not Alter pass this point
# ============================

# PREPARATIONS (directories, etc)
unless File.exists?(File.join(IMAGES_DIR))
    Dir.mkdir(File.join(IMAGES_DIR))
end

# ASKING URL
print "Paste the URL to download: "
url = gets.chomp

if url == ""
    abort("Please put URL!!")
end

# INITIALIZING
# e.g : http://boards.4chan.org/s/res/13870434

ID = url.split('/').last
CAT = url.split("/")[3]

unless File.exists?(File.join(IMAGES_DIR,CAT))
	Dir.mkdir(File.join(IMAGES_DIR,CAT))
end

# CHECKING URL
if Dir[File.join(IMAGES_DIR,CAT,"*")].grep(/#{ID}/).size > 0
	puts "This URL have been downloaded. We will skip existing images."
	DIRNAME = Dir[File.join(IMAGES_DIR,CAT,"*")].grep(/#{ID}/).first.gsub(/^.*\//,"")
else
	puts "Directory name:"
	print "> "
	dir_name = gets.chomp.downcase.gsub(/[\?\!\/\ \.\,\\]+/,"_")
	DIRNAME = ID + ( dir_name != "" ? "_" : "") + dir_name
	Dir.mkdir(File.join(IMAGES_DIR,CAT,DIRNAME))
end

# PROCESSING URL

puts "Now crawling #{url}"

doc = Nokogiri::HTML(open(url))
images = doc.css('a.fileThumb')

puts "There are #{images.size} images"
puts "Saving images to #{File.join(IMAGES_DIR,CAT,DIRNAME).to_s}"



# DOWNLOAD IMAGES
# if File.exists?(File.join(IMAGES_DIR,CAT,DIRNAME))

loop_number = 1

images.each do |image|
	img = "http:" + image.attr('href')
	filename = img.gsub(/^.*\//,"")

	print "#{loop_number}/#{images.size} "
	if File.exist?(File.join(IMAGES_DIR,CAT,DIRNAME,filename))
		puts "File #{filename} exist, skipping"
	else
		print "Downloading #{filename}..."

		File.open(File.join(IMAGES_DIR,CAT,DIRNAME,filename),'wb') do |save_file|
			open(img,'rb') do |read_file|
				save_file.write(read_file.read)
			end
		end
		puts "done!"
	end
	loop_number += 1
end

# ARCHIVE (only on nix)


# ALL done
puts "Your #{images.size} images saved in #{File.join(IMAGES_DIR,CAT,DIRNAME)}."