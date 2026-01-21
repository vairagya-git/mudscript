/* 
Upload stock sector data from csv file 
upload_stock_sector
*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/stock_sector.csv'
INTO TABLE upload_stock_sector
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@sector, @stockTicker)
SET
  sector     = NULLIF(@sector, ''),
  stockTicker     = NULLIF(@stockTicker, '');
  
/* Populate Sector Stock Data */
INSERT IGNORE INTO mud.sector_stock (sector_id, stock_id)
SELECT DISTINCT se.id AS sector_id, s.id AS stock_id
FROM mud.upload_stock_sector uss
JOIN mud.stock s ON s.ticker = trim(uss.stockTicker)
JOIN mud.sector se ON se.code = uss.sector
/*** *** *** *** *** *** *** *** *** *** *** ***/

UPLOAD WATCHLIST STOCK FROM CSV TO DB. 

/*** *** *** *** *** *** *** *** *** *** *** ***/
/* 
Upload watchlist and stock data from csv file 
upload_watchlist_stock
*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/watch_list_stock.csv'
INTO TABLE upload_watchlist_stock
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@watchlist, @stock, @country)
SET
  watchlist     = NULLIF(@watchlist, ''),
  stock     = NULLIF(@stock, ''),
  country     = NULLIF(@country, '');
  
select * from watchlist;

  /* Populate Watchlist Data */
INSERT IGNORE INTO mud.watchlist_stock (watchlist_id, stock_id)
SELECT DISTINCT  w.id AS watchlistid, s.id AS stockid
FROM mud.upload_watchlist_stock uws
JOIN mud.stock s ON s.ticker = trim(uws.stock)
JOIN mud.watchlist w ON w.code = uws.watchlist
WHERE uws.watchlist IS NOT NULL
  AND uws.stock IS NOT NULL;
/*** *** *** *** *** *** *** *** *** *** *** ***/


/*** *** *** *** *** *** *** *** *** *** *** ***/
/* 
Upload upcoming earning date
upload_earnings_upcoming
*/

LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/earnings/earnings_jan_2026.csv'
INTO TABLE upload_earnings_upcoming_date
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker, @quarter, @time, @earningsDate)
SET
  ticker     = NULLIF(@ticker, ''),
  quarter     = NULLIF(@quarter, ''),
  time     = NULLIF(@time, ''),
  earnings_date     = STR_TO_DATE(@earningsDate, '%d-%b-%Y');
  
/* Insert into fund_manager with cik value */
INSERT IGNORE INTO mud.earnings_upcoming_dates (ticker, earnings_date, quarter, time, stock_id)
SELECT DISTINCT  ueud.ticker, ueud.earnings_date, ueud.quarter, ueud.time, s.id
FROM mud.upload_earnings_upcoming_date ueud
JOIN mud.stock s ON s.ticker = trim(ueud.ticker)
WHERE ueud.ticker IS NOT NULL
  AND ueud.earnings_date IS NOT NULL;
  
/* Update the missing stock in upload_earnings_upcoming_date */  
UPDATE upload_earnings_upcoming_date ueud
LEFT JOIN stock s ON s.ticker = ueud.ticker
SET ueud.missingStock = CASE
  WHEN s.id IS NULL THEN 1
  ELSE 0
END;
/*** *** *** *** *** *** *** *** *** *** *** ***/



/*** *** *** *** *** *** *** *** *** *** *** ***/
/* 
Upload stock inside details. 
TABLE: upload_stock_inside_details
*/
/*** *** *** *** *** *** *** *** *** *** *** ***/

LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/inside_details/stock_inside_details.csv'
INTO TABLE upload_stock_inside_details
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker,@seqNo,@newsDate,@code,@details)
SET
  ticker     = NULLIF(@ticker, ''),
  seqNo	= NULLIF(@seqNo, ''),
  newsDate     =  STR_TO_DATE(@newsDate, '%d-%b-%Y'),
  code     = NULLIF(@code, ''),
  details     = NULLIF(@details, '');

