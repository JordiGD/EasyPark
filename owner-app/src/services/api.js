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
  // Registrar nuevo propietario
  register: (userData) => {
    return api.post('/user/saveUser', userData);
  },

  // Login
  login: (email, password) => {
    return api.post('/user/login', { email, password });
  },

  // Actualizar perfil
  updateProfile: (userData) => {
    return api.post('/user/updateUser', userData);
  },
};

// ==================== OWNER ENDPOINTS ====================

export const ownerService = {
  // Registrar parqueadero
  saveParking: (parkingData) => {
    return api.post('/owner/saveParking', parkingData);
  },

  // Actualizar parqueadero
  updateParking: (parkingData) => {
    return api.post('/owner/updateParking', parkingData);
  },
};

export default api;
