require 'test_helper'

class TemplatesTest < ActiveSupport::TestCase

  def setup
    @lib_path = "/volume1/Media/Movies"
    stub_request(:get, Plex.server.query_path("/library/sections")).to_return(status: 200, body: load_response(:libraries))
    stub_request(:get, Plex.server.query_path("/library/sections/1/all")).to_return(status: 200, body: load_response(:movies))
  end

  test "create a movie template" do
    @renamer = MediaRename::PlexRenamer.new(@lib_path, preview: true, target_path: '/Volumes/Media')    
    @movie = @renamer.library.all.first
    p @renamer.target_name_for_file("RARBG.mp4", @movie, @movie.medias.first)
  end

end
