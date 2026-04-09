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
CREATE USER IF NOT EXISTS 'easypark_user'@'%' IDENTIFIED BY 'easypark_pass123';
GRANT ALL PRIVILEGES ON easypark_db.* TO 'easypark_user'@'%';

-- Usuario para Parking Service (parking_db)
CREATE USER IF NOT EXISTS 'parking_user'@'%' IDENTIFIED BY 'parking_pass123';
GRANT ALL PRIVILEGES ON parking_db.* TO 'parking_user'@'%';

FLUSH PRIVILEGES;
