The task: some script to quickly edit the iTunes library and copy files around.<!--more-->

<h2>About the challenge</h2>
iTunes is quite limiting in what it does and doesn't allow people to do with their own music. There are a number of things which are not easy to do: copying files from a playlists into a USB stick for car journeys, identifying missing files, removing files from the hard disk which are no longer in the iTunes library, and so on.

One can write AppleScript utilities for those types of tasks - check out <a href="http://dougscripts.com/itunes/" title="[new window] Doug's AppleScripts for iTunes ♫ - dougscripts.com" target="_blank">Doug's AppleScripts for iTunes</a> for example - but I try to avoid AppleScript at all costs if I can.

Luckily, iTunes keeps an XML copy of the library data (a <a href="http://en.wikipedia.org/wiki/Property_list" title="[new window] Property list - Wikipedia, the free encyclopedia" target="_blank">plist</a>), one I can manipulate in any language of my choice. Since I have been wanting to play with Ruby for years, I decided to make this my first script. Because the file can get quite huge, an event based parser like SAX should be used, whether it's pull or push (here's <a href="http://www.programmersheaven.com/user/pawanspace/blog/609-XML-parsers-Push-versus-Pull-parsers/" title="[new window] XML parsers: Push versus Pull parsers - Pawan's blog" target="_blank">a quick article explaining the difference between push and pull parsers</a>).

Some artefacts <a href="https://github.com/gotofritz/Weekly-Challenges/" title="[new window] code GitHub" target="_blank">available on GitHub</a>.

<h2>Generating an XML iTunes library file with Ruby</h2>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#bbb;border:2px solid #666;"><code class="user-story">Feature: Generating an XML iTunes library file with Ruby
    In order to manipulate the iTunes library
    As a command line user
    I need to be able to read it and generate a manipulated version</code></pre>

Initially I need to find a good XML parser, and prove that I can read the library file and process it into another library file that is still valid.

<h3>Running a simple Ruby script from the command line</h3>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#ccc;border:1px solid #999;"><code class="scenario">Scenario: Running a simple Ruby script from the command line
    Given that I am in the folder "weekly-challenge-23_ruby-itunes-fiddler"
    When I run the command itunefiddler
    Then the script should run
    And the last line of output should start with "done"</code></pre>
Babysteps, as this is my very first ruby script. This can all be done quickly on the command line:

[bash]touch itunesfiddler
echo '#!/usr/bin/env ruby' >> itunesfiddler
echo '' >> itunesfiddler
echo 'puts "done"' >> itunesfiddler
chmod 775 itunesfiddler
./itunesfiddler
subl itunesfiddler[/bash]

The lines starting with <tt>touch</tt> and <tt>echo</tt> create the files and add a line at the time to it. Then I make it executable, run it, and open it in Sublime Text 2 for further editing.

<h3>Duplicating the XML library file in Ruby</h3>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#ccc;border:1px solid #999;"><code class="scenario">Scenario: Duplicating the XML library file in Ruby
    Given that I have a library XML file called iTunes Music Library.xml
    And an executable ruby script called itunefiddler
    When I run the command itunefiddler
    And I pass --input "iTunes Music Library.xml" as an argument
    And I pass --output "iTunes_library_new.xml" as an argument
    Then "iTunes_library_new.xml" should be created
    And it should be a copy of "iTunes_library.xml"
    And the output should be "done - iTunes_library_new.xml"</code></pre>

This scenario covers passing command line arguments, and opening files for reading and writing.

I started using ARGV to read arguments, but that is nowhere near flexible enough.
[ruby]#!/usr/bin/env ruby

# =itunesfiddler
# parses an XML library file for iTunes into another
ARGV.each do|a|
  puts "Argument: #{a}"
  case a
  when /--input=(\w+)/
    puts "INPUT: #{$1}"
  end
end
puts "done"[/ruby]

Ugly regex alert! I used the OptionParser module in the end.

[ruby]# =itunesfiddler
# parses an XML library file for iTunes into another
require 'optparse'

#reads command line args
options = {}
itunesfiddler = OptionParser.new do |opt|

  #help screen
  opt.banner = "Usage: itunesfiddler --input=FILE [OPTIONS] [COMMAND]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  ""
  opt.separator  "Options"

  #individual options
  opt.on("-i","--input SRC","input xml file") do |src|
    unless File.file? src
      abort( "File not found #{src}" )
    end
    options[:src] = src
    unless options[:target]
      options[:target] = options[:src].clone.insert( -5, ".new" )
    end
  end

  opt.on("-o","--output [TARGET]","output xml file") do |target|
    options[:target] = target
  end

  opt.on("-h","--help","help") do
    puts itunesfiddler
  end

end

#collects args and quits if something wrong
itunesfiddler.parse!
unless options[:src]
  puts itunesfiddler
  abort( "ERROR: missing --input" )
end[/ruby]

As for reading and writing the file, it's all very simple in Ruby.

[ruby]#copies file over
open( options[:target], 'w' ) do |f|
  open( options[:src] ).each { |x|
    f << x
  }
end

puts "done #{options[:target]}"
exit( 0 )[/ruby]

I have added a couple of nice to haves - the <tt>--input=</tt> parameter is mandatory, the <tt>--output=</tt> param is derived from input if not passed.

To test it, first of all I moved <tt>iTunes Library.itl</tt> and <tt>iTunes Music Library.xml</tt> out of the Music/iTunes folder, which means next time iTunes is started it will run with a blank library. Started iTunes, and a new version of <tt>iTunes Music Library.xml</tt> was created automatically. I took that file as the starting point for my work - the real library is too big.

