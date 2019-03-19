module MediaRename

  class Movie
    
    TMBD_IMAGE_PATH = "http://image.tmdb.org/t/p/"
    THUMBNAIL_PATH  = "160w"

    attr_reader :title, :year, :popularity, :thumbnail_url

    def initialize(entry)
      @title         = entry.title
      @year          = entry.release_date.present? ? Date.parse(entry.release_date).year : nil
      @popularity    = entry.popularity
      @thumbnail_url = [TMBD_IMAGE_PATH, THUMBNAIL_PATH, entry.poster_path].compact.join
    end

    def to_liquid
      {
        title: title,
        year: year,
        popularity: popularity,
        thumbnail_url: thumbnail_url
      }
    end
  end
end