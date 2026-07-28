-- =============================================================================
-- Osven City — Database Migration v1.0
-- Source: Project Terrific → Osven City
-- =============================================================================

-- Step 1: Create the new Osven City database
CREATE DATABASE IF NOT EXISTS `osvencity`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `osvencity`;

-- Step 2: Recreate all tables with proper charset/collation
-- NOTE: Copy all CREATE TABLE statements from ProjectTerrific.sql
-- but replace `projectterrific.` with `osvencity.` and fix:
--   - All tables use utf8mb4 + utf8mb4_unicode_ci
--   - JSON columns use JSON type instead of TEXT
--   - Add FOREIGN KEY constraints where appropriate
--   - Add proper INDEXes

-- Step 3: Migrate data from projectterrific to osvencity
-- INSERT INTO osvencity.tablename SELECT * FROM projectterrific.tablename;

-- Step 4: Drop duplicate tables
DROP TABLE IF EXISTS `projectterrific`.`bank_accounts`;       -- Use bank_accounts_new
DROP TABLE IF EXISTS `projectterrific`.`bank_statements`;    -- Legacy

-- Step 5: Remove legacy inventory tables (replaced by ox_inventory)
DROP TABLE IF EXISTS `projectterrific`.`gloveboxitems`;
DROP TABLE IF EXISTS `projectterrific`.`stashitems`;
DROP TABLE IF EXISTS `projectterrific`.`trunkitems`;

-- Step 6: Remove legacy phone tables (replaced by NPWD)
-- NPWD uses its own schema — keep phone_* tables only if migrating data
-- DROP TABLE IF EXISTS `projectterrific`.`phone_*`; -- UNCOMMENT AFTER DATA MIGRATION

-- Step 7: Osven City new tables
CREATE TABLE IF NOT EXISTS `osvencity`.`osven_armory_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `item` VARCHAR(100) NOT NULL,
    `timestamp` BIGINT NOT NULL,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `osvencity`.`osven_admin_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `admin_citizenid` VARCHAR(50) NOT NULL,
    `action` VARCHAR(100) NOT NULL,
    `target` VARCHAR(100),
    `detail` TEXT,
    `timestamp` BIGINT NOT NULL,
    INDEX `idx_admin` (`admin_citizenid`),
    INDEX `idx_action` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `osvencity`.`bans` (
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
-- NPWD Phone Integration
-- =============================================================================

-- Add phone_number column to players table if not exists
ALTER TABLE `players`
  ADD COLUMN IF NOT EXISTS `phone_number` VARCHAR(20) DEFAULT NULL AFTER `citizenid`;

-- NPWD requires `npwd_` prefix tables; create if not present
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
