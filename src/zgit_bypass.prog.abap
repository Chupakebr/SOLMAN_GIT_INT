*&---------------------------------------------------------------------*
*& Report  ZGIT_BYPASS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
report zgit_bypass.
tables: crmd_customer_h.
select-options: p_t_id for crmd_customer_h-zzgit_repo no intervals.
parameters: p_bypass type zdtel00000m.


IF LINES( p_t_id ) > 0.
  UPDATE crmd_customer_h
    SET zzbypassgit = @p_bypass
    WHERE zzgit_repo IN @p_t_id.
ENDIF.
