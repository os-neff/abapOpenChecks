class ZCL_AOC_CHECK_06 definition
  public
  inheriting from ZCL_AOC_SUPER
  create public .

public section.
*"* public components of class ZCL_AOC_CHECK_06
*"* do not include other source files here!!!

  methods CONSTRUCTOR .

  methods CHECK
    redefinition .
  methods GET_ATTRIBUTES
    redefinition .
  methods GET_MESSAGE_TEXT
    redefinition .
  methods IF_CI_TEST~DISPLAY_DOCUMENTATION
    redefinition .
  methods IF_CI_TEST~QUERY_ATTRIBUTES
    redefinition .
  methods PUT_ATTRIBUTES
    redefinition .
protected section.
*"* protected components of class ZCL_AOC_CHECK_06
*"* do not include other source files here!!!

  data MV_ERRTY type SCI_ERRTY .
  data MV_HIKEY type FLAG .
  data MV_LOKEY type FLAG .
private section.
*"* private components of class ZCL_AOC_CHECK_06
*"* do not include other source files here!!!

  constants C_MY_NAME type SEOCLSNAME value 'ZCL_AOC_CHECK_06'. "#EC NOTEXT
ENDCLASS.



CLASS ZCL_AOC_CHECK_06 IMPLEMENTATION.


METHOD check.

  DATA: lt_code      TYPE string_table,
        lv_statement TYPE i,
        lv_error     TYPE abap_bool,
        lv_code      TYPE string,
        lv_lower     TYPE string,
        lv_upper     TYPE string,
        lv_offset    TYPE i.

  FIELD-SYMBOLS: <ls_level>     LIKE LINE OF it_levels,
                 <ls_statement> LIKE LINE OF it_statements,
                 <lv_code>      LIKE LINE OF lt_code,
                 <ls_token>     LIKE LINE OF it_tokens.

* todo, this is too simple

  LOOP AT it_levels ASSIGNING <ls_level>.
* skip class definitions, they are auto generated(in most cases)
    IF strlen( <ls_level>-name ) = 32
        AND ( <ls_level>-name+30(2) = 'CU'
        OR <ls_level>-name+30(2) = 'CO'
        OR <ls_level>-name+30(2) = 'CI' ).
      CONTINUE. " current loop
    ENDIF.

    lt_code = get_source( <ls_level> ).

* only run for lowest level
    READ TABLE it_levels WITH KEY level = sy-tabix TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      CONTINUE. " current loop
    ENDIF.

    LOOP AT it_statements ASSIGNING <ls_statement>
        FROM <ls_level>-from TO <ls_level>-to
        WHERE type <> scan_stmnt_type-comment
        AND type <> scan_stmnt_type-comment_in_stmnt
        AND type <> scan_stmnt_type-compute_direct
        AND type <> scan_stmnt_type-method_direct
        AND type <> scan_stmnt_type-trmac_call
        AND type <> scan_stmnt_type-macro_call.
      lv_statement = sy-tabix.

* check first token in statement, this is always a keyword
      READ TABLE it_tokens ASSIGNING <ls_token> INDEX <ls_statement>-from.
      CHECK sy-subrc = 0.

      IF <ls_token>-row = 0.
* in case of macros
        CONTINUE. " current loop
      ENDIF.

      READ TABLE lt_code ASSIGNING <lv_code> INDEX <ls_token>-row.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
* todo, how to handle INCLUDE
* ASSERT sy-subrc = 0.

      lv_offset = <ls_token>-col.
      lv_code = <lv_code>+lv_offset(<ls_token>-len1).
      lv_lower = lv_code.
      lv_upper = lv_code.
      TRANSLATE lv_lower TO LOWER CASE.
      TRANSLATE lv_upper TO UPPER CASE.

      lv_error = abap_false.
      IF mv_hikey = abap_true AND lv_code <> lv_upper.
        lv_error = abap_true.
      ELSEIF mv_lokey = abap_true AND lv_code <> lv_lower.
      ENDIF.

      IF lv_error = abap_true.
