class ZL_AIC_CMCD_AICCMCDHEADER_CN05 definition
  public
  inheriting from CL_AIC_CMCD_AICCMCDHEADER_CN05
  create public .

public section.

  methods GET_I_ZZBYPASSGIT
    importing
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(RV_DISABLED) type STRING .
  methods GET_I_ZZGIT_REPO
    importing
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(RV_DISABLED) type STRING .
  methods GET_M_ZZBYPASSGIT
    importing
      !ATTRIBUTE_PATH type STRING
    returning
      value(METADATA) type ref to IF_BSP_METADATA_SIMPLE .
  methods GET_M_ZZGIT_REPO
    importing
      !ATTRIBUTE_PATH type STRING
    returning
      value(METADATA) type ref to IF_BSP_METADATA_SIMPLE .
  methods GET_ZZBYPASSGIT
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(VALUE) type STRING .
  methods GET_ZZGIT_REPO
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
    returning
      value(VALUE) type STRING .
  methods SET_ZZBYPASSGIT
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
      !VALUE type STRING .
  methods SET_ZZGIT_REPO
    importing
      !ATTRIBUTE_PATH type STRING
      !ITERATOR type ref to IF_BOL_BO_COL_ITERATOR optional
      !VALUE type STRING .
  methods GET_V_ZZGIT_REPO
    importing
      !IV_MODE type CHAR1 default IF_BSP_WD_MODEL_SETTER_GETTER=>RUNTIME_MODE
      !IV_INDEX type I optional
    returning
      value(RV_VALUEHELP_DESCRIPTOR) type ref to IF_BSP_WD_VALUEHELP_DESCRIPTOR .
protected section.
private section.
ENDCLASS.



CLASS ZL_AIC_CMCD_AICCMCDHEADER_CN05 IMPLEMENTATION.


  method get_i_zzbypassgit.
    data: current type ref to if_bol_bo_property_access.

    rv_disabled = 'TRUE'.
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

    try.

        if current->is_property_readonly(
                      'ZZBYPASSGIT' ) = abap_false.         "#EC NOTEXT
          rv_disabled = 'FALSE'.
        endif.

      catch cx_sy_ref_is_initial cx_sy_move_cast_error
            cx_crm_genil_model_error.
        return.
    endtry.

    " 1.  The Fields “Test Set” and “Bypass Reason” should be enabled until
    " “To be Regressions Tested” status.
    if rv_disabled = 'FALSE'.
      data lv_guid       type crmt_object_guid.
      data: dref    type ref to data.
      data:lr_btadminh type ref to cl_crm_bol_entity.

      "get document guid
      try.
          data: coll   type ref to if_bol_entity_col.
          data: entity type ref to cl_crm_bol_entity.

          entity ?= current.

          check entity is bound.

          entity->get_property_as_value(
            exporting
              iv_attr_name =     'GUID'
            importing
              ev_result    = lv_guid ).
        catch cx_root.
      endtry.

      if lv_guid is initial.
        "customer_h is not field.
        check current is bound.
        lr_btadminh ?= current.
* GET PARENT ENTITY
        try.
            while lr_btadminh->get_name( ) ne 'BTAdminH'.
              lr_btadminh = lr_btadminh->get_parent( ).
            endwhile.
          catch cx_sy_ref_is_initial.
        endtry.
