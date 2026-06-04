-- ==================== CREAR BASE DE DATOS EASYPARK (USER SERVICE) ====================
CREATE DATABASE IF NOT EXISTS easypark_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE easypark_db;

-- Tabla: user (Usuarios del sistema)
CREATE TABLE IF NOT EXISTS user (
  user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: driver (Información de conductores y vehículos)
CREATE TABLE IF NOT EXISTS driver (
  driver_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  vehicule VARCHAR(255),
  plate VARCHAR(255),
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: owner (Información de propietarios de estacionamientos)
CREATE TABLE IF NOT EXISTS owner (
  owner_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== CREAR BASE DE DATOS PARKING (PARKING SERVICE) ====================
CREATE DATABASE IF NOT EXISTS parking_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE parking_db;

-- Tabla: parking (Estacionamientos)
CREATE TABLE IF NOT EXISTS parking (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  owner_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255),
  price_per_hour DOUBLE,
  availability BOOLEAN DEFAULT TRUE,
  latitude DOUBLE,
  longitude DOUBLE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_owner_id (owner_id),
  INDEX idx_availability (availability)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: space (Espacios de Parqueo)
CREATE TABLE IF NOT EXISTS space (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  parking_id BIGINT NOT NULL,
  space_number VARCHAR(255) NOT NULL,
  status VARCHAR(50) DEFAULT 'AVAILABLE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_parking_id (parking_id),
  INDEX idx_status (status),
  UNIQUE KEY unique_space (parking_id, space_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== CREDENCIALES Y PRIVILEGIOS ====================

-- Usuario para User Service (easypark_db)
DROP USER IF EXISTS 'easypark_user'@'%';
CREATE USER 'easypark_user'@'%' IDENTIFIED BY 'easypark_pass123';
GRANT ALL PRIVILEGES ON easypark_db.* TO 'easypark_user'@'%';

-- Usuario para Parking Service (parking_db)
DROP USER IF EXISTS 'parking_user'@'%';
CREATE USER 'parking_user'@'%' IDENTIFIED BY 'parking_pass123';
GRANT ALL PRIVILEGES ON parking_db.* TO 'parking_user'@'%';

-- Usuario para Reservation Service (reservation_db)
CREATE DATABASE IF NOT EXISTS reservation_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE reservation_db;

DROP USER IF EXISTS 'reservation_user'@'%';
CREATE USER 'reservation_user'@'%' IDENTIFIED BY 'reservation_pass123';
GRANT ALL PRIVILEGES ON reservation_db.* TO 'reservation_user'@'%';

-- Tabla: reservation (Reservas de Espacios de Parqueo)
CREATE TABLE IF NOT EXISTS reservation (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_id BIGINT NOT NULL,
  space_id BIGINT NOT NULL,
  parking_id BIGINT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  start_time DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_driver_id (driver_id),
  INDEX idx_space_id (space_id),
  INDEX idx_parking_id (parking_id),
  INDEX idx_status (status),
  INDEX idx_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS review_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE review_db;

CREATE TABLE IF NOT EXISTS review (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  parking_id BIGINT NOT NULL,
  driver_id BIGINT NOT NULL,
  rating INT NOT NULL,
  comment VARCHAR(1000),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_parking_id (parking_id),
  INDEX idx_driver_id (driver_id),
  INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuario para Review Service (review_db)
DROP USER IF EXISTS 'review_user'@'%';
CREATE USER 'review_user'@'%' IDENTIFIED BY 'review_pass123';
GRANT ALL PRIVILEGES ON review_db.* TO 'review_user'@'%';

-- ==================== CREAR BASE DE DATOS SUBSCRIPTION (SUBSCRIPTION SERVICE) ====================
CREATE DATABASE IF NOT EXISTS subscription_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE subscription_db;

-- Tabla: subscription_plans (Planes de Suscripción - Parking Específicos)
CREATE TABLE IF NOT EXISTS subscription_plans (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  parking_id BIGINT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  monthly_price DECIMAL(10, 2) NOT NULL,
  discount_percentage INT NOT NULL DEFAULT 0,
  max_daily_hours INT,
  monthly_hours INT,
  features JSON,
  is_active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_parking_name (parking_id, name),
  INDEX idx_is_active (is_active),
  INDEX idx_parking_id (parking_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: driver_subscriptions (Suscripciones de Conductores por Parqueadero)
CREATE TABLE IF NOT EXISTS driver_subscriptions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_id BIGINT NOT NULL,
  parking_id BIGINT NOT NULL,
  plan_id BIGINT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'ACTIVE',
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  renewal_date DATETIME NOT NULL,
  auto_renew BOOLEAN DEFAULT TRUE,
  hours_used_this_month INT DEFAULT 0,
  payment_method VARCHAR(50) NOT NULL,
  next_payment_date DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (plan_id) REFERENCES subscription_plans(id),
  INDEX idx_driver_id (driver_id),
  INDEX idx_parking_id (parking_id),
  INDEX idx_plan_id (plan_id),
  INDEX idx_status (status),
  INDEX idx_driver_parking_status (driver_id, parking_id, status),
  INDEX idx_auto_renew (auto_renew)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: subscription_transactions (Transacciones de Suscripción)
CREATE TABLE IF NOT EXISTS subscription_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  driver_subscription_id BIGINT NOT NULL,
  type VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  transaction_date DATETIME NOT NULL,
  payment_gateway_id VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (driver_subscription_id) REFERENCES driver_subscriptions(id),
  INDEX idx_subscription_id (driver_subscription_id),
  INDEX idx_status (status),
  INDEX idx_transaction_date (transaction_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usuario para Subscription Service (subscription_db)
DROP USER IF EXISTS 'subscription_user'@'%';
CREATE USER 'subscription_user'@'%' IDENTIFIED BY 'subscription_pass123';
GRANT ALL PRIVILEGES ON subscription_db.* TO 'subscription_user'@'%';

-- Insertar planes de suscripción por defecto para parking_id 1
INSERT INTO subscription_plans (parking_id, name, description, monthly_price, discount_percentage, max_daily_hours, monthly_hours, features, is_active)
VALUES 
  (1, 'Plan Básico', 'Plan ideal para conductores ocasionales', 9.99, 5, 2, 40, '["Basic features"]', TRUE),
  (1, 'Plan Premium', 'Plan para conductores frecuentes', 29.99, 15, 8, 200, '["Priority booking", "Customer support", "Discounted rates"]', TRUE),
  (1, 'Plan VIP', 'Plan máximo con todos los beneficios', 59.99, 30, NULL, NULL, '["Priority booking", "24/7 support", "VIP rates", "Free cancellation"]', TRUE);

-- ==================== CREAR BASE DE DATOS NOTIFICATION (NOTIFICATION SERVICE) ====================
CREATE DATABASE IF NOT EXISTS notification_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE notification_db;

CREATE TABLE IF NOT EXISTS notification (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  target_user_id BIGINT NOT NULL,
  role VARCHAR(50) NOT NULL,
  type VARCHAR(100) NOT NULL,
  message VARCHAR(500) NOT NULL,
  reservation_id BIGINT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_target_user_id (target_user_id),
  INDEX idx_reservation_id (reservation_id),
  INDEX idx_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP USER IF EXISTS 'notification_user'@'%';
CREATE USER 'notification_user'@'%' IDENTIFIED BY 'notification_pass123';
GRANT ALL PRIVILEGES ON notification_db.* TO 'notification_user'@'%';

-- ==================== CREAR BASE DE DATOS PAYMENT (PAYMENT SERVICE) ====================
CREATE DATABASE IF NOT EXISTS payment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE payment_db;

CREATE TABLE IF NOT EXISTS invoice (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  reservation_id BIGINT NOT NULL UNIQUE,
  driver_id BIGINT NOT NULL,
  owner_id BIGINT NOT NULL,
  parking_id BIGINT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  description VARCHAR(500),
  status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  mercado_pago_preference_id VARCHAR(255),
  payment_url VARCHAR(1000),
  mercado_pago_payment_id VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME,
  INDEX idx_reservation_id (reservation_id),
  INDEX idx_driver_id (driver_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP USER IF EXISTS 'payment_user'@'%';
CREATE USER 'payment_user'@'%' IDENTIFIED BY 'payment_pass123';
GRANT ALL PRIVILEGES ON payment_db.* TO 'payment_user'@'%';

FLUSH PRIVILEGES;
