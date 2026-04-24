import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { parkingService, spaceService } from '../services/api';
import './Spaces.css';

export default function SpacesPage() {
  const { parkingId } = useParams();
  const navigate = useNavigate();
  const [parking, setParking] = useState(null);
  const [spaces, setSpaces] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [refreshInterval, setRefreshInterval] = useState(null);

  // Cargar espacios y sus estados
  const loadSpaces = async () => {
    try {
      setError('');
      
      // Obtener detalles del parqueadero
      const parkingResponse = await parkingService.getParkingById(parkingId);
      setParking(parkingResponse.data);

      // Obtener espacios
      const spacesResponse = await spaceService.getSpacesByParking(parkingId);
      const spacesList = spacesResponse.data || [];

      // Obtener estados de cada espacio
      const spacesWithStatus = await Promise.all(
        spacesList.map(async (space) => {
          try {
            const statusResponse = await spaceService.getSpaceStatus(space.id);
            return {
              ...space,
              currentStatus: statusResponse.data || space.status,
            };
          } catch (err) {
            return {
              ...space,
              currentStatus: space.status,
            };
          }
        })
      );

      setSpaces(spacesWithStatus);
      setLoading(false);
    } catch (err) {
      console.error('Error al cargar espacios:', err);
      setError('Error al cargar los espacios. Intenta de nuevo.');
      setLoading(false);
    }
  };

  // Cargar espacios al montar el componente
  useEffect(() => {
    loadSpaces();
  }, [parkingId]);

  // Auto-refrescar si está habilitado
  useEffect(() => {
    if (autoRefresh) {
      const interval = setInterval(() => {
        loadSpaces();
      }, 5000); // Refrescar cada 5 segundos
      setRefreshInterval(interval);

      return () => clearInterval(interval);
    } else if (refreshInterval) {
      clearInterval(refreshInterval);
      setRefreshInterval(null);
    }
  }, [autoRefresh, parkingId]);

  // Estadísticas
  const stats = {
    total: spaces.length,
    available: spaces.filter((s) => s.currentStatus === 'AVAILABLE').length,
    occupied: spaces.filter((s) => s.currentStatus === 'OCCUPIED').length,
  };

  const occupancyPercentage = stats.total > 0 
    ? ((stats.occupied / stats.total) * 100).toFixed(1)
    : 0;

  if (loading) {
    return <div className="spaces-page loading">Cargando espacios...</div>;
  }

  return (
    <div className="spaces-page">
      {/* Header */}
      <header className="spaces-header">
        <div className="header-content">
          <button className="back-btn" onClick={() => navigate('/dashboard')} title="Volver al dashboard">
            ← Volver
          </button>
          <div className="header-title">
            <h1>{parking?.name}</h1>
            <p className="address">{parking?.address}</p>
          </div>
          <div className="header-actions">
            <button
              className={`refresh-btn ${autoRefresh ? 'active' : ''}`}
              onClick={() => setAutoRefresh(!autoRefresh)}
              title={autoRefresh ? 'Detener auto-refresco' : 'Iniciar auto-refresco'}
            >
              {autoRefresh ? '🔄 Actualizando...' : '⏸️ Auto-refresco desactivado'}
            </button>
            <button className="refresh-manual-btn" onClick={loadSpaces} title="Refrescar ahora">
              🔃 Refrescar
            </button>
          </div>
        </div>
      </header>

      {/* Stats */}
      <section className="spaces-stats">
        <div className="stat-card">
          <div className="stat-icon">🅿️</div>
          <div className="stat-content">
            <span className="stat-label">Total de Espacios</span>
            <span className="stat-value">{stats.total}</span>
          </div>
        </div>

        <div className="stat-card available">
          <div className="stat-icon">🟢</div>
          <div className="stat-content">
            <span className="stat-label">Disponibles</span>
            <span className="stat-value">{stats.available}</span>
          </div>
        </div>

        <div className="stat-card occupied">
          <div className="stat-icon">🔴</div>
          <div className="stat-content">
            <span className="stat-label">Ocupados</span>
            <span className="stat-value">{stats.occupied}</span>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <span className="stat-label">Ocupación</span>
            <span className="stat-value">{occupancyPercentage}%</span>
          </div>
        </div>
      </section>

      {/* Progress Bar */}
      <div className="occupancy-bar">
        <div className="bar-background">
          <div
            className="bar-fill"
            style={{ width: `${occupancyPercentage}%` }}
          ></div>
        </div>
      </div>

      {/* Error Message */}
      {error && <div className="error-message">{error}</div>}

      {/* Spaces Grid */}
      <section className="spaces-grid">
        {spaces.length === 0 ? (
          <div className="empty-state">
            <p>No hay espacios en este parqueadero</p>
          </div>
        ) : (
          spaces.map((space) => (
            <div
              key={space.id}
              className={`space-card status-${space.currentStatus.toLowerCase()}`}
            >
              <div className="space-number">{space.spaceNumber}</div>
              <div className="space-status">
                {space.currentStatus === 'AVAILABLE' ? (
                  <>
                    <span className="status-badge available">🟢 DISPONIBLE</span>
                  </>
                ) : (
                  <>
                    <span className="status-badge occupied">🔴 OCUPADO</span>
                  </>
                )}
              </div>
            </div>
          ))
        )}
      </section>

      {/* Last Updated */}
      <footer className="spaces-footer">
        <small>Última actualización: {new Date().toLocaleTimeString()}</small>
        {autoRefresh && <small className="refresh-note">Auto-refresco activo (cada 5s)</small>}
      </footer>
    </div>
  );
}
