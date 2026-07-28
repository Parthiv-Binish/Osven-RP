-- =============================================================================
-- Osven City — Full Database Schema (standalone, fresh install)
-- Run: sudo mysql -u root -p < database/migration_v1_osven_city.sql
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `osvencity`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `osvencity`;

-- =============================================================================
-- Core QBCore tables
-- =============================================================================

CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `cid` int(11) DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `player_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `number` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

-- =============================================================================
-- Osven City custom tables
-- =============================================================================

CREATE TABLE IF NOT EXISTS `osven_armory_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `item` VARCHAR(100) NOT NULL,
    `timestamp` BIGINT NOT NULL,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `osven_admin_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `admin_citizenid` VARCHAR(50) NOT NULL,
    `action` VARCHAR(100) NOT NULL,
    `target` VARCHAR(100),
    `detail` TEXT,
    `timestamp` BIGINT NOT NULL,
    INDEX `idx_admin` (`admin_citizenid`),
    INDEX `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `osven_bans` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `license` VARCHAR(100) NOT NULL,
    `reason` TEXT NOT NULL,
    `banner` VARCHAR(100) NOT NULL,
    `time` BIGINT NOT NULL,
    `expiry` BIGINT DEFAULT NULL,
    UNIQUE KEY `uk_license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- Gang Territory System
-- =============================================================================

CREATE TABLE IF NOT EXISTS `osven_territories` (
  `territory` VARCHAR(50) PRIMARY KEY,
  `owner` VARCHAR(50) NOT NULL DEFAULT 'none',
  `captured_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- Relationship / Marriage System
-- =============================================================================

CREATE TABLE IF NOT EXISTS `osven_relationships` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `spouse1` VARCHAR(50) NOT NULL,
  `spouse2` VARCHAR(50) NOT NULL,
  `ring_type` VARCHAR(50) NOT NULL,
  `married_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `divorced` TINYINT(1) DEFAULT 0,
  `divorced_at` TIMESTAMP NULL DEFAULT NULL,
  INDEX `idx_spouse1` (`spouse1`),
  INDEX `idx_spouse2` (`spouse2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- Server Logs
-- =============================================================================

