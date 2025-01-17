class ZCL_IM_GIT_ENABLED definition
  public
  final
  create public .

public section.

  interfaces IF_EX_CONTAINER_PPF .
protected section.

  class-methods IS_GIT_ENABLED
    importing
      !IV_GUID type CRMT_OBJECT_GUID optional
      !IO_CONTAINER type ref to IF_SWJ_PPF_CONTAINER optional
      !IO_PARAMETER type ref to IF_SWJ_PPF_CONTAINER optional .
private section.
ENDCLASS.



CLASS ZCL_IM_GIT_ENABLED IMPLEMENTATION.


  method IF_EX_CONTAINER_PPF~MODIFY_CONTAINER.
        DATA: lt_values TYPE TABLE OF swcont,
          ls_value  TYPE swcont,
          ls_object TYPE sibflporb,
          lv_guid   TYPE crmt_object_guid.


    CHECK: ci_container IS BOUND,
           ci_parameter IS BOUND.


    "Get GUID
    CALL METHOD ci_container->get_value
      EXPORTING
        element_name = 'BUSINESSOBJECT'
      IMPORTING
        data         = ls_object.

    lv_guid = ls_object-instid.


    "Get Parameter
    lt_values = ci_parameter->get_values( ).


    READ TABLE lt_values INTO ls_value WITH KEY element = 'ZGIT_ENABLED'.
    IF sy-subrc = 0.
      is_git_enabled( iv_guid      = lv_guid
                         io_container = ci_container
                         io_parameter = ci_parameter ).
    ENDIF.
  endmethod.


  method is_git_enabled.

    if zcl_git_helper=>is_git_enabled( iv_guid ) = 1.
      io_parameter->set_value( element_name = 'ZGIT_ENABLED' data = abap_true ).
    else.
      io_parameter->set_value( element_name = 'ZGIT_ENABLED' data = abap_false ).
    endif.
  endmethod.
ENDCLASS.
