#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'fileutils'

MEGABYTE = 1024.0 * 1024.0
def bytesToMeg bytes
  "#{(bytes /  MEGABYTE).round(3)} MB"
end

# this script looks at the files that were processed to see how much, if any, change in file size occurred

stats = 'stats.csv'
processed_file = 'processed.csv'
original_folder = "/original"

if File.exists? processed_file
  # read in the processed videos
  videos = []
  CSV.parse(File.new(processed_file)) do |row|
    if row.length > 0
      videos << row
    end
  end

  # for each video, get the original and processed file size
  videos.each do |video|
    puts "------------------"
    original = video.first
    processed = original.gsub(original_folder, '')
    puts "- original: #{original}"
    puts "- processed: #{processed}"
    
    original_size = File.size(original)
    processed_size = File.size(processed)
  
    video << original_size
    video << processed_size
    video << original_size-processed_size
    
    puts "- difference = #{bytesToMeg(original_size-processed_size)}"
  end

  puts "------------------"
  puts "------------------"
  puts "------------------"

  # create summary results
  puts "total files: #{videos.length}"
  puts "total with original > processed: #{videos.select{|x| x[1] > x[2]}.length}"
  puts "total with original < processed: #{videos.select{|x| x[1] < x[2]}.length}"
  puts "sum original size: #{bytesToMeg(videos.map{|x| x[1]}.inject(:+))}"
  puts "average original size: #{bytesToMeg(videos.map{|x| x[1]}.inject(:+).to_f / videos.size)}"
  puts "sum processed size: #{bytesToMeg(videos.map{|x| x[2]}.inject(:+))}"
  puts "average processed size: #{bytesToMeg(videos.map{|x| x[2]}.inject(:+).to_f / videos.size)}"
  puts "sum difference size: #{bytesToMeg(videos.map{|x| x[3]}.inject(:+))}"
  puts "average difference size: #{bytesToMeg(videos.map{|x| x[3]}.inject(:+).to_f / videos.size)}"

  puts "------------------"
  puts "------------------"

  puts "files where original > processed:"
  videos.select{|x| x[1] > x[2]}.sort_by{|x| x[2]}.each do |x|
    puts "#{bytesToMeg(x[3])}; original: #{bytesToMeg(x[1])}; processed: #{bytesToMeg(x[2])}"
  end

  puts "------------------"
  puts "------------------"

  puts "files where original < processed:"
  videos.select{|x| x[1] < x[2]}.sort_by{|x| x[2]}.each do |x|
    puts "#{bytesToMeg(x[3])}; original: #{bytesToMeg(x[1])}; processed: #{bytesToMeg(x[2])}"
  end

end

