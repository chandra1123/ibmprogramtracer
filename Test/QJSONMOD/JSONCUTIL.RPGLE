000100120130     /**
000200120130      * \brief JSON : Checker Utilities
000300120130      *
000400120130      * Utility module for validating string for the JSON syntax.
000500120130      * The strings are converted from the passed or Job ccsid to
000600120130      * ASCII (ccsid 819). Comments before, inline and after the JSON
000700120130      * string are not supported.
000800120130      *
000900120130      * \author Mihael Schmidt
001000120130      * \date   2009-02-28
001100120130      *
001200120130      * \link http://www.json.org/JSON_checker/ JSON Checker
001300120130      */
001400120130
001500120130      *-------------------------------------------------------------------------
001600120130      * And thanks to Scott Klement for his excellent tutorials about IFS and
001700120130      * iconv() at http://www.scottklement.com .
001800120130      *-------------------------------------------------------------------------
001900120130
002000120130      *-------------------------------------------------------------------------
002100120130      * Copyright (c) 2007-2009 Mihael Schmidt
002200120130      * All rights reserved.
002300120130      *
002400120130      * This file is part of the JSON service program.
002500120130      *
002600120130      * JSON service program is free software: you can redistribute it and/or modify it under
002700120130      * the terms of the GNU Lesser General Public License as published by
002800120130      * the Free Software Foundation, either version 3 of the License, or
002900120130      * any later version.
003000120130      *
003100120130      * JSON service program is distributed in the hope that it will be useful,
003200120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
003300120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
003400120130      * GNU Lesser General Public License for more details.
003500120130      *
003600120130      * You should have received a copy of the GNU Lesser General Public
003700120130      * License along with JSON service program.  If not, see http://www.gnu.org/licenses/.
003800120130      *-------------------------------------------------------------------------
003900120130
004000120130     H nomain
004100120130     H bnddir('QC2LE')
004200120130     H copyright('Copyright (c) 2007-2009 Mihael Schmidt. All rights reserved.')
004300120130
004400120130
004500120130      *------------------------------------------------------------------------
004600120130      * Prototypes
004700120130      *------------------------------------------------------------------------
004800120130      /include qjsontxt,json
004900120130      /include qjsontxt,jsonint
005000120130      /include qjsontxt,iconv
005100120130      /include qjsontxt,ifsio
005200120130      /include qjsontxt,libc
005300120130      /include qjsontxt,ceeapi
005400120130
005500120130
005600120130      *-------------------------------------------------------------------------
005700120130      * Global Variables
005800120130      *-------------------------------------------------------------------------
005900120130      *
006000120130      * Parameters passed to CEEDOD
006100120130      *
006200120130     D cee_descType    S             10I 0
006300120130     D cee_dataType    S             10I 0
006400120130     D cee_descInfo1   S             10I 0
006500120130     D cee_descInfo2   S             10I 0
006600120130     D cee_length      S             10I 0
006700120130      *
006800120130     D true            S             10I 0 inz(1)
006900120130     D false           S             10I 0 inz(0)
007000120130
007100120130      *------------------------------------------------------------------------
007200120130      * Procedures
007300120130      *------------------------------------------------------------------------
007400120130
007500120130     /**
007600120130      * \brief Validate JSON string
007700120130      *
007800120130      * Validates the passed JSON string.
007900120130      *
008000120130      * \author Mihael Schmidt
008100120130      *
008200120130      * \param JSON string
008300120130      * \param CCSID from the source string (default: 0 = Job CCSID)
008400120130      *
008500120130      * \return *on = valid JSON string <br>
008600120130      *         *off = invalid JSON string
008700120130      */
008800120130     P json_validate   B                   export
008900120130     D                 PI              N   opdesc
009000120130     D   string                   65535A   const options(*varsize)
009100120130     D   ccsid                       10I 0 const options(*nopass)
009200120130      *
009300120130     D iconv_table     DS                  likeds(iconv_t)
009400120130     D json_string_ptr...
009500120130     D                 S               *
009600120130     D json_string     S          65535A
009700120130     D json_string_length...
009800120130     D                 S             10U 0
009900120130     D json_checker_ptr...
010000120130     D                 S               *
010100120130     D json_checker    DS                  likeds(tmpl_json_checker)
010200120130     D                                     based(json_checker_ptr)
010300120130      *
010400120130     D conv_ds         DS
010500120130     D unsInt                        10U 0 inz(0)
010600120130     D char                           1A   overlay(unsInt : 4)
010700120130      *
010800120130     D tmpLength       S             10U 0
010900120130     D i               S             10I 0
011000120130     D valid           S               N   inz(*on)
011100120130      /free
011200120130       cee_getOpDescInfo(1 : cee_descType : cee_dataType : cee_descInfo1 :
011300120130                         cee_descInfo2 : cee_length : *omit);
011400120130       json_string = %trim(%subst(string : 1 : cee_length)) + x'00';
011500120130       json_string_ptr = %addr(json_string);
011600120130       json_string_length = strlen(json_string_ptr);
011700120130       tmpLength = json_string_length;
011800120130
011900120130       if (%parms() = 2);
012000120130         iconv_from.ccsid = ccsid;
012100120130       else;
012200120130         iconv_from.ccsid = 0;
012300120130       endif;
012400120130
012500120130       //
012600120130       // translate the string from the current job ccsid (or passed ccsid)
012700120130       // to ascii (819) because the checker only understands ascii
012800120130       //
012900120130       iconv_table = iconv_open(iconv_to : iconv_from);
013000120130       if (iconv_table.return_value <> -1);
013100120130
013200120130         if (iconv(iconv_table :
013300120130                   json_string_ptr : tmpLength :
013400120130                   json_string_ptr : tmpLength) <> -1);
013500120130
013600120130           // create json checker
013700120130           json_checker_ptr = json_new_checker(99);
013800120130
013900120130           // check string char by char
014000120130           for i = 1 to json_string_length;
014100120130             char =  %subst(json_string : i : 1);
014200120130             if (json_checker_char(json_checker_ptr : unsInt) = false);
014300120130               sendDiagnosticMessage('JSON checker aborted at position ' +
014400120130                     %char(i) + '.');
014500120130               valid = *off;
014600120130               leave;
014700120130             endif;
014800120130           endfor;
014900120130
015000120130           // free memory
015100120130           if (valid and json_checker_done(json_checker_ptr) = true);
015200120130             valid = *on;
015300120130           endif;
015400120130
015500120130         else;
015600120130           sendDiagnosticMessage('Could not translate buffer from ccsid ' +
015700120130                %char(iconv_from.ccsid) + ' to ccsid ' +
015800120130                %char(iconv_to.ccsid) + '.');
015900120130           valid = *off;
016000120130         endif;
016100120130
016200120130         // cleanup
016300120130         iconv_close(iconv_table);
016400120130
016500120130       else;
016600120130         sendDiagnosticMessage('Could not init iconv.');
016700120130         valid = *off;
016800120130       endif;
016900120130
017000120130       return valid;
017100120130      /end-free
017200120130     P                 E
017300120130
017400120130
017500120130     /**
017600120130      * \brief Validate JSON file
017700120130      *
017800120130      * Validates the JSON string in the passed file. The file should only
017900120130      * contain the JSON string. Comments are not supported.
018000120130      *
018100120130      * \author Mihael Schmidt
018200120130      *
018300120130      * \param IFS file path
018400120130      * \param CCSID from the source string (default: 0 = Job CCSID)
018500120130      *
018600120130      * \return *on = valid JSON string <br>
018700120130      *         *off = invalid JSON string
018800120130      */
018900120130     P json_validateFile...
019000120130     P                 B                   export
019100120130     D                 PI              N   opdesc
019200120130     D   path                     65535A   const options(*varsize)
019300120130     D   ccsid                       10I 0 const options(*nopass)
019400120130      *
019500120130      * file stuff
019600120130      *
019700120130     D filePath        S          65535A
019800120130     D fd              S             10I 0
019900120130     D dataPtr         S               *
020000120130     D data            S           1024A   inz
020100120130     D length          S             10I 0
020200120130      *
020300120130      * translation stuff
020400120130      *
020500120130     D iconv_table     DS                  likeds(iconv_t)
020600120130     D json_string_ptr...
020700120130     D                 S               *
020800120130     D json_string     S          65535A
020900120130     D json_checker_ptr...
021000120130     D                 S               *
021100120130     D json_checker    DS                  likeds(tmpl_json_checker)
021200120130     D                                     based(json_checker_ptr)
021300120130      *
021400120130     D conv_ds         DS
021500120130     D unsInt                        10U 0 inz(0)
021600120130     D char                           1A   overlay(unsInt : 4)
021700120130      *
021800120130     D tmpLength       S             10U 0
021900120130     D i               S             10I 0
022000120130     D valid           S               N   inz(*on)
022100120130      /free
022200120130       cee_getOpDescInfo(1 : cee_descType : cee_dataType : cee_descInfo1 :
022300120130                         cee_descInfo2 : cee_length : *omit);
022400120130       filePath = %trim(%subst(path : 1 : cee_length)) + x'00';
022500120130       json_string_ptr = %addr(json_string);
022600120130       dataPtr = %addr(data);
022700120130
022800120130       fd = open(filePath : O_RDONLY + O_TEXTDATA);
022900120130       if (fd >= 0);
023000120130
023100120130         if (%parms() = 2);
023200120130           iconv_from.ccsid = ccsid;
023300120130         else;
023400120130           iconv_from.ccsid = 0;
023500120130         endif;
023600120130
023700120130         // create json checker
023800120130         json_checker_ptr = json_new_checker(99);
023900120130
024000120130         //
024100120130         // translate the string from the current job ccsid (or passed ccsid)
024200120130         // to ascii (819) because the checker only understands ascii
024300120130         //
024400120130         iconv_table = iconv_open(iconv_to : iconv_from);
024500120130         if (iconv_table.return_value <> -1);
024600120130
024700120130           length = read(fd : dataPtr : %size(data));
024800120130           dow (length >= 1 and valid);
024900120130             tmpLength = length;
025000120130
025100120130             if (iconv(iconv_table :
025200120130                     dataPtr : tmpLength :
025300120130                     json_string_ptr : tmpLength) <> -1);
025400120130
025500120130
025600120130               // check string char by char
025700120130               for i = 1 to length;
025800120130                 char =  %subst(json_string : i : 1);
025900120130                 if (json_checker_char(json_checker_ptr : unsInt) = false);
026000120130                   sendDiagnosticMessage('JSON checker aborted at position ' +
026100120130                         %char(i) + '.');
026200120130                   valid = *off;
026300120130                   leave;
026400120130                 endif;
026500120130               endfor;
026600120130
026700120130             else;
026800120130               sendDiagnosticMessage('Could not translate buffer from ccsid ' +
026900120130                    %char(iconv_from.ccsid) + ' to ccsid ' +
027000120130                    %char(iconv_to.ccsid) + '.');
027100120130               valid = *off;
027200120130             endif;
027300120130
027400120130             length = read(fd : dataPtr : %size(data));
027500120130           enddo;
027600120130
027700120130         else;
027800120130           sendDiagnosticMessage('Could not init iconv.');
027900120130           valid = *off;
028000120130         endif;
028100120130
028200120130         // free memory
028300120130         if (not valid or json_checker_done(json_checker_ptr) = false);
028400120130           valid = *off;
028500120130         endif;
028600120130
028700120130         // cleanup
028800120130         iconv_close(iconv_table);
028900120130         callp close(fd);
029000120130
029100120130       else;
029200120130         sendDiagnosticMessage('Could not open file ' + %trim(filePath) + '.');
029300120130         valid = *off;
029400120130       endif;
029500120130
029600120130       return valid;
029700120130      /end-free
029800120130     P                 E