* skip if part of macro
        LOOP AT it_structures TRANSPORTING NO FIELDS
            WHERE stmnt_from <= lv_statement
            AND stmnt_to >= lv_statement
            AND type = scan_struc_type-macro.
          EXIT. " current loop.
        ENDLOOP.
        IF sy-subrc = 0.
          CONTINUE. " current loop
        ENDIF.

        inform( p_sub_obj_type = c_type_include
                p_sub_obj_name = <ls_level>-name
                p_line         = <ls_token>-row
                p_kind         = mv_errty
                p_test         = c_my_name
                p_code         = '001' ).

        EXIT. " current loop, only one error per level
      ENDIF.

    ENDLOOP.
  ENDLOOP.

ENDMETHOD.


METHOD constructor .

  super->constructor( ).

  description    = 'Check pretty printer use'.              "#EC NOTEXT
  category       = 'ZCL_AOC_CATEGORY'.
  version        = '000'.

  has_attributes = abap_true.
  attributes_ok  = abap_true.

  mv_errty = c_error.
  mv_hikey = abap_true.
  mv_lokey = abap_false.

ENDMETHOD.                    "CONSTRUCTOR


METHOD get_attributes.

  EXPORT
    mv_errty = mv_errty
    mv_hikey = mv_hikey
    mv_lokey = mv_lokey
    TO DATA BUFFER p_attributes.

ENDMETHOD.


METHOD get_message_text.

  CASE p_code.
    WHEN '001'.
      p_text = 'Use pretty printer'.                        "#EC NOTEXT
    WHEN OTHERS.
      ASSERT 1 = 1 + 1.
  ENDCASE.

ENDMETHOD.                    "GET_MESSAGE_TEXT


METHOD if_ci_test~display_documentation.

  documentation( c_my_name ).

ENDMETHOD.


METHOD if_ci_test~query_attributes.

  DATA: lv_ok         TYPE abap_bool,
        lv_message    TYPE c LENGTH 72,
        lt_attributes TYPE sci_atttab,
        ls_attribute  LIKE LINE OF lt_attributes.

  DEFINE fill_att.
    clear ls_attribute.
    get reference of &1 into ls_attribute-ref.
    ls_attribute-text = &2.
    ls_attribute-kind = &3.
    append ls_attribute to lt_attributes.
  END-OF-DEFINITION.

  DEFINE fill_att_rb.
    clear ls_attribute.
    get reference of &1 into ls_attribute-ref.
    ls_attribute-text = &2.
    ls_attribute-kind = &3.
    ls_attribute-button_group = &4.
    append ls_attribute to lt_attributes.
  END-OF-DEFINITION.


  fill_att mv_errty 'Error Type' ''.                        "#EC NOTEXT

  fill_att_rb mv_hikey 'Keywords upper case' 'R' 'TYPE'.    "#EC NOTEXT
  fill_att_rb mv_lokey 'Keywords lower case' 'R' 'TYPE'.    "#EC NOTEXT

  WHILE lv_ok = abap_false.
    cl_ci_query_attributes=>generic(
                          p_name       = c_my_name
                          p_title      = 'Options'
                          p_attributes = lt_attributes
                          p_message    = lv_message
                          p_display    = p_display ).       "#EC NOTEXT
    IF mv_errty = c_error OR mv_errty = c_warning OR mv_errty = c_note.
      lv_ok = abap_true.
    ELSE.
      lv_message = 'Fill attributes'.                       "#EC NOTEXT
    ENDIF.
  ENDWHILE.

ENDMETHOD.


METHOD put_attributes.

  IMPORT
    mv_errty = mv_errty
    mv_hikey = mv_hikey
    mv_lokey = mv_lokey
    FROM DATA BUFFER p_attributes.                   "#EC CI_USE_WANTED

ENDMETHOD.
ENDCLASS.