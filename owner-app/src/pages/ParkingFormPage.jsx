import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { parkingService } from '../services/api';
import './ParkingForm.css';

export default function ParkingFormPage() {
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: '',
    zipCode: '',
    capacity: '',
    pricePerHour: '',
    pricePerDay: '',
    description: '',
    hasRestroom: false,
    has24HourGuard: false,
    hasCameras: false,
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.name || !formData.address || !formData.capacity) {
      setError('Por favor completa los campos obligatorios');
      return;
    }

    setLoading(true);

    try {
      const parkingData = {
        ...formData,
        capacity: parseInt(formData.capacity),
        pricePerHour: parseFloat(formData.pricePerHour),
        pricePerDay: parseFloat(formData.pricePerDay),
      };

      await parkingService.createParking(parkingData);
      setSuccess('✓ Parqueadero registrado exitosamente');

      setTimeout(() => {
        navigate('/parkings');
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message ||
          'Error al registrar el parqueadero. Intenta de nuevo.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="parking-form-container">
      <div className="form-header">
        <button className="back-btn" onClick={() => navigate('/parkings')}>
          ← Atrás
        </button>
        <h1>Registrar Nuevo Parqueadero</h1>
      </div>

      <form onSubmit={handleSubmit} className="parking-form">
        {/* Basic Information */}
        <fieldset className="form-section">
          <legend>Información Básica</legend>

          <div className="form-group">
            <label htmlFor="name">Nombre del Parqueadero *</label>
            <input
              id="name"
              type="text"
              name="name"
              placeholder="Mi Parqueadero Centro"
              value={formData.name}
              onChange={handleChange}
              disabled={loading}
              required
            />
          </div>

          <div className="form-group">
            <label htmlFor="description">Descripción</label>
            <textarea
              id="description"
              name="description"
              placeholder="Describe tu parqueadero..."
              value={formData.description}
              onChange={handleChange}
              disabled={loading}
              rows="4"
            />
          </div>
        </fieldset>

        {/* Location */}
        <fieldset className="form-section">
          <legend>Ubicación</legend>

          <div className="form-group">
            <label htmlFor="address">Dirección *</label>
            <input
              id="address"
              type="text"
              name="address"
              placeholder="Calle 10 #5-50"
              value={formData.address}
              onChange={handleChange}
              disabled={loading}
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="city">Ciudad</label>
              <input
                id="city"
                type="text"
                name="city"
                placeholder="Bogotá"
                value={formData.city}
                onChange={handleChange}
                disabled={loading}
              />
            </div>

            <div className="form-group">
              <label htmlFor="zipCode">Código Postal</label>
              <input
                id="zipCode"
                type="text"
                name="zipCode"
                placeholder="110001"
                value={formData.zipCode}
                onChange={handleChange}
                disabled={loading}
              />
            </div>
          </div>
        </fieldset>

        {/* Capacity & Pricing */}
        <fieldset className="form-section">
          <legend>Capacidad y Tarifas</legend>

          <div className="form-group">
            <label htmlFor="capacity">Capacidad Total *</label>
            <input
              id="capacity"
              type="number"
              name="capacity"
              placeholder="50"
              value={formData.capacity}
              onChange={handleChange}
              disabled={loading}
              required
              min="1"
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="pricePerHour">Tarifa por Hora</label>
              <input
                id="pricePerHour"
                type="number"
                name="pricePerHour"
                placeholder="5000"
                value={formData.pricePerHour}
                onChange={handleChange}
                disabled={loading}
                step="0.01"
              />
            </div>

            <div className="form-group">
              <label htmlFor="pricePerDay">Tarifa por Día</label>
              <input
                id="pricePerDay"
                type="number"
                name="pricePerDay"
                placeholder="30000"
                value={formData.pricePerDay}
                onChange={handleChange}
                disabled={loading}
                step="0.01"
              />
            </div>
          </div>
        </fieldset>

        {/* Amenities */}
        <fieldset className="form-section">
          <legend>Servicios y Seguridad</legend>

          <div className="checkbox-group">
            <label className="checkbox-label">
              <input
                type="checkbox"
                name="hasRestroom"
                checked={formData.hasRestroom}
                onChange={handleChange}
                disabled={loading}
              />
              <span>Baños disponibles</span>
            </label>
          </div>

          <div className="checkbox-group">
            <label className="checkbox-label">
              <input
                type="checkbox"
                name="has24HourGuard"
                checked={formData.has24HourGuard}
                onChange={handleChange}
                disabled={loading}
              />
              <span>Seguridad 24 horas</span>
            </label>
          </div>

          <div className="checkbox-group">
            <label className="checkbox-label">
              <input
                type="checkbox"
                name="hasCameras"
                checked={formData.hasCameras}
                onChange={handleChange}
                disabled={loading}
              />
              <span>Cámaras de vigilancia</span>
            </label>
          </div>
        </fieldset>

        {/* Messages */}
        {error && <div className="error-message">{error}</div>}
        {success && <div className="success-message">{success}</div>}

        {/* Submit Button */}
        <div className="form-actions">
          <button type="submit" className="submit-btn" disabled={loading}>
            {loading ? 'Registrando...' : 'Registrar Parqueadero'}
          </button>
        </div>
      </form>
    </div>
  );
}
