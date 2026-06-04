import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';
const PARKING_API_URL = process.env.REACT_APP_PARKING_API_URL || 'http://localhost:8081';
const REVIEW_API_URL = process.env.REACT_APP_REVIEW_API_URL || 'http://localhost:8083';
const RESERVATION_API_URL = process.env.REACT_APP_RESERVATION_API_URL || 'http://localhost:8082';

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

const reviewApi = axios.create({
  baseURL: REVIEW_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

const reservationApi = axios.create({
  baseURL: RESERVATION_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

const subscriptionApi = axios.create({
  baseURL: process.env.REACT_APP_SUBSCRIPTION_API_URL || 'http://localhost:8084',
  headers: {
    'Content-Type': 'application/json',
  },
});

const paymentApi = axios.create({
  baseURL: process.env.REACT_APP_PAYMENT_API_URL || 'http://localhost:8085',
  headers: {
    'Content-Type': 'application/json',
  },
});

const notificationApi = axios.create({
  baseURL: process.env.REACT_APP_NOTIFICATION_API_URL || 'http://localhost:8086',
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

reviewApi.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

reservationApi.interceptors.request.use((config) => {
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

reviewApi.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

reservationApi.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

subscriptionApi.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
subscriptionApi.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) { localStorage.removeItem('token'); window.location.href = '/login'; }
    return Promise.reject(error);
  }
);

paymentApi.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

notificationApi.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

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

  // Obtener usuario por email
  getUserByEmail: (email) => {
    return api.get(`/user/email/${email}`);
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
  // Crear espacio individual
  createSpace: (parkingId) => {
    return parkingApi.post(`/api/spaces/create/${parkingId}`);
  },

  // Crear múltiples espacios para un parqueadero
  createMultipleSpaces: (parkingId, quantity) => {
    const promises = [];
    for (let i = 0; i < quantity; i++) {
      promises.push(parkingApi.post(`/api/spaces/create/${parkingId}`));
    }
    return Promise.all(promises);
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

// ==================== REVIEW ENDPOINTS ====================

export const reviewService = {
  // Obtener todas las reseñas de un parqueadero
  getReviewsByParking: (parkingId) => {
    return reviewApi.get(`/api/reviews/parking/${parkingId}`);
  },

  // Obtener promedio de calificación de un parqueadero
  getAverageRating: (parkingId) => {
    return reviewApi.get(`/api/reviews/parking/${parkingId}/average`);
  },

  // Obtener todas las reseñas
  getAllReviews: () => {
    return reviewApi.get('/api/reviews/all');
  },

  // Obtener reseña por ID
  getReviewById: (id) => {
    return reviewApi.get(`/api/reviews/${id}`);
  },

  // Obtener reseñas por conductor
  getReviewsByDriver: (driverId) => {
    return reviewApi.get(`/api/reviews/driver/${driverId}`);
  },
};

// ==================== RESERVATION ENDPOINTS ====================

export const reservationService = {
  // Obtener todas las reservas de un parqueadero
  getReservationsByParking: (parkingId) => {
    return reservationApi.get(`/api/reservations/parking/${parkingId}`);
  },

  // Obtener reserva por ID
  getReservationById: (id) => {
    return reservationApi.get(`/api/reservations/${id}`);
  },

  // Obtener reservas por conductor
  getReservationsByDriver: (driverId) => {
    return reservationApi.get(`/api/reservations/driver/${driverId}`);
  },

  // Obtener reservas activas por conductor
  getActiveReservationsByDriver: (driverId) => {
    return reservationApi.get(`/api/reservations/driver/${driverId}/active`);
  },

  // Obtener reservas por espacio
  getReservationsBySpace: (spaceId) => {
    return reservationApi.get(`/api/reservations/space/${spaceId}`);
  },

  // Cancelar reserva (solo permitido después de 15 min si conductor no llegó)
  cancelReservation: (id) => {
    return reservationApi.put(`/api/reservations/${id}/cancel`);
  },

  // Completar reserva
  completeReservation: (id) => {
    return reservationApi.put(`/api/reservations/${id}/complete`);
  },

  // Propietario confirma llegada del conductor
  ownerConfirmArrival: (id) => {
    return reservationApi.put(`/api/reservations/${id}/owner-confirm`);
  },
};

// ==================== SUBSCRIPTION ENDPOINTS ====================

export const subscriptionService = {
  // Obtener todos los planes activos
  getActivePlans: () => {
    return subscriptionApi.get('/api/subscriptions/plans');
  },

  // Obtener todos los planes
  getAllPlans: () => {
    return subscriptionApi.get('/api/subscriptions/plans/all');
  },

  // Obtener un plan específico
  getPlanById: (planId) => {
    return subscriptionApi.get(`/api/subscriptions/plans/${planId}`);
  },

  // Obtener planes activos de un parqueadero específico
  getActivePlansByParking: (parkingId) => {
    return subscriptionApi.get(`/api/subscriptions/plans/parking/${parkingId}`);
  },

  // Crear nuevo plan
  createPlan: (planData) => {
    return subscriptionApi.post('/api/subscriptions/plans', planData);
  },

  // Actualizar plan
  updatePlan: (planId, planData) => {
    return subscriptionApi.put(`/api/subscriptions/plans/${planId}`, planData);
  },

  // Desactivar plan
  deactivatePlan: (planId) => {
    return subscriptionApi.delete(`/api/subscriptions/plans/${planId}`);
  },

  // Crear suscripción para un conductor por email
  createSubscriptionByEmail: (subscriptionData) => {
    return subscriptionApi.post('/api/subscriptions/by-email', subscriptionData);
  },

  // Crear suscripción para un conductor
  createSubscription: (subscriptionData) => {
    return subscriptionApi.post('/api/subscriptions', subscriptionData);
  },

  // Obtener suscripción activa de un conductor
  getActiveSubscription: (driverId) => {
    return subscriptionApi.get(`/api/subscriptions/driver/${driverId}/active`);
  },

  // Obtener todas las suscripciones de un conductor
  getDriverSubscriptions: (driverId) => {
    return subscriptionApi.get(`/api/subscriptions/driver/${driverId}`);
  },

  // Obtener descuento aplicable
  getApplicableDiscount: (driverId) => {
    return subscriptionApi.get(`/api/subscriptions/driver/${driverId}/discount`);
  },

  // Renovar suscripción
  renewSubscription: (subscriptionId) => {
    return subscriptionApi.post(`/api/subscriptions/${subscriptionId}/renew`);
  },

  // Cancelar suscripción
  cancelSubscription: (subscriptionId) => {
    return subscriptionApi.put(`/api/subscriptions/${subscriptionId}/cancel`);
  },

  // Pausar suscripción
  pauseSubscription: (subscriptionId) => {
    return subscriptionApi.put(`/api/subscriptions/${subscriptionId}/pause`);
  },

  // Verificar si puede reservar
  canReserve: (driverId, estimatedHours) => {
    return subscriptionApi.get(`/api/subscriptions/driver/${driverId}/can-reserve`, {
      params: { estimatedHours },
    });
  },

  getSubscriptionsByParking: (parkingId) =>
    subscriptionApi.get(`/api/subscriptions/parking/${parkingId}`),

  getActiveSubscriptionsByParking: (parkingId) =>
    subscriptionApi.get(`/api/subscriptions/parking/${parkingId}/active`),
};

// ==================== PAYMENT ENDPOINTS ====================

export const paymentService = {
  createInvoice: (invoiceData) => paymentApi.post('/api/invoices', invoiceData),
  getInvoiceById: (id) => paymentApi.get(`/api/invoices/${id}`),
  getInvoiceByReservation: (reservationId) => paymentApi.get(`/api/invoices/reservation/${reservationId}`),
  getInvoicesByDriver: (driverId) => paymentApi.get(`/api/invoices/driver/${driverId}`),
};

// ==================== NOTIFICATION ENDPOINTS ====================

export const notificationService = {
  getUnread: (userId) => notificationApi.get(`/api/notifications/user/${userId}/unread`),
  getAll: (userId) => notificationApi.get(`/api/notifications/user/${userId}`),
  markAsRead: (id) => notificationApi.put(`/api/notifications/${id}/read`),
};

export default {
  userService,
  parkingService,
  spaceService,
  reservationService,
  reviewService,
  subscriptionService,
  paymentService,
  notificationService,
};