CREATE TABLE `earnings_upcoming_dates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stock_id` bigint unsigned NOT NULL,
  `ticker` varchar(255) DEFAULT NULL,
  `quarter` varchar(64) DEFAULT NULL,
  `time` varchar(64) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_earnings_upcoming_dates` (`stock_id`),
  CONSTRAINT `fk_earnings_upcoming_dates` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`,`stock_id`, `earnings_date`)
) ENGINE=InnoDB;

CREATE TABLE `earnings_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stock_id` bigint unsigned NOT NULL,
  `ticker` varchar(255) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  `stockPriceSOD` decimal(20,2) DEFAULT NULL,
  `stockPriceEOD` decimal(20,2) DEFAULT NULL,
  `stockPriceEO2Ds` decimal(20,2) DEFAULT NULL,
  `stockPriceEOW` decimal(20,2) DEFAULT NULL,
  `stockPriceEO2Ws` decimal(20,2) DEFAULT NULL,
  `movement` varchar(64) DEFAULT NULL,
  `supriseEarning` varchar(32) DEFAULT NULL,
  `supriseRevenue` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_earnings_data` (`stock_id`),
  CONSTRAINT `fk_earnings_data` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`,`stock_id`, `earnings_date`)
) ENGINE=InnoDB;

CREATE TABLE `split_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stock_id` bigint unsigned NOT NULL,
  `ticker` varchar(255) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  `priceBeforeSplit` decimal(20,2) DEFAULT NULL,
  `priceAfterSplit` decimal(20,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`, `stock_id`, `earnings_date`)
) ENGINE=InnoDB;

CREATE TABLE `stock_inside_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `upload_stock_inside_details_id` bigint unsigned NOT NULL,
  `ticker` varchar(255) DEFAULT NULL,
  `newsDate` date NOT NULL,
  `code` varchar(64) NOT NULL,
  `analystSource` varchar(64) NOT NULL,
  `details` varchar(255) NOT NULL,
  `seqNo` bigint unsigned default NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_stock_inside_details UNIQUE (`ticker`,`newsDate`,`code`,`analystSource`,`seqNo`)
) ENGINE=InnoDB;