* GET PROC
        if lr_btadminh is bound.

          lr_btadminh->get_property_as_value(
         exporting
           iv_attr_name =     'GUID'
         importing
           ev_result    = lv_guid ).
        endif.
      endif.
      if lv_guid is not initial.
        "check if CCL is enabled for git
        select single set~ccl
          from tsocm_cr_context as cont
          left join slan_header as ccl on ccl~slan_id = cont~slan_id
          left join zgit_set as set on ccl~slan_name = set~ccl
          where cont~created_guid = @lv_guid
          and set~repo is not null
          and set~testset_key is not null
          and set~testplan is not null
          into @data(lv_ccl).
        if lv_ccl is initial.
          rv_disabled = 'TRUE'.
        else.
          "check if document was or is in status To Be Regression Tested
          select single stat from crm_jest where objnr = @lv_guid
            and stat = 'E0025' "To Be Regression Tested
            into @data(lv_stat).
          if lv_stat is not initial.
            rv_disabled = 'TRUE'.
          endif.
        endif.
      endif.
    endif.


  endmethod.


  method get_i_zzgit_repo.
    data: current type ref to if_bol_bo_property_access.

    rv_disabled = 'TRUE'.
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

    try.

        if current->is_property_readonly(
                      'ZZGIT_REPO' ) = abap_false.          "#EC NOTEXT
          rv_disabled = 'FALSE'.
        endif.

      catch cx_sy_ref_is_initial cx_sy_move_cast_error
            cx_crm_genil_model_error.
        return.
    endtry.

    " 1.  The Fields “Test Set” and “Bypass Reason” should be enabled until
    " “To be Regressions Tested” status.
    if rv_disabled = 'FALSE'.
      data lv_guid       type crmt_object_guid.
      data: dref    type ref to data.
      data:lr_btadminh type ref to cl_crm_bol_entity.

      "get document guid
      try.
          data: coll   type ref to if_bol_entity_col.
          data: entity type ref to cl_crm_bol_entity.

          entity ?= current.

          check entity is bound.

          entity->get_property_as_value(
            exporting
              iv_attr_name =     'GUID'
            importing
              ev_result    = lv_guid ).
        catch cx_root.
      endtry.

      if lv_guid is initial.
        "customer_h is not field.
        check current is bound.
        lr_btadminh ?= current.
* GET PARENT ENTITY
        try.
            while lr_btadminh->get_name( ) ne 'BTAdminH'.
              lr_btadminh = lr_btadminh->get_parent( ).
            endwhile.
          catch cx_sy_ref_is_initial.
        endtry.
* GET PROC
        if lr_btadminh is bound.

          lr_btadminh->get_property_as_value(
         exporting
           iv_attr_name =     'GUID'
         importing
           ev_result    = lv_guid ).
        endif.
      endif.
      if lv_guid is not initial.
        "check if CCL is enabled for git
        select single set~ccl
          from tsocm_cr_context as cont
          left join slan_header as ccl on ccl~slan_id = cont~slan_id
          left join zgit_set as set on ccl~slan_name = set~ccl
          where cont~created_guid = @lv_guid
          and set~repo is not null
          and set~testset_key is not null
          and set~testplan is not null
          into @data(lv_ccl).
        if lv_ccl is initial.
          rv_disabled = 'TRUE'.
        else.
          "check if document was or is in status To Be Regression Tested
          select single stat from crm_jest where objnr = @lv_guid
            and stat = 'E0025' "To Be Regression Tested
            into @data(lv_stat).
          if lv_stat is not initial.
            rv_disabled = 'TRUE'.
          endif.
        endif.
      endif.
    endif.
  endmethod.


  method GET_M_ZZBYPASSGIT.

  DATA: attr    TYPE ZDTEL00000M.

  DATA: dref    TYPE REF TO data.

  GET REFERENCE OF attr INTO dref.

  metadata ?= if_bsp_model_binding~get_attribute_metadata(
       attribute_ref  = dref
       attribute_path = attribute_path
       name           = 'ZZBYPASSGIT'  "#EC NOTEXT
*      COMPONENT      =
       no_getter      = 1 ).


  endmethod.


  method GET_M_ZZGIT_REPO.

  DATA: attr    TYPE ZDTEL00000G.

  DATA: dref    TYPE REF TO data.

  GET REFERENCE OF attr INTO dref.

  metadata ?= if_bsp_model_binding~get_attribute_metadata(
       attribute_ref  = dref
       attribute_path = attribute_path
       name           = 'ZZGIT_REPO'  "#EC NOTEXT
*      COMPONENT      =
       no_getter      = 1 ).


  endmethod.


