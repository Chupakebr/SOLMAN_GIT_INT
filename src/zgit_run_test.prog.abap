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
  with unique key  run_id.

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

  if  p_t_id is initial.
    write:/ 'Process all documents in staus regression testing'.

    call method zcl_git_helper=>get_all_cd_to_proc
      importing
        et_crm_guid = data(lt_cd).
    loop at lt_cd into data(lv_guid).
      data: ls_selopt like line of p_t_id.
      ls_selopt-sign    = 'I'.
      ls_selopt-option  = 'EQ'.
      ls_selopt-low     = lv_guid.
      insert ls_selopt into table p_t_id.
    endloop.
  endif.


  if lv_tcodes > 0 and LINES( p_t_id ) > 0.
    "   if pl_test is initial or sy-batch = 'X'.
    "10. trigger relewant tests
    select distinct cont~slan_id as ccl, set~testset_id, set~testset_key, set~repo, set~testplan
      from tsocm_cr_context as cont
      left join crmd_customer_h as git on git~guid = cont~created_guid
      left join slan_header as ccl on ccl~slan_id = cont~slan_id
      left join zgit_set as set on ccl~slan_name = set~ccl and git~zzgit_repo = set~testset_id
      where cont~created_guid in @p_t_id
      and set~repo is not null
      and set~testset_key is not null
      and set~testplan is not null
      into table @data(lt_repos_to_run).

    if lt_repos_to_run is not initial.
      call method zcl_git_helper=>git_get_user
        importing
          ev_user = data(lv_git_user).

      loop at lt_repos_to_run into data(lv_repos).
        data ls_git_settings type zgit_settings.
        clear: ls_repos, ls_repos.
        move-corresponding lv_repos to ls_repos.
        move-corresponding lv_repos to ls_git_settings.

        " dispatch workflow
        call method zcl_git_helper=>git_dispatch_workflow
          exporting
            iv_git_set = ls_git_settings
          importing
            ev_ok      = data(lv_ok).
        wait up to 3 seconds. "wate while git process data
        if lv_ok = 1.
          "20. check new workflow status
          call method zcl_git_helper=>git_get_last_workflow_run
            exporting
              iv_repo     = ls_repos-repo
            importing
              es_git_data = ls_repos.

          ls_repos-testplan = ls_git_settings-testplan.
          ls_repos-testset_key = ls_git_settings-testset_key.
          ls_repos-ccl = lv_repos-ccl.
          ls_repos-testset_id = lv_repos-testset_id.

          write:/ 'Test started:', ls_repos-repo, ', Plan:', ls_git_settings-testplan, ', key:', ls_git_settings-testplan .

          if lv_git_user = ls_repos-git_user and ls_repos-event = 'repository_dispatch'.
            "21 save data to logging table and calculate stop time
            call method zcl_git_helper=>set_workflow_runs_data
              exporting
                iv_git_data = ls_repos.
            insert ls_repos into table lt_repos.
            "APPEND ls_repos TO lt_repos.
          else.
            write:/ 'Test start data is wrong: User:', ls_repos-git_user, ', event:', ls_repos-event.
          endif.
        else.
          write:/ 'Test failed to start:', ls_repos-repo, ', Plan:', ls_git_settings-testplan, ', key:', ls_git_settings-testplan.
        endif.
      endloop.
    endif.


    "50. update documents that was passed
    loop at p_t_id into data(lv_guid_to_upd).
      data: lv_result type zgit_data.
      lv_result-guid = lv_guid_to_upd-low.

      select single c~zzgit_repo as testset_id, cont~slan_id as ccl
      from crmd_customer_h as c
      left join tsocm_cr_context as cont on c~guid = cont~created_guid
        where c~guid = @lv_guid_to_upd-low
        and c~zzbypassgit = ''
        and c~zzgit_repo <> ''
        into @data(lt_repo_to_update).

      loop at lt_repos into lv_result where ccl = lt_repo_to_update-ccl and  testset_id = lt_repo_to_update-testset_id.
        exit.
      endloop.
      lv_result-guid = lv_guid_to_upd-low.
      if lv_result-status is initial.
        lv_result-status = 'Failed to start'.
      endif.
      call method zcl_git_helper=>set_git_data_cd_db
        exporting
          iv_git_data = lv_result
        importing
          ev_ok       = lv_ok.
      write: / 'Document updated:', lv_guid_to_upd-low, lv_result-status, 'workflow_id: ',
      lv_result-workflow_id, 'run_id: ', lv_result-run_id.
    endloop.
    "70 Schedule next report to get tests results.
    call method zcl_git_helper=>schedule_follow_up_job
      importing
        ev_ok = data(lv_job_ok).
    if lv_job_ok = 1.
      write:/ 'Update job scheduled'.
    endif.
  else.
    write:/ 'No CD relevant for GIT Tests.'.
  endif.
