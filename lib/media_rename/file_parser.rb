module MediaRename

  module FileParser

    TITLE_STOP_WORDS = %w| 
      xvid dvdrip dvdscr screener bluray brrip divx hdrip bdrip bdremux hdtv
      h264 h265 hevc hevc10 dolby atmos
      cd1 cd2 
      UHD
      rarbg stv yify
      1080p 720p 2160p
      Multi|

    TAGS = {
      "extended cut"             => "Extended",
      "extented version"         => "Extended",
      "extended"                 => "Extended",
      "unrated"                  => "Unrated",
      "dc"                       => "Directors Cut",
      "director cut"             => "Directors Cut",
      "director's cut"           => "Directors Cut",
      "directors cut"            => "Directors Cut",
      "directors version"        => "Directors Cut",
      "director's version"       => "Directors Cut",
      "directors definitive cut" => "Directors Cut",
      "the final cut"            => "Final Cut",
      "final cut"                => "Final Cut",
      "rogue version"            => "Rogue Version",
      "rogue cut"                => "Rogue Version",
      "ultimate edition"         => "Ultimate Edition",
      "us theatrical cut"        => "Theatrical Cut",
      "fan edit"                 => "Fan Edit",
      "fanedit"                  => "Fan Edit",
      "special edition"          => "Special Edition"
    }
    
    VIDEO_EXT = %w| avi mp4 mkv mov divx|
    AUDIO_EXT = %w| ogg mp3 aac flac |
    SUB_EXT   = %w| sub srt idx |
    IMAGE_EXT = %w| jpeg jpg bmp png tiff|

    MIN_MOVIE_TIME = 100 * 60 # 1.5hr
    MIN_TV_TIME    = 20 * 60  # 24m

    def sanitize_filename(filename)
      # remove extension
      filename = File.basename(filename, ".*")
      # convert . to spaces
      filename = filename.gsub(/\./,' ')
      # add space infront of [] or ()
      filename = filename.gsub(/\[/, " [").gsub(/\(/, " (")

      # remove extra spaces
      filename = filename.gsub(/\s+/, ' ')
      filename.downcase
    end

    def get_file_type(filename)
      return :unknown if !File.exist?(filename)
      return :directory if File.directory?(filename)
      ext = File.extname(filename).gsub(/\./,'')
      case
      when VIDEO_EXT.include?(ext)
        :video
      when AUDIO_EXT.include?(ext)
        :audio
      when SUB_EXT.include?(ext)
        :subtitle
      when IMAGE_EXT.include?(ext)
        :image
      else
        :unknown
      end
    end

    def extract_year(filename)
      # grab year in () or []
      if result = /(\[|\()(\d{4})(\]|\))/.match(filename)
        return result[2]
      end

      # ignore anything after ( or [
      filename = filename.split(/\[|\(/).first.strip
      
      # get filename before any stop words
      TITLE_STOP_WORDS.each do |word|
        filename = filename.downcase.split(/#{word}/).first || ""
      end

      # return year if last word is a year
      words = filename.split(" ")
      if words.count > 1 && result = words.last.match(/(\d{4})/)
        return result[1]
      end

      # get filename before any tags
      TAGS.each_pair do |tag, _|
        filename = filename.split(/#{tag}/).first || filename
      end

      # return year if last word is a year
      words = filename.split(" ")
      if words.count > 1 && result = words.last.match(/(\d{4})/)
        return result[1]
      end
    end

    def extract_title(filename)
      # ignore anything after ( or [
      filename = filename.split(/\[|\(/).first.strip
      
      # get filename before any stop words
      filename = filename.downcase.split(/#{TITLE_STOP_WORDS.join("|")}/).first || ""

      # get filename before any tv season/episode info
      filename = filename.split(/(\A|\s)s\d{1,2}/).first || filename
      # get filename before any tags
      TAGS.each_pair do |tag, _|
        filename = filename.split(/#{tag}/).first || filename
      end

      # remove year if its the last word but not the only word
      words = filename.split(" ").map(&:strip).compact
      if words.count > 0
        filename = if words.last.match(/\d{4}/) && words.count > 1
          words[0..-2].join(" ")
        else
          words.join(" ")
        end
      else
        filename
      end

      # titleize remaining words and strip
      filename.strip.titleize
    end

    def extract_tags(filename)
      tags = TAGS.map do |text, tag|
        tag if matches = filename.match(/(\A|\s|\(|\[)#{text}(\s|\z)/)
      end.compact.uniq.sort.join(" ")
      tags.blank? ? nil : tags
    end

    def extract_season(filename)
      if matches = tv_match(filename)
        "%02d" % matches[2].to_i
      end
    end

    def extract_episode(filename)
      if matches = tv_match(filename)
        "%02d" % matches[4].to_i
      end
    end

    def tv_match(filename)
      filename.match(/\s(s|season)(\d{1,2})\s?(e|episode)(\d{1,2})/)
    end


    private

    def log
      MediaRename.logger
    end
  end


end