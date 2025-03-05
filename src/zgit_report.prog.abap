*&---------------------------------------------------------------------*
*& Report  ZGIT_BYPASS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zgit_report.
tables: slan_header, crm_jcds.

types:
  begin of vs_rep_line,
    object_id   type crmt_object_id_db,
    udate       type cddatum,
    usnam       type usnam,
    zzgit_repo  type zdtel00000g,
    slan_name   type slan_technical_name,
    zzbypassgit type zdtel00000m,
  end of vs_rep_line.

type-pools slis.
data: lt_fcat type slis_t_fieldcat_alv,
      ls_fcat type slis_fieldcat_alv.


data:
  lt_git_status type table of vs_rep_line.

selection-screen: begin of block b1 with frame title text-001.
select-options: p_ccl for slan_header-slan_name no intervals.
select-options: p_date for crm_jcds-udate.
selection-screen: end of block b1.


start-of-selection.

  select distinct a~object_id, "Change document number
    s~udate, "Date of transition to the status of "Successful Business Tests” (E0018)
    s~usnam, "Username who set the status “Successful Business Tests” (E0018)
    h~zzgit_repo, "Test Set
    ccl~slan_name,"CCL
    h~zzbypassgit "Bypass reason
    from crmd_customer_h as h
    left join crmd_orderadm_h as a on h~guid = a~guid
    left join crm_jcds as s on s~objnr = h~guid and s~inact ='' and s~stat = 'E0018'
    left join tsocm_cr_context as cont on h~guid = cont~created_guid
    left join slan_header as ccl on ccl~slan_id = cont~slan_id
    where h~zzgit_repo <> ''
    and h~zzbypassgit <> ''
    and s~stat = 'E0018'
    and s~udate in @p_date
    and ccl~slan_name in @p_ccl
   into table @data(lt_git_status_t).

  " post processing...

  loop at lt_git_status_t into data(lv_pp).
    data: lv_rep_line type vs_rep_line.
    move-corresponding lv_pp to lv_rep_line.
    insert lv_rep_line into table lt_git_status .
  endloop.

  if not lt_git_status[] is initial.
    clear ls_fcat.
    ls_fcat-fieldname = 'object_id'.
    ls_fcat-tabname   = 'lt_git_status'.
    ls_fcat-seltext_m = 'CD number'.
    ls_fcat-outputlen = '20'.
    append ls_fcat to lt_fcat.

    clear ls_fcat.
    ls_fcat-fieldname = 'udate'.
    ls_fcat-tabname   = 'lt_git_status'.
    ls_fcat-seltext_m = 'Status Set Date'.
    ls_fcat-outputlen = '10'.
    append ls_fcat to lt_fcat.

    clear ls_fcat.
    ls_fcat-fieldname = 'usnam'.
    ls_fcat-tabname   = 'lt_git_status'.
    ls_fcat-seltext_m = 'User'.
    ls_fcat-outputlen = '10'.
    append ls_fcat to lt_fcat.

    clear ls_fcat.
    ls_fcat-fieldname = 'slan_name'.
    ls_fcat-tabname   = 'lt_git_status'.
    ls_fcat-seltext_m = 'Solution'.
    ls_fcat-outputlen = '20'.
    append ls_fcat to lt_fcat.

    clear ls_fcat.
    ls_fcat-fieldname = 'zzbypassgit'.
    ls_fcat-tabname   = 'lt_git_status'.
    ls_fcat-seltext_m = 'Baypass Reason'.
    ls_fcat-outputlen = '40'.
    append ls_fcat to lt_fcat.

    call function 'REUSE_ALV_LIST_DISPLAY'
      exporting
        it_fieldcat   = lt_fcat
        i_default     = 'X'
        i_save        = 'A'
      tables
        t_outtab      = lt_git_status
      exceptions
        program_error = 1
        others        = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.
