class ZCL_IM__GIT_ORDER_SAVE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_ORDER_SAVE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__GIT_ORDER_SAVE IMPLEMENTATION.


  method if_ex_order_save~change_before_update.
    data:
      iv_1o_api     type ref to cl_ags_crm_1o_api,
      lv_customer_h type crmt_customer_h_wrk.

    select single zzgit_repo
    from crmd_customer_h
    into (  @data(lv_repo) )
    where guid = @iv_guid.

    " get admin header
    cl_ags_crm_1o_api=>get_instance(
        exporting
        iv_header_guid                = iv_guid
        iv_process_mode               = cl_ags_crm_1o_api=>ac_mode-change  " Processing Mode of Transaction
      importing
        eo_instance                   = iv_1o_api
      exceptions
        invalid_parameter_combination = 1
        error_occurred                = 2
        others                        = 3 ).
    if sy-subrc <> 0.
    endif.

    call method iv_1o_api->get_customer_h
      importing
        es_customer_h        = lv_customer_h
      exceptions
        document_not_found   = 1
        error_occurred       = 2
        document_locked      = 3
        no_change_authority  = 4
        no_display_authority = 5
        no_change_allowed    = 6
        others               = 7.
    if sy-subrc <> 0.
*       Implement suitable error handling here
    endif.
    if lv_customer_h-zzgit_status <> ''
      and lv_customer_h-zzgit_repo <> lv_repo.
      data: lv_cust_h type crmt_customer_h_com.
      move-corresponding lv_customer_h to lv_cust_h.
      lv_cust_h-zzgit_status = ''.

      call method iv_1o_api->set_customer_h
        exporting
          is_customer_h = lv_cust_h
*       changing
*         cv_log_handle =
       exceptions
         error_occurred    = 1
         document_locked   = 2
         no_change_allowed = 3
         no_authority  = 4
         others        = 5
        .
      if sy-subrc <> 0.
*      Implement suitable error handling here
      endif.


    endif.

  endmethod.


  method IF_EX_ORDER_SAVE~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_EX_ORDER_SAVE~PREPARE.
  endmethod.
ENDCLASS.
