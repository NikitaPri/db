CREATE TABLE P_PRODUCTS(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
 "NAME" NVARCHAR2(255),
"CATEGORY" NVARCHAR2(255),
"EXPIRATION" NUMBER,
"PROVIDER" NVARCHAR2(255),
"UNITS" NVARCHAR2(255),
 CONSTRAINT code_unique UNIQUE ("CODE")
);
CREATE TABLE P_PRODUCTSIN(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
"DATE" DATE NOT NULL,
"CONTRACT" NUMBER,
"AMOUNT_PROVIDED" NUMBER NOT NULL,
"AMOUNT_LEFT" NUMBER,
CONSTRAINT fk_code
  FOREIGN KEY ("CODE") REFERENCES P_PRODUCTS("CODE")
);
CREATE TABLE P_CUSTOMERS(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CARD_NUMBER" NUMBER NOT NULL,
"DATE" DATE NOT NULL,
"NAME" NVARCHAR2(64) NOT NULL,
"PHONE" NVARCHAR2(16),
"EMAIL" NVARCHAR2(255),
CONSTRAINT phone_check
  CHECK (REGEXP_LIKE (PHONE, '^\(\d{3}\) \d{3}-\d{4}$')),
CONSTRAINT email_check
  CHECK (REGEXP_LIKE (EMAIL, '\w+@\w+(\.\w+)+'))
);
CREATE TABLE P_PRICE(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
"BUY_PRICE" NUMBER,
"BASE_PRICE" NUMBER,
"SALE_PRICE" NUMBER,
"CARD_SALE_PRICE" NUMBER,
CONSTRAINT p_code_fk FOREIGN KEY ("CODE") REFERENCES P_PRODUCTS("CODE")
);
CREATE TABLE P_SALE(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
"BASE_SALE" NUMBER,
"EXPIRE_DATE" DATE,
"ONE_PLUS" NUMBER,
"CARD_SALE" NUMBER,
CONSTRAINT s_code_fk FOREIGN KEY ("CODE") REFERENCES P_PRODUCTS("CODE")
);
CREATE TABLE P_ORDERS(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
"AMOUNT" NUMBER,
"PRICE" NUMBER,
"DATE" DATE,
"CONTRACT_NUMBER" NUMBER,
CONSTRAINT o_code_fk FOREIGN KEY ("CODE") REFERENCES P_PRODUCTS("CODE")
);
CREATE TABLE P_SOLD(
"ID" NUMBER NOT NULL PRIMARY KEY,
"CODE" NUMBER NOT NULL,
"DATE" DATE,
"AMOUNT" NUMBER,
"TOTAL_PRICE" NUMBER,
"CARD_NUMBER" NUMBER,
"PAIMENT_TYPE" NUMBER,
CONSTRAINT sold_code_fk FOREIGN KEY ("CODE") REFERENCES P_PRODUCTS("CODE")
);
