
EXECUTE API.BUYPRODUCT(111, 2, NULL, 1);


DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.BUYPRODUCT(111, 2, 12, 1);
END;

DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.BUYPRODUCT(113, 1, 12, 1);
END;DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.BUYPRODUCT(116, 3, 12, 1);
END;DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.BUYPRODUCT(121, 5, 12, 1);
END;DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.BUYPRODUCT(119, 6, 12, 1);
END;

DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.ADDCUSTOMER('iVANOV IVAN', '(999) 123-4567', 'TEST@TEST.TEST');
DBMS_OUTPUT.put_line(RES);
END;
DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.ADDCUSTOMER('mame na', '(999) 122-4567', 'TEST@TEST.TEST');
DBMS_OUTPUT.put_line(RES);
END;
DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.ADDCUSTOMER('name fdf', '(999) 456-4567', 'TEST@TEST.TEST');
DBMS_OUTPUT.put_line(RES);
END;
DECLARE
 RES NVARCHAR2(1024);
BEGIN
RES:=API.ADDCUSTOMER('namer ra', '(999) 633-4567', 'TEST@TEST.TEST');
DBMS_OUTPUT.put_line(RES);
END;
