module MediaRename

  class PlexRenamer

    attr_reader :plex
    attr_accessor :path

    def initialize(path, options = {})
      @path = File.expand_path(path)
      @plex = if plex_id = options.fetch(:plex_library, nil)
        Plex.server.section(plex_id)
      else
        detect_plex_library(@path)
      end
      raise MediaRename::LibraryNotFound unless @plex
    end

    # options parameters
    #   :preview => true|false
    def run(options = {})
      paths, files = get_files_and_paths(path)
      paths.each {|path| process_path(path) }
      files.each {|file| process_file(file) }
    end

    def process_path(path)
      log.debug("Processing [#{path}]")
      media_files = MediaRename::Utils.detect_media_files(path)
      log.debug("Found Media files: #{media_files}")
      log.debug("Searching Plex library for file")
      if movie = media_files.map {|file| @plex.find_by_filename(file) }.first
        log.debug("Matched movie #{movie.title}")
      else
        log.debug("[Warn] No movie matching filename found. Skip.")
        return
      end


      

      # for each movie file in subdirectory
        # if file exists in plex
          # get movie 
          # move file and contents to new path
          # remove old subdirectory
        # else
          # skip
    end

    def process_file(file)
    end



    private

    def log
      @log ||= MediaRename.logger
    end

    def get_files_and_paths(path)
      paths, files = Dir.glob(MediaRename::Utils.escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
      log.debug("Found in [#{path}] Paths: #{paths.count} Files: #{files.count}")
      [paths, files]
    end

    def detect_plex_library(path)
      section = Plex.server.sections.detect {|section| section.locations.include?(path) }
    end

  end
end
