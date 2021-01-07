require 'test_helper'

class MediaRename::MediaTest < ActiveSupport::TestCase

  def setup
    @file = load_file("Skyfall.2012.1080p.BluRay.x264-TiMELORDS.mkv")
    @path = File.expand_path('./../files', __FILE__)
  end

  # video_format

  test "#video_format returns proper tag for video resolution" do
    assert_equal "4K", MediaRename::Media.video_format(4000, 3000)
    assert_equal "1080p", MediaRename::Media.video_format(1920, 1080)
    assert_equal "720p", MediaRename::Media.video_format(1200, 720)
    assert_equal "480p", MediaRename::Media.video_format(640, 480)
  end

  # video_codec
  test "#video_codec returns HEVC for hevc video formats" do
    assert_equal "HEVC", MediaRename::Media.video_codec("hevc")
    assert_equal "HEVC", MediaRename::Media.video_codec("h265")
  end

  test "#video_codec returns H264 for .h264 video formats" do
    assert_equal "H264", MediaRename::Media.video_codec("h264")
    assert_equal "H264", MediaRename::Media.video_codec("H264")
  end

  test "#video_codec returns MP4 for .mp4 video format" do
    assert_equal "MP4", MediaRename::Media.video_codec("mp4")
    assert_equal "MP4", MediaRename::Media.video_codec("mpeg4")
  end

  test "#video_codec returns nil for unknown video format tag" do
    assert_nil MediaRename::Media.video_codec("mp3")
    assert_nil MediaRename::Media.video_codec(nil)
    assert_nil MediaRename::Media.video_codec('')
  end


  # audio_codec

  test "#audio_codec returns proper tag for known audio codec tags" do
    assert_equal "OTH", MediaRename::Media.audio_codec('oth')
    assert_equal "TRUEHD", MediaRename::Media.audio_codec('truehd')
    assert_equal "AC3", MediaRename::Media.audio_codec('ac3')
    assert_equal "MP3", MediaRename::Media.audio_codec('mp3')
    assert_equal "AAC", MediaRename::Media.audio_codec('aac')
    assert_equal "DTS", MediaRename::Media.audio_codec('dca')
    assert_equal "DTS-HD", MediaRename::Media.audio_codec('dca-ma')
    assert_equal "OTH", MediaRename::Media.audio_codec('')
  end
  
  test "#audio_codec returns proper channel for known audio channel tags" do
    assert_equal "OTH 2.0", MediaRename::Media.audio_codec('oth', 2)
    assert_equal "OTH 2.1", MediaRename::Media.audio_codec('oth', 3)
    assert_equal "OTH 5.1", MediaRename::Media.audio_codec('oth', 6)
    assert_equal "OTH 6.1", MediaRename::Media.audio_codec('oth', 7)
    assert_equal "OTH 7.1", MediaRename::Media.audio_codec('oth', 8)
    assert_equal "OTH", MediaRename::Media.audio_codec('oth')
  end

end
