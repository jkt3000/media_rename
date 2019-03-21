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
      log.debug("\n\nProcessing: #{path}")
      
      media_files = MediaRename::Utils.detect_media_files(path)
      log.debug("-- media files: #{media_files}")
      
      matches = media_files.map do |file| 
        next unless movie = @plex.find_by_filename(file)
        { movie: movie, file: file }
      end
      
      if entry = matches.first
        log.debug("-- Match movie \"#{entry[:movie].title}\"")
        create_movie(entry)
        remove_file_and_parent(entry[:file])
      else
        log.debug("[Warn] No movie matching filename found. Skip.")
        return
      end
      raise
    end

    def process_file(file)
      # if any root files to process
    end

    def create_movie(entry)
      old_file = entry[:file]
      new_file = File.join(root_path, MediaRename::Templates.render_from_plex(entry[:file], entry[:movie]))
      
      MediaRename::Utils.mv(old_file, new_file, options)
      MediaRename::Utils.mv_subtitles(old_file, options)
    end

    def remove_file_and_parent(file)
      MediaRename::Utils.rm_parent(file, options)
    end


    private

    def root_path
      File.expand_path(File.join(path, "../"))
    end

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
