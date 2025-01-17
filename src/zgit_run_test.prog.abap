*&---------------------------------------------------------------------*
*& Report  ZGIT_RUN_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zgit_run_test.
include <icon>.
tables: crmd_orderadm_h.

selection-screen begin of block p_tl_id with frame title lv_frame.
selection-screen begin of line.
selection-screen comment 01(20) lv_field for field p_t_id.
selection-screen position 21.
select-options: p_t_id for crmd_orderadm_h-guid no intervals.
selection-screen end of line.
selection-screen end of block p_tl_id.

data:
  lv_tcodes type int4,
  ls_repos  type zgit_data,
  lt_repos  like sorted table of ls_repos
  with unique key repo_s.

initialization.
  lv_frame = 'Enter CD GUID below and then execute.'.
  lv_field = 'GUID:'.

at selection-screen.

start-of-selection.

*0. Make sure the transaction exist
  select count( * ) from crmd_customer_h into @lv_tcodes
  where guid in @p_t_id
    and zzgit_repo <> ''
    and zzbypassgit = ''.

  if lv_tcodes > 0 and p_t_id is not initial.
    "   if pl_test is initial or sy-batch = 'X'.
    "10. trigger relewant tests
    select distinct c~zzgit_repo
    from crmd_customer_h as c
      where c~guid in @p_t_id
      and c~zzbypassgit = ''
      and c~zzgit_repo <> ''
      into table @data(lt_repos_to_run).

    if lt_repos_to_run is not initial.
      loop at lt_repos_to_run into data(lv_repos).
        clear: ls_repos, ls_repos.
        move-corresponding lv_repos to ls_repos.
        " get long txt
        call method zcl_git_helper=>get_repo_name_long
          exporting
            iv_repo_s = lv_repos-zzgit_repo
          importing
            ev_repo   = ls_repos-repo.

        ls_repos-repo_s = lv_repos-zzgit_repo.
        "11 check if test is running, and cencel if needed
        call method zcl_git_helper=>git_get_last_workflow_run
          exporting
            iv_repo     = ls_repos-repo
          importing
            es_git_data = data(ls_is_on).

        data lv_canceled type boolean.
        lv_canceled = 1.
        ls_is_on-repo_s = lv_repos-zzgit_repo.

        if ls_is_on-status ='in_progress' or ls_is_on-status = 'queued'.
          call method zcl_git_helper=>cancel_workflow_run
            exporting
              iv_git_data = ls_is_on
            importing
              ev_ok       = lv_canceled.
        endif.
        "12 test is not runing, disputch
        if lv_canceled = 1.
          call method zcl_git_helper=>git_dispatch_workflow
            exporting
              iv_repo     = ls_repos-repo
              iv_workflow = ls_is_on-workflow_id.
        endif.
        insert ls_repos into table lt_repos.
      endloop.
    endif.

    wait up to 5 seconds. "wate while git process data

    "20. check new workflow statuses
    loop at lt_repos into ls_repos.
      "lv_repo = ls_repos-repo.
      call method zcl_git_helper=>git_get_last_workflow_run
        exporting
          iv_repo     = ls_repos-repo
        importing
          es_git_data = ls_repos.

      "21 save data to logging table

      call method zcl_git_helper=>set_workflow_runs_data
        exporting
          iv_git_data = ls_repos.

      modify lt_repos from ls_repos
      transporting workflow_id run_id conclusion status started_at
      where repo_s = ls_repos-repo_s.
    endloop.

    "50. update documents that was passed
    loop at p_t_id into data(lv_guid_to_upd).

      select single c~zzgit_repo
      from crmd_customer_h as c
        where c~guid = @lv_guid_to_upd-low
        and c~zzbypassgit = ''
        and c~zzgit_repo <> ''
        into @data(lt_repo_to_update).

      loop at lt_repos into data(lv_result) where repo_s = lt_repo_to_update.
        lv_result-guid = lv_guid_to_upd-low.
        call method zcl_git_helper=>set_git_data_cd
          exporting
            iv_git_data = lv_result
          importing
            ev_ok       = data(lv_ok).
      endloop.
    endloop.
    "70 Schedule next report to get tests results.
    call method zcl_git_helper=>schedule_follow_up_job.
  else.
    write:/ 'No CD relevant for GIT Tests.'.
  endif.