delete from upload_stock_inside_details;

/* Insert into stock_inside_details */
/* Insert earnings data to db earnings_data */
INSERT IGNORE INTO mud.stock_inside_details (upload_stock_inside_details_id, ticker, newsDate, code, details, seqNo)
SELECT DISTINCT  usid.id, usid.ticker, usid.newsDate, usid.code, usid.details, usid.seqNo
FROM mud.upload_stock_inside_details usid
WHERE usid.ticker IS NOT NULL; 

select * from stock_inside_details;

select * from upload_stock_inside_details;

/* Insert stock and stock_inside_details_stock mapping */
INSERT IGNORE INTO mud.stock_inside_details_stock
(stock_id, stock_inside_details_id)
SELECT
  s.id,
  sid.id
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
JOIN mud.stock_inside_details sid 
	ON sid.upload_stock_inside_details_id = usid.id
WHERE usid.ticker IS NOT NULL
  AND usid.ticker <> '';

/* Check it out here */
select * from mud.stock_inside_details_stock as sids 
JOIN mud.stock s ON s.id = sids.stock_id
JOIN mud.stock_inside_details sid ON sid.id = sids.stock_inside_details_id ;

/* Insert master table record table_filter_master */
/* code */
INSERT IGNORE INTO mud.table_filter_master (table_name, field_name, filter_value)
SELECT DISTINCT  "stock_inside_details", "code", code
FROM mud.upload_stock_inside_details ;

/* analystSource */
INSERT IGNORE INTO mud.table_filter_master (table_name, field_name, filter_value)
SELECT DISTINCT  "stock_inside_details", "analystSource", analystSource
FROM mud.upload_stock_inside_details ;
/*** *** *** *** *** *** *** *** *** *** *** ***/


/*** *** *** *** *** *** *** *** *** *** *** ***/
/* 
Upload stock inside details. 
TABLE: upload_fund_manager_stock_inside_details
*/
/*** *** *** *** *** *** *** *** *** *** *** ***/

LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/inside_details/fund_manager_stock_inside_details.csv'
INTO TABLE upload_fund_manager_stock_inside_details
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker, @seqNo, @newsDate, @code, @manager_search_code, @manager_people_search_code, @details)
SET
  ticker     = NULLIF(@ticker, ''),
  seqNo     = NULLIF(@seqNo, ''),
  newsDate     =  STR_TO_DATE(@newsDate, '%d-%b-%Y'),
  code     = NULLIF(@code, ''),
  manager_search_code     = NULLIF(@manager_search_code, ''),
  manager_people_search_code     = NULLIF(@manager_people_search_code, ''),
  details     = NULLIF(@details, '');

/* Insert into fund_manager_insight */
INSERT IGNORE INTO mud.fund_manager_insight (ufmsid_id, ticker, seqNo, newsDate, code, details)
SELECT DISTINCT  ufmsid.id, ufmsid.ticker, ufmsid.seqNo, ufmsid.newsDate, ufmsid.code, ufmsid.details
FROM mud.upload_fund_manager_stock_inside_details ufmsid
WHERE ufmsid.ticker IS NOT NULL; 

/* update  fund_manager_insight.fund_manager_id */
UPDATE mud.fund_manager_insight fmi 
JOIN mud.upload_fund_manager_stock_inside_details ufmsid on fmi.ufmsid_id = ufmsid.id
JOIN mud.fund_manager fm on ufmsid.manager_search_code = fm.search_code
SET fmi.fund_manager_id = fm.id;

/* update  fund_manager_insight.fund_manager_people_id */
UPDATE mud.fund_manager_insight fmi 
JOIN mud.upload_fund_manager_stock_inside_details ufmsid on fmi.ufmsid_id = ufmsid.id
JOIN mud.fund_manager_people fmp on ufmsid.manager_people_search_code = fmp.search_code
SET fmi.fund_manager_people_id = fmp.id;

