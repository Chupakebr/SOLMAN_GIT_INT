class ZCL_IM__GIT_TEST_SOCM definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SOCM_CHECK_CONDITION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__GIT_TEST_SOCM IMPLEMENTATION.


  method if_ex_socm_check_condition~check_condition.
    data:
      lo_api_object    type ref to cl_ags_crm_1o_api,
      ls_error_message type symsg.

    data: lv_msg_dummy type string.
    data: ls_msg_text  type sty_cond_ltext.
    data: ls_message   type tsocm_cond_def.

    break-point id socm.

    conditions_ok = abap_true.

    "Get document instance
    call method cl_ags_crm_1o_api=>get_instance
      exporting
        iv_language                   = sy-langu
        iv_header_guid                = hf_instance->change_document_id
        iv_process_mode               = cl_ags_crm_1o_api=>ac_mode-display
      importing
        eo_instance                   = lo_api_object
      exceptions
        invalid_parameter_combination = 1
        error_occurred                = 2
        others                        = 3.
    if sy-subrc <> 0.
      "add error handeling
    endif.

    " get customer header
    lo_api_object->get_customer_h( importing es_customer_h = data(ls_customer_h) ).

    case flt_val.  "values must be chosen from DB-table TSOCM_CONDITIONS
      when 'Z_GIT_PASS'.
        "check if test was success?
        if ls_customer_h-zzgit_status cs 'success' and ls_customer_h-zzbypassgit = ''.
          conditions_ok = abap_true.
        else.
          conditions_ok = cl_socm_integration=>false.
        endif.

        if conditions_ok = cl_socm_integration=>false.

          message e003(zcharm) into lv_msg_dummy.
          ls_message-condition_id = flt_val.
          ls_message-arbgb = sy-msgid.
          ls_message-msgnr = sy-msgno.
          ls_message-type  = sy-msgty.
          ls_msg_text-condition_id = ls_message-condition_id.
          ls_msg_text-dynamic_defined-msgid = sy-msgid.
          ls_msg_text-dynamic_defined-msgno = sy-msgno.
          ls_msg_text-dynamic_defined-msgty = sy-msgty.
          ls_msg_text-dynamic_defined-msgv1 = sy-subrc.
          call method cl_hf_helper=>post_message
            exporting
              im_change_document_id = hf_instance->change_document_id
              im_error_tbp          = ls_message
              im_cond_text          = ls_msg_text.
          return.
        endif.
      when 'Z_GIT_RESET'.
        "reset testing status
        update crmd_customer_h set zzgit_status = ''
        where guid = @hf_instance->change_document_id and zzgit_status <> ''.
      when 'Z_GIT_SET'.
        "check if test set or bypass reason is populated
        if ls_customer_h-zzgit_repo = '' and ls_customer_h-zzbypassgit = ''.
          "check if CCL is enabled for git
          select single set~ccl
            from tsocm_cr_context as cont
            left join slan_header as ccl on ccl~slan_id = cont~slan_id
            left join zgit_set as set on ccl~slan_name = set~ccl
            where cont~created_guid = @hf_instance->change_document_id
            and set~repo is not null
            and set~testset_key is not null
            and set~testplan is not null
            into @data(lv_ccl).
          if lv_ccl <> ''.
            conditions_ok = cl_socm_integration=>false.
            message e005(zcharm) into lv_msg_dummy.
            ls_message-condition_id = flt_val.
            ls_message-arbgb = sy-msgid.
            ls_message-msgnr = sy-msgno.
            ls_message-type  = sy-msgty.
            ls_msg_text-condition_id = ls_message-condition_id.
            ls_msg_text-dynamic_defined-msgid = sy-msgid.
            ls_msg_text-dynamic_defined-msgno = sy-msgno.
            ls_msg_text-dynamic_defined-msgty = sy-msgty.
            ls_msg_text-dynamic_defined-msgv1 = sy-subrc.
            call method cl_hf_helper=>post_message
              exporting
                im_change_document_id = hf_instance->change_document_id
                im_error_tbp          = ls_message
                im_cond_text          = ls_msg_text.
            return.
          endif.
        endif.
    endcase.
  endmethod.
ENDCLASS.
