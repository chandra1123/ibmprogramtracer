000100121008CREATE TABLE COVERTOTAL (                                                                           
000101121008        PGMLIB    VARCHAR(10) NOT NULL,                                                             
000102121008        PGMNAME   VARCHAR(10) NOT NULL,                                                             
000103121008        TOTLINES  INTEGER NOT NULL,                                                                 
000104121008        EXECLINES INTEGER NOT NULL,                                                                 
000105121008        COVERAGE  DECIMAL(10,5) NOT NULL,                                                           
000108121008        CONSTRAINT COVERTOTAL_PK PRIMARY KEY(PGMLIB, PGMNAME)                                       
000109121008);                                                                                                  
