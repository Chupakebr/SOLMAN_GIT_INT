PROCESS BEFORE OUTPUT.
 MODULE detail_init.
*
PROCESS AFTER INPUT.
 MODULE DETAIL_EXIT_COMMAND AT EXIT-COMMAND.
 MODULE DETAIL_SET_PFSTATUS.
 CHAIN.
    FIELD ZGIT-URL .
    FIELD ZGIT-TOKEN .
    FIELD ZGIT-API .
    FIELD ZGIT-TIME .
  MODULE SET_UPDATE_FLAG ON CHAIN-REQUEST.
 endchain.
 chain.
  module detail_pai.
 endchain.
