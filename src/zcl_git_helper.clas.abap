class ZCL_GIT_HELPER definition
  public
  final
  create public .

public section.

  class-methods SCHEDULE_FOLLOW_UP_JOB
    exporting
      !EV_OK type BOOLEAN .
  class-methods SET_DOCS_STATUS .
  class-methods GET_NEXT_RUN_TIME
    importing
      !IT_REPORTS type ZGIT_REPO_STOP_TAB
    exporting
      !EV_START_AT type TIMESTAMP .
  class-methods GET_REPO_NAME_LONG
    importing
      !IV_REPO_S type CHAR60
    exporting
      !EV_REPO type CHAR60 .
  class-methods CONVERT_GIT_DATE_TIME
    importing
      !IV_STARTED_AT type STRING
    exporting
      !EV_DATE_TIME type TIMESTAMP .
  class-methods GET_ALL_CD_TO_PROC
    exporting
      !ET_CRM_GUID type CRMT_OBJECT_GUID_TAB .
  class-methods GET_CYCLE_CD
    importing
      !IV_CRM_GUID type CRMT_OBJECT_GUID
    exporting
      !ET_CRM_GUID type CRMT_OBJECT_GUID_TAB .
  class-methods GET_IN_PROC_REPO
    exporting
      !ET_REPORTS type ZGIT_REPO_STOP_TAB .
  class-methods GET_GIT_SETTINGS
    importing
      !IV_CRM_GUID type CRMT_OBJECT_GUID
    returning
      value(ES_GIT_SETTINGS) type ZGIT_SETTINGS .
  class-methods IS_GIT_ENABLED
    importing
      !IV_CRM_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_IS_GIT) type FLAG .
  class-methods RUN_JOB_TO_GIT
    importing
      !IV_ORDER_GUID type CRMT_OBJECT_GUID
    returning
      value(RV_SUCCESS) type BOOLEAN .
  class-methods RUN_JOB_UPDATE_GIT
    importing
      !IV_START_AT type TIMESTAMP
    returning
      value(RV_SUCCESS) type BOOLEAN .
  class-methods SET_STATUS_BY_PPF
    importing
      !IV_OBJECT_GUID type CRMT_OBJECT_GUID
      !IV_ESTATUS type J_ESTAT
    returning
      value(RV_EXEC_STATUS) type PPFDTSTAT .
  class-methods SET_GIT_DATA_CD
    importing
      !IV_GIT_DATA type ZGIT_DATA
    exporting
      !EV_OK type BOOLEAN .
  class-methods SET_GIT_DATA_CD_DB
    importing
      !IV_GIT_DATA type ZGIT_DATA
    exporting
      !EV_OK type BOOLEAN .
  class-methods GET
    importing
      !IV_BODY type STRING
      !IV_URI type STRING
    exporting
      !EV_HTTP_RESPONSE type STRING
      !EV_HTTP_RESPONSE_STATUS_CODE type STRING .
  class-methods GIT_CANCEL_WORKFLOW_RUN
    importing
      !IV_RUN_ID type ZDTEL00000Q
      !IV_REPO type CHAR60
    exporting
      !EV_OK type BOOLEAN .
  class-methods CANCEL_WORKFLOW_RUN
    importing
      !IV_GIT_DATA type ZGIT_DATA
    exporting
      !EV_OK type BOOLEAN .
  class-methods GIT_DISPATCH_WORKFLOW
    importing
      !IV_GIT_SET type ZGIT_SETTINGS
    exporting
      !EV_OK type BOOLEAN .
  class-methods GIT_GET_LAST_WORKFLOW_RUN
    importing
      !IV_REPO type CHAR60
    exporting
      !ES_GIT_DATA type ZGIT_DATA .
  class-methods GIT_GET_USER
    exporting
      !EV_USER type SMOG_RELBY .
  class-methods GIT_GET_WORKFLOW_RUN
    importing
      !IV_REPO type CHAR60
      !IV_RUN_ID type ZDTEL00000S
    exporting
      !ES_GIT_DATA type ZGIT_DATA .
  class-methods SET_WORKFLOW_RUNS_DATA
    importing
      !IV_GIT_DATA type ZGIT_DATA .
  class-methods POST
    importing
      !IV_BODY type STRING
      !IV_URI type STRING
    exporting
      !EV_HTTP_RESPONSE type STRING
      !EV_HTTP_RESPONSE_STATUS_CODE type STRING .
  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GIT_HELPER IMPLEMENTATION.


  method cancel_workflow_run.

    data: lv_time         type /bcv/sin_st_exctime_max,
          lv_current_time type timestamp.

    ev_ok = 0.

    select single time from zgit_set where repo = @iv_git_data-repo_s into @lv_time.
    if lv_time is initial.
      select single time from zgit into @lv_time.
    endif.

    if lv_time is not initial
      .
      get time stamp field lv_current_time.

      select single stop_at from zgit_status
        where repo = @iv_git_data-repo
        and workfolw_id = @iv_git_data-workflow_id
        and run_id = @iv_git_data-run_id
        into @data(lv_stop_at).

      try.
          call method cl_abap_tstmp=>compare
            exporting
              tstmp1 = lv_current_time
              tstmp2 = lv_stop_at
            receiving
              comp   = data(lv_diff).
        catch cx_parameter_invalid_range .
          return.
        catch cx_parameter_invalid_type .
          return.
      endtry.
      if lv_diff = 1.
        call method zcl_git_helper=>git_cancel_workflow_run
          exporting
            iv_run_id = iv_git_data-run_id
            iv_repo   = iv_git_data-repo
          importing
            ev_ok     = ev_ok.
      endif.
    endif.
  endmethod.


  method CONSTRUCTOR.
  endmethod.


  method convert_git_date_time.
    data: lv_run  type zgit_status,
          lv_date type string.
    lv_date = iv_started_at.
    replace all occurrences of substring ':' in lv_date with ''.
    replace all occurrences of substring '-' in lv_date with ''.
    "T: Separates the date (2020-01-22) from the time (19:33:08).
    replace all occurrences of substring 'T' in lv_date with ''.
    "Z: Indicates that the time is in Coordinated Universal Time (UTC) (also referred to as "Zulu time").
    replace all occurrences of substring 'Z' in lv_date with ''.
    EV_DATE_TIME = lv_date.

  endmethod.


  method get.

