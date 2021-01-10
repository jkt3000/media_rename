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
    assert_equal 2, paths.count
    assert File.directory?(paths.first)
  end

  # media_files()

  test "#media_files() returns array of video files in path" do
    path = File.expand_path("./test/files") # /test/files
    files = MediaRename::Utils.media_files(path)
    assert_equal 2, files.count
  end

  # subtitle_files()

  test "#subtitle_files() returns array of subtitle files in path" do
  end

  test "#subtitle_files() returns empty array if no subtitle files found in path" do  
  end

  # key_subfolders()

  test "#key_subfolders() returns array of valid subfolders in path" do
  end

  # mv_subtitle_files()

  # mv_subfolders()

  # mv

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

  # rm_path

  test '#rm_dir removes directory' do
    path = File.expand_path("./tmp")
    options = {preview: true}
    FileUtils.expects(:rm_rf).with(path, anything).returns(true)
    MediaRename::Utils.rm_path(path, options)
  end

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
