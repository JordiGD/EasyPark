-- Crear la base de datos driverdb
CREATE DATABASE driverdb;

-- Conectarse a la base de datos (esto se ejecuta en el cliente psql)
-- \c driverdb

-- Crear tabla driver
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice en email para búsquedas más rápidas
CREATE INDEX idx_driver_email ON driver(email);

-- Crear índice en phone_number
CREATE INDEX idx_driver_phone ON driver(phone_number);

-- Insertar datos de ejemplo (opcional)
INSERT INTO driver (name, phone_number, email, password) VALUES
('Juan Pérez', '3001234567', 'juan@example.com', 'password123'),
('María García', '3007654321', 'maria@example.com', 'password456');
