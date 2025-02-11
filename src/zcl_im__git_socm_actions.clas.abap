class ZCL_IM__GIT_SOCM_ACTIONS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SOCM_PROCESS_ACTION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__GIT_SOCM_ACTIONS IMPLEMENTATION.


  method if_ex_socm_process_action~process_action.
    "reset git test status.
    data: lv_guid       type guid.

    case flt_val.
      when 'ZTEST_RESET'.
        "get attributes
        lv_guid = hf_instance->change_document_id.
        if lv_guid is not initial.
          update crmd_customer_h set zzgit_status = ''
          where guid = @lv_guid and zzbypassgit = '' and zzgit_repo <> ''.
        endif.
    endcase.

  endmethod.
ENDCLASS.
