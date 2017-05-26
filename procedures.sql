CREATE OR REPLACE PACKAGE CLIENTAPI AS
  PROCEDURE AddClient(client_name NVARCHAR2, client_email NVARCHAR2, client_phone NVARCHAR2, client_login NVARCHAR2, client_password NVARCHAR2);
  PROCEDURE DeleteClient(client_login NVARCHAR2);
  PROCEDURE CreateOrder(order_id NVARCHAR2, address NVARCHAR2, client_login NVARCHAR2, product_name NVARCHAR2, amount NUMBER);
  PROCEDURE CancelOrder(order_id NVARCHAR2);
  PROCEDURE ExecuteOrder(order_id NVARCHAR2);
  FUNCTION ShowOrderInfo(order_id NVARCHAR2) RETURN NVARCHAR2;
  FUNCTION GetClientData(client_login NVARCHAR2) RETURN NVARCHAR2;
END CLIENTAPI;
/
create or replace PACKAGE API AS
 function BUYPRODUCT(CODE NUMBER, AMOUNT NUMBER, CARD_NUMBER NUMBER, PAIMENT_TYPE NUMBER) RETURN NVARCHAR2;
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
  
  END API;
  /

  PROCEDURE CreateOrder(order_id NVARCHAR2, address NVARCHAR2, client_login NVARCHAR2, product_name NVARCHAR2, amount NUMBER)
  AS
  client_exists NUMBER;
  login_exists NUMBER;
  product_exists NUMBER;
  orderid_exist NUMBER;

  amount_available NUMBER;
  product_id NUMBER;
  product_price NUMBER;
  client_id NUMBER;
  total_ NUMBER;
  total_to_insert NUMBER;
  orders_amount NUMBER;
  new_orders_amount NUMBER;
  cur_time TIMESTAMP;
  
  BEGIN
  SELECT COUNT(*) INTO login_exists FROM LOGIN_PASSWORD WHERE "Login"=client_login;
  SELECT COUNT(*) INTO client_exists FROM CLIENTS WHERE "Login"=client_login;
  SELECT COUNT(*) INTO product_exists FROM PRODUCTS WHERE "Name"=product_name;
  SELECT COUNT(*) INTO orderid_exist FROM ORDERS WHERE "OrderId"=order_id;


  IF (login_exists>0 AND client_exists>0 AND product_exists>0) THEN
    SELECT "Available" INTO amount_available FROM PRODUCTS WHERE "Name"=product_name;
    IF (amount <= amount_available) THEN
      SELECT "Id" INTO product_id FROM PRODUCTS WHERE "Name"=product_name;
      SELECT "Id" INTO client_id FROM CLIENTS WHERE "Login"=client_login;

      SELECT CURRENT_TIMESTAMP INTO cur_time  FROM DUAL;
      SELECT "Price" INTO product_price FROM PRODUCTS WHERE "Name"=product_name; 
      
      IF (orderid_exist > 0) THEN
          SELECT "Total" INTO total_ FROM ORDERS WHERE "OrderId"=order_id;
      ELSE
          total_ := 0;
      END IF;

      total_to_insert:=total_+(product_price*amount);

      INSERT INTO ORDERS ("Id", "OrderId", "Address", "Time", "Client", "Product", "Amount", "Total") VALUES (ORDERS_SEQ.NEXTVAL, order_id, address, cur_time, client_id, product_id, amount, total_to_insert);
      
      UPDATE ORDERS SET "Total"=total_to_insert WHERE "OrderId"=order_id;
      SELECT "OrdersAmount" INTO orders_amount FROM CLIENTS WHERE "Id"=client_id;
      new_orders_amount:=orders_amount+1;
      UPDATE CLIENTS SET "OrdersAmount"=new_orders_amount WHERE "Id"=client_id;
      
      
    ELSE
      DBMS_OUTPUT.put_line('ERROR: NOT ENOUGH PRODUCTS AT WAREHOUSES');
    END IF;
  ELSE
    DBMS_OUTPUT.put_line('ERROR: SUCH CLIENT DOES NOT EXIST');
  END IF;
  COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
       DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  END CreateOrder;


  PROCEDURE CancelOrder(order_id NVARCHAR2)
  AS
  order_exists NUMBER;
  cancelled_orders NUMBER;
  new_cancelled_orders NUMBER;
  client_id NUMBER;
  BEGIN
  SELECT COUNT(*) INTO order_exists FROM ORDERS WHERE "OrderId"=order_id;
  IF (order_exists>0) THEN
    DELETE FROM ORDERS WHERE "OrderId"=order_id;
    SELECT "Client" INTO client_id FROM ORDERS WHERE "OrderId"=order_id;
    SELECT "OrdersCancelledAmount" INTO cancelled_orders FROM CLIENTS WHERE "Id"=client_id;
    new_cancelled_orders:=cancelled_orders+1;
    UPDATE CLIENTS SET "OrdersCancelledAmount"=new_cancelled_orders WHERE "Id"=client_id;
  ELSE
    DBMS_OUTPUT.put_line('ERROR: NO SUCH ORDER');
  END IF;
  COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
       DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  END CancelOrder;  


  PROCEDURE ExecuteOrder(order_id NVARCHAR2)
  AS
  CURSOR search_res IS 
      SELECT "Product", "Amount" FROM ORDERS WHERE "OrderId"=order_id; 
  
  order_exists NUMBER;
  product_id NUMBER;
  product_amount NUMBER;
  remove_result BOOLEAN;
  
  
  BEGIN
  SELECT COUNT(*) INTO order_exists FROM ORDERS WHERE "OrderId"=order_id;
  IF (order_exists>0) THEN
    OPEN search_res;
          LOOP
              FETCH search_res INTO product_id, product_amount;
              EXIT WHEN search_res%NOTFOUND;
              remove_result:=PRODUCTAPI.CheckProductAvailable(product_id, product_amount);
      IF (remove_result) THEN
        PRODUCTAPI.RemoveProduct(product_id, product_amount);
      ELSE
        DBMS_OUTPUT.put_line('ERROR: SORRY, NOT ENOUGH PRODUCT AVAILABLE ON WAREHOUSES. PLEASE STANDBY.');
      END IF;
          END LOOP;
          CLOSE search_res;
  ELSE
    DBMS_OUTPUT.put_line('ERROR: NO SUCH ORDER');
  END IF;
  COMMIT;
  EXCEPTION
     WHEN OTHERS THEN
       DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  END ExecuteOrder;



  PROCEDURE DeleteClient(client_login NVARCHAR2)
  AS
  search_res_login_password NUMBER;
  search_res_clients NUMBER;
  BEGIN
    SELECT COUNT(*) INTO search_res_clients FROM CLIENTS WHERE "Login"=client_login;
    SELECT COUNT(*) INTO search_res_login_password FROM LOGIN_PASSWORD WHERE "Login"=client_login;

    IF (search_res_clients > 0) THEN
    IF (search_res_login_password > 0) THEN
      DELETE FROM CLIENTS WHERE "Login"=client_login;
      DELETE FROM LOGIN_PASSWORD WHERE "Login"=client_login;
      COMMIT;
      DBMS_OUTPUT.put_line('User ' || client_login || ' DELETED');
    ELSE
      DBMS_OUTPUT.put_line('ERROR: CLIENT NOT FOUND');
    END IF;
  ELSE
    DBMS_OUTPUT.put_line('ERROR: CLIENT NOT FOUND');
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
  END DeleteClient;

  FUNCTION GetClientData(client_login NVARCHAR2) RETURN NVARCHAR2
  IS 
    CURSOR search_res IS 
      SELECT * FROM CLIENTS WHERE "Login"=client_login;  
      
    search_res_clients NUMBER; 
    res_id NUMBER;
    res_name NVARCHAR2(255);
    res_phone NVARCHAR2(16);
    res_login NVARCHAR2(255);
    res_registered_date DATE;
    res_email NVARCHAR2(255);
    res_orders_amount NUMBER;
    res_orders_canceled NUMBER;
    
    res_percent NUMBER;
    res NVARCHAR2(1024);
      
  BEGIN
    SELECT COUNT(*) INTO search_res_clients FROM CLIENTS WHERE "Login"=client_login;
    IF (search_res_clients != 0) THEN
      BEGIN
        res := '';
        OPEN search_res;
        LOOP
          FETCH search_res INTO res_id, res_name, res_login, res_registered_date, res_email, res_phone, res_orders_amount, res_orders_canceled;
          EXIT WHEN search_res%NOTFOUND;
          IF (res_orders_amount = 0) THEN
            res_percent := 0;
          ELSE 
            res_percent := 100 - (res_orders_canceled / res_orders_amount)*100;
          END IF;
          res := res || ' Id: ' || TO_CHAR(res_id) || ' ;Name: ' || res_name || ' ;Login: ' || res_login || ' ;Email: ' || res_email || ' ;Phone: ' || res_phone || ' ;Registered:' || TO_CHAR(res_registered_date, 'DD.MM.YYYY') || ' ;SuccessOrders: ' || TO_CHAR(res_percent) || '%;';
        END LOOP;
        CLOSE search_res;
        RETURN res;
      END;
    ELSE 
      DBMS_OUTPUT.put_line('ERROR: CLIENT NOT FOUND');
      RETURN '';
    END IF;
  
  EXCEPTION
   WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
   RETURN '';
  END GetClientData;


  FUNCTION ShowOrderInfo(order_id NVARCHAR2) RETURN NVARCHAR2
  AS
  CURSOR search_res IS 
      SELECT * FROM ORDERS WHERE "OrderId"=order_id;
  
  order_exists NUMBER; 

  id_of_order NUMBER;
  id_of_order2 NUMBER;
  order_address NVARCHAR2(255);
  order_time TIMESTAMP WITH TIME ZONE;
  client_id NUMBER;
  product_id NUMBER;
  product_amount NUMBER;
  product_total NUMBER;
  product_name NVARCHAR2(255);
  client_login NVARCHAR2(255);
  res NVARCHAR2(1024);

  BEGIN
  SELECT COUNT(*) INTO order_exists FROM ORDERS WHERE "OrderId"=order_id;
  IF (order_exists>0) THEN
    res := '';
          OPEN search_res;
          LOOP
              FETCH search_res INTO id_of_order, id_of_order2, order_address, order_time, client_id, product_id, product_amount, product_total; 
              EXIT WHEN search_res%NOTFOUND;
              SELECT "Name" INTO product_name FROM PRODUCTS WHERE "Id"=product_id;
              SELECT "Login" INTO client_login FROM CLIENTS WHERE "Id"=client_id;

              res := res || ' Id: ' || TO_CHAR(id_of_order) || ' ;Order Id: ' || TO_CHAR(id_of_order2) || ' ;Address: ' || order_address || ' ;Time: ' || TO_CHAR(order_time) || ' ;Client Id: ' || client_login || ' ;Product: ' || product_name || ' ;Amount:' || TO_CHAR(product_amount) ||  ';Total Sum: ' || TO_CHAR(product_total) ||';\n';

          END LOOP;
          CLOSE search_res;
          RETURN res;
  ELSE
    DBMS_OUTPUT.put_line('ERROR: ORDER NOT FOUND');
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('ERROR: NONE OF ARGS COULD BE NULL');
   RETURN '';
  END ShowOrderInfo;

END CLIENTAPI;
/