CREATE TABLE IF NOT EXISTS `server_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(50) DEFAULT NULL,
  `message` TEXT DEFAULT NULL,
  `metadata` TEXT DEFAULT NULL,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- NPWD Phone Tables
-- =============================================================================

CREATE TABLE IF NOT EXISTS `npwd_twitter_profiles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `profile_name` VARCHAR(90) NOT NULL,
  `avatar_url` VARCHAR(255) DEFAULT NULL,
  `identifier` VARCHAR(48) NOT NULL,
  UNIQUE KEY `uk_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_twitter_tweets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `message` TEXT NOT NULL,
  `images` TEXT DEFAULT NULL,
  `retweet` INT DEFAULT NULL,
  `profile_id` INT NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `likes` INT DEFAULT 0,
  `retweets` INT DEFAULT 0,
  FOREIGN KEY (`profile_id`) REFERENCES `npwd_twitter_profiles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_twitter_likes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `profile_id` INT NOT NULL,
  `tweet_id` INT NOT NULL,
  FOREIGN KEY (`profile_id`) REFERENCES `npwd_twitter_profiles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`tweet_id`) REFERENCES `npwd_twitter_tweets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `message` TEXT NOT NULL,
  `user_identifier` VARCHAR(48) NOT NULL,
  `conversation_id` VARCHAR(64) NOT NULL,
  `isRead` TINYINT(1) DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `image` VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_messages_conversations` (
  `id` VARCHAR(64) PRIMARY KEY,
  `participant_identifier` VARCHAR(48) NOT NULL,
  `label` VARCHAR(60) DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_contacts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `number` VARCHAR(20) NOT NULL,
  `display` VARCHAR(60) NOT NULL,
  `avatar` VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_calls` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `transmitter` VARCHAR(20) NOT NULL,
  `receiver` VARCHAR(20) NOT NULL,
  `is_accepted` TINYINT(1) DEFAULT 0,
  `startedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `endedAt` TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_notes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `content` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_marketplace_listings` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `username` VARCHAR(60) DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `url` VARCHAR(255) DEFAULT NULL,
  `price` INT DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reported` TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_match_profiles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `name` VARCHAR(90) NOT NULL,
  `image` VARCHAR(255) DEFAULT NULL,
  `bio` TEXT DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_match_likes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `profile_id` INT NOT NULL,
  `liker_id` INT NOT NULL,
  FOREIGN KEY (`profile_id`) REFERENCES `npwd_match_profiles`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`liker_id`) REFERENCES `npwd_match_profiles`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_match_views` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) NOT NULL,
  `profile` INT NOT NULL,
  `liked` TINYINT DEFAULT 0,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `match_profile_idx` (`profile`),
  CONSTRAINT `match_profile` FOREIGN KEY (`profile`) REFERENCES `npwd_match_profiles`(`id`),
  INDEX `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_twitter_reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `profile_id` INT NOT NULL,
  `tweet_id` INT NOT NULL,
  UNIQUE KEY `unique_combination` (`profile_id`, `tweet_id`),
  KEY `profile_idx` (`profile_id`),
  KEY `tweet_idx` (`tweet_id`),
  CONSTRAINT `report_profile` FOREIGN KEY (`profile_id`) REFERENCES `npwd_twitter_profiles`(`id`),
  CONSTRAINT `report_tweet` FOREIGN KEY (`tweet_id`) REFERENCES `npwd_twitter_tweets`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_phone_gallery` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `identifier` VARCHAR(48) DEFAULT NULL,
  `image` VARCHAR(255) NOT NULL,
  INDEX `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_darkchat_channels` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `channel_identifier` VARCHAR(191) NOT NULL,
  `label` VARCHAR(255) DEFAULT '',
  UNIQUE INDEX `channel_identifier` (`channel_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_darkchat_channel_members` (
  `channel_id` INT NOT NULL,
  `user_identifier` VARCHAR(255) NOT NULL,
  `is_owner` TINYINT NOT NULL DEFAULT 0,
  INDEX `member_channel_idx` (`channel_id`),
  CONSTRAINT `member_channel_fk` FOREIGN KEY (`channel_id`) REFERENCES `npwd_darkchat_channels`(`id`) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `npwd_darkchat_messages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `channel_id` INT NOT NULL,
  `message` VARCHAR(255) NOT NULL,
  `user_identifier` VARCHAR(255) NOT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_image` TINYINT NOT NULL DEFAULT 0,
  INDEX `darkchat_messages_channel_idx` (`channel_id`),
  CONSTRAINT `darkchat_messages_channel_fk` FOREIGN KEY (`channel_id`) REFERENCES `npwd_darkchat_channels`(`id`) ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================================
-- Additional resource tables
-- =============================================================================

-- ox_inventory
CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` VARCHAR(60) DEFAULT NULL,
  `name` VARCHAR(100) NOT NULL,
  `data` LONGTEXT DEFAULT NULL,
  `lastupdated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `owner_name` (`owner`, `name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- qb-houses
CREATE TABLE IF NOT EXISTS `player_houses` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `house` VARCHAR(50) NOT NULL,
  `identifier` VARCHAR(50) DEFAULT NULL,
  `citizenid` VARCHAR(50) DEFAULT NULL,
  `keyholders` TEXT DEFAULT NULL,
  `furniture` LONGTEXT DEFAULT NULL,
  `decorations` LONGTEXT DEFAULT NULL,
  `stash` LONGTEXT DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `house` (`house`),
  INDEX `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- qb-apartments
CREATE TABLE IF NOT EXISTS `apartments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `citizenid` VARCHAR(50) NOT NULL,
  `apartment` VARCHAR(50) NOT NULL,
  `furnished` TINYINT(1) DEFAULT 0,
  `furniture` LONGTEXT DEFAULT NULL,
  `decorations` LONGTEXT DEFAULT NULL,
  `stash` LONGTEXT DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- qb-garages
CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `license` VARCHAR(50) DEFAULT NULL,
  `citizenid` VARCHAR(50) DEFAULT NULL,
  `vehicle` VARCHAR(50) DEFAULT NULL,
  `hash` VARCHAR(50) DEFAULT NULL,
  `mods` LONGTEXT DEFAULT NULL,
  `plate` VARCHAR(50) NOT NULL,
  `garage` VARCHAR(50) DEFAULT NULL,
  `state` INT DEFAULT 0,
  `fuel` INT DEFAULT 100,
  `engine` FLOAT DEFAULT 1000,
  `body` FLOAT DEFAULT 1000,
  `depotprice` INT NOT NULL DEFAULT 0,
  `drivingdistance` INT DEFAULT 0,
  `status` TEXT DEFAULT NULL,
  `parking` VARCHAR(60) DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `plate` (`plate`),
  INDEX `citizenid` (`citizenid`),
  INDEX `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ps-mdt
CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `citizenid` VARCHAR(50) DEFAULT NULL,
  `title` VARCHAR(255) DEFAULT NULL,
  `incident` LONGTEXT DEFAULT NULL,
  `charges` LONGTEXT DEFAULT NULL,
  `author` VARCHAR(50) DEFAULT NULL,
  `author_name` VARCHAR(100) DEFAULT NULL,
  `date` VARCHAR(50) DEFAULT NULL,
  `jail_time` INT DEFAULT 0,
  INDEX `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- qb-phone (legacy, for data migration only)
-- CREATE TABLE IF NOT EXISTS `phone_messages` (...)
-- CREATE TABLE IF NOT EXISTS `phone_calls` (...)
-- CREATE TABLE IF NOT EXISTS `phone_gallery` (...)
