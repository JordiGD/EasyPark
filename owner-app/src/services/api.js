import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';
const PARKING_API_URL = process.env.REACT_APP_PARKING_API_URL || 'http://localhost:8081';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

const parkingApi = axios.create({
  baseURL: PARKING_API_URL,
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

parkingApi.interceptors.request.use((config) => {
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

parkingApi.interceptors.response.use(
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

// ==================== PARKING ENDPOINTS ====================

export const parkingService = {
  // Crear nuevo parqueadero
  createParking: (parkingData) => {
    return parkingApi.post('/api/parkings', parkingData);
  },

  // Obtener todos los parqueaderos del propietario
  getParkingsByOwner: (ownerId) => {
    return parkingApi.get(`/api/parkings/owner/${ownerId}`);
  },

  // Obtener detalles de un parqueadero
  getParkingById: (parkingId) => {
    return parkingApi.get(`/api/parkings/${parkingId}`);
  },

  // Obtener todos los parqueaderos
  getAllParkings: () => {
    return parkingApi.get('/api/parkings');
  },

  // Actualizar parqueadero
  updateParking: (parkingId, parkingData) => {
    return parkingApi.put(`/api/parkings/${parkingId}`, parkingData);
  },

  // Obtener estado del parqueadero
  getParkingStatus: (parkingId) => {
    return parkingApi.get(`/api/parkings/${parkingId}/status`);
  },
};

// ==================== SPACE ENDPOINTS ====================

export const spaceService = {
  // Crear espacio en parqueadero
  createSpace: (parkingId, spaceData) => {
    return parkingApi.post(`/api/spaces/create/${parkingId}`, spaceData);
  },

  // Obtener espacios de un parqueadero
  getSpacesByParking: (parkingId) => {
    return parkingApi.get(`/api/spaces/parking/${parkingId}`);
  },

  // Obtener estado de un espacio
  getSpaceStatus: (spaceId) => {
    return parkingApi.get(`/api/spaces/${spaceId}/status`);
  },
};

export default api;
