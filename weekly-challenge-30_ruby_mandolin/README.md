* cd here:
cd /Users/fritz/work/weekly-challenges/weekly-challenge-30_ruby_mandolin/
* Delete all old music if any
rm -rf  ~/Documents/CAPTAIN_MANDOLIN/MUSIC/*
* Export KIDS Must have to the Desktop
* Make sure you are using right version of ruby
rvm use ruby-2.0.0-p594
* Copy Must have to Computer
mkdir /Users/fritz/Documents/CAPTAIN_MANDOLIN/MUSIC/MUST_HAVE/; ./itunes_copy.rb -i /Users/fritz/Desktop/KIDS\ must\ have.xml -o /Users/fritz/Documents/CAPTAIN_MANDOLIN/MUSIC/MUST_HAVE/
* rename files so that they don't start with digits
Regex ^[\d- .]+
* set disk number of all tunes in KIDS Sould have to 100
* enompty playlist KIDS should have
* copy all tunes in playlist KIDS Next should have to KIDS Should have
* refresh list "KIDS Next 120"
* copy all tunes to KIDS Sould have
* Export KIDS NExt Should HAve to Desktop
mkdir /Users/fritz/Documents/CAPTAIN_MANDOLIN/MUSIC/SHOULD_HAVE/; ./itunes_copy.rb -i /Users/fritz/Desktop/KIDS\ should\ have.xml -o /Users/fritz/Documents/CAPTAIN_MANDOLIN/MUSIC/SHOULD_HAVE/
* check out if any tune is .m4a -> convert them to mp3
* Re-export and re-copy
* Empty all directories in the flashcard
rm -rf /Volumes/Lexar/MUSIC/*
rm -rf /Volumes/Lexar/STORIES/*
* Empty trash
* copy music to flashcard
concat -r -o /Volumes/Lexar/MUSIC/ /Users/fritz/Documents/CAPTAIN_MANDOLIN/MUSIC
* copy special libraries
mkdir /Volumes/Lexar/MUSIC/__DEXTER__; ./itunes_copy.rb -i /Users/fritz/Desktop/DEXTER.xml -o /Volumes/Lexar/MUSIC/__DEXTER__
mkdir /Volumes/Lexar/MUSIC/__FRIDA__; ./itunes_copy.rb -i /Users/fritz/Desktop/FRIDA.xml -o /Volumes/Lexar/MUSIC/__FRIDA__
* clean up flashcard
 find /Volumes/Lexar/  -name ".DS_*" -delete; find /Volumes/Lexar/  -name "._*" -delete;