*    data: lo_http_client     type ref to if_http_client,
*          lo_rest_client     type ref to cl_rest_http_client,
*          lv_url             type        string,
*          http_status        type        string,
*          lv_token              type        string,
*          agreements         type        string,
*          lo_response        type ref to if_rest_entity,
*          lv_header_guid     type crmt_object_guid,
*          lv_object_type_ref type swo_objtyp,
*          iv_transactionid   type string,
*          lv_message         type i.

    data: lo_http_client   type ref to if_http_client,
          lv_url           type string,
          lv_api           type string,
          lv_response_body type string,
          lv_token         type string.

* Create HTTP intance using RFC restination created

    select single * from zgit into @data(lv_git).
    concatenate 'Bearer ' lv_git-token into lv_token separated by space.
    concatenate lv_git-url iv_uri into lv_url .
    lv_api = lv_git-api.

    " Create HTTP client for the specified URL
    call method cl_http_client=>create_by_url
      exporting
        url    = lv_url
      importing
        client = lo_http_client.

    " Set HTTP method to GET
    lo_http_client->request->set_method( if_http_request=>co_request_method_get ).

    " Set headers
    lo_http_client->request->set_header_field( name = 'Accept' value = 'application/vnd.github+json' ).
    lo_http_client->request->set_header_field( name = 'Authorization' value = lv_token ).
    lo_http_client->request->set_header_field( name = 'X-GitHub-Api-Version' value = lv_api ).

    " Define the body for the POST request
    "lv_body = '{"ref": "main", "inputs": {"test-plan-key": "XD-2539", "mtb-file-path": "MTB Files/Test Plans/Test_Plan_XD-2539.mtb", "artifact-name": "uftone-tests-report", "environment": "pre", "runner": "cctests-windows-04", "jira-url": ""}}'.

    " Set the body content
    lo_http_client->request->set_cdata( iv_body ).

    " Execute HTTP request
    call method lo_http_client->send
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2.

    " Receive the response
    call method lo_http_client->receive
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2.

    " Read response body
    lv_response_body = lo_http_client->response->get_cdata( ).

    " Handle response (you can parse JSON here if needed)
    ev_http_response = lv_response_body.

    " Free resources
    lo_http_client->close( ).
** Create REST client instance
*    create object lo_rest_client
*      exporting
*        io_http_client = lo_http_client.
*
** Set HTTP version
*    lo_http_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).
*    if lo_http_client is bound and lo_rest_client is bound.
*
** Set the URI if any
*      cl_http_utility=>set_request_uri(
*        exporting
*          request = lo_http_client->request    " HTTP Framework (iHTTP) HTTP Request
*          uri     = iv_uri                     " URI String (in the Form of /path?query-string)
*      ).
*
** HTTP GET
*      lo_rest_client->if_rest_client~get( ).
*
** HTTP_POST
*
*      data: lo_json        type ref to cl_clb_parse_json,
*            lo_request     type ref to if_rest_entity,
*            lo_sql         type ref to cx_sy_open_sql_db,
*            status         type  string,
*            reason         type  string,
*            response       type  string,
*            content_length type  string,
*            location       type  string,
*            content_type   type  string,
*            lv_status      type  i.
*
** Set Payload or body ( JSON or XML)
*      lo_request = lo_rest_client->if_rest_client~create_request_entity( ).
*      lo_request->set_content_type( iv_media_type = if_rest_media_type=>gc_appl_json ).
*      lo_request->set_string_data( iv_body ).
*
** Set request header if any
*      call method lo_rest_client->if_rest_client~set_request_header
*        exporting
*          iv_name  = 'X-GitHub-Api-Version'
*          iv_value = '2022-11-28'. "Set your header .
*
*      call method lo_rest_client->if_rest_client~set_request_header
*        exporting
*          iv_name  = 'Accept'
*          iv_value = 'application/vnd.github+json'. "Set your header .
*
*      call method lo_rest_client->if_rest_client~set_request_header
*        exporting
*          iv_name  = 'Authorization'
*          iv_value = token. "Set your header .
** Put
*      lo_rest_client->if_rest_resource~post( lo_request ).
** Collect response
*
** HTTP response
*      lo_response = lo_rest_client->if_rest_client~get_response_entity( ).
** HTTP return status
*      http_status = lv_status = lo_response->get_header_field( '~status_code' ).
*      reason = lo_response->get_header_field( '~status_reason' ).
*      content_length = lo_response->get_header_field( 'content-length' ).
*      location = lo_response->get_header_field( 'location' ).
*      content_type = lo_response->get_header_field( 'content-type' ).
** RAW response
*      response = lo_response->get_string_data( ).
** JSON to ABAP
*      data lr_json_deserializer type ref to cl_trex_json_deserializer.
*      types: begin of ty_json_res,
*               error   type string,
*               details type string,
*             end of ty_json_res.
*      data: json_res type ty_json_res.
*
*      ev_http_response_status_code = http_status.
*      ev_http_response = response.
*
*    endif.
  endmethod.


  method get_all_cd_to_proc.
    "guid = 005056B75C641EE88C9BC660D352781F
    select distinct h~guid
      from crmd_customer_h as h
      left join crm_jest as s on s~objnr = h~guid and s~inact ='' and s~stat = 'E0025'
      left join tsocm_cr_context as cont on h~guid = cont~created_guid
      left join slan_header as ccl on ccl~slan_id = cont~slan_id
      left join zgit_set as set on ccl~slan_name = set~ccl and h~zzgit_repo = set~testset_id
      where h~zzbypassgit = '' and h~zzgit_repo <> ''
      and set~repo is not null
      and set~testset_key is not null
      and set~testplan is not null
      into table @et_crm_guid.
  endmethod.


  method get_cycle_cd.
    "guid = 005056B75C641EE88C9BC660D352781F
        select distinct h~guid
      from aic_release_cycl as c
      left join tsocm_cr_context as cd on c~smi_project = cd~project_id and process_type = 'YMMJ'
      left join crm_jest as s on s~OBJNR = cd~created_guid and s~INACT ='' and s~stat = 'E0025'
      left join crmd_customer_h as h on h~guid = s~OBJNR and h~zzgit_repo <> '' and h~zzbypassgit = ''
      where c~release_crm_guid = @iv_crm_guid and h~guid is not null
      into table @et_crm_guid.
  endmethod.


  method get_git_settings.
    select single set~* from tsocm_cr_context as cont
      left join slan_header as ccl on ccl~slan_id = cont~slan_id
      left join zgit_set as set  on ccl~slan_name = set~ccl
      where cont~created_guid = @iv_crm_guid
      into @data(lv_git_settings).
    move-corresponding lv_git_settings to es_git_settings.
  endmethod.


  method get_in_proc_repo.
