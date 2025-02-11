class ZL_AIC_CMCD_AICCMCDHEADER_CTXT definition
  public
  inheriting from CL_AIC_CMCD_AICCMCDHEADER_CTXT
  create public .

public section.
protected section.

  methods CONNECT_NODES
    redefinition .
  methods CREATE_CONTEXT_NODES
    redefinition .
  methods CREATE_BTCUSTOMERH
    redefinition .
private section.

  data ZBTCUSTOMERH type ref to ZL_AIC_CMCD_AICCMCDHEADER_CN05 .
ENDCLASS.



CLASS ZL_AIC_CMCD_AICCMCDHEADER_CTXT IMPLEMENTATION.


  method CONNECT_NODES.

    data: coll_wrapper type ref to cl_bsp_wd_collection_wrapper.

    super->connect_nodes( iv_activate ).


  endmethod.


  method CREATE_BTCUSTOMERH.
    DATA:
      model        TYPE REF TO if_bsp_model,
      coll_wrapper TYPE REF TO cl_bsp_wd_collection_wrapper,
      entity       TYPE REF TO cl_crm_bol_entity,    "#EC *
      entity_col   TYPE REF TO if_bol_entity_col.    "#EC *

    model = owner->create_model(

      class_name     = 'ZL_AIC_CMCD_AICCMCDHEADER_CN05'

        model_id       = 'BTCUSTOMERH' ). "#EC NOTEXT
    BTCUSTOMERH ?= model.
    CLEAR model.
  coll_wrapper =
  btadminh->get_collection_wrapper( ).
  TRY.
      entity ?= coll_wrapper->get_current( ).
    CATCH cx_sy_move_cast_error.
  ENDTRY.
  IF entity IS BOUND.
    btcustomerh->on_new_focus(
               focus_bo = entity ).
  ENDIF.
  endmethod.


  method CREATE_CONTEXT_NODES.


    super->create_context_nodes( controller ).


  endmethod.
ENDCLASS.