CREATE TABLE stock_inside_details_stock (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  stock_inside_details_id BIGINT UNSIGNED NOT NULL,
  stock_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  UNIQUE KEY uq_stock_inside_details_stock (stock_inside_details_id, stock_id),

  CONSTRAINT fk_stock_inside_details
    FOREIGN KEY (stock_inside_details_id) REFERENCES stock_inside_details(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_stock_inside_details_stock
    FOREIGN KEY (stock_id) REFERENCES stock(id)
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE `filing_13f` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `fund_manager_id` bigint unsigned NOT NULL,
  `accession_number` varchar(50) NOT NULL,
  `form_type` varchar(20) DEFAULT '13F-HR',
  `filing_date` date NOT NULL,
  `period_end` date NOT NULL,
  `total_value` decimal(20,2) DEFAULT NULL,
  `number_of_positions` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_filing_fund_manager` (`fund_manager_id`),
  CONSTRAINT `fk_filing_fund_manager` FOREIGN KEY (`fund_manager_id`) REFERENCES `fund_manager` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `filing_13f_holding` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `filing_13f_id` bigint unsigned NOT NULL,
  `stock_id` bigint unsigned DEFAULT NULL,
  `ticker` varchar(32) DEFAULT NULL,
  `name_of_issuer` varchar(255) NOT NULL,
  `title_of_class` varchar(255) NOT NULL,
  `cusip` char(9) NOT NULL,
  `figi` varchar(32) DEFAULT NULL,
  `value` decimal(20,2) NOT NULL,
  `shares` bigint unsigned NOT NULL,
  `per_share_value` decimal(20,8) NOT NULL,
  `prn_amt` bigint unsigned NOT NULL,
  `prn` varchar(8) NOT NULL,
  `put_call` varchar(4) DEFAULT NULL,
  `investment_discretion` varchar(32) DEFAULT NULL,
  `manager` varchar(255) DEFAULT NULL,
  `sole` bigint unsigned NOT NULL DEFAULT '0',
  `shared` bigint unsigned NOT NULL DEFAULT '0',
  `none` bigint unsigned NOT NULL DEFAULT '0',
  `quarter` varchar(16) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_filing_13f_holding_filing` (`filing_13f_id`),
  KEY `fk_filing_13f_holding_stock` (`stock_id`),
  CONSTRAINT `fk_filing_13f_holding_filing` FOREIGN KEY (`filing_13f_id`) REFERENCES `filing_13f` (`id`),
  CONSTRAINT `fk_filing_13f_holding_stock` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `fund_manager` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `cik` varchar(20) NOT NULL,
  `manager_type` varchar(100) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `search_code` varchar(128) DEFAULT NULL,
  `investment_areas` varchar(512) NOT NULL,
  `13f_name` varchar(256) DEFAULT NULL,
  `former_name` varchar(256) DEFAULT NULL,
  `former_cik` varchar(256) DEFAULT NULL,
  `website_url` varchar(256) default NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_cik` (`cik`)
) ENGINE=InnoDB;

CREATE TABLE `fund_manager_people` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `fund_manager_id` bigint unsigned DEFAULT NULL,
  `reputation` ENUM('SPOTON', 'HIGH', 'MODERATE', 'OCCASSIONAL', 'RANDOM'),
  `website_url` varchar(256) default NULL,
  `search_code` varchar(128) DEFAULT NULL,
  `focus_area`  ENUM('SEMICONDUCTOR', 'INTERNET_DIGITAL_MEDIA_AND_TRAVEL', 'COMMUNICATIONS_SERVICES', 'FINTECH', 'SECURITY_SOFTWARE', 'ENTERPRISE_SOFTWARE', 'VERTICAL_SOFTWARE') NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_fmp_fund_manager_id` (`fund_manager_id`),
  CONSTRAINT `fk_fmp_fund_manager_id` FOREIGN KEY (`fund_manager_id`) REFERENCES `fund_manager` (`id`)
) ENGINE=InnoDB;

alter table `fund_manager_people`
MODIFY COLUMN focus_area ENUM('SEMICONDUCTOR', 'INTERNET_DIGITAL_MEDIA_AND_TRAVEL', 
'COMMUNICATIONS_SERVICES', 'FINTECH', 'SECURITY_SOFTWARE', 'ENTERPRISE_SOFTWARE', 
'VERTICAL_SOFTWARE', 'ALL_EQUITY') NOT NULL;


CREATE TABLE `fund_manager_insight` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ufmsid_id` bigint unsigned NOT NULL,
  `fund_manager_id` bigint unsigned DEFAULT NULL,
  `fund_manager_people_id` bigint unsigned DEFAULT NULL,
  `ticker` varchar(255) DEFAULT NULL,
  `seqNo` bigint unsigned default NULL,
  `newsDate` date NOT NULL,
  `code` varchar(64) NOT NULL,
  `details` varchar(512) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_fmi_fund_manager_id` (`fund_manager_id`),
  CONSTRAINT unique_fund_manager_insight UNIQUE (`ticker`,`newsDate`,`code`,`seqNo`),
  CONSTRAINT `fk_fmi_fmp_id` FOREIGN KEY (`fund_manager_people_id`) REFERENCES `fund_manager_people` (`id`),
  CONSTRAINT `fk_fmi_fund_manager_id` FOREIGN KEY (`fund_manager_id`) REFERENCES `fund_manager` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `fund_manager_insight_stock` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `fund_manager_insight_id` bigint unsigned NOT NULL,
  `stock_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_fund_manager_insight_stock` (`fund_manager_insight_id`,`stock_id`),
  CONSTRAINT unique_fund_manager_insight_stock UNIQUE (`fund_manager_insight_id`,`stock_id`),
  CONSTRAINT `fk_fmpi_fmi` FOREIGN KEY (`fund_manager_insight_id`) REFERENCES `fund_manager_insight` (`id`),
  CONSTRAINT `fk_fmpi_stock` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`)
) ENGINE=InnoDB;

/* @TODO Not needed. 
CREATE TABLE `fund_manager_people_insight` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `fund_manager_people_id` bigint unsigned DEFAULT NULL,
  `details` varchar(512) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_fmpi_fund_manager_id` (`fund_manager_people_id`),
  CONSTRAINT `fk_fmpi_fund_manager_people_id` FOREIGN KEY (`fund_manager_people_id`) REFERENCES `fund_manager_people` (`id`)
) ENGINE=InnoDB;
*/

