SET GLOBAL local_infile = 1;
SET SESSION local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/stock.csv'
INTO TABLE mud.stock
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ticker, name, cl, cusip)
SET created_at = NOW(), updated_at = NOW();

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';
SELECT VERSION();

SHOW GLOBAL VARIABLES LIKE 'secure_file_priv';

SHOW SESSION VARIABLES LIKE 'local_infile';


select * from mud.stock where ticker in ("IONQ","RGTI", "PLD");

select * from stock_inside_details;

select * from upload_stock_inside_details usid where usid.id = 25;

INSERT IGNORE INTO mud.stock_inside_details
(upload_stock_inside_details_id, ticker, newsDate, code, analystSource, details)
SELECT
  usid.id,
  jt.ticker,
  usid.newsDate,
  usid.code,
  usid.analystSource,
  usid.details
FROM mud.upload_stock_inside_details usid
JOIN JSON_TABLE(
  CONCAT(
    '["',
    REPLACE(
      REPLACE(TRIM(TRAILING ';' FROM usid.ticker), ' ', ''),
      ',','","'
    ),
    '"]'
  ),
  '$[*]' COLUMNS (ticker VARCHAR(32) PATH '$')
) jt
JOIN mud.stock s
  ON s.ticker = jt.ticker
WHERE usid.ticker IS NOT NULL
  AND usid.ticker <> ''
  AND usid.id = 25;


CREATE TABLE stock_inside_details_stock (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  stock_inside_details_id BIGINT UNSIGNED NOT NULL,
  stock_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

select * from fund_manager_people;

KEYBANC_JohnVinh
KEYBANC_JustinPatterson
KEYBANC_BrandonNispel
KEYBANC_AlexMarkgraff
KEYBANC_EricHeath
KEYBANC_JasonCelino
KEYBANC_JacksonAder

select * from upload_fund_manager_stock_inside_details;

select * from fund_manager_people

select * from stock where ticker = "NOSTOCK"

SELECT DISTINCT 
  *
FROM fund_manager_insight fmi
JOIN fund_manager_people fmp
  ON fmp.id = fmi.fund_manager_people_id
JOIN fund_manager fm 
  ON fm.id = fmi.fund_manager_id
JOIN fund_manager_insight_stock fmis
  ON fmis.fund_manager_insight_id = fmi.id
JOIN stock s
  ON fmis.stock_id = s.id
LEFT JOIN watchlist_stock ws
  ON ws.stock_id = s.id
LEFT JOIN watchlist w
  ON w.id = ws.watchlist_id
WHERE s.ticker = "NOSTOCK"
  [[ AND fm.search_code IN ({{variable_manager_search_code}}) ]]
  [[ AND fmp.search_code IN ({{variable_manager_people_search_code}}) ]]
LIMIT 1048575;

alter table `upload_stock_inside_details`
ADD column `seqNo` bigint unsigned default NULL;

ALTER TABLE mud.stock_inside_details
DROP INDEX unique_stock_inside_details;

ALTER TABLE mud.stock_inside_details
ADD CONSTRAINT unique_stock_inside_details
UNIQUE (ticker, newsDate, code, analystSource, seqNo);

delete from stock_inside_details_stock

ADD column `focus_area` varchar(256) default NULL;

alter table `fund_manager_people`
MODIFY COLUMN focus_area ENUM('SEMICONDUCTOR', 'INTERNET_DIGITAL_MEDIA_AND_TRAVEL', 'COMMUNICATIONS_SERVICES', 'FINTECH', 'SECURITY_SOFTWARE', 'ENTERPRISE_SOFTWARE', 'VERTICAL_SOFTWARE') NOT NULL;



*** To upload file from MYSQL Workbench, Do the following. 

* settings
1. Open Workbench → Home
2. Right-click your MySQL connection → Edit Connection
3. Click Advanced
4. Add this in the "Others" box: OPT_LOCAL_INFILE=1


Query should be like this.   LOAD DATA LOCAL INFILE '/Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/stock.csv'
INTO TABLE mud.stock
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ticker, name, cl, cusip)
SET created_at = NOW(), updated_at = NOW();