$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require "bundler/gem_tasks"
require "rake/testtask"
require "bundler/setup"
require "media_rename"


Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test


desc "List movies that have stereo sound only"
task :stereo_movies do

  library = Plex.server.libraries[1]
  movies = library.all

    stereo_only = []
    multi       = []
    movies.each do |movie|
      medias = movie.medias
      channels = medias.map(&:audio_channels).sort
      next if channels.any? {|c| c > 2}
      if medias.count > 1
        multi << movie
      else
        stereo_only << movie
      end
    end


    open("./stereo_movies.csv", 'wb') do |f|
      f.write "# Movies that have Stero sound only\n"
      stereo_only.map {|m| f.write "#{m.files.first.split("Media/Movies/").last}\n"}
      multi.map {|m| f.write "#{m.title}, #{m.year}, #{m.medias.map(&:audio_channels).sort.join(", ")}\n" }
    end

    puts "stereo: #{stereo_only.count}"
    puts "multi: #{multi.count}"

end
