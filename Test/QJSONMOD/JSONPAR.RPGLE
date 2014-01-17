000100120130     /**
000200120130      * \brief JSON Parser
000300120130      *
000400120130      * A utility module for parsing JSON strings.
000500120130      *
000600120130      * <br><br>
000700120130      *
000800120130      * The parser string should be a valid JSON string or else and escape
000900120130      * message will be sent to the caller.
001000120130      *
001100120130      * <br><br>
001200120130      *
001300120130      * The parser also accepts the equal sign (=) as a separator for the key
001400120130      * and the value. The parser also supports the ; instead of the , for
001500120130      * separating pairs of values or values in an array. Strings may be
001600120130      * enclosed in single or double quotes. Arrays can either be enclosed in
001700120130      * curly braces () or in brackets []. Empty objects and arrays are supported.
001800120130      * Unicode representation of a character is supported like \u00CF.
001900120130      *
002000120130      * \author Mihael Schmidt
002100120130      * \date   2009-03-07
002200120130      *
002300120130      * \link http://www.json.org JSON.org
002400120130      *
002500120130      * \info The JSON syntax is not fully supported at the moment.
002600120130      *
002700120130      * \rev 09.04.2011 Mihael Schmidt
002800120130      *      Fixed parser error when newline characters follow a numeric value.
002900120130      *
003000120130      * \rev 23.07.2011 Matthias Aumüller
003100120130      *      Arrays only support (JSON array without JSON object)
003200120130      */
003300120130
003400120130      *-------------------------------------------------------------------------
003500120130      * Copyright (c) 2007-2011 Mihael Schmidt
003600120130      * All rights reserved.
003700120130      *
003800120130      * This file is part of the JSON service program.
003900120130      *
004000120130      * JSON service program is free software: you can redistribute it and/or modify it under
004100120130      * the terms of the GNU Lesser General Public License as published by
004200120130      * the Free Software Foundation, either version 3 of the License, or
004300120130      * any later version.
004400120130      *
004500120130      * JSON service program is distributed in the hope that it will be useful,
004600120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
004700120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
004800120130      * GNU Lesser General Public License for more details.
004900120130      *
005000120130      * You should have received a copy of the GNU Lesser General Public
005100120130      * License along with JSON service program.  If not, see http://www.gnu.org/licenses/.
005200120130      *-------------------------------------------------------------------------
005300120130
005400120130
005500120130     H nomain
005600120130     H bnddir('QC2LE')
005700120130     H copyright('Copyright (c) 2007-2011 Mihael Schmidt. All rights reserved.')
005800120130
005900120130
006000120130      *---------------------------------------------------------------
006100120130      * Constants
006200120130      *---------------------------------------------------------------
006300120130     D CR              C                   const(x'0d')
006400120130     D LF              C                   const(x'25')
006500120130     D NULL            C                   const(x'00')
006600120130     D TYPE_NO_VALUE   C                   const(-1)
006700120130      *
006800120130      /include qjsontxt,jsonconst
006900120130      /include qjsontxt,unicodcnst
007000120130
007100120130
007200120130      *---------------------------------------------------------------
007300120130      * Prototypes
007400120130      *---------------------------------------------------------------
007500120130     D nextValue       PR
007600120130     D   retValPtr                     *   const
007700120130     D   header                        *
007800120130     D   dataType                    10I 0
007900120130      *
008000120130     D nextCleanChar   PR             1A
008100120130     D   header                        *
008200120130      *
008300120130     D nextString      PR         10000A
008400120130     D   header                        *
008500120130     D   quote                        1A   const
008600120130      *
008700120130     D nextObject      PR              *
008800120130     D   header                        *
008900120130      *
009000120130     D nextArray       PR              *
009100120130     D   header                        *
009200120130      *
009300120130     D next            PR             1A
009400120130     D   header                        *
009500120130      *
009600120130     D back            PR
009700120130     D   header                        *
009800120130      *
009900120130     D more            PR              N
010000120130     D   header                        *
010100120130      *
010200120130     D abortParsing    PR
010300120130     D   header                        *
010400120130     D   message                   1000A   const
010500120130      *
010600120130     D strlen          PR            10I 0 extproc('strlen')
010700120130     D   buffer1                       *   value
010800120130      *
010900120130     D strcasecmp      PR            10I 0 extproc('strcasecmp')
011000120130     D   buffer1                       *   value
011100120130     D   buffer2                       *   value
011200120130      *
011300120130     D convertChar     PR                  extproc('cvtch')
011400120130     D   target1byte                   *   value
011500120130     D   source2byte                   *   value options(*string)
011600120130     D   sourceBytes                 10I 0 value
011700120130      *
011800120130      /include qjsontxt,json
011900120130
012000120130
012100120130      *---------------------------------------------------------------
012200120130      * Data structures
012300120130      *---------------------------------------------------------------
012400120130     D tmpl_parser_ds  DS                  qualified based(nullPointer)
012500120130     D   json_string_ptr...
012600120130     D                                 *
012700120130     D   index_pos                   10I 0
012800120130      *
012900120130     D tmpl_return_value_ds...
013000120130     D                 DS                  qualified based(nullPointer)
013100120130     D   text                     65535A
013200120130     D   boolean                       N   overlay(text : 1)
013300120130     D   integer                     10I 0 overlay(text : 1)
013400120130     D   long                        20I 0 overlay(text : 1)
013500120130     D   double                       8F   overlay(text : 1)
013600120130     D   pointer                       *   overlay(text : 1)
013700120130
013800120130
013900120130     /**
014000120130      * \brief Parse JSON string
014100120130      *
014200120130      * Creates a JSON object or array from the passed string. If the passed
014300120130      * string is not a valid JSON string an escape message will be
014400120130      * sent. The string must be null terminated.
014500120130      *
014600120130      * \param Pointer to JSON string
014700120130      * \param Pointer to parser header (only for internal use)
014800120130      *
014900120130      * \return Pointer to JSON object or array
015000120130      */
015100120130     P json_parse      B                   export
015200120130     D                 PI              *
015300120130     D  string                         *   const options(*omit)
015400120130     D  ptrHeader                      *   const options(*nopass)
015500120130      *
015600120130     D ptr             S               *
015700120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
015800120130     D data            S              1A
015900120130     D json            S               *
016000120130      /free
016100120130       if (%parms() = 2);
016200120130         // nested json object
016300120130         ptr = ptrHeader;
016400120130         data = UNICODE_LEFT_CURLY_BRACE;
016500120130       else;
016600120130         // first json object (top-level)
016700120130         ptr = %alloc(%size(tmpl_parser_ds));
016800120130
016900120130         // init header ds
017000120130         header.json_string_ptr = string;
017100120130         header.index_pos = -1;
017200120130
017300120130         data = nextCleanChar(ptr);
017400120130       endif;
017500120130
017600120130
017700120130       if (data = UNICODE_LEFT_CURLY_BRACE);
017800120130         json = nextObject(ptr);
017900120130
018000120130       elseif (data = UNICODE_LEFT_BRACKET or data = UNICODE_LEFT_BRACE);
018100120130         json = nextArray(ptr);
018200120130
018300120130       else;
018400120130         abortParsing(ptr : 'String is no JSON object or JSON array string');
018500120130       endif;
018600120130
018700120130       // deallocate memory
018800120130       if (%parms() = 1 and ptr <> *null);
018900120130         dealloc ptr;
019000120130       endif;
019100120130
019200120130       return json;
019300120130      /end-free
019400120130     P                 E
019500120130
019700120130     /**
019800120130      * \brief Next value
019900120130      *
020000120130      * Returns the next value. The parser is moved after the next value.
020100120130      * The returned value can be any supported JSON data type including array
020200120130      * and object.
020300120130      *
020400120130      * \param Pointer to the return value data structure
020500120130      * \param Pointer to the JSON string
020600120130      * \param JSON data type of the return value
020700120130      */
020800120130     P nextValue       B
020900120130     D                 PI
021000120130     D  retValPtr                      *   const
021100120130     D  ptr                            *
021200120130     D  dataType                     10I 0
021300120130      *
021400120130     D retValDs        DS                  likeds(tmpl_return_value_ds)
021500120130     D                                     based(retValPtr)
021600120130     D data            S              1A
021700120130     D backupData      S              1A
021800120130     D tmp             S          65535A
021900120130     D unquotedTextEnd...
022000120130     D                 S             13A
022100120130      *
022200120130     D STRING_TRUE     S              5A
022300120130     D STRING_FALSE    S              6A
022400120130     D STRING_NULL     S              5A
022500120130     D numbers         S             14A
022600120130      /free
022700120130       // ,:]}/\''"[{;=#
022800120130       unquotedTextEnd =u'002C003A005D007D002F005C00270022005B007B003B003D0023';
022900120130       // 0123456789.,+-
023000120130       numbers = u'0030003100320033003400350036003700380039002E002C002B002D';
023100120130
023200120130       STRING_TRUE = 'true' + NULL;
023300120130       STRING_FALSE = 'false' + NULL;
023400120130       STRING_NULL = 'null' + NULL;
023500120130
023600120130       data = nextCleanChar(ptr);
023700120130
023800120130       if (data = UNICODE_DOUBLE_QUOTE or data = UNICODE_APOSTROPHE);
023900120130         // string
024000120130         retValDs.text = nextString(ptr : data);
024100120130         dataType = JSON_TYPE_STRING;
024200120130         return;
024300120130
024400120130       elseif (data = UNICODE_LEFT_CURLY_BRACE);
024500120130         // json object
024600120130         retValDs.pointer = json_parse(*omit : ptr);
024700120130         dataType = JSON_TYPE_OBJECT;
024800120130         return;
024900120130
025000120130       elseif (data = UNICODE_LEFT_BRACKET or data = UNICODE_LEFT_BRACE);
025100120130         // json array
025200120130         retValDs.pointer = nextArray(ptr);
025300120130         dataType = JSON_TYPE_ARRAY;
025400120130         return;
025500120130
025600120130       elseif (data = UNICODE_RIGHT_BRACKET or data = UNICODE_RIGHT_BRACE);
025700120130         dataType = TYPE_NO_VALUE;
025800120130         return;
025900120130
026000120130       elseif (data = UNICODE_RIGHT_CURLY_BRACE);
026100120130         dataType = TYPE_NO_VALUE;
026200120130         return;
026300120130
026400120130       else;
026500120130         //
026600120130         // Handle unquoted text. This could be the values true, false, or
026700120130         // null, or it can be a number. An implementation (such as this one)
026800120130         // is allowed to also accept non-standard forms.
026900120130         //
027000120130         // Accumulate characters until we reach the end of the text or a
027100120130         // formatting character.
027200120130         //
027300120130         backupData = data;
027400120130         dow (%scan(data : unquotedTextEnd) = 0);
027500120130           tmp = %trimr(tmp) + data;
027600120130           data = next(ptr);
027700120130         enddo;
027800120130
027900120130         back(ptr);
028000120130
028100120130
028200120130         //
028300120130         // If it is true, false, or null, return the proper value.
028400120130         //
028500120130
028600120130         // remove CR and LF characters
028700120130         // add null for string compare
028800120130         tmp = %trimr(tmp : ' ' + x'0D' + x'25') + NULL;
028900120130
029000120130         if (strcasecmp(%addr(tmp) : %addr(STRING_TRUE)) = 0);
029100120130           dataType = JSON_TYPE_BOOLEAN;
029200120130           retValDs.boolean = *on;
029300120130           return;
029400120130         elseif (strcasecmp(%addr(tmp) : %addr(STRING_FALSE)) = 0);
029500120130           dataType = JSON_TYPE_BOOLEAN;
029600120130           retValDs.boolean = *off;
029700120130           return;
029800120130         elseif (strcasecmp(%addr(tmp) : %addr(STRING_NULL)) = 0);
029900120130           dataType = JSON_TYPE_NULL;
030000120130           return;
030100120130         endif;
030200120130
030300120130
030400120130         // remove null from tmp
030500120130         tmp = %str(%addr(tmp));
030600120130
030700120130
030800120130         //
030900120130         // It should be a number
031000120130         //
031100120130         if (%scan(backupData : numbers) > 0);
031200120130
031300120130           // determine if integer or double
031400120130           if (%scan('.' : tmp) > 0);
031500120130             // is double
031600120130             monitor;
031700120130               dataType = JSON_TYPE_DOUBLE;
031800120130               retValDs.double = %float(tmp);
031900120130               return;
032000120130               on-error *all;
032100120130                 // do nothing => value should be returned as string;
032200120130             endmon;
032300120130           else;
032400120130             monitor;
032500120130               dataType = JSON_TYPE_INT;
032600120130               retValDs.integer = %int(tmp);
032700120130               return;
032800120130
032900120130               on-error 0103;
033000120130
033100120130                 monitor;
033200120130                   dataType = JSON_TYPE_LONG;
033300120130                   retValDs.long = %int(tmp);
033400120130                   return;
033500120130                   on-error *all;
033600120130                     // do nothing => value should be returned as string
033700120130                     // because it ain't parsable as number
033800120130                 endmon;
033900120130
034000120130               on-error 0202;
034100120130                 // do nothing => value should be returned as string
034200120130             endmon;
034300120130           endif;
034400120130         endif;
034500120130
034600120130         //
034700120130         // Ain't a number => return value as string
034800120130         //
034900120130         dataType = JSON_TYPE_STRING;
035000120130         retValDs.text = tmp;
035100120130
035200120130       endif;
035300120130      /end-free
035400120130     P                 E
035500120130
035600120130
035700120130     /**
035800120130      * \brief Next clean character
035900120130      *
036000120130      * Moves the parser to the position on the next clean character and
036100120130      * returns it to the caller. Character like carriage return, linefeed and
036200120130      * blanks are ignored. On a null character an escape message will be sent.
036300120130      *
036400120130      * \param Pointer to the parser header structure
036500120130      *
036600120130      * \return next clean character
036700120130      */
036800120130     P nextCleanChar   B
036900120130     D                 PI             1A
037000120130     D  ptr                            *
037100120130      *
037200120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
037300120130     D data            S              1A
037400120130     D retVal          S              1A
037500120130     D keepLooping     S               N   inz(*on)
037600120130      /free
037700120130       dow (keepLooping);
037800120130         data = next(ptr);
037900120130
038000120130         if (data = *blank);
038100120130           // loop
038200120130         elseif (data = CR);
038300120130           // loop
038400120130         elseif (data = LF);
038500120130           // loop
038600120130         elseif (data = NULL);
038700120130           abortParsing(ptr : 'Unexpected ending of JSON string');
038800120130         else;
038900120130           keepLooping = *off;
039000120130         endif;
039100120130       enddo;
039200120130
039300120130       retVal = data;
039400120130
039500120130       return retVal;
039600120130      /end-free
039700120130     P                 E
039800120130
039900120130
040000120130     /**
040100120130      * \brief Next string
040200120130      *
040300120130      * Returns the next string from the current parser position on and moves
040400120130      * the parser to the position behind the returned string.
040500120130      *
040600120130      * \param Pointer to the parser header structure
040700120130      * \param Open quote character of the string (' or ")
040800120130      *
040900120130      * \return next JSON string
041000120130      */
041100120130     P nextString      B
041200120130     D                 PI         10000A
041300120130     D   ptr                           *
041400120130     D   quote                        1A   const
041500120130      *
041600120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
041700120130     D data            S              1A
041800120130     D keepLooping     S               N   inz(*on)
041900120130     D retVal          S          10000A   varying
042000120130     D unicode         S              1C
042100120130     D unicodeCharRep  S              4A
042200120130     D allowedChars    C                   'ABCDEFabcdef0123456789'
042300120130      /free
042400120130       dow (keepLooping);
042500120130         data = next(ptr);
042600120130
042700120130         if (data = CR);
042800120130           // throw esc message (unterminated end)
042900120130           abortParsing(ptr : 'Unterminated string (cr)');
043000120130         elseif (data = LF);
043100120130           // throw esc message (unterminated end)
043200120130           abortParsing(ptr : 'Unterminated string (linefeed)');
043300120130         elseif (data = NULL);
043400120130           // throw esc message (unterminated end)
043500120130           abortParsing(ptr : 'Unterminated string (null)');
043600120130         elseif (data = quote); // end of string
043700120130           keepLooping = *off;
043800120130         elseif (data = UNICODE_BACKSLASH);
043900120130
044000120130           // check if we have an escape sequence
044100120130           data = next(ptr);
044200120130           if (data = UNICODE_DOUBLE_QUOTE);
044300120130             retVal += %char(UNICODE_DOUBLE_QUOTE);
044400120130           elseif (data = UNICODE_BACKSLASH);
044500120130             retVal += %char(UNICODE_BACKSLASH);
044600120130           elseif (data = UNICODE_SLASH);
044700120130             retVal += %char(UNICODE_SLASH);
044800120130           elseif (data = 'b');
044900120130             retVal += x'16';    // backspace
045000120130           elseif (data = 'f');
045100120130             retVal += x'0c';    // form feed
045200120130           elseif (data = 'n');
045300120130             retVal += x'25';    // new line / line feed
045400120130           elseif (data = 'r');
045500120130             retVal += x'0d';    // carriage return
045600120130           elseif (data = 't');
045700120130             retVal += x'05';    // tab (horizontal)
045800120130           elseif (data = 'u');
045900120130
046000120130             // add the next 4 character to the unicode char representation
046100120130             unicodeCharRep = next(ptr) + next(ptr) + next(ptr) + next(ptr);
046200120130             if (%check(allowedChars : unicodeCharRep) > 0);
046300120130               abortParsing(ptr :'Incomplete unicode character representation');
046400120130             endif;
046500120130             convertChar(%addr(unicode) : %addr(unicodeCharRep) : 4);
046600120130             retVal += %char(unicode);
046700120130
046800120130           else;
046900120130             abortParsing(ptr : 'Invalid escape sequence \' + data);
047000120130           endif;
047100120130
047200120130         else;
047300120130           retVal += data;
047400120130         endif;
047500120130
047600120130       enddo;
047700120130
047800120130       return retVal;
047900120130      /end-free
048000120130     P                 E
048100120130
048200120130
048300120130     /**
048400120130      * \brief Next JSON array
048500120130      *
048600120130      * Returns the JSON array which is at the next position in the JSON
048700120130      * string. This procedure expects the position of the parser to be on
048800120130      * the opening bracket of the array ( [ ). If there is no JSON array
048900120130      * at the current position an escape message will be sent.
049000120130      *
049100120130      * <br><br>
049200120130      *
049300120130      * Empty arrays are also supported.
049400120130      *
049500120130      * \param Pointer to the parser header structure
049600120130      *
049700120130      * \return Pointer to JSON array
049800120130      */
049900120130     P nextArray       B
050000120130     D                 PI              *
050100120130     D   ptr                           *
050200120130      *
050300120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
050400120130     D array           S               *
050500120130     D retValDs        DS                  likeds(tmpl_return_value_ds)
050600120130     D dataType        S             10I 0
050700120130     D data            S              1A   inz
050800120130     D keepLooping     S               N   inz(*on)
050900120130      /free
051000120130       array = jsona_create();
051100120130
051200120130       dow (keepLooping);
051300120130
051400120130         // Values are separated by ','. We will also tolerate ';'.
051500120130         if (data = NULL);
051600120130           abortParsing(ptr : 'A JSON array text must end with "]"');
051700120130         elseif (data = UNICODE_RIGHT_BRACKET);
051800120130           // end of array
051900120130           leave;
052000120130         elseif (data = UNICODE_COMMA);
052100120130           // everything ok
052200120130         elseif (data = UNICODE_SEMICOLON);
052300120130           // everything ok
052400120130         endif;
052500120130
052600120130         // arrays consists of values only
052700120130         nextValue(%addr(retValDs) : ptr : dataType);
052800120130         if (dataType = JSON_TYPE_STRING);
052900120130           jsona_putString(array : %trimr(retValDs.text));
053000120130         elseif (dataType = JSON_TYPE_BOOLEAN);
053100120130           jsona_putBoolean(array : retValDs.boolean);
053200120130         elseif (dataType = JSON_TYPE_NULL);
053300120130           jsona_putNull(array);
053400120130         elseif (dataType = JSON_TYPE_INT);
053500120130           jsona_putInt(array : retValDs.integer);
053600120130         elseif (dataType = JSON_TYPE_LONG);
053700120130           jsona_putLong(array : retValDs.long);
053800120130         elseif (dataType = JSON_TYPE_DOUBLE);
053900120130           jsona_putDouble(array : retValDs.double);
054000120130         elseif (dataType = JSON_TYPE_OBJECT);
054100120130           jsona_putObject(array : retValDs.pointer);
054200120130         elseif (dataType = JSON_TYPE_ARRAY);
054300120130           jsona_putArray(array : retValDs.pointer);
054400120130         elseif (dataType = TYPE_NO_VALUE);
054500120130           leave;
054600120130         endif;
054700120130
054800120130         // get next char
054900120130         data = nextCleanChar(ptr);
055000120130
055100120130         // next iteration
055200120130
055300120130       enddo;
055400120130
055500120130       return array;
055600120130      /end-free
055700120130     P                 E
055800120130
055900120130
056000120130     /**
056100120130      * \brief Next character
056200120130      *
056300120130      * Returns the next character in the JSON string and moves the parser
056400120130      * forward by one position.
056500120130      *
056600120130      * \param Pointer to parser header structure
056700120130      *
056800120130      * \return next character or null if there are no more characters
056900120130      */
057000120130     P next            B
057100120130     D                 PI             1A
057200120130     D  ptrHead                        *
057300120130      *
057400120130     D header          DS                  likeds(tmpl_parser_ds) based(ptrHead)
057500120130     D ptr             S               *
057600120130     D data            S              1A   based(ptr)
057700120130     D retVal          S              1A
057800120130      /free
057900120130       if (more(ptrHead));
058000120130         ptr = header.json_string_ptr + header.index_pos + 1;
058100120130         retVal = data;
058200120130         header.index_pos += 1;
058300120130       else;
058400120130         retVal = NULL;
058500120130       endif;
058600120130
058700120130       return retVal;
058800120130      /end-free
058900120130     P                 E
059000120130
059100120130
059200120130     /**
059300120130      * \brief Move parser back
059400120130      *
059500120130      * Moves the position of the parser back by one position.
059600120130      *
059700120130      * \param Pointer to parser header structure
059800120130      */
059900120130     P back            B
060000120130     D                 PI
060100120130     D  ptr                            *
060200120130      *
060300120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
060400120130      /free
060500120130       header.index_pos -= 1;
060600120130      /end-free
060700120130     P                 E
060800120130
060900120130
061000120130     /**
061100120130      * \brief Checks for more characters in string
061200120130      *
061300120130      * Checks if there are still more characters to parse in the given string.
061400120130      *
061500120130      * \param Pointer to the rest of the JSON string to be parsed
061600120130      */
061700120130     P more            B
061800120130     D                 PI              N
061900120130     D  ptr                            *
062000120130      /free
062100120130       if (strlen(ptr) = 0);
062200120130         return *off;
062300120130       else;
062400120130         return *on;
062500120130       endif;
062600120130      /end-free
062700120130     P                 E
062800120130
062900120130
063000120130     /**
063100120130      * \brief Abort parsing
063200120130      *
063300120130      * The memory of the parser header is deallocated (freed) and an
063400120130      * escape message is sent to the previous call stack entry with the
063500120130      * passed message text.
063600120130      *
063700120130      * \param Pointer to parser header
063800120130      * \param Message text
063900120130      */
064000120130     P abortParsing    B
064100120130     D                 PI
064200120130     D   ptr                           *
064300120130     D   message                   1000A   const
064400120130      *
064500120130     D sendProgramMessage...
064600120130     D                 PR                  extpgm('QMHSNDPM')
064700120130     D  szMsgID                       7A   const
064800120130     D  szMsgFile                    20A   const
064900120130     D  szMsgData                  6000A   const  options(*varsize)
065000120130     D  nMsgDataLen                  10I 0 const
065100120130     D  szMsgType                    10A   const
065200120130     D  szCallStkEntry...
065300120130     D                               10A   const
065400120130     D  nRelativeCallStkEntry...
065500120130     D                               10I 0 const
065600120130     D  szRtnMsgKey                   4A
065700120130     D  error                       265A   options(*varsize)
065800120130      *
065900120130     D msgdata         S            512A
066000120130     D msgkey          S              4A
066100120130     D apiError        S            265A
066200120130      /free
066300120130       // dispose header
066400120130       dealloc(n) ptr;
066500120130
066600120130       // set message data
066700120130       msgdata = message;
066800120130
066900120130       // send escape message
067000120130       sendProgramMessage('CPF9898' :
067100120130                          'QCPFMSG   *LIBL     ' :
067200120130                          %trimr(msgdata) :
067300120130                          %len(%trimr(msgdata)) :
067400120130                          '*ESCAPE   ' :
067500120130                          '*' :
067600120130                          1 :
067700120130                          msgkey :
067800120130                          apiError);
067900120130      /end-free
068000120130     P                 E
068100120130
068200120130
068300120130     /**
068400120130      * \brief Next JSON object
068500120130      *
068600120130      * Returns the JSON object which is at the next position in the JSON
068700120130      * string. This procedure expects the position of the parser to be on
068800120130      * the opening bracket of the array ( { ).
068900120130      *
069000120130      * <br><br>
069100120130      *
069200120130      * Empty objects are supported.
069300120130      *
069400120130      * \param Pointer to the parser header structure
069500120130      *
069600120130      * \return Pointer to JSON object
069700120130      */
069800120130     P nextObject      B
069900120130     D                 PI              *
070000120130     D   ptr                           *
070100120130      *
070200120130     D json            S               *
070300120130     D key             S          10000A
070400120130      *
070500120130     D header          DS                  likeds(tmpl_parser_ds) based(ptr)
070600120130      *
070700120130     D retValDs        DS                  likeds(tmpl_return_value_ds)
070800120130     D dataType        S             10I 0
070900120130     D data            S              1A
071000120130     D keepLooping     S               N   inz(*on)
071100120130      /free
071200120130       json = json_create();
071300120130
071400120130       dow (keepLooping);
071500120130         data = nextCleanChar(ptr);
071600120130
071700120130         if (data = NULL);
071800120130           abortParsing(ptr : 'A JSON object text must end with ' +
071900120130                              %char(UNICODE_RIGHT_CURLY_BRACE));
072000120130         elseif (data = UNICODE_RIGHT_CURLY_BRACE);
072100120130           leave;
072200120130         else;
072300120130           // should be a key
072400120130           back(ptr);
072500120130           nextValue(%addr(retValDs) : ptr : dataType);
072600120130           if (dataType <> JSON_TYPE_STRING);
072700120130             abortParsing(ptr : 'Key is not of type string');
072800120130           endif;
072900120130           key = retValDs.text;
073000120130
073100120130           // The key is followed by ':'. We will also tolerate '='.
073200120130           data = nextCleanChar(ptr);
073300120130           if (data <> UNICODE_COLON and data <> UNICODE_EQUAL);
073400120130             abortParsing(ptr : 'Expected a colon after a key');
073500120130           endif;
073600120130
073700120130           // A value should be following
073800120130           nextValue(%addr(retValDs) : ptr : dataType);
073900120130           if (dataType = JSON_TYPE_STRING);
074000120130             json_putString(json : %trimr(key) : %trimr(retValDs.text));
074100120130           elseif (dataType = JSON_TYPE_BOOLEAN);
074200120130             json_putBoolean(json : %trimr(key) : retValDs.boolean);
074300120130           elseif (dataType = JSON_TYPE_NULL);
074400120130             json_putNull(json : %trimr(key));
074500120130           elseif (dataType = JSON_TYPE_INT);
074600120130             json_putInt(json : %trimr(key) : retValDs.integer);
074700120130           elseif (dataType = JSON_TYPE_LONG);
074800120130             json_putLong(json : %trimr(key) : retValDs.long);
074900120130           elseif (dataType = JSON_TYPE_DOUBLE);
075000120130             json_putDouble(json : %trimr(key) : retValDs.double);
075100120130           elseif (dataType = JSON_TYPE_OBJECT);
075200120130             json_putObject(json : %trimr(key) : retValDs.pointer);
075300120130           elseif (dataType = JSON_TYPE_ARRAY);
075400120130             json_putArray(json : %trimr(key) : retValDs.pointer);
075500120130           endif;
075600120130
075700120130           // Pairs are separated by ','. We will also tolerate ';'.
075800120130           data = nextCleanChar(ptr);
075900120130           if (data = UNICODE_COMMA);
076000120130             // everything ok
076100120130           elseif (data = UNICODE_SEMICOLON);
076200120130             // everything ok
076300120130           elseif (data = UNICODE_RIGHT_CURLY_BRACE); // end of object
076400120130             leave;
076500120130             abortParsing(ptr : 'Expected a comma or right curly brace ' +
076600120130                                'after value');
076700120130           endif;
076800120130
076900120130           // next iteration => next key/value pair
077000120130         endif;
077100120130
077200120130       enddo;
077300120130
077400120130       return json;
077500120130      /end-free
077600120130     P                 E
077700120130