*    select distinct h~zzgit_repo as repo,
*        h~zzgit_status as status,
*        h~zzgit_workflow as workflow_id,
*        h~zzgit_run_id as run_id
*      from crmd_customer_h as h
*      where ( h~zzgit_status = 'in_progress' or h~zzgit_status = 'queued' )
*      and  zzbypassgit = ''
*      and zzgit_repo <> ''
*      into table @data(et_repos).

    select distinct set~repo,
          h~zzgit_status as status,
          h~zzgit_workflow as workflow_id,
          h~zzgit_run_id as run_id
    from crmd_customer_h as h
    left join crm_jest as s on s~objnr = h~guid and s~inact ='' and s~stat = 'E0025'
    left join tsocm_cr_context as cont on h~guid = cont~created_guid
    left join slan_header as ccl on ccl~slan_id = cont~slan_id
    left join zgit_set as set on ccl~slan_name = set~ccl and h~zzgit_repo = set~testset_id
    where ( h~zzgit_status = 'in_progress' or h~zzgit_status = 'queued' )
    and h~zzbypassgit = '' and h~zzgit_repo <> ''
    and set~repo is not null
    and set~testset_key is not null
    and set~testplan is not null
    into table @data(et_repos).

    loop at et_repos into data(lv_repos).
      data lv_repo_line type zgit_repo_stop.
      move-corresponding lv_repos to lv_repo_line.
      select single
        s~start_at as start_at,
        s~stop_at from
        zgit_status as s
      where s~workfolw_id = @lv_repo_line-workflow_id
      and s~run_id = @lv_repo_line-run_id
      into (@lv_repo_line-start_at, @lv_repo_line-stop_at).
      append lv_repo_line to et_reports.
    endloop.

  endmethod.


  method get_next_run_time.
    data: lv_current_time type timestamp.
    get time stamp field lv_current_time.
    loop at it_reports into data(lv_report).
      try.
          call method cl_abap_tstmp=>compare
            exporting
              tstmp1 = lv_current_time
              tstmp2 = lv_report-stop_at
            receiving
              comp   = data(lv_diff).
        catch cx_parameter_invalid_range .
          return.
        catch cx_parameter_invalid_type .
          return.
      endtry.
      if lv_diff = -1. "stop is in future
        if ev_start_at is initial.
          ev_start_at = lv_report-stop_at.
        else.
          try.
              call method cl_abap_tstmp=>compare
                exporting
                  tstmp1 = ev_start_at
                  tstmp2 = lv_report-stop_at
                receiving
                  comp   = lv_diff.
            catch cx_parameter_invalid_range .
              return.
            catch cx_parameter_invalid_type .
              return.
          endtry.
          if lv_diff = 1.
            ev_start_at = lv_report-stop_at.
          endif.
        endif.
      endif.
    endloop.
  endmethod.


  method get_repo_name_long.
    "not used any more
