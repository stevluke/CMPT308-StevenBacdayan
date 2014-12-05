--Drop commands for debugging
/*
DROP VIEW view_in_stock;
DROP VIEW view_tea_out_stock;
DROP VIEW view_tea_set_out_stock;
DROP VIEW view_tea_pot_out_stock;
DROP VIEW view_mug_out_stock;
DROP VIEW view_flavor_out_stock;
DROP VIEW view_tea_blend_out_stock;
DROP FUNCTION  getblendingredients (blendname text) ;
DROP FUNCTION updateQTY(productID INT, sold INT);
DROP FUNCTION  insertIntoInventory(productID INT, productName VARCHAR(20), amount int, price int);
DROP FUNCTION message() CASCADE;
DROP TABLE MUG_T;
DROP TABLE TEA_POT_T;
DROP TABLE TEA_SET_T;
DROP TABLE FLAVOR_MIX_T;
DROP TABLE FLAVOR_T;
DROP TABLE TEA_MIX_T;
DROP TABLE TEA_T;
DROP TABLE TEA_CATEGORY_T;
DROP TABLE TEA_BLEND_T;
DROP TABLE COUNTRY_T;
DROP TABLE VENDOR_T CASCADE;
DROP TABLE INVENTORY_T;
*/

/*
The INVENTORY_T table holds every single item that the store sells. PRODUCT_ID and NAME_ID are
inherited by the different product tables

functional dependencies: PRODUCT_ID, NAME_ID > QTY, PRICEUSD
*/
CREATE TABLE INVENTORY_T(
	PRODUCT_ID INT NOT NULL,
	NAME_ID VARCHAR(50) NOT NULL,
	QTY INT NOT NULL,
	PRICEUSD INT NOT NULL,
	PRIMARY KEY (PRODUCT_ID, NAME_ID)
);

/*
The COUNTRY_T table holds the different countries that produce tea. This is inherited by the TEA_T table.


functional dependencies: COUNTRY_CODE_ID > COUNTRY_NAME
*/
CREATE TABLE IF NOT EXISTS COUNTRY_T(
	COUNTRY_CODE_ID INT NOT NULL,
	COUNTRY_NAME VARCHAR(100),
	PRIMARY KEY (COUNTRY_CODE_ID)
);

/*
The VENDOR_T table is used to keep track of the different suppliers and their contact information. This is inherited by the all the products
tables

functional dependencies VENDOR_ID, VENDOR_NAME > ADDRESS, PHONE_NUM, EMAIL
*/
CREATE TABLE IF NOT EXISTS VENDOR_T(
	VENDOR_ID INT NOT NULL,
	VENDOR_NAME VARCHAR(100) NOT NULL,
	ADDRESS VARCHAR(100) NOT NULL,
	PHONE_NUM VARCHAR(50) NOT NULL,
	EMAIL VARCHAR(50) NOT NULL,
	PRIMARY KEY (VENDOR_ID)
);

/*
The TEA_CATEGORY_T keeps track of the different types of teas. This is inherited by the TEA_T table

functional dependencies CATE_NAME_ID > RECO_BREW_TEMP_F, RECO_BREW_TIME_SEC, RECO_POT_MATERIAL
*/

CREATE TABLE IF NOT EXISTS TEA_CATEGORY_T (
	CATE_NAME_ID VARCHAR(50) NOT NULL,
	RECO_BREW_TEMP_F INT NOT NULL,
	RECO_BREW_TIME_SEC INT NOT NULL,
	RECO_POT_MATERIAL VARCHAR (10),
	PRIMARY KEY (CATE_NAME_ID)
);

/*
The TEA_T table holds all the basic tea products. Inhereted by the TEA_MIX_T table

No functional dependencies
*/

