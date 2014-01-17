000100120130     /**
000200120130      * \brief List Implementation : ArrayList
000300120130      *
000400120130      * A list implementation with a memory block as backend. The memory for
000500120130      * will be dynamically allocated and deallocated. Therefore the list
000600120130      * can grow and shrink dynamically as requested.
000700120130      *
000800120130      * <br><br>
000900120130      *
001000120130      * This list implementation works with a head data structure.
001100120130      *
001200120130      * <br><br>
001300120130      *
001400120130      * The entries are stored in an "array" which consists of pointers.
001500120130      * The pointers of the array store the start address of the memory
001600120130      * of the values.
001700120130      *
001800120130      * <br><br>
001900120130      *
002000120130      * All values are internally null-terminated. So a value of x'00'
002100120130      * won't work as expected and should be avoided.
002200120130      *
002300120130      * <br><br>
002400120130      *
002500120130      * Access to the element is accomplished through accessing the arraylist
002600120130      * with an index (position). The index is 0-based. So the first element
002700120130      * has an index of 0 (zero).
002800120130      *
002900120130      * \author Mihael Schmidt
003000120130      * \date   16.04.2011
003100120130      */
003200120130
003300120130
003400120130
003500120130      *------------------------------------------------------------------------
003600120130      *
003700120130      * Copyright (c) 2011 Mihael Schmidt
003800120130      * All rights reserved.
003900120130      *
004000120130      * This file is part of the ARRAYLIST service program.
004100120130      *
004200120130      * ARRAYLIST is free software: you can redistribute it and/or modify it under
004300120130      * the terms of the GNU Lesser General Public License as published by
004400120130      * the Free Software Foundation, either version 3 of the License, or
004500120130      * any later version.
004600120130      *
004700120130      * ARRAYLIST is distributed in the hope that it will be useful,
004800120130      * but WITHOUT ANY WARRANTY; without even the implied warranty of
004900120130      * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
005000120130      * GNU Lesser General Public License for more details.
005100120130      *
005200120130      * You should have received a copy of the GNU Lesser General Public
005300120130      * License along with ARRAYLIST.  If not, see http://www.gnu.org/licenses/.
005400120130      *
005500120130      *------------------------------------------------------------------------
005600120130
005700120130
005800120130
005900120130     H nomain
006000120130     HCOPYRIGHT('Copyright (c) 2011 Mihael Schmidt. All rights reserved.')
006001120130     H bnddir('QC2LE')
006100120130
006200120130
006300120130      *---------------------------------------------------------------
006400120130      * Prototypen
006500120130      *---------------------------------------------------------------
006600120130     D increment       PR
006700120130     D   arraylist                     *   const
006800120130     D   size                        10U 0 const options(*nopass)
006900120130      *
007000120130     D sendEscapeMessage...
007100120130     D                 PR
007200120130     D   message                  65535A   const varying
007300120130      *
007400120130     D getEntry...
007500120130     D                 PR              *
007600120130     D   arraylist                     *   const
007700120130     D   pos                         10I 0 const
007800120130      *
007900120130     D moveElements...
008000120130     D                 PR
008100120130     D   arraylist                     *   const
008200120130     D   pos                         10U 0 const
008300120130     D   pDownBy                     10I 0 const options(*nopass)
008400120130
008500120130      /include qjsontxt,arraylist
008600120130      /include qjsontxt,libc
008700120130
008800120130
008900120130      *-------------------------------------------------------------------------
009000120130      * Constants
009100120130      *-------------------------------------------------------------------------
009200120130      *
009300120130      * Incrementation size of 0 (zero) doubles the size of the array.
009400120130      *
009500120130     D DEFAULT_INCREMENT_SIZE...
009600120130     D                 C                    0
009700120130     D DEFAULT_INIT_SIZE...
009800120130     D                 C                   10
009900120130
010000120130
010100120130      *-------------------------------------------------------------------------
010200120130      * Variables
010300120130      *-------------------------------------------------------------------------
010400120130     D tmpl_header     DS                  qualified based(nullPointer) align
010500120130     D   elementsAllocated...
010600120130     D                               10I 0
010700120130     D   elementCount                10I 0
010800120130     D   elementData                   *
010900120130     D   incrementSize...
011000120130     D                               10U 0
011100120130      *
011200120130     D tmpl_entry      DS                  qualified align based(nullPointer)
011300120130     D   value                         *
011400120130     D   length                      10I 0
011500120130      // so that the pointer is aligned on a 16-byte boundary we need to fill
011600120130      // this data structure up to the next 16 byte
011700120130     D   reserved                    12A
011800120130      *
011900120130     D hexNull         S              1A   inz(x'00')
012000120130
012100120130
012200120130      *-------------------------------------------------------------------------
012300120130      * Procedures
012400120130      *-------------------------------------------------------------------------
012500120130
012600120130     /**
012700120130      * \brief Create arraylist
012800120130      *
012900120130      * Creates an arraylist.
013000120130      *
013100120130      * <br><br>
013200120130      *
013300120130      * The initial size is 10. The default increment size
013400120130      * is 0 which means with each incrementation the arraylist will double its
013500120130      * size.
013600120130      *
013700120130      * \author Mihael Schmidt
013800120130      * \date   16.04.2011
013900120130      *
014000120130      * \param Initial arraylist size (default: 10)
014100120130      * \param Incrementation size (default: 0 - double)
014200120130      *
014300120130      * \return Pointer to arraylist
014400120130      */
014500120130     P arraylist_create...
014600120130     P                 B                   export
014700120130     D                 PI              *
014800120130     D   initSize                    10U 0 const options(*nopass)
014900120130     D   incSize                     10U 0 const options(*nopass)
015000120130      *
015100120130     D arraylist       S               *
015200120130     D header          DS                  likeds(tmpl_header) based(arraylist)
015300120130      /free
015400120130       arraylist = %alloc(%size(tmpl_header));
015500120130
015600120130       header.elementCount = 0;
015700120130       header.elementData = *null;
015800120130
015900120130       // init arraylist size if passed
016000120130       if (%parms() = 0);
016100120130         header.elementsAllocated = DEFAULT_INIT_SIZE;
016200120130         header.incrementSize = DEFAULT_INCREMENT_SIZE;
016300120130       elseif (%parms() = 1);
016400120130         header.incrementSize = DEFAULT_INCREMENT_SIZE;
016500120130         header.elementsAllocated = initSize;
016600120130       elseif (%parms() = 2);
016700120130         header.incrementSize = incSize;
016800120130         header.elementsAllocated = initSize;
016900120130       endif;
017000120130
017100120130       // alloc memory for entries
017200120130       header.elementData =
017300120130           %alloc(header.elementsAllocated * %size(tmpl_entry));
017400120130
017500120130       return arraylist;
017600120130      /end-free
017700120130     P                 E
017800120130
017900120130
018000120130     /**
018100120130      * \brief Dispose arraylist
018200120130      *
018300120130      * Disposes the arraylist and all its elements. The pointer will be set
018400120130      * to *null.
018500120130      *
018600120130      * \author Mihael Schmidt
018700120130      * \date   16.04.2011
018800120130      *
018900120130      * \param Pointer to arraylist
019000120130      */
019100120130     P arraylist_dispose...
019200120130     P                 B                   export
019300120130     D                 PI
019400120130     D   arraylist                     *
019500120130      *
019600120130     D header          DS                  likeds(tmpl_header) based(arraylist)
019700120130     D i               S             10I 0
019800120130      /free
019900120130       if (arraylist <> *null);
020000120130         arraylist_clear(arraylist);
020100120130         dealloc(n) arraylist;
020200120130       endif;
020300120130      /end-free
020400120130     P                 E
020500120130
020600120130
020700120130     /**
020800120130      * \brief Add element
020900120130      *
021000120130      * Adds an element to the arraylist by copying the content to dynamically
021100120130      * allocated memory. Values are stored null-terminated.
021200120130      *
021300120130      * <br><br>
021400120130      *
021500120130      * If a position is passed the caller must be certain that the
021600120130      * position is inside the bounds of the arraylist. If the position is
021700120130      * outside of the arraylist an escape message will be sent.
021800120130      *
021900120130      * \author Mihael Schmidt
022000120130      * \date   16.04.2011
022100120130      *
022200120130      * \param Pointer to arraylist
022300120130      * \param Pointer to new entry
022400120130      * \param Length of new entry (in byte)
022500120130      * \param Position
022600120130      */
022700120130     P arraylist_add   B                   export
022800120130     D                 PI
022900120130     D   arraylist                     *   const
023000120130     D   value                         *   const
023100120130     D   valueLength                 10U 0 const
023200120130     D   pPos                        10U 0 const options(*nopass)
023300120130      *
023400120130     D pos             S             10U 0
023500120130     D header          DS                  likeds(tmpl_header) based(arraylist)
023600120130     D ptr             S               *
023700120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
023800120130      /free
023900120130       // determine the position
024000120130       if (%parms() = 3);
024100120130         pos = header.elementCount;
024200120130       elseif (%parms() = 4);
024300120130         // if a position was passed, check if it is inside the arraylist
024400120130         if (pPos >= header.elementCount);
024500120130           sendEscapeMessage('Position out of bounds');
024600120130         else;
024700120130           pos = pPos;
024800120130           moveElements(arraylist : pos);
024900120130         endif;
025000120130       endif;
025100120130
025200120130       // make some space if necessary
025300120130       if (header.elementCount = header.elementsAllocated);
025400120130         increment(arraylist);
025500120130       endif;
025600120130
025700120130       // get free entry
025800120130       ptr = getEntry(arraylist : pos);
025900120130
026000120130       // alloc memory for this entry
026100120130       entry.value = %alloc(valueLength + 1); // +1 for the null byte
026200120130       entry.length = valueLength;
026300120130
026400120130       // copy value to the entry
026500120130       memcpy(entry.value : value : valueLength);
026600120130
026700120130       // set null to the last byte
026800120130       memcpy(entry.value + valueLength : %addr(hexNull) : 1);
026900120130
027000120130       // update header
027100120130       header.elementCount += 1;
027200120130      /end-free
027300120130     P                 E
027400120130
027500120130
027600120130     /**
027700120130      * \brief Append element to the arraylist
027800120130      *
027900120130      * Adds an element to the end of the arraylist by copying the content to
028000120130      * dynamically allocated memory. Values are stored null-terminated.
028100120130      *
028200120130      * \author Mihael Schmidt
028300120130      * \date   16.04.2011
028400120130      *
028500120130      * \param Pointer to arraylist
028600120130      * \param Pointer to new entry
028700120130      * \param Length of new entry (in byte)
028800120130      */
028900120130     P arraylist_addLast...
029000120130     P                 B                   export
029100120130     D                 PI
029200120130     D   arraylist                     *   const
029300120130     D   value                         *   const
029400120130     D   valueLength                 10U 0 const
029500120130      /free
029600120130       arraylist_add(arraylist : value : valueLength);
029700120130      /end-free
029800120130     P                 E
029900120130
030000120130
030100120130     /**
030200120130      * \brief Prepend element to the arraylist
030300120130      *
030400120130      * Adds an element to the beginning of the arraylist by copying the content to
030500120130      * dynamically allocated memory. Values are stored null-terminated. If the
030600120130      * the arraylist is not empty all other elements will be pushed down by one
030700120130      * position.
030800120130      *
030900120130      * \author Mihael Schmidt
031000120130      * \date   16.04.2011
031100120130      *
031200120130      * \param Pointer to arraylist
031300120130      * \param Pointer to new entry
031400120130      * \param Length of new entry (in byte)
031500120130      */
031600120130     P arraylist_addFirst...
031700120130     P                 B                   export
031800120130     D                 PI
031900120130     D   arraylist                     *   const
032000120130     D   value                         *   const
032100120130     D   valueLength                 10U 0 const
032200120130      /free
032300120130       arraylist_add(arraylist : value : valueLength : 0);
032400120130      /end-free
032500120130     P                 E
032600120130
032700120130     /**
032800120130      * \brief Get arraylist size
032900120130      *
033000120130      * Returns the number of elements currently in the arraylist.
033100120130      *
033200120130      * \author Mihael Schmidt
033300120130      * \date   16.04.2011
033400120130      *
033500120130      * \param Pointer to arraylist
033600120130      *
033700120130      * \return Number of elements in the arraylist
033800120130      */
033900120130     P arraylist_getSize...
034000120130     P                 B                   export
034100120130     D                 PI            10U 0
034200120130     D   arraylist                     *   const
034300120130      *
034400120130     D header          DS                  likeds(tmpl_header) based(arraylist)
034500120130     D size            S             10U 0
034600120130      /free
034700120130       return header.elementCount;
034800120130      /end-free
034900120130     P                 E
035000120130
035100120130
035200120130     /**
035300120130      * \brief Get arraylist capacity
035400120130      *
035500120130      * Returns the number of elements which can be stored in the current
035600120130      * arraylist.
035700120130      *
035800120130      * \author Mihael Schmidt
035900120130      * \date   16.04.2011
036000120130      *
036100120130      * \param Pointer to arraylist
036200120130      *
036300120130      * \return Number of elements able to store in the arraylist
036400120130      */
036500120130     P arraylist_getCapacity...
036600120130     P                 B                   export
036700120130     D                 PI            10U 0
036800120130     D   arraylist                     *   const
036900120130      *
037000120130     D header          DS                  likeds(tmpl_header) based(arraylist)
037100120130     D size            S             10U 0
037200120130      /free
037300120130       return header.elementsAllocated;
037400120130      /end-free
037500120130     P                 E
037600120130
037700120130
037800120130
037900120130     /**
038000120130      * \brief Get element
038100120130      *
038200120130      * Returns a pointer to the elment at the given position. The element is
038300120130      * null-terminated. Changes to the element through the returned pointer is
038400120130      * not recommended. Use the appropriate procedures instead.
038500120130      *
038600120130      * <br><br>
038700120130      *
038800120130      * If the requested element position is not in the arraylist then an escape
038900120130      * message will be sent.
039000120130      *
039100120130      * \author Mihael Schmidt
039200120130      * \date   16.04.2011
039300120130      *
039400120130      * \param Pointer to arraylist
039500120130      * \param Position
039600120130      *
039700120130      * \return Pointer to the null-terminated element
039800120130      *         or *null if arraylist is empty
039900120130      */
040000120130     P arraylist_get   B                   export
040100120130     D                 PI              *
040200120130     D   arraylist                     *   const
040300120130     D   index                       10U 0 const
040400120130      *
040500120130     D header          DS                  likeds(tmpl_header) based(arraylist)
040600120130     D ptr             S               *
040700120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
040800120130      /free
040900120130       if (header.elementCount = 0);
041000120130         return *null;
041100120130       elseif (index >= header.elementCount);
041200120130         sendEscapeMessage('Position out of bounds');
041300120130       endif;
041400120130
041500120130       ptr = getEntry(arraylist : index);
041600120130
041700120130       return entry.value;
041800120130      /end-free
041900120130     P                 E
042000120130
042100120130
042200120130     /**
042300120130      * \brief Get first element
042400120130      *
042500120130      * Returns a pointer to the first elment in the arraylist. The element is
042600120130      * null-terminated. Changes to the element through the returned pointer is
042700120130      * not recommended. Use the appropriate procedures instead.
042800120130      *
042900120130      * \author Mihael Schmidt
043000120130      * \date   16.04.2011
043100120130      *
043200120130      * \param Pointer to arraylist
043300120130      *
043400120130      * \return Pointer to the null-terminated element or *null if the arraylist is empty
043500120130      */
043600120130     P arraylist_getFirst...
043700120130     P                 B                   export
043800120130     D                 PI              *
043900120130     D   arraylist                     *   const
044000120130      *
044100120130     D header          DS                  likeds(tmpl_header) based(arraylist)
044200120130      /free
044300120130       return arraylist_get(arraylist : 0);
044400120130      /end-free
044500120130     P                 E
044600120130
044700120130
044800120130     /**
044900120130      * \brief Get last element
045000120130      *
045100120130      * Returns a pointer to the last elment in the arraylist. The element is
045200120130      * null-terminated. Changes to the element through the returned pointer is
045300120130      * not recommended. Use the appropriate procedures instead.
045400120130      *
045500120130      * \author Mihael Schmidt
045600120130      * \date   16.04.2011
045700120130      *
045800120130      * \param Pointer to arraylist
045900120130      *
046000120130      * \return Pointer to the null-terminated element
046100120130      *         or *null if the arraylist is empty
046200120130      */
046300120130     P arraylist_getLast...
046400120130     P                 B                   export
046500120130     D                 PI              *
046600120130     D   arraylist                     *   const
046700120130      *
046800120130     D header          DS                  likeds(tmpl_header) based(arraylist)
046900120130      /free
047000120130       return arraylist_get(arraylist : header.elementCount - 1);
047100120130      /end-free
047200120130     P                 E
047300120130
047400120130
047500120130     /**
047600120130      * \brief Check if arraylist is empty
047700120130      *
047800120130      * Checks if the arraylist is empty.
047900120130      *
048000120130      * \author Mihael Schmidt
048100120130      * \date   16.04.2011
048200120130      *
048300120130      * \param Pointer to the arraylist
048400120130      *
048500120130      * \return *on = arraylist is empty <br>
048600120130      *         *off = arraylist is not empty
048700120130      */
048800120130     P arraylist_isEmpty...
048900120130     P                 B                   export
049000120130     D                 PI              N
049100120130     D   arraylist                     *   const
049200120130      *
049300120130     D header          DS                  likeds(tmpl_header) based(arraylist)
049400120130      /free
049500120130       return (header.elementCount = 0);
049600120130      /end-free
049700120130     P                 E
049800120130
049900120130
050000120130     /**
050100120130      * \brief Clear arraylist
050200120130      *
050300120130      * Deletes all entries. The capacity of the arraylist remains the same.
050400120130      *
050500120130      * \author Mihael Schmidt
050600120130      * \date   16.04.2011
050700120130      *
050800120130      * \param Pointer to the arraylist
050900120130      */
051000120130     P arraylist_clear...
051100120130     P                 B                   export
051200120130     D                 PI
051300120130     D   arraylist                     *   const
051400120130      *
051500120130     D header          DS                  likeds(tmpl_header) based(arraylist)
051600120130     D i               S             10I 0
051700120130     D ptr             S               *
051800120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
051900120130      /free
052000120130       for i = 0 to header.elementCount-1;
052100120130         ptr = getEntry(arraylist : i);
052200120130         dealloc(n) entry.value;
052300120130       endfor;
052400120130
052500120130       // TODO reduce array size?
052600120130
052700120130       header.elementCount = 0;
052800120130      /end-free
052900120130     P                 E
053000120130
053100120130
053200120130     /**
053300120130      * \brief Remove an element
053400120130      *
053500120130      * Removes an element from the arraylist. If the given position is outside of
053600120130      * the bounds of the arraylist an escape message will be sent.
053700120130      *
053800120130      * \author Mihael Schmidt
053900120130      * \date   16.04.2011
054000120130      *
054100120130      * \param Pointer to the arraylist
054200120130      * \param Element index to be removed
054300120130      */
054400120130     P arraylist_remove...
054500120130     P                 B                   export
054600120130     D                 PI
054700120130     D   arraylist                     *   const
054800120130     D   index                       10U 0 const
054900120130      *
055000120130     D header          DS                  likeds(tmpl_header) based(arraylist)
055100120130     D ptr             S               *
055200120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
055300120130      /free
055400120130       if (index >= header.elementCount);
055500120130         sendEscapeMessage('Position out of bounds');
055600120130       endif;
055700120130
055800120130       ptr = getEntry(arraylist : index);
055900120130       dealloc(n) entry.value; // release allocated memory
056000120130
056100120130       // check if it is the last element
056200120130       if (index <> header.elementCount -1); // not the last => move other elements
056300120130         moveElements(arraylist : index + 1 : -1);
056400120130       endif;
056500120130
056600120130       header.elementCount -= 1;
056700120130      /end-free
056800120130     P                 E
056900120130
057000120130
057100120130     /**
057200120130      * \brief Remove the first element
057300120130      *
057400120130      * Removes the first element from the arraylist.
057500120130      *
057600120130      * \author Mihael Schmidt
057700120130      * \date   16.04.2011
057800120130      *
057900120130      * \param Pointer to the arraylist
058000120130      */
058100120130     P arraylist_removeFirst...
058200120130     P                 B                   export
058300120130     D                 PI
058400120130     D   arraylist                     *   const
058500120130      /free
058600120130       arraylist_remove(arraylist : 0);
058700120130      /end-free
058800120130     P                 E
058900120130
059000120130
059100120130     /**
059200120130      * \brief Remove the last element
059300120130      *
059400120130      * Removes the last element from the arraylist.
059500120130      *
059600120130      * \author Mihael Schmidt
059700120130      * \date   16.04.2011
059800120130      *
059900120130      * \param Pointer to the arraylist
060000120130      */
060100120130     P arraylist_removeLast...
060200120130     P                 B                   export
060300120130     D                 PI
060400120130     D   arraylist                     *   const
060500120130      *
060600120130     D header          DS                  likeds(tmpl_header) based(arraylist)
060700120130      /free
060800120130       if (header.elementCount > 0);
060900120130         arraylist_remove(arraylist : arraylist_getSize(arraylist) - 1);
061000120130       endif;
061100120130      /end-free
061200120130     P                 E
061300120130
061400120130
061500120130     /**
061600120130      * \brief Remove a range of elements
061700120130      *
061800120130      * Removes a range of elements from the arraylist. The range must be inside
061900120130      * the bounds of the arraylist. If the range is outside the arraylist an
062000120130      * escape message will be sent.
062100120130      *
062200120130      * \author Mihael Schmidt
062300120130      * \date   16.04.2011
062400120130      *
062500120130      * \param Pointer to the arraylist
062600120130      * \param Range starting index
062700120130      * \param Number of elements to remove
062800120130      */
062900120130     P arraylist_removeRange...
063000120130     P                 B                   export
063100120130     D                 PI
063200120130     D   arraylist                     *   const
063300120130     D   index                       10U 0 const
063400120130     D   count                       10U 0 const
063500120130      *
063600120130     D header          DS                  likeds(tmpl_header) based(arraylist)
063700120130     D i               S             10I 0
063800120130      /free
063900120130       if (index + count -1 >= header.elementCount);
064000120130         sendEscapeMessage('Position out of bounds');
064100120130       endif;
064200120130
064300120130       for i = index to index + count - 1;
064400120130         // always index for position because the other elements have moved up by one
064500120130         arraylist_remove(arraylist : index);
064600120130       endfor;
064700120130
064800120130      /end-free
064900120130     P                 E
065000120130
065100120130
065200120130     /**
065300120130      * \brief Contains element
065400120130      *
065500120130      * Checks if the arraylist contains the passed data.
065600120130      * The check will be done byte by byte, so trailing spaces also count.
065700120130      *
065800120130      * \author Mihael Schmidt
065900120130      * \date   16.04.2011
066000120130      *
066100120130      * \param Pointer to the arraylist
066200120130      * \param Pointer to data
066300120130      * \param Data length
066400120130      *
066500120130      * \return *on if the arraylist contains the data, *off otherwise
066600120130      */
066700120130     P arraylist_contains...
066800120130     P                 B                   export
066900120130     D                 PI              N
067000120130     D   arraylist                     *   const
067100120130     D   value                         *   const
067200120130     D   valueLength                 10U 0 const
067300120130      /free
067400120130       return (arraylist_indexOf(arraylist : value : valueLength) >= 0);
067500120130      /end-free
067600120130     P                 E
067700120130
067800120130
067900120130     /**
068000120130      * \brief Get index of element
068100120130      *
068200120130      * Returns the index of the passed element.
068300120130      *
068400120130      * \author Mihael Schmidt
068500120130      * \date   16.04.2011
068600120130      *
068700120130      * \param Pointer to the arraylist
068800120130      * \param Pointer to data
068900120130      * \param Data length
069000120130      *
069100120130      * \return index of the element or -1 if the element is not in the arraylist
069200120130      */
069300120130     P arraylist_indexOf...
069400120130     P                 B                   export
069500120130     D                 PI            10I 0
069600120130     D   arraylist                     *   const
069700120130     D   value                         *   const
069800120130     D   valueLength                 10U 0 const
069900120130      *
070000120130     D header          DS                  likeds(tmpl_header) based(arraylist)
070100120130     D ptr             S               *
070200120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
070300120130     D i               S             10I 0
070400120130     D retVal          S             10I 0 inz(-1)
070500120130      /free
070600120130       for i = 0 to header.elementCount - 1;
070700120130         ptr = header.elementData + (i * %size(tmpl_entry));
070800120130         if (entry.length = valueLength);
070900120130
071000120130           if (memcmp(entry.value : value : valueLength) = 0);
071100120130             retVal = i;
071200120130             leave;
071300120130           endif;
071400120130
071500120130         endif;
071600120130       endfor;
071700120130
071800120130       return retVal;
071900120130      /end-free
072000120130     P                 E
072100120130
072200120130
072300120130     /**
072400120130      * \brief Get last index of element
072500120130      *
072600120130      * Returns the last index of the passed element.
072700120130      *
072800120130      * \author Mihael Schmidt
072900120130      * \date   16.04.2011
073000120130      *
073100120130      * \param Pointer to the arraylist
073200120130      * \param Pointer to data
073300120130      * \param Data length
073400120130      *
073500120130      * \return last index of the element
073600120130      *         or -1 if the element is not in the arraylist
073700120130      */
073800120130     P arraylist_lastIndexOf...
073900120130     P                 B                   export
074000120130     D                 PI            10I 0
074100120130     D   arraylist                     *   const
074200120130     D   value                         *   const
074300120130     D   valueLength                 10U 0 const
074400120130      *
074500120130     D header          DS                  likeds(tmpl_header) based(arraylist)
074600120130     D ptr             S               *
074700120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
074800120130     D i               S             10I 0
074900120130     D retVal          S             10I 0 inz(-1)
075000120130      /free
075100120130       for i = header.elementCount - 1 downto 0;
075200120130         ptr = header.elementData + (i * %size(tmpl_entry));
075300120130         if (entry.length = valueLength);
075400120130
075500120130           if (memcmp(entry.value : value : valueLength) = 0);
075600120130             retVal = i;
075700120130             leave;
075800120130           endif;
075900120130
076000120130         endif;
076100120130       endfor;
076200120130
076300120130       return retVal;
076400120130      /end-free
076500120130     P                 E
076600120130
076700120130
076800120130     /**
076900120130      * \brief Frequency of element
077000120130      *
077100120130      * Returns the number of times the passed element is in the arraylist.
077200120130      *
077300120130      * \author Mihael Schmidt
077400120130      * \date   2011-04-19
077500120130      *
077600120130      * \param Pointer to the arraylist
077700120130      * \param Pointer to data
077800120130      * \param Data length
077900120130      *
078000120130      * \return frequency of the passed data in the arraylist
078100120130      */
078200120130     P arraylist_frequency...
078300120130     P                 B                   export
078400120130     D                 PI            10U 0
078500120130     D   arraylist                     *   const
078600120130     D   value                         *   const
078700120130     D   valueLength                 10U 0 const
078800120130      *
078900120130     D header          DS                  likeds(tmpl_header) based(arraylist)
079000120130     D ptr             S               *
079100120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
079200120130     D i               S             10I 0
079300120130     D retVal          S             10U 0
079400120130      /free
079500120130       for i = 0 to header.elementCount - 1;
079600120130         ptr = header.elementData + (i * %size(tmpl_entry));
079700120130         if (entry.length = valueLength);
079800120130
079900120130           if (memcmp(entry.value : value : valueLength) = 0);
080000120130             retVal += 1;
080100120130           endif;
080200120130
080300120130         endif;
080400120130       endfor;
080500120130
080600120130       return retVal;
080700120130      /end-free
080800120130     P                 E
080900120130
081000120130
081100120130     /**
081200120130      * \brief Replace element
081300120130      *
081400120130      * Replaces the given element with the new data.
081500120130      *
081600120130      * \author Mihael Schmidt
081700120130      * \date 2011-04-19
081800120130      *
081900120130      * \param Pointer to the arraylist
082000120130      * \param Index to data which should be replaced
082100120130      * \param Pointer to the new data
082200120130      * \param Length of the new data
082300120130      */
082400120130     P arraylist_replace...
082500120130     P                 B                   export
082600120130     D                 PI
082700120130     D   arraylist                     *   const
082800120130     D   index                       10U 0 const
082900120130     D   value                         *   const
083000120130     D   valueLength                 10U 0 const
083100120130      *
083200120130     D header          DS                  likeds(tmpl_header) based(arraylist)
083300120130     D ptr             S               *
083400120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
083500120130      /free
083600120130       // if a position was passed, check if it is inside the array
083700120130       if (index >= header.elementCount);
083800120130         sendEscapeMessage('Position out of bounds.');
083900120130       endif;
084000120130
084100120130       // get entry
084200120130       ptr = getEntry(arraylist : index);
084300120130
084400120130       // alloc memory for this entry
084500120130       entry.value = %realloc(entry.value : valueLength + 1); // +1 for the null byte
084600120130       entry.length = valueLength;
084700120130
084800120130       // copy value to the entry
084900120130       memcpy(entry.value : value : valueLength);
085000120130
085100120130       // set null to the last byte
085200120130       memcpy(entry.value + valueLength : %addr(hexNull) : 1);
085300120130      /end-free
085400120130     P                 E
085500120130
085600120130
085700120130     /**
085800120130      * \brief Create a sublist
085900120130      *
086000120130      * Returns a sublist of this arraylist.
086100120130      *
086200120130      * \author Mihael Schmidt
086300120130      * \date 2011-04-19
086400120130      *
086500120130      * \param Pointer to the arraylist
086600120130      *
086700120130      * \return Pointer to the new arraylist (sublist)
086800120130      */
086900120130     P arraylist_sublist...
087000120130     P                 B                   export
087100120130     D                 PI              *
087200120130     D   arraylist                     *   const
087300120130     D   startIndex                  10U 0 const
087400120130     D   length                      10U 0 const options(*nopass)
087500120130      *
087600120130     D header          DS                  likeds(tmpl_header) based(arraylist)
087700120130     D ptr             S               *
087800120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
087900120130      *
088000120130     D i               S             10U 0
088100120130     D endIndex        S             10U 0
088200120130     D sublist         S               *
088300120130      /free
088400120130       sublist = arraylist_create();
088500120130
088600120130       if (%parms() = 3);
088700120130         endIndex = startIndex + length;
088800120130         endIndex -= 1;
088900120130       else;
089000120130         endIndex = header.elementCount - 1;
089100120130       endif;
089200120130
089300120130       if (startIndex >= header.elementCount);
089400120130         sendEscapeMessage('Start index position out of bounds.');
089500120130       endif;
089600120130
089700120130       if (endIndex >= header.elementCount);
089800120130         sendEscapeMessage('End index position out of bounds.');
089900120130       endif;
090000120130
090100120130       for i = startIndex to endIndex;
090200120130         ptr = getEntry(arraylist : i);
090300120130         arraylist_add(sublist : entry.value : entry.length);
090400120130       endfor;
090500120130
090600120130       return sublist;
090700120130      /end-free
090800120130     P                 E
090900120130
091000120130
091100120130     /**
091200120130      * \brief Create a copy of the arraylist
091300120130      *
091400120130      * Returns a copy of the arraylist.
091500120130      *
091600120130      * \author Mihael Schmidt
091700120130      * \date 2011-04-19
091800120130      *
091900120130      * \param Pointer to the arraylist
092000120130      *
092100120130      * \return Pointer to the new arraylist
092200120130      */
092300120130     P arraylist_copy...
092400120130     P                 B                   export
092500120130     D                 PI              *
092600120130     D   arraylist                     *   const
092700120130      *
092800120130     D copyList        S               *
092900120130      /free
093000120130       copyList = arraylist_sublist(arraylist : 0);
093100120130
093200120130       return copyList;
093300120130      /end-free
093400120130     P                 E
093500120130
093600120130
093700120130     /**
093800120130      * \brief Swap arraylist items
093900120130      *
094000120130      * \author Mihael Schmidt
094100120130      * \date 2011-04-19
094200120130      *
094300120130      * \param Pointer to the arraylist
094400120130      * \param Item to swap
094500120130      * \param Item to swap
094600120130      */
094700120130     P arraylist_swap...
094800120130     P                 B                   export
094900120130     D                 PI
095000120130     D   arraylist                     *   const
095100120130     D   itemPos1                    10U 0 const
095200120130     D   itemPos2                    10U 0 const
095300120130      *
095400120130     D header          DS                  likeds(tmpl_header) based(arraylist)
095500120130     D ptr1            S               *
095600120130     D entry1          DS                  likeds(tmpl_entry) based(ptr1)
095700120130     D ptr2            S               *
095800120130     D entry2          DS                  likeds(tmpl_entry) based(ptr2)
095900120130     D tmpEntry        DS                  likeds(tmpl_entry)
096000120130      /free
096100120130       // if a position was passed, check if it is inside the array
096200120130       if (itemPos1 >= header.elementCount or
096300120130           itemPos2 >= header.elementCount);
096400120130         sendEscapeMessage('Position out of bounds');
096500120130       endif;
096600120130
096700120130       ptr1 = getEntry(arraylist : itemPos1);
096800120130       ptr2 = getEntry(arraylist : itemPos2);
096900120130
097000120130       tmpEntry = entry1;
097100120130       entry1 = entry2;
097200120130       entry2 = tmpEntry;
097300120130      /end-free
097400120130     P                 E
097500120130
097600120130
097700120130     /**
097800120130      * \brief Add all elements to the arraylist
097900120130      *
098000120130      * Adds all elements from the source arraylist to the destination arraylist.
098100120130      *
098200120130      * \param Pointer to the destination arraylist
098300120130      * \param Pointer to the source arraylist
098400120130      */
098500120130     P arraylist_addAll...
098600120130     P                 B                   export
098700120130     D                 PI
098800120130     D   destArraylist...
098900120130     D                                 *   const
099000120130     D   sourceArraylist...
099100120130     D                                 *   const
099200120130      *
099300120130     D header          DS                  likeds(tmpl_header)
099400120130     D                                     based(sourceArraylist)
099500120130     D ptr             S               *
099600120130     D entry           Ds                  likeds(tmpl_entry) based(ptr)
099700120130      *
099800120130     D i               S             10U 0
099900120130      /free
100000120130       for i = 0 to header.elementCount -1;
100100120130         ptr = getEntry(sourceArraylist : i);
100200120130         arraylist_add(destArraylist : entry.value : entry.length);
100300120130       endfor;
100400120130      /end-free
100500120130     P                 E
100600120130
100700120130
100800120130     /**
100900120130      * \brief Add integer value to the arraylist
101000120130      *
101100120130      * This procedure is a wrapper for the <em>add</em> procedure and
101200120130      * adds an integer to the arraylist.
101300120130      *
101400120130      * \param Pointer to the arraylist
101500120130      * \param Value
101600120130      * \param Position (default: append)
101700120130      */
101800120130     P arraylist_addInteger...
101900120130     P                 B                   export
102000120130     D                 PI
102100120130     D   arraylist                     *   const
102200120130     D   value                       10I 0 const
102300120130     D   index                       10U 0 const options(*nopass)
102400120130      *
102500120130     D tmpValue        S             10I 0
102600120130      /free
102700120130       tmpValue = value;
102800120130
102900120130       if (%parms() = 2);
103000120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
103100120130       elseif (%parms() = 3);
103200120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
103300120130       endif;
103400120130
103500120130      /end-free
103600120130     P                 E
103700120130
103800120130
103900120130     /**
104000120130      * \brief Add short integer value to the arraylist
104100120130      *
104200120130      * This procedure is a wrapper for the <em>add</em> procedure and
104300120130      * adds a short integer to the arraylist.
104400120130      *
104500120130      * \param Pointer to the arraylist
104600120130      * \param Value
104700120130      * \param Position (default: append)
104800120130      */
104900120130     P arraylist_addShort...
105000120130     P                 B                   export
105100120130     D                 PI
105200120130     D   arraylist                     *   const
105300120130     D   value                        5I 0 const
105400120130     D   index                       10U 0 const options(*nopass)
105500120130      *
105600120130     D tmpValue        S              5I 0
105700120130      /free
105800120130       tmpValue = value;
105900120130
106000120130       if (%parms() = 2);
106100120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
106200120130       elseif (%parms() = 3);
106300120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
106400120130       endif;
106500120130
106600120130      /end-free
106700120130     P                 E
106800120130
106900120130
107000120130     /**
107100120130      * \brief Add long integer value to the arraylist
107200120130      *
107300120130      * This procedure is a wrapper for the <em>add</em> procedure and
107400120130      * adds a long integer to the arraylist.
107500120130      *
107600120130      * \param Pointer to the arraylist
107700120130      * \param Value
107800120130      * \param Position (default: append)
107900120130      */
108000120130     P arraylist_addLong...
108100120130     P                 B                   export
108200120130     D                 PI
108300120130     D   arraylist                     *   const
108400120130     D   value                       20I 0 const
108500120130     D   index                       10U 0 const options(*nopass)
108600120130      *
108700120130     D tmpValue        S             20I 0
108800120130      /free
108900120130       tmpValue = value;
109000120130
109100120130       if (%parms() = 2);
109200120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
109300120130       elseif (%parms() = 3);
109400120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
109500120130       endif;
109600120130
109700120130      /end-free
109800120130     P                 E
109900120130
110000120130
110100120130     /**
110200120130      * \brief Add packed decimal value to the arraylist
110300120130      *
110400120130      * This procedure is a wrapper for the <em>add</em> procedure and
110500120130      * adds a packed decimal to the arraylist.
110600120130      *
110700120130      * \param Pointer to the arraylist
110800120130      * \param Value
110900120130      * \param Position (default: append)
111000120130      */
111100120130     P arraylist_addDecimal...
111200120130     P                 B                   export
111300120130     D                 PI
111400120130     D   arraylist                     *   const
111500120130     D   value                       15P 5 const
111600120130     D   index                       10U 0 const options(*nopass)
111700120130      *
111800120130     D tmpValue        S             15P 5
111900120130      /free
112000120130       tmpValue = value;
112100120130
112200120130       if (%parms() = 2);
112300120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
112400120130       elseif (%parms() = 3);
112500120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
112600120130       endif;
112700120130
112800120130      /end-free
112900120130     P                 E
113000120130
113100120130
113200120130     /**
113300120130      * \brief Add float value to the arraylist
113400120130      *
113500120130      * This procedure is a wrapper for the <em>add</em> procedure and
113600120130      * adds a float to the arraylist.
113700120130      *
113800120130      * \param Pointer to the arraylist
113900120130      * \param Value
114000120130      * \param Position (default: append)
114100120130      */
114200120130     P arraylist_addFloat...
114300120130     P                 B                   export
114400120130     D                 PI
114500120130     D   arraylist                     *   const
114600120130     D   value                        4F   const
114700120130     D   index                       10U 0 const options(*nopass)
114800120130      *
114900120130     D tmpValue        S              4F
115000120130      /free
115100120130       tmpValue = value;
115200120130
115300120130       if (%parms() = 2);
115400120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
115500120130       elseif (%parms() = 3);
115600120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
115700120130       endif;
115800120130
115900120130      /end-free
116000120130     P                 E
116100120130
116200120130
116300120130     /**
116400120130      * \brief Add double value to the arraylist
116500120130      *
116600120130      * This procedure is a wrapper for the <em>add</em> procedure and
116700120130      * adds a double to the arraylist.
116800120130      *
116900120130      * \param Pointer to the arraylist
117000120130      * \param Value
117100120130      * \param Position (default: append)
117200120130      */
117300120130     P arraylist_addDouble...
117400120130     P                 B                   export
117500120130     D                 PI
117600120130     D   arraylist                     *   const
117700120130     D   value                        8F   const
117800120130     D   index                       10U 0 const options(*nopass)
117900120130      *
118000120130     D tmpValue        S              8F
118100120130      /free
118200120130       tmpValue = value;
118300120130
118400120130       if (%parms() = 2);
118500120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
118600120130       elseif (%parms() = 3);
118700120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
118800120130       endif;
118900120130
119000120130      /end-free
119100120130     P                 E
119200120130
119300120130
119400120130     /**
119500120130      * \brief Add date value to the arraylist
119600120130      *
119700120130      * This procedure is a wrapper for the <em>add</em> procedure and
119800120130      * adds a date to the arraylist.
119900120130      *
120000120130      * \param Pointer to the arraylist
120100120130      * \param Value
120200120130      * \param Position (default: append)
120300120130      */
120400120130     P arraylist_addDate...
120500120130     P                 B                   export
120600120130     D                 PI
120700120130     D   arraylist                     *   const
120800120130     D   value                         D   const
120900120130     D   index                       10U 0 const options(*nopass)
121000120130      *
121100120130     D tmpValue        S               D
121200120130      /free
121300120130       tmpValue = value;
121400120130
121500120130       if (%parms() = 2);
121600120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
121700120130       elseif (%parms() = 3);
121800120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
121900120130       endif;
122000120130
122100120130      /end-free
122200120130     P                 E
122300120130
122400120130
122500120130     /**
122600120130      * \brief Add boolean value to the arraylist
122700120130      *
122800120130      * This procedure is a wrapper for the <em>add</em> procedure and
122900120130      * adds a boolean to the arraylist.
123000120130      *
123100120130      * \param Pointer to the arraylist
123200120130      * \param Value
123300120130      * \param Position (default: append)
123400120130      */
123500120130     P arraylist_addBoolean...
123600120130     P                 B                   export
123700120130     D                 PI
123800120130     D   arraylist                     *   const
123900120130     D   value                         N   const
124000120130     D   index                       10U 0 const options(*nopass)
124100120130      *
124200120130     D tmpValue        S               N
124300120130      /free
124400120130       tmpValue = value;
124500120130
124600120130       if (%parms() = 2);
124700120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue));
124800120130       elseif (%parms() = 3);
124900120130         arraylist_add(arraylist : %addr(tmpValue) : %size(tmpValue) : index);
125000120130       endif;
125100120130
125200120130      /end-free
125300120130     P                 E
125400120130
125500120130
125600120130     /**
125700120130      * \brief Add character value to the arraylist
125800120130      *
125900120130      * This procedure is a wrapper for the <em>add</em> procedure and
126000120130      * adds a character string to the arraylist.
126100120130      *
126200120130      * \param Pointer to the arraylist
126300120130      * \param Value
126400120130      * \param Position (default: append)
126500120130      */
126600120130     P arraylist_addString...
126700120130     P                 B                   export
126800120130     D                 PI
126900120130     D   arraylist                     *   const
127000120130     D   value                    65535A   const varying
127100120130     D   index                       10U 0 const options(*nopass)
127200120130      *
127300120130     D length          S             10I 0
127400120130     D string          S          65535A   varying
127500120130      /free
127600120130       string = value;
127700120130       length = %len(value);
127800120130
127900120130       if (%parms() = 2);
127901120130
127902120130         //Modified by: Isaac Ramirez Herrera
127903120130         //Add 2 positions to the adress of string in order to skip the first two
127904120130         //bytes corresponding to the length. If recompiled in V6R1, change for
127905120130         //%addr(string : *DATA)
128000120130         arraylist_add(arraylist : %addr(string) + 2 : length);
128100120130       elseif (%parms() = 3);
128200120130         arraylist_add(arraylist : %addr(string) + 2 : length : index);
128300120130       endif;
128400120130
128500120130      /end-free
128600120130     P                 E
128700120130
128800120130
128900120130     /**
129000120130      * \brief Get integer value from arraylist
129100120130      *
129200120130      * Returns the previously inserted integer value from the arraylist.
129300120130      * If the value cannot be interpreted as an integer an escape message
129400120130      * will be sent.
129500120130      *
129600120130      * \param Pointer to the arraylist
129700120130      * \param Position
129800120130      *
129900120130      * \return Value
130000120130      */
130100120130     P arraylist_getInteger...
130200120130     P                 B                   export
130300120130     D                 PI            10I 0
130400120130     D   arraylist                     *   const
130500120130     D   index                       10U 0 const
130600120130      *
130700120130     D header          DS                  likeds(tmpl_header) based(arraylist)
130800120130     D ptr             S               *
130900120130     D dataptr         S               *   based(ptr)
131000120130     D data            S             10I 0 based(dataPtr)
131100120130     D retVal          S             10I 0
131200120130      /free
131300120130       // check if the arraylist is empty or the position is outside of the arraylist
131400120130       if (header.elementCount = 0);
131500120130         sendEscapeMessage('Position out of bounds');
131600120130         return *loval;
131700120130       elseif (index < 0 or index > header.elementCount -1);
131800120130         sendEscapeMessage('Position out of bounds');
131900120130         return *loval;
132000120130       endif;
132100120130
132200120130       ptr = getEntry(arraylist : index);
132300120130
132400120130       monitor;
132500120130         // test if the temp variable is filled with the right data for the type
132600120130         // by moving the data from temp to another var (retVal in this case)
132700120130         retVal = data;
132800120130         return retVal;
132900120130         on-error *all;
133000120130           sendEscapeMessage('Invalid value type');
133100120130           return *loval;
133200120130       endmon;
133300120130
133400120130      /end-free
133500120130     P                 E
133600120130
133700120130
133800120130     /**
133900120130      * \brief Get short integer value from arraylist
134000120130      *
134100120130      * Returns the previously inserted short integer value from the arraylist.
134200120130      * If the value cannot be interpreted as a short integer an escape message
134300120130      * will be sent.
134400120130      *
134500120130      * \param Pointer to the arraylist
134600120130      * \param Position
134700120130      *
134800120130      * \return Value
134900120130      */
135000120130     P arraylist_getShort...
135100120130     P                 B                   export
135200120130     D                 PI             5I 0
135300120130     D   arraylist                     *   const
135400120130     D   index                       10U 0 const
135500120130      *
135600120130     D header          DS                  likeds(tmpl_header) based(arraylist)
135700120130     D ptr             S               *
135800120130     D dataptr         S               *   based(ptr)
135900120130     D data            S              5I 0 based(dataPtr)
136000120130     D retVal          S              5I 0
136100120130      /free
136200120130       // check if the arraylist is empty or the position is outside of the arraylist
136300120130       if (header.elementCount = 0);
136400120130         sendEscapeMessage('Position out of bounds');
136500120130         return *loval;
136600120130       elseif (index < 0 or index > header.elementCount -1);
136700120130         sendEscapeMessage('Position out of bounds');
136800120130         return *loval;
136900120130       endif;
137000120130
137100120130       ptr = getEntry(arraylist : index);
137200120130
137300120130       monitor;
137400120130         // test if the temp variable is filled with the right data for the type
137500120130         // by moving the data from temp to another var (retVal in this case)
137600120130         retVal = data;
137700120130         return retVal;
137800120130         on-error *all;
137900120130           sendEscapeMessage('Invalid value type');
138000120130           return *loval;
138100120130       endmon;
138200120130
138300120130      /end-free
138400120130     P                 E
138500120130
138600120130
138700120130     /**
138800120130      * \brief Get long integer value from arraylist
138900120130      *
139000120130      * Returns the previously inserted long integer value from the arraylist.
139100120130      * If the value cannot be interpreted as a long integer an escape message
139200120130      * will be sent.
139300120130      *
139400120130      * \param Pointer to the arraylist
139500120130      * \param Position
139600120130      *
139700120130      * \return Value
139800120130      */
139900120130     P arraylist_getLong...
140000120130     P                 B                   export
140100120130     D                 PI            20I 0
140200120130     D   arraylist                     *   const
140300120130     D   index                       10U 0 const
140400120130      *
140500120130     D header          DS                  likeds(tmpl_header) based(arraylist)
140600120130     D ptr             S               *
140700120130     D dataptr         S               *   based(ptr)
140800120130     D data            S             20I 0 based(dataPtr)
140900120130     D retVal          S             20I 0
141000120130      /free
141100120130       // check if the arraylist is empty or the position is outside of the arraylist
141200120130       if (header.elementCount = 0);
141300120130         sendEscapeMessage('Position out of bounds');
141400120130         return *loval;
141500120130       elseif (index < 0 or index > header.elementCount -1);
141600120130         sendEscapeMessage('Position out of bounds');
141700120130         return *loval;
141800120130       endif;
141900120130
142000120130       ptr = getEntry(arraylist : index);
142100120130
142200120130       monitor;
142300120130         // test if the temp variable is filled with the right data for the type
142400120130         // by moving the data from temp to another var (retVal in this case)
142500120130         retVal = data;
142600120130         return retVal;
142700120130         on-error *all;
142800120130           sendEscapeMessage('Invalid value type');
142900120130           return *loval;
143000120130       endmon;
143100120130
143200120130      /end-free
143300120130     P                 E
143400120130
143500120130
143600120130     /**
143700120130      * \brief Get packed decimal value from arraylist
143800120130      *
143900120130      * Returns the previously inserted packed decimal value from the arraylist.
144000120130      * If the value cannot be interpreted as a packed decimal an escape message
144100120130      * will be sent.
144200120130      *
144300120130      * \param Pointer to the arraylist
144400120130      * \param Position
144500120130      *
144600120130      * \return Value
144700120130      */
144800120130     P arraylist_getDecimal...
144900120130     P                 B                   export
145000120130     D                 PI            15P 5
145100120130     D   arraylist                     *   const
145200120130     D   index                       10U 0 const
145300120130      *
145400120130     D header          DS                  likeds(tmpl_header) based(arraylist)
145500120130     D ptr             S               *
145600120130     D dataptr         S               *   based(ptr)
145700120130     D data            S             15P 5 based(dataPtr)
145800120130     D retVal          S             15P 5
145900120130      /free
146000120130       // check if the arraylist is empty or the position is outside of the arraylist
146100120130       if (header.elementCount = 0);
146200120130         sendEscapeMessage('Position out of bounds');
146300120130         return *loval;
146400120130       elseif (index < 0 or index > header.elementCount -1);
146500120130         sendEscapeMessage('Position out of bounds');
146600120130         return *loval;
146700120130       endif;
146800120130
146900120130       ptr = getEntry(arraylist : index);
147000120130
147100120130       monitor;
147200120130         // test if the temp variable is filled with the right data for the type
147300120130         // by moving the data from temp to another var (retVal in this case)
147400120130         retVal = data;
147500120130         return retVal;
147600120130         on-error *all;
147700120130           sendEscapeMessage('Invalid value type');
147800120130           return *loval;
147900120130       endmon;
148000120130
148100120130      /end-free
148200120130     P                 E
148300120130
148400120130
148500120130     /**
148600120130      * \brief Get float value from arraylist
148700120130      *
148800120130      * Returns the previously inserted float value from the arraylist.
148900120130      * If the value cannot be interpreted as a float an escape message
149000120130      * will be sent.
149100120130      *
149200120130      * \param Pointer to the arraylist
149300120130      * \param Position
149400120130      *
149500120130      * \return Value
149600120130      */
149700120130     P arraylist_getFloat...
149800120130     P                 B                   export
149900120130     D                 PI             4F
150000120130     D   arraylist                     *   const
150100120130     D   index                       10U 0 const
150200120130      *
150300120130     D header          DS                  likeds(tmpl_header) based(arraylist)
150400120130     D ptr             S               *
150500120130     D dataptr         S               *   based(ptr)
150600120130     D data            S              4F   based(dataPtr)
150700120130     D retVal          S              4F
150800120130      /free
150900120130       // check if the arraylist is empty or the position is outside of the arraylist
151000120130       if (header.elementCount = 0);
151100120130         sendEscapeMessage('Position out of bounds');
151200120130         return *loval;
151300120130       elseif (index < 0 or index > header.elementCount -1);
151400120130         sendEscapeMessage('Position out of bounds');
151500120130         return *loval;
151600120130       endif;
151700120130
151800120130       ptr = getEntry(arraylist : index);
151900120130
152000120130       monitor;
152100120130         // test if the temp variable is filled with the right data for the type
152200120130         // by moving the data from temp to another var (retVal in this case)
152300120130         retVal = data;
152400120130         return retVal;
152500120130         on-error *all;
152600120130           sendEscapeMessage('Invalid value type');
152700120130           return *loval;
152800120130       endmon;
152900120130
153000120130      /end-free
153100120130     P                 E
153200120130
153300120130
153400120130     /**
153500120130      * \brief Get dobule value from arraylist
153600120130      *
153700120130      * Returns the previously inserted double value from the arraylist.
153800120130      * If the value cannot be interpreted as a double an escape message
153900120130      * will be sent.
154000120130      *
154100120130      * \param Pointer to the arraylist
154200120130      * \param Position
154300120130      *
154400120130      * \return Value
154500120130      */
154600120130     P arraylist_getDouble...
154700120130     P                 B                   export
154800120130     D                 PI             8F
154900120130     D   arraylist                     *   const
155000120130     D   index                       10U 0 const
155100120130      *
155200120130     D header          DS                  likeds(tmpl_header) based(arraylist)
155300120130     D ptr             S               *
155400120130     D dataptr         S               *   based(ptr)
155500120130     D data            S              8F   based(dataPtr)
155600120130     D retVal          S              8F
155700120130      /free
155800120130       // check if the arraylist is empty or the position is outside of the arraylist
155900120130       if (header.elementCount = 0);
156000120130         sendEscapeMessage('Position out of bounds');
156100120130         return *loval;
156200120130       elseif (index < 0 or index > header.elementCount -1);
156300120130         sendEscapeMessage('Position out of bounds');
156400120130         return *loval;
156500120130       endif;
156600120130
156700120130       ptr = getEntry(arraylist : index);
156800120130
156900120130       monitor;
157000120130         // test if the temp variable is filled with the right data for the type
157100120130         // by moving the data from temp to another var (retVal in this case)
157200120130         retVal = data;
157300120130         return retVal;
157400120130         on-error *all;
157500120130           sendEscapeMessage('Invalid value type');
157600120130           return *loval;
157700120130       endmon;
157800120130
157900120130      /end-free
158000120130     P                 E
158100120130
158200120130
158300120130     /**
158400120130      * \brief Get date value from arraylist
158500120130      *
158600120130      * Returns the previously inserted date value from the arraylist.
158700120130      * If the value cannot be interpreted as a date an escape message
158800120130      * will be sent.
158900120130      *
159000120130      * \param Pointer to the arraylist
159100120130      * \param Position
159200120130      *
159300120130      * \return Value
159400120130      */
159500120130     P arraylist_getDate...
159600120130     P                 B                   export
159700120130     D                 PI              D
159800120130     D   arraylist                     *   const
159900120130     D   index                       10U 0 const
160000120130      *
160100120130     D header          DS                  likeds(tmpl_header) based(arraylist)
160200120130     D ptr             S               *
160300120130     D dataptr         S               *   based(ptr)
160400120130     D data            S               D   based(dataPtr)
160500120130     D retVal          S               D
160600120130      /free
160700120130       // check if the arraylist is empty or the position is outside of the arraylist
160800120130       if (header.elementCount = 0);
160900120130         sendEscapeMessage('Position out of bounds');
161000120130         return *loval;
161100120130       elseif (index < 0 or index > header.elementCount -1);
161200120130         sendEscapeMessage('Position out of bounds');
161300120130         return *loval;
161400120130       endif;
161500120130
161600120130       ptr = getEntry(arraylist : index);
161700120130
161800120130       monitor;
161900120130         // test if the temp variable is filled with the right data for the type
162000120130         // by moving the data from temp to another var (retVal in this case)
162100120130         retVal = data;
162200120130         return retVal;
162300120130         on-error *all;
162400120130           sendEscapeMessage('Invalid value type');
162500120130           return *loval;
162600120130       endmon;
162700120130
162800120130      /end-free
162900120130     P                 E
163000120130
163100120130
163200120130     /**
163300120130      * \brief Get boolean value from arraylist
163400120130      *
163500120130      * Returns the previously inserted boolean value from the arraylist.
163600120130      * If the value cannot be interpreted as a boolean an escape message
163700120130      * will be sent.
163800120130      *
163900120130      * \param Pointer to the arraylist
164000120130      * \param Position
164100120130      *
164200120130      * \return Value
164300120130      */
164400120130     P arraylist_getBoolean...
164500120130     P                 B                   export
164600120130     D                 PI              N
164700120130     D   arraylist                     *   const
164800120130     D   index                       10U 0 const
164900120130      *
165000120130     D header          DS                  likeds(tmpl_header) based(arraylist)
165100120130     D ptr             S               *
165200120130     D dataptr         S               *   based(ptr)
165300120130     D data            S               N   based(dataPtr)
165400120130     D retVal          S               N
165500120130      /free
165600120130       // check if the arraylist is empty or the position is outside of the arraylist
165700120130       if (header.elementCount = 0);
165800120130         sendEscapeMessage('Position out of bounds');
165900120130         return *loval;
166000120130       elseif (index < 0 or index > header.elementCount -1);
166100120130         sendEscapeMessage('Position out of bounds');
166200120130         return *loval;
166300120130       endif;
166400120130
166500120130       ptr = getEntry(arraylist : index);
166600120130
166700120130       monitor;
166800120130         // test if the temp variable is filled with the right data for the type
166900120130         // by moving the data from temp to another var (retVal in this case)
167000120130         retVal = data;
167100120130         return retVal;
167200120130         on-error *all;
167300120130           sendEscapeMessage('Invalid value type');
167400120130           return *loval;
167500120130       endmon;
167600120130
167700120130      /end-free
167800120130     P                 E
167900120130
168000120130
168100120130     /**
168200120130      * \brief Get character value from arraylist
168300120130      *
168400120130      * Returns the previously inserted character string value from the arraylist.
168500120130      * If the value cannot be interpreted as a char value an escape message
168600120130      * will be sent.
168700120130      *
168800120130      * \param Pointer to the arraylist
168900120130      * \param Position
169000120130      *
169100120130      * \return Value
169200120130      */
169300120130     P arraylist_getString...
169400120130     P                 B                   export
169500120130     D                 PI         65535A
169600120130     D   arraylist                     *   const
169700120130     D   index                       10U 0 const
169800120130      *
169900120130     D header          DS                  likeds(tmpl_header) based(arraylist)
170000120130     D ptr             S               *
170100120130     D dataptr         S               *   based(ptr)
170200120130     D retVal          S          65535A
170300120130      /free
170400120130       // check if the arraylist is empty or the position is outside of the arraylist
170500120130       if (header.elementCount = 0);
170600120130         sendEscapeMessage('Position out of bounds');
170700120130         return *loval;
170800120130       elseif (index < 0 or index > header.elementCount -1);
170900120130         sendEscapeMessage('Position out of bounds');
171000120130         return *loval;
171100120130       endif;
171200120130
171300120130       ptr = getEntry(arraylist : index);
171400120130
171500120130       monitor;
171600120130         // test if the temp variable is filled with the right data for the type
171700120130         // by moving the data from temp to another var (retVal in this case)
171800120130         retVal = %str(dataPtr);
171900120130         return retVal;
172000120130         on-error *all;
172100120130           sendEscapeMessage('Invalid value type');
172200120130           return *loval;
172300120130       endmon;
172400120130
172500120130      /end-free
172600120130     P                 E
172700120130
172800120130
172900120130     /**
173000120130      * \brief Execute procedure for every arraylist entry
173100120130      *
173200120130      * The passed procedure will be executed for every entry
173300120130      * in the arraylist.
173400120130      *
173500120130      * <br><br>
173600120130      *
173700120130      * The user can pass data through a pointer to the procedure.
173800120130      * The pointer will not be touched by this procedure itself, so it
173900120130      * can be *null.
174000120130      *
174100120130      * <br><br>
174200120130      *
174300120130      * The value of list entry can be changed through the passed procedure.
174400120130      *
174500120130      * <br><br>
174600120130      *
174700120130      * The parameters for the passed procedure are:
174800120130      * <ul>
174900120130      *   <li>Pointer to the entry value (const)</li>
175000120130      *   <li>Value length (const) <li>
175100120130      *   <li>Pointer to the user data (const)</li>
175200120130      * </ul>
175300120130      *
175400120130      * \param Pointer to the arraylist
175500120130      * \param Procedure pointer
175600120130      * \param Pointer to user data
175700120130      */
175800120130     P arraylist_foreach...
175900120130     P                 B                   export
176000120130     D                 PI
176100120130     D   arraylist                     *   const
176200120130     D   procPtr                       *   const procptr
176300120130     D   userData                      *   const
176400120130      *
176500120130     D foreachProc     PR                  extproc(procPtr)
176600120130     D   valuePtr                      *   const
176700120130     D   length                      10I 0 const
176800120130     D   userData                      *   const
176900120130      *
177000120130     D header          DS                  likeds(tmpl_header) based(arraylist)
177100120130     D ptr             S               *
177200120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
177300120130     D i               S             10I 0
177400120130      /free
177500120130       for i = 0 to header.elementCount - 1;
177600120130         ptr = getEntry(arraylist : i);
177700120130         foreachProc(entry.value : entry.length : userData);
177800120130       endfor;
177900120130      /end-free
178000120130     P                 E
178100120130
178200120130     /**
178300120130      * \brief To character array
178400120130      *
178500120130      * Copies all entries of this arraylist to the passed array. Entries will be
178600120130      * truncated if they are too big for the array. If the array is not big
178700120130      * enough, the last entries will be silently dropped.
178800120130      *
178900120130      * \param Pointer to the arraylist
179000120130      * \param Pointer to the array
179100120130      * \param Element count
179200120130      * \param Element length
179300120130      *
179400120130      */
179500120130     P arraylist_toCharArray...
179600120130     P                 B                   export
179700120130     D                 PI
179800120130     D   arraylist                     *   const
179900120130     D   arrayPtr                      *   const
180000120130     D   count                       10U 0 const
180100120130     D   length                      10U 0 const
180200120130      *
180300120130     D header          DS                  likeds(tmpl_header) based(arraylist)
180400120130     D entryPtr        S               *
180500120130     D entry           DS                  likeds(tmpl_entry) based(entryPtr)
180600120130     D i               S             10I 0
180700120130     D arrayElemPtr    S               *
180800120130     D tmpLength       S             10I 0
180900120130      /free
181000120130       for i = 0 to header.elementCount - 1;
181100120130         if (count > i);
181200120130           entryPtr = getEntry(arraylist : i);
181300120130           arrayElemPtr = arrayPtr + (i * length);
181400120130
181500120130           // determine how many bytes to copy (check length)
181600120130           if (entry.length < length);
181700120130             tmpLength = entry.length;
181800120130           else;
181900120130             tmpLength = length;
182000120130           endif;
182100120130
182200120130           // copy entry from arraylist to array
182300120130           memcpy(arrayElemPtr : entry.value : tmpLength);
182400120130          endif;
182500120130       endfor;
182600120130
182700120130      /end-free
182800120130     P                 E
182900120130
183000120130
183100120130     /**
183200120130      * \brief Reverse order of arraylist entries
183300120130      *
183400120130      * Reverses the order of the entries of the arraylist.
183500120130      *
183600120130      * \param Pointer to the arraylist
183700120130      */
183800120130     P arraylist_reverse...
183900120130     P                 B                   export
184000120130     D                 PI
184100120130     D   arraylist                     *   const
184200120130      *
184300120130     D header          DS                  likeds(tmpl_header) based(arraylist)
184400120130     D ptr1            S               *
184500120130     D entry1          DS                  likeds(tmpl_entry) based(ptr1)
184600120130     D ptr2            S               *
184700120130     D entry2          DS                  likeds(tmpl_entry) based(ptr2)
184800120130     D tmpEntry        DS                  likeds(tmpl_entry)
184900120130     D i               S             10I 0
185000120130     D endValue        S             10I 0
185100120130      /free
185200120130       if (header.elementCount <= 1);
185300120130         return;
185400120130       endif;
185500120130
185600120130       endValue = header.elementCount / 2 - 1;
185700120130
185800120130       for i = 0 to endValue;
185900120130         ptr1 = getEntry(arraylist : i);
186000120130         ptr2 = getEntry(arraylist : header.elementCount - i - 1);
186100120130
186200120130         tmpEntry = entry1;
186300120130         entry1 = entry2;
186400120130         entry2 = tmpEntry;
186500120130       endfor;
186600120130
186700120130      /end-free
186800120130     P                 E
186900120130
187000120130
187100120130     /**
187200120130      * \brief Split character string
187300120130      *
187400120130      * The passed character string will be split into tokens by either
187500120130      * a passed or the default separator. All tokens will be added to
187600120130      * a new arraylist which will be returned.
187700120130      *
187800120130      * <br><br>
187900120130      *
188000120130      * Empty (but not blank) values will be dropped silently.
188100120130      *
188200120130      * \author Mihael Schmidt
188300120130      * \date   26.01.2009
188400120130      *
188500120130      * \param Character string (null-terminated)
188600120130      * \param Separator (default: ;)
188700120130      *
188800120130      * \return Pointer to the filled arraylist
188900120130      */
189000120130     P arraylist_split...
189100120130     P                 B                   export
189200120130     D                 PI              *
189300120130     D   pString                  65535A   const varying
189400120130     D   pSeparator                   1A   const options(*nopass)
189500120130      *
189600120130     D length          S             10I 0
189700120130     D arraylist       S               *
189800120130     D token           S               *
189900120130     D separator       S              1A   inz(';')
190000120130     D string          S          65535A
190100120130      /free
190200120130       string = pString;
190300120130
190400120130       if (%parms() = 2);
190500120130         separator = pSeparator;
190600120130       endif;
190700120130
190800120130       arraylist = arraylist_create();
190900120130
191000120130       token = strtok(string : separator);
191100120130       dow (token <> *null);
191200120130         arraylist_add(arraylist : token : strlen(token));
191300120130         token = strtok(*null : separator);
191400120130       enddo;
191500120130
191600120130       return arraylist;
191700120130      /end-free
191800120130     P                 E
191900120130
192000120130
192100120130     /**
192200120130      * \brief Return character representation of arraylist
192300120130      *
192400120130      * Returns a string with the arraylist items separated either by
192500120130      * the passed or default separator. The items can be
192600120130      * enclosed by a passed character. The maximum character length
192700120130      * returned is 65535. Every character/item after that will be
192800120130      * dropped silently. Items will not be trimmed for this operation.
192900120130      *
193000120130      * <br><br>
193100120130      *
193200120130      * If the third parameter is passed, the third parameter will be
193300120130      * pre- and appended to the item. If the fourth parameter is also
193400120130      * passed the third parameter will be prepended to the item and the
193500120130      * fourth parameter will be appended to the item.
193600120130      *
193700120130      * \param Pointer to the arraylist
193800120130      * \param separator (default: ,)
193900120130      * \param enclosing character (default: nothing)
194000120130      * \param enclosing character at the end of item (default: nothing)
194100120130      *
194200120130      * \return character representation of all arraylist items
194300120130      */
194400120130     P arraylist_toString...
194500120130     P                 B                   export
194600120130     D                 PI         65535A   varying
194700120130     D   arraylist                     *   const
194800120130     D   pSeparator                   1A   const options(*omit : *nopass)
194900120130     D   pEnclosing                 100A   const varying options(*nopass)
195000120130     D   pEnclosingEnd...
195100120130     D                              100A   const varying options(*nopass)
195200120130      *
195300120130     D header          DS                  likeds(tmpl_header) based(arraylist)
195400120130     D separator       S              1A   inz(',')
195500120130     D enclosingStart...
195600120130     D                 S            100A   varying
195700120130     D enclosingEnd...
195800120130     D                 S            100A   varying
195900120130     D entry           DS                  likeds(tmpl_entry) based(ptr)
196000120130     D i               S             10I 0
196100120130     D retVal          S          65535A   varying
196200120130      /free
196300120130       // check if separator is passed
196400120130       if (%parms() >= 2 and %addr(pSeparator) <> *null);
196500120130         separator = pSeparator;
196600120130       endif;
196700120130
196800120130       // check if enclosing characters are passed
196900120130       if (%parms() >= 3);
197000120130         enclosingStart = pEnclosing;
197100120130         enclosingEnd = pEnclosing;
197200120130       endif;
197300120130
197400120130       // check if we should use different chars for start and end of item
197500120130       if (%parms() = 4);
197600120130         enclosingEnd = pEnclosingEnd;
197700120130       endif;
197800120130
197900120130       // process arraylist items
198000120130       for i = 0 to header.elementCount - 2;
198100120130         ptr = getEntry(arraylist : i);
198200120130         retVal += enclosingStart + %str(entry.value) + enclosingEnd +
198300120130                   separator;
198400120130       endfor;
198500120130
198600120130       ptr = getEntry(arraylist : header.elementCount-1);
198700120130       retVal += enclosingStart + %str(entry.value) + enclosingEnd;
198800120130
198900120130       return retVal;
199000120130      /end-free
199100120130     P                 E
199200120130
199300120130
199400120130     /**
199500120130      * \brief Get entry pointer
199600120130      *
199700120130      * Returns the pointer of an entry.
199800120130      *
199900120130      * \author Mihael Schmidt
200000120130      * \date   23.06.2008
200100120130      *
200200120130      * \param Pointer to the arraylist
200300120130      * \param Position (zero-based)
200400120130      *
200500120130      * \return Pointer to arraylist entry or *null
200600120130      */
200700120130     P getEntry...
200800120130     P                 B
200900120130     D                 PI              *
201000120130     D   arraylist                     *   const
201100120130     D   pos                         10I 0 const
201200120130      *
201300120130     D i               S             10I 0
201400120130     D header          DS                  likeds(tmpl_header) based(arraylist)
201500120130     D entry           S               *
201600120130      /free
201700120130       entry = header.elementData + (pos * %size(tmpl_entry));
201800120130       return entry;
201900120130      /end-free
202000120130     P                 E
202100120130
202200120130
202300120130     /**
202400120130      * \brief Push element down by x positions
202500120130      *
202600120130      * Moves the passed element up or down by the x number of entries. This
202700120130      * procedure also pushes/pulls every element under it also up or down by
202800120130      * the given number of positions.
202900120130      *
203000120130      * <br><br>
203100120130      *
203200120130      * A positive <em>downBy</em> value will push the entries down. A negative
203300120130      * <em>downBy</em> value will pull the entries up.
203400120130      *
203500120130      * \author Mihael Schmidt
203600120130      * \date   30.07.2008
203700120130      *
203800120130      * \param Pointer to the arraylist
203900120130      * \param Number of positions to go up or down (default: 1 = down by one position)
204000120130      */
204100120130     P moveElements...
204200120130     P                 B
204300120130     D                 PI
204400120130     D   arraylist                     *   const
204500120130     D   pos                         10U 0 const
204600120130     D   pDownBy                     10I 0 const options(*nopass)
204700120130      *
204800120130     D header          DS                  likeds(tmpl_header) based(arraylist)
204900120130     D downBy          S             10I 0 inz(1)
205000120130     D x               S             10I 0
205100120130     D elementsToCopy...
205200120130     D                 S             10I 0
205300120130     D startElement    S               *
205400120130     D tmp_mem         S               *
205500120130      /free
205600120130       if (%parms() = 3);
205700120130         downBy = pDownBy;
205800120130       endif;
205900120130
206000120130       // check if the destination of the entry is before the head of the arraylist
206100120130       if (pos + downBy < 0);
206200120130         sendEscapeMessage('Destination out of bounds');
206300120130       endif;
206400120130
206500120130       // resize the array if necessary
206600120130       if (header.elementsAllocated < header.elementCount + downBy);
206700120130         increment(arraylist : header.elementCount + downBy);
206800120130       endif;
206900120130
207000120130       startElement = getEntry(arraylist : pos);
207100120130
207200120130       elementsToCopy = header.elementCount - pos;
207300120130
207400120130       if (startElement <> *null);
207500120130         // alloc temp. memory for entries
207600120130         tmp_mem = %alloc(elementsToCopy * %size(tmpl_entry));
207700120130
207800120130         // copy to temp. memory
207900120130         memcpy(tmp_mem :
208000120130                startElement :
208100120130                elementsToCopy * %size(tmpl_entry));
208200120130
208300120130         // copy to real destination
208400120130         memcpy(startElement + (downBy * %size(tmpl_entry)) :  // destination
208500120130                tmp_mem :                                      // source
208600120130                elementsToCopy * %size(tmpl_entry));           // number of bytes
208700120130
208800120130         // release the temp. memory
208900120130         dealloc tmp_mem;
209000120130       endif;
209100120130      /end-free
209200120130     P                 E
209300120130
209400120130
209500120130     /**
209600120130      * \brief Increment array size
209700120130      *
209800120130      * Increases the size of the arraylist either by 2 or up to the passed
209900120130      * size. The arraylist size will be decreased if the given size is lower
210000120130      * than the current size.
210100120130      *
210200120130      * <br><br>
210300120130      *
210400120130      * If the new size cannot be less than the number of elements currently
210500120130      * in the arraylist.
210600120130      *
210700120130      * \author Mihael Schmidt
210800120130      * \date   23.06.2008
210900120130      *
211000120130      * \param Pointer to the arraylist
211100120130      * \param New size of the arraylist (default: determined by the header)
211200120130      */
211300120130     P increment       B
211400120130     D                 PI
211500120130     D   arraylist                     *   const
211600120130     D   size                        10U 0 const options(*nopass)
211700120130      *
211800120130     D header          DS                  likeds(tmpl_header) based(arraylist)
211900120130     D newSize         S             10U 0
212000120130      /free
212100120130       monitor;
212200120130         if (%parms() = 1);
212300120130           if (header.incrementSize = 0);
212400120130             // double the size
212500120130             newSize = header.elementsAllocated * 2;
212600120130           else;
212700120130             newSize = header.incrementSize;
212800120130           endif;
212900120130         else;
213000120130           if (size = 0);
213100120130             // double the size
213200120130             newSize = header.elementsAllocated * 2;
213300120130           elseif (size <= header.elementsAllocated);
213400120130             // return if the new size is going to be smaller
213500120130             // than the number of elements currently in the arraylist
213600120130             // (same size => do nothing)
213700120130             return;
213800120130           else;
213900120130             newSize = size;
214000120130           endif;
214100120130         endif;
214200120130
214300120130         on-error *all;
214400120130           sendEscapeMessage('Maximum arraylist size reached');
214500120130       endmon;
214600120130
214700120130       if (header.elementsAllocated <> newSize);
214800120130         header.elementData = %realloc(header.elementData :
214900120130                               newSize * %size(tmpl_entry));
215000120130         header.elementsAllocated = newSize;
215100120130       endif;
215200120130      /end-free
215300120130     P                 E
215400120130
215500120130
215600120130     /**
215700120130      * \brief Send Escape Message
215800120130      *
215900120130      * Sends an escape message with the specified Id.
216000120130      *
216100120130      * \author Mihael Schmidt
216200120130      * \date   23.06.2008
216300120130      *
216400120130      * \param Message Id
216500120130      */
216600120130     P sendEscapeMessage...
216700120130     P                 B
216800120130     D                 PI
216900120130     D   message                  65535A   const varying
217000120130      *
217100120130     D sendProgramMessage...
217200120130     D                 PR                  extpgm('QMHSNDPM')
217300120130     D  szMsgID                       7A   const
217400120130     D  szMsgFile                    20A   const
217500120130     D  szMsgData                  6000A   const  options(*varsize)
217600120130     D  nMsgDataLen                  10I 0 const
217700120130     D  szMsgType                    10A   const
217800120130     D  szCallStkEntry...
217900120130     D                               10A   const
218000120130     D  nRelativeCallStkEntry...
218100120130     D                               10I 0 const
218200120130     D  szRtnMsgKey                   4A
218300120130     D  error                       265A   options(*varsize)
218400120130      *
218500120130     D msgdata         S            512A
218600120130     D msgkey          S              4A
218700120130     D apiError        S            265A
218800120130      /free
218900120130       msgdata = message;
219000120130
219100120130       sendProgramMessage('CPF9898' :
219200120130                          'QCPFMSG   *LIBL     ' :
219300120130                          %trimr(msgdata) :
219400120130                          %len(%trimr(msgdata)) :
219500120130                          '*ESCAPE   ' :
219600120130                          '*PGMBDY' :
219700120130                          0 :
219800120130                          msgkey :
219900120130                          apiError);
220000120130      /end-free
220100120130     P                 E
