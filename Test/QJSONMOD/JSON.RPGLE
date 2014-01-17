000100120130     /**
000200120130      * \brief JSON Service program
000300120130      *
000400120130      * From the main web site:
000500120130      *
000600120130      * <p>
000700120130      * JSON (JavaScript Object Notation) is a lightweight data-interchange
000800120130      * format. It is easy for humans to read and write. It is easy for
000900120130      * machines to parse and generate. It is based on a subset of the
001000120130      * JavaScript Programming Language, Standard ECMA-262 3rd Edition -
001100120130      * December 1999. JSON is a text format that is completely language
001200120130      * independent but uses conventions that are familiar to programmers
001300120130      * of the C-family of languages, including C, C++, C#, Java, JavaScript,
001400120130      * Perl, Python, and many others. These properties make JSON an ideal
001500120130      * data-interchange language.
001600120130      * </p>
001700120130      *
001800120130      * JSON is built on two structures:
001900120130      *
002000120130      * <ul>
002100120130      *   <li>A collection of name/value pairs. In various languages, this is
002200120130      *       realized as an object, record, struct, dictionary, hash table,
002300120130      *       keyed list, or associative array.
002400120130      *   </li>
002500120130      *   <li>
002600120130      *       An ordered list of values. In most languages, this is realized as
002700120130      *       an array, vector, list, or sequence.
002800120130      *   </li>
002900120130      * </ul>
003000120130      *
003100120130      * <p>
003200120130      * These are universal data structures. Virtually all modern programming
003300120130      * languages support them in one form or another. It makes sense that a
003400120130      * data format that is interchangable with programming languages also be
003500120130      * based on these structures.
003600120130      * </p>
003700120130      *
003800120130      * In JSON, they take on these forms:
003900120130      *
004000120130      * <p>
004100120130      * An object is an unordered set of name/value pairs. An object begins
004200120130      * with { (left brace) and ends with } (right brace). Each name is followed
004300120130      * by : (colon) and the name/value pairs are separated by , (comma).
004400120130      * </p>
004500120130      *
004600120130      * Concerning this implementation:
004700120130      *
004800120130      * <br><br>
004900120130      *
005000120130      * The pointer to the JSON object will be check on every procedure call.
005100120130      * If the pointer does not point to a JSON object an escape message will
005200120130      * be send to the next level of the call stack.
005300120130      *
005400120130      * <br><br>
005500120130      *
005600120130      * If the JSON obect is queried for an entry of a specific type and the
005700120130      * type does not match with the expectation of the procedure an escape
005800120130      * message will be send to the next level of the call stack.
005900120130      *
006000120130      * <br><br>
006100120130      *
006200120130      * All the allocated memory of the JSON object and its entries is managed
006300120130      * by this service program and will be freed with the call of the
006400120130      * procedure <em>dispose</em>. No manual deallocation must be done.
006500120130      *
006600120130      * \author Mihael Schmidt
006700120130      * \date   20.03.2008
006800120130      *
006900120130      * \link http://www.json.org JSON
007000120130      *
007100120130      * \rev 27.01.2010 Mihael Schmidt
007200120130      *      Added support for getting numbers with procedures json_getInt,
007300120130      *      json_getLong, json_getDouble no matter what the original type was
007400120130      *      (f. e. double value will be cast to int with json_getInt).
007500120130      *
007600120130      * \rev 13.02.2011 Mihael Schmidt
007700120130      *      Fixed bug in remove procedure. Replaced string and hex constants
007800120130      *      with unicode constants.
007900120130      *
008000120130      * \rev 09.04.2011 Mihael Schmidt
008100120130      *      Fixed memory management error in toString procedure.
008200120130      *
008300120130      * \rev 24.06.2011 Brian Garland
008400120130      *      Remove leading plus (+) from floating point numbers when creating
008500120130      *      a string from a json object.
008600120130      *
008700120130      * \rev 23.10.2011 Mihael Schmidt
008800120130      *      Switched from Linked List to Arraylist and by that removing a
008900120130      *      dependency to Linked List <br>
009000120130      *      Fixed bug in escapeLastToken procedure
009100120130      *
009200120130      */
009300120130
009400120130      *-------------------------------------------------------------------------
009500120130      * Copyright (c) 2007-2011 Mihael Schmidt
009600120130      * All rights reserved.
009700120130      *
009800120130      * This file is part of the JSON service program.
009900120130      *
010000120130      * JSON service program is free software: you can redistribute it and/or modify it under
010100120130      * the terms of the GNU Lesser General Public License as published by
010200120130      * the Free Software Foundation, either version 3 of the License, or
010300120130      * any later version.
010400120130      *
010500120130      * JSON service program is distributed in the hope that it will be useful,
010600120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
010700120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
010800120130      * GNU Lesser General Public License for more details.
010900120130      *
011000120130      * You should have received a copy of the GNU Lesser General Public
011100120130      * License along with JSON service program.  If not, see http://www.gnu.org/licenses/.
011200120130      *-------------------------------------------------------------------------
011300120130
011400120130
011500120130     H nomain
011600120130     H bnddir('QC2LE')
011700120130     H copyright('Copyright (c) 2007-2010 Mihael Schmidt. All rights reserved.')
011800120130
011900120130      *-------------------------------------------------------------------------
012000120130      * Prototypes
012100120130      *-------------------------------------------------------------------------
012200120130     D json_srvpgm_init...
012300120130     D                 PR            10I 0 extproc('json_srvpgm_init')
012400120130      *
012500120130      /include qjsontxt,json
012600120130      /include qjsontxt,jsonint
012601120130      /include qjsontxt,ceeapi
012800120130      /include qjsontxt,libc
012900120130      /include qjsontxt,arraylist
013000120130
013100120130      /if not defined (QUSEC)
013200120130      /define QUSEC
013300120130      /copy qsysinc/qrpglesrc,qusec
013400120130      /endif
013500120130
013600120130
013700120130      *-------------------------------------------------------------------------
013800120130      * Constants
013900120130      *-------------------------------------------------------------------------
014000120130     D HEX_NULL        C                   x'00'
014100120130     D JSON_ID         C                   'JSON_IMPLEMENTATION'
014200120130
014300120130      /include qjsontxt,jsonconst
014400120130      /include qjsontxt,unicodcnst
014500120130
014600120130
014700120130      *-------------------------------------------------------------------------
014800120130      * Global Variables
014900120130      *-------------------------------------------------------------------------
015000120130      *
015100120130      * Parameters passed to CEEDOD
015200120130      *
015300120130     D descType        S             10I 0
015400120130     D dataType        S             10I 0
015500120130     D descInfo1       S             10I 0
015600120130     D descInfo2       S             10I 0
015700120130     D length          S             10I 0
015800120130      *
015900120130     D chars           DS                  likeds(tmpl_chars)
016000120130     D chars_compact   DS                  likeds(tmpl_chars)
016100120130      *
016200120130     D hexNull         S              1A   inz(HEX_NULL)
016300120130
016400120130
016500120130      *-------------------------------------------------------------------------
016600120130      * Procedures
016700120130      *-------------------------------------------------------------------------
016800120130
016900120130     /**
017000120130      * \brief Service program initialization
017100120130      *
017200120130      * String formattings are preloaded.
017300120130      */
017400120130     P json_srvpgm_init...
017500120130     P                 B                   export
017600120130     D                 PI            10I 0
017700120130      /free
017800120130       chars.d_quote = %char(UNICODE_DOUBLE_QUOTE) + x'00';
017900120130       chars.l_brace = ' ' + %char(UNICODE_LEFT_CURLY_BRACE) + ' ' + x'00';
018000120130       chars.r_brace = ' ' + %char(UNICODE_RIGHT_CURLY_BRACE) + ' ' + x'00';
018100120130       chars.l_bracket = ' ' + %char(UNICODE_LEFT_BRACKET) + ' ' + x'00';
018200120130       chars.r_bracket = ' ' + %char(UNICODE_RIGHT_BRACKET) + ' ' + x'00';
018300120130       chars.comma = ' ' + %char(UNICODE_COMMA) + ' ' + x'00';
018400120130       chars.colon = ' ' + %char(UNICODE_COLON) + ' ' + x'00';
018500120130       chars.true = 'true' + x'00';
018600120130       chars.false = 'false' + x'00';
018700120130       chars.null_str = 'null' + x'00';
018800120130       chars.size_d_quote = 1;
018900120130       chars.size_l_brace = 3;
019000120130       chars.size_r_brace = 3;
019100120130       chars.size_l_bracket = 3;
019200120130       chars.size_r_bracket = 3;
019300120130       chars.size_comma = 3;
019400120130       chars.size_colon = 3;
019500120130       chars.size_true = 4;
019600120130       chars.size_false = 5;
019700120130       chars.size_null_str = 4;
019800120130
019900120130       chars_compact.d_quote = %char(UNICODE_DOUBLE_QUOTE) + x'00';
020000120130       chars_compact.l_brace = %char(UNICODE_LEFT_CURLY_BRACE) + x'00';
020100120130       chars_compact.r_brace = %char(UNICODE_RIGHT_CURLY_BRACE) + x'00';
020200120130       chars_compact.l_bracket = %char(UNICODE_LEFT_BRACKET) + x'00';
020300120130       chars_compact.r_bracket = %char(UNICODE_RIGHT_BRACKET) + x'00';
020400120130       chars_compact.comma = %char(UNICODE_COMMA) + x'00';
020500120130       chars_compact.colon = %char(UNICODE_COLON) + x'00';
020600120130       chars_compact.true = 'true' + x'00';
020700120130       chars_compact.false = 'false' + x'00';
020800120130       chars_compact.null_str = 'null' + x'00';
020900120130       chars_compact.size_d_quote = 1;
021000120130       chars_compact.size_l_brace = 1;
021100120130       chars_compact.size_r_brace = 1;
021200120130       chars_compact.size_l_bracket = 1;
021300120130       chars_compact.size_r_bracket = 1;
021400120130       chars_compact.size_comma = 1;
021500120130       chars_compact.size_colon = 1;
021600120130       chars_compact.size_true = 4;
021700120130       chars_compact.size_false = 5;
021800120130       chars_compact.size_null_str = 4;
021900120130
022000120130       return 0;
022100120130      /end-free
022200120130     P                 E
022300120130
022400120130
022500120130     /**
022600120130      * \brief Create JSON Object
022700120130      *
022800120130      * Creates a JSON Object.
022900120130      *
023000120130      * <br><br>
023100120130      *
023200120130      * The memory allocated for this object must be deallocated with the
023300120130      * <em>dispose</em> procedure when finished.
023400120130      *
023500120130      * \author Mihael Schmidt
023600120130      * \date   20.03.2008
023700120130      *
023800120130      * \return Pointer to the JSON object
023900120130      */
024000120130     P json_create     B                   export
024100120130     D                 PI              *
024200120130      *
024300120130     D jsonPtr         S               *
024400120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
024500120130      /free
024600120130       jsonPtr = %alloc(%size(tmpl_header));
024700120130       header.id = JSON_ID;
024800120130       header.size = 0;
024900120130       header.firstEntry = *null;
025000120130       header.lastEntry = *null;
025100120130       header.iteration = -1;
025200120130       header.iterNextEntry = *null;
025300120130       header.iterPrevEntry = *null;
025400120130       header.disposeList = arraylist_create();
025500120130
025600120130       return jsonPtr;
025700120130      /end-free
025800120130     P                 E
025900120130
026000120130
026100120130     /**
026200120130      * \brief Deallocate JSON object
026300120130      *
026400120130      * The memory for the JSON Object will be deallocated and the passed
026500120130      * pointer will be set to *null.
026600120130      *
026700120130      * \author Mihael Schmidt
026800120130      * \date   20.03.2008
026900120130      *
027000120130      * \param Pointer to the JSON object
027100120130      */
027200120130     P json_dispose    B                   export
027300120130     D                 PI
027400120130     D   jsonPtr                       *
027500120130      *
027600120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
027700120130     D ptr             S               *
027800120130     D ptrDisposeElement...
027900120130     D                 S               *   based(ptr)
028000120130     D size            S             10I 0
028100120130     D i               S             10I 0
028200120130      /free
028300120130       if (jsonPtr <> *null);
028400120130         isJSONImpl(jsonPtr);
028500120130
028600120130         // deallocate all temporary allocated memory from the dispose list
028700120130         size = arraylist_getSize(header.disposeList);
028800120130         size -= 1;
028900120130         for i = 0 to size;
029000120130           // a user may have already freed the memory so ignore all errors
029100120130           ptr = arraylist_get(header.disposeList : i);
029200120130           monitor;
029300120130             if (ptrDisposeElement <> *null);
029400120130               dealloc ptrDisposeElement;
029500120130             endif;
029600120130             on-error *all;
029700120130           endmon;
029800120130
029900120130         endfor;
030000120130
030100120130         arraylist_dispose(header.disposeList);
030200120130
030300120130         json_clear(jsonPtr);
030400120130         dealloc(n) jsonPtr;
030500120130       endif;
030600120130      /end-free
030700120130     P                 E
030800120130
030900120130
031000120130     /**
031100120130      * \brief Remove entry
031200120130      *
031300120130      * If the JSON object contains such an entry it will be removed.
031400120130      *
031500120130      * \author Mihael Schmidt
031600120130      * \date   20.03.2008
031700120130      *
031800120130      * \param Pointer to the JSON object
031900120130      * \param Entry key
032000120130      *
032100120130      */
032200120130     P json_remove     B                   export
032300120130     D                 PI                  opdesc
032400120130     D   jsonPtr                       *   const
032500120130     D   key                      65535A   const options(*varsize)
032600120130      *
032700120130     D tmpKey          S          65535A
032800120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
032900120130     D ptr             S               *
033000120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
033100120130     D nextEntryPtr    S               *
033200120130     D nextEntry       DS                  likeds(tmpl_entry)
033300120130     D                                     based(nextEntryPtr)
033400120130     D prevEntryPtr    S               *
033500120130     D prevEntry       DS                  likeds(tmpl_entry)
033600120130     D                                     based(prevEntryPtr)
033700120130
033800120130      /free
033900120130       isJSONImpl(jsonPtr);
034000120130
034100120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
034200120130                         length : *omit);
034300120130       tmpKey = %subst(key : 1 : length);
034400120130
034500120130       ptr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
034600120130
034700120130       // check if entry was found
034800120130       if (ptr <> *null);
034900120130
035000120130         // update header
035100120130         if (header.firstEntry = ptr);
035200120130           header.firstEntry = entry.next;
035300120130         endif;
035400120130         if (header.lastEntry = ptr);
035500120130           header.lastEntry = entry.prev;
035600120130         endif;
035700120130
035800120130         // update previous and next (if exist)
035900120130         if (entry.prev <> *null);
036000120130           prevEntryPtr = entry.prev;
036100120130           prevEntry.next = entry.next;
036200120130         endif;
036300120130         if (entry.next <> *null);
036400120130           nextEntryPtr = entry.next;
036500120130           nextEntry.prev = entry.prev;
036600120130         endif;
036700120130
036800120130         // release memory of entry value
036900120130         disposeEntryValue(ptr);
037000120130
037100120130         dealloc(n) entry.key;
037200120130         dealloc(n) ptr;
037300120130
037400120130         header.size -= 1;
037500120130       endif;
037600120130
037700120130      /end-free
037800120130     P                 E
037900120130
038000120130
038100120130     /**
038200120130      * \brief Clear JSON object
038300120130      *
038400120130      * Removes all entries from the JSON object.
038500120130      *
038600120130      * \author Mihael Schmidt
038700120130      * \date   20.03.2008
038800120130      *
038900120130      * \param Pointer to the JSON object
039000120130      *
039100120130      */
039200120130     P json_clear      B                   export
039300120130     D                 PI
039400120130     D   jsonPtr                       *   const
039500120130      *
039600120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
039700120130     D tmpPtr          S               *
039800120130     D ptr             S               *
039900120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
040000120130      /free
040100120130       isJSONImpl(jsonPtr);
040200120130
040300120130       ptr = header.lastEntry;
040400120130       dow (ptr <> *null);
040500120130         tmpPtr = entry.prev;
040600120130
040700120130         // dispose/dealloc old value
040800120130         disposeEntryValue(ptr);
040900120130
041000120130         dealloc(n) entry.key;
041100120130         dealloc(n) ptr;
041200120130         ptr = tmpPtr;
041300120130       enddo;
041400120130
041500120130       // update header
041600120130       header.size = 0;
041700120130       header.firstEntry = *null;
041800120130       header.lastEntry = *null;
041900120130       header.iteration = -1;
042000120130       header.iterNextEntry = *null;
042100120130       header.iterPrevEntry = *null;
042200120130      /end-free
042300120130     P                 E
042400120130
042500120130
042600120130     /**
042700120130      * \brief Get next entry
042800120130      *
042900120130      * Iterates through all JSON entries and returns a pointer to the key of
043000120130      * the next entry.
043100120130      *
043200120130      * <br><br>
043300120130      *
043400120130      * If the iteration ends with the last key *null will be returned.
043500120130      *
043600120130      * <br><br>
043700120130      *
043800120130      * If the iteration is aborted the calling program should use the
043900120130      * <em>abortIteration</em> procedure to reset the iteration.
044000120130      *
044100120130      * \author Mihael Schmidt
044200120130      * \date   20.03.2008
044300120130      *
044400120130      * \param Pointer to the JSON object
044500120130      *
044600120130      * \return Pointer to the key of the next entry or *null if there are no
044700120130      *         more entries
044800120130      */
044900120130     P json_getNext    B                   export
045000120130     D                 PI              *
045100120130     D   jsonPtr                       *   const
045200120130      *
045300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
045400120130     D entryPtr        S               *
045500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
045600120130     D retVal          S               *
045700120130      /free
045800120130       isJSONImpl(jsonPtr);
045900120130
046000120130       if (header.iteration = header.size-1  or
046100120130           header.iteration < -1);
046200120130         header.iteration = -1;
046300120130         retVal = *null;
046400120130       else;
046500120130         if (header.iterNextEntry = *null);
046600120130           entryPtr = header.firstEntry;
046700120130         else;
046800120130           entryPtr = header.iterNextEntry;
046900120130         endif;
047000120130
047100120130         header.iteration += 1;
047200120130         header.iterNextEntry = entry.next;
047300120130         retVal = entry.key;
047400120130       endif;
047500120130
047600120130       return retVal;
047700120130      /end-free
047800120130     P                 E
047900120130
048000120130
048100120130     /**
048200120130      * \brief Abort iteration
048300120130      *
048400120130      * Resets the iteration of the JSON Object.
048500120130      *
048600120130      * \author Mihael Schmidt
048700120130      * \date   20.03.2008
048800120130      *
048900120130      * \param Pointer to the JSON object
049000120130      */
049100120130     P json_abortIteration...
049200120130     P                 B                   export
049300120130     D                 PI
049400120130     D   jsonPtr                       *   const
049500120130      *
049600120130     D header          DS                  likeds(tmpl_header)  based(jsonPtr)
049700120130      /free
049800120130       isJSONImpl(jsonPtr);
049900120130
050000120130       header.iteration = -1;
050100120130       header.iterNextEntry = *null;
050200120130       header.iterPrevEntry = *null;
050300120130      /end-free
050400120130     P                 E
050500120130
050600120130
050700120130     /**
050800120130      * \brief Contains key
050900120130      *
051000120130      * Checks if the JSON object contains an entry with the passed key.
051100120130      *
051200120130      * \author Mihael Schmidt
051300120130      * \date   20.03.2008
051400120130      *
051500120130      * \param Pointer to the JSON object
051600120130      * \param Entry key
051700120130      *
051800120130      * \return *on = JSON object contains key<br>
051900120130      *         *off = JSON object does not contain key
052000120130      */
052100120130     P json_contains...
052200120130     P                 B                   export
052300120130     D                 PI              N   opdesc
052400120130     D   jsonPtr                       *   const
052500120130     D   key                      65535A   const options(*varsize)
052600120130      *
052700120130     D tmpKey          S          65535A
052800120130     D entryPtr        S               *
052900120130     D retVal          S               N
053000120130      /free
053100120130       isJSONImpl(jsonPtr);
053200120130
053300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
053400120130                         length : *omit);
053500120130       tmpKey = %subst(key : 1 : length);
053600120130
053700120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
053800120130       if (entryPtr = *null);
053900120130         retVal = *off;
054000120130       else;
054100120130         retVal = *on;
054200120130       endif;
054300120130
054400120130       return retVal;
054500120130      /end-free
054600120130     P                 E
054700120130
054800120130
054900120130     /**
055000120130      * \brief Is JSON object empty
055100120130      *
055200120130      * Checks if the JSON object contains no entries at all.
055300120130      *
055400120130      * \author Mihael Schmidt
055500120130      * \date   20.03.2008
055600120130      *
055700120130      * \param Pointer to the JSON object
055800120130      *
055900120130      * \return *on = JSON object is empty <br>
056000120130      *         *off = JSON object is not empty
056100120130      */
056200120130     P json_isEmpty    B                   export
056300120130     D                 PI              N
056400120130     D   jsonPtr                       *   const
056500120130      *
056600120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
056700120130     D retVal          S               N
056800120130      /free
056900120130       isJSONImpl(jsonPtr);
057000120130
057100120130       if (header.size = 0);
057200120130         retVal = *on;
057300120130       else;
057400120130         retVal = *off;
057500120130       endif;
057600120130
057700120130       return retVal;
057800120130      /end-free
057900120130     P                 E
058000120130
058100120130
058200120130     /**
058300120130      * \brief Count JSON object entries
058400120130      *
058500120130      * Returns the number of entries in the JSON object. The keys of the
058600120130      * entries are counted. If the JSON object contains arrays the elements
058700120130      * of the arrays are ignored.
058800120130      *
058900120130      * \author Mihael Schmidt
059000120130      * \date   20.03.2008
059100120130      *
059200120130      * \param Pointer to the JSON object
059300120130      *
059400120130      * \return number of entries in the JSON object
059500120130      */
059600120130     P json_size       B                   export
059700120130     D                 PI            10I 0
059800120130     D  jsonPtr                        *   const
059900120130      *
060000120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
060100120130      /free
060200120130       isJSONImpl(jsonPtr);
060300120130
060400120130       return header.size;
060500120130      /end-free
060600120130     P                 E
060700120130
060800120130
060900120130     /**
061000120130      * \brief Add character entry
061100120130      *
061200120130      * Adds an entry of type character.
061300120130      *
061400120130      * \author Mihael Schmidt
061500120130      * \date   20.03.2008
061600120130      *
061700120130      * \param Pointer to the JSON object
061800120130      * \param Key
061900120130      * \param Value
062000120130      */
062100120130     P json_putString  B                   export
062200120130     D                 PI                  opdesc
062300120130     D   jsonPtr                       *   const
062400120130     D   key                      65535A   const options(*varsize)
062500120130     D   value                    65535A   const options(*varsize)
062600120130      *
062700120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
062800120130     D prevEntryPtr    S               *
062900120130     D prevEntry       DS                  likeds(tmpl_entry)
063000120130     D                                     based(prevEntryPtr)
063100120130     D newEntryPtr     S               *
063200120130     D newEntry        DS                  likeds(tmpl_entry)
063300120130     D                                     based(newEntryPtr)
063400120130     D tmpPtr          S               *
063500120130     D tmpKey          S          65535A
063600120130     D tmpValue        S          65535A
063700120130     D keyLength       S             10I 0
063800120130     D valueLength     S             10I 0
063900120130      /free
064000120130       isJSONImpl(jsonPtr);
064100120130
064200120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
064300120130                         length : *omit);
064400120130       keyLength = length;
064500120130       tmpKey = %subst(key : 1 : keyLength);
064600120130       cee_getOpDescInfo(3 : descType : dataType : descInfo1 : descInfo2 :
064700120130                         length : *omit);
064800120130       valueLength = length;
064900120130       tmpValue = %subst(value : 1 : valueLength);
065000120130
065100120130       // check if key is in already in the map
065200120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
065300120130       if (newEntryPtr = *null);    // entry not in json object
065400120130         // create new entry
065500120130         newEntryPtr = %alloc(%size(tmpl_entry));
065600120130         newEntry.type = JSON_TYPE_STRING;
065700120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
065800120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
065900120130         newEntry.valueLength = valueLength;
066000120130         newEntry.value = %alloc(valueLength + 1);   // +1 for the null byte
066100120130         newEntry.next = *null;
066200120130         newEntry.prev = *null;
066300120130
066400120130         // update header
066500120130         header.size += 1;
066600120130         if (header.firstEntry = *null);
066700120130           header.firstEntry = newEntryPtr;
066800120130         else;
066900120130           prevEntryPtr = header.lastEntry;
067000120130           prevEntry.next = newEntryPtr;
067100120130           newEntry.prev = prevEntryPtr;
067200120130         endif;
067300120130         header.lastEntry = newEntryPtr;
067400120130
067500120130       else;
067600120130         // entry needs to be resized
067700120130         newEntry.type = JSON_TYPE_STRING;
067800120130         newEntry.keyLength = keyLength + 1;
067900120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
068000120130         newEntry.valueLength = valueLength;
068100120130
068200120130         // dispose/dealloc old value
068300120130         disposeEntryValue(newEntryPtr);
068400120130       endif;
068500120130
068600120130       // copy value to the list entry
068700120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
068800120130       memcpy(newEntry.value : %addr(tmpValue) : valueLength);
068900120130
069000120130       // set null to the last byte
069100120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
069200120130       memcpy(newEntry.value + valueLength : %addr(hexNull) : 1);
069300120130      /end-free
069400120130     P                 E
069500120130
069600120130
069700120130     /**
069800120130      * \brief Add boolean entry
069900120130      *
070000120130      * Adds an entry of type boolean.
070100120130      *
070200120130      * \author Mihael Schmidt
070300120130      * \date   20.03.2008
070400120130      *
070500120130      * \param Pointer to the JSON object
070600120130      * \param Key
070700120130      * \param Value
070800120130      */
070900120130     P json_putBoolean...
071000120130     P                 B                   export
071100120130     D                 PI                  opdesc
071200120130     D   jsonPtr                       *   const
071300120130     D   key                      65535A   const options(*varsize)
071400120130     D   value                         N   const
071500120130      *
071600120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
071700120130     D prevEntryPtr    S               *
071800120130     D prevEntry       DS                  likeds(tmpl_entry)
071900120130     D                                     based(prevEntryPtr)
072000120130     D newEntryPtr     S               *
072100120130     D newEntry        DS                  likeds(tmpl_entry)
072200120130     D                                     based(newEntryPtr)
072300120130     D tmpPtr          S               *
072400120130     D tmpKey          S          65535A
072500120130     D keyLength       S             10I 0
072600120130     D tmpValue        S               N   based(newEntry.value)
072700120130      /free
072800120130       isJSONImpl(jsonPtr);
072900120130
073000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
073100120130                         length : *omit);
073200120130       keyLength = length;
073300120130       tmpKey = %subst(key : 1 : keyLength);
073400120130
073500120130
073600120130       // check if key is in already in the map
073700120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
073800120130       if (newEntryPtr = *null);    // entry not in json object
073900120130         // create new entry
074000120130         newEntryPtr = %alloc(%size(tmpl_entry));
074100120130         newEntry.type = JSON_TYPE_BOOLEAN;
074200120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
074300120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
074400120130         newEntry.valueLength = 1;
074500120130         newEntry.value = %alloc(1);
074600120130         newEntry.next = *null;
074700120130         newEntry.prev = *null;
074800120130
074900120130         // update header
075000120130         header.size += 1;
075100120130         if (header.firstEntry = *null);
075200120130           header.firstEntry = newEntryPtr;
075300120130         else;
075400120130           prevEntryPtr = header.lastEntry;
075500120130           prevEntry.next = newEntryPtr;
075600120130           newEntry.prev = prevEntryPtr;
075700120130         endif;
075800120130         header.lastEntry = newEntryPtr;
075900120130
076000120130       else;
076100120130         // entry needs to be resized
076200120130         newEntry.type = JSON_TYPE_BOOLEAN;
076300120130         newEntry.keyLength = keyLength + 1;
076400120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
076500120130         newEntry.valueLength = 1;
076600120130
076700120130         // dispose/dealloc old value
076800120130         disposeEntryValue(newEntryPtr);
076900120130       endif;
077000120130
077100120130
077200120130       // copy key/value to the list entry
077300120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
077400120130       tmpValue = value;
077500120130
077600120130       // set null to the last byte
077700120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
077800120130      /end-free
077900120130     P                 E
078000120130
078100120130
078200120130     /**
078300120130      * \brief Add integer entry
078400120130      *
078500120130      * Adds an entry of type integer.
078600120130      *
078700120130      * \author Mihael Schmidt
078800120130      * \date   20.03.2008
078900120130      *
079000120130      * \param Pointer to the JSON object
079100120130      * \param Key
079200120130      * \param Value
079300120130      */
079400120130     P json_putInt...
079500120130     P                 B                   export
079600120130     D                 PI                  opdesc
079700120130     D   jsonPtr                       *   const
079800120130     D   key                      65535A   const options(*varsize)
079900120130     D   value                       10I 0 const
080000120130      *
080100120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
080200120130     D prevEntryPtr    S               *
080300120130     D prevEntry       DS                  likeds(tmpl_entry)
080400120130     D                                     based(prevEntryPtr)
080500120130     D newEntryPtr     S               *
080600120130     D newEntry        DS                  likeds(tmpl_entry)
080700120130     D                                     based(newEntryPtr)
080800120130     D tmpPtr          S               *
080900120130     D tmpKey          S          65535A
081000120130     D keyLength       S             10I 0
081100120130     D tmpValue        S             10I 0 based(newEntry.value)
081200120130      /free
081300120130       isJSONImpl(jsonPtr);
081400120130
081500120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
081600120130                         length : *omit);
081700120130       keyLength = length;
081800120130       tmpKey = %subst(key : 1 : keyLength);
081900120130
082000120130       // check if key is in already in the map
082100120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
082200120130       if (newEntryPtr = *null);    // entry not in json object
082300120130         // create new entry
082400120130         newEntryPtr = %alloc(%size(tmpl_entry));
082500120130         newEntry.type = JSON_TYPE_INT;
082600120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
082700120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
082800120130         newEntry.valueLength = %size(tmpValue);
082900120130         newEntry.value = %alloc(%size(tmpValue));
083000120130         newEntry.next = *null;
083100120130         newEntry.prev = *null;
083200120130
083300120130         // update header
083400120130         header.size += 1;
083500120130         if (header.firstEntry = *null);
083600120130           header.firstEntry = newEntryPtr;
083700120130         else;
083800120130           prevEntryPtr = header.lastEntry;
083900120130           prevEntry.next = newEntryPtr;
084000120130           newEntry.prev = prevEntryPtr;
084100120130         endif;
084200120130         header.lastEntry = newEntryPtr;
084300120130       else;
084400120130         // entry needs to be resized
084500120130         newEntry.type = JSON_TYPE_INT;
084600120130         newEntry.keyLength = keyLength + 1;
084700120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
084800120130         newEntry.valueLength = %size(tmpValue);
084900120130
085000120130         // dispose/dealloc old value
085100120130         disposeEntryValue(newEntryPtr);
085200120130       endif;
085300120130
085400120130       // copy value to the list entry
085500120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
085600120130       tmpValue = value;
085700120130
085800120130       // set null to the last byte
085900120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
086000120130      /end-free
086100120130     P                 E
086200120130
086300120130
086400120130     /**
086500120130      * \brief Add long entry
086600120130      *
086700120130      * Adds an entry of type long.
086800120130      *
086900120130      * \author Mihael Schmidt
087000120130      * \date   20.03.2008
087100120130      *
087200120130      * \param Pointer to the JSON object
087300120130      * \param Key
087400120130      * \param Value
087500120130      */
087600120130     P json_putLong...
087700120130     P                 B                   export
087800120130     D                 PI                  opdesc
087900120130     D   jsonPtr                       *   const
088000120130     D   key                      65535A   const options(*varsize)
088100120130     D   value                       20I 0 const
088200120130      *
088300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
088400120130     D prevEntryPtr    S               *
088500120130     D prevEntry       DS                  likeds(tmpl_entry)
088600120130     D                                     based(prevEntryPtr)
088700120130     D newEntryPtr     S               *
088800120130     D newEntry        DS                  likeds(tmpl_entry)
088900120130     D                                     based(newEntryPtr)
089000120130     D tmpPtr          S               *
089100120130     D tmpKey          S          65535A
089200120130     D keyLength       S             10I 0
089300120130     D tmpValue        S             20I 0 based(newEntry.value)
089400120130      /free
089500120130       isJSONImpl(jsonPtr);
089600120130
089700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
089800120130                         length : *omit);
089900120130       keyLength = length;
090000120130       tmpKey = %subst(key : 1 : keyLength);
090100120130
090200120130       // check if key is in already in the map
090300120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
090400120130       if (newEntryPtr = *null);    // entry not in json object
090500120130         // create new entry
090600120130         newEntryPtr = %alloc(%size(tmpl_entry));
090700120130         newEntry.type = JSON_TYPE_LONG;
090800120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
090900120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
091000120130         newEntry.valueLength = %size(tmpValue);
091100120130         newEntry.value = %alloc(%size(tmpValue));
091200120130         newEntry.next = *null;
091300120130         newEntry.prev = *null;
091400120130
091500120130         // update header
091600120130         header.size += 1;
091700120130         if (header.firstEntry = *null);
091800120130           header.firstEntry = newEntryPtr;
091900120130         else;
092000120130           prevEntryPtr = header.lastEntry;
092100120130           prevEntry.next = newEntryPtr;
092200120130           newEntry.prev = prevEntryPtr;
092300120130         endif;
092400120130         header.lastEntry = newEntryPtr;
092500120130
092600120130       else;
092700120130         // entry needs to be resized
092800120130         newEntry.type = JSON_TYPE_LONG;
092900120130         newEntry.keyLength = keyLength + 1;
093000120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
093100120130         newEntry.valueLength = %size(tmpValue);
093200120130
093300120130         // dispose/dealloc old value
093400120130         disposeEntryValue(newEntryPtr);
093500120130       endif;
093600120130
093700120130       // copy value to the list entry
093800120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
093900120130       tmpValue = value;
094000120130
094100120130       // set null to the last byte
094200120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
094300120130      /end-free
094400120130     P                 E
094500120130
094600120130
094700120130     /**
094800120130      * \brief Add double entry
094900120130      *
095000120130      * Adds an entry of type double.
095100120130      *
095200120130      * \author Mihael Schmidt
095300120130      * \date   20.03.2008
095400120130      *
095500120130      * \param Pointer to the JSON object
095600120130      * \param Key
095700120130      * \param Value
095800120130      */
095900120130     P json_putDouble...
096000120130     P                 B                   export
096100120130     D                 PI                  opdesc
096200120130     D   jsonPtr                       *   const
096300120130     D   key                      65535A   const options(*varsize)
096400120130     D   value                        8F   const
096500120130      *
096600120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
096700120130     D prevEntryPtr    S               *
096800120130     D prevEntry       DS                  likeds(tmpl_entry)
096900120130     D                                     based(prevEntryPtr)
097000120130     D newEntryPtr     S               *
097100120130     D newEntry        DS                  likeds(tmpl_entry)
097200120130     D                                     based(newEntryPtr)
097300120130     D tmpPtr          S               *
097400120130     D tmpKey          S          65535A
097500120130     D keyLength       S             10I 0
097600120130     D tmpValue        S              8F   based(newEntry.value)
097700120130      /free
097800120130       isJSONImpl(jsonPtr);
097900120130
098000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
098100120130                         length : *omit);
098200120130       keyLength = length;
098300120130       tmpKey = %subst(key : 1 : keyLength);
098400120130
098500120130       // check if key is in already in the map
098600120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
098700120130       if (newEntryPtr = *null);    // entry not in json object
098800120130         // create new entry
098900120130         newEntryPtr = %alloc(%size(tmpl_entry));
099000120130         newEntry.type = JSON_TYPE_DOUBLE;
099100120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
099200120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
099300120130         newEntry.valueLength = %size(tmpValue);
099400120130         newEntry.value = %alloc(%size(tmpValue));
099500120130         newEntry.next = *null;
099600120130         newEntry.prev = *null;
099700120130
099800120130         // update header
099900120130         header.size += 1;
100000120130         if (header.firstEntry = *null);
100100120130           header.firstEntry = newEntryPtr;
100200120130         else;
100300120130           prevEntryPtr = header.lastEntry;
100400120130           prevEntry.next = newEntryPtr;
100500120130           newEntry.prev = prevEntryPtr;
100600120130         endif;
100700120130         header.lastEntry = newEntryPtr;
100800120130
100900120130       else;
101000120130         // entry needs to be resized
101100120130         newEntry.type = JSON_TYPE_DOUBLE;
101200120130         newEntry.keyLength = keyLength + 1;
101300120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
101400120130         newEntry.valueLength = %size(tmpValue);
101500120130
101600120130         // dispose/dealloc old value
101700120130         disposeEntryValue(newEntryPtr);
101800120130       endif;
101900120130
102000120130       // copy value to the list entry
102100120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
102200120130       tmpValue = value;
102300120130
102400120130       // set null to the last byte
102500120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
102600120130      /end-free
102700120130     P                 E
102800120130
102900120130
103000120130     /**
103100120130      * \brief Add array entry
103200120130      *
103300120130      * Adds an entry of type array.
103400120130      *
103500120130      * \author Mihael Schmidt
103600120130      * \date   19.04.2008
103700120130      *
103800120130      * \param Pointer to the JSON object
103900120130      * \param Key
104000120130      * \param Array
104100120130      */
104200120130     P json_putArray...
104300120130     P                 B                   export
104400120130     D                 PI                  opdesc
104500120130     D   jsonPtr                       *   const
104600120130     D   key                      65535A   const options(*varsize)
104700120130     D   value                         *   const
104800120130      *
104900120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
105000120130     D prevEntryPtr    S               *
105100120130     D prevEntry       DS                  likeds(tmpl_entry)
105200120130     D                                     based(prevEntryPtr)
105300120130     D newEntryPtr     S               *
105400120130     D newEntry        DS                  likeds(tmpl_entry)
105500120130     D                                     based(newEntryPtr)
105600120130     D tmpKey          S          65535A
105700120130     D keyLength       S             10I 0
105800120130      /free
105900120130       isJSONImpl(jsonPtr);
106000120130
106100120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
106200120130                         length : *omit);
106300120130       keyLength = length;
106400120130       tmpKey = %subst(key : 1 : keyLength);
106500120130
106600120130       // check if key is in already in the map
106700120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
106800120130       if (newEntryPtr = *null);    // entry not in json object
106900120130         // create new entry
107000120130         newEntryPtr = %alloc(%size(tmpl_entry));
107100120130         newEntry.type = JSON_TYPE_ARRAY;
107200120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
107300120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
107400120130         newEntry.valueLength = 0;
107500120130         newEntry.value = *null;
107600120130         newEntry.next = *null;
107700120130         newEntry.prev = *null;
107800120130
107900120130         // update header
108000120130         header.size += 1;
108100120130         if (header.firstEntry = *null);
108200120130           header.firstEntry = newEntryPtr;
108300120130         else;
108400120130           prevEntryPtr = header.lastEntry;
108500120130           prevEntry.next = newEntryPtr;
108600120130           newEntry.prev = prevEntryPtr;
108700120130         endif;
108800120130         header.lastEntry = newEntryPtr;
108900120130
109000120130       else;
109100120130         // entry needs to be resized
109200120130         newEntry.type = JSON_TYPE_ARRAY;
109300120130         newEntry.keyLength = keyLength + 1;
109400120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
109500120130         newEntry.valueLength = 0;
109600120130
109700120130         // dispose/dealloc old value
109800120130         disposeEntryValue(newEntryPtr);
109900120130       endif;
110000120130
110100120130       // copy key and value to entry
110200120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
110300120130       newEntry.value = value;
110400120130
110500120130       // set null to the last byte
110600120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
110700120130      /end-free
110800120130     P                 E
110900120130
111000120130
111100120130     /**
111200120130      * \brief Get entry
111300120130      *
111400120130      * Gets the value of entry in the JSON object as a string.
111500120130      *
111600120130      * <br><br>
111700120130      *
111800120130      * The return value is a pointer to a null terminated string so that it
111900120130      * can be easily processed with the %str BIF.
112000120130      *
112100120130      * <br><br>
112200120130      *
112300120130      * The memory for the return value was allocated will be managed by
112400120130      * the JSON object and will be disposed with the <em>dispose</em>
112500120130      * procedure. The calling program does not need to deallocate the
112600120130      * the memory by itself.
112700120130      *
112800120130      * \author Mihael Schmidt
112900120130      * \date   20.03.2008
113000120130      *
113100120130      * \param Pointer to the JSON object
113200120130      * \param Key
113300120130      *
113400120130      * \return Pointer to a null terminated string or *null if JSON object
113500120130      *         does not contain the passed key
113600120130      */
113700120130     P json_get        B                   export
113800120130     D                 PI              *   opdesc
113900120130     D   jsonPtr                       *   const
114000120130     D   key                      65535A   const options(*varsize)
114100120130      *
114200120130     D tmpKey          S          65535A
114300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
114400120130     D entryPtr        S               *
114500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
114600120130     D retVal          S               *   inz(*null)
114700120130      *
114800120130     D tmpPtr          S               *
114900120130     D tmpDs           DS                  based(tmpPtr)
115000120130     D   tmpBoolean                    N   overlay(tmpDs)
115100120130     D   tmpInt                      10I 0 overlay(tmpDs)
115200120130     D   tmpLong                     20I 0 overlay(tmpDs)
115300120130     D   tmpDouble                    8F   overlay(tmpDs)
115400120130     D tmpString       S            310A
115500120130     D tmpLength       S             10I 0
115600120130     D hex_null        S              1A   inz(x'00')
115700120130      /free
115800120130       isJSONImpl(jsonPtr);
115900120130
116000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
116100120130                         length : *omit);
116200120130       tmpKey = %subst(key : 1 : length);
116300120130
116400120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
116500120130       if (entryPtr <> *null);
116600120130         select;
116700120130           when (entry.type = JSON_TYPE_STRING);
116800120130             retVal = %alloc(entry.valueLength + 1); // + 1 byte for the null value
116900120130             // +1 because the null byte was already added to the string during putString
117000120130             memcpy(retVal : entry.value : entry.valueLength + 1);
117100120130
117200120130           when (entry.type = JSON_TYPE_INT);
117300120130             tmpPtr = entry.value;
117400120130             tmpString = %char(tmpInt);
117500120130             tmpLength = %len(%trimr(tmpString));
117600120130             retVal = %alloc(tmpLength);
117700120130             memcpy(retVal : %addr(tmpString) : tmpLength);
117800120130             memcpy(retVal + tmplength : %addr(hex_null) : 1);
117900120130
118000120130           when (entry.type = JSON_TYPE_LONG);
118100120130             tmpPtr = entry.value;
118200120130             tmpString = %char(tmpLong);
118300120130             tmpLength = %len(%trimr(tmpString));
118400120130             retVal = %alloc(tmpLength);
118500120130             memcpy(retVal : %addr(tmpString) : tmpLength);
118600120130             memcpy(retVal + tmplength : %addr(hex_null) : 1);
118700120130
118800120130           when (entry.type = JSON_TYPE_DOUBLE);
118900120130             tmpPtr = entry.value;
119000120130             tmpString = %char(tmpDouble);
119100120130             tmpLength = %len(%trimr(tmpString));
119200120130             retVal = %alloc(tmpLength);
119300120130             memcpy(retVal : %addr(tmpString) : tmpLength);
119400120130             memcpy(retVal + tmplength : %addr(hex_null) : 1);
119500120130
119600120130           when (entry.type = JSON_TYPE_BOOLEAN);
119700120130             tmpPtr = entry.value;
119800120130             retVal = %alloc(%size(tmpBoolean));
119900120130             memcpy(retVal : %addr(tmpDs) : %size(tmpBoolean));
120000120130             memcpy(retVal + 1 : %addr(hex_null) : 1);
120100120130
120200120130           when (entry.type = JSON_TYPE_ARRAY);
120300120130             retVal = jsona_toString(entry.value);
120400120130
120500120130           when (entry.type = JSON_TYPE_OBJECT);
120600120130             retVal = json_toString(entry.value);
120700120130
120800120130         endsl;
120900120130       endif;
121000120130
121100120130       // register this pointer to the dispose list so that the memory will be managed
121200120130       if (retVal <> *null);
121300120130         if (entry.type = JSON_TYPE_OBJECT);
121400120130           // don't add this pointer to the dispose list
121500120130           // it has already been added to the list in the toString procedure
121600120130         else;
121700120130           arraylist_add(header.disposeList : %addr(retVal) : 16);
121800120130         endif;
121900120130       endif;
122000120130
122100120130       return retVal;
122200120130      /end-free
122300120130     P                 E
122400120130
122500120130
122600120130     /**
122700120130      * \brief Get string entry
122800120130      *
122900120130      * Returns a pointer to the value of the entry for the passed key.
123000120130      * The value is null terminated and can be processed with the %str BIF.
123100120130      *
123200120130      * <br><br>
123300120130      *
123400120130      * If the entry is not of type string an escape message will be send.
123500120130      *
123600120130      * \author Mihael Schmidt
123700120130      * \date   20.03.2008
123800120130      *
123900120130      * \param Pointer to the JSON object
124000120130      * \param Key
124100120130      *
124200120130      * \return Pointer to a null-terminated string
124300120130      */
124400120130     P json_getString  B                   export
124500120130     D                 PI              *   opdesc
124600120130     D   jsonPtr                       *   const
124700120130     D   key                      65535A   const options(*varsize)
124800120130      *
124900120130     D tmpKey          S          65535A
125000120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
125100120130     D entryPtr        S               *
125200120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
125300120130     D retVal          S               *   inz(*null)
125400120130      /free
125500120130       isJSONImpl(jsonPtr);
125600120130
125700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
125800120130                         length : *omit);
125900120130       tmpKey = %subst(key : 1 : length);
126000120130
126100120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
126200120130       if (entryPtr <> *null);
126300120130         if (entry.type = JSON_TYPE_STRING);
126400120130           retVal = entry.value;
126500120130         else;
126600120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
126700120130         endif;
126800120130       endif;
126900120130
127000120130       return retVal;
127100120130      /end-free
127200120130     P                 E
127300120130
127400120130
127500120130     /**
127600120130      * \brief Get boolean entry
127700120130      *
127800120130      * Returns the boolean value of the entry.
127900120130      *
128000120130      * <br><br>
128100120130      *
128200120130      * If the entry is not of type boolean an escape message will be send.
128300120130      *
128400120130      * \author Mihael Schmidt
128500120130      * \date   20.03.2008
128600120130      *
128700120130      * \param Pointer to the JSON object
128800120130      * \param Key
128900120130      *
129000120130      * \return Boolean value of the entry
129100120130      */
129200120130     P json_getBoolean...
129300120130     P                 B                   export
129400120130     D                 PI              N   opdesc
129500120130     D   jsonPtr                       *   const
129600120130     D   key                      65535A   const options(*varsize)
129700120130      *
129800120130     D tmpKey          S          65535A
129900120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
130000120130     D entryPtr        S               *
130100120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
130200120130     D value           S               N   based(entry.value)
130300120130     D retVal          S               N
130400120130      /free
130500120130       isJSONImpl(jsonPtr);
130600120130
130700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
130800120130                         length : *omit);
130900120130       tmpKey = %subst(key : 1 : length);
131000120130
131100120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
131200120130       if (entryPtr <> *null);
131300120130         if (entry.type = JSON_TYPE_BOOLEAN);
131400120130           retVal = value;
131500120130         else;
131600120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
131700120130         endif;
131800120130       endif;
131900120130
132000120130       return retVal;
132100120130      /end-free
132200120130     P                 E
132300120130
132400120130
132500120130     /**
132600120130      * \brief Get integer entry
132700120130      *
132800120130      * Returns the integer value of the entry.
132900120130      *
133000120130      * <br><br>
133100120130      *
133200120130      * If the entry is not of type integer an escape message will be send.
133300120130      *
133400120130      * \author Mihael Schmidt
133500120130      * \date   20.03.2008
133600120130      *
133700120130      * \param Pointer to the JSON object
133800120130      * \param Key
133900120130      *
134000120130      * \return Integer value of the entry
134100120130      */
134200120130     P json_getInt...
134300120130     P                 B                   export
134400120130     D                 PI            10I 0 opdesc
134500120130     D   jsonPtr                       *   const
134600120130     D   key                      65535A   const options(*varsize)
134700120130      *
134800120130     D tmpKey          S          65535A
134900120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
135000120130     D entryPtr        S               *
135100120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
135200120130     D valueInt        S             10I 0 based(entry.value)
135300120130     D valueLong       S             20I 0 based(entry.value)
135400120130     D valueDouble     S              8F   based(entry.value)
135500120130     D retVal          S             10I 0
135600120130      /free
135700120130       isJSONImpl(jsonPtr);
135800120130
135900120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
136000120130                         length : *omit);
136100120130       tmpKey = %subst(key : 1 : length);
136200120130
136300120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
136400120130       if (entryPtr <> *null);
136500120130         if (entry.type = JSON_TYPE_INT);
136600120130           retVal = valueInt;
136700120130         elseif (entry.type = JSON_TYPE_LONG);
136800120130           monitor;
136900120130             retVal = valueLong;
137000120130             on-error *all;
137100120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
137200120130           endmon;
137300120130         elseif (entry.type = JSON_TYPE_DOUBLE);
137400120130           monitor;
137500120130             retVal = %int(valueDouble);
137600120130             on-error *all;
137700120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
137800120130           endmon;
137900120130         else;
138000120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
138100120130         endif;
138200120130       endif;
138300120130
138400120130       return retVal;
138500120130      /end-free
138600120130     P                 E
138700120130
138800120130
138900120130     /**
139000120130      * \brief Get long entry
139100120130      *
139200120130      * Returns the long value of the entry.
139300120130      *
139400120130      * <br><br>
139500120130      *
139600120130      * If the entry is not of type long an escape message will be send.
139700120130      *
139800120130      * \author Mihael Schmidt
139900120130      * \date   20.03.2008
140000120130      *
140100120130      * \param Pointer to the JSON object
140200120130      * \param Key
140300120130      *
140400120130      * \return Long value of the entry
140500120130      */
140600120130     P json_getLong...
140700120130     P                 B                   export
140800120130     D                 PI            20I 0 opdesc
140900120130     D   jsonPtr                       *   const
141000120130     D   key                      65535A   const options(*varsize)
141100120130      *
141200120130     D tmpKey          S          65535A
141300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
141400120130     D entryPtr        S               *
141500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
141600120130     D valueInt        S             10I 0 based(entry.value)
141700120130     D valueLong       S             20I 0 based(entry.value)
141800120130     D valueDouble     S              8F   based(entry.value)
141900120130     D retVal          S             20I 0
142000120130      /free
142100120130       isJSONImpl(jsonPtr);
142200120130
142300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
142400120130                         length : *omit);
142500120130       tmpKey = %subst(key : 1 : length);
142600120130
142700120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
142800120130       if (entryPtr <> *null);
142900120130         if (entry.type = JSON_TYPE_LONG);
143000120130           retVal = valueLong;
143100120130         elseif (entry.type = JSON_TYPE_INT);
143200120130           retVal = valueInt;
143300120130         elseif (entry.type = JSON_TYPE_DOUBLE);
143400120130           monitor;
143500120130             retVal = %int(valueDouble);
143600120130             on-error *all;
143700120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
143800120130           endmon;
143900120130         else;
144000120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
144100120130         endif;
144200120130       endif;
144300120130
144400120130       return retVal;
144500120130      /end-free
144600120130     P                 E
144700120130
144800120130
144900120130     /**
145000120130      * \brief Get double entry
145100120130      *
145200120130      * Returns the double value of the entry.
145300120130      *
145400120130      * <br><br>
145500120130      *
145600120130      * If the entry is not of type double an escape message will be send.
145700120130      *
145800120130      * \author Mihael Schmidt
145900120130      * \date   20.03.2008
146000120130      *
146100120130      * \param Pointer to the JSON object
146200120130      * \param Key
146300120130      *
146400120130      * \return Double value of the entry
146500120130      */
146600120130     P json_getDouble...
146700120130     P                 B                   export
146800120130     D                 PI             8F   opdesc
146900120130     D   jsonPtr                       *   const
147000120130     D   key                      65535A   const options(*varsize)
147100120130      *
147200120130     D tmpKey          S          65535A
147300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
147400120130     D entryPtr        S               *
147500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
147600120130     D valueInt        S             10I 0 based(entry.value)
147700120130     D valueLong       S             20I 0 based(entry.value)
147800120130     D valueDouble     S              8F   based(entry.value)
147900120130     D retVal          S              8F
148000120130      /free
148100120130       isJSONImpl(jsonPtr);
148200120130
148300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
148400120130                         length : *omit);
148500120130       tmpKey = %subst(key : 1 : length);
148600120130
148700120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
148800120130       if (entryPtr <> *null);
148900120130         if (entry.type = JSON_TYPE_DOUBLE);
149000120130           retVal = valueDouble;
149100120130         elseif (entry.type = JSON_TYPE_INT);
149200120130           retVal = %float(valueInt);
149300120130         elseif (entry.type = JSON_TYPE_LONG);
149400120130           monitor;
149500120130             retVal = %float(valueLong);
149600120130             on-error *all;
149700120130               sendEscapeMessage(MSG_TYPE_CAST_EXCEPTION);
149800120130           endmon;
149900120130         else;
150000120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
150100120130         endif;
150200120130       endif;
150300120130
150400120130       return retVal;
150500120130      /end-free
150600120130     P                 E
150700120130
150800120130
150900120130     /**
151000120130      * \brief Get array entry
151100120130      *
151200120130      * Returns the array value of the entry.
151300120130      *
151400120130      * <br><br>
151500120130      *
151600120130      * If the entry is not of type array an escape message will be send.
151700120130      *
151800120130      * \author Mihael Schmidt
151900120130      * \date   20.03.2008
152000120130      *
152100120130      * \param Pointer to the JSON object
152200120130      * \param Key
152300120130      *
152400120130      * \return Pointer to the JSON array
152500120130      */
152600120130     P json_getArray...
152700120130     P                 B                   export
152800120130     D                 PI              *   opdesc
152900120130     D   jsonPtr                       *   const
153000120130     D   key                      65535A   const options(*varsize)
153100120130      *
153200120130     D tmpKey          S          65535A
153300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
153400120130     D entryPtr        S               *
153500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
153600120130     D retVal          S               *
153700120130      /free
153800120130       isJSONImpl(jsonPtr);
153900120130
154000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
154100120130                         length : *omit);
154200120130       tmpKey = %subst(key : 1 : length);
154300120130
154400120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
154500120130       if (entryPtr <> *null);
154600120130         if (entry.type = JSON_TYPE_ARRAY);
154700120130           retVal = entry.value;
154800120130         else;
154900120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
155000120130         endif;
155100120130       endif;
155200120130
155300120130       return retVal;
155400120130      /end-free
155500120130     P                 E
155600120130
155700120130
155800120130     /**
155900120130      * \brief String representation of the JSON object in JSON syntax
156000120130      *
156100120130      * Creates a null terminated string representation of the JSON object in
156200120130      * JSON syntax.
156300120130      *
156400120130      * <br><br>
156500120130      *
156600120130      * For entries of type string double quotes and backslashes will be escaped
156700120130      * (" => \" and \ => \\).
156800120130      *
156900120130      * \author Mihael Schmidt
157000120130      * \date   20.03.2008
157100120130      *
157200120130      * \param Pointer to the JSON object
157300120130      */
157400120130     P json_toString   B                   export
157500120130     D                 PI              *
157600120130     D   jsonPtr                       *   const
157700120130     D   pOutputFormat...
157800120130     D                               10I 0 const options(*nopass)
157900120130     D   pPrettyPrintFormat...
158000120130     D                                     likeds(json_prettyPrintFormat)
158100120130     D                                     const options(*nopass)
158200120130     D   pIndentationLevel...
158300120130     D                               10I 0 options(*nopass)
158400120130      *
158500120130     D outputFormat    S             10I 0
158600120130     D prettyPrintOption...
158700120130     D                 S               N   inz(*off)
158800120130     D prettyPrintFormat...
158900120130     D                 DS                  likeds(json_prettyPrintFormat) inz
159000120130     D indentationLevel...
159100120130     D                 S             10I 0 inz(0)
159200120130      *
159300120130     D l_chars         DS                  likeds(tmpl_chars) inz
159400120130      *
159500120130     D json_string_ptr...
159600120130     D                 S               *
159700120130     D json_string_length...
159800120130     D                 S             10I 0
159900120130     D tokenList       S               *
160000120130      *
160100120130     D tmpDs           DS                  based(entry.value)
160200120130     D   tmpBoolean                    N   overlay(tmpDs)
160300120130     D   tmpInt                      10I 0 overlay(tmpDs)
160400120130     D   tmpLong                     20I 0 overlay(tmpDs)
160500120130     D   tmpDouble                    8F   overlay(tmpDs)
160600120130     D   tmpArray                      *   overlay(tmpDs)
160700120130     D tmpString       S            310A
160800120130     D tmpLength       S             10I 0
160900120130     D hex_null        S              1A   inz(x'00')
161000120130     D newline         S              2A   inz(x'0D25')
161100120130      *
161200120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
161300120130     D entryPtr        S               *
161400120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
161500120130      *
161600120130     D ptr             S               *
161700120130     D x               S             10I 0
161800120130     D i               S             10I 0
161900120130     D size            S             10I 0
162000120130      /free
162100120130       isJSONImpl(jsonPtr);
162200120130
162300120130       if (%parms() = 2);
162400120130         outputFormat = pOutputFormat;
162500120130         prettyPrintFormat.useTabs = *off;
162600120130         prettyPrintFormat.numberWhitespace = 4;
162700120130         prettyPrintFormat.breakAfterElement = *on;
162800120130         prettyPrintFormat.breakAfterObjectBrace = *on;
162900120130         prettyPrintFormat.breakBeforeArrayBrace = *on;
163000120130         prettyPrintFormat.breakAfterArrayBrace = *on;
163100120130       elseif (%parms() = 3);
163200120130         outputFormat = pOutputFormat;
163300120130         prettyPrintFormat = pPrettyPrintFormat;
163400120130       elseif (%parms() = 4);
163500120130         outputFormat = pOutputFormat;
163600120130         prettyPrintFormat = pPrettyPrintFormat;
163700120130         indentationLevel = pIndentationLevel;
163800120130       endif;
163900120130
164000120130       if (outputFormat = JSON_OUTPUT_PRETTY_PRINT);
164100120130         prettyPrintOption = *on;
164200120130       endif;
164300120130
164400120130       exsr init;
164500120130
164600120130       // initialisierung
164700120130       //  - anfangszeichen schreiben
164800120130       //  - tokenlist initialisieren
164900120130       tokenList = arraylist_create();
165000120130       arraylist_add(tokenList : %addr(l_chars.l_brace) :
165100120130                     %size(l_chars.size_l_brace));
165200120130
165300120130       if (prettyPrintOption);
165400120130
165500120130         if (prettyPrintFormat.breakAfterObjectBrace);
165600120130           indentationLevel += 1;
165700120130           arraylist_add(tokenList : %addr(newline) : %size(newline));
165800120130         endif;
165900120130
166000120130       endif;
166100120130
166200120130       // einträge verarbeiten
166300120130       entryPtr = header.firstEntry;
166400120130       dow (entryPtr <> *null);
166500120130
166600120130         if (prettyPrintOption);
166700120130           prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
166800120130         endif;
166900120130
167000120130         // add key as token to token list
167100120130         arraylist_add(tokenList : %addr(l_chars.d_quote) :
167200120130                       l_chars.size_d_quote);
167300120130         arraylist_add(tokenList : entry.key : entry.keyLength -1);
167400120130         arraylist_add(tokenList : %addr(l_chars.d_quote) :
167500120130                       l_chars.size_d_quote);
167600120130
167700120130         // add key/value separator
167800120130         arraylist_add(tokenList : %addr(l_chars.colon) : l_chars.size_colon);
167900120130
168000120130         select;
168100120130           when (entry.type = JSON_TYPE_STRING);
168200120130             arraylist_add(tokenList : %addr(l_chars.d_quote) :
168300120130                           l_chars.size_d_quote);
168400120130             // +1 weil das null byte schon beim hinzufügen des wertes hinzugefügt wurde
168500120130             arraylist_add(tokenList : entry.value : entry.valueLength + 1);
168600120130             escapeLastToken(tokenList);
168700120130             arraylist_add(tokenList : %addr(l_chars.d_quote) :
168800120130                           l_chars.size_d_quote);
168900120130
169000120130           when (entry.type = JSON_TYPE_INT);
169100120130             tmpString = %char(tmpInt);
169200120130             tmpLength = %len(%trimr(tmpString));
169300120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
169400120130
169500120130           when (entry.type = JSON_TYPE_LONG);
169600120130             tmpString = %char(tmpLong);
169700120130             tmpLength = %len(%trimr(tmpString));
169800120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
169900120130
170000120130           when (entry.type = JSON_TYPE_DOUBLE);
170100120130             tmpString = %triml(%char(tmpDouble):'+');
170200120130             tmpLength = %len(%trimr(tmpString));
170300120130             // JSON Syntax erwartet immer ein . als Trennzeichen (und kein ,)
170400120130             tmpString = %xlate(',' : '.' : tmpString);
170500120130             arraylist_add(tokenList : %addr(tmpString) : tmpLength);
170600120130
170700120130           when (entry.type = JSON_TYPE_BOOLEAN);
170800120130             if (tmpBoolean);
170900120130               arraylist_add(tokenList : %addr(l_chars.true) :
171000120130                             l_chars.size_true);
171100120130             else;
171200120130               arraylist_add(tokenList : %addr(l_chars.false) :
171300120130                             l_chars.size_false);
171400120130             endif;
171500120130
171600120130           when (entry.type = JSON_TYPE_ARRAY);
171700120130             ptr = jsona_toString(entry.value : outputFormat:prettyPrintFormat:
171800120130                                  indentationLevel);
171900120130             arraylist_add(tokenList : ptr : strlen(ptr));
172000120130             dealloc(n) ptr;
172100120130
172200120130           when (entry.type = JSON_TYPE_OBJECT);
172300120130             ptr = json_toString(entry.value : outputFormat : prettyPrintFormat:
172400120130                                 indentationLevel);
172500120130             arraylist_add(tokenList : ptr : strlen(ptr));
172600120130
172700120130           when (entry.type = JSON_TYPE_NULL);
172800120130             arraylist_add(tokenList : %addr(l_chars.null_str) :
172900120130                           l_chars.size_null_str);
173000120130
173100120130         endsl;
173200120130
173300120130
173400120130         // komma hinzufügen falls es nicht der letzte eintrag ist
173500120130         if (entryPtr <> header.lastEntry);
173600120130           arraylist_add(tokenList : %addr(l_chars.comma) : l_chars.size_comma);
173700120130
173800120130           if (prettyPrintOption and prettyPrintFormat.breakAfterElement);
173900120130             arraylist_add(tokenList : %addr(newline) : %size(newline));
174000120130           endif;
174100120130         endif;
174200120130
174300120130         // nächsten eintrag
174400120130         entryPtr = entry.next;
174500120130       enddo;
174600120130
174700120130       if (prettyPrintOption);
174800120130         if (prettyPrintFormat.breakAfterObjectBrace);
174900120130           arraylist_add(tokenList : %addr(newline) : %size(newline));
175000120130           indentationLevel -= 1;
175100120130         endif;
175200120130         prettyPrint(tokenList : prettyPrintFormat : indentationLevel);
175300120130       endif;
175400120130
175500120130       // endezeichen schreiben falls einträge vorhanden
175600120130       arraylist_add(tokenList : %addr(l_chars.r_brace) : l_chars.size_r_brace);
175700120130
175800120130       //  json string länge ermitteln
175900120130       // calculate json string length
176000120130       size = %int(arraylist_getSize(tokenList)) - 1;
176100120130       for i = 0 to size;
176200120130         ptr = arraylist_get(tokenList : i);
176300120130         json_string_length += strlen(ptr);
176400120130       endfor;
176500120130       // +1 für hex Null
176600120130       json_string_length += 1;
176700120130
176800120130       // speicher für json string reservieren
176900120130       json_string_ptr = %alloc(json_string_length);
177000120130
177100120130       // build json string
177200120130       size = %int(arraylist_getSize(tokenList)) - 1;
177300120130       for i = 0 to size;
177400120130         ptr = arraylist_get(tokenList : i);
177500120130         tmpLength = strlen(ptr);
177600120130         memcpy(json_string_ptr + x : ptr : tmpLength);
177700120130         x += tmpLength;
177800120130       endfor;
177900120130
178000120130       // hex Null anhängen
178100120130       memcpy(json_string_ptr + x : %addr(hexNull) : 1);
178200120130
178300120130       // aufräumen
178400120130       if (tokenList <> *null);
178500120130         arraylist_dispose(tokenList);
178600120130       endif;
178700120130
178800120130       // register allocated memory at the dispose list
178900120130       if (json_string_ptr <> *null);
179000120130         arraylist_add(header.disposeList : %addr(json_string_ptr) :
179100120130                       %size(json_string_ptr));
179200120130       endif;
179300120130
179400120130       return json_string_ptr;
179500120130
179600120130       begsr init;
179700120130         if (outputFormat = JSON_OUTPUT_COMPACT);
179800120130           l_chars = chars_compact;
179900120130         else;
180000120130           l_chars = chars;
180100120130         endif;
180200120130       endsr;
180300120130      /end-free
180400120130     P                 E
180500120130
180600120130
180700120130     /**
180800120130      * \brief Add null value entry
180900120130      *
181000120130      * Adds an entry of type null to the array.
181100120130      *
181200120130      * \author Mihael Schmidt
181300120130      * \date   11.05.2008
181400120130      *
181500120130      * \param Pointer to the JSON array
181600120130      * \param Key
181700120130      */
181800120130     P json_putNull    B                   export
181900120130     D                 PI                  opdesc
182000120130     D   jsonPtr                       *   const
182100120130     D   key                      65535A   const options(*varsize)
182200120130      *
182300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
182400120130     D prevEntryPtr    S               *
182500120130     D prevEntry       DS                  likeds(tmpl_entry)
182600120130     D                                     based(prevEntryPtr)
182700120130     D newEntryPtr     S               *
182800120130     D newEntry        DS                  likeds(tmpl_entry)
182900120130     D                                     based(newEntryPtr)
183000120130     D tmpPtr          S               *
183100120130     D tmpKey          S          65535A
183200120130     D keyLength       S             10I 0
183300120130      /free
183400120130       isJSONImpl(jsonPtr);
183500120130
183600120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
183700120130                         length : *omit);
183800120130       keyLength = length;
183900120130       tmpKey = %subst(key : 1 : keyLength);
184000120130
184100120130       // check if key is in already in the map
184200120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
184300120130       if (newEntryPtr = *null);    // entry not in json object
184400120130         // create new entry
184500120130         newEntryPtr = %alloc(%size(tmpl_entry));
184600120130         newEntry.type = JSON_TYPE_NULL;
184700120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
184800120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
184900120130         newEntry.valueLength = 0;
185000120130         newEntry.value = *null;
185100120130         newEntry.next = *null;
185200120130         newEntry.prev = *null;
185300120130
185400120130         // update header
185500120130         header.size += 1;
185600120130         if (header.firstEntry = *null);
185700120130           header.firstEntry = newEntryPtr;
185800120130         else;
185900120130           prevEntryPtr = header.lastEntry;
186000120130           prevEntry.next = newEntryPtr;
186100120130           newEntry.prev = prevEntryPtr;
186200120130         endif;
186300120130         header.lastEntry = newEntryPtr;
186400120130
186500120130       else;
186600120130         // entry needs to be resized
186700120130         newEntry.type = JSON_TYPE_NULL;
186800120130         newEntry.keyLength = keyLength + 1;
186900120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
187000120130         newEntry.valueLength = 0;
187100120130
187200120130         // dispose/dealloc old value
187300120130         disposeEntryValue(newEntryPtr);
187400120130       endif;
187500120130
187600120130
187700120130       // copy key/value to the list entry
187800120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
187900120130
188000120130       // set null to the last byte
188100120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
188200120130      /end-free
188300120130     P                 E
188400120130
188500120130
188600120130     /**
188700120130      * \brief Add JSON object entry
188800120130      *
188900120130      * Adds an entry of type object to the array.
189000120130      *
189100120130      * \author Mihael Schmidt
189200120130      * \date   11.05.2008
189300120130      *
189400120130      * \param Pointer to the JSON array
189500120130      * \param Key
189600120130      * \param Pointer to the JSON object
189700120130      */
189800120130     P json_putObject...
189900120130     P                 B                   export
190000120130     D                 PI                  opdesc
190100120130     D   jsonPtr                       *   const
190200120130     D   key                      65535A   const options(*varsize)
190300120130     D   objPtr                        *   const
190400120130      *
190500120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
190600120130     D prevEntryPtr    S               *
190700120130     D prevEntry       DS                  likeds(tmpl_entry)
190800120130     D                                     based(prevEntryPtr)
190900120130     D newEntryPtr     S               *
191000120130     D newEntry        DS                  likeds(tmpl_entry)
191100120130     D                                     based(newEntryPtr)
191200120130     D tmpKey          S          65535A
191300120130     D keyLength       S             10I 0
191400120130      /free
191500120130       isJSONImpl(jsonPtr);
191600120130
191700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
191800120130                         length : *omit);
191900120130       keyLength = length;
192000120130       tmpKey = %subst(key : 1 : keyLength);
192100120130
192200120130       // check if key is in already in the map
192300120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
192400120130       if (newEntryPtr = *null);    // entry not in json object
192500120130         // create new entry
192600120130         newEntryPtr = %alloc(%size(tmpl_entry));
192700120130         newEntry.type = JSON_TYPE_OBJECT;
192800120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
192900120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
193000120130         newEntry.valueLength = 0;
193100120130         newEntry.value = *null;
193200120130         newEntry.next = *null;
193300120130         newEntry.prev = *null;
193400120130
193500120130         // update header
193600120130         header.size += 1;
193700120130         if (header.firstEntry = *null);
193800120130           header.firstEntry = newEntryPtr;
193900120130         else;
194000120130           prevEntryPtr = header.lastEntry;
194100120130           prevEntry.next = newEntryPtr;
194200120130           newEntry.prev = prevEntryPtr;
194300120130         endif;
194400120130         header.lastEntry = newEntryPtr;
194500120130
194600120130       else;
194700120130         // entry needs to be resized
194800120130         newEntry.type = JSON_TYPE_OBJECT;
194900120130         newEntry.keyLength = keyLength + 1;
195000120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
195100120130         newEntry.valueLength = 0;
195200120130
195300120130         // dispose/dealloc old value
195400120130         disposeEntryValue(newEntryPtr);
195500120130       endif;
195600120130
195700120130       // copy key and value to entry
195800120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
195900120130       newEntry.value = objPtr;
196000120130
196100120130       // set null to the last byte
196200120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
196300120130      /end-free
196400120130     P                 E
196500120130
196600120130
196700120130     /**
196800120130      * \brief Get object entry
196900120130      *
197000120130      * Returns a pointer to the object.
197100120130      *
197200120130      * <br><br>
197300120130      *
197400120130      * If the entry is not of type object an escape message will be send.
197500120130      *
197600120130      * \author Mihael Schmidt
197700120130      * \date   11.05.2008
197800120130      *
197900120130      * \param Pointer to the JSON array
198000120130      * \param Index
198100120130      *
198200120130      * \return Pointer to the JSON object
198300120130      */
198400120130     P json_getObject...
198500120130     P                 B                   export
198600120130     D                 PI              *   opdesc
198700120130     D   jsonPtr                       *   const
198800120130     D   key                      65535A   const options(*varsize)
198900120130      *
199000120130     D tmpKey          S          65535A
199100120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
199200120130     D entryPtr        S               *
199300120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
199400120130     D retVal          S               *
199500120130      /free
199600120130       isJSONImpl(jsonPtr);
199700120130
199800120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
199900120130                         length : *omit);
200000120130       tmpKey = %subst(key : 1 : length);
200100120130
200200120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
200300120130       if (entryPtr <> *null);
200400120130         if (entry.type = JSON_TYPE_OBJECT);
200500120130           retVal = entry.value;
200600120130         else;
200700120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
200800120130         endif;
200900120130       endif;
201000120130
201100120130       return retVal;
201200120130      /end-free
201300120130     P                 E
201400120130
201500120130
201600120130     /**
201700120130      * \brief Get entry type
201800120130      *
201900120130      * Returns the type of the entry.
202000120130      *
202100120130      * \param Pointer to the JSON object
202200120130      * \param Key
202300120130      *
202400120130      * \return Entry type
202500120130      */
202600120130     P json_getEntryType...
202700120130     P                 B                   export
202800120130     D                 PI            10I 0 opdesc
202900120130     D   jsonPtr                       *   const
203000120130     D   key                      65535A   const options(*varsize)
203100120130      *
203200120130     D tmpKey          S          65535A
203300120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
203400120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
203500120130     D type            S             10I 0
203600120130      /free
203700120130       isJSONImpl(jsonPtr);
203800120130
203900120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
204000120130                         length : *omit);
204100120130
204200120130       tmpKey = %subst(key : 1 : length);
204300120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
204400120130       if (entryPtr <> *null);
204500120130         type = entry.type;
204600120130       else;
204700120130         sendEscapeMessage(MSG_ENTRY_NOT_FOUND);
204800120130       endif;
204900120130
205000120130       return type;
205100120130      /end-free
205200120130     P                 E
205300120130
205400120130
205500120130     /**
205600120130      * \brief Checks if entry is of special type null
205700120130      *
205800120130      * \param Pointer to the JSON object
205900120130      * \param Key
206000120130      *
206100120130      * \return *on = entry is of type null <br>
206200120130      *         *off = entry is of another type
206300120130      */
206400120130     P json_isNull     B                   export
206500120130     D                 PI              N   opdesc
206600120130     D   jsonPtr                       *   const
206700120130     D   key                      65535A   const options(*varsize)
206800120130      *
206900120130     D tmpKey          S          65535A
207000120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
207100120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
207200120130      /free
207300120130       isJSONImpl(jsonPtr);
207400120130
207500120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
207600120130                         length : *omit);
207700120130
207800120130       tmpKey = %subst(key : 1 : length);
207900120130       entryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : length);
208000120130       if (entryPtr <> *null);
208100120130         return (entry.type = JSON_TYPE_NULL);
208200120130       else;
208300120130         sendEscapeMessage(MSG_ENTRY_NOT_FOUND);
208400120130         return *off; // dummy
208500120130       endif;
208600120130      /end-free
208700120130     P                 E
208800120130
208900120130
209000120130     /**
209100120130      * \brief Check for JSON object
209200120130      *
209300120130      * Checks if the passed pointer points to a JSON object.
209400120130      *
209500120130      * <br><br>
209600120130      *
209700120130      * If the pointer does not point to a JSON object and escape message will
209800120130      * be send to the next entry in the call stack.
209900120130      *
210000120130      * \author Mihael Schmidt
210100120130      * \date   20.03.2008
210200120130      *
210300120130      * \param Pointer to the JSON object
210400120130      */
210500120130     P isJSONImpl...
210600120130     P                 B                   export
210700120130     D                 PI
210800120130     D   jsonPtr                       *   const
210900120130      *
211000120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
211100120130      /free
211200120130       monitor;
211300120130         if (header.id <> JSON_ID);
211400120130           sendEscapeMessage(MSG_NO_JSON_OBJECT);
211500120130         endif;
211600120130
211700120130         on-error *all;
211800120130           sendEscapeMessage(MSG_NO_JSON_OBJECT);
211900120130       endmon;
212000120130      /end-free
212100120130     P                 E
212200120130
212300120130
212400120130     /**
212500120130      * \brief Send escape message
212600120130      *
212700120130      * A wrapper for the i5/OS API QMHSNDPM.
212800120130      *
212900120130      * \author Mihael Schmidt
213000120130      * \date   20.03.2008
213100120130      *
213200120130      * \param Message id
213300120130      */
213400120130     P sendEscapeMessage...
213500120130     P                 B                   export
213600120130     D                 PI
213700120130     D   id                          10I 0 const
213800120130      *
213900120130     D sendProgramMessage...
214000120130     D                 PR                  extpgm('QMHSNDPM')
214100120130     D  szMsgID                       7A   const
214200120130     D  szMsgFile                    20A   const
214300120130     D  szMsgData                  6000A   const  options(*varsize)
214400120130     D  nMsgDataLen                  10I 0 const
214500120130     D  szMsgType                    10A   const
214600120130     D  szCallStkEntry...
214700120130     D                               10A   const
214800120130     D  nRelativeCallStkEntry...
214900120130     D                               10I 0 const
215000120130     D  szRtnMsgKey                   4A
215100120130     D  error                       265A   options(*varsize)
215200120130      *
215300120130     D msgdata         S            512A
215400120130     D msgkey          S              4A
215500120130      /free
215600120130       if (id = MSG_NO_JSON_OBJECT);
215700120130         msgdata = 'The pointer does not point to a JSON object data structure';
215800120130       elseif (id = MSG_ENTRY_TYPE_MISMATCH);
215900120130         msgdata = 'The entry type does not match with the expected type.';
216000120130       elseif (id = MSG_ARRAY_ELEMENT_NOT_FOUND);
216100120130         msgdata = 'The specified array element was not found in the array.';
216200120130       elseif (id = MSG_TYPE_CAST_EXCEPTION);
216300120130         msgdata = 'The specified entry could not be cast to the requested ' +
216400120130                   'type.';
216500120130       else;
216600120130         return;
216700120130       endif;
216800120130
216900120130       clear QUSEC;
217000120130       QUSBPRV = 0;
217100120130       sendProgramMessage('CPF9898' :
217200120130                          'QCPFMSG   *LIBL     ' :
217300120130                          %trimr(msgdata) :
217400120130                          %len(%trimr(msgdata)) :
217500120130                          '*ESCAPE   ' :
217600120130                          '*PGMBDY' :
217700120130                          0 :
217800120130                          msgkey :
217900120130                          QUSEC);
218000120130      /end-free
218100120130     P                 E
218200120130
218300120130
218400120130     /**
218500120130      * \brief Get entry by key
218600120130      *
218700120130      * Returns a pointer to the entry data structure for the passed key.
218800120130      *
218900120130      * \param Pointer to the JSON object
219000120130      * \param Pointer to the key
219100120130      * \param Key length
219200120130      *
219300120130      * \return Pointer to the entry or *null if no such entry exists in this
219400120130      *         JSON object.
219500120130      */
219600120130     P getJSONEntry    B                   export
219700120130     D                 PI              *
219800120130     D  jsonPtr                        *   const
219900120130     D  keyPtr                         *   const
220000120130     D  keyLength                    10U 0 const
220100120130      *
220200120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
220300120130     D entryPtr        S               *
220400120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
220500120130     D retVal          S               *   inz(*null)
220600120130      /free
220700120130       entryPtr = header.firstEntry;
220800120130
220900120130       dow (entryPtr <> *null);
221000120130
221100120130         if (keyLength = entry.keyLength - 1 and
221200120130             memcmp(keyPtr : entry.key : keyLength) = 0); // dont include the null
221300120130           retVal = entryPtr;
221400120130           leave;
221500120130         endif;
221600120130
221700120130         entryPtr = entry.next;
221800120130       enddo;
221900120130
222000120130       return retVal;
222100120130      /end-free
222200120130     P                 E
222300120130
222400120130
222500120130     /**
222600120130      * \brief Escape characters
222700120130      *
222800120130      * Double quotes and backslashes must be escape in string values to
222900120130      * comply to the JSON specs.
223000120130      *
223100120130      * <br><br>
223200120130      *
223300120130      * The last element of the token list will be checked for characters
223400120130      * which need to be escaped.
223500120130      *
223600120130      * \author Mihael Schmidt
223700120130      * \date   20.03.2008
223800120130      *
223900120130      * \param Pointer to token list
224000120130      */
224100120130     P escapeLastToken...
224200120130     P                 B                   export
224300120130     D                 PI
224400120130     D   tokenList                     *
224500120130      *
224600120130     D ptr             S               *
224700120130     D length          S             10I 0
224800120130     D backslash       S              1A   inz('\')
224900120130     D newPtr          S               *
225000120130     D newLength       S             10I 0
225100120130     D newCurLength    S             10I 0
225200120130     D i               S             10I 0
225300120130     D x               S             10I 0
225400120130     D iPtr            S               *
225500120130     D char            S              1A   based(iPtr)
225600120130      /free
225700120130       ptr = arraylist_getLast(tokenList);
225800120130       length = strlen(ptr);
225900120130       newLength = length;
226000120130
226100120130       // number of character to be escaped
226200120130       for i = 0 to length - 1;
226300120130         iPtr = ptr + i;
226400120130         if (char = '\' or char = '"');
226500120130           newLength += 1;
226600120130         endif;
226700120130       endfor;
226800120130
226900120130       // check if there are any characters which need to be escaped
227000120130       if (newLength <> length);
227100120130         newPtr = %alloc(newLength);
227200120130
227300120130         for i = 0 to length - 1;
227400120130           iPtr = ptr + i;
227500120130           if (char = '\' or char = '"');
227600120130             memcpy(newPtr + newCurLength : ptr + x : i - x);
227700120130             newCurLength += i - x;
227800120130             // copy escape character
227900120130             memcpy(newPtr + newCurLength : %addr(backslash) : 1);
228000120130             newCurLength += 1;
228100120130
228200120130             x = i; // save last position
228300120130           endif;
228400120130         endfor;
228500120130
228600120130         // copy the rest of the string
228700120130         memcpy(newPtr + newCurLength : ptr + x : i - x + 1);
228800120130         newCurLength += i - x;
228900120130
229000120130         // replace value in token list
229100120130         arraylist_removeLast(tokenList);
229200120130         arraylist_add(tokenList : newPtr : newCurLength);
229300120130
229400120130         dealloc(n) newPtr;
229500120130       endif;
229600120130      /end-free
229700120130     P                 E
229800120130
229900120130
230000120130     /**
230100120130      * \brief Dealloc entry value
230200120130      *
230300120130      * The value of an entry is deallocated. If the entry is of
230400120130      * type object or array it must be disposed.
230500120130      *
230600120130      * \author Mihael Schmidt
230700120130      * \date   14.05.2008
230800120130      *
230900120130      * \param Pointer to an entry
231000120130      */
231100120130     P disposeEntryValue...
231200120130     P                 B                   export
231300120130     D                 PI
231400120130     D   entryPtr                      *
231500120130      *
231600120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
231700120130      /free
231800120130       if (entry.type = JSON_TYPE_ARRAY);
231900120130         jsona_dispose(entry.value);
232000120130       elseif (entry.type = JSON_TYPE_OBJECT);
232100120130         json_dispose(entry.value);
232200120130       elseif (entry.type = JSON_TYPE_NULL);
232300120130         // do nothing, entry is already *null
232400120130       elseif (entry.value <> *null);
232500120130         dealloc(n) entry.value;
232600120130       endif;
232700120130      /end-free
232800120130     P                 E
232900120130
233000120130
233100120130     /**
233200120130      * \brief Send diagnostic message
233300120130      *
233400120130      * Sends a diagnostic message to the call stack
233500120130      * (one level above this one).
233600120130      *
233700120130      * \author Mihael Schmidt
233800120130      * \date   07.03.2009
233900120130      *
234000120130      * \param Message
234100120130      */
234200120130     P sendDiagnosticMessage...
234300120130     P                 B                   export
234400120130     D                 PI
234500120130     D   message                    200A   const
234600120130      *
234700120130     D sendProgramMessage...
234800120130     D                 PR                  extpgm('QMHSNDPM')
234900120130     D  szMsgID                       7A   const
235000120130     D  szMsgFile                    20A   const
235100120130     D  szMsgData                  6000A   const  options(*varsize)
235200120130     D  nMsgDataLen                  10I 0 const
235300120130     D  szMsgType                    10A   const
235400120130     D  szCallStkEntry...
235500120130     D                               10A   const
235600120130     D  nRelativeCallStkEntry...
235700120130     D                               10I 0 const
235800120130     D  szRtnMsgKey                   4A
235900120130     D  error                       265A   options(*varsize)
236000120130      *
236100120130     D msgdata         S            512A
236200120130     D msgkey          S              4A
236300120130      /free
236400120130       msgdata = message;
236500120130
236600120130       clear QUSEC;
236700120130       QUSBPRV = 0;
236800120130       sendProgramMessage(*blank :
236900120130                          *blank :
237000120130                          %trimr(msgdata) :
237100120130                          %len(%trimr(msgdata)) :
237200120130                          '*DIAG' :
237300120130                          '*PGMBDY' :
237400120130                          0 :
237500120130                          msgkey :
237600120130                          QUSEC);
237700120130      /end-free
237800120130     P                 E
237900120130
238000120130
238100120130     P prettyPrint     B                   export
238200120130     D                 PI
238300120130     D   tokenList                     *   const
238400120130     D   printFormat                       const likeds(json_prettyPrintFormat)
238500120130     D   indentationLevel...
238600120130     D                               10I 0 const
238700120130      *
238800120130     D indentSpace     S           1000A   static inz
238900120130     D indentTab       S           1000A   static inz(*ALLx'05')
239000120130      /free
239100120130       if (printFormat.useTabs);
239200120130         arraylist_add(tokenList : %addr(indentTab) :
239300120130                  indentationLevel * printFormat.numberWhitespace);
239400120130       else;
239500120130         arraylist_add(tokenList : %addr(indentSpace) :
239600120130                  indentationLevel * printFormat.numberWhitespace);
239700120130       endif;
239800120130      /end-free
239900120130     P                 E
240000120130
240100120130
