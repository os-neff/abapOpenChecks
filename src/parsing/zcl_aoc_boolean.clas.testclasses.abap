CLASS lcl_parse DEFINITION FINAL.

  PUBLIC SECTION.
    CLASS-METHODS:
      parse IMPORTING iv_code          TYPE string
            RETURNING VALUE(ro_tokens) TYPE REF TO zcl_aoc_boolean_tokens.

ENDCLASS.

CLASS lcl_parse IMPLEMENTATION.

  METHOD parse.

    DATA: lt_code       TYPE string_table,
          lt_statements TYPE sstmnt_tab,
          lt_tokens     TYPE stokesx_tab.


    APPEND iv_code TO lt_code.

    SCAN ABAP-SOURCE lt_code
         TOKENS        INTO lt_tokens
         STATEMENTS    INTO lt_statements
         WITH ANALYSIS
         WITH COMMENTS
         WITH PRAGMAS  abap_true.
    cl_abap_unit_assert=>assert_subrc( ).

    CREATE OBJECT ro_tokens EXPORTING it_tokens = lt_tokens.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_parse DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      parse IMPORTING iv_string        TYPE string
            RETURNING VALUE(rv_result) TYPE string,
      test001 FOR TESTING,
      test002 FOR TESTING,
      test003 FOR TESTING,
      test004 FOR TESTING,
      test005 FOR TESTING,
      test006 FOR TESTING,
      test007 FOR TESTING,
      test008 FOR TESTING,
      test009 FOR TESTING,
      test010 FOR TESTING,
      test011 FOR TESTING,
      test012 FOR TESTING,
      test013 FOR TESTING,
      test014 FOR TESTING,
      test015 FOR TESTING.

ENDCLASS.       "ltcl_Test

CLASS ltcl_parse IMPLEMENTATION.

  METHOD parse.

    DATA: lt_code       TYPE string_table,
          lt_tokens     TYPE stokesx_tab,
          lo_node       TYPE REF TO zcl_aoc_boolean_node,
          lt_statements TYPE sstmnt_tab.


    lt_tokens = lcl_parse=>parse( iv_string )->remove( 1 )->get_tokens( ).

    lo_node = zcl_aoc_boolean=>parse( lt_tokens ).
    cl_abap_unit_assert=>assert_bound( lo_node ).

    rv_result = lo_node->to_string( ).

  ENDMETHOD.

  METHOD test001.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo = bar.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test002.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo NE bar.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test003.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo <> bar.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test004.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo( ) = bar( ).' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test005.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF ( foo = bar ).' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '( COMPARE )' ).
  ENDMETHOD.

  METHOD test006.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo = bar AND moo = boo.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'AND ( COMPARE COMPARE )' ).
  ENDMETHOD.

  METHOD test007.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF ( foo = bar AND moo = boo ).' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '( AND ( COMPARE COMPARE )' ).
  ENDMETHOD.

  METHOD test008.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF ( foo = bar ) AND ( moo = boo ).' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'AND ( ( COMPARE ) ( COMPARE ) )' ).
  ENDMETHOD.

  METHOD test009.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF ( ( foo = bar ) AND ( moo = boo ) ).' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = '( AND ( ( COMPARE ) ( COMPARE ) ) )' ).
  ENDMETHOD.

  METHOD test010.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF method( value ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test011.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF method( field = value ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test012.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF method( VALUE #( foo = bar ) ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test013.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF foo->method( field = value ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test014.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF moo-foo->method( field = value ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

  METHOD test015.
    DATA: lv_result TYPE string.

    lv_result = parse( 'IF method1( method2( ) ) = 1.' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = 'COMPARE' ).
  ENDMETHOD.

ENDCLASS.

CLASS ltcl_remove_strings DEFINITION DEFERRED.
CLASS zcl_aoc_boolean DEFINITION LOCAL FRIENDS ltcl_remove_strings.

CLASS ltcl_remove_strings DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      test
        IMPORTING
          iv_code TYPE string
          iv_exp  TYPE string,
      test01 FOR TESTING,
      test02 FOR TESTING,
      test03 FOR TESTING.

ENDCLASS.

CLASS ltcl_remove_strings IMPLEMENTATION.

  METHOD test.

    DATA: lv_result TYPE string,
          lo_node   TYPE REF TO zcl_aoc_boolean_node,
          lo_tokens TYPE REF TO zcl_aoc_boolean_tokens.


    lo_tokens = lcl_parse=>parse( iv_code ).

    zcl_aoc_boolean=>remove_strings( lo_tokens ).
    cl_abap_unit_assert=>assert_bound( lo_tokens ).

    lv_result = lo_tokens->to_string( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = to_upper( iv_exp ) ).

  ENDMETHOD.

  METHOD test01.

    test( iv_code = 'bar'
          iv_exp = 'bar' ).

  ENDMETHOD.

  METHOD test02.

    test( iv_code = '''bar'''
          iv_exp = 'str' ).

  ENDMETHOD.

  METHOD test03.

    test( iv_code = '`bar`'
          iv_exp = 'str' ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_remove_method_calls DEFINITION DEFERRED.
CLASS zcl_aoc_boolean DEFINITION LOCAL FRIENDS ltcl_remove_method_calls.

CLASS ltcl_remove_method_calls DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    METHODS:
      test
        IMPORTING iv_code TYPE string
                  iv_exp  TYPE string,
      test01 FOR TESTING,
      test02 FOR TESTING,
      test03 FOR TESTING,
      test04 FOR TESTING,
      test05 FOR TESTING,
      test06 FOR TESTING,
      test07 FOR TESTING.

ENDCLASS.       "ltcl_Remove_Method_Calls

CLASS ltcl_remove_method_calls IMPLEMENTATION.

  METHOD test.

    DATA: lv_result TYPE string,
          lo_node   TYPE REF TO zcl_aoc_boolean_node,
          lo_tokens TYPE REF TO zcl_aoc_boolean_tokens.


    lo_tokens = lcl_parse=>parse( iv_code ).

    zcl_aoc_boolean=>remove_method_calls( lo_tokens ).
    cl_abap_unit_assert=>assert_bound( lo_tokens ).

    lv_result = lo_tokens->to_string( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_result
      exp = to_upper( iv_exp ) ).

  ENDMETHOD.

  METHOD test01.

    test( iv_code = 'foo( )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test02.

    test( iv_code = 'foo( )->bar( )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test03.

    test( iv_code = 'foo( bar( ) )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test04.

    test( iv_code = 'bar->method( )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test05.

    test( iv_code = 'bar=>method( )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test06.

    test( iv_code = 'foo-bar->method( )'
          iv_exp  = 'method' ).

  ENDMETHOD.

  METHOD test07.

    test( iv_code = 'foo( ) = bar( )'
          iv_exp  = 'method = method' ).

  ENDMETHOD.

ENDCLASS.
