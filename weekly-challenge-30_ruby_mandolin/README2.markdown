    > cd /pth
    > bundle init
    Writing new Gemfile to /pth/Gemfile
    > subl Gemfile

Added the following to Gemfile

    source "https://rubygems.org"
    gem "nokogiri"

Then tried installing it

    > sudo bundle install
    > Password:
    /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/site_ruby/1.9.1/rubygems/dependency.rb:247:in `to_specs': Could not find bundler (>= 0) amongst [bigdecimal-1.1.0, io-console-0.3, json-1.5.4, minitest-2.5.1, rake-0.9.2.2, rdoc-3.9.4] (Gem::LoadError)
    from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/site_ruby/1.9.1/rubygems/dependency.rb:256:in `to_spec'
    from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/site_ruby/1.9.1/rubygems.rb:1231:in `gem'
    from /Users/ME/.rvm/gems/ruby-1.9.3-p194/bin/bundle:18:in `<main>'
    from /Users/ME/.rvm/gems/ruby-1.9.3-p194/bin/ruby_noexec_wrapper:14:in `eval'
    from /Users/ME/.rvm/gems/ruby-1.9.3-p194/bin/ruby_noexec_wrapper:14:in `<main>'

Assumed the problem was the lack of Bundler. But `gem install bundler` (which worked) didn't solve the problem.

Decided to install nokogiri directly.

    > sudo gem install nokogiri
    Building native extensions.  This could take a while...
    Building nokogiri using packaged libraries.
    ERROR:  Error installing nokogiri:
      ERROR: Failed to build gem native extension.

    /Users/ME/.rvm/rubies/ruby-1.9.3-p194/bin/ruby extconf.rb
    Building nokogiri using packaged libraries.
    checking for iconv.h... *** extconf.rb failed ***
    Could not create Makefile due to some reason, probably lack of
    necessary libraries and/or headers.  Check the mkmf.log file for more
    details.  You may need configuration options.

    Provided configuration options:
      --with-opt-dir
      --with-opt-include
      --without-opt-include=${opt-dir}/include
      --with-opt-lib
      --without-opt-lib=${opt-dir}/lib
      --with-make-prog
      --without-make-prog
      --srcdir=.
      --curdir
      --ruby=/Users/ME/.rvm/rubies/ruby-1.9.3-p194/bin/ruby
      --help
      --clean
      --use-system-libraries
      --enable-static
      --disable-static
      --with-zlib-dir
      --without-zlib-dir
      --with-zlib-include
      --without-zlib-include=${zlib-dir}/include
      --with-zlib-lib
      --without-zlib-lib=${zlib-dir}/lib
      --enable-cross-build
      --disable-cross-build
    /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:381:in `try_do': The compiler failed to generate an executable file. (RuntimeError)
    You have to install development tools first.
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:506:in `try_cpp'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:931:in `block in have_header'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:790:in `block in checking_for'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:284:in `block (2 levels) in postpone'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:254:in `open'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:284:in `block in postpone'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:254:in `open'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:280:in `postpone'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:789:in `checking_for'
      from /Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib/ruby/1.9.1/mkmf.rb:930:in `have_header'
      from extconf.rb:103:in `have_iconv?'
      from extconf.rb:148:in `block (2 levels) in iconv_prefix'
      from extconf.rb:90:in `preserving_globals'
      from extconf.rb:143:in `block in iconv_prefix'
      from extconf.rb:120:in `each_iconv_idir'
      from extconf.rb:137:in `iconv_prefix'
      from extconf.rb:428:in `block in <main>'
      from extconf.rb:161:in `block in process_recipe'
      from extconf.rb:154:in `tap'
      from extconf.rb:154:in `process_recipe'
      from extconf.rb:423:in `<main>'

    Gem files will remain installed in /Users/ME/.rvm/gems/ruby-1.9.3-p194/gems/nokogiri-1.6.3.1 for inspection.
    Results logged to /Users/ME/.rvm/gems/ruby-1.9.3-p194/gems/nokogiri-1.6.3.1/ext/nokogiri/gem_make.out

I went and checked mkmf.log file

    > cat ~/.rvm/gems/ruby-1.9.3-p194/gems/nokogiri-1.6.3.1/ext/nokogiri/mkmf.log
    "/usr/bin/gcc-4.2 -o conftest -I/Users/ME/.rvm/rubies/ruby-1.9.3-p194/include/ruby-1.9.1/x86_64-darwin10.8.0 -I/Users/ME/.rvm/rubies/ruby-1.9.3-p194/include/ruby-1.9.1/ruby/backward -I/Users/ME/.rvm/rubies/ruby-1.9.3-p194/include/ruby-1.9.1 -I. -I/usr/include -I/Users/ME/.rvm/usr/include -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE    -O3 -ggdb -Wextra -Wno-unused-parameter -Wno-parentheses -Wno-long-long -Wno-missing-field-initializers -Wpointer-arith -Wwrite-strings -Wdeclaration-after-statement -Wshorten-64-to-32 -Wimplicit-function-declaration  -fno-common -pipe  -O3 -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline conftest.c  -L. -L/Users/ME/.rvm/rubies/ruby-1.9.3-p194/lib -L/usr/lib -L/Users/ME/.rvm/usr/lib -L.      -lruby.1.9.1  -lpthread -ldl -lobjc  "
    checked program was:
    /* begin */
    1: #include "ruby.h"
    2:
    3: int main() {return 0;}
    /* end */

Totally useless. In the end I started doubting the integrity of my system.

    > ruby --version
    ruby 1.9.3p194 (2012-04-20 revision 35410)

But Maverick is supposed to be on 2.0 by default. So that's it. I must have installed it way back and then when I installed Maverick it left it as was - pointless, since it doesn't work.

    > rvm install ruby-2.0.0-p576
    ....

Worked. Then

    > bundle install
    Fetching gem metadata from https://rubygems.org/.........
    Resolving dependencies...
    Using mini_portile 0.6.0
    Using nokogiri 1.6.3.1
    Using bundler 1.7.3
    Your bundle is complete!
    Use `bundle show [gemname]` to see where a bundled gem is installed.

Worked as expected. Finally.