I copied this default XML file to the <tt>weekly-challenge-23_ruby-itunes-fiddler</tt> folder, and manually added some tracks - I copied the XML fragment from the original libray. It's all quite straight forward. I also added a track I knew wasn't there.

To test my hand editing was done properly, I imported the edited XML file with: <span style="background: #eee;display :block">File &gt; Library  &gt; Import Playlist... </span> It did what I expected, i.e. imported the songs I had added manually, as well as complaining about the missing track.

I then quit iTunes and deleted the library files again again. This time I used my script to duplicate the edited XML file [bash]./itunesfiddler --input "iTunes Music Library.xml" --output "iTunes_library_new.xml"[/bash] It created a duplicate called <tt>iTunes_library_new.xml</tt>. I imported that into iTunes, and it worked just like the hand coded original.

So far so good - but no XML parsing yet.


<h2>Using an event based parser to duplicate an XML file</h2>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#bbb;border:2px solid #666;"><code class="user-story">Feature: Using an event based parser to duplicate an XML file
    In order to understand the XML data in the iTunes library
    As a command line user
    I want to duplicate it using a SAX parser</code></pre>

No new functionality is introduced, this is just refactoring to use a SAX parser. I picked the <a href="http://nokogiri.org/Nokogiri/XML/SAX.html" title="[new window] Nokogiri" target="_blank">Nokogiri SAX Parser</a>, which is easily installed as a gem [bash]sudo gem install nokogiri[/bash]

In the code, I subclassed the SAX::Document class to set up all the callbacks, passing a filehandle so that it can write XML out there and then. I could have stored the XML to a temp object and returned that at the end, but I didn't want to keep a 200MB string in memory.

<h3>What is SAX parsing</h3>
If you are not familiar with SAX, the idea is very simple. The parser reads the input file one character at the time, and whenever it detects a point where a node changes, it generates a corresponding event. For example, when it sees a &gt; after a &lt;TAG_NAME it generates the event "node start" (or suchlike), and passes "TAG_NAME" and an array of attributes, to the event call. It then moves on to the next character, forgetting everything about TAG_NAME. It's this forgetting that make SAX parsers useful - because they only remember enough to detect when tags are open or closed, they don't clog the memory.

The way to use a SAX parser is to set up callbacks for each of those events emitted as the parser reads the document. Sounds laborious, but in reality there isn't that much going on in an XML document as you can see from the <a href="http://nokogiri.org/Nokogiri/XML/SAX/Document.html" title="[new window] Nokogiri" target="_blank">list of Nokogiri SAX events</a> - a new tag is found, a tag is finished, a CDATA is found, etc.

The lack of memory is both the strength and the weakness of SAX parsers. Because they have no concept of the data structure they are parsing, it is very hard, for example, to move a node to another parent. Even recognizing where you are at any given time is quite laborious, particularly if you use the same node name at different depths - which is what plists do. SAX parsers are typically used to convert XML data to another format, or extract some nodes from a large list, or do some simple node manipulation.

At this stage however, I am keeping track of nothing, I am just duplicating the file to prove it works.

[ruby]#collection of callbacks for SAX parser
class ITunesLibraryCallbacks < Nokogiri::XML::SAX::Document
  def initialize(filehandle)
    @filehandle = filehandle
  end
  def characters str
    @filehandle << str
  end
  def start_element element_name, attributes
    case element_name
    when "plist"
      @filehandle << '<plist version="1.0">'
    else
      @filehandle << "<#{element_name}>"
    end
  end
  def end_element element_name
    @filehandle << "</#{element_name}>"
  end
  def error error_message
    abort "ERROR: #{error_message}"
  end
end[/ruby]