CREATE TABLE IF NOT EXISTS TEA_T(
	PRODUCT_ID INT NOT NULL,
	TEA_NAME_ID VARCHAR(50) NOT NULL UNIQUE,
	CATE_NAME_ID VARCHAR(10) NOT NULL,
	DESCRIPTION VARCHAR(300),
	COUNTRY_ORIGIN INT NOT NULL,
	VENDOR_ID INT NOT NULL ,
	FOREIGN KEY (PRODUCT_ID, TEA_NAME_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	FOREIGN KEY (CATE_NAME_ID) REFERENCES TEA_CATEGORY_T(CATE_NAME_ID),
	FOREIGN KEY (COUNTRY_ORIGIN) REFERENCES COUNTRY_T(COUNTRY_CODE_ID),
	FOREIGN KEY (VENDOR_ID) REFERENCES VENDOR_T(VENDOR_ID),
	PRIMARY KEY(PRODUCT_ID, TEA_NAME_ID)
);

/*
The TEA_BLEND_T table holds the teas that are mixed together with different flavors. Inhereted by TEA_MIX_T and FLAVOR_MIX_T

functional dependencies: PROUDUCT_ID, BLEND_NAME_ID >RECO_BREW_TEMP_FTEMP, RECO_BREW_TIME_SEC, RECO_POT_MATERIAL 
*/
CREATE TABLE IF NOT EXISTS TEA_BLEND_T(
	PRODUCT_ID INT NOT NULL,
	BLEND_NAME_ID VARCHAR(50) NOT NULL UNIQUE,
	DESCRIPTION VARCHAR(300),
	RECO_BREW_TEMP_F INT NOT NULL,
	RECO_BREW_TIME_SEC INT NOT NULL,
	RECO_POT_MATERIAL VARCHAR (10),
	FOREIGN KEY (PRODUCT_ID, BLEND_NAME_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	PRIMARY KEY(PRODUCT_ID, BLEND_NAME_ID)
);

/*
The TEA_MIX_T contains whats teas a tea blend is made out up

Functional Dependencies TEA_PROD_ID, TEA_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID > TEA_QTY_OZ
*/

CREATE TABLE IF NOT EXISTS TEA_MIX_T(
	TEA_PROD_ID INT NOT NULL,
	TEA_NAME_ID VARCHAR(50) NOT NULL, 
	BLEND_PROD_ID INT NOT NULL,
	BLEND_NAME_ID VARCHAR(50) NOT NULL,
	TEA_QTY_OZ INT NOT NULL,
	FOREIGN KEY (TEA_PROD_ID, TEA_NAME_ID) REFERENCES TEA_T(PRODUCT_ID, TEA_NAME_ID),
	FOREIGN KEY (BLEND_PROD_ID, BLEND_NAME_ID) REFERENCES TEA_BLEND_T(PRODUCT_ID, BLEND_NAME_ID),
	PRIMARY KEY (TEA_PROD_ID, TEA_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID)
);

/*
FLAVOR_T contains the different flavor products

functional dependencies: PRODUCT_ID, FLAV_NAME_IDs
*/

CREATE TABLE IF NOT EXISTS FLAVOR_T(
	PRODUCT_ID INT NOT NULL,
	FLAV_NAME_ID VARCHAR(50),
	DESCRIPTION VARCHAR(300),
	VENDOR_ID INT NOT NULL,
	FOREIGN KEY (PRODUCT_ID, FLAV_NAME_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	FOREIGN KEY (VENDOR_ID) REFERENCES VENDOR_T(VENDOR_ID),
	PRIMARY KEY (PRODUCT_ID, FLAV_NAME_ID)
);

/*
FLAVOR_MIX_T contains what flavor is in what blend

Functional Dependencies FLAV_PROD_ID, FLAV_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID > FLAV_QTY_OZ
*/
CREATE TABLE IF NOT EXISTS FLAVOR_MIX_T(
	FLAV_PROD_ID INT NOT NULL,
	FLAV_NAME_ID VARCHAR(50) NOT NULL,
	BLEND_PROD_ID INT NOT NULL,
	BLEND_NAME_ID VARCHAR(50) NOT NULL,
	FLAVOR_QTY_OZ INT NOT NULL,
	FOREIGN KEY (FLAV_PROD_ID, FLAV_NAME_ID) REFERENCES  FLAVOR_T(PRODUCT_ID, FLAV_NAME_ID),
	FOREIGN KEY (BLEND_PROD_ID, BLEND_NAME_ID) REFERENCES TEA_BLEND_T(PRODUCT_ID, BLEND_NAME_ID),
	PRIMARY KEY (FLAV_PROD_ID, FLAV_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID)
);

/*
TEA_SET_T contains th different tea set products

PRODUCT_ID, SET_NAME_ID > MAKER, STYLE, MATERIAL, NUM_CUPS
*/
CREATE TABLE IF NOT EXISTS TEA_SET_T(
	PRODUCT_ID INT NOT NULL,
	SET_NAME_ID VARCHAR(50) NOT NULL,
	MAKER VARCHAR(50) NOT NULL,
	STYLE VARCHAR(50),
	MATERIAL VARCHAR(50),
	NUM_CUPS INT,
	DESCRIPTION VARCHAR(300),
	VENDOR_ID INT NOT NULL,
	FOREIGN KEY (PRODUCT_ID, SET_NAME_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	FOREIGN KEY (VENDOR_ID) REFERENCES VENDOR_T(VENDOR_ID),
	PRIMARY KEY (PRODUCT_ID, SET_NAME_ID)
);
/*
TEA_POT_T contains the different tea pot products

functional depenedencies: PRODUCT_ID, POT_MODEL_ID > MAKER, STYLE, MAKER, MATERIAL
*/
CREATE TABLE IF NOT EXISTS TEA_POT_T(
	PRODUCT_ID INT NOT NULL,
	POT_MODEL_ID VARCHAR(50) NOT NULL,
	MAKER VARCHAR(50),
	STYLE VARCHAR(50),
	MATERIAL VARCHAR(50),
	DESCRIPTION VARCHAR(300),
	VENDOR_ID INT NOT NULL,
	FOREIGN KEY (PRODUCT_ID, POT_MODEL_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	FOREIGN KEY (VENDOR_ID) REFERENCES VENDOR_T(VENDOR_ID),
	PRIMARY KEY (PRODUCT_ID, POT_MODEL_ID)
);
/*
MUG_T contains the different mug products

functional dependencies PRODUCT_ID, MUG_MODEL_ID > MAKER, MATERIAL
*/
CREATE TABLE IF NOT EXISTS MUG_T(
	PRODUCT_ID INT NOT NULL,
	MUG_MODEL_ID VARCHAR(50) NOT NULL,
	MAKER VARCHAR(50),
	MATERIAL VARCHAR(50),
	DESCRIPTION VARCHAR(300),
	VENDOR_ID INT NOT NULL,
	FOREIGN KEY (PRODUCT_ID, MUG_MODEL_ID) REFERENCES INVENTORY_T(PRODUCT_ID, NAME_ID),
	FOREIGN KEY (VENDOR_ID) REFERENCES VENDOR_T(VENDOR_ID),
	PRIMARY KEY (PRODUCT_ID, MUG_MODEL_ID)
);

/*
Data to be inserted into tables for testing purposes. Please note that this is purely test data! Accuracy concerning the data, 
such as brew time for green tea, or a countries code may not be on point!
*/

INSERT INTO TEA_CATEGORY_T(CATE_NAME_ID, RECO_BREW_TEMP_F, RECO_BREW_TIME_SEC, RECO_POT_MATERIAL)
	VALUES ('green tea', 175, 120, 'clay'),
		    ('oolong tea', 185, 180, 'ceramic'),
		    ('black tea', 212, 180, 'ceramic'),
			('white tea', 212, 180, 'clay');

INSERT INTO VENDOR_T(VENDOR_ID, VENDOR_NAME, ADDRESS, PHONE_NUM, EMAIL)
	VALUES (001, 'adaigo tea', '99 awesome rd NY, NY',1122334455, 'adaigo@email.com'),
			(002, 'teavana', '44 coolio rd NY, NY',1122334455, 'teavana@email.com'),
			(003, 'starbucks', '99 gross street ny, NY',1122334455, 'itastelikedirt@email.com'),
			(004, 'Links Pottery Shop', '99 Castle Town Hyrule, Hyrule',1122334455, 'heylisten@email.com'),
			(005, 'mi6', '85 Albert Embankment, London, United Kingdom',0800789321, 'mi6@email.com');
			
INSERT INTO COUNTRY_T(COUNTRY_CODE_ID, COUNTRY_NAME)
	VALUES (81, 'japan'),
			(86, 'china'),
			(886, 'taiwan');

INSERT INTO INVENTORY_T(PRODUCT_ID, NAME_ID, QTY, PRICEUSD)
	VALUES (0010, 'sencha', 100, 2.00),
			(0020, 'gunpowder', 0, 2.00),
			(0030, 'jasmine', 100, 2.00),
			(0040, 'samuri', 1, 2.00),
			(0050, 'da hong pao', 100, 3.00),
			(0060, 'oriental beuty', 100, 3.00),
			(0070, 'jade oolong', 0, 3.00),
			(0080, 'ti kaun yin', 100, 3.00),
			(0090, 'irish breakfast', 100, 2.5),
			(0100, 'black dragon', 13, 2.5),
			(0110, 'earl grey', 100, 2.5),
			(0120, 'cinnamon', 100, 2.5),
			(0130, 'blueberry', 11, 2.5),
			(0140, 'pomegranite', 15, 2.5),
			(0150, 'ginger root', 100, 2.5),
			(0160, 'coconut', 0, 2.5),
			(0170, 'tardis', 100, 2.5),
			(0180, 'harry potter', 100, 2.5),
			(0190, 'breaking bad', 100, 2.5),
			(0200, 'james bond', 6, 2.5),
			(0210, 'blend a', 3, 2.5),
			(0220, 'chinese set', 20, 100),
			(0230, 'japanese set', 20, 100),
			(0240, 'master set', 0, 100),
			(0250, 'chinese pot', 20, 30),
			(0260, 'japanese pot', 0, 30),
			(0270, 'master pot', 20, 30),
			(0280, 'chinese mug', 20, 10),
			(0290, 'japanese mug', 20, 10),
			(0300, 'master mug', 0, 10);
			
INSERT INTO TEA_T(PRODUCT_ID, TEA_NAME_ID, CATE_NAME_ID, DESCRIPTION, COUNTRY_ORIGIN, VENDOR_ID)
	VALUES (0010, 'sencha', 'green tea', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 81, 002),
			(0020, 'gunpowder', 'green tea', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',86, 002 ),
			(0030, 'jasmine', 'green tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 886, 001),
			(0040, 'samuri', 'green tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 81, 004),
			(0050, 'da hong pao', 'oolong tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 81, 001),
			(0060, 'oriental beuty', 'oolong tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 86, 003 ),
			(0070, 'jade oolong', 'oolong tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 886, 004),
			(0080, 'ti kaun yin', 'oolong tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 81, 004),
			(0090, 'irish breakfast', 'black tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 81, 001),
			(0100, 'black dragon', 'black tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 86, 002 ),
			(0110, 'earl grey', 'black tea','Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 886, 001);
			
INSERT INTO FLAVOR_T(PRODUCT_ID, FLAV_NAME_ID, DESCRIPTION, VENDOR_ID)
	VALUES (0130, 'blueberry', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 001),
			(0140, 'pomegranite', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 002),
			(0150, 'ginger root', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 003),
			(0160, 'coconut', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 004);
			

INSERT INTO TEA_BLEND_T(PRODUCT_ID, BLEND_NAME_ID, DESCRIPTION, RECO_BREW_TEMP_F, RECO_BREW_TIME_SEC, RECO_POT_MATERIAL)
	VALUES (0170, 'tardis', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 212, 180, 'porclein'),
			(0180, 'harry potter', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',212, 180, 'porclein'),
			(0190, 'breaking bad', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',175, 180, 'clay'),
			(0200, 'james bond', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',212, 180, 'porclein'),
			(0210, 'blend a', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 212, 180, 'porclein');

INSERT INTO TEA_MIX_T(TEA_PROD_ID, TEA_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID, TEA_QTY_OZ)
	VALUES (0110, 'earl grey', 0170, 'tardis', 4),
			(0070, 'jade oolong', 0170, 'tardis', 4),
			(0010, 'sencha', 0180, 'harry potter', 4),
			(0060, 'oriental beuty', 180, 'harry potter', 4),
			(0030, 'jasmine', 0190, 'breaking bad', 4),
			(0100, 'black dragon', 0190, 'breaking bad', 4),
			(0020, 'gunpowder', 0200, 'james bond', 4),
			(0110, 'earl grey', 0200, 'james bond', 4),
			(0090, 'irish breakfast', 0210, 'blend a', 4),
			(0080, 'ti kaun yin', 0210, 'blend a', 4);
			
INSERT INTO FLAVOR_MIX_T(FLAV_PROD_ID, FLAV_NAME_ID, BLEND_PROD_ID, BLEND_NAME_ID, FLAVOR_QTY_OZ)
	VALUES (0130, 'blueberry', 0170, 'tardis', 2),
			(0140, 'pomegranite', 180, 'harry potter', 2),
			(0150, 'ginger root', 0190, 'breaking bad', 2),
			(0130, 'blueberry', 0200, 'james bond', 4),
			(0160, 'coconut', 0210, 'blend a', 4);

INSERT INTO TEA_SET_T(PRODUCT_ID, SET_NAME_ID, MAKER, STYLE, MATERIAL, NUM_CUPS, DESCRIPTION, VENDOR_ID)
	VALUES (0220, 'chinese set', 'set makers', 'chinese', 'clay', 4, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 001),
			(0230, 'japanese set', 'set builders', 'japanese', 'porclein', 4, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 002),
			(0240, 'master set', 'set cookers', 'western', 'clay', 4, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 003);


INSERT INTO TEA_POT_T(PRODUCT_ID, POT_MODEL_ID, MAKER, STYLE, MATERIAL, DESCRIPTION, VENDOR_ID)
	values (0250, 'chinese pot', 'pot makers', 'chinese', 'clay', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 003),
			(0260, 'japanese pot', 'pot builders', 'japanese', 'glass', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 001),
			(0270, 'master pot', 'pot cookers', 'western', 'glass', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 002);

INSERT INTO MUG_T (PRODUCT_ID, MUG_MODEL_ID, MAKER, MATERIAL, DESCRIPTION, VENDOR_ID)
	VALUES (0280, 'chinese mug', 'mug makers', 'metal', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 003),
			(0290, 'japanese mug', 'mug builders', 'glass', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 001),
			(0300, 'master mug', 'mug cookers', 'glass', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', 002);			

		
--View all the items that are in stock, i.e QTY > 0
CREATE VIEW view_in_stock
AS
SELECT PRODUCT_ID AS "Product ID",
		NAME_ID AS "Name", 
		QTY AS "Qty"
FROM INVENTORY_T
WHERE QTY != 0
ORDER BY PRODUCT_ID ASC;

--View teas that not in stock and also display the suppliers contact information
CREATE VIEW view_tea_out_stock
AS
SELECT TEA_T.PRODUCT_ID AS "Product ID",
		TEA_T.TEA_NAME_ID AS "Name", 
		INVENTORY_T.QTY AS "Qty",
		TEA_T.VENDOR_ID AS "Supplier ID",
		VENDOR_T.PHONE_NUM AS "Supplier Phone Number",
		VENDOR_T.Email AS "Supplier Email"
FROM TEA_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=TEA_T.PRODUCT_ID)
		LEFT JOIN VENDOR_T ON (TEA_T.VENDOR_ID=VENDOR_T.VENDOR_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY TEA_T.PRODUCT_ID ASC;

--View tea sets that not in stock and also display the suppliers contact information
CREATE VIEW view_tea_set_out_stock
AS
SELECT TEA_SET_T.PRODUCT_ID AS "Product ID",
		TEA_SET_T.SET_NAME_ID AS "Name", 
		INVENTORY_T.QTY AS "Qty",
		TEA_SET_T.VENDOR_ID AS "Supplier ID",
		VENDOR_T.PHONE_NUM AS "Supplier Phone Number",
		VENDOR_T.Email AS "Supplier Email"
FROM TEA_SET_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=TEA_SET_T.PRODUCT_ID)
		LEFT JOIN VENDOR_T ON (TEA_SET_T.VENDOR_ID=VENDOR_T.VENDOR_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY TEA_SET_T.PRODUCT_ID ASC;

--View tea pots that not in stock and also display the suppliers contact information
CREATE VIEW view_tea_pot_out_stock
AS
SELECT TEA_POT_T.PRODUCT_ID AS "Product ID",
		TEA_POT_T.POT_MODEL_ID AS "Model", 
		INVENTORY_T.QTY AS "Qty",
		TEA_POT_T.VENDOR_ID AS "Supplier ID",
		VENDOR_T.PHONE_NUM AS "Supplier Phone Number",
		VENDOR_T.Email AS "Supplier Email"
FROM TEA_POT_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=TEA_POT_T.PRODUCT_ID)
		LEFT JOIN VENDOR_T ON (TEA_POT_T.VENDOR_ID=VENDOR_T.VENDOR_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY TEA_POT_T.PRODUCT_ID ASC;

--View mugs that not in stock and also display the suppliers contact information
CREATE VIEW view_mug_out_stock
AS
SELECT MUG_T.PRODUCT_ID AS "Product ID",
		MUG_T.MUG_MODEL_ID AS "Model", 
		INVENTORY_T.QTY AS "Qty",
		MUG_T.VENDOR_ID AS "Supplier ID",
		VENDOR_T.PHONE_NUM AS "Supplier Phone Number",
		VENDOR_T.Email AS "Supplier Email"
FROM MUG_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=MUG_T.PRODUCT_ID)
		LEFT JOIN VENDOR_T ON (MUG_T.VENDOR_ID=VENDOR_T.VENDOR_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY MUG_T.PRODUCT_ID ASC;

--View flavors that not in stock and also display the suppliers contact information
CREATE VIEW view_flavor_out_stock
AS
SELECT FLAVOR_T.PRODUCT_ID AS "Product ID",
		FLAVOR_T.FLAV_NAME_ID AS "Name", 
		INVENTORY_T.QTY AS "Qty",
		FLAVOR_T.VENDOR_ID AS "Supplier ID",
		VENDOR_T.PHONE_NUM AS "Supplier Phone Number",
		VENDOR_T.Email AS "Supplier Email"
FROM FLAVOR_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=FLAVOR_T.PRODUCT_ID)
		LEFT JOIN VENDOR_T ON (FLAVOR_T.VENDOR_ID=VENDOR_T.VENDOR_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY FLAVOR_T.PRODUCT_ID ASC;

--View tea blends that not in stock
CREATE VIEW view_tea_blend_out_stock
AS
SELECT TEA_BLEND_T.PRODUCT_ID AS "Product ID",
		TEA_BLEND_T.BLEND_NAME_ID AS "Name", 
		INVENTORY_T.QTY AS "Qty"
FROM TEA_BLEND_T 
		LEFT JOIN  INVENTORY_T ON (INVENTORY_T.PRODUCT_ID=TEA_BLEND_T.PRODUCT_ID)
WHERE INVENTORY_T.QTY=0		
ORDER BY TEA_BLEND_T.PRODUCT_ID ASC;

/* View Queries
select * from view_tea_out_stock;
select * from view_tea_set_out_stock;
select * from view_tea_pot_out_stock;
select * from view_mug_out_stock;
select * from view_flavor_out_stock;
select * from view_tea_blend_out_stock;


*/
--Get the ingredients for a tea blend
CREATE FUNCTION getblendingredients(blendname TEXT) 
returns table ("Blend Name" varchar(10), "Tea" varchar(10), "Tea QTY" int, "Flavoring" varchar(10), "Flavor QTY" int) AS $$
BEGIN
RETURN QUERY SELECT TEA_BLEND_T.BLEND_NAME_ID AS "Blend Name",
		
		TEA_MIX_T.TEA_NAME_ID AS "Tea", 
		
		TEA_MIX_T.TEA_QTY_OZ AS "Tea QTY",
		
		FLAVOR_MIX_T.FLAV_NAME_ID AS "Flavoring", 
		
		FLAVOR_MIX_T.FLAVOR_QTY_OZ AS "Flavoring QTY"
		
	FROM TEA_BLEND_T LEFT JOIN TEA_MIX_T ON (TEA_BLEND_T.BLEND_NAME_ID=TEA_MIX_T.BLEND_NAME_ID)
			 LEFT JOIN FLAVOR_MIX_T ON (TEA_MIX_T.BLEND_NAME_ID=FLAVOR_MIX_T.BLEND_NAME_ID)	
	WHERE TEA_BLEND_T.BLEND_NAME_ID=blendname;
END;
$$ LANGUAGE plpgsql;

--Update the qty of an item in the INVENTORY_T 
CREATE FUNCTION updateQTY(productID INT, sold INT)
returns table ("Product ID" int, "Product Name" varchar(20),"New Amount" int) AS $$
BEGIN
IF sold < 0 then
	RAISE NOTICE 'Number Sold may NOT be negative';
ELSE 	
UPDATE INVENTORY_T
			SET QTY= QTY - sold
			WHERE INVENTORY_T.PRODUCT_ID= productID;
RETURN QUERY SELECT INVENTORY_T.PRODUCT_ID AS "Product ID", 
					INVENTORY_T.NAME_ID AS "Product Name", 
					INVENTORY_T.QTY AS "New Amount"
				FROM INVENTORY_T
				WHERE INVENTORY_T.PRODUCT_ID=productID;
END IF;
END;
$$ LANGUAGE plpgsql;

--Insert a new record int Inventory_T
CREATE FUNCTION insertIntoInventory(productID INT, productName VARCHAR(20), amount int, price int)
returns table ("Product ID" int, "Product Name" varchar(20),"QTY" int, "Price" int) AS $$
BEGIN	
INSERT INTO INVENTORY_T(PRODUCT_ID, NAME_ID, QTY, PRICEUSD)
				VALUES (productID, productName, amount, price);
RETURN QUERY SELECT INVENTORY_T.PRODUCT_ID AS "Product ID", 
					INVENTORY_T.NAME_ID AS "Product Name", 
					INVENTORY_T.QTY AS "QTY",
					INVENTORY_T.PRICEUSD AS "PriceUSD"
				FROM INVENTORY_T
				WHERE INVENTORY_T.PRODUCT_ID=productID;
END;
$$ LANGUAGE plpgsql;

--Creates an admin role with password alpaca

CREATE ROLE admin WITH LOGIN PASSWORD 'alpaca';
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA PUBLIC
TO admin;

CREATE ROLE employee WITH LOGIN PASSWORD 'password';
GRANT SELECT, INSERT, UPDATE
ON ALL TABLES IN SCHEMA PUBLIC
TO employee;

CREATE ROLE guest LOGIN; 
GRANT SELECT
ON  TEA_T, FLAVOR_T, TEA_BLEND_T, TEA_SET_T, TEA_POT_T, MUG_T
TO guest;
/*

--Get all the recommend materials for all the teas, and match them with a pot that made out of that recommend material.
SELECT TEA_T.TEA_NAME_ID, TEA_CATEGORY_T.RECO_POT_MATERIAL, TEA_POT_T.POT_MODEL_ID
FROM TEA_T LEFT JOIN TEA_CATEGORY_T ON (TEA_T.CATE_NAME_ID=TEA_CATEGORY_T.CATE_NAME_ID)
			LEFT JOIN TEA_POT_T ON (TEA_POT_T.MATERIAL=TEA_CATEGORY_T.RECO_POT_MATERIAL);

--Get all the green teas and their country of origin
SELECT TEA_T.TEA_NAME_ID AS "Tea Name",
		TEA_T.COUNTRY_ORIGIN AS "Country of Origin"
FROM TEA_T
WHERE TEA_T.CATE_NAME_ID = 'green tea';

--Get all the oolong teas and their country of origin
SELECT TEA_T.TEA_NAME_ID AS "Tea Name",
		TEA_T.COUNTRY_ORIGIN AS "Country of Origin"
FROM TEA_T
WHERE TEA_T.CATE_NAME_ID = 'oolong tea';

--Get all the black teas and their country of origin
SELECT TEA_T.TEA_NAME_ID AS "Tea Name",
		TEA_T.COUNTRY_ORIGIN AS "Country of Origin"
FROM TEA_T
WHERE TEA_T.CATE_NAME_ID = 'black tea';

--Get all the green teas and their country of origin
SELECT TEA_T.TEA_NAME_ID AS "Tea Name",
		TEA_T.COUNTRY_ORIGIN AS "Country of Origin"
FROM TEA_T
WHERE TEA_T.CATE_NAME_ID = 'white tea';
*/

--Display an error message if Combination of Product ID and Name ID, already exists--
CREATE OR REPLACE FUNCTION message()
returns trigger AS $message$
BEGIN
	IF EXISTS (SELECT PRODUCT_ID, NAME_ID FROM INVENTORY_T WHERE PRODUCT_ID=NEW.PRODUCT_ID AND NAME_ID=NEW.NAME_ID) THEN
	RAISE EXCEPTION 'Combination of Product ID and Name ID, already exists';
	END IF;
RETURN NEW;
END;
$message$
 LANGUAGE plpgsql;

--Execute Function 'message()' before a new item is added to the INVENTORY_T table.
CREATE TRIGGER check_insert BEFORE INSERT 
ON INVENTORY_T
 FOR EACH ROW  EXECUTE PROCEDURE message();










