require 'test_helper'

class MediaRename::PlexRenamerTest < ActiveSupport::TestCase
  
  def setup
    @lib_path = "/volume1/Media/Movies"
    stub_request(:get, Plex.server.query_path("/library/sections")).to_return(status: 200, body: load_response(:libraries))
  end

  test "create a new PlexRenamer model" do
    @renamer = MediaRename::PlexRenamer.new(@lib_path, verbose: true, preview: true, confirm: true, target_path: '/Volumes/Media')
    assert @renamer.library.is_a?(Plex::Library)
    assert @renamer.options.key?(:preview)
    assert @renamer.options.key?(:confirm)
    assert @renamer.options.key?(:target_path)
    assert @renamer.options.key?(:verbose)
  end

  test "create fails if path is invalid" do
    assert_raises MediaRename::LibraryNotFoundError do
      @renamer = MediaRename::PlexRenamer.new('invalid/path')
    end
  end



end