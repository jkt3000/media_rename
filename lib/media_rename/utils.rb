module MediaRename

  require 'fileutils'

  module Utils

    MEDIA_FILES    = %w| .mp4 .mov .mkv .avi .m4v |
    SUB_FILES      = %w| .srt .idx .sub |
    KEY_FOLDERS = [
      "subs", "Subtitles", "Extras", "Featurettes",
      "Bonus Disc", "Deleted Scenes"
    ].map(&:downcase)

    extend self


    def files(path)
      ls(path).last
    end

    def folders(path)
      ls(path).first
    end

    def media_files(path)
      list = files(path).select {|file| MEDIA_FILES.include?(File.extname(file).downcase) }
      log.debug("Found #{list.count} media files: #{list}")
      list
    end

    def subtitle_files(path)
      list = files(path).select {|f| SUB_FILES.include?(File.extname(f).downcase) }
      log.debug("Found #{list.count} subtitle files: #{list}")
      list
    end

    def key_subfolders(path)
      list = folders(path).select {|p| KEY_FOLDERS.include?(File.basename(p.downcase)) }
      log.debug("Found #{list.count} subfolders: #{list}")
      list
    end

    def mv_subtitle_files(path, target_file, options = {})
      dest_path = File.dirname(target_file)
      subtitle_files(path).each do |file|
        dest_file = File.join(dest_path, [File.basename(target_file, ".*"), File.extname(file)].join)
        mv(file, dest_file, options)
      end
    end

    def mv_subfolders(path, target_file, options = {})
      dest_path = File.dirname(target_file)
      key_subfolders(path).each do |subfolder|
        dest_file = File.join(dest_path, File.basename(subfolder))
        mv(subfolder, dest_file, options)
      end
    end
    
    def mv(source, dest, options = {})
      log.debug("Move: Dest does not exist..skip") && return if dest.nil?
      log.debug("Move: Source does not exist..skip") && return unless File.exist?(source)
      log.debug("Move: Source and Dest are the same...skip.") && return if source == dest
      log.info("Move: #{File.basename(source)} => #{dest}")
      mkdir(File.dirname(dest), options)
      FileUtils.mv source, dest, verbose: options[:verbose], noop: options[:preview]
    end

    def mkdir(path, options = {})
      return if File.directory?(path)
      log.debug("Creating directory [#{path}]")
      FileUtils.mkdir_p path, verbose: options[:verbose], noop: options[:preview]
    end

    def rm_path(path, options = {})
      log.debug("Deleting directory [#{path}]")
      FileUtils.rm_rf path, verbose: options[:verbose], noop: options[:preview] 
    end

    def empty?(path)
      Dir.glob(escape_glob("#{path}/*")).empty?
    end


    private


    def ls(path)
      path = File.expand_path(File.directory?(path) ? path : File.dirname(path))
      Dir.glob(escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
    end

    def escape_glob(s)
      s.gsub(/[\[\]\{\}]/) {|x| "\\" + x }
    end

    def log
      @log ||= MediaRename.logger
    end

  end
end