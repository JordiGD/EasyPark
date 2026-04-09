import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parkingService, spaceService } from '../services/api';
import './Dashboard.css';

export default function DashboardPage() {
  const [parkings, setParkings] = useState([]);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [spaceCounts, setSpaceCounts] = useState({}); // Para contar espacios por parqueadero
  const [formData, setFormData] = useState({
    name: '',
    address: '',
    pricePerHour: '',
    availability: '',
    numSpaces: '',
  });
  const navigate = useNavigate();

  // Cargar usuario y parqueaderos
  useEffect(() => {
    const loadData = async () => {
      try {
        const userData = localStorage.getItem('user');
        if (!userData) {
          navigate('/login');
          return;
        }

        const parsedUser = JSON.parse(userData);
        setUser(parsedUser);

        // Obtener parqueaderos del propietario
        try {
          const parkingsResponse = await parkingService.getParkingsByOwner(parsedUser.userID);
          const parkingsList = parkingsResponse.data || [];
          setParkings(parkingsList);

          // Obtener cantidad de espacios para cada parqueadero
          const counts = {};
          for (const parking of parkingsList) {
            try {
              const spacesResponse = await spaceService.getSpacesByParking(parking.id);
              counts[parking.id] = spacesResponse.data ? spacesResponse.data.length : 0;
            } catch (err) {
              counts[parking.id] = 0;
            }
          }
          setSpaceCounts(counts);
        } catch (parkingErr) {
          // Si no encuentra parqueaderos, simplemente mostrar lista vacía
          console.log('No hay parqueaderos o error al cargar:', parkingErr);
          setParkings([]);
        }
        
        setLoading(false);
      } catch (err) {
        console.error('Error al cargar datos:', err);
        setError('Error al cargar los datos. Intenta de nuevo.');
        setLoading(false);
      }
    };

    loadData();
  }, [navigate]);

  // Manejar cambios en el formulario
  const handleFormChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  // Crear nuevo parqueadero
  const handleCreateParking = async (e) => {
    e.preventDefault();
    if (!user) return;

    try {
      const parkingData = {
        name: formData.name,
        address: formData.address,
        pricePerHour: parseFloat(formData.pricePerHour) || 0,
        availability: formData.availability === 'true',
        ownerId: user.userID,
        latitude: 0,
        longitude: 0,
      };

      const parkingResponse = await parkingService.createParking(parkingData);
      const newParking = parkingResponse.data;

      // Crear los espacios si se especificó una cantidad
      if (formData.numSpaces && parseInt(formData.numSpaces) > 0) {
        await spaceService.createMultipleSpaces(newParking.id, parseInt(formData.numSpaces));
      }

      // Recargar parqueaderos y espacios
      const parkingsResponse = await parkingService.getParkingsByOwner(user.userID);
      const parkingsList = parkingsResponse.data || [];
      setParkings(parkingsList);

      // Actualizar conteo de espacios
      const counts = {};
      for (const parking of parkingsList) {
        try {
          const spacesResponse = await spaceService.getSpacesByParking(parking.id);
          counts[parking.id] = spacesResponse.data ? spacesResponse.data.length : 0;
        } catch (err) {
          counts[parking.id] = 0;
        }
      }
      setSpaceCounts(counts);

      // Limpiar formulario
      setFormData({
        name: '',
        address: '',
        pricePerHour: '',
        availability: '',
        numSpaces: '',
      });
      setShowCreateForm(false);
      setError('');
    } catch (err) {
      console.error('Error al crear parqueadero:', err);
      setError('No se pudo crear el parqueadero. Verifica los datos e intenta de nuevo.');
    }
  };

  // Actualizar parqueadero
  const handleUpdateParking = async (e) => {
    e.preventDefault();
    if (!editingId || !user) return;

    try {
      const parkingData = {
        name: formData.name,
        address: formData.address,
        pricePerHour: parseFloat(formData.pricePerHour) || 0,
        availability: formData.availability === 'true', // Convertir a boolean
        ownerId: user.userID,
        latitude: 0, // Valores por defecto
        longitude: 0, // Valores por defecto
      };

      await parkingService.updateParking(editingId, parkingData);

      // Si se especificó un cambio en la cantidad de espacios
      const numSpaces = formData.numSpaces ? parseInt(formData.numSpaces) : null;
      if (numSpaces !== null) {
        const currentSpaceCount = spaceCounts[editingId] || 0;
        if (numSpaces > currentSpaceCount) {
          // Agregar espacios
          const difference = numSpaces - currentSpaceCount;
          await spaceService.createMultipleSpaces(editingId, difference);
        }
      }

      // Recargar parqueaderos y espacios
      const parkingsResponse = await parkingService.getParkingsByOwner(user.userID);
      const parkingsList = parkingsResponse.data || [];
      setParkings(parkingsList);

      // Actualizar conteo de espacios
      const counts = {};
      for (const parking of parkingsList) {
        try {
          const spacesResponse = await spaceService.getSpacesByParking(parking.id);
          counts[parking.id] = spacesResponse.data ? spacesResponse.data.length : 0;
        } catch (err) {
          counts[parking.id] = 0;
        }
      }
      setSpaceCounts(counts);

      // Limpiar formulario
      setFormData({
        name: '',
        address: '',
        pricePerHour: '',
        availability: '',
        numSpaces: '',
      });
      setEditingId(null);
      setError(''); // Limpiar error si lo había
    } catch (err) {
      console.error('Error al actualizar parqueadero:', err);
      setError('No se pudo actualizar el parqueadero. Intenta de nuevo.');
    }
  };

  // Editar parqueadero
  const handleEditParking = (parking) => {
    setFormData({
      name: parking.name,
      address: parking.address,
      pricePerHour: parking.pricePerHour || '',
      availability: parking.availability ? 'true' : 'false',
      numSpaces: spaceCounts[parking.id] || 0,
    });
    setEditingId(parking.id);
    setShowCreateForm(true);
  };

  // Cancelar edición
  const handleCancel = () => {
    setFormData({
      name: '',
      address: '',
      pricePerHour: '',
      availability: '',
      numSpaces: '',
    });
    setEditingId(null);
    setShowCreateForm(false);
  };

  // Logout
  const handleLogout = () => {
    localStorage.removeItem('user');
    localStorage.removeItem('email');
    localStorage.removeItem('isAuthenticated');
    navigate('/login');
  };

  if (loading) {
    return <div className="dashboard loading">Cargando...</div>;
  }

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <div className="logo">
            <span className="logo-icon">🅿️</span>
            <span className="logo-text">EasyPark</span>
          </div>

          <div className="header-user">
            <span>Bienvenido, {user?.name}</span>
            <button className="profile-btn" onClick={() => navigate('/profile')} title="Editar perfil">
              👤 Mi Perfil
            </button>
            <button className="logout-btn" onClick={handleLogout}>
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="dashboard-main">
        <section className="parking-section">
          <div className="section-header">
            <h2>Mis Parqueaderos</h2>
            <button
              className="btn-primary"
              onClick={() => {
                setShowCreateForm(!showCreateForm);
                setEditingId(null);
              }}
            >
              {showCreateForm && !editingId ? '✕ Cancelar' : '+ Crear Parqueadero'}
            </button>
          </div>

          {error && <div className="error-message">{error}</div>}

          {/* Formulario de Crear/Actualizar */}
          {showCreateForm && (
            <form
              className="parking-form"
              onSubmit={editingId ? handleUpdateParking : handleCreateParking}
            >
              <h3>{editingId ? 'Actualizar Parqueadero' : 'Crear Nuevo Parqueadero'}</h3>

              <div className="form-group">
                <label htmlFor="name">Nombre del Parqueadero</label>
                <input
                  id="name"
                  type="text"
                  name="name"
                  placeholder="Ej: Parqueadero Centro"
                  value={formData.name}
                  onChange={handleFormChange}
                  required
                />
              </div>

              <div className="form-group">
                <label htmlFor="address">Dirección</label>
                <input
                  id="address"
                  type="text"
                  name="address"
                  placeholder="Ej: Calle 50 # 10-20"
                  value={formData.address}
                  onChange={handleFormChange}
                  required
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label htmlFor="pricePerHour">Precio por Hora ($)</label>
                  <input
                    id="pricePerHour"
                    type="number"
                    name="pricePerHour"
                    placeholder="Ej: 5000"
                    value={formData.pricePerHour}
                    onChange={handleFormChange}
                    step="0.01"
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="availability">Estado</label>
                  <select
                    id="availability"
                    name="availability"
                    value={formData.availability}
                    onChange={handleFormChange}
                    required
                  >
                    <option value="">Selecciona estado</option>
                    <option value="true">Activo</option>
                    <option value="false">Inactivo</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label htmlFor="numSpaces">
                  {editingId ? 'Ajustar Cantidad de Espacios' : 'Cantidad de Espacios'}
                </label>
                <input
                  id="numSpaces"
                  type="number"
                  name="numSpaces"
                  placeholder="Ej: 50"
                  value={formData.numSpaces}
                  onChange={handleFormChange}
                  min="0"
                />
                {editingId && spaceCounts[editingId] && (
                  <p className="form-helper">
                    Espacios actuales: {spaceCounts[editingId]}
                  </p>
                )}
              </div>

              <div className="form-actions">
                <button type="submit" className="btn-primary">
                  {editingId ? 'Actualizar' : 'Crear'}
                </button>
                <button type="button" className="btn-secondary" onClick={handleCancel}>
                  Cancelar
                </button>
              </div>
            </form>
          )}

          {/* Lista de Parqueaderos */}
          <div className="parkings-list">
            {parkings.length === 0 ? (
              <div className="empty-state">
                <p>No tienes parqueaderos registrados aún</p>
                <p className="empty-subtitle">Crea uno para comenzar</p>
              </div>
            ) : (
              parkings.map((parking) => (
                <div key={parking.id} className="parking-card">
                  <div className="parking-header">
                    <h4>{parking.name}</h4>
                    <div className="parking-actions">
                      <button
                        className="btn-edit"
                        onClick={() => handleEditParking(parking)}
                      >
                        ✏️ Editar
                      </button>
                    </div>
                  </div>

                  <div className="parking-info">
                    <div className="info-item">
                      <span className="info-label">📍 Dirección:</span>
                      <span className="info-value">{parking.address}</span>
                    </div>
                    <div className="info-item">
                      <span className="info-label">💰 Precio/Hora:</span>
                      <span className="info-value">${parking.pricePerHour}</span>
                    </div>
                    <div className="info-item">
                      <span className="info-label">✓ Estado:</span>
                      <span className="info-value">
                        {parking.availability ? '🟢 Activo' : '🔴 Inactivo'}
                      </span>
                    </div>
                    <div className="info-item">
                      <span className="info-label">🅿️ Espacios:</span>
                      <span className="info-value">{spaceCounts[parking.id] || 0}</span>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </section>
      </main>
    </div>
  );
}
