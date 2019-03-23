module MediaRename

  class PlexRenamer

    attr_reader :plex, :options
    attr_accessor :path

    DEFAULT_OPTIONS = { preview: true }

    def initialize(path, options = {})
      @options = DEFAULT_OPTIONS.dup.merge(options)
      @path = File.expand_path(path)
      @plex = if plex_id = options.fetch(:plex_library, nil)
        Plex.server.section(plex_id)
      else
        Plex.server.section_by_path(@path)
      end
      raise MediaRename::LibraryNotFound unless @plex
    end

    # options parameters
    #   :preview => true|false
    def run(options = {})
      MediaRename::Utils.subdirs(path).each {|path| process_path(path) }
      MediaRename::Utils.files(path).each {|file| process_file(file) }
    end

    def process_path(path)
      log.debug("---------------------------\n\n")
      log.debug("Processing subdirectory: #{path}")
      
      entries = find_plex_entry(path)
      if entries.empty?
        log.debug("[Warn] No movie matching filename found. Skip.")
        return
      end

      entries.map do |entry|    
        log.debug("-- Match movie [#{entry[:movie].title}]")
        create_movie(entry)
      end

      raise StandardError, "Breaking"
    end

    def find_plex_entry(path)
      matches = MediaRename::Utils.media_files(path).map do |file| 
        next unless movie = @plex.find_by_filename(file)
        { movie: movie, file: file }
      end
    end

    def process_file(file)
      log.debug("\n\n")
      log.debug("Processing file: #{file}")
      # if any root files to process
    end

    def create_movie(entry)
      old_file = entry[:file]
      new_file = File.join(root_path, MediaRename::Templates.render_from_plex(entry[:file], entry[:movie]))
      
      MediaRename::Utils.mv(old_file, new_file, options)
      MediaRename::Utils.mv_subtitles(old_file, options)
      # move subs folder
      # move featurettes folder
      # MediaRename::Utils.rm_parent(file, options)
    end


    private

    def root_path
      File.expand_path(File.join(path, "../"))
    end

    def log
      @log ||= MediaRename.logger
    end

  end
end