*
*    " get long txt from domain
*    " Name of the domain
*    data(lv_domain) = 'ZDTEL00000G'.
*    " logon laguage
*    data(lv_lang) = cl_abap_syst=>get_logon_language( ).
*
*    select single t~ddtext
*      into @data(lv_dom_repo)
*      from dd07l as l
*      inner join dd07t as t on l~domname = t~domname and
*                               l~valpos = t~valpos and
*                               l~domvalue_l = t~domvalue_l
*      where l~domname    = @lv_domain
*        and t~ddlanguage = @lv_lang
*      and l~domvalue_l = @iv_repo_s.
*
*    ev_repo = lv_dom_repo.
  endmethod.


  method git_cancel_workflow_run.
    "https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#cancel-a-workflow-run
    data:
      lv_body        type string,
      lv_uri         type string,
      lv_response    type string,
      lv_http_status type string.

    ev_ok = 0.
    if iv_repo is not initial and iv_run_id is not initial.

      concatenate '/repos/GitHub-EDP/' iv_repo '/actions/runs/' iv_run_id '/cancel' into lv_uri.

      call method zcl_git_helper=>post
        exporting
          iv_body                      = lv_body
          iv_uri                       = lv_uri
        importing
          ev_http_response             = lv_response
          ev_http_response_status_code = lv_http_status.

      ev_ok = 1.
    endif.

  endmethod.


  method git_dispatch_workflow.
    "https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event
    data:
      lv_body        type string,
      lv_uri         type string,
      lv_response    type string,
      lv_http_status type string,
      lv_key         type string,
      lv_plan        type string,
      lv_repo        type string.

    if iv_git_set is initial.
      lv_repo = 'cctests-shared-blueprint-uftone'.
      lv_key  = 'TEST_SET_XD-10116'.
      lv_plan = 'XD-2539'.
    else.
      lv_repo = iv_git_set-repo.
      lv_key  = iv_git_set-testset_key.
      lv_plan = iv_git_set-testplan.
    endif.
    ev_ok = 0.
    if lv_repo is not initial.

      concatenate '/repos/GitHub-EDP/' lv_repo '/dispatches' into lv_uri.

      concatenate '{"event_type": "webhook",'
      '"client_payload": {"testkeyUFT": "' lv_key '",'
      '"testplan": "' lv_plan '"'
      '}}' into lv_body.

      call method zcl_git_helper=>post
        exporting
          iv_body                      = lv_body
          iv_uri                       = lv_uri
        importing
          ev_http_response             = lv_response
          ev_http_response_status_code = lv_http_status.
      if lv_response is initial.
        ev_ok = 1.
      else.
        ev_ok = 0.
      endif.
    endif.
  endmethod.


  method git_get_last_workflow_run.
    "https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-a-workflow-run

    data:
      lv_body        type string,
      lv_uri         type string,
      lv_response    type string,
      lv_http_status type string,
      lv_repo        type string.

    if iv_repo is initial.
      lv_repo = 'cctests-shared-blueprint-uftone'. "test
    else.
      lv_repo = iv_repo.
    endif.

    if lv_repo is not initial.
      es_git_data-repo = lv_repo.

      concatenate '/repos/GitHub-EDP/' lv_repo '/actions/runs' into lv_uri.

      call method zcl_git_helper=>get
        exporting
          iv_body                      = lv_body
          iv_uri                       = lv_uri
        importing
          ev_http_response             = lv_response
          ev_http_response_status_code = lv_http_status.

      "prase json

      data lr_data type ref to data.

      call method /ui2/cl_json=>deserialize
        exporting
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        changing
          data         = lr_data.

      field-symbols:
        <data>          type data,
        <results>       type any,
        <structure>     type any,
        <result_struct> type any,
        <result_field>  type any,

        <table>         type any table,
        <field>         type any,
        <field_value>   type data,
        <field_2>       type any.

      field-symbols:
        <lv_field> type any,
        <ld_data>  type ref to data,
        <ls_row>   type any.


      assign lr_data->* to <structure>.
      assign component 'workflow_runs' of structure <structure> to <result_field>.
      if <result_field> is assigned.
        assign <result_field>->* to <table>.
        loop at <table> assigning <result_struct>.
          assign <result_struct>->* to <data>.

          assign component 'conclusion' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              es_git_data-conclusion = <field_value>.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'ID' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              es_git_data-run_id = <field_value>.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'workflow_id' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              es_git_data-workflow_id = <field_value>.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'status' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              es_git_data-status = <field_value>.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'run_started_at' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              call method zcl_git_helper=>convert_git_date_time
                exporting
                  iv_started_at = <field_value>
                importing
                  ev_date_time  = es_git_data-started_at.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'event' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_value>.
              es_git_data-event = <field_value>.
            endif.
          endif.
          unassign: <field>, <field_value>.

          assign component 'TRIGGERING_ACTOR' of structure <data> to <field>.
          if <field> is assigned.
            lr_data = <field>.
            if lr_data is not initial.
              assign lr_data->* to <field_2>.
              assign component 'LOGIN' of structure <field_2> to <field>.
              if <field> is assigned.
                lr_data = <field>.
                if lr_data is not initial.
                  assign lr_data->* to <field_value>.
                  es_git_data-git_user = <field_value>.
                endif.
              endif.
            endif.
          endif.
          unassign: <field>, <field_value>, <field_2>.

*          assign component 'updated_at' of structure <data> to <field>.
*          if <field> is assigned.
*            lr_data = <field>.
*            if lr_data is not initial.
*              assign lr_data->* to <field_value>.
*              ev_updated_at = <field_value>.
*            endif.
*          endif.
*          unassign: <field>, <field_value>.
          exit. "take only last run.
        endloop.
      endif.
    endif.

  endmethod.


  method git_get_user.
    "https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-a-workflow-run

    data:
      lv_body        type string,
      lv_uri         type string,
      lv_response    type string,
      lv_http_status type string,
      lv_repo        type string,
      lv_run_id      type string.


    lv_uri = '/user'.

    call method zcl_git_helper=>get
      exporting
        iv_body                      = lv_body
        iv_uri                       = lv_uri
      importing
        ev_http_response             = lv_response
        ev_http_response_status_code = lv_http_status.

    "prase json

    data lr_data type ref to data.

    call method /ui2/cl_json=>deserialize
      exporting
        json         = lv_response
        pretty_name  = /ui2/cl_json=>pretty_mode-user
        assoc_arrays = abap_true
      changing
        data         = lr_data.

    field-symbols:
      <data>          type data,
      <results>       type any,
      <structure>     type any,
      <result_struct> type any,
      <result_field>  type any,

      <table>         type any table,
      <field>         type any,
      <field_value>   type data.

    field-symbols:
      <lv_field> type any,
      <ld_data>  type ref to data,
      <ls_row>   type any.


    assign lr_data->* to <data>.
    if <data> is assigned.

      assign component 'login' of structure <data> to <field>.
      if <field> is assigned.
        lr_data = <field>.
        if lr_data is not initial.
          assign lr_data->* to <field_value>.
          ev_user = <field_value>.
        endif.
      endif.
      unassign: <field>, <field_value>.
    endif.

  endmethod.


  method git_get_workflow_run.
    "https://docs.github.com/en/rest/actions/workflow-runs?apiVersion=2022-11-28#get-a-workflow-run

    data:
      lv_body        type string,
      lv_uri         type string,
      lv_response    type string,
      lv_http_status type string,
      lv_repo        type string,
      lv_run_id      type string.

*    if iv_repo is initial.
*      lv_repo = 'cctests-shared-blueprint-uftone'.
*      lv_run_id = '000012832176618'.
*    else.
    lv_repo = iv_repo.
    lv_run_id = iv_run_id.
