-- ==================== CREAR TABLAS ====================

-- Tabla de Usuarios
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(50) DEFAULT 'user' COMMENT 'admin, owner, driver, user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de Conductores (Vehículos)
CREATE TABLE IF NOT EXISTS drivers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  license_plate VARCHAR(50) UNIQUE NOT NULL,
  brand VARCHAR(100) NOT NULL,
  model VARCHAR(100) NOT NULL,
  color VARCHAR(100),
  year INT,
  seats INT DEFAULT 4,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de Propietarios (Parqueaderos)
CREATE TABLE IF NOT EXISTS parkings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  name VARCHAR(150) NOT NULL,
  address VARCHAR(255) NOT NULL,
  city VARCHAR(100),
  zip_code VARCHAR(20),
  capacity INT NOT NULL,
  price_per_hour DECIMAL(10, 2),
  price_per_day DECIMAL(10, 2),
  description LONGTEXT,
  has_restroom BOOLEAN DEFAULT FALSE,
  has_24hour_guard BOOLEAN DEFAULT FALSE,
  has_cameras BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_city (city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== INSERTAR DATOS DE PRUEBA ====================

-- Crear usuario admin
INSERT INTO users (first_name, last_name, email, password, phone, role) VALUES
('Admin', 'Sistema', 'admin@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', '+57 3001234567', 'admin');

-- Crear usuario propietario
INSERT INTO users (first_name, last_name, email, password, phone, role) VALUES
('Juan', 'Propietario', 'owner@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', '+57 3002234567', 'owner');

-- Crear usuario conductor
INSERT INTO users (first_name, last_name, email, password, phone, role) VALUES
('Carlos', 'Conductor', 'driver@easypark.com', '$2a$10$slYQmyNdGzin7olVN8/eZulDW3KjBQwXKP0RhHGmHlWNVzwVvCxo2', '+57 3003234567', 'driver');

-- Crear parqueadero de prueba
INSERT INTO parkings (user_id, name, address, city, zip_code, capacity, price_per_hour, price_per_day, description, has_restroom, has_24hour_guard, has_cameras) VALUES
(2, 'Parqueadero Centro Plus', 'Calle 10 #5-50', 'Bogotá', '110001', 50, 5000.00, 30000.00, 'Parqueadero seguro en el centro de la ciudad', TRUE, TRUE, TRUE);

-- Crear vehículo de prueba
INSERT INTO drivers (user_id, license_plate, brand, model, color, year, seats) VALUES
(3, 'ABC-1234', 'Toyota', 'Corolla', 'Negro', 2023, 4);

-- Crear índices para optimización
CREATE INDEX idx_drivers_user ON drivers(user_id);
CREATE INDEX idx_parkings_user ON parkings(user_id);

-- ==================== PRIVILEGIOS ====================
GRANT ALL PRIVILEGES ON easypark_db.* TO 'easypark_user'@'%';
FLUSH PRIVILEGES;
