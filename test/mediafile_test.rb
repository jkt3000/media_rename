require 'test_helper'

class MediaRename::MediafileTest < ActiveSupport::TestCase

  def setup
    @file = load_file("Skyfall.2012.1080p.BluRay.x264-TiMELORDS.mkv")
    @path = File.expand_path('./../files', __FILE__)
  end

  test "#create creates a mediafile object for a file" do
    media_params = {
      width: 1920, 
      height: 1080, 
      video_codec: 'h264', 
      audio_codec: "aac", 
      audio_channels: 2
    }
    mock_mediainfo(media_params)
    @media = MediaRename::Mediafile.new(@file)
    attribs = @media.attributes

    assert !@media.directory?
    assert_equal "Skyfall.2012.1080p.BluRay.x264-TiMELORDS.mkv", File.basename(@media.filename)
    assert_equal "mkv", @media.ext
    assert @media.exists?
    assert_equal "Skyfall", @media.title
    assert_equal "2012", @media.year
  end

  test "#create creates a mediafile object for a directory" do
    @media = MediaRename::Mediafile.new(@path)
    assert @media.directory?
    assert_equal "", @media.ext
  end

  test "#create a mediafile for file that doesn't exist" do
    @file = load_file("not-valid-file.avi")
    @media = MediaRename::Mediafile.new(@file)
    assert_equal :unknown, @media.type
    assert !@media.exists?
    assert !@media.directory?
  end


  # # mediainfo

  # test "#attributes returns hash if file is not valid or a movie" do
  #   @media = MediaRename::Mediafile.new(load_file("sample_files.txt"))
  #   expected = { type: :unknown }
  #   assert_equal expected, @media.to_hash
  # end

  # test "#attributes returns hash of type :directory if file is a path" do
  #   @media = MediaRename::Mediafile.new(load_file("./"))
  #   expected = { type: :directory }
  #   assert_equal expected, @media.to_hash
  # end


end