*    endif.

    if lv_repo is not initial.
      es_git_data-repo = lv_repo.

      concatenate '/repos/GitHub-EDP/' lv_repo '/actions/runs/' lv_run_id into lv_uri.
      "/repos/{owner}/{repo}/actions/runs/{run_id}

      call method zcl_git_helper=>get
        exporting
          iv_body                      = lv_body
          iv_uri                       = lv_uri
        importing
          ev_http_response             = lv_response
          ev_http_response_status_code = lv_http_status.

      "prase json

      data lr_data type ref to data.

      call method /ui2/cl_json=>deserialize
        exporting
          json         = lv_response
          pretty_name  = /ui2/cl_json=>pretty_mode-user
          assoc_arrays = abap_true
        changing
          data         = lr_data.

      field-symbols:
        <data>          type data,
        <results>       type any,
        <structure>     type any,
        <result_struct> type any,
        <result_field>  type any,

        <table>         type any table,
        <field>         type any,
        <field_2>       type any,
        <field_value>   type data.

      field-symbols:
        <lv_field> type any,
        <ld_data>  type ref to data,
        <ls_row>   type any.


      assign lr_data->* to <data>.
      if <data> is assigned.

        assign component 'conclusion' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            es_git_data-conclusion = <field_value>.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'ID' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            es_git_data-run_id = <field_value>.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'workflow_id' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            es_git_data-workflow_id = <field_value>.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'status' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            es_git_data-status = <field_value>.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'run_started_at' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            call method zcl_git_helper=>convert_git_date_time
              exporting
                iv_started_at = <field_value>
              importing
                ev_date_time  = es_git_data-started_at.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'event' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_value>.
            es_git_data-event = <field_value>.
          endif.
        endif.
        unassign: <field>, <field_value>.

        assign component 'TRIGGERING_ACTOR' of structure <data> to <field>.
        if <field> is assigned.
          lr_data = <field>.
          if lr_data is not initial.
            assign lr_data->* to <field_2>.
            assign component 'LOGIN' of structure <field_2> to <field>.
            if <field> is assigned.
              lr_data = <field>.
              if lr_data is not initial.
                assign lr_data->* to <field_value>.
                es_git_data-git_user = <field_value>.
              endif.
            endif.
          endif.
        endif.
        unassign: <field>, <field_value>, <field_2>.

*          assign component 'updated_at' of structure <data> to <field>.
*          if <field> is assigned.
*            lr_data = <field>.
*            if lr_data is not initial.
*              assign lr_data->* to <field_value>.
*              ev_updated_at = <field_value>.
*            endif.
*          endif.
*          unassign: <field>, <field_value>.
        exit. "take only last run.
      endif.
    endif.

  endmethod.


  method is_git_enabled.
    include: crm_mode_con. "Include with standard CRM constants
    data: lo_cd         type ref to cl_ags_crm_1o_api,
          lv_customer_h type crmt_customer_h_wrk.

    cl_ags_crm_1o_api=>get_instance(
      exporting
      iv_header_guid = iv_crm_guid
      iv_process_mode = gc_mode-display
      importing
      eo_instance = lo_cd
      ).

    call method lo_cd->get_customer_h
      importing
        es_customer_h        = lv_customer_h
*       et_customer_h        =
      exceptions
        document_not_found   = 1
        error_occurred       = 2
        document_locked      = 3
        no_change_authority  = 4
        no_display_authority = 5
        no_change_allowed    = 6
        others               = 7.

    if sy-subrc <> 0.
* Implement suitable error handling here
      return.
    endif.

    if lv_customer_h-zzgit_repo is not initial and lv_customer_h-zzbypassgit = ''.
      rv_is_git = 1.
    else.
      rv_is_git = 0.
    endif.
  endmethod.


  method post.

*    data: lo_http_client     type ref to if_http_client,
*          lo_rest_client     type ref to cl_rest_http_client,
*          lv_url             type        string,
*          http_status        type        string,
*          lv_token              type        string,
*          agreements         type        string,
*          lo_response        type ref to if_rest_entity,
*          lv_header_guid     type crmt_object_guid,
*          lv_object_type_ref type swo_objtyp,
*          iv_transactionid   type string,
*          lv_message         type i.

    data: lo_http_client   type ref to if_http_client,
          lv_url           type string,
          lv_api           type string,
          lv_response_body type string,
          lv_token         type string.

* Create HTTP intance using RFC restination created

    select single * from zgit into @data(lv_git).
    concatenate 'Bearer ' lv_git-token into lv_token separated by space.
    concatenate lv_git-url iv_uri into lv_url .
    lv_api = lv_git-api.

    " Create HTTP client for the specified URL
    call method cl_http_client=>create_by_url
      exporting
        url    = lv_url
      importing
        client = lo_http_client.

    " Set HTTP method to POST
    lo_http_client->request->set_method( if_http_request=>co_request_method_post ).

    " Set headers
    lo_http_client->request->set_header_field( name = 'Accept' value = 'application/vnd.github+json' ).
    lo_http_client->request->set_header_field( name = 'Authorization' value = lv_token ).
    lo_http_client->request->set_header_field( name = 'X-GitHub-Api-Version' value = lv_api  ).

    " Define the body for the POST request
    "lv_body = '{"ref": "main", "inputs": {"test-plan-key": "XD-2539", "mtb-file-path": "MTB Files/Test Plans/Test_Plan_XD-2539.mtb", "artifact-name": "uftone-tests-report", "environment": "pre", "runner": "cctests-windows-04", "jira-url": ""}}'.

    " Set the body content
    lo_http_client->request->set_cdata( iv_body ).

    " Execute HTTP request
    call method lo_http_client->send
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2.

    " Receive the response
    call method lo_http_client->receive
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2.

    " Read response body
    lv_response_body = lo_http_client->response->get_cdata( ).

    " Handle response (you can parse JSON here if needed)
    ev_http_response = lv_response_body.

    " Free resources
    lo_http_client->close( ).
  endmethod.


  method run_job_to_git.
    data:
      lv_task_guid  type sysuuid_x16,
      ls_selopt     type rsparams,
      lt_selopt     type rsparams_tt,
      lv_job_exists type boolean,
      ls_balmi      type balmi,
      lv_dummystr   type string,
      lv_job_id     type btcjobcnt,
      lt_cd         type crmt_object_guid_tab.

    field-symbols:
         <fs_task>       type ref to cl_td_task.

    constants co_job_task_name type char32 value 'ZGIT_RUN_TEST'.

    select single process_type from crmd_orderadm_h where guid = @iv_order_guid into @data(lv_type).
    if lv_type = 'SMIM' or lv_type = 'SMRE' or lv_type = 'SMRE'.
      "process all CD`s for cycle
      call method zcl_git_helper=>get_cycle_cd
        exporting
          iv_crm_guid = iv_order_guid
        importing
          et_crm_guid = lt_cd.
      loop at lt_cd into data(lv_guid).
        clear ls_selopt.
        ls_selopt-selname = 'P_T_ID'.
        ls_selopt-kind    = 'P'.
        ls_selopt-sign    = 'I'.
        ls_selopt-option  = 'EQ'.
        ls_selopt-low     = lv_guid.
        insert ls_selopt into table lt_selopt.
      endloop.
    else.
      "process single CD
      "parameters
      clear ls_selopt.
      ls_selopt-selname = 'P_T_ID'.
      ls_selopt-kind    = 'P'.
      ls_selopt-sign    = 'I'.
      ls_selopt-option  = 'EQ'.
      ls_selopt-low     = iv_order_guid.
      insert ls_selopt into table lt_selopt.
    endif.

    if lt_selopt is not initial.