method get_v_zzgit_repo.
*---------------------
  data lv_guid       type crmt_object_guid.
  data: current type ref to if_bol_bo_property_access.
  data: dref    type ref to data.

  data:lt_keypair  type bsp_wd_dropdown_table,
       ls_keypair  like line of lt_keypair,
       lt_values   type table of dd07t,
       ls_values   like line of lt_values,
       lr_dropdown type ref to cl_crm_uiu_ddlb.

  data:lt_ddlb type bsp_wd_dropdown_table.
  data:lr_btadminh type ref to cl_crm_bol_entity.

  current = collection_wrapper->get_current( ).

  try.

      data: coll   type ref to if_bol_entity_col.
      data: entity type ref to cl_crm_bol_entity.
      data: lv_ccl type slan_technical_name.

      entity ?= current.

      check entity is bound.

      entity->get_property_as_value(
        exporting
          iv_attr_name =     'GUID'
        importing
          ev_result    = lv_guid ).
    catch cx_root.
  endtry.

  if lv_guid is initial.
    "customer_h is not field.
    check current is bound.
    lr_btadminh ?= current.
* GET PARENT ENTITY
    try.
        while lr_btadminh->get_name( ) ne 'BTAdminH'.
          lr_btadminh = lr_btadminh->get_parent( ).
        endwhile.
      catch cx_sy_ref_is_initial.
    endtry.
* GET PROC
    if lr_btadminh is bound.

      lr_btadminh->get_property_as_value(
     exporting
       iv_attr_name =     'GUID'
     importing
       ev_result    = lv_guid ).
    endif.
  endif.

  select single s~slan_name
    from tsocm_cr_context as c
    left join slan_header as s on c~slan_id = s~slan_id
    where c~created_guid = @lv_guid
    into @lv_ccl.

  if lv_ccl is not initial.
    select v~* into table @lt_values from dd07t as v
      left join zgit_set as g on v~domvalue_l = g~testset_id
      where v~domname = 'ZDTEL00000G' and v~ddlanguage = @sy-langu and g~ccl = @lv_ccl.
    if sy-subrc = 0.
      "take required values in the form of key-value pairs.
      clear ls_values.
      loop at lt_values into ls_values.
        ls_keypair-key = ls_values-domvalue_l.
        ls_keypair-value = ls_values-ddtext.
        append ls_keypair to lt_keypair.
        clear ls_values.
      endloop.

      create object lr_dropdown
        exporting
          iv_source_type = 'T'.
      "insert initial line in case user wants to choose blank values.
      insert initial line into lt_keypair index 1.

      "give the values we fetched.
      lr_dropdown->set_selection_table( it_selection_table = lt_keypair ).
    endif.

    rv_valuehelp_descriptor = lr_dropdown.
  endif.

  if rv_valuehelp_descriptor is initial.
    "github is not bound to ccl?
    select v~* into table @lt_values from dd07t as v
    where v~domname = 'ZDTEL00000G' and v~ddlanguage = @sy-langu
      and v~ddtext = 'TEST N/A'.

    if sy-subrc = 0.
      "take required values in the form of key-value pairs.
      clear ls_values.
      loop at lt_values into ls_values.
        ls_keypair-key = ls_values-domvalue_l.
        ls_keypair-value = ls_values-ddtext.
        append ls_keypair to lt_keypair.
        clear ls_values.
      endloop.

      create object lr_dropdown
        exporting
          iv_source_type = 'T'.
      "insert initial line in case user wants to choose blank values.
      insert initial line into lt_keypair index 1.

      "give the values we fetched.
      lr_dropdown->set_selection_table( it_selection_table = lt_keypair ).
    endif.
    rv_valuehelp_descriptor = lr_dropdown.
  endif.

  if rv_valuehelp_descriptor is initial.
    "all other options are failed, just populate defoult values.
    data: lr_handler type ref to if_axt_ui_context_node_handler.
    lr_handler = get_ext_access( ).

    if lr_handler is not bound.
      "No handler could be found
      "This should not happen as there could not be ext. fields

      return.
    endif.
    rv_valuehelp_descriptor = lr_handler->get_v(
      component               = 'ZZGIT_REPO'
      iv_mode                 = iv_mode
      iv_index                = iv_index
         ).
  endif.