I only need to worry about three callbacks because plists have a very basic structure - they have no comments, CDATA, or attributes except the root node, which can be hardcoded. Therefore only three callbacks are needed: opening tag, closing tag, and characters (i.e., what's inside a tag).

Then I changed the block that copies the file over. In theory the SAX parser could open its own filehandle and write the whole thing itself, but this particular parser doesn't generate an event for DOCTYPE nodes. Therefore I open a filehandle outside the parser, copy the first two lines of the input files manually, then pass on the filehandle to the parser and let it do its job. Not great, but not the end of the world either.

[ruby]#copies file over
open( options[:target], 'w' ) do |f|
  open( options[:src] ) { |r|
    f << r.readline #the xml declaration - could be handled by parser but...
    f << r.readline #the doctype - this one cannot be handled by the parser
  }
  parser = Nokogiri::XML::SAX::Parser.new( ITunesLibraryCallbacks.new( f ) )
  parser.parse_file( options[:src] )
end[/ruby]

I run it and tested as I did earlier, and iTunes seems happy importing it.

<h3>Extracting track records with SAX parsing</h3>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#ccc;border:1px solid #999;"><code class="scenario">Scenario: Extracting track records with SAX parsing
    Given that the script is parsing the XML iTunes file
    When it encounters the start of a track block
    Then it should hold off producing output until it gets all the related tags</code></pre>

Now the "fun" with SAX parsing can start. To make the whole thing useful, it is important the script can abstract a group of tags into a 'track'. Because SAX has no memory, I need to keep track of what is being parsed. A common trick is to use a breadcrumb.

First of all, I put the ITunesLibraryCallbacks class into its own file, and included it using [ruby]#collection of callbacks for SAX parser
require 'ITunesLibraryCallbacks'

#copies file over
open( options[:target], 'w' ) do |f|
  open( options[:src] ) { |r|
    f << r.readline #the xml declaration - could be handled by parser but...
    f << r.readline #the doctype - this one cannot be handled by the parser
  }
  $iTLCInstance = ITunesLibraryCallbacks.new( f )
  parser = Nokogiri::XML::SAX::Parser.new( $iTLCInstance )
  parser.parse_file( options[:src] )
end

puts "done - #{$iTLCInstance.track_count} tracks, created:#{options[:target]}"
exit( 0 )[/ruby]
I made the instance global, <tt>$iTLCInstance</tt>, so that I can query its <tt>get_count</tt> method later.

<tt>ITunesLibraryCallbacks</tt> will now stop writing output when a new track is found, collect all the track data in an object, and only write it out in one go when the end track in the input is found. Potentially, at that stage further processing is possible (e.g., don't add the track in if the song file doesn't exist, etc).

The code is a bit ugly, but that's partly how SAX parsing goes, and partly this being my first Ruby script.

[ruby]class ITunesLibraryCallbacks < Nokogiri::XML::SAX::Document
  attr_accessor :breadcrumb, :track_count

  def initialize(filehandle)
    @track_count  = 0
    @separator    = "/"
    @breadcrumb   = ""
    @mode         = ""
    @filehandle   = filehandle
    @is_tracks    = false
    @is_playlists = false
    @track = Hash.new
    @element_name = ""
    @track_attr
    @node_separator = "\n       "
    @track_separator = "\n    "
  end

  def characters str
    case str
    when "Tracks"
      @is_tracks    = true
      @filehandle << str
    when "Playlists"
      @is_playlists = true
      @filehandle << str
    else
      if is_track_start
        @track[:key] = str
        @track[:dict] = Array.new
      elsif is_track_key
        @track_attr[:key] = str
      elsif is_track_value
        @track_attr[:value] = str
      elsif !@is_tracks
        @filehandle << str
      end
    end
  end

  def start_element element_name, attributes = []
    breadcrumb_add( element_name )
    @element_name = element_name
    case element_name
    when "plist"
      @filehandle << '<plist version="1.0">'
    else
      if is_top_level_key
        @is_tracks    = false
        @is_playlists = false
        @filehandle << "<#{element_name}>"
      elsif is_track_start
        @track = Hash.new
        @track_count += 1
      elsif is_track_key
        if( nil != @track_attr )
          @track[:dict].push( @track_attr )
        end
        @track_attr = Hash.new
      elsif is_track_value
        @track_attr[:type] = @element_name
      elsif !@is_tracks || is_tracks_container
        @filehandle << "<#{element_name}>"
      end
    end
  end

  def end_element element_name
    if is_track_end
      track_print
    elsif !@is_tracks || is_tracks_container
      @filehandle << "</#{element_name}>"
    end
    breadcrumb_remove
  end

  def breadcrumb_add element_name
    @breadcrumb = @breadcrumb + @separator + element_name
  end

  def breadcrumb_remove
    temp = @breadcrumb.split( @separator )
    temp.pop()
    @element_name = temp[-1]
    @breadcrumb = temp.join( @separator )
  end

  def track_print
    @filehandle << @track_separator + "<key>#{@track[:key]}</key>"
    @filehandle << @track_separator + "<dict>"
    @track[:dict].each { |row|
      t = row[:type]
      @filehandle << @node_separator + "<key>#{row[:key]}</key>" + "<#{t}>#{row[:value]}</#{t}>"
    }
    @filehandle << @track_separator + "</dict>"
  end

  def is_track_start
    return @is_tracks && "/plist/dict/dict/key" == @breadcrumb
  end

  def is_top_level_key
    return "/plist/dict/key" == @breadcrumb
  end

  def is_track_key
    return @is_tracks && "/plist/dict/dict/dict/key" == @breadcrumb
  end

  def is_track_value
    return @is_tracks && [
      '/plist/dict/dict/dict/integer',
      '/plist/dict/dict/dict/string',
      '/plist/dict/dict/dict/true',
      '/plist/dict/dict/dict/false',
      '/plist/dict/dict/dict/date'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  def is_tracks_container
    return @is_tracks && [ '/plist/dict/dict', '/plist/dict/key' ].any? { |bc|
      @breadcrumb === bc
    }
  end

  def is_track_end
    return @is_tracks && "/plist/dict/dict/dict" == @breadcrumb
  end

  def error error_message
    abort "ERROR: #{error_message}"
  end
end[/ruby]

As before I run it on a reduced file and imported the result into iTunes, and it worked. I also benchmarked it against the real iTunes library, a 150MB file with 3M lines and 80k tracks, and it run in 2m47.366s - which is much better than I thought it would be.

<h3>Unit Testing and Mocking a SAX Parser with Ruby</h3>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#ccc;border:1px solid #999;"><code class="scenario">Scenario: Unit Testing and MOcking a SAX parser with Ruby
    Given that I have a ITunesLibraryCallbacks
    When I run unit tests on it
    Then they should pass</code></pre>

Now that I got something useful, it's time to bring unit testing and TDD into the picture, so that I can improve it more easily as my Ruby improves.

I created a file <tt>test-ITunesLibraryCallbacks.tb</tt> [ruby]require 'ITunesLibraryCallbacks'
require 'test/unit'

class ITunesLibraryCallbacksTest < Test::Unit::TestCase

  def setup
    @iTLCInstance = ITunesLibraryCallbacks.new({})
  end

  def terdown
  end

  def test_breadcrumb_add
    @iTLCInstance.breadcrumb_add "test"
    assert_equal '/test', @iTLCInstance.breadcrumb
  end
end[/ruby]

And then run it simply with [bash]ruby -rtest/unit -e0 -- --pattern 'test-'
Loaded suite .
Started
.
Finished in 0.000193 seconds.

1 tests, 1 assertions, 0 failures, 0 errors[/bash]

Blimey, that was easy.

The next step is to mock the writing to file. I did that with FlexMock: [bash]sudo gem install flexmock[/bash]

I wrote a simple test to make sure the mocking works,

[ruby]class ITunesLibraryCallbacksTest < Test::Unit::TestCase
  def setup
    @filehandle = flexmock()
  end

  def test_breadcrumb_add
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle )
    @iTLCInstance.breadcrumb_add "test"
    assert_equal '/test', @iTLCInstance.breadcrumb
  end

  def test_character_add
    chars = "this_should_be_written"
    @filehandle.should_receive( "<<" ).with( chars ).once
    @iTLCInstance = ITunesLibraryCallbacks.new( @filehandle )
    @iTLCInstance.characters chars
  end
end[/ruby]

And it does.

<h3>Refactoring into a library parser, and a library callback class</h3>
Now that I got started on unit testing, it's time for the first round of refactoring. The main objective here is to split the two main responsibilities of the class into separate classes. <tt>ITunesLibraryCallbacks</tt> will concentrate on parsing the input XML and understanding when a track or a plalyist starts or end. It will then generate its own SAX-like events, such as "track start" or "playlist end", and pass data with them.

A new class, <tt>ITunesLibraryWriter</tt>, will respond to these events. The initial implementation will simply output an exact copy of the original XML file (give or take - for example it prints &lt;true&gt;&lt;/true&gt; instead of &lt;true/&gt;). The idea is that when special processing is needed, one overwrites some of the method calls as needed.

The events I added for now are: tracks_collection_start, tracks_collection_end, playlists_collection_start, playlists_collection_end, top_level_start, library_start, track_end, playlist_end, top_level_row, top_level_end, library_end. Here's the code for all of them.

The script itunesfiddler hasn't changed.

ITunesLibraryCallbacks has been changed a lot. It takes an <tt>ITunesLibraryWriter</tt> instance as optional second argument, or will create a vanilla one if none passed.
[ruby collapse="true"]# =ITunesLibraryCallbacks
# SAX callbacks for iTunes library parsing

require 'rubygems'
require 'nokogiri'
require 'ITunesLibraryWriter'

class ITunesLibraryCallbacks < Nokogiri::XML::SAX::Document
  attr_accessor :breadcrumb, :track_count, :is_tracks

  #takes a filehandler as argument
  #optionally an instance of a subclass of ITunesLibraryWriter
  def initialize( *args )
    case args.size
    when 1
      @filehandle   = args[0]
      @library_callbacks = ITunesLibraryWriter.new( args[0] )
    when 2
      @filehandle, @library_callbacks = args
    else
      raise ArgumentError, "This class takes either 1 or 2 arguments."
    end

    @track_count  = 0
    @playlist = Hash.new
    @separator    = "/"
    @breadcrumb   = ""
    @top_level_key    = ""
    @last_key    = ""
    @track = Hash.new
    @element_name = ""
    @property_row
    @node_separator = "\n       "
    @track_separator = "\n    "
  end

  #standard callback
  def characters str
    if is_top_level_key
      @top_level_key = str.clone.downcase!
      @property_row[:key] = str
    elsif is_track_value
      @property_row[:value] = str
    elsif is_track_key
      @property_row[:key] = str
    elsif is_playlist_items_value
      @playlist[:items].push( { :key => "Track ID", :type => "integer", :value => str } )
    elsif is_playlist_value
      @property_row[:value] = str
    elsif is_playlist_key
      @property_row[:key] = str
    elsif is_top_level_value
      @property_row[:value] = str
    elsif is_track_start
      @track[:key] = str
      @track[:dict] = Array.new
    end
    if ( "key" == @element_name ) &&
      ( 5 == depth )
      @last_key = str.clone.downcase!
    end
  end

  #standard callback
  def start_element element_name, attributes = []
    breadcrumb_add( element_name )
    @element_name = element_name

    if is_track_start
      @track = Hash.new
      @track_count += 1
    elsif is_track_key
      @property_row = Hash.new
    elsif is_track_value
      @property_row[:type] = @element_name
    elsif is_playlist_items_key
    elsif is_playlist_key
      @property_row = Hash.new
    elsif is_playlist_value
      @property_row[:type] = @element_name
    elsif is_playlist_start
      @playlist[:dict] = Array.new
    elsif is_top_level_value
      @property_row[:type] = @element_name
    elsif is_tracks_collection_start
      @property_row = nil
      @library_callbacks.tracks_collection_start
    elsif is_playlists_collection_start
      @property_row = nil
      @library_callbacks.playlists_collection_start
    elsif is_top_level_key
      @is_tracks    = false
      @is_playlists = false
      @property_row = Hash.new
    elsif is_top_level
      @library_callbacks.top_level_start
    elsif element_name == "plist"
      @library_callbacks.library_start
    end
  end

  #standard callback
  def end_element element_name
    if is_track_end
      @library_callbacks.track_end @track
    elsif is_track_key
      @track[:dict].push( @property_row )
    elsif is_playlist_items_start
      @playlist[:items] = Array.new
    elsif is_playlist_key
      @playlist[:dict].push( @property_row )
    elsif is_playlist_end
      @library_callbacks.playlist_end @playlist
    elsif is_top_level_value
      unless [ "tracks", "playlists" ].any? { |tlk|
          @top_level_key == tlk
        }
        @library_callbacks.top_level_row @property_row
      end
    elsif is_top_level_key
    elsif is_tracks_collection_end
     @library_callbacks.tracks_collection_end
    elsif is_playlists_collection_end
     @library_callbacks.playlists_collection_end
    elsif is_top_level
      @library_callbacks.top_level_end
    elsif element_name == "plist"
      @library_callbacks.library_end
    end
    breadcrumb_remove
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  def breadcrumb_add element_name
    @breadcrumb = @breadcrumb + @separator + element_name
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  def breadcrumb_remove
    temp = @breadcrumb.split( @separator )
    temp.pop()
    @element_name = temp[-1]
    @breadcrumb = temp.join( @separator )
  end

  #matches the very first dict after plist
  def is_top_level
    return "/plist/dict" == @breadcrumb
  end

  #the key a top level plist property
  def is_top_level_key
    return [
      '/plist/dict/key'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #the value a top level plist property
  def is_top_level_value
    return [
      '/plist/dict/integer',
      '/plist/dict/string',
      '/plist/dict/true',
      '/plist/dict/false',
      '/plist/dict/date'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #main container for tracks
  def is_tracks_collection_start
    return ( 'tracks' == @top_level_key ) &&
      ( "/plist/dict/dict" == @breadcrumb )
  end

  #main container for tracks
  def is_tracks_collection_end
    return ( is_tracks_collection_start ) &&
      ( "dict" == @element_name )
  end

  #the start of a track
  def is_track_start
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/key" == @breadcrumb
  end

  #the key for one of the tracks' attributes
  def is_track_key
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/dict/key" == @breadcrumb
  end

  #the value for one of the tracks' attributes
  def is_track_value
    return ( 'tracks' == @top_level_key ) && [
      '/plist/dict/dict/dict/integer',
      '/plist/dict/dict/dict/string',
      '/plist/dict/dict/dict/true',
      '/plist/dict/dict/dict/false',
      '/plist/dict/dict/dict/date'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #the key for one of the tracks' attributes
  def is_playlist_key
    return ( 'playlists' == @top_level_key ) &&
      "/plist/dict/array/dict/key" == @breadcrumb
  end

  #the value for one of the tracks' attributes
  def is_playlist_value
    return ( 'playlists' == @top_level_key ) && [
      '/plist/dict/array/dict/integer',
      '/plist/dict/array/dict/string',
      '/plist/dict/array/dict/true',
      '/plist/dict/array/dict/false',
      '/plist/dict/array/dict/date',
      '/plist/dict/array/dict/data'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #a single track with all its attributes
  def is_track_end
    return ( 'tracks' == @top_level_key ) &&
      "/plist/dict/dict/dict" == @breadcrumb
  end

  #main container for playlists
  def is_playlists_collection_start
    return ( 'playlists' == @top_level_key ) &&
      ( "/plist/dict/array" == @breadcrumb )
  end

  #main container for playlists
  def is_playlists_collection_end
    return ( is_playlists_collection_start ) &&
      ( "array" == @element_name )
  end

  #the start of a playlist
  def is_playlist_start
    return ( 'playlists' == @top_level_key ) &&
      "/plist/dict/array/dict" == @breadcrumb
  end

  #the end of a playlist
  def is_playlist_end
    return ( is_playlist_start ) &&
      "dict" == @element_name
  end

  #the start of a playlist
  def is_playlist_items_start
    return ( 'playlist items' == @last_key ) &&
      "/plist/dict/array/dict/key" == @breadcrumb
  end

  #non-important
  def is_playlist_items_key
    return ( 'playlist items' == @last_key ) && [
      '/plist/dict/array/dict/array/dict',
      '/plist/dict/array/dict/array/dict/key'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #non-important
  def is_playlist_items_value
    return ( 'playlist items' == @last_key ) && [
      '/plist/dict/array/dict/array/dict/integer'
      ].any? { |bc|
        @breadcrumb === bc
      }
  end

  #breadcrumbs are stores xpath style, i.e. /path/to/node
  #this methods counts the slashes to determine the dept
  def depth
    @breadcrumb.scan( "/" ).size
  end

  def error error_message
    abort "ERROR: #{error_message}"
  end
end[/ruby]

Because iTunes specific callbacks are now in another class, tests are much easier to write, if a bit tedious. The ITunesCallbacksTest creates an instance of the ITunesCallbacks class and passes it an ITunesLibraryWriter mock. The test check the mock receive all the expected events. The parsing is done manually by calling <tt>start_element</tt> and all the other SAX methods. I could have created a few mock files and passed them on instead, but this will do for now.

[ruby collapse="true"]require 'rubygems'
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
end[/ruby]

<tt>ITunesLibraryWriter</tt> is the new class that handles all the writing and the business logic. It's pretty simple, in the end it is just a pretty printer.

[ruby collapse="true"]# =ITunesLibraryWriter
# responds to event raised by ITunesLibraryCallbacks

class ITunesLibraryWriter
  attr_accessor

  #takes a filehandler as argument
  def initialize( *args )
    case args.size
    when 1
      @filehandle   = args[0]
    else
      raise ArgumentError, "This class takes 1 argument."
    end
    @node_separator = "\n       "
    @track_separator = "\n    "
  end

  #called by ITunesLibraryEvent
  #prints a complete playlist
  def playlist_end playlist
      playlist_print playlist
  end

  #called by ITunesLibraryEvent
  #prints a complete track
  def track_end track
      track_print track
  end

  #called by ITunesLibraryEvent
  #prints the opening plist tag
  def library_start
    @filehandle << '<plist version="1.0">'
  end

  #called by ITunesLibraryEvent
  #prints the opening plist tag
  def library_end
    @filehandle << "\n</plist>"
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag
  def top_level_start element_name="dict"
    @filehandle << "\n<#{element_name}>"
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag
  def top_level_end element_name="dict"
    @filehandle << "\n</#{element_name}>"
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag for tracks
  def tracks_collection_start
    @filehandle << "\n\t<key>Tracks</key>\n\t<dict>"
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag for tracks
  def playlists_collection_start
    @filehandle << "\n\t<key>Playlists</key>\n\t<array>"
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag for tracks
  def tracks_collection_end
    @filehandle << "\n\t</dict>"
  end

  #called by ITunesLibraryEvent
  #prints the closing dict tag for playlists
  def playlists_collection_end
    @filehandle << "\n\t</array>"
  end

  #called by ITunesLibraryEvent
  #prints the opening dict tag
  def top_level_row row
    track_row_print row, 1
  end

  #prints a complete playlist
  def playlist_print playlist
    @filehandle << @track_separator + "<dict>"
    playlist[:dict].each { |row|
      track_row_print row
    }
    if nil != playlist[:items]
      @filehandle << "\n\t\t\t<key>Playlist Items</key>\n\t\t\t<array>"
      playlist[:items].each { |row|
        playlist_item_row_print row
      }
      @filehandle << "\n\t\t\t</array>"
    end
    @filehandle << @track_separator + "</dict>"
  end

  #prints a complete track
  def track_print track
    @filehandle << @track_separator + "<key>#{track[:key]}</key>"
    @filehandle << @track_separator + "<dict>"
    track[:dict].each { |row|
      track_row_print row
    }
    @filehandle << @track_separator + "</dict>"
  end

  #prints the row generated by track_row_string
  def track_row_print row, tabs=3
    @filehandle << track_row_string( row, tabs )
  end

  #prints the row generated by track_row_string
  def playlist_item_row_print row, tabs=5
    @filehandle << "\n\t\t\t\t<dict>"
    @filehandle << track_row_string( row, tabs )
    @filehandle << "\n\t\t\t\t</dict>"
  end

  #takes an hash with { :key :value :type } and outputs
  #    <key>KEY</key><TYPE>VALUE</TYPE>
  def track_row_string row, tabs=3
    k = row[:key]
    v = row[:value]
    t = row[:type]
    return "\n" + ( "\t"*tabs ) + "<key>#{k}</key><#{t}>#{v}</#{t}>"
  end
end[/ruby]

The unit tests are also relatively simple

[ruby collapse="true"]require 'rubygems'
require 'flexmock/test_unit'
require 'ITunesLibraryWriter'
require 'test/unit'

class ITunesLibraryWriterTest < Test::Unit::TestCase

  def setup
    @filehandle = flexmock( "filehandle" )
  end

  def test_library_start
    @filehandle.should_receive( "<<" ).with( '<plist version="1.0">' )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.library_start
  end

  def test_library_end
    @filehandle.should_receive( "<<" ).with( "\n</plist>")
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.library_end
  end

  def test_playlist_end
    playlist = {:dict=>[
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"integer", :value=>2, :key=>"Eyes"}
      ]}
    @filehandle.should_receive( "<<" ).with( "\n    <dict>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>John</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Eyes</key><integer>2</integer>" )
    @filehandle.should_receive( "<<" ).with( "\n    </dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlist_end playlist
  end

  def test_track_end
    track = { :dict => [
        {:type=>"integer", :value=>2, :key=>"Track ID"},
        {:type=>"string", :value=>"John", :key=>"Name"},
        {:type=>"string", :value=>"Ski", :key=>"Artist"},
        {:type=>"string", :value=>"Jazzanova: The Remixes, 1997-2000", :key=>"Album"}
      ],
      :key => 2
    }
    @filehandle.should_receive( "<<" ).with( "\n    <key>2</key>" )
    @filehandle.should_receive( "<<" ).with( "\n    <dict>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Track ID</key><integer>2</integer>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>John</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Artist</key><string>Ski</string>" )
    @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Album</key><string>Jazzanova: The Remixes, 1997-2000</string>" )
    @filehandle.should_receive( "<<" ).with( "\n    </dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.track_end track
  end

  def test_top_level_start
    @filehandle.should_receive( "<<" ).with( "\n<dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_start
  end

  def test_top_level_end
    @filehandle.should_receive( "<<" ).with( "\n</dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_end
  end

  def test_tracks_collection_start
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Tracks</key>\n\t<dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.tracks_collection_start
  end

  def test_tracks_collection_end
    @filehandle.should_receive( "<<" ).with( "\n\t</dict>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.tracks_collection_end
  end

  def test_playlists_collection_start
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Playlists</key>\n\t<array>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlists_collection_start
  end

  def test_playlists_collection_end
    @filehandle.should_receive( "<<" ).with( "\n\t</array>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.playlists_collection_end
  end

  def test_top_level_row
    row = {:type=>"string", :value=>"10.6.3", :key=>"Application Version"}
    @filehandle.should_receive( "<<" ).with( "\n\t<key>Application Version</key><string>10.6.3</string>" )
    @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
    @iTLWInstance.top_level_row row
  end

end[/ruby]

<h3>Creating a playlist of missing iTunes tracks</h3>
<pre style="margin:1em 0;-webkit-border-radius:20px;-moz-border-radius:20px;border-radius:20px;background:#ccc;border:1px solid #999;"><code class="scenario">Scenario: Creating a playlist of missing iTunes tracks
    Given that "itunes XML library" contains references to X files
    And only 8 of these are in "folder"
    When I run itunesfiddler with input "itunes XML library"
    And folder "folder"
    And command "keep_missing_only"
    Then it should create a Library file with the two missing files only
    And no playlists</code></pre>

To finish off, I wanted to create at least a useful utility, which is what the whole point of this challenge was (as well as learning Ruby).

I am always swapping hard disks around for backing up. Since my playlist is huge, sometimes iTunes gives up and tells me it couldn't copy all the files - but with no indication of what the missing files were. A utility that could compare the original iTunes library with the files in the new location, and create a playlist including only the files that weren't copied over would be quite useful.

This shouldn't be too hard too achieve. First of all the script needs to be able to read in the new parameters, so that it knows what it is expected to do and where to look for files. Then I will subclass <tt>ITunesLibraryWriter</tt> and overwrite the playlist writer method (to do nothing - I don't need playlists, only tracks), and the track writing method (to only write if the file wasn't found).

<h4>Changing the main shell script to take commands</h4>
<tt>itunesfiddler</tt> is changed so that it now accept command names. I also made --input optional - got bored of typing it...

[ruby]#reads command line args
options = {}
itunesfiddler = OptionParser.new do |opt|

  #help screen
  opt.banner = "Usage: itunesfiddler --input=FILE [OPTIONS] [COMMAND]"
  opt.separator  ""
  opt.separator  "Commands"
  opt.separator  "   keep_missing_only - only includes track not found in folder, and doesn't print out any playlists. Requires --folder option"
  opt.separator  "Options"

  #individual options
  opt.on("-i","--input SRC","input xml file, default iTunes Music Library.xml") do |src|
    options[:src] = src
  end

  opt.on("-o","--output [TARGET]","output xml file") do |target|
    options[:target] = target
  end

  opt.on("-f","--folder [FOLDER]","folder where files are, or should be, copied to") do |folder|
    options[:folder] = folder
  end

  opt.on("-h","--help","help") do
    puts itunesfiddler
  end

end

#collects args and quits if something wrong
itunesfiddler.parse!

unless options[:src]
  options[:src] = "iTunes Music Library.xml"
end

unless File.file? options[:src]
  puts itunesfiddler
  abort( "ERROR: missing --input file - tried #{options[:src]}" )
end

unless options[:target]
  options[:target] = options[:src].clone.insert( -5, " - new" )
end[/ruby]

A big switch statement associates an ITunesLibraryWriter (sub)class with a command. Not the most elegant approach, but it will do for now. The class I will be creating now is <tt>ITunesLibraryWriterKeepMissingOnly</tt>

[ruby firstline="46"]#collection of callbacks for SAX parser
require 'ITunesLibraryCallbacks'

#copies file over
open( options[:target], 'w' ) do |f|
  open( options[:src] ) { |r|

    #the top two lines are not easily dealt with by SAX, so done manually
    f << r.readline
    f << r.readline
  }

  #FIXME something more elegant is on its way
  #each command gets its own subclass of SAX::Document
  case ARGV[0]

  when "keep_missing_only"
    unless options[:folder]
      puts itunesfiddler
      abort( "ERROR: missing --folder" )
    end
    require "ITunesLibraryWriterKeepMissingOnly"
    $iTLCInstance = ITunesLibraryCallbacks.new( f, ITunesLibraryWriterKeepMissingOnly.new( f, options[:folder] ) )

  else
    $iTLCInstance = ITunesLibraryCallbacks.new( f )

  end
  parser = Nokogiri::XML::SAX::Parser.new( $iTLCInstance )
  parser.parse_file( options[:src] )
end

puts "done - #{$iTLCInstance.track_count} tracks, created:#{options[:target]}"
exit( 0 )[/ruby]

<h4>Setting up ITunesLibraryWriterKeepMissingOnly</h4>
Now that I got unit tests in place I can start using TDD for the rest. First task, ensure playlists are not written out - they only increase the file size needlessly.

First of all I created a blank <tt>ITunesLibraryWriterKeepMissingOnly</tt> file

[ruby]# =ITunesLibraryWriterKeepMissingOnly
# keeps only the files which are not found in @folder

require 'ITunesLibraryWriter'

class ITunesLibraryWriterKeepMissingOnly < ITunesLibraryWriter
end[/ruby]

Then I duplicated the <tt>ITunesLibraryWriterTest</tt> file and renamed the test class <tt>ITunesLibraryWriterKeepMissingOnlyTest</tt> - it should just run as it is, as none of the methods were overwritten. And it does.

I want to force the class to read in a new paramter - folder, so I added a test
[ruby]def setup
    @filehandle = flexmock( "filehandle" )
    @folder = "tracks/"
  end

  def test_instantiation
    assert_raise(ArgumentError) { @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle ) }
  end[/ruby]

To pass it, I amended the class as
[ruby]#takes a filehandler as argument
  def initialize( *args )
    case args.size
    when 2
      @filehandle = args[0]
      @folder     = args[1]
    else
      raise ArgumentError, "This class takes 2 argument."
    end
  end[/ruby]

Now that test passes, but all the others failed as they still only pass in one argument. I changed them all to two. I can now delete all the tests that are not relevant, and change the ones I want to overwrite.

<h4>Making ITunesLibraryWriterKeepMissingOnly not write out output</h4>
Playlists are written at the end of a playlist block, so the relevant event is playlist_end. Here's the test
[ruby]def test_playlist_end
  playlist = {:dict=>[
      {:type=>"string", :value=>"John", :key=>"Name"},
      {:type=>"integer", :value=>2, :key=>"Eyes"}
    ]}
  @filehandle.should_receive( "<<" ).never
  @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
  @iTLWInstance.playlist_end playlist
end[/ruby]

The code to pass it couldn't be easier - just do nothing
[ruby]def playlist_end playlist
end[/ruby]

<h4>Storing meta information</h4>
Tracks are also written at the end of the corresponding block. Each track's path is stored under the key <tt>Location</tt>, so in theory it should be easy to look up whether a file in that location actually exists in --folder. But before doing that, in each path I need to replace the folder the tracks were copied <i>from</i>, i.e. the original iTunes library folder, with the folder the paths are being copied <i>to</i>. But where do I get hold of the iTunes library folder path?

One of the top level keys in the iTunes XML plist is <tt>Music Folder</tt>, which is exactly what I need. But nowhere in my code is this information stored, it is just copied over. In fact, it would be a good idea to store <em>all</em> those top level properties in an object - there are only a handful. I will add a new method, <tt>meta</tt> to the parent <tt>ITunesLibraryWriter</tt> class

[ruby]def test_meta
  folder_key = "Music Folder"
  folder_value = "file://localhost/Volumes/HD1T/Music/"
  row = { :type=>"string", :value=>folder_value, :key=>folder_key }
  @filehandle.should_receive( "<<" )
  @iTLWInstance = ITunesLibraryWriter.new( @filehandle )
  @iTLWInstance.top_level_row row
  assert_equal( folder_value, @iTLWInstance.meta( folder_key ) )
end[/ruby]

And the implementation - @top_level is created in the initialize method
[ruby]#called by ITunesLibraryEvent
#prints the opening dict tag
def top_level_row row
  @top_level[row[:key]] = row[:value]
  track_row_print row, 1
end

#top level keys are saved in a global object. this method returns it
def meta the_key
  return @top_level[the_key]
end[/ruby]

<h4>Copying tracks only if the file doesn't exist in --folder</h4>
Now it should be possible to check those files. Two new test: one for files that are not there, and one for files that are.

[ruby]def test_track_exists
  folder_key = "Music Folder"
  folder_value = "file://localhost/Volumes/HD1T/Music/"
  row = { :type=>"string", :value=>folder_value, :key=>folder_key }
  track = { :dict => [
      {:type=>"integer", :value=>2, :key=>"Track ID"},
      {:type=>"string", :value=>"Tonton Du Bled", :key=>"Name"},
      {:type=>"string", :value=> folder_value + "113/Tonton%20Du%20Bled/Tonton%20Du%20Bled.mp3", :key=>"Location"},
    ],
    :key => 2
  }
  @filehandle.should_receive( "<<" ).with( "\n\t<key>Music Folder</key><string>file://localhost/Volumes/HD1T/Music/</string>" ).once
  @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
  @iTLWInstance.top_level_row row
  @iTLWInstance.track_end track
end

def test_track_doesnt_exist
  folder_key = "Music Folder"
  folder_value = "file://localhost/Volumes/HD1T/Music/"
  row = { :type=>"string", :value=>folder_value, :key=>folder_key }
  track = { :dict => [
      {:type=>"integer", :value=>3, :key=>"Track ID"},
      {:type=>"string", :value=>"Tonton Du Bled", :key=>"Name"},
      {:type=>"string", :value=> folder_value + "113/ThisDoesNotExist.mp3", :key=>"Location"},
    ],
    :key => 3
  }
  @filehandle.should_receive( "<<" ).with( "\n\t<key>Music Folder</key><string>file://localhost/Volumes/HD1T/Music/</string>" ).once
  @filehandle.should_receive( "<<" ).with( "\n    <key>3</key>" ).once
  @filehandle.should_receive( "<<" ).with( "\n    <dict>" ).once
  @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Track ID</key><integer>3</integer>" ).once
  @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Name</key><string>Tonton Du Bled</string>" ).once
  @filehandle.should_receive( "<<" ).with( "\n\t\t\t<key>Location</key><string>file://localhost/Volumes/HD1T/Music/113/ThisDoesNotExist.mp3</string>" ).once
  @filehandle.should_receive( "<<" ).with( "\n    </dict>" ).once
  @iTLWInstance = ITunesLibraryWriterKeepMissingOnly.new( @filehandle, @folder )
  @iTLWInstance.top_level_row row
  @iTLWInstance.track_end track
end[/ruby]

The code to pass them is fairly simple. I created a helper function to extract the file path from a track array of tuples, including URL-decoding them. Then all the track_end event handler has to do is to check that path, and only call the parent (super) method if the track wasn't found.
[ruby]#called by ITunesLibraryEvent
def track_end track
  unless File.file?( extract_pth( track[:dict], "Location" ) )
    super track
  end
end

def extract_pth the_array, the_key
  the_array.each { |tuple|
    if the_key == tuple[:key]
      str =  URI.unescape( tuple[:value] )
      return @folder + str[meta( "Music Folder" ).size .. str.size]
    end
  }
  return nil
end[/ruby]

It works a treat.

<h2>Challenge 100% complete</h2>
Farily happy with this - it was reasonably straightforward, it gets the job done, it allowed me to get to know Ruby, and I got the foundation for a flexible system. The code is far from perfect, it's just the bare minimum to pass the tests, but that's the point of TDD - I can go back and refactor it without fear of breaking everything.

The scripts are <a href="https://github.com/gotofritz/Weekly-Challenges/" title="[new window] code GitHub" target="_blank">available on GitHub</a>.