* check if there is a job currently running
      rv_success = abap_true.
      data(lt_task) = cl_td_task_manager=>get_all_open_tasks(
        iv_task_name = co_job_task_name ).
      if lt_task is not initial.
        do 5 times.
          loop at lt_task assigning <fs_task>.
            if <fs_task>->get_status( ) = cl_td_task_manager=>con_task_status_in_progress. "'P'. " in progress
              lv_job_exists = abap_true.
              wait up to 5 seconds.
              continue.
            else.
              lv_job_exists = abap_false.
            endif.
          endloop.
        enddo.
      endif.

      if lv_job_exists = abap_true.
        rv_success = abap_false.
        return.
        " add log message and exit ?
      endif.

      try.
          lv_task_guid = cl_system_uuid=>create_uuid_x16_static( ).
        catch cx_uuid_error.
          " Message: Internal error
          message e298(ags_td) into lv_dummystr.
          ls_balmi = cl_td_assistant=>prepare_app_log( ).
          "append ls_balmi to ip_application_log.
          rv_success = abap_false.
          return.
      endtry.

* Create a new job with JOB_OPEN

      call function 'JOB_OPEN'
        exporting
          jobname          = co_job_task_name
        importing
          jobcount         = lv_job_id
        exceptions
          cant_create_job  = 1
          invalid_job_data = 2
          jobname_missing  = 3
          others           = 4.
      if sy-subrc <> 0.
        rv_success = abap_false.
      endif.

*------------------------------------------------------------------------------
* Connect one report to the job by SUBMIT
      submit (co_job_task_name) and return
                    with p_taskid = lv_task_guid
                    with selection-table lt_selopt
                    user sy-uname
                    via job co_job_task_name
                    number lv_job_id.
      if sy-subrc <> 0.
        rv_success = abap_false.
      endif.

*------------------------------------------------------------------------------
* Close the job definition with JOB_CLOSE to release the job

      " Convert the date and time from "000..." to space, so that JOB_CLOSE
      " doesn't recognize them as specified
*****  IF ls_batch-sdlstrtdt IS INITIAL.
*****    ls_batch-sdlstrtdt = lc_space_dats.
*****    ls_batch-sdlstrttm = lc_space_tims.
*****  ENDIF.
*****  IF ls_batch-laststrtdt IS INITIAL.
*****    ls_batch-laststrtdt = lc_space_dats.
*****    ls_batch-laststrttm = lc_space_tims.
*****  ENDIF.
      " Note that if you go to the JOB_CLOSE function module, you can find the
      " detailed parameter documentation there
      call function 'JOB_CLOSE'
        exporting
          jobcount             = lv_job_id
          jobname              = co_job_task_name
          strtimmed            = abap_true
*         sdlstrtdt            = ls_batch-sdlstrtdt
*         sdlstrttm            = ls_batch-sdlstrttm
*         prddays              = ls_batch-prddays
*         prdhours             = ls_batch-prdhours
*         prdmins              = ls_batch-prdmins
*         prdmonths            = ls_batch-prdmonths
*         prdweeks             = ls_batch-prdweeks
*         laststrtdt           = ls_batch-laststrtdt
*         laststrttm           = ls_batch-laststrttm
        exceptions
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          others               = 8.
      if sy-subrc <> 0.
        rv_success = abap_false.
      endif.
    endif.
  endmethod.


  method run_job_update_git.
    data:
      lv_task_guid  type sysuuid_x16,
      ls_selopt     type rsparams,
      lt_selopt     type rsparams_tt,
      lv_job_exists type boolean,
      ls_balmi      type balmi,
      lv_dummystr   type string,
      lv_job_id     type btcjobcnt,
      lt_cd         type crmt_object_guid_tab.

    field-symbols:
         <fs_task>       type ref to cl_td_task.

    constants co_job_task_name type char32 value 'ZGIT_TEST_UPDATE'.

    "first check if job is already scheduled?
    select single jobname from tbtco where jobname = @co_job_task_name and status = 'S'
      into @data(lv_job_s).
    "schedule only one time
    if lv_job_s = ''.
      if iv_start_at is not initial.
        data:
          lv_date type btcsdate,
          lv_time type btcstime.

        convert time stamp iv_start_at time zone sy-zonlo
        into date lv_date time lv_time.

