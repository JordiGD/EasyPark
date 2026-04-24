import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { parkingService, spaceService } from '../services/api';
import './ParkingForm.css';

export default function ParkingFormPage() {
  const { parkingId } = useParams();
  const isEditMode = !!parkingId;
  
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    city: 'Tunja',
    department: 'Boyacá',
    country: 'Colombia',
    pricePerHour: '',
    availability: true,
  });

  const [user, setUser] = useState(null);
  const [spaces, setSpaces] = useState([]);
  const [tempSpaces, setTempSpaces] = useState([]); // Espacios temporales durante creación
  const [spacesLoading, setSpacesLoading] = useState(false);
  const [spacesError, setSpacesError] = useState('');
  const [loading, setLoading] = useState(isEditMode);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const navigate = useNavigate();

  // Cargar usuario
  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) {
      setUser(JSON.parse(userData));
    }
  }, []);

  // Cargar datos del parqueadero si está en modo edición
  useEffect(() => {
    if (isEditMode) {
      const loadParking = async () => {
        try {
          const response = await parkingService.getParkingById(parkingId);
          const parking = response.data;
          setFormData({
            name: parking.name,
            address: parking.address,
            city: parking.city || 'Tunja',
            department: parking.department || 'Boyacá',
            country: parking.country || 'Colombia',
            pricePerHour: parking.pricePerHour,
            availability: parking.availability,
          });

          // Cargar espacios del parqueadero
          try {
            setSpacesLoading(true);
            const spacesResponse = await spaceService.getSpacesByParking(parkingId);
            setSpaces(spacesResponse.data || []);
          } catch (err) {
            setSpacesError('No se pudieron cargar los espacios');
            console.error('Error:', err);
          } finally {
            setSpacesLoading(false);
          }
        } catch (err) {
          setError('No se pudo cargar el parqueadero. Intenta de nuevo.');
          console.error('Error:', err);
        } finally {
          setLoading(false);
        }
      };
      loadParking();
    }
  }, [isEditMode, parkingId]);

  // Options para los selects - Por ahora solo Tunja
  const cities = ['Tunja'];
  const departments = ['Boyacá'];
  const countries = ['Colombia'];

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    console.log(`[PARKING FORM] ${name} = ${value}`);
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleAddSpaces = async () => {
    if (isEditMode && parkingId) {
      // Modo edición - agregar a BD
      try {
        setSpacesLoading(true);
        await spaceService.createSpace(parkingId);
        // Recargar espacios
        const spacesResponse = await spaceService.getSpacesByParking(parkingId);
        setSpaces(spacesResponse.data || []);
        setSpacesError('');
      } catch (err) {
        setSpacesError('No se pudo crear el espacio. Intenta de nuevo.');
        console.error('Error:', err);
      } finally {
        setSpacesLoading(false);
      }
    } else {
      // Modo creación - agregar temporalmente
      setTempSpaces([...tempSpaces, { id: `temp-${Date.now()}`, availability: true }]);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.name || !formData.address || !formData.pricePerHour) {
      setError('Por favor completa los campos obligatorios');
      return;
    }

    setLoading(true);

    try {
      // Construir dirección completa para geocodificación precisa
      const fullAddress = `${formData.address}, ${formData.city}, ${formData.department}, ${formData.country}`;
      
      const parkingData = {
        ownerId: isEditMode ? undefined : 1, // En edición viene del servidor
        name: formData.name,
        address: fullAddress,  // Dirección completa incluye ciudad, departamento, país
        city: formData.city,
        department: formData.department,
        country: formData.country,
        pricePerHour: parseFloat(formData.pricePerHour),
        availability: formData.availability,
      };

      let createdParkingId = null;

      if (isEditMode) {
        // Modo actualizar
        await parkingService.updateParking(parkingId, parkingData);
        setSuccess('✓ Parqueadero actualizado exitosamente');
      } else {
        // Modo crear
        const response = await parkingService.createParking(parkingData);
        createdParkingId = response.data?.id;
        
        // Crear espacios temporales si existen
        if (createdParkingId && tempSpaces.length > 0) {
          try {
            for (let i = 0; i < tempSpaces.length; i++) {
              await spaceService.createSpace(createdParkingId);
            }
          } catch (spaceErr) {
            console.error('Error al crear algunos espacios:', spaceErr);
            // Continuar de todas formas, los espacios se pueden agregar después
          }
        }
        
        setSuccess('✓ Parqueadero registrado exitosamente');
      }

      setTimeout(() => {
        navigate('/parkings');
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message ||
          'Error al guardar el parqueadero. Intenta de nuevo.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="parking-form-wrapper">
      {/* Header */}
      <header className="form-page-header">
        <div className="header-content">
          <div className="logo">
            <span className="logo-icon">🅿️</span>
            <span className="logo-text">EasyPark</span>
          </div>
          <div className="header-user">
            <span>Hola, {user?.name || 'Usuario'}</span>
          </div>
        </div>
      </header>

      <div className="parking-form-container">
        {/* Form Header con Cancelar */}
        <div className="form-header-bar">
          <button 
            className="btn-cancel" 
            onClick={() => navigate('/parkings')}
            type="button"
          >
            ✕ Cancelar
          </button>
          <h1>{isEditMode ? 'Editar Parqueadero' : 'Registrar Nuevo Parqueadero'}</h1>
          <div style={{ width: '120px' }}></div> {/* Spacer para alineación */}
        </div>

        {error && <div className="alert alert-error">{error}</div>}
        {success && <div className="alert alert-success">{success}</div>}

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
              placeholder="Ej: Cra 5 #7-32 (solo la dirección, sin ciudad)"
              value={formData.address}
              onChange={handleChange}
              disabled={loading}
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="city">Ciudad *</label>
              <select
                id="city"
                name="city"
                value={formData.city}
                onChange={handleChange}
                disabled={loading}
                required
              >
                {cities.map((city) => (
                  <option key={city} value={city}>
                    {city}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="department">Departamento *</label>
              <select
                id="department"
                name="department"
                value={formData.department}
                onChange={handleChange}
                disabled={loading}
                required
              >
                {departments.map((dept) => (
                  <option key={dept} value={dept}>
                    {dept}
                  </option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="country">País *</label>
              <select
                id="country"
                name="country"
                value={formData.country}
                onChange={handleChange}
                disabled={loading}
                required
              >
                {countries.map((country) => (
                  <option key={country} value={country}>
                    {country}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </fieldset>

        {/* Pricing */}
        <fieldset className="form-section">
          <legend>Tarifa</legend>

          <div className="form-group">
            <label htmlFor="pricePerHour">Tarifa por Hora (COP) *</label>
            <input
              id="pricePerHour"
              type="number"
              name="pricePerHour"
              placeholder="5000"
              value={formData.pricePerHour}
              onChange={handleChange}
              disabled={loading}
              required
              step="100"
              min="0"
            />
          </div>
        </fieldset>

        {/* Spaces Management - Disponible en ambos modos */}
        <fieldset className="form-section">
          <legend>Gestión de Espacios</legend>
          
          {spacesError && <div className="alert alert-error">{spacesError}</div>}

          <div className="spaces-info">
            <p className="spaces-count">
              Espacios {isEditMode ? 'Registrados' : 'Configurados'}: <strong>{isEditMode ? spaces.length : tempSpaces.length}</strong>
            </p>
            <button
              type="button"
              className="btn-add-space"
              onClick={handleAddSpaces}
              disabled={spacesLoading || loading}
            >
              {spacesLoading ? '⏳ Creando...' : '+ Nuevo Espacio'}
            </button>
          </div>

          {isEditMode ? (
            // Modo edición - mostrar espacios de BD
            spaces.length > 0 && (
              <div className="spaces-list">
                {spaces.map((space, index) => (
                  <div key={space.id || index} className="space-item">
                    <div className="space-number">#{index + 1}</div>
                    <div className="space-status">
                      <span className={`status-badge ${space.availability ? 'available' : 'occupied'}`}>
                        {space.availability ? '🟢 Disponible' : '🔴 Ocupado'}
                      </span>
                    </div>
                    <div className="space-id">ID: {space.id}</div>
                  </div>
                ))}
              </div>
            )
          ) : (
            // Modo creación - mostrar espacios temporales
            tempSpaces.length > 0 && (
              <div className="spaces-list">
                {tempSpaces.map((space, index) => (
                  <div key={space.id || index} className="space-item">
                    <div className="space-number">#{index + 1}</div>
                    <div className="space-status">
                      <span className="status-badge available">
                        🟢 Nuevo
                      </span>
                    </div>
                    <div className="space-id">Temporal</div>
                  </div>
                ))}
              </div>
            )
          )}
        </fieldset>

        {/* Submit Button */}
        <div className="form-actions">
          <button type="submit" className="submit-btn" disabled={loading}>
            {loading 
              ? (isEditMode ? 'Guardando cambios...' : 'Registrando...') 
              : (isEditMode ? 'Guardar Cambios' : 'Registrar Parqueadero')
            }
          </button>
        </div>
        </form>
      </div>
    </div>
  );
}
