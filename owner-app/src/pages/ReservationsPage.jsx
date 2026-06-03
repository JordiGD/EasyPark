import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { parkingService, reservationService } from '../services/api';
import './Reservations.css';

export default function ReservationsPage() {
  const { parkingId } = useParams();
  const [reservations, setReservations] = useState([]);
  const [parking, setParking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filterStatus, setFilterStatus] = useState('all'); // all, active, cancelled, completed
  const navigate = useNavigate();

  // Cargar reservas y datos del parqueadero
  useEffect(() => {
    const loadData = async () => {
      try {
        const userData = localStorage.getItem('user');
        if (!userData) {
          navigate('/login');
          return;
        }

        // Obtener datos del parqueadero
        try {
          const parkingResponse = await parkingService.getParkingById(parkingId);
          setParking(parkingResponse.data);
        } catch (err) {
          console.error('Error al cargar parqueadero:', err);
        }

        // Obtener reservas
        try {
          const reservationsResponse = await reservationService.getReservationsByParking(parkingId);
          setReservations(reservationsResponse.data || []);
        } catch (err) {
          console.error('Error al cargar reservas:', err);
          setReservations([]);
        }

        setLoading(false);
      } catch (err) {
        console.error('Error al cargar datos:', err);
        setError('Error al cargar los datos. Intenta de nuevo.');
        setLoading(false);
      }
    };

    loadData();
  }, [parkingId, navigate]);

  // Cancelar reserva
  const handleCancelReservation = async (reservationId) => {
    const confirmation = window.confirm(
      '¿Estás seguro de que deseas cancelar esta reserva?'
    );

    if (!confirmation) return;

    try {
      await reservationService.cancelReservation(reservationId);
      setReservations(
        reservations.map((r) =>
          r.id === reservationId ? { ...r, status: 'CANCELLED' } : r
        )
      );
    } catch (err) {
      console.error('Error al cancelar reserva:', err);
      setError('Error al cancelar la reserva. Intenta de nuevo.');
    }
  };

  // Completar reserva
  const handleCompleteReservation = async (reservationId) => {
    const confirmation = window.confirm(
      '¿Estás seguro de que deseas marcar esta reserva como completada?'
    );

    if (!confirmation) return;

    try {
      await reservationService.completeReservation(reservationId);
      setReservations(
        reservations.map((r) =>
          r.id === reservationId ? { ...r, status: 'COMPLETED' } : r
        )
      );
    } catch (err) {
      console.error('Error al completar reserva:', err);
      setError('Error al completar la reserva. Intenta de nuevo.');
    }
  };

  // Filtrar reservas
  const filteredReservations = reservations.filter((r) => {
    if (filterStatus === 'all') return true;
    return r.status?.toLowerCase() === filterStatus.toLowerCase();
  });

  // Formatear fecha y hora
  const formatDateTime = (dateString) => {
    return new Date(dateString).toLocaleDateString('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  // Obtener color de estado
  const getStatusColor = (status) => {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return '#4CAF50';
      case 'COMPLETED':
        return '#2196F3';
      case 'CANCELLED':
        return '#f44336';
      default:
        return '#999';
    }
  };

  // Obtener etiqueta de estado
  const getStatusLabel = (status) => {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return '🟢 Activa';
      case 'COMPLETED':
        return '✓ Completada';
      case 'CANCELLED':
        return '✗ Cancelada';
      default:
        return status;
    }
  };

  if (loading) {
    return <div className="reservations-page loading">Cargando reservas...</div>;
  }

  return (
    <div className="reservations-page">
      {/* Header */}
      <header className="reservations-header">
        <div className="header-content">
          <button
            className="btn-back"
            onClick={() => navigate('/dashboard')}
            title="Volver"
          >
            ← Volver
          </button>
          <div className="header-title">
            <h1>Reservas: {parking?.name || 'Parqueadero'}</h1>
            <p className="parking-location">{parking?.address}</p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="reservations-main">
        {/* Filter */}
        <section className="filter-section">
          <div className="filter-buttons">
            <button
              className={`filter-btn ${filterStatus === 'all' ? 'active' : ''}`}
              onClick={() => setFilterStatus('all')}
            >
              Todas ({reservations.length})
            </button>
            <button
              className={`filter-btn ${filterStatus === 'active' ? 'active' : ''}`}
              onClick={() => setFilterStatus('active')}
            >
              Activas (
              {reservations.filter((r) => r.status?.toUpperCase() === 'ACTIVE').length})
            </button>
            <button
              className={`filter-btn ${filterStatus === 'completed' ? 'active' : ''}`}
              onClick={() => setFilterStatus('completed')}
            >
              Completadas (
              {reservations.filter((r) => r.status?.toUpperCase() === 'COMPLETED').length})
            </button>
            <button
              className={`filter-btn ${filterStatus === 'cancelled' ? 'active' : ''}`}
              onClick={() => setFilterStatus('cancelled')}
            >
              Canceladas (
              {reservations.filter((r) => r.status?.toUpperCase() === 'CANCELLED').length})
            </button>
          </div>
        </section>

        {error && <div className="error-message">{error}</div>}

        {/* Reservations List */}
        <section className="reservations-section">
          {filteredReservations.length === 0 ? (
            <div className="empty-state">
              <p>No hay reservas {filterStatus !== 'all' ? 'en este estado' : ''}</p>
              <p className="empty-subtitle">
                Las reservas aparecerán aquí cuando los conductores realicen reservaciones
              </p>
            </div>
          ) : (
            <div className="reservations-list">
              {filteredReservations.map((reservation) => (
                <div key={reservation.id} className="reservation-card">
                  <div className="reservation-header">
                    <div className="reservation-info">
                      <h4>Reserva #{reservation.id}</h4>
                      <p className="reservation-driver">Conductor ID: {reservation.driverId}</p>
                      <p className="reservation-space">Espacio: {reservation.spaceId}</p>
                    </div>
                    <div
                      className="status-badge"
                      style={{ borderColor: getStatusColor(reservation.status) }}
                    >
                      {getStatusLabel(reservation.status)}
                    </div>
                  </div>

                  <div className="reservation-details">
                    <div className="detail-row">
                      <span className="detail-label">📅 Fecha de Inicio:</span>
                      <span className="detail-value">
                        {formatDateTime(reservation.startTime)}
                      </span>
                    </div>
                    <div className="detail-row">
                      <span className="detail-label">📅 Fecha de Fin:</span>
                      <span className="detail-value">
                        {formatDateTime(reservation.endTime)}
                      </span>
                    </div>
                    {reservation.actualEndTime && (
                      <div className="detail-row">
                        <span className="detail-label">✓ Fin Real:</span>
                        <span className="detail-value">
                          {formatDateTime(reservation.actualEndTime)}
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Actions */}
                  {reservation.status?.toUpperCase() === 'ACTIVE' && (
                    <div className="reservation-actions">
                      <button
                        className="btn-complete"
                        onClick={() => handleCompleteReservation(reservation.id)}
                        title="Marcar como completada"
                      >
                        ✓ Completar
                      </button>
                      <button
                        className="btn-cancel"
                        onClick={() => handleCancelReservation(reservation.id)}
                        title="Cancelar reserva"
                      >
                        ✗ Cancelar
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