* check if there is a job currently running
        rv_success = abap_true.
        data(lt_task) = cl_td_task_manager=>get_all_open_tasks(
          iv_task_name = co_job_task_name ).
        if lt_task is not initial.
          do 5 times.
            loop at lt_task assigning <fs_task>.
              if <fs_task>->get_status( ) = cl_td_task_manager=>con_task_status_in_progress. "'P'. " in progress
                lv_job_exists = abap_true.
                wait up to 5 seconds.
                continue.
              else.
                lv_job_exists = abap_false.
              endif.
            endloop.
          enddo.
        endif.

        if lv_job_exists = abap_true.
          rv_success = abap_false.
          return.
          " add log message and exit ?
        endif.

        try.
            lv_task_guid = cl_system_uuid=>create_uuid_x16_static( ).
          catch cx_uuid_error.
            " Message: Internal error
            message e298(ags_td) into lv_dummystr.
            ls_balmi = cl_td_assistant=>prepare_app_log( ).
            "append ls_balmi to ip_application_log.
            rv_success = abap_false.
            return.
        endtry.

* Create a new job with JOB_OPEN

        call function 'JOB_OPEN'
          exporting
            jobname          = co_job_task_name
          importing
            jobcount         = lv_job_id
          exceptions
            cant_create_job  = 1
            invalid_job_data = 2
            jobname_missing  = 3
            others           = 4.
        if sy-subrc <> 0.
          rv_success = abap_false.
        endif.

*------------------------------------------------------------------------------
* Connect one report to the job by SUBMIT
        submit (co_job_task_name) and return
                      with p_taskid = lv_task_guid
                      with selection-table lt_selopt
                      user sy-uname
                      via job co_job_task_name
                      number lv_job_id.
        if sy-subrc <> 0.
          rv_success = abap_false.
        endif.

*------------------------------------------------------------------------------
* Close the job definition with JOB_CLOSE to release the job
        " Note that if you go to the JOB_CLOSE function module, you can find the
        " detailed parameter documentation there
        call function 'JOB_CLOSE'
          exporting
            jobcount             = lv_job_id
            jobname              = co_job_task_name
            strtimmed            = abap_true
            sdlstrtdt            = lv_date
            sdlstrttm            = lv_time
          exceptions
            cant_start_immediate = 1
            invalid_startdate    = 2
            jobname_missing      = 3
            job_close_failed     = 4
            job_nosteps          = 5
            job_notex            = 6
            lock_failed          = 7
            others               = 8.
        if sy-subrc <> 0.
          rv_success = abap_false.
        endif.
      endif.
    endif.
  endmethod.


  method schedule_follow_up_job.

    data: lv_start type timestamp.
    call method zcl_git_helper=>get_in_proc_repo
      importing
        et_reports = data(lt_repos_to_check).

    if lt_repos_to_check is not initial.
      call method zcl_git_helper=>get_next_run_time
        exporting
          it_reports  = lt_repos_to_check
        importing
          ev_start_at = lv_start.
    endif.

    if lv_start is not initial.
      call method zcl_git_helper=>run_job_update_git
        exporting
          iv_start_at = lv_start
        receiving
          rv_success  = data(lv_job_ok).
      if lv_job_ok = abap_true.
        ev_ok = 1.
      else.
        ev_ok = 0.
      endif.
      else.
        ev_ok = 0.
    endif.

  endmethod.


  method set_docs_status.

    select guid from crm_jest as s
      left join crmd_customer_h as h on s~objnr = h~guid
    where inact = '' and stat = 'E0025' "To Be Regression Tested
      and zzgit_status = 'success'
    into table @data(lt_guid).

    loop at lt_guid into data(lv_guid).

      call method zcl_git_helper=>set_status_by_ppf
        exporting
          iv_object_guid = lv_guid-guid
          iv_estatus     = 'E0026'
        receiving
          rv_exec_status = data(lv_stat_ok).

    endloop.
  endmethod.


  method set_git_data_cd.
    include: crm_mode_con. "Include with standard CRM constants
    data:
      lo_cd         type ref to cl_ags_crm_1o_api,
      lv_log_handle type balloghndl.

    ev_ok = 0.

    cl_ags_crm_1o_api=>get_instance(
      exporting
      iv_header_guid = iv_git_data-guid
      iv_process_mode = gc_mode-change
      importing
      eo_instance = lo_cd
      ).

    call method lo_cd->get_customer_h
      importing
        es_customer_h        = data(lv_customer_h)
      exceptions
        document_not_found   = 1
        error_occurred       = 2
        document_locked      = 3
        no_change_authority  = 4
        no_display_authority = 5
        no_change_allowed    = 6
        others               = 7.
    if sy-subrc <> 0.
      ev_ok = 0.
      return.
    endif.
    if lv_customer_h-zzgit_repo <> '' and lv_customer_h-zzgit_repo = iv_git_data-repo_s.
      data: lv_customer_h_n type crmt_customer_h_com.
      move-corresponding lv_customer_h to lv_customer_h_n.
      lv_customer_h_n-zzgit_run_id = iv_git_data-run_id.
      lv_customer_h_n-zzgit_workflow = iv_git_data-workflow_id.
      if iv_git_data-conclusion is initial.
        lv_customer_h_n-zzgit_status = iv_git_data-status.
      else.
        lv_customer_h_n-zzgit_status = iv_git_data-conclusion.
      endif.

      call method lo_cd->set_customer_h
        exporting
          is_customer_h     = lv_customer_h_n
        exceptions
          error_occurred    = 1
          document_locked   = 2
          no_change_allowed = 3
          no_authority      = 4
          others            = 5.
      if sy-subrc <> 0.
        ev_ok = 0.
        return.
      endif.

      call method lo_cd->save
        exporting
          iv_unlock      = 'X'
        changing
          cv_log_handle  = lv_log_handle
        exceptions
          error_occurred = 1
          others         = 2.
      if sy-subrc <> 0.
