module MediaRename

  class TV

    TMBD_IMAGE_PATH = "http://image.tmdb.org/t/p/"
    THUMBNAIL_PATH  = "160w"

    attr_reader :title, :year, :popularity, :thumbnail_url

    def initialize(entry)
      @title         = entry.name
      @year          = entry.first_air_date.present? ? Date.parse(entry.first_air_date).year : nil
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