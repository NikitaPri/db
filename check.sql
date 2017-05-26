
CREATE OR REPLACE PACKAGE UTILS AS
  FUNCTION VerifyHumanName(name_to_test NVARCHAR2) RETURN BOOLEAN;
  FUNCTION VerifyEmail(email_to_test NVARCHAR2) RETURN BOOLEAN;
  FUNCTION VerifyPhone(phone_to_test NVARCHAR2) RETURN BOOLEAN;
  FUNCTION VerifyTime(time_to_test NVARCHAR2) RETURN BOOLEAN;
END UTILS;
/
CREATE OR REPLACE PACKAGE BODY UTILS AS

  FUNCTION VerifyHumanName(name_to_test NVARCHAR2) RETURN BOOLEAN 
  IS
  forbidden_symbol_pos NUMBER;
  BEGIN
    SELECT REGEXP_INSTR(name_to_test, '[0-9,./\!&+=_()^$:;#@"]', 1, 1) "REGEXP_INSTR" INTO forbidden_symbol_pos FROM DUAL;
    
    IF (forbidden_symbol_pos = 0) THEN 
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
    RETURN FALSE;
  END VerifyHumanName;
  
  FUNCTION VerifyEmail(email_to_test NVARCHAR2) RETURN BOOLEAN
  IS
    res NUMBER;
  BEGIN
     SELECT COUNT(REGEXP_SUBSTR(email_to_test, '^[A-Z0-9._%-]+@[A-Z0-9._%-]+\.[A-Z]{2,4}')) INTO res FROM DUAL;
     IF (res = 0) THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
  
  EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  RETURN FALSE;
  END VerifyEmail;
  
  FUNCTION VerifyPhone(phone_to_test NVARCHAR2) RETURN BOOLEAN
  IS
    matches NUMBER;
  BEGIN
    SELECT COUNT(REGEXP_SUBSTR(phone_to_test, '^((\+7|7|8)+([0-9]){10})')) INTO matches FROM DUAL;
     IF (matches = 0) THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
  
  EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  RETURN FALSE;
  END VerifyPhone;
  
  FUNCTION VerifyTime(time_to_test NVARCHAR2) RETURN BOOLEAN
  IS 
    matches NUMBER;
  BEGIN
      SELECT COUNT(REGEXP_SUBSTR(time_to_test, '^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$')) INTO matches FROM DUAL;
      IF (matches = 0) THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
  EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  RETURN FALSE;
  END VerifyTime;

END UTILS;
