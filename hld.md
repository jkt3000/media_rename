# HLD

# models and modules

./bin/media_renamer 
  rename(file|path)
    - find all files
    - process options, params
    - for each filename
      - lookup file type
      - get new target name
      - make change if confirmed


metadata = FileParser.lookup(filename)
  {
    type: :unknown | :directory | :movie | :tv | :audio | :subtitle 
    filename: <original file>
    exists: true | false
    directory: true | false
    ext: 
    title:
    year:
    tv_season:
    tv_episode:
    video_format:
    video_codec:
    audio_codec:
    tags:
  }

  case :type
    when :directory
      # delete or remove
    when :movie
      if movie = Media.find_movie(metadata)
        new_file = Templates.render_movie(movie, params)
      else
        # failed to find movie
      end
    when :tv
      if tv = Media.find_tv(metadata)
        new_file = Templates.render_tv(movie, params)
    when :audio
      # do nothing
    else
      # delete or move