/* Insert into fund_manager_insight */
select * from mud.fund_manager_insight fmi 
JOIN mud.upload_fund_manager_stock_inside_details ufmsid on fmi.ufmsid_id = ufmsid.id
JOIN mud.fund_manager_people fmp on trim(ufmsid.manager_people_search_code) = trim(fmp.search_code);

/* Insert stock and stock_inside_details_stock mapping */
INSERT IGNORE INTO mud.fund_manager_insight_stock
(stock_id, fund_manager_insight_id)
SELECT
  s.id,
  fmi.id
FROM mud.upload_fund_manager_stock_inside_details ufmsid
JOIN JSON_TABLE(
  CONCAT(
    '["',
    REPLACE(
      REPLACE(TRIM(TRAILING ';' FROM ufmsid.ticker), ' ', ''),
      ',','","'
    ),
    '"]'
  ),
  '$[*]' COLUMNS (ticker VARCHAR(32) PATH '$')
) jt
JOIN mud.stock s
  ON s.ticker = jt.ticker
JOIN mud.fund_manager_insight fmi 
	ON fmi.ufmsid_id = ufmsid.id
WHERE ufmsid.ticker IS NOT NULL
  AND ufmsid.ticker <> '';
/*** *** *** *** *** *** *** *** *** *** *** ***/


/*** *** *** *** *** *** *** *** *** *** *** ***/
/* 
Upload past earning data & price reflection.
upload_earnings_data
*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/stock_earnings_history.csv'
INTO TABLE upload_earnings_data
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker, @earningsDate, @stockPriceSOD, @stockPriceEOD, @stockPriceEO2Ds, @stockPriceEOW, @stockPriceEO2Ws, @movement, @supriseEarning, @supriseRevenue)
SET
  ticker     = NULLIF(@ticker, ''),
  earnings_date     =  STR_TO_DATE(@earningsDate, '%d-%b-%Y'), 
  stockPriceSOD      = CASE
                  WHEN NULLIF(@stockPriceSOD, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@stockPriceSOD, ',', '')  AS DECIMAL(20,2))
                END,
  stockPriceEOD      = CASE
                  WHEN NULLIF(@stockPriceEOD, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@stockPriceEOD, ',', '')  AS DECIMAL(20,2))
                END,
  stockPriceEO2Ds      = CASE
                  WHEN NULLIF(@stockPriceEO2Ds, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@stockPriceEO2Ds, ',', '')  AS DECIMAL(20,2))
                END,
  stockPriceEOW      = CASE
                  WHEN NULLIF(@stockPriceEOW, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@stockPriceEOW, ',', '')  AS DECIMAL(20,2))
                END,
  stockPriceEO2Ws      = CASE
                  WHEN NULLIF(@stockPriceEO2Ws, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@stockPriceEO2Ws, ',', '')  AS DECIMAL(20,2))
                END,
 movement     = NULLIF(@movement, ''),
 supriseEarning     = NULLIF(@supriseEarning, ''),
 supriseRevenue     = NULLIF(@supriseRevenue, '');

/* Insert earnings data to db earnings_data */
INSERT IGNORE INTO mud.earnings_data (stock_id, ticker, earnings_date, stockPriceSOD, stockPriceEOD, stockPriceEO2Ds, stockPriceEOW, stockPriceEO2Ws, movement, supriseEarning, supriseRevenue)
SELECT DISTINCT  s.id, ued.ticker, ued.earnings_date, ued.stockPriceSOD, ued.stockPriceEOD, ued.stockPriceEO2Ds, ued.stockPriceEOW, ued.stockPriceEO2Ws, ued.movement, ued.supriseEarning, ued.supriseRevenue
FROM mud.upload_earnings_data ued
JOIN mud.stock s ON s.ticker = trim(ued.ticker)
WHERE ued.ticker IS NOT NULL
  AND ued.earnings_date IS NOT NULL;
  


/*** *** *** *** *** *** *** *** *** *** *** ***/