* Implement suitable error handling here
        ev_ok = 0.
        return.
      else.
        ev_ok = 1.
      endif.
    endif.
  endmethod.


  method set_git_data_cd_db.
    include: crm_mode_con. "Include with standard CRM constants
    data:
      lo_cd         type ref to cl_ags_crm_1o_api,
      lv_log_handle type balloghndl.

    select single * from crmd_customer_h where guid = @iv_git_data-guid into @data(lv_customer_h).

    if lv_customer_h-zzbypassgit = ''.
      lv_customer_h-zzgit_run_id = iv_git_data-run_id.
      lv_customer_h-zzgit_workflow = iv_git_data-workflow_id.
      if iv_git_data-conclusion is initial.
        lv_customer_h-zzgit_status = iv_git_data-status.
      else.
        lv_customer_h-zzgit_status = iv_git_data-conclusion.
      endif.

      update crmd_customer_h from lv_customer_h.
    endif.

  endmethod.


  method set_status_by_ppf.
    include: crm_mode_con. "Include with standard CRM constants

    data: it_status          type crmt_status_comt,
          is_status          type crmt_status_com,
          ev_log_handle_itsm type balloghndl.

    data:
      lo_cd         type ref to cl_ags_crm_1o_api,
      lv_log_handle type balloghndl.

    "is_status-ref_guid = io_cd->av_header_guid.

    data: lv_context         type ref to cl_doc_context_crm_order,
          lo_appl_object     type ref to object,
          li_container       type ref to if_swj_ppf_container,
          lo_partner         type ref to cl_partner_ppf,
          l_protocol_handle  type balloghndl,
          rp_status          type ppfdtstat,
          lc_container       type ref to if_swj_ppf_container,
          lc_exit            type ref to if_ex_exec_methodcall_ppf,
          lt_objects_to_save type crmt_object_guid_tab,
          ls_objects_to_save like line of lt_objects_to_save.

    call function 'CRM_ACTION_CONTEXT_CREATE'
      exporting
        iv_header_guid                 = iv_object_guid
        iv_object_guid                 = iv_object_guid
      importing
        ev_context                     = lv_context
      exceptions
        no_actionprofile_for_proc_type = 1
        no_actionprofile_for_item_type = 2
        order_read_failed              = 3
        others                         = 4.
    if sy-subrc <> 0.
      rv_exec_status = 0.
      exit.
    endif.

    lo_appl_object = lv_context->appl.

* get exit instance
    lc_exit ?= cl_exithandler_manager_ppf=>get_exit_handler(
    ip_badi_definition_name = 'EXEC_METHODCALL_PPF' ).

* call HF_SET_STATUS - Status modification
    create object lc_container
      type
      cl_swj_ppf_container.
    lc_container->set_value( element_name = 'USER_STATUS'
    data = iv_estatus ).

    call method cl_log_ppf=>create_log
*  EXPORTING
*    ip_object    = 'PPF'
*    ip_subobject = 'PROCESSING'
*    ip_ext_no    =
      receiving
        ep_handle = l_protocol_handle.

    try.
        call method lc_exit->execute
          exporting
            flt_val            = 'HF_SET_STATUS'
            io_appl_object     = lo_appl_object
            io_partner         = lo_partner
            ip_application_log = l_protocol_handle
            ip_preview         = ' '
            ii_container       = lc_container
          receiving
            rp_status          = rp_status.
      catch cx_socm_condition_violated.
        rv_exec_status = 0.
        exit.
*        cx_socm_declared_exception.
*        raise error_occurred.
    endtry.

    call method cl_log_ppf=>refresh_log
      exporting
        ip_handle = l_protocol_handle.

* Publish event
    call function 'CRM_EVENT_PUBLISH_OW'
      exporting
        iv_obj_name = 'STATUS'
        iv_guid_hi  = iv_object_guid
        iv_kind_hi  = 'A'
        iv_event    = 'SAVE'.
    if rp_status <> 1.
      rv_exec_status = 0.
      exit.
    endif.
    rv_exec_status = 1.

    cl_ags_crm_1o_api=>get_instance(
    exporting
    iv_header_guid = iv_object_guid
    iv_process_mode = gc_mode-change
    importing
    eo_instance = lo_cd
    ).

    call method lo_cd->save
      exporting
        iv_unlock      = 'X'
      changing
        cv_log_handle  = lv_log_handle
      exceptions
        error_occurred = 1
        others         = 2.
    if sy-subrc <> 0.
* Implement suitable error handling here
      rv_exec_status = 0.
      exit.
    endif.



  endmethod.


  method set_workflow_runs_data.
    data: lv_run  type zgit_status,
          lv_date type string.

    lv_run-repo = iv_git_data-repo.
    lv_run-workfolw_id = iv_git_data-workflow_id.
    lv_run-run_id = iv_git_data-run_id.
    data lv_current_time type timestamp.
    get time stamp field lv_current_time.
    lv_run-start_at = lv_current_time."iv_git_data-started_at.
    lv_run-user_id = sy-uname.
    lv_run-git_user = iv_git_data-git_user.
    lv_run-testplan = iv_git_data-testplan.
    lv_run-testset_key = iv_git_data-testset_key.
    lv_run-event = iv_git_data-event.
    lv_run-ccl = iv_git_data-ccl.
    lv_run-testset_id = iv_git_data-testset_id.

    select single  SLAN_NAME from SLAN_HEADER where slan_id = @lv_run-ccl into @data(lv_slan).

    select single time from zgit_set
      where ccl = @lv_slan
      and testset_id = @lv_run-testset_id
      into @data(lv_time).
    if lv_time is initial.
      select single time from zgit into @lv_time.
    endif.
    if lv_time is not initial.
      try.
          call method cl_abap_tstmp=>add
            exporting
              tstmp   = lv_run-start_at
              secs    = lv_time
            receiving
              r_tstmp = lv_run-stop_at.
        catch cx_parameter_invalid_range .
          return.
        catch cx_parameter_invalid_type .
          return.
      endtry.
    endif.

    modify zgit_status from lv_run.

  endmethod.
ENDCLASS.
