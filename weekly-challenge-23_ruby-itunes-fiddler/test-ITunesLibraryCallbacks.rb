require 'rubygems'
require 'flexmock/test_unit'
require 'ITunesLibraryCallbacks'
require 'ITunesLibraryWriter'
require 'test/unit'

class ITunesLibraryCallbacksTest < Test::Unit::TestCase

  def setup
    @filehandle = flexmock( "<<" => "" )
    @ITunesLibraryWriter = flexmock( ITunesLibraryWriter.new( @filehandle ),
                                    "ITunesLibraryWriter"
                                    )
  end

  def test_tracks_collection_start
    @ITunesLibraryWriter.should_receive( "tracks_collection_start" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Tracks"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "dict", [] )
  end

  def test_playlists_collection_start
    @ITunesLibraryWriter.should_receive( "playlists_collection_start" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Playlists"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "array", [] )
  end

  def test_top_level_start
    @ITunesLibraryWriter.should_receive( "top_level_start" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
  end

  def test_track_end
    #<dict>
    #<key>45543</key>
    #<dict>
    #  <key>Track ID</key><integer>45543</integer>
    #  <key>Name</key><string>Fifths (Jazzanova 6 Sickth Mix)</string>
    #  <key>Artist</key><string>Ski</string>
    #  <key>Album</key><string>Jazzanova: The Remixes, 1997-2000</string>
    #</dict>
    track = { :dict => [
        {:type=>"integer", :value=>2, :key=>"Track ID"},
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"string", :value=>"Ski", :key=>"Artist"},
        {:type=>"string", :value=>"Jazzanova: The Remixes, 1997-2000", :key=>"Album"}
      ],
      :key => 2
    }
    @ITunesLibraryWriter.should_receive( "track_end" ).with( track ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Tracks"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "dict", [] )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters 2
    @iTLCInstance.end_element( "key" )

    @iTLCInstance.start_element( "dict", [] )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Track ID"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "integer", [] )
    @iTLCInstance.characters 2
    @iTLCInstance.end_element( "integer" )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Name"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "string", [] )
    @iTLCInstance.characters "John"
    @iTLCInstance.end_element( "string" )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Artist"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "string", [] )
    @iTLCInstance.characters "Ski"
    @iTLCInstance.end_element( "string" )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Album"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "string", [] )
    @iTLCInstance.characters "Jazzanova: The Remixes, 1997-2000"
    @iTLCInstance.end_element( "string" )


    @iTLCInstance.end_element( "dict"  )
  end

  def test_playlist_end
    playlist = {:dict=>[
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"integer", :value=>2, :key=>"Eyes"}
      ]}
    @ITunesLibraryWriter.should_receive( "playlist_end" ).with( playlist ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "playlists"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "array", [] )
    @iTLCInstance.start_element( "dict", [] )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Name"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "string", [] )
    @iTLCInstance.characters "John"
    @iTLCInstance.end_element( "string" )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Eyes"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "integer", [] )
    @iTLCInstance.characters 2
    @iTLCInstance.end_element( "integer" )

    @iTLCInstance.end_element( "dict"  )
  end

  def test_top_level_row
    #<key>Application Version</key><string>10.6.3</string>
    property_row = {:type=>"string", :value=>"10.6.3", :key=>"Application Version"}
    @ITunesLibraryWriter.should_receive( "top_level_row" ).with( property_row ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )

    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Application Version"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "string", [] )
    @iTLCInstance.characters "10.6.3"
    @iTLCInstance.end_element( "string" )
  end

  def test_tracks_collection_end
    @ITunesLibraryWriter.should_receive( "tracks_collection_end" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Tracks"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.end_element( "dict" )
  end

  def test_playlists_collection_end
    @ITunesLibraryWriter.should_receive( "playlists_collection_end" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.start_element( "key", [] )
    @iTLCInstance.characters "Playlists"
    @iTLCInstance.end_element( "key" )
    @iTLCInstance.start_element( "array", [] )
    @iTLCInstance.end_element( "dict" )
  end

  def test_top_level_end
    @ITunesLibraryWriter.should_receive( "top_level_end" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.start_element( "dict", [] )
    @iTLCInstance.end_element( "dict"  )
  end

  def test_library_end
    @ITunesLibraryWriter.should_receive( "library_end" ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle, @ITunesLibraryWriter )
    @iTLCInstance.start_element( "plist", [ :version => "1.0" ] )
    @iTLCInstance.end_element( "plist"  )
  end
end