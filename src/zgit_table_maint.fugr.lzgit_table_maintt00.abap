*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGIT............................................*
DATA:  BEGIN OF STATUS_ZGIT                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGIT                          .
*...processing: ZGIT_TIME.......................................*
DATA:  BEGIN OF STATUS_ZGIT_TIME                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGIT_TIME                     .
CONTROLS: TCTRL_ZGIT_TIME
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: *ZGIT                          .
TABLES: *ZGIT_TIME                     .
TABLES: ZGIT                           .
TABLES: ZGIT_TIME                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
