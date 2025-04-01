-- Database: website_db
CREATE DATABASE IF NOT EXISTS `fabe_website`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `fabe_Website`;

CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password_hash` CHAR(60) NOT NULL,
  `role` ENUM('superAdmin','admin','user') NOT NULL DEFAULT 'user', 
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `username_UNIQUE` (`username`),
  UNIQUE INDEX `email_UNIQUE` (`email`)
) ENGINE=InnoDB;

CREATE TABLE `profiles` (
  `user_id` INT UNSIGNED NOT NULL,
  `first_name` VARCHAR(50),
  `last_name` VARCHAR(50),
  `avatar_url` VARCHAR(255),
  `bio` TEXT,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_profiles_users`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ======================
-- posts Table 
-- ======================
CREATE TABLE `posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL, -- this field will generate SEO friendly URL
  `content` TEXT NOT NULL,
  `status` ENUM('draft','published','archived'),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `slug_UNIQUE` (`slug`),
  INDEX `fk_posts_users_idx` (`user_id`),
  CONSTRAINT `fk_posts_users`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

CREATE TABLE `comments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `post_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED,
  `parent_id` INT UNSIGNED,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_comments_posts_idx` (`post_id`),
  INDEX `fk_comments_users_idx` (`user_id`),
  INDEX `fk_comments_comments_idx` (`parent_id`),
  CONSTRAINT `fk_comments_posts`
    FOREIGN KEY (`post_id`)
    REFERENCES `posts` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_comments_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL,
  CONSTRAINT `fk_comments_comments`
    FOREIGN KEY (`parent_id`)
    REFERENCES `comments` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ======================
-- products table
-- ======================
CREATE TABLE `products` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `price` DECIMAL NOT NULL,
  `stock_quantity` INT DEFAULT 0,
  `image_url` VARCHAR(255),
  `status` ENUM('active','archived') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `orders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `total_amount` DECIMAL NOT NULL,
  `status` ENUM('pending','processing','completed','cancelled') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_users_idx` (`user_id`),
  CONSTRAINT `fk_orders_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE RESTRICT -- you can set NULL or cascade her as the scenario requres
) ENGINE=InnoDB;

CREATE TABLE `order_items` (
  `order_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL NOT NULL,
  PRIMARY KEY (`order_id`, `product_id`),
  INDEX `fk_order_items_products_idx` (`product_id`),
  CONSTRAINT `fk_order_items_orders`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders` (`id`),
  CONSTRAINT `fk_order_items_products`
    FOREIGN KEY (`product_id`)
    REFERENCES `products` (`id`)
    ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ======================
-- Gallery System
-- ======================
CREATE TABLE `galleries` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_galleries_users_idx` (`user_id`),
  CONSTRAINT `fk_galleries_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `gallery_media` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gallery_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `media_type` ENUM('image','video','document') DEFAULT 'image',
  `file_url` VARCHAR(255) NOT NULL,
  `caption` VARCHAR(255),
  `alt_text` VARCHAR(255),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_gallery_media_galleries_idx` (`gallery_id`),
  INDEX `fk_gallery_media_users_idx` (`user_id`),
  CONSTRAINT `fk_gallery_media_galleries`
    FOREIGN KEY (`gallery_id`)
    REFERENCES `galleries` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_gallery_media_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `job_categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL,
  `description` TEXT,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `slug_UNIQUE` (`slug`)
) ENGINE=InnoDB;

CREATE TABLE `job_posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `location` VARCHAR(100),
  `job_type` ENUM('full-time','part-time','contract','freelance') DEFAULT 'full-time',
  `salary_range` VARCHAR(100),
  `application_deadline` DATETIME,
  `status` ENUM('draft','published','closed') DEFAULT 'draft',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_job_posts_users_idx` (`user_id`),
  CONSTRAINT `fk_job_posts_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `job_post_category` (
  `job_post_id` INT UNSIGNED NOT NULL,
  `category_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`job_post_id`, `category_id`),
  INDEX `fk_job_post_category_category_idx` (`category_id`),
  CONSTRAINT `fk_job_post_category_post`
    FOREIGN KEY (`job_post_id`)
    REFERENCES `job_posts` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_job_post_category_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `job_categories` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- ======================
-- Newsletter & Contact
-- ======================
CREATE TABLE `newsletter_subscriptions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `user_id` INT UNSIGNED,
  `token` VARCHAR(255),
  `status` ENUM('pending','subscribed','unsubscribed') DEFAULT 'pending',
  `subscribed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `confirmed_at` TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email_UNIQUE` (`email`),
  INDEX `fk_newsletter_users_idx` (`user_id`),
  CONSTRAINT `fk_newsletter_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `contact_messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('new','read','archived') DEFAULT 'new',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_contact_messages_users_idx` (`user_id`),
  CONSTRAINT `fk_contact_messages_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;




-- ======================
-- RFQ Process
-- ======================

-- Main RFQ Table
CREATE TABLE `rfqs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL, -- Requester (from users table)
  `supplier_id` INT UNSIGNED NULL, -- Assigned supplier (optional)
  `rfq_number` VARCHAR(20) NOT NULL, 
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `status` ENUM('draft','submitted','processing','completed','cancelled') DEFAULT 'draft',
  `due_date` DATE NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `rfq_number_UNIQUE` (`rfq_number`),
  INDEX `fk_rfqs_users_idx` (`user_id`),
  INDEX `fk_rfqs_suppliers_idx` (`supplier_id`),
  CONSTRAINT `fk_rfqs_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE RESTRICT,
  CONSTRAINT `fk_rfqs_suppliers`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- RFQ Items Table
CREATE TABLE `rfq_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rfq_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NULL, -- Link to products table (optional)
  `item_name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `quantity` INT NOT NULL,
  `unit` VARCHAR(50) NOT NULL, -- e.g., pieces, kg, liters
  `technical_specs` TEXT,
  PRIMARY KEY (`id`),
  INDEX `fk_rfq_items_rfqs_idx` (`rfq_id`),
  INDEX `fk_rfq_items_products_idx` (`product_id`),
  CONSTRAINT `fk_rfq_items_rfqs`
    FOREIGN KEY (`rfq_id`)
    REFERENCES `rfqs` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_rfq_items_products`
    FOREIGN KEY (`product_id`)
    REFERENCES `products` (`id`)
    ON DELETE SET NULL
) ENGINE=InnoDB;

-- Supplier Responses Table
CREATE TABLE `rfq_responses` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rfq_id` INT UNSIGNED NOT NULL,
  `supplier_id` INT UNSIGNED NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `total_price` DECIMAL(10,2) NOT NULL,
  `validity_days` INT NOT NULL, -- Quote validity period
  `notes` TEXT,
  `status` ENUM('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_rfq_responses_rfqs_idx` (`rfq_id`),
  INDEX `fk_rfq_responses_users_idx` (`supplier_id`),
  CONSTRAINT `fk_rfq_responses_rfqs`
    FOREIGN KEY (`rfq_id`)
    REFERENCES `rfqs` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_rfq_responses_users`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;

-- RFQ Attachments Table
CREATE TABLE `rfq_attachments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rfq_id` INT UNSIGNED NOT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(255) NOT NULL,
  `file_type` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255),
  `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_rfq_attachments_rfqs_idx` (`rfq_id`),
  CONSTRAINT `fk_rfq_attachments_rfqs`
    FOREIGN KEY (`rfq_id`)
    REFERENCES `rfqs` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;





CREATE TABLE `password_resets` (
  `user_id` INT UNSIGNED NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `token_UNIQUE` (`token`),
  CONSTRAINT `fk_password_resets_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB;