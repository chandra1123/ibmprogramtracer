000100121001     /**                                                                                            
000101121001      * \brief Generate code coverage reports                                                       
000102121001      *                                                                                             
000103121001      * <p>                                                                                         
000104121001      *  This program generates a code coverage report indicating                                   
000105121001      *  the executed code lines vs executable code lines                                           
000106121001      * </p>                                                                                        
000107121001      *                                                                                             
000108121001      * \author Isaac Ramirez Herrera                                                               
000109121001      * \date   October, 2012                                                                       
000110121009      * \rev    2.0                                                                                 
000111120821                                                                                                    
000112120821     h dftactgrp(*no)                                                                               
000113121001     h actgrp(*NEW)                                                                                 
000114120821     h option(*srcstmt:*nodebugio)                                                                  
000115120821     h bnddir('TRACEBNDD')                                                                          
000116120821     h main(CODCOVER_calculateCoverage)                                                             
000117120821                                                                                                    
000118120821      /include tsx/qsrctxt,debugrapis                                                               
000119120821      /include tsx/qsrctxt,trchandler                                                               
000120120821      /include tsx/qsrctxt,traceconst                                                               
000121120821      /include tsx/qsrctxt,tracetypes                                                               
000122120823      /include tsx/qsrctxt,csqlutil                                                                 
000123121008      /include tsx/qsrctxt,cexception                                                               
000124121008      /include tsx/qsrctxt,cexcptypes                                                               
000125121008      /include tsx/qsrctxt,cexcperror                                                               
000126121009      /include tsx/qsrctxt,llist_h                                                                  
000127120821                                                                                                    
000128121001      /////////////////////////////////////////////////////////////////////////                     
000129121001      // Constants declaration                                                                      
000130121001      /////////////////////////////////////////////////////////////////////////                     
000131121001                                                                                                    
000132121001     d ALL_PROGRAMS    c                   const('*ALL')                                            
000133121001                                                                                                    
000134120823      /////////////////////////////////////////////////////////////////////////                     
000135120823      // Variable declaration                                                                       
000136120823      /////////////////////////////////////////////////////////////////////////                     
000137120823                                                                                                    
000138121011     d psds           sds                  qualified                                                
000139121011     d  pgm_library           81     90                                                             
000140121011     d  job_name             244    253                                                             
000141121011     d  job_user             254    263                                                             
000142121011     d  job_num              264    269s 0                                                          
000143121011                                                                                                    
000144120823     d traceCoverLine_record...                                                                     
000145120823     d               e ds                  extname(FULLCODE) qualified                              
000146120823     d                                     template                                                 
000147120823                                                                                                    
000148120823     d qualifiedName_t...                                                                           
000149120823     d                 ds                  qualified template                                       
000150120823     d  name                         10a   inz                                                      
000151120823     d  library                      10a   inz                                                      
000152120823                                                                                                    
000153120823      /////////////////////////////////////////////////////////////////////////                     
000154120823      // Prototype declaration                                                                      
000155120823      /////////////////////////////////////////////////////////////////////////                     
000156120821                                                                                                    
000157120821     d TS_Malloc       pr              *   extproc('_C_TS_malloc')                                  
000158120821     d  size                         10u 0 value                                                    
000159120821                                                                                                    
000160120821     d TS_Free         pr                  extproc('_C_TS_free')                                    
000161120821     d  pointer                        *   value                                                    
000162120821                                                                                                    
000163121008     d validateInput   pr                                                                           
000164121008     d programName                         likeds(qualifiedName_t) const                            
000165121008     d programType                   10a   const options(*varsize)                                  
000166121008                                                                                                    
000167120823     d prepareOutputFiles...                                                                        
000168120823     d                 pr                                                                           
000169120823                                                                                                    
000170121001     d retrieveExecutableLines...                                                                   
000171121001     d                 pr                                                                           
000172121009     d programName                         likeds(qualifiedName_t)                                  
000173121001     d programType                   10a   const options(*varsize)                                  
000174121001                                                                                                    
000175120823     d writeSource     pr                                                                           
000176121009     d viewIndex                           likeds(viewIndex_type) const                             
000177121001     d programName                         likeds(qualifiedName_t) const                            
000178121001                                                                                                    
000179120823     d generateStatistics...                                                                        
000180120823     d                 pr                                                                           
000181120823                                                                                                    
000182121001     d createProgramList...                                                                         
000183121001     d                 pr                                                                           
000184121001                                                                                                    
000185121001     d nextProgram     pr              n                                                            
000186121001     d currentProgram                      likeds(qualifiedName_t)                                  
000187121001     d currentProgramType...                                                                        
000188121001     d                               10a                                                            
000189121001                                                                                                    
000190121008     d sendUserMessage...                                                                           
000191121008     d                 pr                                                                           
000192121008     d message                      150a   const                                                    
000193121008                                                                                                    
000194120823     d CODCOVER_calculateCoverage...                                                                
000195120823     d                 pr                  extpgm('CODCOVER')                                       
000196120823     d programName                         likeds(qualifiedName_t) const                            
000197120823     d programType                   10a   const options(*varsize)                                  
000198120823                                                                                                    
000199120823      /////////////////////////////////////////////////////////////////////////                     
000200120823      // Procedure definition                                                                       
000201120823      /////////////////////////////////////////////////////////////////////////                     
000202120821                                                                                                    
000203121009     /**                                                                                            
000204121009      * \brief CODCOVER_calculateCoverage: calculates the coverage of a program                     
000205121009      *                                                                                             
000206121009      * <p>                                                                                         
000207121009      *  This procedure calculates the code coverage for a program or service                       
000208121009      *  program. The code coverage is calculated against a file containing                         
000209121009      *  the trace data for the same program or service program.                                    
000210121009      * </p>                                                                                        
000211121009      *                                                                                             
000212121009      * \param qualified name of the program                                                        
000213121009      * \param type of the program                                                                  
000214121009      */                                                                                            
000215120821     p CODCOVER_calculateCoverage...                                                                
000216120821     p                 b                                                                            
000217120821     d                 pi                                                                           
000218120823     d programName                         likeds(qualifiedName_t) const                            
000219120821     d programType                   10a   const options(*varsize)                                  
000220120821     d                                                                                              
000221120823     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)                       
000222120821     d stopHandlerPgm  ds                  qualified                                                
000223120821     d  name                         10a   inz('TRCSTPHDLR')                                        
000224121011     d  library                      10a                                                            
000225121001     d                                                                                              
000226121001     d currentProgram...                                                                            
000227121001     d                 ds                  likeds(qualifiedName_t)                                  
000228121001     d currentProgramType...                                                                        
000229121001     d                 s             10a                                                            
000230121009     d wrkProgramName  ds                  likeds(qualifiedName_t)                                  
000231121009                                                                                                    
000232120821      /free                                                                                         
000233121009       //Set SQL options                                                                            
000234121008       EXEC SQL                                                                                     
000235121008         SET OPTION DATFMT = *ISO,                                                                  
000236121008                    TIMFMT = *ISO;                                                                  
000237121001                                                                                                    
000238120821       monitor;                                                                                     
000239121008         sendUserMessage('Code Coverage executing');                                                
000240121008                                                                                                    
000241121008         //Validate parameters                                                                      
000242121008         validateInput(programName:programType);                                                    
000243121001                                                                                                    
000244120824         //Prepare the files to generate                                                            
000245120824         prepareOutputFiles();                                                                      
000246120824                                                                                                    
000247120823         //This forces an exception if the API fails                                                
000248120821         errorDS.Bytes = 0;                                                                         
000249120821                                                                                                    
000250121011         //StopHandler MUST be in the same library as                                               
000251121011         //this program (CODCOVER)                                                                  
000252121011         stopHandlerPgm.library = psds.pgm_library;                                                 
000253121011                                                                                                    
000254120821         //Initiate the debug                                                                       
000255120821         StarSourceDebugAPI(stopHandlerPgm:errorDS);                                                
000256120821                                                                                                    
000257121009         wrkProgramName = programName;                                                              
000258121009                                                                                                    
000259121009         if (wrkProgramName.name = ALL_PROGRAMS);                                                   
000260121001           createProgramList();                                                                     
000261121001                                                                                                    
000262121001           dow nextProgram(currentProgram:currentProgramType);                                      
000263121001             retrieveExecutableLines(currentProgram:currentProgramType);                            
000264121001           enddo;                                                                                   
000265121001         else;                                                                                      
000266121001           //Retrieve all the executable lines of the program                                       
000267121009           retrieveExecutableLines(wrkProgramName:programType);                                     
000268121001         endif;                                                                                     
000269121001                                                                                                    
000270121001         //Calculate all the estatistics                                                            
000274120824         generateStatistics();                                                                      
000275121008                                                                                                    
000276121008         sendUserMessage('Code Coverage ended successfully');                                       
000282120821       on-error;                                                                                    
000283120821         CEXCEPTION_catchException();                                                               
000284120821         CEXCEPTION_printStackTrace();                                                              
000285121008         sendUserMessage('Code Coverage ended with errors');                                        
000286120821       endmon;                                                                                      
000287120821                                                                                                    
000288120821       monitor;                                                                                     
000290120821         //Stop the source debugger                                                                 
000291120821         EndSourceDebugAPI(errorDS);                                                                
000293120821       on-error;                                                                                    
000294120823         //Ignore error                                                                             
000295120821       endmon;                                                                                      
000296120821      /end-free                                                                                     
000297120821     p                 e                                                                            
000298120821      //_______________________________________________________________________                     
000299120821                                                                                                    
000300121008     /**                                                                                            
000301121009      * \brief validateInput: validates the input parameters of the command                         
000302121008      *                                                                                             
000303121008      * <p>                                                                                         
000304121009      *  This procedure validates all of the parameters passed to the code                          
000305121009      *  coverage command                                                                           
000306121008      * </p>                                                                                        
000307121008      *                                                                                             
000308121009      * \param name of the program                                                                  
000309121009      * \param type of the program                                                                  
000311121008      */                                                                                            
000312121008     p validateInput   b                                                                            
000313121008     d                 pi                                                                           
000314121008     d programName                         likeds(qualifiedName_t) const                            
000315121008     d programType                   10a   const options(*varsize)                                  
000316121008                                                                                                    
000317121008      /free                                                                                         
000318121008       if (%trim(programName) = *blanks);                                                           
000319121008         CEXCEPTION_throwNewException('CPF9898':'QCPFMSGF'                                          
000320121008            :'Program Name should not be blanks');                                                  
000321121008       endif;                                                                                       
000322121008                                                                                                    
000323121009       if (programName <> ALL_PROGRAMS and %trim(programType) = *blanks);                           
000324121008         CEXCEPTION_throwNewException('CPF9898':'QCPFMSGF'                                          
000325121008            :'Program Type should not be blanks');                                                  
000326121008       endif;                                                                                       
000327121008      /end-free                                                                                     
000328121008     p                 e                                                                            
000329121008      //_______________________________________________________________________                     
000330121008                                                                                                    
000331121008     /**                                                                                            
000332121009      * \brief prepareOutputFiles: prepares the output files of the coverage.                       
000333121008      *                                                                                             
000334121008      * <p>                                                                                         
000335121009      *  This procedure deletes all the data of the output files used to                            
000336121009      *  keep the code coverage data                                                                
000337121008      * </p>                                                                                        
000338121008      *                                                                                             
000339121008      */                                                                                            
000340120823     p prepareOutputFiles...                                                                        
000341120823     p                 b                                                                            
000342120823                                                                                                    
000343120823      /free                                                                                         
000344121008       sendUserMessage('Clearing output files');                                                    
000345121008                                                                                                    
000346121008       EXEC SQL                                                                                     
000347121008         DELETE FROM FULLCODE;                                                                      
000348120823                                                                                                    
000349121008       EXEC SQL                                                                                     
000350121008         DELETE FROM TRACECOVER;                                                                    
000351121008                                                                                                    
000352121008       EXEC SQL                                                                                     
000353121008         DELETE FROM COVERTOTAL;                                                                    
000354120823      /end-free                                                                                     
000355120823     p                 e                                                                            
000356120823      //_______________________________________________________________________                     
000357120823                                                                                                    
000358121008     /**                                                                                            
000359121009      * \brief createProgramList: creates a list of programs to calculate cover.                    
000360121008      *                                                                                             
000361121008      * <p>                                                                                         
000362121009      *  This procedure creates the list of program to which the coverage                           
000363121009      *  will be calculated                                                                         
000364121008      * </p>                                                                                        
000367121008      */                                                                                            
000368121001     p createProgramList...                                                                         
000369121001     p                 b                                                                            
000370121001                                                                                                    
000371121001      /free                                                                                         
000372121001       monitor;                                                                                     
000373121008         sendUserMessage('Creating program list');                                                  
000374121008                                                                                                    
000375121008         EXEC SQL                                                                                   
000376121008           DECLARE PROGRAM_LIST SCROLL CURSOR FOR                                                   
000377121008             SELECT DISTINCT                                                                        
000378121008                    TEMPTRACE.PGMLIB,                                                               
000379121008                    TEMPTRACE.PGMNAME,                                                              
000380121008                    TEMPTRACE.PGMTYPE                                                               
000381121008               FROM TRACEDATA TEMPTRACE;                                                            
000382121001                                                                                                    
000383121001         CSQLUTIL_checkSQLState(SQLSTT:'DECLARE PROGRAM_LIST');                                     
000384121001                                                                                                    
000385121008         EXEC SQL                                                                                   
000386121008           OPEN PROGRAM_LIST;                                                                       
000387121001                                                                                                    
000388121001         CSQLUTIL_checkSQLState(SQLSTT:'DECLARE PROGRAM_LIST');                                     
000389121001       on-error;                                                                                    
000390121001         CEXCEPTION_catchException();                                                               
000391121001         CEXCEPTION_printStackTrace();                                                              
000392121008         CEXCEPTION_throwNewException('CPF9898':'QCPFMSGF'                                          
000393121008            :'Error creating program list');                                                        
000394121001       endmon;                                                                                      
000395121001      /end-free                                                                                     
000396121001     p                 e                                                                            
000397121001      //_______________________________________________________________________                     
000398121001                                                                                                    
000399121008     /**                                                                                            
000400121009      * \brief nextProgram: iterates to the next program in the list                                
000401121008      *                                                                                             
000402121008      * <p>                                                                                         
000403121009      *  This procedure iterates to the next program in the list of                                 
000404121009      *  programs to calculate coverage                                                             
000405121008      * </p>                                                                                        
000406121008      *                                                                                             
000407121009      * \param contains the current program in the list (output)                                    
000408121009      * \param contains the type of current program in the list (output)                            
000409121009      * \return indicate if the next program was retrieved                                          
000410121008      */                                                                                            
000411121001     p nextProgram     b                                                                            
000412121001     d                 pi              n                                                            
000413121001     d currentProgram                      likeds(qualifiedName_t)                                  
000414121001     d currentProgramType...                                                                        
000415121001     d                               10a                                                            
000416121001     d tempProgramName...                                                                           
000417121001     d                 s                   like(qualifiedName_t.name)                               
000418121001     d tempProgramLib  s                   like(qualifiedName_t.library)                            
000419121001                                                                                                    
000420121001      /free                                                                                         
000421121001       monitor;                                                                                     
000422121008         EXEC SQL                                                                                   
000423121008           FETCH NEXT FROM PROGRAM_LIST                                                             
000424121008            INTO :TEMPPROGRAMLIB, :TEMPPROGRAMNAME, :CURRENTPROGRAMTYPE;                            
000425121001                                                                                                    
000426121001         if CSQLUTIL_checkSQLState(SQLSTT:'FECTH PROGRAM_LIST');                                    
000427121001           currentProgram.name    = tempProgramName;                                                
000428121001           currentProgram.library = tempProgramLib;                                                 
000429121001           return *on;                                                                              
000430121001         else;                                                                                      
000431121008           EXEC SQL                                                                                 
000432121008             CLOSE PROGRAM_LIST;                                                                    
000433121001                                                                                                    
000434121001           return *off;                                                                             
000435121001         endif;                                                                                     
000436121001       on-error;                                                                                    
000437121001         CEXCEPTION_catchException();                                                               
000438121001         CEXCEPTION_printStackTrace();                                                              
000439121001                                                                                                    
000440121001         monitor;                                                                                   
000441121008           EXEC SQL                                                                                 
000442121008             CLOSE PROGRAM_LIST;                                                                    
000443121001         on-error;                                                                                  
000444121001           //Ignore error                                                                           
000445121001         endmon;                                                                                    
000446121001                                                                                                    
000447121008         CEXCEPTION_throwNewException('CPF9898':'QCPFMSGF'                                          
000448121008            :'Error retrieving program from list');                                                 
000449121001       endmon;                                                                                      
000450121001      /end-free                                                                                     
000451121001     p                 e                                                                            
000452121001      //_______________________________________________________________________                     
000453121001                                                                                                    
000454121008     /**                                                                                            
000455121009      * \brief retrieveExecutableLines: retrieve the executable lines of a mod.                     
000456121008      *                                                                                             
000457121008      * <p>                                                                                         
000458121009      *  This procedure uses the debbuger API to retrieve all the executable                        
000459121009      *  source lines an write them in a temporary code file                                        
000460121008      * </p>                                                                                        
000461121008      *                                                                                             
000462121009      * \param qualified name of the program                                                        
000463121009      * \param type of the program                                                                  
000464121008      */                                                                                            
000465121001     p retrieveExecutableLines...                                                                   
000466121001     p                 b                                                                            
000467121001     d                 pi                                                                           
000468121009     d programName                         likeds(qualifiedName_t)                                  
000469121001     d programType                   10a   const options(*varsize)                                  
000470121001     d                                                                                              
000472121001     d index           s             10i 0                                                          
000480121009     d viewIndex       ds                  likeds(viewIndex_type)                                   
000482121009     d program_data    ds                  likeds(programData_type)                                 
000484121009                                                                                                    
000485121001      /free                                                                                         
000486121001       monitor;                                                                                     
000487121009         //Retrieve and register all the debug views                                                
000488121011         TRCHANDLER_retrieveDebugViews(programName:programType:program_data);                       
000490121009                                                                                                    
000494121011         if (program_data.viewIndexListSize > 0);                                                   
000496121011           program_data.programType = programType;                                                  
000497121011           program_data.program     = programName;                                                  
000499121009                                                                                                    
000502121011           for index = 1 to program_data.viewIndexListSize;                                         
000503121011             viewIndex = program_data.viewIndexList(index);                                         
000505121009             //Write all the source code in a temporary file                                        
000506121009             writeSource(viewIndex:programName);                                                    
000507121009           endfor;                                                                                  
000510121009         else;                                                                                      
000512121009           CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'                                         
000513121009             :'Error retrieving debug views for ' + programName);                                   
000514121009         endif;                                                                                     
000553121001       on-error;                                                                                    
000554121001         CEXCEPTION_catchException();                                                               
000555121001         CEXCEPTION_printStackTrace();                                                              
000556121009         CEXCEPTION_throwNewException('CPF9898':'QCPFMSG'                                           
000557121009           :'Error retrieving debug views');                                                        
000558121001       endmon;                                                                                      
000559121001      /end-free                                                                                     
000560121001     p                 e                                                                            
000561121001      //_______________________________________________________________________                     
000562121001                                                                                                    
000563121008     /**                                                                                            
000564121009      * \brief writeSource: writes to a file the executables lines of a program                     
000565121008      *                                                                                             
000566121008      * <p>                                                                                         
000567121009      *  This procedure writes the retrieved source lines of a program to                           
000568121009      *  a temporary file                                                                           
000569121008      * </p>                                                                                        
000570121008      *                                                                                             
000571121009      * \param index of the available debug views                                                   
000572121008      * \return                                                                                     
000573121008      */                                                                                            
000574120823     p writeSource     b                                                                            
000575120821     d                 pi                                                                           
000576121009     d viewIndex                           likeds(viewIndex_type) const                             
000580121001     d programName                         likeds(qualifiedName_t) const                            
000581120823     d                                                                                              
000582120821     d stmtBuffer      ds                  likeds(statementBuffer_type)                             
000583120823     d                                     based(stmtBufferPtr)                                     
000584120821     d stmtBufferLen   s             10i 0                                                          
000585120821     d tempBuffer      ds                  likeds(statementBuffer_type)                             
000586120821     d tempBufferLen   s             10i 0 inz(8)                                                   
000587120821     d index           s             10i 0                                                          
000588120821     d limit           s             10i 0                                                          
000589120821     d statementInfo   ds                  likeds(statementInfo_type)                               
000590120821     d                                     based(statementInfoPtr)                                  
000591120821     d procedureInfo   ds                  likeds(procedureInfo_type)                               
000592120821     d                                     based(procedureInfoPtr)                                  
000593121009     d procedureName   s           1024a                                                            
000595120821     d codeLineNum     s             10i 0                                                          
000596121004     d listingLineNum  s             10i 0                                                          
000597120821     d codeLine        ds                  likeds(codeLine_type)                                    
000598120821     d errorDS         ds                  likeds(ApiError_Type) inz(*likeds)                       
000599120821     d newRecord       ds                  likeds(traceCoverLine_record)                            
000600121009     d statementLine   s             10i 0                                                          
000601120823                                                                                                    
000602120821      /free                                                                                         
000603120821       clear tempBuffer;                                                                            
000604120823                                                                                                    
000605120823       //Forces an exception if the api fails                                                       
000606120821       errorDs.Bytes = 0;                                                                           
000607120823                                                                                                    
000608120821       //Query the API to retrieve the size that must be                                            
000609120821       //allocated for the buffer                                                                   
000610121009       RetrieveStatementViewAPI(tempBuffer                                                          
000611121009          :tempBufferLen:viewIndex.statementId:1:0:errorDS);                                        
000612120821                                                                                                    
000613120821       //Alloc the right size                                                                       
000614120821       stmtBufferLen = tempBuffer.bytesAvailable;                                                   
000615120821       stmtBufferPtr = TS_Malloc(stmtBufferLen);                                                    
000616120821                                                                                                    
000617120821       //Retrieve the data with the right buffer                                                    
000618120821       RetrieveStatementViewAPI(stmtBuffer:stmtBufferLen                                            
000619121009           :viewIndex.statementId:1:0:errorDS);                                                     
000620120821                                                                                                    
000621120821       limit = stmtBuffer.numLinesReturned;                                                         
000622120821                                                                                                    
000623120821       for index = 1 to limit;                                                                      
000624121009         procedureName = TRCHANDLER_getCurrentProcedureName(                                        
000625121009           stmtBufferPtr:index:statementLine);                                                      
000626121009                                                                                                    
000639121009         codeLine = TRCHANDLER_getCodeLine(viewIndex:index);                                        
000640121009                                                                                                    
000655120823         //Prepare the record to write                                                              
000656121009         newRecord.CODSTMT  = statementLine;                                                        
000657121001         newRecord.CODESEQ  = codeline.sequence;                                                    
000658121001                                                                                                    
000659121001         monitor;                                                                                   
000660121001           newRecord.CODEDATE = %date(codeline.date:*YMD0);                                         
000661121001         on-error;                                                                                  
000662121004           newRecord.CODEDATE = %date('1940-01-01');                                                
000663121001         endmon;                                                                                    
000664121001                                                                                                    
000665121001         newRecord.CODEDTA  = codeline.text;                                                        
000666121001         newRecord.PGMLIB   = programName.library;                                                  
000667121001         newRecord.PGMNAME  = programName.name;                                                     
000668121009         newRecord.MDLNAME  = viewIndex.module;                                                     
000669121009         newRecord.PROCNAME = procedureName;                                                        
000671120821                                                                                                    
000672121009         EXEC SQL                                                                                   
000673121009           INSERT INTO FULLCODE VALUES(:NEWRECORD);                                                 
000674120823       endfor;                                                                                      
000675120823                                                                                                    
000676120823       //Release the memory used                                                                    
000677120823       TS_Free(stmtBufferPtr);                                                                      
000678120821      /end-free                                                                                     
000679120821     p                 e                                                                            
000680120821      //_______________________________________________________________________                     
000681120821                                                                                                    
000682121008     /**                                                                                            
000683121009      * \brief generateStatistics: generate coverage statistics                                     
000684121008      *                                                                                             
000685121008      * <p>                                                                                         
000686121009      *  This procedure generates the coverage statistics. This process                             
000687121009      *  include the tracecover data file and the the summary tables                                
000688121008      * </p>                                                                                        
000692121008      */                                                                                            
000693120823     p generateStatistics...                                                                        
000694120823     p                 b                                                                            
000695120823                                                                                                    
000696120823      /free                                                                                         
000697121008       //------------------------------------------                                                 
000698121008       //Generate execution frequency per code line                                                 
000699121008       EXEC SQL                                                                                     
000700121009         INSERT INTO TRACECOVER                                                                     
000701121009           SELECT DISTINCT                                                                          
000702121009                  CODELINES.PGMLIB,                                                                 
000703121009                  CODELINES.PGMNAME,                                                                
000704121009                  CODELINES.MDLNAME,                                                                
000705121009                  CODELINES.PROCNAME,                                                               
000706121009                  CODELINES.CODSTMT,                                                                
000707121009                  CODELINES.CODESEQ,                                                                
000708121009                  CODELINES.CODEDATE,                                                               
000709121009                  CODELINES.CODEDTA,                                                                
000710121009                  (SELECT COUNT(*)                                                                  
000711121009                     FROM TRACEDATA TEMPTRACE                                                       
000712121009                    WHERE CODELINES.CODESEQ = TEMPTRACE.CODESEQ                                     
000713121009                      AND CODELINES.CODSTMT = TEMPTRACE.CODSTMT                                     
000714121009                      AND CODELINES.PGMLIB  = TEMPTRACE.PGMLIB                                      
000715121009                      AND CODELINES.PGMNAME = TEMPTRACE.PGMNAME                                     
000716121009                      AND CODELINES.MDLNAME = TEMPTRACE.MDLNAME                                     
000717121009                  ) FREQEXEC                                                                        
000718121009             FROM FULLCODE CODELINES                                                                
000719121009             LEFT JOIN TRACEDATA EXECLINES                                                          
000720121009               ON CODELINES.CODSTMT = EXECLINES.CODSTMT                                             
000721121009              AND CODELINES.CODESEQ = EXECLINES.CODESEQ                                             
000722121009              AND CODELINES.PGMLIB  = EXECLINES.PGMLIB                                              
000723121009              AND CODELINES.PGMNAME = EXECLINES.PGMNAME                                             
000724121009              AND CODELINES.MDLNAME = EXECLINES.MDLNAME                                             
000725121009         ORDER BY CODELINES.PGMLIB, CODELINES.PGMNAME,                                              
000726121009                  CODELINES.MDLNAME, CODELINES.PROCNAME,                                            
000727121009                  CODELINES.CODSTMT;                                                                
000728121009                                                                                                    
000729121009       //Check sql resukt                                                                           
000730121009       CSQLUTIL_checkSQLState(sqlstt:'Insert into tracecover');                                     
000731121009                                                                                                    
000732121008       //-------------------------                                                                  
000733121008       //Generate coverage summary                                                                  
000734121008       EXEC SQL                                                                                     
000735121008         INSERT INTO COVERTOTAL (                                                                   
000736121008           SELECT RESULT.*,                                                                         
000737121008  	             CAST(DEC(RESULT.EXECLINES) /                                                        
000738121008                       DEC(RESULT.TOTLINES) AS DECIMAL(10,5))                                       
000739121008                      AS COVERAGE                                                                   
000740121008             FROM (SELECT COVER.PGMLIB,                                                             
000741121008         	               COVER.PGMNAME,                                                             
000742121008                     	   COUNT(COVER.CODSTMT) AS TOTLINES,                                          
000743121008         	               (SELECT COUNT(*)                                                           
000744121008                     	      FROM TRACECOVER                                                         
000745121008                     	     WHERE FREQEXEC > 0                                                       
000746121008                     	       AND COVER.PGMLIB  = PGMLIB                                             
000747121008                     	       AND COVER.PGMNAME = PGMNAME                                            
000748121008             	     GROUP BY PGMLIB, PGMNAME) AS EXECLINES	                                          
000749121008                     FROM TRACECOVER COVER                                                          
000750121008                    GROUP BY PGMLIB, PGMNAME) RESULT);                                              
000751121008                                                                                                    
000752121009       //Check sql resukt                                                                           
000753121009       CSQLUTIL_checkSQLState(sqlstt:'Insert into covertotal');                                     
000754120823      /end-free                                                                                     
000755120823     p                 e                                                                            
000756120823      //_______________________________________________________________________                     
000757121008                                                                                                    
000758121008     /**                                                                                            
000759121009      * \brief sendUserMessage: sends a message to the user session                                 
000760121008      *                                                                                             
000761121008      * <p>                                                                                         
000762121009      *  This procedure sends a message to the user in the                                          
000763121009      *  interactive session.                                                                       
000764121008      * </p>                                                                                        
000765121008      *                                                                                             
000766121009      * \param  message to send                                                                     
000767121008      */                                                                                            
000768121008     p sendUserMessage...                                                                           
000769121008     p                 b                   export                                                   
000770121008     d                 pi                                                                           
000771121008     d message                      150a   const                                                    
000772121008     d                                                                                              
000773121008     d errorApi        ds                  likeds(errorDS_Type)                                     
000774121008     d msgKey          s              4a                                                            
000775121008                                                                                                    
000776121008      /free                                                                                         
000777121008       SendProgramMessage(*blanks:                                                                  
000778121008                    *blanks:                                                                        
000779121008                    message:                                                                        
000780121008                    %len(%trimr(message)):                                                          
000781121008                    '*COMP':                                                                        
000782121008                    '*':                                                                            
000783121008                    5:                                                                              
000784121008                    MsgKey:                                                                         
000785121008                    errorApi);                                                                      
000786121008                                                                                                    
000787121008      /end-free                                                                                     
000788121008     p                 e                                                                            
000789121008      //_______________________________________________________________________                     
000790121008                                                                                                    