/*** *** *** *** *** *** *** *** *** *** *** ***/  
/* Load 13f stock data from csv file */
/* 
STEPS 

1. Go to https://13f.info/ search by ticket. 
2. then from debug network get the json data, the url has cusip something like this https://13f.info/data/cusip/732908108/2025/3
3. Use AI chat to extra the data in the right format. Fef one of the file in 13f_stock_holding for format. So fields are ; separated
4. Search and remove any "\;"
5. Change the ticker, quarter value in the below script  
      "ticker 	  = 'NVDA' "
      "quarter 	  = 'Q32025' "
6. Run the sql script below. 

*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/13f_stock_holding/PONY_Q3_2025_all.csv'
INTO TABLE upload_13f_stock_data
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@manager, @cik, @reportDate, @value, @shares, @optionType, @cusip)
SET
  manager     = NULLIF(@manager, ''),
  cik     = NULLIF(@cik, ''),
  reportDate  = CASE
                  WHEN NULLIF(@reportDate, '') IS NULL THEN NULL
                  ELSE STR_TO_DATE(@reportDate, '%m/%d/%Y')
                END,
  value       = CASE
                  WHEN NULLIF(@value, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@value, ',', '') * 1000 AS DECIMAL(20,0))
                END,
  shares      = CASE
                  WHEN NULLIF(@shares, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@shares, ',', '')  AS DECIMAL(20,0))
                END,
  optionType  = NULLIF(@optionType, ''),
  cusip       = NULLIF(@cusip, ''),
  ticker 	  = 'NVDA',
  quarter 	  = 'Q32025',
  created_at  = NOW();
  /*** *** *** *** *** *** *** *** *** *** *** ***/
  
  
/*** *** *** *** *** *** *** *** *** *** *** ***/
/* Load 13f manager data from csv file */
/* 
STEPS 
1. Go to https://13f.info/ search by ticket. 
2. then from debug network get the json data, the url has cusip something like this https://13f.info/data/13f/000201238325002949
3. Use AI chat to extra the data in the right format. Fef one of the file in 13f_manager for format. So fields are ; separated
4. Search and remove any "\;"
5. Change the manager, cik, quarter value in the below script  
        manager 	  = 'BlackRock, Inc',
        cik 	  = '0002012383',
        quarter 	  = 'Q32025',
6. Run the sql script below. 

*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/13f_manager/toyota_Q3_2025.csv'
INTO TABLE upload_13f_manager_data
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker, @stockName, @cl, @cusip, @value, @percentage, @shares, @principal, @optionType)
SET
  ticker     	= @ticker,
  stockName     = @stockName,
  cl 			= @cl,
  cusip       	= @cusip,
  value       = CASE
                  WHEN NULLIF(@value, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@value, ',', '') * 1000 AS DECIMAL(20,0))
                END,
  percentage  = CASE
                  WHEN NULLIF(@percentage, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@percentage, ',', '') * 1000 AS DECIMAL(20,2))
                END,
  shares      = @shares,
  principal   = CASE
                  WHEN NULLIF(@principal, '') IS NULL THEN NULL
                  ELSE CAST(REPLACE(@principal, ',', '') * 1000 AS DECIMAL(20,0))
                END,
  optionType  = NULLIF(@optionType, ''),
  manager 	  = 'TOYOTA MOTOR CORP',
  cik 	  = '0001094517',
  quarter 	  = 'Q32025',
  created_at  = NOW();

/* Insert into fund_manager with cik value */
INSERT IGNORE INTO mud.fund_manager (name, cik)
SELECT DISTINCT  u1md.manager AS manager, u1md.cik AS cik
FROM mud.upload_13f_manager_data as u1md;


/* Insert into fund_manager with cik value */
INSERT IGNORE INTO mud.stock (ticker, cusip, cl, name)
SELECT DISTINCT  u1md.ticker AS ticker, u1md.cusip AS cusip, u1md.cl as cl, u1md.stockName as name
FROM mud.upload_13f_manager_data as u1md;
/*** *** *** *** *** *** *** *** *** *** *** ***/

  




