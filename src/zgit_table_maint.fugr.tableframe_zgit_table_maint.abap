*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZGIT_TABLE_MAINT
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZGIT_TABLE_MAINT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
