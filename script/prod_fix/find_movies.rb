#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'fileutils'

# this script will find all videos that have not been processed and add it to the 
# to_process.csv file

to_process = 'to_process.csv'
path = "../../public/system/places/video/"
original = "/original/"

# for each folder in path, create original folder and move all files into it
Dir.new(path).each do |dir|
  if !(['.', '..'].include?(dir))

    puts dir

    video_path = "#{path}#{dir}"
    original_path = video_path + original

    puts "- video path = #{video_path}"

FileUtils.rm_r(original_path) if Dir.exists?(original_path)


    # create folder if not exist
    FileUtils.mkdir(original_path) if !Dir.exists?(original_path)
    
    # get mp4 files at root of folder
    videos = Dir.glob("#{video_path}/*.mp4")
    if videos.length > 0
     puts "- has #{videos.length} videos"
     videos.each do |video|
        file = File.basename(video)
        puts "- video path: #{video}"
        puts "- video file: #{file}"
        # if video is not already in the original folder, add it to the list
        if !File.exists?(original_path + file)
          # copy to the original folder
          FileUtils.cp(video, original_path)

          # add this video to the csv
          CSV.open(to_process, "a") do |csv|      
            csv << [original_path + file]
          end
        end
      end
    end
  end
end


