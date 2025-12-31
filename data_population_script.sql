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
Upload upcoming earning data
upload_earnings_upcoming
*/
  
LOAD DATA LOCAL INFILE '//Users/rama/Library/Mobile Documents/com~apple~CloudDocs/Mud/data/stock_upcoming_earnings.csv'
INTO TABLE upload_earnings_upcoming
CHARACTER SET utf8mb4
FIELDS
  TERMINATED BY ';'
  OPTIONALLY ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES
(@ticker, @earningsDate)
SET
  ticker     = NULLIF(@ticker, ''),
  earnings_date     = NULLIF(@earningsDate, '');

/* Insert into fund_manager with cik value */
INSERT IGNORE INTO mud.earnings_upcoming (ticker, earnings_date)
SELECT DISTINCT  ticker, earnings_date
FROM mud.upload_earnings_upcoming
WHERE ticker IS NOT NULL
  AND earnings_date IS NOT NULL;
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

select * from watchlist;

select * from filing_13f_holding;

select * from  upload_13f_stock_data
where manager like "Toyota%";

select * from earnings_upcoming;


drop table sector_stock;
drop table stock;
drop table watchlist_stock;
drop table filing_13f_holding;