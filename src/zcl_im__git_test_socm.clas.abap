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

* !!! This checks will be processed only for documents with GITHUB
    if ls_customer_h-zzgit_repo is not initial and ls_customer_h-zzbypassgit = ''.
      case flt_val.  "values must be chosen from DB-table TSOCM_CONDITIONS
        when 'ZGIT_PASS'.
          "check that document is set?
          if ls_customer_h-zzgit_status cs 'success'.
            conditions_ok = abap_true.
          else.
            conditions_ok = cl_socm_integration=>false.
          endif.

          if conditions_ok = cl_socm_integration=>false.
            if ls_error_message is not initial.
              " show message in webui
              cl_ai_crm_utility=>show_message( ls_error_message ).
            endif.
            return.
          endif.
      endcase.
    endif.
  endmethod.
ENDCLASS.
