import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import DashboardPage from './pages/DashboardPage';
import ParkingFormPage from './pages/ParkingFormPage';
import UserProfilePage from './pages/UserProfilePage';
import SpacesPage from './pages/SpacesPage';
import ReviewsPage from './pages/ReviewsPage';
import ReservationsPage from './pages/ReservationsPage';
import SubscriptionsPage from './pages/SubscriptionsPage';
import TestSelectPage from './pages/TestSelectPage';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        {/* Auth Routes */}
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />

        {/* Debug Routes */}
        <Route path="/test-select" element={<TestSelectPage />} />

        {/* Protected Routes */}
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/parkings/new" element={<ParkingFormPage />} />
        <Route path="/parkings/:parkingId/edit" element={<ParkingFormPage />} />
        <Route path="/parkings/:parkingId/spaces" element={<SpacesPage />} />
        <Route path="/parkings/:parkingId/reviews" element={<ReviewsPage />} />
        <Route path="/parkings/:parkingId/reservations" element={<ReservationsPage />} />
        <Route path="/parkings" element={<DashboardPage />} />
        <Route path="/profile" element={<UserProfilePage />} />
        <Route path="/subscriptions" element={<SubscriptionsPage />} />

        {/* Default Route */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
