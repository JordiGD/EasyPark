import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { parkingService, spaceService } from '../services/api';
import './Dashboard.css';

export default function DashboardPage() {
  const [parkings, setParkings] = useState([]);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [spaceCounts, setSpaceCounts] = useState({});
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
          {/* Botón para Crear Parqueadero */}
          <div className="section-header">
            <h2>Mis Parqueaderos</h2>
            <button
              className="btn-primary"
              onClick={() => navigate('/parkings/new')}
            >
              + Crear Parqueadero
            </button>
          </div>

          {error && <div className="error-message">{error}</div>}

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
                  </div>

                  <div className="parking-info">
                    <div className="info-item">
                      <span className="info-label"> Dirección:</span>
                      <span className="info-value">{parking.address}</span>
                    </div>
                    <div className="info-item">
                      <span className="info-label"> Precio/Hora:</span>
                      <span className="info-value">${parking.pricePerHour}</span>
                    </div>
                    <div className="info-item">
                      <span className="info-label"> Estado:</span>
                      <span className="info-value">
                        {parking.availability ? '🟢 Activo' : '🔴 Inactivo'}
                      </span>
                    </div>
                    <div className="info-item">
                      <span className="info-label"> Espacios:</span>
                      <span className="info-value">{spaceCounts[parking.id] || 0}</span>
                    </div>
                  </div>

                  <div className="parking-actions">
                    <button
                      className="btn-view-spaces"
                      onClick={() => navigate(`/parkings/${parking.id}/spaces`)}
                      title="Ver espacios y estados"
                    >
                      👀 Ver Espacios
                    </button>
                    <button
                      className="btn-edit"
                      onClick={() => navigate(`/parkings/${parking.id}/edit`)}
                      title="Editar parqueadero"
                    >
                      ✏️ Editar
                    </button>
                    <button
                      className="btn-delete"
                      onClick={() => {
                        if (window.confirm('¿Estás seguro de que deseas eliminar este parqueadero?')) {
                          // TODO: Implement delete functionality
                          console.log('Delete parking:', parking.id);
                        }
                      }}
                      title="Eliminar parqueadero"
                    >
                      🗘 Eliminar
                    </button>
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
