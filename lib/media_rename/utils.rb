module MediaRename

  require 'fileutils'

  module Utils

    MEDIA_FILES    = %w| .mp4 .mov .mkv .avi |
    SUB_FILES      = %w| .srt .idx .sub |
    MIN_MEDIA_SIZE = 838860800 # 800.megabytes
    KEY_FOLDERS = %w| subs subtitles featurettes | # case insensitive

    extend self


    def files(path)
      ls(path).last
    end

    def folders(path)
      list = ls(path).first
      log.debug("-- folders found: #{list}")
      list
    end

    def media_files(path)
      found = files(path).select do |f| 
        MEDIA_FILES.include?(File.extname(f)) && File.size?(f) > MIN_MEDIA_SIZE
      end
      log.debug("-- media files: #{found}")
      found
    end

    def subtitle_files(path)
      found = files(path).select {|f| SUB_FILES.include?(File.extname(f)) }
      found
    end

    def key_subfolders(path)
      found = folders(path).select {|p| KEY_FOLDERS.include?(File.basename(p.downcase)) }
      found
    end

    def mkdir(path, options = {})
      return if File.directory?(path)
      FileUtils.mkdir_p path, verbose: true, noop: options[:preview]
    end

    def mv_subtitles(source, dest, options = {})
      dest_path = File.dirname(dest)
      subtitle_files(source).each do |file|
        dest_file = File.join(dest_path, File.basename(file))
        mv(file, dest_file, options)
      end
    end

    def mv_subfolders(source, dest, options = {})
      dest_path = File.dirname(dest)
      key_subfolders(source).each do |file|
        dest_file = File.join(dest_path, File.basename(file))
        mv(file, dest_file, options)
      end
    end
    
    def mv(source, dest, options = {})
      log.debug("moving file to #{dest}")
      mkdir(File.dirname(dest), options)
      FileUtils.mv source, dest, verbose: true, noop: options[:preview]
    end

    def rm_path(path, options = {})
      log.debug("deleting directory #{path}")
      FileUtils.rm_rf path, verbose: true, noop: options[:preview] 
    end


    private


    def ls(path)
      path = File.expand_path(File.directory?(path) ? path : File.dirname(path))
      paths, files = Dir.glob(escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
    end

    def escape_glob(s)
      s.gsub(/[\[\]\{\}]/) {|x| "\\" + x }
    end


    def log
      @log ||= MediaRename.logger
    end

  end
end