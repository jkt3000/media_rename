# require 'test_helper'

# class MediaRename::FileParserTest < ActiveSupport::TestCase

#   MOVIES = [
#     {
#       file: "countdown.to.zero.2010.xvid-submerge.avi",
#       title: "Countdown To Zero",
#       year: "2010",
#       tag: nil
#     },
#     {
#       file: "Nim's.Island[2008]DvDrip-aXXo.avi",
#       title: "Nim's Island",
#       year: "2008",
#       tag:  nil
#     },
#     {
#       file: "Kingdom of Heaven 2005 DC Roadshow (1080p Bluray x265 HEVC 10bit AAC 5.1 Tigole)",
#       title: "Kingdom Of Heaven",
#       year: "2005",
#       tag: "Directors Cut"
#     },
#     {
#       file: "Defiance DvDSCR[2009] ( 10rating ).avi",
#       title: "Defiance",
#       year: "2009",
#       tag: nil
#     },
#     {
#       file: "Adoration 2008 DvdRip ExtraScene RG.avi",
#       title: "Adoration",
#       year: "2008",
#       tag: nil
#     }
#   ]

#   class TestMedia 
#     include MediaRename::FileParser

#     attr_reader :filename

#     def initialize(f)
#       @filename = sanitize_filename(f)
#     end
#   end

#   def setup
#   end

#   # sanitize_filename

#   # extract title

#   # extract year

#   test "#extract_year returns back first valid year found in filename" do
#     # MOVIES.each do |movie|
#     #   parser = MediaRename::FileParser.new(movie[:file])
#     #   assert_equal movie[:title], parser.title
#     #   assert_equal movie[:year], parser.year
#     #   assert_equal movie[:tag], parser.tag
#     # end
#   end


#   # extract tags

#   test "#extract_tags returns back expected tag" do
#     f = "Kingdom of Heaven 2005 DC Roadshow (1080p Bluray x265 HEVC 10bit AAC 5.1 Tigole)"
#     @f = TestMedia.new(f)
#     assert_equal "Directors Cut", @f.extract_tags(@f.filename)

#     f = "Kingdom of Heaven 2005 Director's Cut (1080p Bluray x265 HEVC 10bit AAC 5.1 Tigole)"
#     @f = TestMedia.new(f)
#     assert_equal "Directors Cut", @f.extract_tags(@f.filename)

#     f = "Kingdom of Heaven 2005 (extended version)"
#     @f = TestMedia.new(f)
#     assert_equal "Extended", @f.extract_tags(@f.filename)

#     f = "Kingdom of Heaven 2005 unrated dc (1080p)"
#     @f = TestMedia.new(f)    
#     assert_equal "Directors Cut Unrated", @f.extract_tags(@f.filename)
#   end

#   test "#extract_tags does not return tag if tag words are within a word" do
#     f = "the dcators"
#     @f = TestMedia.new(f)    
#     assert_nil @f.extract_tags(@f.filename)
#   end

#   test "#extract_tags extracts multiple tags and uniqs them" do
#     f = "Kingdom of Heaven 2005 unrated dc (1080p)"
#     @f = TestMedia.new(f)
#     assert_equal "Directors Cut Unrated", @f.extract_tags(@f.filename)
#   end

#   # get_file_type

#   # extract_season

#   test "#extract_season returns season number when filename contains season info" do
#     f = "The Newsroom S01E2.avi"
#     @f = TestMedia.new(f)
#     assert_equal "01", @f.extract_season(@f.filename)

#     f = "The Newsroom S1E2.avi"
#     @f = TestMedia.new(f)
#     assert_equal "01", @f.extract_season(@f.filename)

#     f = "The Newsroom S01 E2.avi"
#     @f = TestMedia.new(f)
#     assert_equal "01", @f.extract_season(@f.filename)
#   end

#   # extract episode

#   test "#extract_episode returns season number when filename contains season info" do
#     f = "The Newsroom S01E12.avi"
#     @f = TestMedia.new(f)
#     assert_equal "12", @f.extract_episode(@f.filename)

#     f = "The Newsroom S1E2.avi"
#     @f = TestMedia.new(f)
#     assert_equal "02", @f.extract_episode(@f.filename)

#     f = "The Newsroom S01 E2.avi"
#     @f = TestMedia.new(f)
#     assert_equal "02", @f.extract_episode(@f.filename)

#     f = "The Newsroom S01 E02.avi"
#     @f = TestMedia.new(f)
#     assert_equal "02", @f.extract_episode(@f.filename)
#   end

# end