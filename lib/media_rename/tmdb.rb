module MediaRename

  module TMDB
    extend self

    def find_movie(query, options = {})
      results = TMDb::Movie.search(query, options)
      sleep(0.5) # handle this better
      results.map {|entry| MediaRename::Movie.new(entry)}
    end

    def find_tv(query, options = {})
      results = TMDb::Tv.search(query, options)
      sleep(0.5) # handle this better
      results.map {|entry| MediaRename::TV.new(entry)}
    end

  end

end