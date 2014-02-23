/*jshint laxcomma: true*/
( function(){
  var MandolinHelper = ( function(){
    var fs =  require('fs')
      , debug = true
      , NO_PATH = "_"
      , MandolinHelper = function( options ){
      };


    /**
     *
     * OSX decomposes UTF-8 characters into two - for example ü becomes ¨+u
     * they are then encoded in itunes, so they become ü becomes %CC%88
     * I don't understand the rules, so for now it will have to be a hard
     * coded list
     * @param  {String} str
     * @return {String}
     */
    MandolinHelper.prototype.replaceOSXDecomposedChars =
      function replaceOSXDecomposedChars( str ){
        str = str
              .replace( /&#38;/g,   "&")
              .replace( /a%CC%88/g, "ä" )
              .replace( /o%CC%88/g, "ö" )
              .replace( /u%CC%88/g, "ü" )
              .replace( /A%CC%88/g, "Á" )
              .replace( /O%CC%88/g, "Ó" )
              .replace( /U%CC%88/g, "Ü" )
              .replace( /%C3%9F/g,  "ß" )
              .replace( /c%CC%A7/g, "ç" )
              .replace( /n%CC%83/g, "ñ" )
              .replace( /N%CC%83/g, "Ñ" )
              .replace( /a%CC%80/g, "à" )
              .replace( /e%CC%80/g, "è" )
              .replace( /i%CC%80/g, "ì" )
              .replace( /o%CC%80/g, "ò" )
              .replace( /u%CC%80/g, "ù" )
              .replace( /A%CC%80/g, "À" )
              .replace( /E%CC%80/g, "È" )
              .replace( /I%CC%80/g, "Ì" )
              .replace( /O%CC%80/g, "Ò" )
              .replace( /U%CC%80/g, "Ù" )
              .replace( /a%CC%81/g, "á" )
              .replace( /e%CC%81/g, "é" )
              .replace( /i%CC%81/g, "í" )
              .replace( /o%CC%81/g, "ó" )
              .replace( /u%CC%81/g, "ú" )
              .replace( /A%CC%81/g, "Á" )
              .replace( /E%CC%81/g, "É" )
              .replace( /I%CC%81/g, "Í" )
              .replace( /O%CC%81/g, "Ó" )
              .replace( /U%CC%81/g, "Ú" )
              .replace( /i%CC%82/g, "î" )
              .replace( /o%CC%82/g, "ô" )
              .replace( /O%CC%82/g, "Ô" )
              .replace( /e%CC%82/g, "ê" )
              .replace( /E%CC%82/g, "Ê" )
              .replace( /a%CC%83/g, "ã" )
              .replace( /A%CC%83/g, "Ã" )
              .replace( /i%CC%88/g, "ï" )
              .replace( /I%CC%88/g, "Ï" )
              .replace( /%C2%B0/g, "°" )
              .replace( /%E2%80%A6/g, "…" );

        return str;
      };

    /**
     * recursive, sync listing
     * @param  {String} pth_src directory to list
     * @return {MandolinHelper}
     */
    MandolinHelper.prototype.collectFiles =
      function collectFiles( pth_src ){

        var walk = function( pth, files ){
              files = files || [];
              var list = fs
                         .readdirSync( pth )
                , i, i2
                , stat
                , pth_file
                ;
              for( i = 0, i2 = list.length; i < i2; i += 1 ){

                pth_file = pth + "/" + list[i];
                stat = fs.lstatSync( pth_file );

                if( stat && stat.isFile() &&
                    ".ds_store" !== list[i].toLowerCase() ){
                  files.push( pth_file );

                } else if( stat && stat.isDirectory() ){
                  walk( pth_file, files );
                }

              }
              return files;
            }
          , file_list = walk( pth_src );
        return file_list;
    };


    /**
     * loads a file list from a file
     * @param  {String} pth_src
     * @return {Array}
     */
    MandolinHelper.prototype.fromFile =
      function fromFile( pth_src ){

        var that = this;

        return fs.readFileSync(pth_src)
                  .toString()
                  .split("\n")
                  .map( function ( el ) {

                    if( el ){
                       el = that.replaceOSXDecomposedChars( el );
                       el = unescape( el ).replace( /"/g, "\"" );
                    }

                    return el;
                  });
      };


    /**
     * filters a file list as per passed args. Only regexes supported
     * @param  {Array<Object>} file_list
     * @param  {Object}        args filtering criteria
     *                              (only regex: "regex") supported
     * @return {Array<Object>} filtered file_list
     */
    MandolinHelper.prototype.getFilesWhere =
      function getFilesWhere( file_list, args ){

        args = args || {};
        var re
          , key
          , found
          ;

        if( args.regex ){
          re    = new RegExp( args.regex );
          key   = args.field;
          found = file_list.filter( function( el, i ){
              return re.test( el[ key ] );
            });

        } else {
          found = file_list.slice( 0 );
        }

        return found;
    };


    /**
     * filters a file list as per passed args. Only regexes supported
     * @param  {Array<Object>} file_list
     * @param  {Object}        args filtering criteria
     *                              (only regex: "regex") supported
     * @return {Array<Object>} filtered file_list
     */
    MandolinHelper.prototype.removeFilesWhere =
      function removeFilesWhere( file_list, args ){

        args = args || {};
        var re
          , key
          , found = []
          , removeThese = []
          , i
          ;

        if( args.regex ){
          re    = new RegExp( args.regex );
          key   = args.field;
          found = file_list.filter( function( el, i ){
              var match = re.test( el[ key ] );
              if( match ){
                removeThese.push( i );
              }
              return match;
            });

          i = removeThese.length;
          while( i-- ){
            file_list.splice( removeThese[i], 1 );
          }

        } else {
          found = file_list.slice( 0 );
          file_list.length = 0;
        }

        return found
                .reduce( function( previous, current ){
                  return previous.concat( current );
                }, []);
    };


    /**
     * another filtering - this returns all files whose paths is below
     * a given path
     * @param  {Array<Object>} list  files
     * @param  {String} value the path
     * @return {Array<Object>}
     */
    MandolinHelper.prototype.groupBy =  function groupBy( list, value ){

        var valueLen = value.length + 1;

        return list
        .sort( function( a, b ){
            return a.path < b.path ? -1 : 1;
          })
        .reduce( function( new_list, current ){
            var currentObj
              , substr = current.path.substr( valueLen )
              , group  = substr.split( "/" )[0]
              , epic   = substr.split( "/" )[1] || NO_PATH
              ;

            if( 0 < new_list.length &&
                new_list[new_list.length-1].group === group ){

              currentObj = new_list.pop();
              currentObj.epics[epic] = current.files.slice(0);

            } else {
              currentObj = Object.create({});
              currentObj.path = current.path.substr( 0, valueLen ) +
                                group;
              currentObj.group = group;
              currentObj.epics = {};
              currentObj.epics[epic] = current.files.slice(0);

            }
            new_list.push( currentObj );

            return new_list;
        }, []);
    };


    /**
     * rotates array by random amount, so that item 1 becomes, say 5, 2
     * 6, etc
     * @param  {Array} list1
     * @return {Array}
     */
    MandolinHelper.prototype.randomShift =
    function randomShift( list1 ){
        var shift_by =  Math.floor( list1.length * Math.random() )
          , up_to = list1.length - shift_by
          , list_clone = list1.slice()
          ;

        return [].concat( list_clone.splice( shift_by, up_to ),
                                list_clone.splice( 0 ) );
    };


    /**
     * interweaves array, creating an array which is A1[0], A2[0], ...
     * A1[1], A2[1] ... etc
     * @return {Array}
     */
    MandolinHelper.prototype.transpose =
      function transpose(){

        var max_array = Array.prototype.reduce.call( arguments,
                          function( previous, current, i ){
                            var token = previous;
                            if( previous[0] < current.length ){
                              token = [ current.length, i ];
                            }
                            return token;
                          }, [0, -1])
          , the_max   = max_array[0]
          , which_max = max_array[1]
          , result    = [].slice.call( arguments, 0 )
          , diff      = 0
          ;

        result.forEach( function( el, a ){
          var factor = the_max / el.length
            , i, j2, j = 0, jdecimal = factor - 1
            ;

          for( i = el.length - 1; i >= 0; i -= 1 ){
            for( j2 = Math.round( jdecimal ); j < j2; j += 1 ){
              result[a].splice( i, 0, undefined );
            }
            jdecimal += factor - 1;
          }
        });

        return Object
                .keys( result[which_max] )
                .map( function( b ) {
                    return result.map(
                        function (c) {
                            return c[b];
                          });
                  })
                .filter( function( el ){
                  return !!el;
                })
                .reduce( function( previous, current ){
                  return previous.concat( current );
                }, [])
                .filter( function( el ){
                  return !!el;
                });
    };


    /**
     * creates a list suitable to be turned into a bash command
     * @param  {Array} file_list
     * @param  {String} pth_target
     * @return {Array}
     */
    MandolinHelper.prototype.prepareFinalList =
      function prepareFinalList( file_list, pth_target ){

        var final_list
          , counter = 0
          , pad     = 4
          ;

        final_list = file_list.map( function( el, i ){

            el = el || {};
            var file_new = ""
              ;

            try{
              file_new = ( "0000" + counter ).slice( -pad ) +
                         " " +
                         el.file.replace( /^\d+\s*/, "" );
             } catch( e ){
               return false;
             }

            counter += 1;

            return {
              src: el.path + "/" + el.file,
              target: pth_target + "/" + file_new
            };
          });

        return final_list;
    };


    /**
     * random shuffle
     * @param  {Array} file_list
     * @return {Array}
     */
    MandolinHelper.prototype.shuffle =
      function shuffle( file_list ){

        var iLast = file_list.length
          , temp
          , iRandom
          ;

        // While there are elements in the array
        while( iLast ) {
          iLast -= 1;
          iRandom = ~~( Math.random() * iLast );
          temp = file_list[iLast];
          file_list[iLast] = file_list[iRandom];
          file_list[iRandom] = temp;
        }

        return file_list;
    };


    /**
     * format a list in Mandolin friendly way
     * @param  {Array} files
     * @return {Array}
     */
    MandolinHelper.prototype.asFileMoveList =
      function asFileMoveList( files ){

        var file_list = files.map( function( file ) {
          var path_elements = file.split( "/" )
            , basename = path_elements.pop()
            , dir = path_elements.join( "/" )
            ;

          return {
            file:   basename,
            path:   dir
          };
        });

        return file_list;
    };


    /**
     * files whose name start with 3 digits are assumed to be part of
     * a sequence (an "epic"). this functions filters the others out
     * @param  {Array<Object>} files
     * @return {Array<Object>}
     */
    MandolinHelper.prototype.getEpicsList =
      function getEpicsList( files ){

        return files
                .reduce( function( previous, current ){
                  var iLast = Math.max( previous.length-1, 0 );
                  if( previous[iLast] &&
                      previous[iLast].path === current.path ){
                    previous[iLast].files.push( current.file );

                  } else {
                    previous.push({
                      path:   current.path,
                      files: [ current.file ]
                    });
                  }
                  return previous;
                }, []);
    };


    /**
     * Ensures all the sequences of files are distrubuted evenly rather
     * than being one after the other
     * @param  {Array<Object>} files
     * @return {Array<Object>}
     */
    MandolinHelper.prototype.spreadGroup =
      function spreadGroup( files ){

        var length = files
                     .reduce( function( previous, current ){
                       return previous +
                              Object
                              .keys( current.epics )
                              .length;
                     }, 0 ),
            map = [],
            new_list = [],
            i;

        for( i=0; i<length; i += 1 ){
          map[i] = i;
        }

        files
        .sort( function( a, b ){
           return Object.keys( a.epics ).length >
                  Object.keys( b.epics ).length ?
                    -1:
                    1;
         })
        .forEach( function( el ){

          var lenToFit = Object.keys( el.epics ).length
            , factor = map.length / lenToFit
            , iMap = map.length - 1
            ;

          Object
          .keys( el.epics )
          .forEach( function( key ){
            var iList = map.splice( Math.round( iMap ), 1 )[0]
              , path = NO_PATH === key ?
                        el.path :
                        el.path + "/" + key
              ;
            new_list[iList] = { files: el.epics[key],
                                path: path };
            iMap -= factor;
          } );
         });

        return new_list;
    };


    /**
     * make sure a multidimensional array becomes a 1D one
     * @param  {Array<Object>} files
     * @return {Array<Object>}
     */
    MandolinHelper.prototype.flatten =
      function flatten( files ){

        return files
                .reduce( function( previous, current ){
                  if( current && "file" in current) {
                    previous.push( current );
                  } else if( current && "files" in current ) {
                    current.files.forEach( function( f ){
                      previous.push({
                        path: current.path,
                        file: f
                      });
                    });
                  }
                  return previous;
                }, []);
    };


    /**
     * for deubgging
     * @return MandolinHelper
     */
    MandolinHelper.prototype.logToFile =
      function logToFile( file_name, data ){

        if( !debug ){
          return MandolinHelper;
        }

        data = data || [];
        if( !data.splice ){
          data = [ data ];
        }
        var fn      = file_name + ".txt"
          , rowdata = []
          ;

        fs.writeFileSync( fn, "" );
        data.forEach( function( row ){
          var key_length = 0
            , tabs       = 0
            ;

          if( "[object Object]" === Object.prototype.toString.apply( row ) ){
            rowdata = [ "{" ];
            Object
              .keys( row )
              .sort( function( a, b ){
                return a.length > b.length? -1: 1;
              })
              .forEach( function( key, i ){
                if( 0 === i ){
                  key_length = key.length;
                  tabs = 0;
                } else {
                  tabs = key_length - key.length;
                }
                rowdata.push( key +
                              ": " +
                              "          ".substr( 0, tabs ) +
                              JSON.stringify( row[key] )
                              );
              });
            rowdata.push( "}" );
            fs.appendFileSync( fn, rowdata.join( "\n" ) );
          } else {
            fs.appendFileSync( fn, JSON.stringify( row ) + "\n" );

          }
        });

        return MandolinHelper;
      };

    /**
     * given an array of files and some paths, it creates a strings
     * full of bash instructions for copying these files from a dir
     * to another
     * @param  {Array} files      array of tuples
     *                            { src: /path, dest: /a/path }
     * @param  {String} pth_target dir name of files where music is
     * @param  {String} pth_src    dir name where to move files
     * @return {String}            the bash command with all the file
     *                             instructions
     */
    MandolinHelper.prototype.generateBash =
      function generateBash( bash_file, files, pth_target ){

        files      = files || [];
        pth_target = pth_target || "";

        var fn      = bash_file
          , bash_cmd = "[ -d \"" + pth_target + "\" ] && rm -r \"" +
                       pth_target + "\";\n mkdir -p \"" +
                       pth_target + "\"\n"
          ;

        fs.writeFileSync( fn, "" );

        if( pth_target ){
          bash_cmd = files
                     .reduce( function( previous, current, index){
                         return [ previous,
                                  "cp ",
                                  "\"" + current.src + "\" ",
                                  "\"" + current.target + "\"",
                                  "\n"
                                ].join( "" );
                       }, bash_cmd );
        }
        fs.appendFileSync( fn, bash_cmd );
        return bash_cmd;
    };

    return MandolinHelper;
  })();


  if( typeof module !== 'undefined' &&
      typeof module.exports !== 'undefined' ){
    module.exports = MandolinHelper;
  } else {
    window.MandolinHelper = MandolinHelper;
  }
})();