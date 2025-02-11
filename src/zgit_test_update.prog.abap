*&---------------------------------------------------------------------*
*& Report  ZGIT_RUN_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zgit_test_update.

at selection-screen.

start-of-selection.

  call method zcl_git_helper=>get_in_proc_repo
    importing
      et_reports = data(lt_to_update).

  loop at lt_to_update into data(lv_to_update).
    write:/ 'Updating repo: ', lv_to_update-repo, ',workflow:', lv_to_update-workflow_id, ',run:', lv_to_update-run_id.
    data lv_canceled type boolean.
    lv_canceled = 0.

    "11 check if test is running, and cencel if needed
    call method zcl_git_helper=>git_get_workflow_run
      exporting
        iv_repo     = lv_to_update-repo
        iv_run_id   = lv_to_update-run_id
      importing
        es_git_data = data(ls_is_on).

    if ls_is_on-status = 'in_progress' or ls_is_on-status = 'queued'.
      call method zcl_git_helper=>cancel_workflow_run
        exporting
          iv_git_data = ls_is_on
        importing
          ev_ok       = lv_canceled.
      if lv_canceled = 1.
        ls_is_on-status = 'canceled'.
        "12 test was canceled, update status
        write:/ 'Run canceled'.
      endif.
    endif.

    "20 update documents data
    select distinct h~guid
      from crmd_customer_h as h
      where ( h~zzgit_status = 'in_progress' or h~zzgit_status = 'queued' )
      and h~zzgit_workflow = @ls_is_on-workflow_id
      and h~zzgit_run_id = @ls_is_on-run_id
      and h~zzbypassgit = ''
      into table @data(et_guids).

    loop at et_guids into data(lv_guid).
      ls_is_on-guid = lv_guid-guid.
      call method zcl_git_helper=>set_git_data_cd_db
        exporting
          iv_git_data = ls_is_on
        importing
          ev_ok       = data(lv_ok).
      if lv_ok = 1.
        write: / 'Document updated:', lv_guid-guid, ls_is_on-status, ls_is_on-conclusion, 'workflow_id: ',
        ls_is_on-workflow_id, 'run_id: ', ls_is_on-run_id.
      endif.

    endloop.
  endloop.

  "30 update documents status
  call method zcl_git_helper=>set_docs_status.

  "70 Schedule next report to get tests results.
  call method zcl_git_helper=>schedule_follow_up_job.