endmethod.


  method GET_ZZBYPASSGIT.

    DATA: current TYPE REF TO if_bol_bo_property_access.
    DATA: dref    TYPE REF TO data.


    value =
'BTCustomerH not bound'."#EC NOTEXT


    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.


  TRY.

    TRY.
        dref = current->get_property( 'ZZBYPASSGIT' ). "#EC NOTEXT
      CATCH cx_crm_cic_parameter_error.
    ENDTRY.

    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
          cx_crm_genil_model_error.
      RETURN.
  ENDTRY.

    IF dref IS NOT BOUND.

      value = 'BTCustomerH/ZZBYPASSGIT not bound'."#EC NOTEXT

      RETURN.
    ENDIF.
    TRY.
        value = if_bsp_model_util~convert_to_string( data_ref = dref
                                    attribute_path = attribute_path ).
      CATCH cx_bsp_conv_illegal_ref.
        FIELD-SYMBOLS: <l_data> type DATA.
        assign dref->* to <l_data>.
*       please implement here some BO specific handler coding
*       conversion of currency/quantity field failed caused by missing
*       unit relation
*       Coding sample:
*       provide currency, decimals, and reference type
*       value = cl_bsp_utility=>make_string(
*                          value = <l_data>
*                          reference_value = c_currency
*                          num_decimals = decimals
*                          reference_type = reference_type
*                          ).
          value = '-CURR/QUANT REF DATA MISSING-'.
      CATCH cx_root.
        value = '-CONVERSION FAILED-'.                  "#EC NOTEXT
    ENDTRY.


  endmethod.


  method get_zzgit_repo.

    data: current type ref to if_bol_bo_property_access.
    data: dref    type ref to data.


    value =
'BTCustomerH not bound'.                                    "#EC NOTEXT


    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.
*---------------------
    data lv_guid       type crmt_object_guid.
    data lr_entity     type ref to cl_crm_bol_entity.
    try.

        data: coll   type ref to if_bol_entity_col.
        data: entity type ref to cl_crm_bol_entity.

        entity ?= current.

        check entity is bound.
        entity->get_property_as_value(
          exporting
            iv_attr_name =     'GUID'
          importing
            ev_result    = lv_guid ).
      catch cx_root.
    endtry.
*---------------------

    try.

        try.
            dref = current->get_property( 'ZZGIT_REPO' ).   "#EC NOTEXT
          catch cx_crm_cic_parameter_error.
        endtry.

      catch cx_sy_ref_is_initial cx_sy_move_cast_error
            cx_crm_genil_model_error.
        return.
    endtry.

    if dref is not bound.

      value = 'BTCustomerH/ZZGIT_REPO not bound'.           "#EC NOTEXT

      return.
    endif.
    try.
        value = if_bsp_model_util~convert_to_string( data_ref = dref
                                    attribute_path = attribute_path ).
      catch cx_bsp_conv_illegal_ref.
        field-symbols: <l_data> type data.
        assign dref->* to <l_data>.
*       please implement here some BO specific handler coding
*       conversion of currency/quantity field failed caused by missing
*       unit relation
*       Coding sample:
*       provide currency, decimals, and reference type
*       value = cl_bsp_utility=>make_string(
*                          value = <l_data>
*                          reference_value = c_currency
*                          num_decimals = decimals
*                          reference_type = reference_type
*                          ).
        value = '-CURR/QUANT REF DATA MISSING-'.
      catch cx_root.
        value = '-CONVERSION FAILED-'.                      "#EC NOTEXT
    endtry.


  endmethod.


  method SET_ZZBYPASSGIT.
    DATA:
      current TYPE REF TO if_bol_bo_property_access,
      dref    TYPE REF TO data,
      copy    TYPE REF TO data.

    FIELD-SYMBOLS:
      <nval> TYPE ANY,
      <oval> TYPE ANY.

*   get current entity
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

*   get old value and dataref to appropriate type

  TRY.

    TRY.
        dref = current->get_property( 'ZZBYPASSGIT' ). "#EC NOTEXT
      CATCH cx_crm_cic_parameter_error.
    ENDTRY.

    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
          cx_crm_genil_model_error.
      RETURN.
  ENDTRY.


