class ZCL_IM__GIT_TEST definition
  public
  final
  create public .

public section.

  interfaces IF_EX_EXEC_METHODCALL_PPF .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__GIT_TEST IMPLEMENTATION.


  method if_ex_exec_methodcall_ppf~execute.
    data: lo_1order  type ref to cl_ags_crm_1o_api,
          lt_timerep type ags_t_crm_timerep.

    data: lr_appl            type ref to cl_doc_crm_order,
          lv_header_guid     type crmt_object_guid,
          lcl_action_execute type ref to cl_action_execute,
          lv_save_subrc      like rp_status.



    include crm_mode_con.

    rp_status = 1. "0 = Not Processed, 1 = Successfully Processed , 2 = Incorrectly Processed.
    lcl_action_execute = cl_action_execute=>get_instance( ).

    try.
        lr_appl ?= io_appl_object.
        lv_header_guid  = lr_appl->get_crm_obj_guid( ).

      catch cx_sy_move_cast_error .
        rp_status = 2.
        return.
    endtry.


    call method zcl_git_helper=>run_job_to_git
      exporting
        iv_order_guid = lv_header_guid
      receiving
        rv_success    = data(lv_ok).
    if lv_ok = abap_true.
      rp_status = lv_ok.
    else.
      rp_status = 2.
    endif.

  endmethod.
ENDCLASS.
