*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGIT............................................*
DATA:  BEGIN OF STATUS_ZGIT                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGIT                          .
*...processing: ZGIT_SET........................................*
DATA:  BEGIN OF STATUS_ZGIT_SET                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGIT_SET                      .
CONTROLS: TCTRL_ZGIT_SET
            TYPE TABLEVIEW USING SCREEN '0005'.
*.........table declarations:.................................*
TABLES: *ZGIT                          .
TABLES: *ZGIT_SET                      .
TABLES: ZGIT                           .
TABLES: ZGIT_SET                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
