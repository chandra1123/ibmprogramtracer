000100120130     /**
000200120130      * \brief JSON : Utilities
000300120130      *
000400120130      * Utilities module for the JSON service program.
000500120130      *
000600120130      * \author Mihael Schmidt
000700120130      * \date   31.01.2010
000800120130      *
000900120130      * \link http://www.rpgnextgen.com RPG Next Gen
001000120130      * \link http://www.json.org JSON
001100120130      *
001200120130      * \todo json_util_dataStructureToJsonObject : pointer to datastructure as parm
001300120130      *
001400120130      * \rev 01.08.2010 Mihael Schmidt
001500120130      *      added date data type support
001600120130      *
001700120130      * \rev 26.11.2010 Mihael Schmidt
001800120130      *      added toFile/fromFile procedures
001900120130      *
002000120130      * \rev 09.04.2011 Mihael Schmidt
002100120130      *      added decimal data type support
002200120130      *
002300120130      * \rev 06.05.2011 Mihael Schmidt
002400120130      *      Switch from Linked List to ArrayList
002500120130      *
002600120130      * \rev 24.06.2011 Brian Garland
002700120130      *      added time and timestamp procedures,
002800120130      *      added dataStructure to JSON object procedure
002900120130      */
003000120130
003100120130      *-------------------------------------------------------------------------
003200120130      * Copyright (c) 2010-2011 Mihael Schmidt
003300120130      * All rights reserved.
003400120130      *
003500120130      * This file is part of the JSON service program.
003600120130      *
003700120130      * JSON service program is free software: you can redistribute it and/or modify it under
003800120130      * the terms of the GNU Lesser General Public License as published by
003900120130      * the Free Software Foundation, either version 3 of the License, or
004000120130      * any later version.
004100120130      *
004200120130      * JSON service program is distributed in the hope that it will be useful,
004300120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
004400120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
004500120130      * GNU Lesser General Public License for more details.
004600120130      *
004700120130      * You should have received a copy of the GNU Lesser General Public
004800120130      * License along with JSON service program. If not, see http://www.gnu.org/licenses/.
004900120130      *-------------------------------------------------------------------------
005000120130
005100120130
005200120130     H nomain
005300120130     H bnddir('QC2LE')
005400120130     H copyright('Copyright (c) 2010-2011 Mihael Schmidt. All rights reserved.')
005500120130
005600120130
005700120130      *-------------------------------------------------------------------------
005800120130      * Prototypes
005900120130      *-------------------------------------------------------------------------
006000120130     D extractNumber   PR           256A
006100120130     D  fieldPtr                       *   value
006200120130     D  editCode                      1A   value
006300120130     D  fieldType                    10A   value
006400120130     D  numDigits                     2P 0 value
006500120130     D  numDecimals                   2P 0 value
006600120130      *
006700120130     D sendProgramMessage...
006800120130     D                 PR                  extpgm('QMHSNDPM')
006900120130     D  szMsgID                       7A   const
007000120130     D  szMsgFile                    20A   const
007100120130     D  szMsgData                  6000A   const  options(*varsize)
007200120130     D  nMsgDataLen                  10I 0 const
007300120130     D  szMsgType                    10A   const
007400120130     D  szCallStkEntry...
007500120130     D                               10A   const
007600120130     D  nRelativeCallStkEntry...
007700120130     D                               10I 0 const
007800120130     D  szRtnMsgKey                   4A
007900120130     D  error                       265A   options(*varsize)
008000120130      *
008100120130     D errno           PR              *   extproc('__errno')
008200120130      *
008300120130     D strerr          PR              *   extproc('strerror')
008400120130     D    errnum                     10I 0 value
008500120130      *
008600120130     D retreiveFileDescription...
008700120130     D                 PR                  extpgm('QDBRTVFD')
008800120130     D  receiverVariable...
008900120130     D                            65535A   options(*varsize)
009000120130     D  receiverLen                  10I 0 const
009100120130     D  qReturnFile                  20A
009200120130     D  formatName                    8A   const
009300120130     D  qFileName                    20A   const
009400120130     D  recordFormatName...
009500120130     D                               10A   const
009600120130     D  overrideProcessing...
009700120130     D                                1A   const
009800120130     D  system                       10A   const
009900120130     D  formatType                   10A   const
010000120130     D  errorCode                   256A   options(*varsize)
010100120130      *
010200120130     D convertEditCode...
010300120130     D                 PR                  extpgm('QECCVTEC')
010400120130     D  editMask                    256A
010500120130     D  editMaskLen                  10I 0
010600120130     D  outputLen                    10I 0
010700120130     D  zeroFillChar                  1A
010800120130     D  editCode                      1A   const
010900120130     D  fillChar                      1A   const
011000120130     D  numDigits                    10I 0 const
011100120130     D  numDecimals                  10I 0 const
011200120130     D  errorCode                   256A   options(*varsize)
011300120130      *
011400120130     D edit...
011500120130     D                 PR                  extpgm('QECEDT')
011600120130     D  editedField                 256A
011700120130     D  editedFieldLen...
011800120130     D                               10I 0
011900120130     D  field                        31A   const
012000120130     D  fieldType                    10A   const
012100120130     D  numDigits                    10I 0 const
012200120130     D  editMask                    256A   const
012300120130     D  editMaskLen                  10I 0 const
012400120130     D  zeroFillChar                  1A   const
012500120130     D  errorCode                   256A   options(*varsize)
012600120130      *
012700120130      /include qjsontxt,json
012800120130      /include qjsontxt,jsonint
012900120130      /include qjsontxt,ifsio
013000120130      /include qjsontxt,libc
013100120130      /include qjsontxt,ceeapi
013200120130      /include qjsontxt,arraylist
013300120130
013400120130      /if not defined (QUSEC)
013500120130      /define QUSEC
013600120130      /include qsysinc/qrpglesrc,qusec
013700120130      /endif
013800120130
013900120130
013901120130
014000120130      *-------------------------------------------------------------------------
014100120130      * Constants
014200120130      *-------------------------------------------------------------------------
014300120130      * Field types returned from QDBRTVFD
014400120130     D FIELD_TYPE_BINARY...
014500120130     D                 C                   x'0000'
014600120130     D FIELD_TYPE_FLOAT...
014700120130     D                 C                   x'0001'
014800120130     D FIELD_TYPE_ZONED...
014900120130     D                 C                   x'0002'
015000120130     D FIELD_TYPE_PACKED...
015100120130     D                 C                   x'0003'
015200120130     D FIELD_TYPE_CHAR...
015300120130     D                 C                   x'0004'
015400120130     D FIELD_TYPE_VARCHAR...
015500120130     D                 C                   x'8004'
015600120130     D FIELD_TYPE_DATE...
015700120130     D                 C                   x'000B'
015800120130     D FIELD_TYPE_TIME...
015900120130     D                 C                   x'000C'
016000120130     D FIELD_TYPE_TIMESTAMP...
016100120130     D                 C                   x'000D'
016200120130      *
016300120130      /include qjsontxt,jsonconst
016400120130
016500120130
016600120130      *-------------------------------------------------------------------------
016700120130      * Global Variables
016800120130      *-------------------------------------------------------------------------
016900120130      *
017000120130      * Format Definition Header returned from QDBRTVFD
017100120130      *
017200120130     D Qddfmt          DS           256    BASED(p_Qddfmt)
017300120130     D  Qddbyrtn                     10I 0
017400120130     D  Qddbyava                     10I 0
017500120130     D  Qddftext                     50A   OVERLAY(Qddfmt:94)
017600120130     D  Qddffldnum                    5I 0 OVERLAY(Qddfmt:144)
017700120130      *
017800120130      * Field Header returned from QDBRTVFD
017900120130      *
018000120130     D Qddffld         DS           252    BASED(p_Qddffld)
018100120130     D  Qddfdefl                     10I 0
018200120130     D  Qddffldi                     30A
018300120130     D  Qddfflde                     30A
018400120130     D  Qddfftyp                      2A
018500120130     D  Qddffiob                      1A
018600120130     D  Qddffobo                     10I 0
018700120130     D  Qddffibo                     10I 0
018800120130     D  Qddffldb                      5I 0
018900120130     D  Qddffldd                      5I 0
019000120130     D  Qddffldp                      5I 0
019100120130     D  Qddffkbs                      1A
019200120130     D  Qddfxals                     10I 0 OVERLAY(Qddffld:237)
019300120130      *
019400120130      * Alias Name Structure returned from QDBRTVFD
019500120130      *
019600120130     D Qddfalis        DS                  BASED(p_Qddfalis)
019700120130     D  Qddfalsl                      5I 0
019800120130     D  Reserved_85                  14A
019900120130     D  Qddfalsn                    258A
020000120130      *
020100120130      * Parameters passed to CEEDOD
020200120130      *
020300120130     D descType        S             10I 0
020400120130     D dataType        S             10I 0
020500120130     D descInfo1       S             10I 0
020600120130     D descInfo2       S             10I 0
020700120130     D length          S             10I 0
020800120130
020900120130
021000120130      *-------------------------------------------------------------------------
021100120130      * Procedures
021200120130      *-------------------------------------------------------------------------
021300120130
021400120130     /**
021500120130      * \brief Get date entry
021600120130      *
021700120130      * A convenience procedure for getting a date from a string entry.
021800120130      * The string must be in *ISO format (yyyy-mm-dd).
021900120130      *
022000120130      * <br><br>
022100120130      *
022200120130      * If the entry is not of type string or the entry is not a date string
022300120130      * in *ISO format an escape message will be sent.
022400120130      *
022500120130      * \author Mihael Schmidt
022600120130      * \date   01.08.2010
022700120130      *
022800120130      * \param Pointer to the JSON object
022900120130      * \param Key
023000120130      *
023100120130      * \return Date
023200120130      */
023300120130     P json_util_getDate...
023400120130     P                 B                   export
023500120130     D                 PI              D   opdesc
023600120130     D   json                          *   const
023700120130     D   key                      65535A   const options(*varsize)
023800120130      *
023900120130     D tmpKey          S          65535A
024000120130     D header          DS                  likeds(tmpl_header) based(json)
024100120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
024200120130
024300120130     D retVal          S               D
024400120130      /free
024500120130       isJSONImpl(json);
024600120130
024700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
024800120130                         length : *omit);
024900120130       tmpKey = %subst(key : 1 : length);
025000120130
025100120130       entryPtr = getJSONEntry(json : %addr(tmpKey) : length);
025200120130       if (entryPtr <> *null);
025300120130         if (entry.type = JSON_TYPE_STRING);
025400120130           retVal = %date(%str(entry.value) : *ISO);
025500120130         else;
025600120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
025700120130         endif;
025800120130       endif;
025900120130
026000120130       return retVal;
026100120130      /end-free
026200120130     P                 E
026300120130
026400120130
026500120130     /**
026600120130      * \brief Add date entry
026700120130      *
026800120130      * Convenience procedure for adding a date string in *ISO format to the
026900120130      * json object.
027000120130      *
027100120130      * \author Mihael Schmidt
027200120130      * \date 2010-08-01
027300120130      *
027400120130      * \param Pointer to the JSON object
027500120130      * \param Key
027600120130      * \param Date
027700120130      */
027800120130     P json_util_putDate...
027900120130     P                 B                   export
028000120130     D                 PI                  opdesc
028100120130     D   jsonPtr                       *   const
028200120130     D   key                      65535A   const options(*varsize)
028300120130     D   value                         D   const
028400120130      *
028500120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
028600120130     D prevEntryPtr    S               *
028700120130     D prevEntry       DS                  likeds(tmpl_entry)
028800120130     D                                     based(prevEntryPtr)
028900120130     D newEntryPtr     S               *
029000120130     D newEntry        DS                  likeds(tmpl_entry)
029100120130     D                                     based(newEntryPtr)
029200120130     D tmpPtr          S               *
029300120130     D tmpKey          S          65535A
029400120130     D tmpValue        S             10A
029500120130     D keyLength       S             10I 0
029600120130     D hexnull         S              1A   inz(x'00')
029700120130      /free
029800120130       isJSONImpl(jsonPtr);
029900120130
030000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
030100120130                         length : *omit);
030200120130       keyLength = length;
030300120130       tmpKey = %subst(key : 1 : keyLength);
030400120130       tmpValue = %char(value : *ISO);
030500120130
030600120130       // check if key is already in the map
030700120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
030800120130       if (newEntryPtr = *null);    // entry not in json object
030900120130         // create new entry
031000120130         newEntryPtr = %alloc(%size(tmpl_entry));
031100120130         newEntry.type = JSON_TYPE_STRING;
031200120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
031300120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
031400120130         newEntry.valueLength = %size(tmpValue);
031500120130         newEntry.value = %alloc(%size(tmpValue) + 1);   // +1 for the null byte
031600120130         newEntry.next = *null;
031700120130         newEntry.prev = *null;
031800120130
031900120130         // update header
032000120130         header.size += 1;
032100120130         if (header.firstEntry = *null);
032200120130           header.firstEntry = newEntryPtr;
032300120130         else;
032400120130           prevEntryPtr = header.lastEntry;
032500120130           prevEntry.next = newEntryPtr;
032600120130           newEntry.prev = prevEntryPtr;
032700120130         endif;
032800120130         header.lastEntry = newEntryPtr;
032900120130
033000120130       else;
033100120130         // entry needs to be resized
033200120130         newEntry.type = JSON_TYPE_STRING;
033300120130         newEntry.keyLength = keyLength + 1;
033400120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
033500120130         newEntry.valueLength = %size(tmpValue);
033600120130
033700120130         // dispose/dealloc old value
033800120130         disposeEntryValue(newEntryPtr);
033900120130       endif;
034000120130
034100120130       // copy value to the list entry
034200120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
034300120130       memcpy(newEntry.value : %addr(tmpValue) : %size(tmpValue));
034400120130
034500120130       // set null to the last byte
034600120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
034700120130       memcpy(newEntry.value + %size(tmpValue) : %addr(hexNull) : 1);
034800120130      /end-free
034900120130     P                 E
035000120130
035100120130
035200120130     /**
035300120130      * \brief Get date entry
035400120130      *
035500120130      * A convenience procedure for getting a date from a string entry.
035600120130      * The string must be in *ISO format (yyyy-mm-dd).
035700120130      *
035800120130      * <br><br>
035900120130      *
036000120130      * If the entry is not of type string or the entry is not a date string
036100120130      * in *ISO format an escape message will be sent.
036200120130      *
036300120130      * \author Mihael Schmidt
036400120130      * \date   01.08.2010
036500120130      *
036600120130      * \param Pointer to the JSON array
036700120130      * \param Index
036800120130      *
036900120130      * \return Date
037000120130      */
037100120130     P jsona_util_getDate...
037200120130     P                 B                   export
037300120130     D                 PI              D
037400120130     D   jsonArrPtr                    *   const
037500120130     D   index                       10U 0 const
037600120130      *
037700120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
037800120130      /free
037900120130       ptr = arraylist_get(jsonArrPtr : index);
038000120130       if (ptr <> *null);
038100120130         if (entry.type = JSON_TYPE_STRING);
038200120130           return %date(%str(ptr + 4) : *ISO);
038300120130         else;
038400120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
038500120130         endif;
038600120130       else;
038700120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
038800120130       endif;
038900120130
039000120130       return %date(); // dummy => will never come to this point
039100120130      /end-free
039200120130     P                 E
039300120130
039400120130
039500120130     /**
039600120130      * \brief Add date entry
039700120130      *
039800120130      * Convenience procedure for adding a date string in *ISO format to the
039900120130      * JSON array.
040000120130      *
040100120130      * \author Mihael Schmidt
040200120130      * \date   01.08.2010
040300120130      *
040400120130      * \param Pointer to the JSON array
040500120130      * \param Date
040600120130      * \param Index (default: last)
040700120130      */
040800120130     P jsona_util_putDate...
040900120130     P                 B                   export
041000120130     D                 PI
041100120130     D   jsonArrPtr                    *   const
041200120130     D   value                         D   const
041300120130     D   index                       10U 0 const options(*nopass)
041400120130      *
041500120130     D entry           DS                  likeds(tmpl_array_entry) inz
041600120130      /free
041700120130       entry.type = JSON_TYPE_STRING;
041800120130       entry.string = %char(value : *ISO);
041900120130
042000120130       if (%parms() = 2);
042100120130         arraylist_add(jsonArrPtr : %addr(entry) : 10 + 4);
042200120130       else;
042300120130         arraylist_add(jsonArrPtr : %addr(entry) : 10 + 4 : index);
042400120130       endif;
042500120130      /end-free
042600120130     P                 E
042700120130
042800120130
042900120130
043000120130     /**
043100120130      * \brief Output JSON Object to stream file
043200120130      *
043300120130      * \param JSON Object
043400120130      * \param Stream file path
043500120130      * \param CCSID (optional)
043600120130      * \param Delete if file exist (optional)
043700120130      *
043800120130      * \throws CPF9898 Error on opening file
043900120130      */
044000120130     P json_util_toFile...
044100120130     P                 B                   export
044200120130     D                 PI
044300120130     D  json                           *   const
044400120130     D  filePath                   1024A   const
044500120130     D  pCcsid                       10I 0 const options(*nopass : *omit)
044600120130     D  pDeleteFile                    N   const options(*nopass : *omit)
044700120130     D  pOutputFormat...
044800120130     D                               10I 0 const options(*nopass)
044900120130     D  pPrettyPrintFormat...
045000120130     D                                     likeds(json_prettyPrintFormat)
045100120130     D                                     const options(*nopass)
045200120130      *
045300120130     D outputFormat    S             10I 0
045400120130     D prettyPrintOption...
045500120130     D                 S               N   inz(*off)
045600120130     D prettyPrintFormat...
045700120130     D                 DS                  likeds(json_prettyPrintFormat) inz
045800120130     D ccsid           S             10I 0 inz(0)
045900120130     D deleteFile      S               N   inz(*off)
046000120130     D jsonString      S               *
046100120130     D fileHandle      S             10I 0
046200120130     D flags           S             10I 0
046300120130     D mode            S             10I 0
046400120130     D errorNumber     S             10I 0 based(errorPtr)
046500120130     D errorString     S           1024A   varying
046600120130     D msgdata         S            512A
046700120130     D msgkey          S              4A
046800120130
046900120130      /free
047000120130       if (%parms() >= 3 and %addr(pCcsid) <> *null);
047100120130         ccsid = pCcsid;
047200120130       endif;
047300120130
047400120130       if (%parms() >= 4 and %addr(pDeleteFile) <> *null);
047500120130         deleteFile = pDeleteFile;
047600120130       endif;
047700120130
047800120130       if (%parms() >= 5);
047900120130         outputFormat = pOutputFormat;
048000120130         prettyPrintFormat.useTabs = *off;
048100120130         prettyPrintFormat.numberWhitespace = 4;
048200120130         prettyPrintFormat.breakAfterElement = *on;
048300120130         prettyPrintFormat.breakAfterObjectBrace = *on;
048400120130         prettyPrintFormat.breakBeforeArrayBrace = *on;
048500120130         prettyPrintFormat.breakAfterArrayBrace = *on;
048600120130       endif;
048700120130
048800120130       if (%parms() >= 6);
048900120130         prettyPrintFormat = pPrettyPrintFormat;
049000120130       endif;
049100120130
049200120130       if (outputFormat = JSON_OUTPUT_PRETTY_PRINT);
049300120130         prettyPrintOption = *on;
049400120130       endif;
049500120130
049600120130
049700120130       if (deleteFile);
049800120130         if (access(%trimr(filePath) : F_OK) >= 0);
049900120130           // file exists => delete
050000120130           system('RMVLNK OBJLNK(''' + %trimr(filePath) + ''')');
050100120130         endif;
050200120130       endif;
050300120130
050400120130
050500120130       // create file
050600120130       flags = O_WRONLY + O_CREAT + O_APPEND + O_TEXTDATA +
050700120130               O_CCSID + O_TEXT_CREAT;
050800120130       mode =  S_IRUSR + S_IWUSR + S_IRGRP + S_IROTH;
050900120130       fileHandle = open(%trimr(filePath) : flags : mode : ccsid : 0);
051000120130       if (fileHandle < 0);
051100120130         // could not create file
051200120130         errorPtr = errno();
051300120130         errorString = 'I/O Error: ' + %str(strerr(errorNumber));
051400120130         msgdata = 'Could not create file ' + %trimr(filePath) +
051500120130                   ': ' + errorString;
051600120130         clear QUSEC;
051700120130         QUSBPRV = 0;
051800120130         sendProgramMessage('CPF9898' :
051900120130                            'QCPFMSG   *LIBL     ' :
052000120130                            %trimr(msgdata) :
052100120130                            %len(%trimr(msgdata)) :
052200120130                            '*ESCAPE   ' :
052300120130                            '*PGMBDY' :
052400120130                            0 :
052500120130                            msgkey :
052600120130                            QUSEC);
052700120130       endif;
052800120130
052900120130       jsonString = json_toString(json  : outputFormat : prettyPrintFormat);
053000120130
053100120130       callp write(fileHandle : jsonString : strlen(jsonString));
053200120130
053300120130       callp close(fileHandle);
053400120130      /end-free
053500120130     P                 E
053600120130
053700120130
053800120130     /**
053900120130      * \brief Read JSON from stream file
054000120130      *
054100120130      * \param Stream file path
054200120130      * \param Delete file after reading (optional)
054300120130      *
054400120130      * \return JSON object
054500120130      *
054600120130      * \throws CPF9898 Error on reading file
054700120130      * \throws CPF9898 File not found
054800120130      * \throws CPF9898 Error buildng JSON object
054900120130      */
055000120130     P json_util_fromFile...
055100120130     P                 B                   export
055200120130     D                 PI              *
055300120130     D  filePath                   1024A   const
055400120130     D  pDeleteFile                    N   const options(*nopass)
055500120130      *
055600120130     D json            S               *
055700120130     D deleteFile      S               N   inz(*off)
055800120130     D buffer          S               *
055900120130     D fileSize        S             10I 0
056000120130     D fileStatus      DS                  likeds(statds)
056100120130     D fileHandle      S             10I 0
056200120130     D flags           S             10I 0
056300120130     D errorNumber     S             10I 0 based(errorPtr)
056400120130     D errorString     S           1024A   varying
056500120130     D msgdata         S            512A
056600120130     D msgkey          S              4A
056700120130
056800120130      /free
056900120130       if (%parms() = 2);
057000120130         deleteFile = pDeleteFile;
057100120130       endif;
057200120130
057300120130       if (stat(%trimr(filePath) : %addr(fileStatus)) < 0);
057400120130         msgdata = 'Could not query file attributes for file ' +
057500120130                   %trimr(filepath) + '.';
057600120130         clear QUSEC;
057700120130         QUSBPRV = 0;
057800120130         sendProgramMessage('CPF9898' :
057900120130                            'QCPFMSG   *LIBL     ' :
058000120130                            %trimr(msgdata) :
058100120130                            %len(%trimr(msgdata)) :
058200120130                            '*ESCAPE   ' :
058300120130                            '*PGMBDY' :
058400120130                            0 :
058500120130                            msgkey :
058600120130                            QUSEC);
058700120130       endif;
058800120130
058900120130       flags = O_RDONLY + O_TEXTDATA;
059000120130       fileHandle = open(%trimr(filePath) : flags);
059100120130       if (fileHandle < 0);
059200120130         // could not open file
059300120130         errorPtr = errno();
059400120130         errorString = 'I/O Error: ' + %str(strerr(errorNumber));
059500120130         msgdata = 'Could not open file ' + %trimr(filePath) + ': '+errorString;
059600120130         clear QUSEC;
059700120130         QUSBPRV = 0;
059800120130         sendProgramMessage('CPF9898' :
059900120130                            'QCPFMSG   *LIBL     ' :
060000120130                            %trimr(msgdata) :
060100120130                            %len(%trimr(msgdata)) :
060200120130                            '*ESCAPE   ' :
060300120130                            '*PGMBDY' :
060400120130                            0 :
060500120130                            msgkey :
060600120130                            QUSEC);
060700120130       endif;
060800120130
060900120130       buffer = %alloc(fileStatus.st_size);
061000120130
061100120130       callp read(fileHandle : buffer : fileStatus.st_size);
061200120130
061300120130       callp close(fileHandle);
061400120130
061500120130       json = json_parse(buffer);
061600120130
061700120130       // clean up
061800120130       dealloc buffer;
061900120130
062000120130       if (deleteFile);
062100120130         if (access(%trimr(filePath) : F_OK) >= 0);
062200120130           // file exists => delete
062300120130           system('RMVLNK OBJLNK(''' + %trimr(filePath) + ''')');
062400120130         endif;
062500120130       endif;
062600120130
062700120130       return json;
062800120130      /end-free
062900120130     P                 E
063000120130
063100120130
063200120130     /**
063300120130      * \brief Get decimal entry
063400120130      *
063500120130      * A convenience procedure for getting a decimal value from a string entry.
063600120130      *
063700120130      * <br><br>
063800120130      *
063900120130      * If the entry is not of type string or the entry is not a number
064000120130      * an escape message will be sent.
064100120130      *
064200120130      * \author Mihael Schmidt
064300120130      * \date   09.04.2011
064400120130      *
064500120130      * \param Pointer to the JSON object
064600120130      * \param Key
064700120130      *
064800120130      * \return Decimal value
064900120130      */
065000120130     P json_util_getDecimal...
065100120130     P                 B                   export
065200120130     D                 PI            30P10 opdesc
065300120130     D   json                          *   const
065400120130     D   key                      65535A   const options(*varsize)
065500120130      *
065600120130     D tmpKey          S          65535A
065700120130     D header          DS                  likeds(tmpl_header) based(json)
065800120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
065900120130
066000120130     D retVal          S             30P10
066100120130      /free
066200120130       isJSONImpl(json);
066300120130
066400120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
066500120130                         length : *omit);
066600120130       tmpKey = %subst(key : 1 : length);
066700120130
066800120130       entryPtr = getJSONEntry(json : %addr(tmpKey) : length);
066900120130       if (entryPtr <> *null);
067000120130         if (entry.type = JSON_TYPE_STRING);
067100120130           retVal = %dec(%str(entry.value) : 30 : 10);
067200120130         else;
067300120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
067400120130         endif;
067500120130       endif;
067600120130
067700120130       return retVal;
067800120130      /end-free
067900120130     P                 E
068000120130
068100120130
068200120130     /**
068300120130      * \brief Get decimal entry
068400120130      *
068500120130      * A convenience procedure for getting a decimal value from a string entry.
068600120130      *
068700120130      * <br><br>
068800120130      *
068900120130      * If the entry is not of type string or the entry is not a number
069000120130      * an escape message will be sent.
069100120130      *
069200120130      * \author Mihael Schmidt
069300120130      * \date   09.04.2011
069400120130      *
069500120130      * \param Pointer to the JSON array
069600120130      * \param Index
069700120130      *
069800120130      * \return Decimal value
069900120130      */
070000120130     P jsona_util_getDecimal...
070100120130     P                 B                   export
070200120130     D                 PI            30P10
070300120130     D   jsonArrPtr                    *   const
070400120130     D   index                       10U 0 const
070500120130      *
070600120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
070700120130     D retVal          S             30P10
070800120130      /free
070900120130       ptr = arraylist_get(jsonArrPtr : index);
071000120130       if (ptr <> *null);
071100120130         if (entry.type = JSON_TYPE_STRING);
071200120130           retVal = %dec(%str(ptr + 4) : 30 : 10);
071300120130           return retVal;
071400120130         else;
071500120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
071600120130         endif;
071700120130       else;
071800120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
071900120130       endif;
072000120130
072100120130       return 0; // dummy => will never come to this point
072200120130      /end-free
072300120130     P                 E
072400120130
072500120130
072600120130     /**
072700120130      * \brief Add decimal entry
072800120130      *
072900120130      * Convenience procedure for adding a decimal value as a string to the
073000120130      * json object.
073100120130      *
073200120130      * \author Mihael Schmidt
073300120130      * \date   09.04.2011
073400120130      *
073500120130      * \param Pointer to the JSON object
073600120130      * \param Key
073700120130      * \param Decimal value
073800120130      * \param Decimal positions (default: 2)
073900120130      */
074000120130     P json_util_putDecimal...
074100120130     P                 B                   export
074200120130     D                 PI                  opdesc
074300120130     D   jsonPtr                       *   const
074400120130     D   key                      65535A   const options(*varsize)
074500120130     D   value                       30P10 const
074600120130     D   pDecimalPositions...
074700120130     D                                2P 0 const options(*nopass)
074800120130      *
074900120130     D decimalPositions...
075000120130     D                 S              2P 0 inz(2)
075100120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
075200120130     D prevEntryPtr    S               *
075300120130     D prevEntry       DS                  likeds(tmpl_entry)
075400120130     D                                     based(prevEntryPtr)
075500120130     D newEntryPtr     S               *
075600120130     D newEntry        DS                  likeds(tmpl_entry)
075700120130     D                                     based(newEntryPtr)
075800120130     D tmpPtr          S               *
075900120130     D tmpKey          S          65535A
076000120130     D tmpValue        S             32A
076100120130     D tmpValueLength  S             10I 0
076200120130     D keyLength       S             10I 0
076300120130     D hexnull         S              1A   inz(x'00')
076400120130     D decimalSepIndex...
076500120130     D                 S             10I 0
076600120130      /free
076700120130       isJSONImpl(jsonPtr);
076800120130
076900120130       if (%parms() = 4);
077000120130         decimalPositions = pDecimalPositions;
077100120130       endif;
077200120130
077300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
077400120130                         length : *omit);
077500120130       keyLength = length;
077600120130       tmpKey = %subst(key : 1 : keyLength);
077700120130       tmpValue = %char(value);
077800120130
077900120130       // max. decimal precision of 10
078000120130       if (decimalPositions > 10);
078100120130         decimalPositions = 10;
078200120130       elseif (decimalPositions < 0); // min. decimal precision of 0
078300120130         decimalPositions = 0;
078400120130       endif;
078500120130
078600120130       // limit the string to the passed number of decimal positions
078700120130       decimalSepIndex = %scan('.' : tmpValue);
078800120130       if (decimalSepIndex = 0);
078900120130         decimalSepIndex = %scan(',' : tmpValue);
079000120130       endif;
079100120130
079200120130       if (decimalSepIndex <> 0);
079300120130         tmpValueLength = decimalSepIndex + decimalPositions;
079400120130       else;
079500120130         tmpValueLength = %len(%trim(tmpvalue));
079600120130       endif;
079700120130
079800120130       // check if key is already in the map
079900120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
080000120130       if (newEntryPtr = *null);    // entry not in json object
080100120130         // create new entry
080200120130         newEntryPtr = %alloc(%size(tmpl_entry));
080300120130         newEntry.type = JSON_TYPE_STRING;
080400120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
080500120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
080600120130         newEntry.valueLength = tmpValueLength;
080700120130         newEntry.value = %alloc(tmpValueLength + 1);   // +1 for the null byte
080800120130         newEntry.next = *null;
080900120130         newEntry.prev = *null;
081000120130
081100120130         // update header
081200120130         header.size += 1;
081300120130         if (header.firstEntry = *null);
081400120130           header.firstEntry = newEntryPtr;
081500120130         else;
081600120130           prevEntryPtr = header.lastEntry;
081700120130           prevEntry.next = newEntryPtr;
081800120130           newEntry.prev = prevEntryPtr;
081900120130         endif;
082000120130         header.lastEntry = newEntryPtr;
082100120130
082200120130       else;
082300120130         // entry needs to be resized
082400120130         newEntry.type = JSON_TYPE_STRING;
082500120130         newEntry.keyLength = keyLength + 1;
082600120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
082700120130         newEntry.valueLength = tmpValueLength;
082800120130
082900120130         // dispose/dealloc old value
083000120130         disposeEntryValue(newEntryPtr);
083100120130       endif;
083200120130
083300120130       // copy value to the list entry
083400120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
083500120130       memcpy(newEntry.value : %addr(tmpValue) : tmpValueLength);
083600120130
083700120130       // set null to the last byte
083800120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
083900120130       memcpy(newEntry.value + tmpValueLength : %addr(hexNull) : 1);
084000120130      /end-free
084100120130     P                 E
084200120130
084300120130
084400120130     /**
084500120130      * \brief Add decimal entry
084600120130      *
084700120130      * Convenience procedure for adding a decimal value as a string to the
084800120130      * JSON array.
084900120130      *
085000120130      * \author Mihael Schmidt
085100120130      * \date   12.04.2011
085200120130      *
085300120130      * \param Pointer to the JSON array
085400120130      * \param Decimal value
085500120130      * \param Decimal positions (default: 2)
085600120130      * \param Index (default: last)
085700120130      */
085800120130     P jsona_util_putDecimal...
085900120130     P                 B                   export
086000120130     D                 PI
086100120130     D   jsonArrPtr                    *   const
086200120130     D   value                       30P10 const
086300120130     D   pDecimalPositions...
086400120130     D                                2P 0 const options(*nopass : *omit)
086500120130     D   index                       10U 0 const options(*nopass)
086600120130      *
086700120130     D entry           DS                  likeds(tmpl_array_entry) inz
086800120130     D decimalSepIndex...
086900120130     D                 S             10I 0
087000120130     D decimalPositions...
087100120130     D                 S              2P 0 inz(2)
087200120130     D tmpValueLength  S             10I 0
087300120130      /free
087400120130       entry.type = JSON_TYPE_STRING;
087500120130       entry.string = %char(value);
087600120130
087700120130       if (%parms() >= 3 and %addr(pDecimalPositions) <> *null);
087800120130         decimalPositions = pDecimalPositions;
087900120130       endif;
088000120130
088100120130       // max. decimal precision of 10
088200120130       if (decimalPositions > 10);
088300120130         decimalPositions = 10;
088400120130       elseif (decimalPositions < 0); // min. decimal precision of 0
088500120130         decimalPositions = 0;
088600120130       endif;
088700120130
088800120130       // limit the string to the passed number of decimal positions
088900120130       decimalSepIndex = %scan('.' : entry.string);
089000120130       if (decimalSepIndex = 0);
089100120130         decimalSepIndex = %scan(',' : entry.string);
089200120130       endif;
089300120130
089400120130       if (decimalSepIndex <> 0);
089500120130         tmpValueLength = decimalSepIndex + decimalPositions;
089600120130       else;
089700120130         tmpValueLength = %len(%trim(entry.string));
089800120130       endif;
089900120130
090000120130       if (%parms() < 4);
090100120130         arraylist_add(jsonArrPtr : %addr(entry) : tmpValueLength + 4);
090200120130       else;
090300120130         arraylist_add(jsonArrPtr : %addr(entry) : tmpValueLength + 4 : index);
090400120130       endif;
090500120130      /end-free
090600120130     P                 E
090700120130
090800120130
090900120130
091000120130     /**
091100120130      * \brief Get time entry
091200120130      *
091300120130      * A convenience procedure for get a time from a string entry.
091400120130      * The string must be in *ISO format (hh.mm.ss).
091500120130      *
091600120130      * <br><br>
091700120130      *
091800120130      * If the entry is not of type string or the entry is not a time string
091900120130      * in *ISO format an escape message will be send.
092000120130      *
092100120130      * \author Brian Garland
092200120130      * \date   2011-06-24
092300120130      *
092400120130      * \param Pointer to the JSON object
092500120130      * \param Key
092600120130      *
092700120130      * \return Time
092800120130      */
092900120130     P json_util_getTime...
093000120130     P                 B                   export
093100120130     D                 PI              T   opdesc
093200120130     D   json                          *   const
093300120130     D   key                      65535A   const options(*varsize)
093400120130      *
093500120130     D tmpKey          S          65535A
093600120130     D header          DS                  likeds(tmpl_header) based(json)
093700120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
093800120130
093900120130     D retVal          S               T
094000120130      /free
094100120130       isJSONImpl(json);
094200120130
094300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
094400120130                         length : *omit);
094500120130       tmpKey = %subst(key : 1 : length);
094600120130
094700120130       entryPtr = getJSONEntry(json : %addr(tmpKey) : length);
094800120130       if (entryPtr <> *null);
094900120130         if (entry.type = JSON_TYPE_STRING);
095000120130           retVal = %time(%str(entry.value) : *ISO);
095100120130         else;
095200120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
095300120130         endif;
095400120130       endif;
095500120130
095600120130       return retVal;
095700120130      /end-free
095800120130     P                 E
095900120130
096000120130
096100120130
096200120130     /**
096300120130      * \brief Add time entry
096400120130      *
096500120130      * Convenience procedure for adding a time string in *ISO format to the
096600120130      * json object.
096700120130      *
096800120130      * \author Brian Garland
096900120130      * \date   2011-06-24
097000120130      *
097100120130      * \param Pointer to the JSON object
097200120130      * \param Key
097300120130      * \param Time
097400120130      */
097500120130     P json_util_putTime...
097600120130     P                 B                   export
097700120130     D                 PI                  opdesc
097800120130     D   jsonPtr                       *   const
097900120130     D   key                      65535A   const options(*varsize)
098000120130     D   value                         T   const
098100120130      *
098200120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
098300120130     D prevEntryPtr    S               *
098400120130     D prevEntry       DS                  likeds(tmpl_entry)
098500120130     D                                     based(prevEntryPtr)
098600120130     D newEntryPtr     S               *
098700120130     D newEntry        DS                  likeds(tmpl_entry)
098800120130     D                                     based(newEntryPtr)
098900120130     D tmpPtr          S               *
099000120130     D tmpKey          S          65535A
099100120130     D tmpValue        S              8A
099200120130     D keyLength       S             10I 0
099300120130     D hexnull         S              1A   inz(x'00')
099400120130      /free
099500120130       isJSONImpl(jsonPtr);
099600120130
099700120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
099800120130                         length : *omit);
099900120130       keyLength = length;
100000120130       tmpKey = %subst(key : 1 : keyLength);
100100120130       tmpValue = %char(value : *ISO);
100200120130
100300120130       // check if key is already in the map
100400120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
100500120130       if (newEntryPtr = *null);    // entry not in json object
100600120130         // create new entry
100700120130         newEntryPtr = %alloc(%size(tmpl_entry));
100800120130         newEntry.type = JSON_TYPE_STRING;
100900120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
101000120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
101100120130         newEntry.valueLength = %size(tmpValue);
101200120130         newEntry.value = %alloc(%size(tmpValue) + 1);   // +1 for the null byte
101300120130         newEntry.next = *null;
101400120130         newEntry.prev = *null;
101500120130
101600120130         // update header
101700120130         header.size += 1;
101800120130         if (header.firstEntry = *null);
101900120130           header.firstEntry = newEntryPtr;
102000120130         else;
102100120130           prevEntryPtr = header.lastEntry;
102200120130           prevEntry.next = newEntryPtr;
102300120130           newEntry.prev = prevEntryPtr;
102400120130         endif;
102500120130         header.lastEntry = newEntryPtr;
102600120130
102700120130       else;
102800120130         // entry needs to be resized
102900120130         newEntry.type = JSON_TYPE_STRING;
103000120130         newEntry.keyLength = keyLength + 1;
103100120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
103200120130         newEntry.valueLength = %size(tmpValue);
103300120130
103400120130         // dispose/dealloc old value
103500120130         disposeEntryValue(newEntryPtr);
103600120130       endif;
103700120130
103800120130       // copy value to the list entry
103900120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
104000120130       memcpy(newEntry.value : %addr(tmpValue) : %size(tmpValue));
104100120130
104200120130       // set null to the last byte
104300120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
104400120130       memcpy(newEntry.value + %size(tmpValue) : %addr(hexNull) : 1);
104500120130      /end-free
104600120130     P                 E
104700120130
104800120130
104900120130     /**
105000120130      * \brief Get time entry
105100120130      *
105200120130      * A convenience procedure for get a time from a string entry.
105300120130      * The string must be in *ISO format (hh.mm.ss).
105400120130      *
105500120130      * <br><br>
105600120130      *
105700120130      * If the entry is not of type string or the entry is not a time string
105800120130      * in *ISO format an escape message will be send.
105900120130      *
106000120130      * \author Brian Garland
106100120130      * \date   2011-06-24
106200120130      *
106300120130      * \param Pointer to the JSON array
106400120130      * \param Index
106500120130      *
106600120130      * \return Time
106700120130      */
106800120130     P jsona_util_getTime...
106900120130     P                 B                   export
107000120130     D                 PI              T
107100120130     D   jsonArrPtr                    *   const
107200120130     D   index                       10U 0 const
107300120130      *
107400120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
107500120130      /free
107600120130       ptr = arraylist_get(jsonArrPtr : index);
107700120130       if (ptr <> *null);
107800120130         if (entry.type = JSON_TYPE_STRING);
107900120130           return %time(%str(ptr + 4) : *ISO);
108000120130         else;
108100120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
108200120130         endif;
108300120130       else;
108400120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
108500120130       endif;
108600120130
108700120130       return %time(); // dummy => will never come to this point
108800120130      /end-free
108900120130     P                 E
109000120130
109100120130
109200120130     /**
109300120130      * \brief Add time entry
109400120130      *
109500120130      * Convenience procedure for adding a time string in *ISO format to the
109600120130      * JSON array.
109700120130      *
109800120130      * \author Brian Garland
109900120130      * \date   2011-06-24
110000120130      *
110100120130      * \param Pointer to the JSON array
110200120130      * \param Time
110300120130      * \param Index (default: last)
110400120130      */
110500120130     P jsona_util_putTime...
110600120130     P                 B                   export
110700120130     D                 PI
110800120130     D   jsonArrPtr                    *   const
110900120130     D   value                         T   const
111000120130     D   index                       10U 0 const options(*nopass)
111100120130      *
111200120130     D entry           DS                  likeds(tmpl_array_entry) inz
111300120130      /free
111400120130       entry.type = JSON_TYPE_STRING;
111500120130       entry.string = %char(value : *ISO);
111600120130
111700120130       if (%parms() = 2);
111800120130         arraylist_add(jsonArrPtr : %addr(entry) : 8 + 4);
111900120130       else;
112000120130         arraylist_add(jsonArrPtr : %addr(entry) : 8 + 4 : index);
112100120130       endif;
112200120130      /end-free
112300120130     P                 E
112400120130
112500120130
112600120130
112700120130     /**
112800120130      * \brief Get timestamp entry
112900120130      *
113000120130      * A convenience procedure for get a timestamp from a string entry.
113100120130      * The string must be in *ISO format (yyyy-mm-dd-hh.mm.ss.mmmmmm).
113200120130      *
113300120130      * <br><br>
113400120130      *
113500120130      * If the entry is not of type string or the entry is not a timestamp string
113600120130      * in *ISO format an escape message will be send.
113700120130      *
113800120130      * \author Brian Garland
113900120130      * \date   2011-06-24
114000120130      *
114100120130      * \param Pointer to the JSON object
114200120130      * \param Key
114300120130      *
114400120130      * \return Timestamp
114500120130      */
114600120130     P json_util_getTimestamp...
114700120130     P                 B                   export
114800120130     D                 PI              Z   opdesc
114900120130     D   json                          *   const
115000120130     D   key                      65535A   const options(*varsize)
115100120130      *
115200120130     D tmpKey          S          65535A
115300120130     D header          DS                  likeds(tmpl_header) based(json)
115400120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
115500120130
115600120130     D retVal          S               Z
115700120130      /free
115800120130       isJSONImpl(json);
115900120130
116000120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
116100120130                         length : *omit);
116200120130       tmpKey = %subst(key : 1 : length);
116300120130
116400120130       entryPtr = getJSONEntry(json : %addr(tmpKey) : length);
116500120130       if (entryPtr <> *null);
116600120130         if (entry.type = JSON_TYPE_STRING);
116700120130           retVal = %timestamp(%str(entry.value) : *ISO);
116800120130         else;
116900120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
117000120130         endif;
117100120130       endif;
117200120130
117300120130       return retVal;
117400120130      /end-free
117500120130     P                 E
117600120130
117700120130
117800120130     /**
117900120130      * \brief Add timestamp entry
118000120130      *
118100120130      * Convenience procedure for adding a timestamp string in *ISO format to the
118200120130      * json object.
118300120130      *
118400120130      * \author Brian Garland
118500120130      * \date   2011-06-24
118600120130      *
118700120130      * \param Pointer to the JSON object
118800120130      * \param Key
118900120130      * \param Timestamp
119000120130      */
119100120130     P json_util_putTimestamp...
119200120130     P                 B                   export
119300120130     D                 PI                  opdesc
119400120130     D   jsonPtr                       *   const
119500120130     D   key                      65535A   const options(*varsize)
119600120130     D   value                         Z   const
119700120130      *
119800120130     D header          DS                  likeds(tmpl_header) based(jsonPtr)
119900120130     D prevEntryPtr    S               *
120000120130     D prevEntry       DS                  likeds(tmpl_entry)
120100120130     D                                     based(prevEntryPtr)
120200120130     D newEntryPtr     S               *
120300120130     D newEntry        DS                  likeds(tmpl_entry)
120400120130     D                                     based(newEntryPtr)
120500120130     D tmpPtr          S               *
120600120130     D tmpKey          S          65535A
120700120130     D tmpValue        S             26A
120800120130     D keyLength       S             10I 0
120900120130     D hexnull         S              1A   inz(x'00')
121000120130      /free
121100120130       isJSONImpl(jsonPtr);
121200120130
121300120130       cee_getOpDescInfo(2 : descType : dataType : descInfo1 : descInfo2 :
121400120130                         length : *omit);
121500120130       keyLength = length;
121600120130       tmpKey = %subst(key : 1 : keyLength);
121700120130       tmpValue = %char(value : *ISO);
121800120130
121900120130       // check if key is already in the map
122000120130       newEntryPtr = getJSONEntry(jsonPtr : %addr(tmpKey) : keyLength);
122100120130       if (newEntryPtr = *null);    // entry not in json object
122200120130         // create new entry
122300120130         newEntryPtr = %alloc(%size(tmpl_entry));
122400120130         newEntry.type = JSON_TYPE_STRING;
122500120130         newEntry.keyLength = keyLength + 1;      // +1 for the null byte
122600120130         newEntry.key = %alloc(keyLength + 1);     // +1 for the null byte
122700120130         newEntry.valueLength = %size(tmpValue);
122800120130         newEntry.value = %alloc(%size(tmpValue) + 1);   // +1 for the null byte
122900120130         newEntry.next = *null;
123000120130         newEntry.prev = *null;
123100120130
123200120130         // update header
123300120130         header.size += 1;
123400120130         if (header.firstEntry = *null);
123500120130           header.firstEntry = newEntryPtr;
123600120130         else;
123700120130           prevEntryPtr = header.lastEntry;
123800120130           prevEntry.next = newEntryPtr;
123900120130           newEntry.prev = prevEntryPtr;
124000120130         endif;
124100120130         header.lastEntry = newEntryPtr;
124200120130
124300120130       else;
124400120130         // entry needs to be resized
124500120130         newEntry.type = JSON_TYPE_STRING;
124600120130         newEntry.keyLength = keyLength + 1;
124700120130         newEntry.key = %realloc(newEntry.key : keyLength + 1);
124800120130         newEntry.valueLength = %size(tmpValue);
124900120130
125000120130         // dispose/dealloc old value
125100120130         disposeEntryValue(newEntryPtr);
125200120130       endif;
125300120130
125400120130       // copy value to the list entry
125500120130       memcpy(newEntry.key : %addr(tmpKey) : keyLength);
125600120130       memcpy(newEntry.value : %addr(tmpValue) : %size(tmpValue));
125700120130
125800120130       // set null to the last byte
125900120130       memcpy(newEntry.key + keyLength : %addr(hexNull) : 1);
126000120130       memcpy(newEntry.value + %size(tmpValue) : %addr(hexNull) : 1);
126100120130      /end-free
126200120130     P                 E
126300120130
126400120130
126500120130     /**
126600120130      * \brief Get timestamp entry
126700120130      *
126800120130      * A convenience procedure for get a timestamp from a string entry.
126900120130      * The string must be in *ISO format (yyyy-mm-dd-hh.mm.ss.mmmmmm).
127000120130      *
127100120130      * <br><br>
127200120130      *
127300120130      * If the entry is not of type string or the entry is not a timestamp string
127400120130      * in *ISO format an escape message will be send.
127500120130      *
127600120130      * \author Brian Garland
127700120130      * \date   2011-06-24
127800120130      *
127900120130      * \param Pointer to the JSON array
128000120130      * \param Index
128100120130      *
128200120130      * \return Timestamp
128300120130      */
128400120130     P jsona_util_getTimestamp...
128500120130     P                 B                   export
128600120130     D                 PI              Z
128700120130     D   jsonArrPtr                    *   const
128800120130     D   index                       10U 0 const
128900120130      *
129000120130     D entry           DS                  likeds(tmpl_array_entry) based(ptr)
129100120130      /free
129200120130       ptr = arraylist_get(jsonArrPtr : index);
129300120130       if (ptr <> *null);
129400120130         if (entry.type = JSON_TYPE_STRING);
129500120130           return %timestamp(%str(ptr + 4) : *ISO);
129600120130         else;
129700120130           sendEscapeMessage(MSG_ENTRY_TYPE_MISMATCH);
129800120130         endif;
129900120130       else;
130000120130         sendEscapeMessage(MSG_ARRAY_ELEMENT_NOT_FOUND);
130100120130       endif;
130200120130
130300120130       return %timestamp(); // dummy => will never come to this point
130400120130      /end-free
130500120130     P                 E
130600120130
130700120130
130800120130     /**
130900120130      * \brief Add timestamp entry
131000120130      *
131100120130      * Convenience procedure for adding a timestamp string in *ISO format to the
131200120130      * JSON array.
131300120130      *
131400120130      * \author Brian Garland
131500120130      * \date   2011-06-24
131600120130      *
131700120130      * \param Pointer to the JSON array
131800120130      * \param Timestamp
131900120130      * \param Index (default: last)
132000120130      */
132100120130     P jsona_util_putTimestamp...
132200120130     P                 B                   export
132300120130     D                 PI
132400120130     D   jsonArrPtr                    *   const
132500120130     D   value                         Z   const
132600120130     D   index                       10U 0 const options(*nopass)
132700120130      *
132800120130     D entry           DS                  likeds(tmpl_array_entry) inz
132900120130      /free
133000120130       entry.type = JSON_TYPE_STRING;
133100120130       entry.string = %char(value : *ISO);
133200120130
133300120130       if (%parms() = 2);
133400120130         arraylist_add(jsonArrPtr : %addr(entry) : 26 + 4);
133500120130       else;
133600120130         arraylist_add(jsonArrPtr : %addr(entry) : 26 + 4 : index);
133700120130       endif;
133800120130      /end-free
133900120130     P                 E
134000120130
134100120130
134200120130     /**
134300120130      * \brief Convert a data structure to a JSON object
134400120130      *
134500120130      * \param Data structure
134600120130      * \param Qualified file name that the data structure is based upon
134700120130      *        (10A filename + 10A library)
134800120130      *
134900120130      * \return JSON object
135000120130      *
135100120130      * \throws CPF9898 File not found
135200120130      * \throws CPF9898 Error building JSON object
135300120130      *
135400120130      * \info Varying fields with a 4-byte header are not supported.
135500120130      *
135600120130      * \author Brian Garland
135700120130      */
135800120130     P json_util_dsToJsonObject...
135900120130     P                 B                   export
136000120130     D                 PI              *
136100120130     D   dataStructure...
136200120130     D                            65535A   options(*varsize)
136300120130     D   qFile                       20A   const
136400120130      *
136500120130      * Used to overlay some field types that either the API's don't support
136600120130      * or it is just more convenient.
136700120130      *
136800120130     D fieldDS         DS                  based(p_FieldDS) qualified
136900120130     D  integer                       9B 0 overlay(fieldDS:1)
137000120130     D  smallInt                      4B 0 overlay(fieldDS:1)
137100120130     D  bigInt                       20I 0 overlay(fieldDS:1)
137200120130     D  float                         4F   overlay(fieldDS:1)
137300120130     D  date                         10D   overlay(fieldDS:1)
137400120130     D  time                          8T   overlay(fieldDS:1)
137500120130     D  timestamp                    26Z   overlay(fieldDS:1)
137600120130     D  real                          4F   overlay(fieldDS:1)
137700120130     D  double                        8F   overlay(fieldDS:1)
137800120130      *
137900120130     D buffer          S              1A   based(p_Buffer)
138000120130     D bufferSize      S             10I 0
138100120130     D data            S             30A
138200120130     D fieldName       S             50A
138300120130     D i               S             10I 0
138400120130     D json            S               *
138500120130     D msgdata         S            512A
138600120130     D msgkey          S              4A
138700120130     D nbrInt          S             10I 0
138800120130     D nbrDouble       S              8F
138900120130     D nbrLong         S             20I 0
139000120130     D rtnFile         S             20A
139100120130     D varCharLen      S              5I 0 BASED(p_varCharLen)
139200120130
139300120130      /free
139400120130
139500120130       // Allocate just enough memory to find out how much we really need
139600120130       p_Buffer = %ALLOC(8);
139700120130       clear QUSEC;
139800120130       QUSBPRV = %SIZE(QUSEC);
139900120130       RetreiveFileDescription(buffer :
140000120130                               8 :
140100120130                               rtnFile :
140200120130                               'FILD0200' :
140300120130                               qFile :
140400120130                               '*FIRST' :
140500120130                               '0' :
140600120130                               '*LCL' :
140700120130                               '*EXT' :
140800120130                               QUSEC);
140900120130       if QUSBAVL > 0;
141000120130         // could not open file
141100120130         msgdata = 'Error retreiving file description for ' +
141200120130                   %trimr(%subst(qFile:11:10)) + '/' +
141300120130                   %trimr(%subst(qFile:1:10)) + '.  (' + QUSEI + ')';
141400120130         clear QUSEC;
141500120130         QUSBPRV = 0;
141600120130         sendProgramMessage('CPF9898' :
141700120130                            'QCPFMSG   *LIBL     ' :
141800120130                            %trimr(msgdata) :
141900120130                            %len(%trimr(msgdata)) :
142000120130                            '*ESCAPE   ' :
142100120130                            '*PGMBDY' :
142200120130                            0 :
142300120130                            msgkey :
142400120130                            QUSEC);
142500120130       endif;
142600120130
142700120130       // The API tells us how much memory we really need
142800120130       p_Qddfmt = p_Buffer;
142900120130       bufferSize = Qddbyava;
143000120130
143100120130       // Now allocate the correct amount of memory and call again
143200120130       p_Buffer = %REALLOC(p_Buffer:bufferSize);
143300120130       clear QUSEC;
143400120130       QUSBPRV = %SIZE(QUSEC);
143500120130       RetreiveFileDescription(buffer :
143600120130                               bufferSize :
143700120130                               rtnFile :
143800120130                               'FILD0200' :
143900120130                               qFile :
144000120130                               '*FIRST' :
144100120130                               '0' :
144200120130                               '*LCL' :
144300120130                               '*EXT' :
144400120130                               QUSEC);
144500120130       if QUSBAVL > 0;
144600120130         // could not open file
144700120130         msgdata = 'Error retreiving file description for ' +
144800120130                   %trimr(%subst(qFile:11:10)) + '/' +
144900120130                   %trimr(%subst(qFile:1:10)) + '.  (' + QUSEI + ')';
145000120130         clear QUSEC;
145100120130         QUSBPRV = 0;
145200120130         sendProgramMessage('CPF9898' :
145300120130                            'QCPFMSG   *LIBL     ' :
145400120130                            %trimr(msgdata) :
145500120130                            %len(%trimr(msgdata)) :
145600120130                            '*ESCAPE   ' :
145700120130                            '*PGMBDY' :
145800120130                            0 :
145900120130                            msgkey :
146000120130                            QUSEC);
146100120130       endif;
146200120130
146300120130       json = json_Create();
146400120130
146500120130       // Point to the Format Definition Header
146600120130       p_Qddfmt = p_Buffer;
146700120130
146800120130       // Point to the first Field Header
146900120130       p_Qddffld = p_Qddfmt + %size(Qddfmt);
147000120130
147100120130       for i = 1 to Qddffldnum;
147200120130
147300120130         // Point to Alias Name Entry
147400120130         p_Qddfalis = p_Qddffld + Qddfxals;
147500120130
147600120130         // Determine field name to use as JSON "name"
147700120130         // Qddffldi = field name                      aka: short name
147800120130         // Qddfalsn = alias name (length = Qddfalsl)  aka: long name
147900120130         if Qddfalsl = 0;
148000120130             fieldName = Qddffldi;
148100120130         else;
148200120130             fieldName = %subst(Qddfalsn:1:Qddfalsl);
148300120130         endif;
148400120130
148500120130         // Retreive actual data to use as JSON "value"
148600120130         // Qddfftyp = field type (see constants)
148700120130         // Qddffibo = offset to field
148800120130         // Qddffldb = field length
148900120130         // Qddffldd = number of digits (for numeric)
149000120130         // Qddffldp = decimal positions (for numeric)
149100120130         select;
149200120130           when Qddfftyp = FIELD_TYPE_BINARY; // either 5I0, 10I0, or 20I0
149300120130             p_FieldDS = %ADDR(dataStructure)+Qddffibo;
149400120130             if Qddffldb = 2;
149500120130               json_putInt(json:%TRIMR(fieldName):fieldDS.smallInt);
149600120130             elseif Qddffldb = 4;
149700120130               json_putInt(json:%TRIMR(fieldName):fieldDS.integer);
149800120130             elseif Qddffldb = 8;
149900120130               json_putLong(json:%TRIMR(fieldName):fieldDS.bigInt);
150000120130             endif;
150100120130
150200120130           when Qddfftyp = FIELD_TYPE_FLOAT; // either 4F or 8F
150300120130             p_FieldDS = %ADDR(dataStructure)+Qddffibo;
150400120130             if Qddffldb = 4;
150500120130               json_putDouble(json:%TRIMR(fieldName):fieldDS.Float);
150600120130             elseif Qddffldb = 8;
150700120130               json_putDouble(json:%TRIMR(fieldName):fieldDS.Double);
150800120130             endif;
150900120130
151000120130           when Qddfftyp = FIELD_TYPE_ZONED; // signed (S) type of any supported size
151100120130             data = ExtractNumber(%ADDR(dataStructure)+Qddffibo:
151200120130                                   'L':'*ZONED':Qddffldd:Qddffldp);
151300120130             if qddffldp = 0;
151400120130               // If no decimal places, treat like an integer
151500120130               if qddffldd > 9;
151600120130                 nbrLong = %INT(%TRIMR(data));
151700120130                 json_putLong(json:%TRIMR(fieldName):nbrLong);
151800120130               else;
151900120130                 nbrInt = %INT(%TRIMR(data));
152000120130                 json_putInt(json:%TRIMR(fieldName):nbrInt);
152100120130               endif;
152200120130             else;
152300120130               // If decimal places, treat like a float
152400120130               nbrDouble = %FLOAT(%TRIMR(data));
152500120130               json_putDouble(json:%TRIMR(fieldName):nbrDouble);
152600120130             endif;
152700120130
152800120130           when Qddfftyp = FIELD_TYPE_PACKED; // packed (P) type of any supported size
152900120130             data = ExtractNumber(%ADDR(dataStructure)+Qddffibo:
153000120130                                   'L':'*PACKED':Qddffldd:Qddffldp);
153100120130             if qddffldp = 0;
153200120130               // If no decimal places, treat like an integer
153300120130               if qddffldd > 9;
153400120130                 nbrLong = %INT(%TRIMR(data));
153500120130                 json_putLong(json:%TRIMR(fieldName):nbrLong);
153600120130               else;
153700120130                 nbrInt = %INT(%TRIMR(data));
153800120130                 json_putInt(json:%TRIMR(fieldName):nbrInt);
153900120130               endif;
154000120130             else;
154100120130               // If decimal places, treat like a float
154200120130               nbrDouble = %FLOAT(%TRIMR(data));
154300120130               json_putDouble(json:%TRIMR(fieldName):nbrDouble);
154400120130             endif;
154500120130
154600120130           when Qddfftyp = FIELD_TYPE_CHAR; // character (A) of any supported size
154700120130             json_putString(json:%TRIMR(fieldName):
154800120130                            %TRIMR(%SUBST(dataStructure:Qddffibo+1:Qddffldb)));
154900120130
155000120130           when Qddfftyp = FIELD_TYPE_VARCHAR; // varying char (A) of any supported size
155100120130             // Assumes 2 byte length at from of varying field
155200120130             // I know IBM added longer fields that can have 4 byte length
155300120130             // I don't know how to tell the difference though
155400120130             p_varCharLen = %ADDR(dataStructure)+Qddffibo;
155500120130             json_putString(json:%TRIMR(fieldName):
155600120130                           %TRIMR(%SUBST(dataStructure:Qddffibo+3:varCharLen)));
155700120130
155800120130           when Qddfftyp = FIELD_TYPE_DATE; // date (L) type
155900120130             p_FieldDS = %ADDR(dataStructure)+Qddffibo;
156000120130             json_util_putDate(json:%TRIMR(fieldName):fieldDS.Date);
156100120130
156200120130           when Qddfftyp = FIELD_TYPE_TIME; // time (T) type
156300120130             p_FieldDS = %ADDR(dataStructure)+Qddffibo;
156400120130             json_util_putTime(json:%TRIMR(fieldName):fieldDS.Time);
156500120130
156600120130           when Qddfftyp = FIELD_TYPE_TIMESTAMP; // timestamp (Z) type
156700120130             p_FieldDS = %ADDR(dataStructure)+Qddffibo;
156800120130             json_util_putTimestamp(json:%TRIMR(fieldName):fieldDS.Timestamp);
156900120130
157000120130           other;
157100120130               // Unknown type?!?
157200120130
157300120130
157400120130         endsl;
157500120130
157600120130         // Point to next Field Header
157700120130         p_Qddffld = p_Qddffld + Qddfdefl;
157800120130
157900120130       endfor;
158000120130
158100120130       // Free up space
158200120130       dealloc p_Buffer;
158300120130
158400120130       return json;
158500120130      /end-free
158600120130     P                 E
158700120130
158800120130
158900120130     /**
159000120130      * \brief Convert record data to an edited number.
159100120130      *
159200120130      *  This makes it easy to extract zoned and packed fields from
159300120130      *  a substring of a record.
159400120130      *
159500120130      * \param Field pointer
159600120130      * \param Edit code
159700120130      * \param Field type (*ZONED or *PACKED)
159800120130      * \param Number of digits
159900120130      * \param Number of decimal places
160000120130      *
160100120130      * \return String containing edited value
160200120130      *
160300120130      * \author Brian Garland
160400120130      *
160500120130      * \throws CPF9898 File not found
160600120130      * \throws CPF9898 Error building JSON object
160700120130      */
160800120130     P extractNumber   B
160900120130     D                 PI           256A
161000120130     D  fieldPtr                       *   value
161100120130     D  editCode                      1A   value
161200120130     D  fieldType                    10A   value
161300120130     D  numDigits                     2P 0 value
161400120130     D  numDecimals                   2P 0 value
161500120130
161600120130     D editMask        S            256A
161700120130     D editMaskLen     S             10I 0
161800120130     D outputLen       S             10I 0
161900120130     D zeroFillChar    S              1A
162000120130     D returnValue     S            256A
162100120130     D inputField      S             31A   BASED(fieldPtr)
162200120130
162300120130      /free
162400120130
162500120130       clear returnValue;
162600120130
162700120130       // Invoke the convert edit code API
162800120130       clear QUSEC;
162900120130       QUSBPRV = %SIZE(QUSEC);
163000120130       ConvertEditCode(editMask :
163100120130                       editMaskLen :
163200120130                       outputLen :
163300120130                       zeroFillChar:
163400120130                       editCode :
163500120130                       ' ' :
163600120130                       numDigits :
163700120130                       numDecimals :
163800120130                       QUSEC);
163900120130
164000120130       if QUSBAVL > 0;
164100120130         return *blanks;
164200120130       endif;
164300120130
164400120130       // Invoke the Edit API
164500120130       clear QUSEC;
164600120130       QUSBPRV = %SIZE(QUSEC);
164700120130       Edit(returnValue :
164800120130            outputLen :
164900120130            inputField :
165000120130            fieldType :
165100120130            numDigits :
165200120130            editMask :
165300120130            editMaskLen :
165400120130            zeroFillChar :
165500120130            QUSEC);
165600120130
165700120130       if QUSBAVL > 0;
165800120130         return *blanks;
165900120130       endif;
166000120130
166100120130       return returnValue;
166200120130      /end-free
166300120130     P                 E
166400120130
