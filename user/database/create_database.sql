-- Crear la base de datos users
CREATE DATABASE users;

-- Conectarse a la base de datos (esto se ejecuta en el cliente psql)
-- \c users

-- Crear tabla user
CREATE TABLE user (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice en email para búsquedas más rápidas
CREATE INDEX idx_user_email ON user(email);

-- Crear índice en phone_number
CREATE INDEX idx_user_phone ON user(phone_number);

-- Crear tabla driver (vehículos)
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    vehicule VARCHAR(255) NOT NULL,
    plate VARCHAR(20) NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- Crear índice en user_id para driver
CREATE INDEX idx_driver_user_id ON driver(user_id);

-- Crear tabla owner (propietarios)
CREATE TABLE owner (
    owner_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    address VARCHAR(500),
    description TEXT,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
);

-- Crear índice en user_id para owner
CREATE INDEX idx_owner_user_id ON owner(user_id);

-- Insertar datos de ejemplo (opcional)
INSERT INTO user (name, phone_number, email, password, role) VALUES
('Juan Pérez', '3001234567', 'juan@example.com', 'password123', 'DRIVER'),
('María García', '3007654321', 'maria@example.com', 'password456', 'OWNER'),
('Carlos López', '3009876543', 'carlos@example.com', 'password789', 'DRIVER');

-- Insertar datos de ejemplo para driver
INSERT INTO driver (user_id, vehicule, plate) VALUES
(1, 'Toyota Corolla', 'ABC-1234'),
(3, 'Honda Civic', 'XYZ-5678');

-- Insertar datos de ejemplo para owner
INSERT INTO owner (user_id, address, description) VALUES
(2, 'Calle 10 #20-30, Bogotá', 'Propietario de parqueadero central');

