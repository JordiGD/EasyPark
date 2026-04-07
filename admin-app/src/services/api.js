import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Agregar token a cada request si existe
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Manejo de errores
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// ==================== USER ENDPOINTS ====================

export const userService = {
  // Login admin
  login: (email, password) => {
    return api.post('/user/login', { email, password });
  },

  // Obtener todos los usuarios
  getAllUsers: () => {
    return api.get('/user/all');
  },

  // Actualizar usuario
  updateUser: (userData) => {
    return api.post('/user/updateUser', userData);
  },

  // Eliminar usuario
  deleteUser: (userId) => {
    return api.delete(`/user/${userId}`);
  },
};

// ==================== DRIVER ENDPOINTS ====================

export const driverService = {
  // Obtener todos los conductores
  getAllDrivers: () => {
    return api.get('/driver/all');
  },

  // Actualizar información del vehículo
  updateVehicle: (vehicleData) => {
    return api.post('/driver/updateVehicule', vehicleData);
  },

  // Eliminar conductor
  deleteDriver: (driverId) => {
    return api.delete(`/driver/${driverId}`);
  },
};

// ==================== OWNER ENDPOINTS ====================

export const ownerService = {
  // Obtener todos los propietarios
  getAllOwners: () => {
    return api.get('/owner/all');
  },

  // Actualizar información del parqueadero
  updateParking: (parkingData) => {
    return api.post('/owner/updateParking', parkingData);
  },

  // Eliminar propietario
  deleteOwner: (ownerId) => {
    return api.delete(`/owner/${ownerId}`);
  },
};

export default api;
