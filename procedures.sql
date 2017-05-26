create or replace PACKAGE API AS
 function BUYPRODUCT(CODE NUMBER, AMOUNT NUMBER, CARD_NUMBER NUMBER, PAIMENT_TYPE NUMBER) RETURN NVARCHAR2;
 FUNCTION ADDCUSTOMER(FULLNAME NVARCHAR2, PHONE NVARCHAR2, EMAIL NVARCHAR2) RETURN NVARCHAR2;
END API;
/
create or replace PACKAGE BODY API AS

FUNCTION BUYPRODUCT(CODE NUMBER, AMOUNT NUMBER, CARD_NUMBER NUMBER, PAIMENT_TYPE NUMBER) RETURN NVARCHAR2
  AS
  already_exists NUMBER;
  already_exists_c NUMBER;
  fcode number;
  new_amount NUMBER;
  cur_date DATE;
  price_t NUMBER;
  price_tmp NUMBER;
  NAME_T NVARCHAR2(255);
  UNITS_T NVARCHAR2(255);
  RES NVARCHAR2(1024);
  BEGIN
    SELECT COUNT(*) INTO already_exists FROM P_PRODUCTS WHERE "CODE"=CODE;
    FCODE:=CODE;
    SELECT SYSDATE INTO cur_date  FROM DUAL;
    IF (already_exists != 0 AND AMOUNT>=1) THEN
          
          SELECT "AMOUNT_LEFT" INTO new_amount FROM P_PRODUCTSIN WHERE "CODE"=fcode;
          UPDATE P_PRODUCTSIN SET "AMOUNT_LEFT"=(new_amount-AMOUNT) WHERE "CODE"=fcode;
          IF (CARD_NUMBER!=NULL) THEN
            SELECT COUNT(*) INTO already_exists_c FROM P_CUSTOMERS WHERE "CARD_NUMBER"=CARD_NUMBER;
            IF (already_exists_c!=0) THEN
                SELECT "CARD_SALE_PRICE" INTO price_tmp FROM P_PRICE WHERE "CODE"=fcode;
                price_t:=price_tmp*AMOUNT;
              ELSE
                DBMS_OUTPUT.put_line('CARD IS NOT IN THE SYSTEM');
            END IF;
            ELSE
               SELECT "SALE_PRICE" INTO price_tmp FROM P_PRICE WHERE "CODE"=fcode;
                price_t:=price_tmp*AMOUNT;
            END IF;
            SELECT "NAME" INTO NAME_T FROM p_products WHERE "CODE"=fcode;
            SELECT "UNITS" INTO UNITS_T FROM P_PRODUCTS WHERE "CODE"=fcode;
              RES:= RES || '  NAME: ' || NAME_T || '  UNITS:  ' || UNITS_T || 
              ' PRICE FOR ONE:  ' ||PRICE_TMP || '  TOTAL PRICE:  ' || price_t ||';\n';
              INSERT INTO P_SOLD("CODE", "DATE_T", "AMOUNT", "TOTAL_PRICE", "CARD_NUMBER", "PAIMENT_TYPE") VALUES (CODE, cur_date, AMOUNT, price_t, CARD_NUMBER, PAIMENT_TYPE);
              COMMIT;
              RETURN RES;
    ELSE
        DBMS_OUTPUT.put_line('ERROR: FORMAT INCORRECT');
        RETURN '';
    END IF;
  EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR');
        RETURN '';
  END BUYPRODUCT;
  
FUNCTION ADDCUSTOMER(FULLNAME NVARCHAR2, PHONE NVARCHAR2, EMAIL NVARCHAR2) RETURN NVARCHAR2
AS
ALREADY_EXISTS NUMBER;
CUR_DATE DATE;
CARD_N NUMBER;
BEGIN
  SELECT COUNT(*) INTO ALREADY_EXISTS FROM P_CUSTOMERS WHERE "NAME"=FULLNAME;
  IF (ALREADY_EXISTS=0) THEN
    IF (UTILS.VerifyHumanName(FULLNAME) AND utils.verifyemail(EMAIL)) THEN
      SELECT SYSDATE INTO CUR_DATE FROM DUAL;
      INSERT INTO P_CUSTOMERS ("DATE_T", "NAME", "EMAIL", "PHONE") VALUES (CUR_DATE, FULLNAME, EMAIL, PHONE);
      COMMIT;
      ELSE
        RETURN 'BAD INPUT';
    END IF;
  END IF;
  SELECT "CARD_NUMBER" INTO CARD_N FROM P_CUSTOMERS WHERE "NAME"=FULLNAME;
  RETURN TO_CHAR(CARD_N);
  END ADDCUSTOMER;

  END API;
  /