CREATE TABLE `past_stock` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(32) NOT NULL,
  `cusip` varchar(32) NOT NULL,
  `cl` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `purchased_at` timestamp NULL DEFAULT NULL,
  `sold_at` timestamp NULL DEFAULT NULL,
  `purchase_price` double(16,2) NOT NULL,
  `sold_price` double(16,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `sector` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(124) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB;


CREATE TABLE `stock` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `cusip` varchar(32) NOT NULL,
  `cik` varchar(20) NOT NULL,
  `cl` varchar(32) NOT NULL,
  `name` varchar(255) NOT NULL,
  `exchange` varchar(64) DEFAULT NULL,
  `sector` varchar(128) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `isin` varchar(32) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `label` varchar(128) DEFAULT NULL,
  `past_stock` tinyint(1) DEFAULT '0',
  `sector_id` bigint unsigned DEFAULT NULL,
  `country` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stock_cusip` (`cusip`),
  CONSTRAINT unique_stock_ticker UNIQUE (`ticker`),
  KEY `idx_stock_ticker` (`ticker`),
  KEY `fk_stock_sector` (`sector_id`),
  CONSTRAINT `fk_stock_sector` FOREIGN KEY (`sector_id`) REFERENCES `sector` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `sector_stock` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sector_id` bigint unsigned NOT NULL,
  `stock_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_sector_stock UNIQUE (`sector_id`,`stock_id`),
  KEY `fk_sector_stock_sector` (`sector_id`),
  KEY `fk_sector_stock_stock` (`stock_id`),
  CONSTRAINT `fk_sector_stock_sector` FOREIGN KEY (`sector_id`) REFERENCES `sector` (`id`),
  CONSTRAINT `fk_sector_stock_stock` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `watchlist` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `country` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB;

CREATE TABLE `watchlist_stock` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `watchlist_id` bigint unsigned NOT NULL,
  `stock_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_watchlist_stock` (`watchlist_id`,`stock_id`),
  CONSTRAINT unique_watchlist_stock UNIQUE (`watchlist_id`,`stock_id`),
  CONSTRAINT `fk_watchlist_stock_watchlist` FOREIGN KEY (`watchlist_id`) REFERENCES `watchlist` (`id`),
  CONSTRAINT `fk_watchlist_stock_stock` FOREIGN KEY (`stock_id`) REFERENCES `stock` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `table_filter_master` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL,
  `field_name` varchar(100) NOT NULL,
  `filter_value` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_watchlist_stock UNIQUE (`table_name`,`field_name`,`filter_value`)
) ENGINE=InnoDB;



/* UPLOAD DATA TABLE */
CREATE TABLE `upload_stock_sector` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `sector` varchar(128) NOT NULL,
  `stockTicker` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `upload_watchlist_stock` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `watchlist` varchar(128) DEFAULT NULL,
  `stock` varchar(128) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  CONSTRAINT unique_name_cik UNIQUE (`watchlist`,`stock`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `upload_earnings_upcoming_date` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ticker` varchar(255) DEFAULT NULL,
  `quarter` varchar(64) DEFAULT NULL,
  `time` varchar(64) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  `missingStock` tinyint(1) DEFAULT '0',
  `missingStock_updateDate` date default NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`,`quarter`,`time`,`earnings_date`)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_ueud_missingStock_updateDate
BEFORE UPDATE ON upload_earnings_upcoming_date
FOR EACH ROW
BEGIN
  IF NEW.missingStock = 1 AND OLD.missingStock <> 1 THEN
    SET NEW.missingStock_updateDate = CURRENT_DATE;
  END IF;
END$$

DELIMITER ;


CREATE TABLE `upload_earnings_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(255) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  `stockPriceSOD` decimal(20,2) DEFAULT NULL,
  `stockPriceEOD` decimal(20,2) DEFAULT NULL,
  `stockPriceEO2Ds` decimal(20,2) DEFAULT NULL,
  `stockPriceEOW` decimal(20,2) DEFAULT NULL,
  `stockPriceEO2Ws` decimal(20,2) DEFAULT NULL,
  `movement` varchar(64) DEFAULT NULL,
  `supriseEarning` varchar(32) DEFAULT NULL,
  `supriseRevenue` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`,`earnings_date`)
) ENGINE=InnoDB;

CREATE TABLE `upload_split_data` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(255) DEFAULT NULL,
  `earnings_date` date DEFAULT NULL,
  `priceBeforeSplit` decimal(20,2) DEFAULT NULL,
  `priceAfterSplit` decimal(20,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT unique_earnings_upcoming UNIQUE (`ticker`,`earnings_date`)
) ENGINE=InnoDB;

CREATE TABLE `upload_stock_inside_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(255) NOT NULL,
  `seqNo` bigint unsigned default NULL,
  `newsDate` date NOT NULL,
  `code` varchar(64) NOT NULL,
  `details` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT upload_stock_inside_details UNIQUE (`ticker`,`seqNo`,`newsDate`,`code`)
) ENGINE=InnoDB;

