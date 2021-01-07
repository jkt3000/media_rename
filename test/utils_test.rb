require 'test_helper'

class MediaRename::UtilsTest < ActiveSupport::TestCase

  def setup
    MediaRename.logger.level = :info  # silence debug logs
  end

  # files()

  test "#files(path) returns array of files of given path" do
    path = File.expand_path("./test/files") # /test/files
    files = MediaRename::Utils.files(path)
    assert_equal 3, files.count
    assert File.file?(files.first)
  end

  # folders()

  test "#folders returns array of subfolders in given path" do
    path = File.expand_path("./test") # ./test/

    paths = MediaRename::Utils.folders(path)
    assert_equal 1, paths.count
    assert File.directory?(paths.first)
  end

  # media_files()

  test "#media_files() returns array of video files in path" do
    path = File.expand_path("./test/files") # /test/files
    files = MediaRename::Utils.media_files(path)
    assert_equal 2, files.count
  end

  # media_file?()

  test "#media_files?() returns true if file has video extension" do
    file = File.expand_path("./test/files/RARBG.mp4")
    assert MediaRename::Utils.media_file?(file)
  end

  test "#media_file?() returns false if file does not have video extension" do
    file = File.expand_path("./test/files/sample_files.txt")
    assert !MediaRename::Utils.media_file?(file)
  end

  # subtitle_files()

  # key_subfolders()

  # mkdir

  test "#mkdir makes directory if it does not exist" do
    FileUtils.expects(:mkdir_p).returns(true)
    path = File.expand_path("./test/files_too")
    assert MediaRename::Utils.mkdir(path)
  end
  
  test "#mkdir does not make directory if it exists" do
    FileUtils.expects(:mkdir_p).times(0)
    path = File.expand_path("./test/files")
    MediaRename::Utils.mkdir(path)
  end

  # mv_subtitles()

  # mv_subfolders()

  # mv

  # rm_path


  # empty?

  test "#empty? returns false if path is not empty" do
    assert !MediaRename::Utils.empty?("./")
  end

  test "#empty? returns true if path is empty" do
    path = File.expand_path("/tmp/empty_dir")

    FileUtils.mkdir_p(path)
    assert MediaRename::Utils.empty?(path)
    MediaRename::Utils.rm_path(path)
    assert !File.exist?(path)
  end

end
