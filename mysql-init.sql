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

-- ==================== DATOS DE PRUEBA USER SERVICE ====================

-- Crear usuario admin
INSERT INTO user (name, phone_number, email, password, role, created_at) VALUES
('Admin Sistema', '+57 3001234567', 'admin@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', 'ADMIN', NOW());

-- Crear usuario propietario
INSERT INTO user (name, phone_number, email, password, role, created_at) VALUES
('Juan Propietario', '+57 3002234567', 'owner@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', 'OWNER', NOW());

-- Crear usuario conductor
INSERT INTO user (name, phone_number, email, password, role, created_at) VALUES
('Carlos Conductor', '+57 3003234567', 'driver@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', 'DRIVER', NOW());

-- Crear registro de conductor (owner user_id=3)
INSERT INTO driver (user_id, vehicule, plate) VALUES
(3, 'Toyota Corolla', 'ABC-1234');

-- Crear registro de propietario (owner user_id=2)
INSERT INTO owner (user_id) VALUES
(2);

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

-- ==================== DATOS DE PRUEBA PARKING SERVICE ====================

-- Insertar estacionamiento de prueba (propietario con owner_id=2)
INSERT INTO parking (owner_id, name, address, price_per_hour, availability, latitude, longitude) VALUES
(2, 'Parqueadero Centro Plus', 'Calle 10 #5-50, Bogotá', 5000.00, TRUE, 4.7169, -74.0704);

-- Insertar espacios de prueba
INSERT INTO space (parking_id, space_number, status) VALUES
(1, 'SPACE-1-001', 'AVAILABLE'),
(1, 'SPACE-1-002', 'AVAILABLE'),
(1, 'SPACE-1-003', 'OCCUPIED'),
(1, 'SPACE-1-004', 'AVAILABLE');

-- ==================== CREDENCIALES Y PRIVILEGIOS ====================

-- Usuario para User Service (easypark_db)
CREATE USER IF NOT EXISTS 'easypark_user'@'%' IDENTIFIED BY 'easypark_pass123';
GRANT ALL PRIVILEGES ON easypark_db.* TO 'easypark_user'@'%';

-- Usuario para Parking Service (parking_db)
CREATE USER IF NOT EXISTS 'parking_user'@'%' IDENTIFIED BY 'parking_pass123';
GRANT ALL PRIVILEGES ON parking_db.* TO 'parking_user'@'%';

FLUSH PRIVILEGES;
