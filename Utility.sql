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


select * from mud.stock where ticker in ("IONQ","RGTI", "PLD")

MY_INVESTIGATE


select * from fund_manager




ticker, name, cl, cusip


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