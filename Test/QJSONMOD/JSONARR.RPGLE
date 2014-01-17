000100120130     /**
000200120130      * \brief JSON Array Implementation
000300120130      *
000400120130      * The value of a JSON object can be an array. This service program deals
000500120130      * with such arrays. Arrays themselves can also contain arrays. An array
000600120130      * can only contain values and arrays but no key/value pairs.
000700120130      *
000800120130      * <br><br>
000900120130      *
001000120130      * Throughout this service program is the index always 0-based. Which
001100120130      * means that the first entry has the index 0, the second entry has the
001200120130      * index 1 and so on.
001300120130      *
001400120130      * <br><br>
001500120130      *
001600120130      * If the index is out of the bounds of the array an escape message will
001700120130      * be send. If a procedure for the retrieval of a special type of value
001800120130      * is called on an entry of another type an escape message will be send
001900120130      * too.
002000120130      *
002100120130      * \author Mihael Schmidt
002200120130      * \date   19.04.2008
002300120130      *
002400120130      * \link http://www.json.org JSON
002500120130      * \link http://www.rpgnextgen.com RPG Next Gen
002600120130      *
002700120130      * \rev 07.03.2009 Mihael Schmidt
002800120130      *      Added <em>jsona_size</em> procedure.
002900120130      *
003000120130      * \rev 27.01.2010 Mihael Schmidt
003100120130      *      Added support for getting numbers with procedures jsona_getInt,
003200120130      *      jsona_getLong, jsona_getDouble no matter what the original type was
003300120130      *      (f. e. double value will be cast to int with jsona_getInt).
003400120130      *
003500120130      * \rev 09.04.2011 Mihael Schmidt
003600120130      *      Fixed memory management error in toString procedure.
003700120130      *
003800120130      * \rev 30.04.2011 Mihael Schmidt
003900120130      *      Switch from Linked List to ArrayList
004000120130      *
004100120130      * \rev 20.07.2011 Mihael Schmidt
004200120130      *      Remove leading plus (+) from floating point numbers when creating
004300120130      *      a string from a json array.
004400120130      *
004500120130      * \rev 23.07.2011 Mihael Schmidt
004600120130      *      Added jsona_isNull
004700120130      *
004800120130      * \rev 13.09.2011 Mihael Schmidt
004900120130      *      Bugfix: toString on empty array caused runtime error
005000120130      */
005100120130
005200120130      *-------------------------------------------------------------------------
005300120130      * Copyright (c) 2007-2011 Mihael Schmidt
005400120130      * All rights reserved.
005500120130      *
005600120130      * This file is part of the JSON service program.
005700120130      *
005800120130      * JSON service program is free software: you can redistribute it and/or modify it under
005900120130      * the terms of the GNU Lesser General Public License as published by
006000120130      * the Free Software Foundation, either version 3 of the License, or
006100120130      * any later version.
006200120130      *
006300120130      * JSON service program is distributed in the hope that it will be useful,
006400120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
006500120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
006600120130      * GNU Lesser General Public License for more details.
006700120130      *
006800120130      * You should have received a copy of the GNU Lesser General Public
006900120130      * License along with JSON service program.  If not, see http://www.gnu.org/licenses/.
007000120130      *-------------------------------------------------------------------------
007100120130
007200120130     H nomain
007300120130     H bnddir('QC2LE')
007400120130     H copyright('Copyright (c) 2007-2011 Mihael Schmidt. All rights reserved.')
007500120130
007600120130
007700120130      *-------------------------------------------------------------------------
007800120130      * Prototypes
007900120130      *-------------------------------------------------------------------------
008000120130     D jsona_srvpgm_init...
008100120130     D                 PR            10I 0 extproc('jsona_srvpgm_init')
008200120130      *
008300120130      /include qjsontxt,json
008400120130      /include qjsontxt,jsonint
008500120130      /include qjsontxt,ceeapi
008600120130      /include qjsontxt,libc
008700120130      /include qjsontxt,arraylist
008800120130
008900120130
009000120130      *-------------------------------------------------------------------------
009100120130      * Constants
009200120130      *-------------------------------------------------------------------------
009300120130      /include qjsontxt,jsonconst
009400120130      /include qjsontxt,unicodcnst
009500120130
009600120130
009700120130      *-------------------------------------------------------------------------
009800120130      * Global Variables
009900120130      *-------------------------------------------------------------------------
010000120130     D hex_null        S              1A   inz(x'00')
010100120130      *
010200120130      * Parameters passed to CEEDOD
010300120130      *
010400120130     D descType        S             10I 0
010500120130     D dataType        S             10I 0
010600120130     D descInfo1       S             10I 0
010700120130     D descInfo2       S             10I 0
010800120130     D length          S             10I 0
010900120130      *
011000120130     D chars           DS                  likeds(tmpl_chars)
011100120130     D chars_compact   DS                  likeds(tmpl_chars)
011200120130
011300120130
011400120130      *-------------------------------------------------------------------------
011500120130      * Procedures
011600120130      *-------------------------------------------------------------------------
011700120130
011800120130
011900120130     /**
012000120130      * \brief Service program initialization
012100120130      *
012200120130      * String formattings are preloaded.
012300120130      */
012400120130     P jsona_srvpgm_init...
012500120130     P                 B                   export
012600120130     D                 PI            10I 0
012700120130      /free
012800120130       chars.d_quote = %char(UNICODE_DOUBLE_QUOTE) + x'00';
012900120130       chars.l_brace = ' ' + %char(UNICODE_LEFT_CURLY_BRACE) + ' ' + x'00';
013000120130       chars.r_brace = ' ' + %char(UNICODE_RIGHT_CURLY_BRACE) + ' ' + x'00';
013100120130       chars.l_bracket = ' ' + %char(UNICODE_LEFT_BRACKET) + ' ' + x'00';
013200120130       chars.r_bracket = ' ' + %char(UNICODE_RIGHT_BRACKET) + ' ' + x'00';
013300120130       chars.comma = ' ' + %char(UNICODE_COMMA) + ' ' + x'00';
013400120130       chars.colon = ' ' + %char(UNICODE_COLON) + ' ' + x'00';
013500120130       chars.true = 'true' + x'00';
013600120130       chars.false = 'false' + x'00';
013700120130       chars.null_str = 'null' + x'00';
013800120130       chars.size_d_quote = 1;
013900120130       chars.size_l_brace = 3;
014000120130       chars.size_r_brace = 3;
014100120130       chars.size_l_bracket = 3;
014200120130       chars.size_r_bracket = 3;
014300120130       chars.size_comma = 3;
014400120130       chars.size_colon = 3;
014500120130       chars.size_true = 4;
014600120130       chars.size_false = 5;
014700120130       chars.size_null_str = 4;
014800120130
014900120130       chars_compact.d_quote = %char(UNICODE_DOUBLE_QUOTE) + x'00';
015000120130       chars_compact.l_brace = %char(UNICODE_LEFT_CURLY_BRACE) + x'00';
015100120130       chars_compact.r_brace = %char(UNICODE_RIGHT_CURLY_BRACE) + x'00';
015200120130       chars_compact.l_bracket = %char(UNICODE_LEFT_BRACKET) + x'00';
015300120130       chars_compact.r_bracket = %char(UNICODE_RIGHT_BRACKET) + x'00';
015400120130       chars_compact.comma = %char(UNICODE_COMMA) + x'00';
015500120130       chars_compact.colon = %char(UNICODE_COLON) + x'00';
015600120130       chars_compact.true = 'true' + x'00';
015700120130       chars_compact.false = 'false' + x'00';
015800120130       chars_compact.null_str = 'null' + x'00';
015900120130       chars_compact.size_d_quote = 1;
016000120130       chars_compact.size_l_brace = 1;
016100120130       chars_compact.size_r_brace = 1;
016200120130       chars_compact.size_l_bracket = 1;
016300120130       chars_compact.size_r_bracket = 1;
016400120130       chars_compact.size_comma = 1;
016500120130       chars_compact.size_colon = 1;
016600120130       chars_compact.size_true = 4;
016700120130       chars_compact.size_false = 5;
016800120130       chars_compact.size_null_str = 4;
016900120130
017000120130       return 0;
017100120130      /end-free
017200120130     P                 E
017300120130
017400120130
017500120130     /**
017600120130      * \brief Create JSON array
017700120130      *
017800120130      * Creates a json array "object". Currently a linked list is used
017900120130      * as a backend for the json array.
018000120130      *
018100120130      * \author Mihael Schmidt
018200120130      * \date   19.04.2008
018300120130      *
018400120130      * \return Pointer to the JSON array
018500120130      */
018600120130     P jsona_create    B                   export
018700120130     D                 PI              *
018800120130      /free
018900120130       return arraylist_create();
019000120130      /end-free
019100120130     P                 E
019200120130
019300120130     /**
019400120130      * \brief Dispose JSON array
019500120130      *
019600120130      * Disposes a JSON array and all values it contains.
019700120130      * All added arrays and objects are also disposed.
019800120130      *
019900120130      * \author Mihael Schmidt
020000120130      * \date   19.04.2008
020100120130      *
020200120130      * \param Pointer to the JSON array
020300120130      */
020400120130     P jsona_dispose   B                   export
020500120130     D                 PI
020600120130     D   array                         *
020700120130      /free
020800120130       if (array <> *null);
020900120130         jsona_clear(array);
021000120130
021100120130         arraylist_dispose(array);
021200120130         array = *null;
021300120130       endif;
021400120130      /end-free
021500120130     P                 E
021600120130
021700120130
021800120130     /**
021900120130      * \brief Remove an entry from the array
022000120130      *
022100120130      * \param Pointer to the JSON array
022200120130      * \param Index of the element to be removed (0-based)
022300120130      */
022400120130     P jsona_remove    B                   export
022500120130     D                 PI                  opdesc
022600120130     D   array                         *   const
022700120130     D   index                       10I 0 const
022800120130      *
022900120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
023000120130      /free
023100120130       ptr = arraylist_get(array : index);
023200120130       if (entry.type = JSON_TYPE_ARRAY);
023300120130         jsona_dispose(entry.array);
023400120130       elseif (entry.type = JSON_TYPE_OBJECT);
023500120130         json_dispose(entry.object);
023600120130       endif;
023700120130
023800120130       arraylist_remove(array : index);
023900120130      /end-free
024000120130     P                 E
024100120130
024200120130
024300120130     /**
024400120130      * \brief Clear array
024500120130      *
024600120130      * Removes all elements from the array.
024700120130      *
024800120130      * \param Pointer to the JSON array
024900120130      */
025000120130     P jsona_clear     B                   export
025100120130     D                 PI
025200120130     D   array                         *   const
025300120130      *
025400120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
025500120130     D size            S             10I 0
025600120130     D i               S             10I 0
025700120130      /free
025800120130       size = arraylist_getSize(array);
025900120130
026000120130       for i = size-1 downto 0;
026100120130         jsona_remove(array : i);
026200120130       endfor;
026300120130      /end-free
026400120130     P                 E
026500120130
026600120130     /**
026700120130      * \brief Add character entry
026800120130      *
026900120130      * Adds an entry of type character.
027000120130      *
027100120130      * \author Mihael Schmidt
027200120130      * \date   20.03.2008
027300120130      *
027400120130      * \param Pointer to the JSON array
027500120130      * \param Value
027600120130      * \param Index (default: last)
027700120130      */
027800120130     P jsona_putString...
027900120130     P                 B                   export
028000120130     D                 PI                  opdesc
028100120130     D   jsonArrPtr                    *   const
028200120130     D   value                    65535A   const options(*varsize)
028300120130     D   index                       10U 0 const options(*nopass)
028400120130      /free
028500120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
028600120130                         length : *omit);
028700120130       tmpl_array_entry.type = JSON_TYPE_STRING;
028800120130       tmpl_array_entry.string = %subst(value : 1 : length);
028900120130
029000120130       if (%parms() = 2);
029100120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : length + 4);
029200120130       else;
029300120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) :
029400120130                                    length + 4 : index);
029500120130       endif;
029600120130      /end-free
029700120130     P                 E
029800120130
029900120130
030000120130     /**
030100120130      * \brief Add boolean entry
030200120130      *
030300120130      * Adds an entry of type boolean.
030400120130      *
030500120130      * \author Mihael Schmidt
030600120130      * \date   20.03.2008
030700120130      *
030800120130      * \param Pointer to the JSON array
030900120130      * \param Value
031000120130      * \param Index (default: last)
031100120130      */
031200120130     P jsona_putBoolean...
031300120130     P                 B                   export
031400120130     D                 PI
031500120130     D   jsonArrPtr                    *   const
031600120130     D   value                         N   const
031700120130     D   index                       10U 0 const options(*nopass)
031800120130      /free
031900120130       tmpl_array_entry.type = JSON_TYPE_BOOLEAN;
032000120130       tmpl_array_entry.boolean = value;
032100120130
032200120130       if (%parms() = 2);
032300120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 5);
032400120130       else;
032500120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 5 : index);
032600120130       endif;
032700120130      /end-free
032800120130     P                 E
032900120130
033000120130
033100120130     /**
033200120130      * \brief Add integer entry
033300120130      *
033400120130      * Adds an entry of type integer.
033500120130      *
033600120130      * \author Mihael Schmidt
033700120130      * \date   20.03.2008
033800120130      *
033900120130      * \param Pointer to the JSON array
034000120130      * \param Value
034100120130      * \param Index (default: last)
034200120130      */
034300120130     P jsona_putInt...
034400120130     P                 B                   export
034500120130     D                 PI
034600120130     D   jsonArrPtr                    *   const
034700120130     D   value                       10I 0 const
034800120130     D   index                       10U 0 const options(*nopass)
034900120130      /free
035000120130       tmpl_array_entry.type = JSON_TYPE_INT;
035100120130       tmpl_array_entry.integer = value;
035200120130
035300120130       if (%parms() = 2);
035400120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 8);
035500120130       else;
035600120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 8 : index);
035700120130       endif;
035800120130      /end-free
035900120130     P                 E
036000120130
036100120130
036200120130     /**
036300120130      * \brief Add long entry
036400120130      *
036500120130      * Adds an entry of type long.
036600120130      *
036700120130      * \author Mihael Schmidt
036800120130      * \date   20.03.2008
036900120130      *
037000120130      * \param Pointer to the JSON array
037100120130      * \param Value
037200120130      * \param Index (default: last)
037300120130      */
037400120130     P jsona_putLong...
037500120130     P                 B                   export
037600120130     D                 PI
037700120130     D   jsonArrPtr                    *   const
037800120130     D   value                       20I 0 const
037900120130     D   index                       10U 0 const options(*nopass)
038000120130      /free
038100120130       tmpl_array_entry.type = JSON_TYPE_LONG;
038200120130       tmpl_array_entry.long = value;
038300120130
038400120130       if (%parms() = 2);
038500120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 12);
038600120130       else;
038700120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 12 : index);
038800120130       endif;
038900120130      /end-free
039000120130     P                 E
039100120130
039200120130
039300120130     /**
039400120130      * \brief Add double entry
039500120130      *
039600120130      * Adds an entry of type double.
039700120130      *
039800120130      * \author Mihael Schmidt
039900120130      * \date   20.03.2008
040000120130      *
040100120130      * \param Pointer to the JSON array
040200120130      * \param Value
040300120130      * \param Index (default: last)
040400120130      */
040500120130     P jsona_putDouble...
040600120130     P                 B                   export
040700120130     D                 PI
040800120130     D   jsonArrPtr                    *   const
040900120130     D   value                        8F   const
041000120130     D   index                       10U 0 const options(*nopass)
041100120130      /free
041200120130       tmpl_array_entry.type = JSON_TYPE_DOUBLE;
041300120130       tmpl_array_entry.double = value;
041400120130
041500120130       if (%parms() = 2);
041600120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 12);
041700120130       else;
041800120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 12 : index);
041900120130       endif;
042000120130      /end-free
042100120130     P                 E
042200120130
042300120130
042400120130     /**
042500120130      * \brief Add array entry
042600120130      *
042700120130      * Adds an entry of type array.
042800120130      *
042900120130      * \author Mihael Schmidt
043000120130      * \date   19.04.2008
043100120130      *
043200120130      * \param Pointer to the JSON array
043300120130      * \param Array
043400120130      * \param Index (default: last)
043500120130      */
043600120130     P jsona_putArray...
043700120130     P                 B                   export
043800120130     D                 PI
043900120130     D   jsonArrPtr                    *   const
044000120130     D   value                         *   const
044100120130     D   index                       10U 0 const options(*nopass)
044200120130      *
044300120130     D entry           DS                  likeds(tmpl_array_entry)
044400120130      /free
044500120130       entry.type = JSON_TYPE_ARRAY;
044600120130       entry.array = value;
044700120130
044800120130       if (%parms() = 2);
044900120130         arraylist_add(jsonArrPtr : %addr(entry) : 32);
045000120130       else;
045100120130         arraylist_add(jsonArrPtr : %addr(entry) : 32 : index);
045200120130       endif;
045300120130      /end-free
045400120130     P                 E
045500120130
045600120130
045700120130     /**
045800120130      * \brief Get string entry
045900120130      *
046000120130      * Returns a pointer to the value of the entry for the passed key.
046100120130      * The value is null terminated and can be processed with the %str BIF.
046200120130      *
046300120130      * <br><br>
046400120130      *
046500120130      * If the entry is not of type string an escape message will be send.
046600120130      *
046700120130      * \author Mihael Schmidt
046800120130      * \date   20.03.2008
046900120130      *
047000120130      * \param Pointer to the JSON array
047100120130      * \param Index
047200120130      *
047300120130      * \return Pointer to a null-terminated string
047400120130      */
047500120130     P jsona_getString...
047600120130     P                 B                   export
047700120130     D                 PI              *
047800120130     D   jsonArrPtr                    *   const
047900120130     D   index                       10U 0 const
048000120130      *
048100120130     D tmpPtr          S               *
048200120130     D tmpDs           DS                  likeds(tmpl_array_entry )
048300120130     D                                     based(tmpPtr)
048400120130      /free
048500120130       tmpPtr = arraylist_get(jsonArrPtr : index);
048600120130       if (tmpPtr <> *null);
048700120130         if (tmpDs.type = JSON_TYPE_STRING);
048800120130           return tmpPtr + 4;
048900120130         else;
049000120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
049100120130         endif;
049200120130       else;
049300120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
049400120130       endif;
049500120130
049600120130       return *null; // dummy => will never come to this point
049700120130      /end-free
049800120130     P                 E
049900120130
050000120130
050100120130     /**
050200120130      * \brief Get boolean entry
050300120130      *
050400120130      * Returns the boolean value of the entry.
050500120130      *
050600120130      * <br><br>
050700120130      *
050800120130      * If the entry is not of type boolean an escape message will be send.
050900120130      *
051000120130      * \author Mihael Schmidt
051100120130      * \date   20.03.2008
051200120130      *
051300120130      * \param Pointer to the JSON array
051400120130      * \param Index
051500120130      *
051600120130      * \return Boolean value of the entry
051700120130      */
051800120130     P jsona_getBoolean...
051900120130     P                 B                   export
052000120130     D                 PI              N
052100120130     D   jsonArrPtr                    *   const
052200120130     D   index                       10U 0 const
052300120130      *
052400120130     D tmpPtr          S               *
052500120130     D tmpDs           DS                  likeds(tmpl_array_entry )
052600120130     D                                     based(tmpPtr)
052700120130      /free
052800120130       tmpPtr = arraylist_get(jsonArrPtr : index);
052900120130       if (tmpPtr <> *null);
053000120130         if (tmpDs.type = JSON_TYPE_BOOLEAN);
053100120130           return tmpDs.boolean;
053200120130         else;
053300120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
053400120130         endif;
053500120130       else;
053600120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
053700120130       endif;
053800120130
053900120130       return *off; // dummy => will never come to this point
054000120130      /end-free
054100120130     P                 E
054200120130
054300120130
054400120130     /**
054500120130      * \brief Get integer entry
054600120130      *
054700120130      * Returns the integer value of the entry.
054800120130      *
054900120130      * <br><br>
055000120130      *
055100120130      * If the entry is not of type integer an escape message will be send.
055200120130      *
055300120130      * \author Mihael Schmidt
055400120130      * \date   20.03.2008
055500120130      *
055600120130      * \param Pointer to the JSON array
055700120130      * \param Index
055800120130      *
055900120130      * \return Integer value of the entry
056000120130      */
056100120130     P jsona_getInt...
056200120130     P                 B                   export
056300120130     D                 PI            10I 0
056400120130     D   jsonArrPtr                    *   const
056500120130     D   index                       10U 0 const
056600120130      *
056700120130     D tmpPtr          S               *
056800120130     D tmpDs           DS                  likeds(tmpl_array_entry )
056900120130     D                                     based(tmpPtr)
057000120130      /free
057100120130       tmpPtr = arraylist_get(jsonArrPtr : index);
057200120130       if (tmpPtr <> *null);
057300120130
057400120130         if (tmpDs.type = JSON_TYPE_INT);
057500120130           return tmpDs.integer;
057600120130         elseif (tmpDs.type = JSON_TYPE_LONG);
057700120130           monitor;
057800120130             return tmpDs.long;
057900120130             on-error *all;
058000120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
058100120130           endmon;
058200120130         elseif (tmpDs.type = JSON_TYPE_DOUBLE);
058300120130           monitor;
058400120130             return %int(tmpDs.double);
058500120130             on-error *all;
058600120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
058700120130           endmon;
058800120130         else;
058900120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
059000120130         endif;
059100120130
059200120130       else;
059300120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
059400120130       endif;
059500120130
059600120130       return -1; // dummy => will never come to this point
059700120130      /end-free
059800120130     P                 E
059900120130
060000120130
060100120130     /**
060200120130      * \brief Get long entry
060300120130      *
060400120130      * Returns the long value of the entry.
060500120130      *
060600120130      * <br><br>
060700120130      *
060800120130      * If the entry is not of type long an escape message will be send.
060900120130      *
061000120130      * \author Mihael Schmidt
061100120130      * \date   20.03.2008
061200120130      *
061300120130      * \param Pointer to the JSON array
061400120130      * \param Index
061500120130      *
061600120130      * \return Long value of the entry
061700120130      */
061800120130     P jsona_getLong...
061900120130     P                 B                   export
062000120130     D                 PI            20I 0
062100120130     D   jsonArrPtr                    *   const
062200120130     D   index                       10U 0 const
062300120130      *
062400120130     D tmpPtr          S               *
062500120130     D tmpDs           DS                  likeds(tmpl_array_entry )
062600120130     D                                     based(tmpPtr)
062700120130      /free
062800120130       tmpPtr = arraylist_get(jsonArrPtr : index);
062900120130       if (tmpPtr <> *null);
063000120130
063100120130         if (tmpDs.type = JSON_TYPE_LONG);
063200120130           return tmpDs.long;
063300120130         elseif (tmpDs.type = JSON_TYPE_INT);
063400120130           return tmpDs.integer;
063500120130         elseif (tmpDs.type = JSON_TYPE_DOUBLE);
063600120130           monitor;
063700120130             return %int(tmpDs.double);
063800120130             on-error *all;
063900120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
064000120130           endmon;
064100120130         else;
064200120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
064300120130         endif;
064400120130
064500120130       else;
064600120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
064700120130       endif;
064800120130
064900120130       return -1; // dummy => will never come to this point
065000120130      /end-free
065100120130     P                 E
065200120130
065300120130
065400120130     /**
065500120130      * \brief Get double entry
065600120130      *
065700120130      * Returns the double value of the entry.
065800120130      *
065900120130      * <br><br>
066000120130      *
066100120130      * If the entry is not of type double an escape message will be send.
066200120130      *
066300120130      * \author Mihael Schmidt
066400120130      * \date   20.03.2008
066500120130      *
066600120130      * \param Pointer to the JSON array
066700120130      * \param Index
066800120130      *
066900120130      * \return Double value of the entry
067000120130      */
067100120130     P jsona_getDouble...
067200120130     P                 B                   export
067300120130     D                 PI             8F
067400120130     D   jsonArrPtr                    *   const
067500120130     D   index                       10U 0 const
067600120130      *
067700120130     D tmpPtr          S               *
067800120130     D tmpDs           DS                  likeds(tmpl_array_entry )
067900120130     D                                     based(tmpPtr)
068000120130      /free
068100120130       tmpPtr = arraylist_get(jsonArrPtr : index);
068200120130       if (tmpPtr <> *null);
068300120130
068400120130         if (tmpDs.type = JSON_TYPE_DOUBLE);
068500120130           return tmpDs.double;
068600120130         elseif (tmpDs.type = JSON_TYPE_INT);
068700120130           return %float(tmpDs.integer);
068800120130         elseif (tmpDs.type = JSON_TYPE_LONG);
068900120130           monitor;
069000120130             return %float(tmpDs.long);
069100120130             on-error *all;
069200120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
069300120130           endmon;
069400120130         else;
069500120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
069600120130         endif;
069700120130
069800120130       else;
069900120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
070000120130       endif;
070100120130
070200120130       return -1.0; // dummy => will never come to this point
070300120130      /end-free
070400120130     P                 E
070500120130
070600120130
070700120130     /**
070800120130      * \brief Get array entry
070900120130      *
071000120130      * Returns the array value of the entry.
071100120130      *
071200120130      * <br><br>
071300120130      *
071400120130      * If the entry is not of type array an escape message will be send.
071500120130      *
071600120130      * \author Mihael Schmidt
071700120130      * \date   20.03.2008
071800120130      *
071900120130      * \param Pointer to the JSON array
072000120130      * \param Index
072100120130      *
072200120130      * \return Pointer to the JSON array
072300120130      */
072400120130     P jsona_getArray...
072500120130     P                 B                   export
072600120130     D                 PI              *
072700120130     D   array                         *   const
072800120130     D   index                       10U 0 const
072900120130      *
073000120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
073100120130      /free
073200120130       ptr = arraylist_get(array : index);
073300120130       if (ptr <> *null);
073400120130         if (entry.type = JSON_TYPE_ARRAY);
073500120130           return entry.array;
073600120130         else;
073700120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
073800120130         endif;
073900120130       else;
074000120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
074100120130       endif;
074200120130
074300120130       return *null; // dummy => will never come to this point
074400120130      /end-free
074500120130     P                 E
074600120130
074700120130
074800120130
074900120130     /**
075000120130      * \brief String representation of the JSON array in JSON syntax
075100120130      *
075200120130      * Creates a null terminated string representation of the JSON array in
075300120130      * JSON syntax.
075400120130      *
075500120130      * <br><br>
075600120130      *
075700120130      * For entries of type string double quotes and backslashes will be escaped
075800120130      * (" => \" and \ => \\).
075900120130      *
076000120130      * \author Mihael Schmidt
076100120130      * \date   20.03.2008
076200120130      *
076300120130      * \param Pointer to the JSON array
076400120130      *
076500120130      * \return Pointer to the JSON string for the passed array
076600120130      *
076700120130      * \info The allocated memory of the returned string must be deallocated
076800120130      *       by the caller.
076900120130      */
077000120130     P jsona_toString...
077100120130     P                 B                   export
077200120130     D                 PI              *
077300120130     D   jsonArrPtr                    *   const
077400120130     D   pOutputFormat...
077500120130     D                               10I 0 const options(*nopass)
077600120130     D   pPrettyPrintFormat...
077700120130     D                                     likeds(json_prettyPrintFormat)
077800120130     D                                     const options(*nopass)
077900120130     D   pIndentationLevel...
078000120130     D                               10I 0 options(*nopass)
078100120130      *
078200120130     D outputFormat...
078300120130     D                 S             10I 0
078400120130     D prettyPrintOption...
078500120130     D                 S               N   inz(*off)
078600120130     D prettyPrintFormat...
078700120130     D                 DS                  likeds(json_prettyPrintFormat) inz
078800120130     D indentationLevel...
078900120130     D                 S             10I 0 inz(0)
079000120130      *
079100120130     D l_chars         DS                  likeds(tmpl_chars) inz
079200120130      *
079300120130     D json_string_ptr...
079400120130     D                 S               *
079500120130     D json_string_length...
079600120130     D                 S             10I 0
079700120130     D tokenList       S               *
079800120130     D tmpString       S            310A
079900120130     D tmpLength       S             10I 0
080000120130     D entry           DS                  likeds(tmpl_array_entry)
080100120130     D                                     based(entryPtr)
080200120130     D ptr             S               *
080300120130     D x               S             10I 0
080400120130     D newline         S              2A   inz(x'0D25')
080500120130     D i               S             10I 0
080600120130     D size            S             10I 0
080700120130      /free
080800120130       if (%parms() >= 2);
080900120130         outputFormat = pOutputFormat;
081000120130       endif;
081100120130
081200120130       if (%parms() >= 3);
081300120130         prettyPrintFormat = pPrettyPrintFormat;
081400120130       endif;
081500120130
081600120130       if (%parms() = 4);
081700120130         indentationLevel = pIndentationLevel;
081800120130       endif;
081900120130
082000120130       exsr init;
082100120130
082200120130       if (outputFormat = JSON_OUTPUT_PRETTY_PRINT);
082300120130         prettyPrintOption = *on;
082400120130       endif;
082500120130
082600120130       // initialization
082700120130       //  - write start tag
082800120130       //  - init token list
082900120130       tokenList = arraylist_create();
083000120130
083100120130       if (prettyPrintOption and prettyPrintFormat.breakBeforeArrayBrace);
083200120130         arraylist_add(tokenList : %addr(newline) : %size(newline));
083300120130         prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
083400120130       endif;
083500120130
083600120130       arraylist_add(tokenList : %addr(l_chars.l_bracket) :
083700120130                     l_chars.size_l_bracket);
083800120130
083900120130       if (prettyPrintOption);
084000120130         prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
084100120130
084200120130         if (prettyPrintFormat.breakAfterArrayBrace);
084300120130           indentationLevel += 1;
084400120130           arraylist_add(tokenList : %addr(newline) : %size(newline));
084500120130         endif;
084600120130
084700120130       endif;
084800120130
084900120130
085000120130       // process entries
085100120130       size = %int(arraylist_getSize(jsonArrPtr)) - 1;
085200120130       for i = 0 to size;
085300120130         entryPtr = arraylist_get(jsonArrPtr : i);
085400120130
085500120130         if (prettyPrintOption);
085600120130           prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
085700120130         endif;
085800120130
085900120130         select;
086000120130           when (entry.type = JSON_TYPE_STRING);
086100120130             arraylist_add(tokenList : %addr(l_chars.d_quote) :
086200120130                           l_chars.size_d_quote);
086300120130             arraylist_add(tokenList : %addr(entry.string) :
086400120130                           strlen(%addr(entry.string)));
086500120130             escapeLastToken(tokenList);
086600120130             arraylist_add(tokenList : %addr(l_chars.d_quote) :
086700120130                           l_chars.size_d_quote);
086800120130
086900120130           when (entry.type = JSON_TYPE_INT);
087000120130             tmpString = %char(entry.integer);
087100120130             tmpLength = %len(%trimr(tmpString));
087200120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
087300120130
087400120130           when (entry.type = JSON_TYPE_LONG);
087500120130             tmpString = %char(entry.long);
087600120130             tmpLength = %len(%trimr(tmpString));
087700120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
087800120130
087900120130           when (entry.type = JSON_TYPE_DOUBLE);
088000120130             tmpString = %triml(%char(entry.double) : '+');
088100120130             tmpLength = %len(%trimr(tmpString));
088200120130             // JSON syntax expects a . as delimiter (and not ,)
088300120130             tmpString = %xlate(',' : '.' : tmpString);
088400120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
088500120130
088600120130           when (entry.type = JSON_TYPE_BOOLEAN);
088700120130             if (entry.boolean);
088800120130               arraylist_add(tokenList : %addr(l_chars.true):l_chars.size_true);
088900120130             else;
089000120130               arraylist_add(tokenList : %addr(l_chars.false) :
089100120130                             l_chars.size_false);
089200120130             endif;
089300120130
089400120130           when (entry.type = JSON_TYPE_ARRAY);
089500120130             ptr = jsona_toString(entry.array : outputFormat :
089600120130                                  prettyPrintFormat : indentationLevel);
089700120130             arraylist_add(tokenList : ptr : strlen(ptr));
089800120130             dealloc(n) ptr;
089900120130
090000120130           when (entry.type = JSON_TYPE_NULL);
090100120130             arraylist_add(tokenList : %addr(entry.string) : 4);
090200120130
090300120130           when (entry.type = JSON_TYPE_OBJECT);
090400120130             ptr = json_toString(entry.object : outputFormat :
090500120130                                 prettyPrintFormat : indentationLevel);
090600120130             arraylist_add(tokenList : ptr : strlen(ptr));
090700120130
090800120130         endsl;
090900120130
091000120130
091100120130         // add comma if it is not the last entry
091200120130         if (entryPtr <> arraylist_getLast(jsonArrPtr));
091300120130           arraylist_add(tokenList : %addr(l_chars.comma) : l_chars.size_comma);
091400120130
091500120130           if (prettyPrintOption and prettyPrintFormat.breakAfterElement);
091600120130             arraylist_add(tokenList : %addr(newline) : %size(newline));
091700120130           endif;
091800120130
091900120130         endif;
092000120130
092100120130       endfor;
092200120130
092300120130       if (prettyPrintOption);
092400120130         if (prettyPrintFormat.breakAfterArrayBrace);
092500120130           arraylist_add(tokenList : %addr(newline) : %size(newline));
092600120130           indentationLevel -= 1;
092700120130         endif;
092800120130         prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
092900120130       endif;
093000120130
093100120130       // write end tag
093200120130       arraylist_add(tokenList : %addr(l_chars.r_bracket) :
093300120130                     l_chars.size_r_bracket);
093400120130
093500120130       // calculate json string length
093600120130       size = %int(arraylist_getSize(tokenList)) - 1;
093700120130       for i = 0 to size;
093800120130         ptr = arraylist_get(tokenList : i);
093900120130         json_string_length += strlen(ptr);
094000120130       endfor;
094100120130       // +1 for hex Null
094200120130       json_string_length += 1;
094300120130
094400120130       // allocate memory for json string
094500120130       json_string_ptr = %alloc(json_string_length);
094600120130
094700120130       // build json string
094800120130       size = %int(arraylist_getSize(tokenList)) - 1;
094900120130       for i = 0 to size;
095000120130         ptr = arraylist_get(tokenList : i);
095100120130         tmpLength = strlen(ptr);
095200120130         memcpy(json_string_ptr + x : ptr : tmpLength);
095300120130         x += tmpLength;
095400120130       endfor;
095500120130
095600120130       // append hex null
095700120130       memcpy(json_string_ptr + x : %addr(hex_null) : 1);
095800120130
095900120130       // clean up
096000120130       if (tokenList <> *null);
096100120130         arraylist_dispose(tokenList);
096200120130       endif;
096300120130
096400120130       return json_string_ptr;
096500120130
096600120130       begsr init;
096700120130         if (outputFormat = JSON_OUTPUT_COMPACT);
096800120130           l_chars = chars_compact;
096900120130         else;
097000120130           l_chars = chars;
097100120130         endif;
097200120130       endsr;
097300120130      /end-free
097400120130     P                 E
097500120130
097600120130
097700120130     /**
097800120130      * \brief Add null value entry
097900120130      *
098000120130      * Adds an entry of type null to the array.
098100120130      *
098200120130      * \author Mihael Schmidt
098300120130      * \date   11.05.2008
098400120130      *
098500120130      * \param Pointer to the JSON array
098600120130      * \param Index (default: last)
098700120130      */
098800120130     P jsona_putNull   B                   export
098900120130     D                 PI
099000120130     D   jsonArrPtr                    *   const
099100120130     D   index                       10U 0 const options(*nopass)
099200120130      /free
099300120130       tmpl_array_entry.type = JSON_TYPE_NULL;
099400120130       tmpl_array_entry.string = 'null';
099500120130
099600120130       if (%parms() = 1);
099700120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 4 + 4);
099800120130       else;
099900120130         arraylist_add(jsonArrPtr : %addr(tmpl_array_entry ) : 4 + 4 : index);
100000120130       endif;
100100120130      /end-free
100200120130     P                 E
100300120130
100400120130
100500120130     /**
100600120130      * \brief Add JSON object entry
100700120130      *
100800120130      * Adds an entry of type object to the array.
100900120130      *
101000120130      * \author Mihael Schmidt
101100120130      * \date   11.05.2008
101200120130      *
101300120130      * \param Pointer to the JSON array
101400120130      * \param Pointer to the JSON object
101500120130      * \param Index (default: last)
101600120130      */
101700120130     P jsona_putObject...
101800120130     P                 B                   export
101900120130     D                 PI
102000120130     D   jsonArrPtr                    *   const
102100120130     D   objPtr                        *   const
102200120130     D   index                       10U 0 const options(*nopass)
102300120130      *
102400120130     D entry           DS                  likeds(tmpl_array_entry)
102500120130      /free
102600120130       entry.type = JSON_TYPE_OBJECT;
102700120130       entry.object = objPtr;
102800120130
102900120130       if (%parms() = 2);
103000120130         arraylist_add(jsonArrPtr : %addr(entry) : 32);
103100120130       else;
103200120130         arraylist_add(jsonArrPtr : %addr(entry) : 32 : index);
103300120130       endif;
103400120130      /end-free
103500120130     P                 E
103600120130
103700120130
103800120130     /**
103900120130      * \brief Get object entry
104000120130      *
104100120130      * Returns a pointer to the object.
104200120130      *
104300120130      * <br><br>
104400120130      *
104500120130      * If the entry is not of type object an escape message will be send.
104600120130      *
104700120130      * \author Mihael Schmidt
104800120130      * \date   11.05.2008
104900120130      *
105000120130      * \param Pointer to the JSON array
105100120130      * \param Index
105200120130      *
105300120130      * \return Pointer to the JSON object
105400120130      */
105500120130     P jsona_getObject...
105600120130     P                 B                   export
105700120130     D                 PI              *
105800120130     D   array                         *   const
105900120130     D   index                       10U 0 const
106000120130      *
106100120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
106200120130      /free
106300120130       ptr = arraylist_get(array : index);
106400120130       if (ptr <> *null);
106500120130         if (entry.type = JSON_TYPE_OBJECT);
106600120130           return entry.object;
106700120130         else;
106800120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
106900120130         endif;
107000120130       else;
107100120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
107200120130       endif;
107300120130
107400120130       return *null; // dummy => will never come to this point
107500120130      /end-free
107600120130     P                 E
107700120130
107800120130
107900120130     /**
108000120130      * \brief Get array size
108100120130      *
108200120130      * Returns the number of elements in the array.
108300120130      *
108400120130      * \param Pointer to the json array
108500120130      *
108600120130      * \return number of elements
108700120130      */
108800120130     P jsona_size      B                   export
108900120130     D                 PI            10U 0
109000120130     D   jsonArrPtr                    *   const
109100120130      /free
109200120130       return arraylist_getSize(jsonArrPtr);
109300120130      /end-free
109400120130     P                 E
109500120130
109600120130
109700120130     /**
109800120130      * \brief Get entry type
109900120130      *
110000120130      * Returns the type of the entry.
110100120130      *
110200120130      * \param Pointer to the JSON object
110300120130      * \param Key
110400120130      *
110500120130      * \return Entry type
110600120130      *
110700120130      * \throws CPF9898 Array element not found
110800120130      */
110900120130     P jsona_getEntryType...
111000120130     P                 B                   export
111100120130     D                 PI            10I 0
111200120130     D   array                         *   const
111300120130     D   index                       10U 0 const
111400120130      *
111500120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
111600120130      /free
111700120130       ptr = arraylist_get(array : index);
111800120130       if (ptr <> *null);
111900120130         return entry.type;
112000120130       else;
112100120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
112200120130         return 0; // dummy
112300120130       endif;
112400120130      /end-free
112500120130     P                 E
112600120130
112700120130
112800120130     /**
112900120130      * \brief Checks if entry is of special type null
113000120130      *
113100120130      * \param Pointer to the JSON object
113200120130      * \param Key
113300120130      *
113400120130      * \return *on = entry is of type null <br>
113500120130      *         *off = entry is of another type
113600120130      */
113700120130     P jsona_isNull...
113800120130     P                 B                   export
113900120130     D                 PI              N
114000120130     D   array                         *   const
114100120130     D   index                       10U 0 const
114200120130      *
114300120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
114400120130      /free
114500120130       ptr = arraylist_get(array : index);
114600120130       if (ptr <> *null);
114700120130         return (entry.type = JSON_TYPE_NULL);
114800120130       else;
114900120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
115000120130         return *off; // dummy
115100120130       endif;
115200120130      /end-free
115300120130     P                 E
115400120130