CREATE TABLE `upload_fund_manager_stock_inside_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(255) NOT NULL,
  `seqNo` bigint unsigned default NULL,
  `newsDate` date NOT NULL,
  `code` varchar(64) NOT NULL,
  `manager_search_code` varchar(128) DEFAULT NULL,
  `manager_people_search_code` varchar(128) NOT NULL,
  `details` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT upload_fund_manager_stock_inside_details UNIQUE (`ticker`, `seqNo`, `newsDate`,`code`,`manager_search_code`,`manager_people_search_code`)
) ENGINE=InnoDB;


CREATE TABLE `upload_13f_stock_data` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `manager` varchar(256) DEFAULT NULL,
  `cik` varchar(20) DEFAULT NULL,
  `reportDate` date NOT NULL,
  `value` decimal(20,2) NOT NULL,
  `shares` bigint unsigned NOT NULL,
  `optionType` varchar(32) DEFAULT NULL,
  `cusip` varchar(20) DEFAULT NULL,
  `ticker` varchar(32) DEFAULT NULL,
  `quarter` varchar(32) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_13f_stock_data UNIQUE (`cik`,`optionType`,`cusip`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `upload_13f_manager_data` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `ticker` varchar(32) NOT NULL,
  `stockName` varchar(256) DEFAULT NULL,
  `cl` varchar(20) DEFAULT NULL,
  `cusip` varchar(20) DEFAULT NULL,
  `value` decimal(20,2) NOT NULL,
  `percentage` decimal(20,2) NOT NULL,
  `shares` bigint unsigned NOT NULL,
  `principal` decimal(20,2) DEFAULT NULL,
  `optionType` varchar(32) DEFAULT NULL,
  `manager` varchar(256) DEFAULT NULL,
  `cik` varchar(20) DEFAULT NULL,
  `quarter` varchar(32) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_name_cik UNIQUE (`cik`,`optionType`,`cusip`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `upload_manager_people_ticker` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `managerName` varchar(256) DEFAULT NULL,
  `search_code` varchar(128) DEFAULT NULL,
  `ticker` varchar(32) NOT NULL,
  `missingStock` tinyint(1) DEFAULT '0',
  `missingStock_updateDate` date default NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT unique_upload_manager_people_ticker UNIQUE (`managerName`,`search_code`,`ticker`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DELIMITER $$

CREATE TRIGGER trg_umpt_missingStock_updateDate
BEFORE UPDATE ON upload_manager_people_ticker
FOR EACH ROW
BEGIN
  IF NEW.missingStock = 1 AND OLD.missingStock <> 1 THEN
    SET NEW.missingStock_updateDate = CURRENT_DATE;
  END IF;
END$$

DELIMITER ;


SHOW CREATE TABLE watchlist;
SHOW CREATE TABLE stock;
SHOW CREATE TABLE watchlist_stock;