*   assure that attribue exists
    CHECK dref IS BOUND.

*   set <oval> to old value
    ASSIGN dref->* TO <oval>.
*   create a copy for new value
    CREATE DATA copy LIKE <oval>.
*   set <nval> to new value
    ASSIGN copy->* TO <nval>.

*   fill new value using the right conversion
    TRY.
*        TRY.
        CALL METHOD if_bsp_model_util~convert_from_string
          EXPORTING
            data_ref       = copy
            value          = value
            attribute_path = attribute_path.
*        CATCH cx_bsp_conv_illegal_ref.
*          FIELD-SYMBOLS: <l_data> type DATA.
*          assign copy->* to <l_data>.
*         please implement here some BO specific handler coding
*         conversion of currency/quantity field failed caused by missing
*         unit relation
*         Coding sample:
*         provide currency for currency fields or decimals for quantity (select from T006).
*          cl_bsp_utility=>instantiate_simple_data(
*                             value = value
*                             reference = c_currency
*                             num_decimals = decimals
*                             use_bsp_exceptions = abap_true
*                             data = <l_data> ).
*      ENDTRY.
      CATCH cx_sy_conversion_error.
        RAISE EXCEPTION TYPE cx_bsp_conv_failed
          EXPORTING
            name = 'ZZBYPASSGIT'."#EC NOTEXT
    ENDTRY.

*   only set new value if value has changed
    IF <nval> <> <oval>.

      current->set_property(
                      iv_attr_name = 'ZZBYPASSGIT' "#EC NOTEXT
                      iv_value     = <nval> ).

    ENDIF.


  endmethod.


  method SET_ZZGIT_REPO.
    DATA:
      current TYPE REF TO if_bol_bo_property_access,
      dref    TYPE REF TO data,
      copy    TYPE REF TO data.

    FIELD-SYMBOLS:
      <nval> TYPE ANY,
      <oval> TYPE ANY.

*   get current entity
    if iterator is bound.
      current = iterator->get_current( ).
    else.
      current = collection_wrapper->get_current( ).
    endif.

*   get old value and dataref to appropriate type

  TRY.

    TRY.
        dref = current->get_property( 'ZZGIT_REPO' ). "#EC NOTEXT
      CATCH cx_crm_cic_parameter_error.
    ENDTRY.

    CATCH cx_sy_ref_is_initial cx_sy_move_cast_error
          cx_crm_genil_model_error.
      RETURN.
  ENDTRY.


*   assure that attribue exists
    CHECK dref IS BOUND.

*   set <oval> to old value
    ASSIGN dref->* TO <oval>.
*   create a copy for new value
    CREATE DATA copy LIKE <oval>.
*   set <nval> to new value
    ASSIGN copy->* TO <nval>.

*   fill new value using the right conversion
    TRY.
*        TRY.
        CALL METHOD if_bsp_model_util~convert_from_string
          EXPORTING
            data_ref       = copy
            value          = value
            attribute_path = attribute_path.
*        CATCH cx_bsp_conv_illegal_ref.
*          FIELD-SYMBOLS: <l_data> type DATA.
*          assign copy->* to <l_data>.
*         please implement here some BO specific handler coding
*         conversion of currency/quantity field failed caused by missing
*         unit relation
*         Coding sample:
*         provide currency for currency fields or decimals for quantity (select from T006).
*          cl_bsp_utility=>instantiate_simple_data(
*                             value = value
*                             reference = c_currency
*                             num_decimals = decimals
*                             use_bsp_exceptions = abap_true
*                             data = <l_data> ).
*      ENDTRY.
      CATCH cx_sy_conversion_error.
        RAISE EXCEPTION TYPE cx_bsp_conv_failed
          EXPORTING
            name = 'ZZGIT_REPO'."#EC NOTEXT
    ENDTRY.

*   only set new value if value has changed
    IF <nval> <> <oval>.

      current->set_property(
                      iv_attr_name = 'ZZGIT_REPO' "#EC NOTEXT
                      iv_value     = <nval> ).

    ENDIF.


  endmethod.
ENDCLASS.
