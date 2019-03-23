module MediaRename

  class PlexRenamer

    attr_reader :plex, :options, :target_path
    attr_accessor :path

    DEFAULT_OPTIONS = { preview: true }

    def initialize(path, options = {})
      @options     = DEFAULT_OPTIONS.dup.merge(options)
      @path        = File.expand_path(path)
      @target_path = @options.fetch(:target_path, root_path)
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
      MediaRename::Utils.folders(path).each {|path| process_path(path) }
      MediaRename::Utils.files(path).each {|file| process_file(file) }
    end

    def process_path(path)
      log.debug("---------------------------\n\n")
      log.debug("Processing subdirectory: #{path}")
      
      entries = find_plex_medias(path)
      if entries.empty?
        log.debug("[Warn] No movie matching filename found. Skip.")
        return
      end

      entries.map do |entry|
        log.debug("-- Match media [#{entry[:media].movie.title}]")
        create_movie(entry)
      end
      MediaRename::Utils.rm_path(path, options)
    end

    def process_file(file)
      log.debug("\n\n")
      log.debug("Processing file: #{file}")
      # if any root files to process
    end


    def find_plex_medias(path)
      matches = MediaRename::Utils.media_files(path).map do |file| 
        next unless movie = @plex.find_by_filename(file)
        {file: file, media: movie.media_by_file(file)}
      end.compact
    end
    
    def create_movie(entry)
      old_file = entry[:file]
      path     = File.dirname(old_file)
      new_file = File.join(target_path, MediaRename::Templates.render_template(entry[:media]))
      
      MediaRename::Utils.mv(old_file, new_file, options)
      MediaRename::Utils.mv_subtitles(path, new_file, options)
      MediaRename::Utils.mv_subfolders(path, new_file, options)      
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