/* Insert Sector */
insert into sector(code, name) values ("TECHNOLOGY", "TECHNOLOGY STOCK");
insert into sector(code, name) values ("SEMI_CONDUCTOR", "SEMI CONDUCTOR STOCK");
insert into sector(code, name) values ("AI", "AI STOCK");
insert into sector(code, name) values ("FINANCE_TECH", "FINANCE TECHNOLOGY STOCK");
insert into sector(code, name) values ("HEALTHCARE", "HEALTH CARE STOCK");
insert into sector(code, name) values ("ENERGY", "ENERGY STOCK");
insert into sector(code, name) values ("REAL_ESTATE", "REAL ESTATE STOCK");
insert into sector(code, name) values ("REAL_ESTATE_TECH", "REAL ESTATE TECH STOCK");
insert into sector(code, name) values ("COMMUNICATION_SERVICES", "COMMUNICATION SERVICE STOCK");
insert into sector(code, name) values ("EV", "ELECTRIC AUTOMOTIVE");
insert into sector(code, name) values ("AUTOMOTIVE", "AUTOMOTIVE");



/*** *** *** *** *** *** *** *** *** *** *** ***/
/* Load Manager People Ticker relationship  */
/* 
STEPS 
1. Go to https://13f.info/ search by ticket. 
2. then from debug network get the json data, the url has cusip something like this https://13f.info/data/13f/000201238325002949
3. Use AI chat to extra the data in the right format. Fef one of the file in 13f_manager for format. So fields are ; separated
4. Search and remove any "\;"
5. Change the manager, cik, quarter value in the below script  
        manager 	  = 'BlackRock, Inc',
        cik 	  = '0002012383',
        quarter 	  = 'Q32025',
6. Run the sql script below. 

*/  
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/fund_manager/temp_fund_manager_stock_ticker_KEYBANC.csv'
INTO TABLE upload_manager_people_ticker
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\r\n'
IGNORE 1 LINES
(@managerName, @search_code, @ticker)
SET
  managerName     	= @managerName,
  search_code     	= @search_code,
  ticker 			= @ticker,
  created_at  = NOW();

/* Insert into fund_manager with cik value */
INSERT IGNORE INTO mud.fund_manager_people_stock (fund_manager_people_id, stock_id)
SELECT fmp.id, s.id
FROM mud.upload_manager_people_ticker as umpt
JOIN mud.fund_manager_people fmp ON fmp.name = umpt.managerName
JOIN mud.stock s ON s.ticker = trim(umpt.ticker);

/* Missing Ticker in Stock DB */

UPDATE upload_manager_people_ticker umpt
LEFT JOIN stock s ON s.ticker = umpt.ticker
SET umpt.missingStock = CASE
  WHEN s.id IS NULL THEN 1
  ELSE 0
END;


select * from upload_manager_people_ticker where missingStock = 1 ;

select * from stock where ticker = "KLAC"

/*** *** *** *** *** *** *** *** *** *** *** ***/







select * from upload_stock_sector;

select * from stock where ticker like "%AAPL%"


select * from  upload_13f_stock_data where ticker = "NVDA";

select * from  upload_13f_manager_data;

select count(*) from stock;

delete from watchlist_stock;
  
  /* NEXT */
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';
  
select * from  upload_13f_stock_data where cusip is null;

select * from upload_earnings_upcoming;

select s.ticker from stock as s
join watchlist_stock ws on s.id = ws.stock_id
join watchlist w on ws.watchlist_id = w.id
where w.code = "52_WEEK_2025"

select * from watchlist;

select * from filing_13f_holding;

select * from  upload_13f_stock_data
where manager like "Toyota%";

select * from earnings_upcoming;


drop table sector_stock;
drop table stock;
drop table watchlist_stock;
drop table filing_13f_holding;


select * from earnings_upcoming_dates
where earnings_date > "2026-01-01"

delete from earnings_upcoming_dates
where earnings_date < "2026-01-01"

select * from watchlist



select * from stock
where ticker = "INFY";


select * from fund_manager where name like "%antor%"