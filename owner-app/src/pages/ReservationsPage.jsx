import React, { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { parkingService, reservationService, paymentService, notificationService } from '../services/api';
import './Reservations.css';

export default function ReservationsPage() {
  const { parkingId } = useParams();
  const [reservations, setReservations] = useState([]);
  const [parking, setParking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');
  const [notifications, setNotifications] = useState([]);
  const [showNotifications, setShowNotifications] = useState(false);
  const [invoiceModal, setInvoiceModal] = useState(null); // { reservation }
  const [invoiceAmount, setInvoiceAmount] = useState('');
  const [invoiceDesc, setInvoiceDesc] = useState('');
  const [invoiceLoading, setInvoiceLoading] = useState(false);
  const [invoiceData, setInvoiceData] = useState({}); // reservationId → invoice
  const pollingRef = useRef(null);
  const navigate = useNavigate();

  const getUserData = () => {
    try { return JSON.parse(localStorage.getItem('user')); } catch { return null; }
  };

  // El user service devuelve el campo como "userID" (mayúscula)
  const getUserId = () => {
    const u = getUserData();
    return u?.userID ?? u?.userId ?? u?.id ?? null;
  };

  const loadData = useCallback(async () => {
    const userData = getUserData();
    if (!userData) { navigate('/login'); return; }

    try {
      const [parkingRes, reservationsRes] = await Promise.allSettled([
        parkingService.getParkingById(parkingId),
        reservationService.getReservationsByParking(parkingId),
      ]);
      if (parkingRes.status === 'fulfilled') setParking(parkingRes.value.data);
      if (reservationsRes.status === 'fulfilled') {
        const list = reservationsRes.value.data || [];
        setReservations(list);
        // Cargar facturas para reservas INVOICED o COMPLETED
        const invoiceable = list.filter(r => ['INVOICED', 'COMPLETED'].includes(r.status));
        invoiceable.forEach(async (r) => {
          try {
            const res = await paymentService.getInvoiceByReservation(r.id);
            setInvoiceData(prev => ({ ...prev, [r.id]: res.data }));
          } catch {}
        });
      }
    } catch (err) {
      setError('Error al cargar los datos.');
    } finally {
      setLoading(false);
    }
  }, [parkingId, navigate]);

  const loadNotifications = useCallback(async () => {
    const userId = getUserId();
    if (!userId) return;
    try {
      const res = await notificationService.getUnread(userId);
      setNotifications(res.data || []);
    } catch {}
  }, []);

  useEffect(() => {
    loadData();
    loadNotifications();
    pollingRef.current = setInterval(() => {
      loadData();
      loadNotifications();
    }, 10000);
    return () => clearInterval(pollingRef.current);
  }, [loadData, loadNotifications]);

  const handleOwnerConfirm = async (reservationId) => {
    if (!window.confirm('¿Confirmas la llegada del conductor?')) return;
    try {
      const res = await reservationService.ownerConfirmArrival(reservationId);
      setReservations(prev => prev.map(r => r.id === reservationId ? res.data : r));
    } catch (err) {
      setError(err.response?.data?.message || 'Error al confirmar llegada.');
    }
  };

  const handleCancel = async (reservationId) => {
    if (!window.confirm('¿Cancelar la reserva porque el conductor no llegó?')) return;
    try {
      const res = await reservationService.cancelReservation(reservationId);
      setReservations(prev => prev.map(r => r.id === reservationId ? res.data : r));
    } catch (err) {
      setError(err.response?.data?.message || 'Error al cancelar.');
    }
  };

  const handleGenerateInvoice = async () => {
    if (!invoiceAmount || isNaN(parseFloat(invoiceAmount))) {
      setError('Ingresa un monto válido.'); return;
    }
    setInvoiceLoading(true);
    const userId = getUserId();
    try {
      const res = await paymentService.createInvoice({
        reservationId: invoiceModal.id,
        driverId: invoiceModal.driverId,
        ownerId: userId,
        parkingId: invoiceModal.parkingId,
        amount: parseFloat(invoiceAmount),
        description: invoiceDesc || `Pago parqueadero - Reserva #${invoiceModal.id}`,
      });
      setInvoiceData(prev => ({ ...prev, [invoiceModal.id]: res.data }));
      setReservations(prev => prev.map(r => r.id === invoiceModal.id ? { ...r, status: 'INVOICED' } : r));
      setInvoiceModal(null);
      setInvoiceAmount('');
      setInvoiceDesc('');
    } catch (err) {
      setError(err.response?.data?.message || 'Error al generar factura.');
    } finally {
      setInvoiceLoading(false);
    }
  };

  const handleMarkNotificationRead = async (id) => {
    try {
      await notificationService.markAsRead(id);
      setNotifications(prev => prev.filter(n => n.id !== id));
    } catch {}
  };

  const getDeadlineInfo = (reservation) => {
    if (!reservation.arrivalDeadline) return null;
    const deadline = new Date(reservation.arrivalDeadline);
    const now = new Date();
    const diffMs = deadline - now;
    const diffMin = Math.floor(diffMs / 60000);
    const diffSec = Math.floor((diffMs % 60000) / 1000);
    if (diffMs <= 0) return { expired: true, label: 'Plazo vencido' };
    return { expired: false, label: `${diffMin}:${String(diffSec).padStart(2,'0')} restantes` };
  };

  const filteredReservations = reservations.filter(r => {
    if (filterStatus === 'all') return true;
    if (filterStatus === 'pending') return ['ACTIVE', 'DRIVER_CONFIRMED', 'OWNER_CONFIRMED'].includes(r.status);
    return r.status?.toUpperCase() === filterStatus.toUpperCase();
  });

  const countByStatus = (s) => reservations.filter(r => r.status?.toUpperCase() === s.toUpperCase()).length;
  const countPending = reservations.filter(r => ['ACTIVE','DRIVER_CONFIRMED','OWNER_CONFIRMED'].includes(r.status)).length;

  const getStatusColor = (status) => {
    switch (status?.toUpperCase()) {
      case 'ACTIVE': return '#FF9800';
      case 'DRIVER_CONFIRMED': return '#2196F3';
      case 'OWNER_CONFIRMED': return '#9C27B0';
      case 'INVOICED': return '#FF5722';
      case 'COMPLETED': return '#4CAF50';
      case 'CANCELLED': return '#f44336';
      case 'EXPIRED': return '#9E9E9E';
      default: return '#999';
    }
  };

  const getStatusLabel = (status) => {
    switch (status?.toUpperCase()) {
      case 'ACTIVE': return '⏳ Esperando conductor';
      case 'DRIVER_CONFIRMED': return '🚗 Conductor llegó';
      case 'OWNER_CONFIRMED': return '✅ Ambos confirmados';
      case 'INVOICED': return '🧾 Factura enviada';
      case 'COMPLETED': return '💰 Pagada';
      case 'CANCELLED': return '✗ Cancelada';
      case 'EXPIRED': return '⏰ Expirada';
      default: return status;
    }
  };

  const formatDateTime = (ds) => ds ? new Date(ds).toLocaleString('es-ES', { year:'numeric', month:'short', day:'numeric', hour:'2-digit', minute:'2-digit' }) : '—';

  if (loading) return <div className="reservations-page loading">Cargando reservas...</div>;

  return (
    <div className="reservations-page">
      {/* Header */}
      <header className="reservations-header">
        <div className="header-content">
          <button className="btn-back" onClick={() => navigate('/dashboard')}>← Volver</button>
          <div className="header-title">
            <h1>Reservas: {parking?.name || 'Parqueadero'}</h1>
            <p className="parking-location">{parking?.address}</p>
          </div>
          {/* Campana de notificaciones */}
          <div className="notification-bell" onClick={() => setShowNotifications(!showNotifications)}>
            <span className="bell-icon">🔔</span>
            {notifications.length > 0 && (
              <span className="bell-badge">{notifications.length}</span>
            )}
            {showNotifications && (
              <div className="notification-dropdown">
                {notifications.length === 0
                  ? <p className="notif-empty">Sin notificaciones</p>
                  : notifications.map(n => (
                    <div key={n.id} className="notif-item">
                      <p className="notif-msg">{n.message}</p>
                      <p className="notif-time">{formatDateTime(n.createdAt)}</p>
                      <button className="notif-read" onClick={() => handleMarkNotificationRead(n.id)}>✓ Marcar leída</button>
                    </div>
                  ))
                }
              </div>
            )}
          </div>
        </div>
      </header>

      <main className="reservations-main">
        {/* Filtros */}
        <section className="filter-section">
          <div className="filter-buttons">
            <button className={`filter-btn ${filterStatus==='all'?'active':''}`} onClick={() => setFilterStatus('all')}>
              Todas ({reservations.length})
            </button>
            <button className={`filter-btn ${filterStatus==='pending'?'active':''}`} onClick={() => setFilterStatus('pending')}>
              En curso ({countPending})
            </button>
            <button className={`filter-btn ${filterStatus==='INVOICED'?'active':''}`} onClick={() => setFilterStatus('INVOICED')}>
              Facturadas ({countByStatus('INVOICED')})
            </button>
            <button className={`filter-btn ${filterStatus==='COMPLETED'?'active':''}`} onClick={() => setFilterStatus('COMPLETED')}>
              Completadas ({countByStatus('COMPLETED')})
            </button>
            <button className={`filter-btn ${filterStatus==='CANCELLED'?'active':''}`} onClick={() => setFilterStatus('CANCELLED')}>
              Canceladas ({countByStatus('CANCELLED')})
            </button>
          </div>
        </section>

        {error && (
          <div className="error-message" onClick={() => setError('')}>{error} ✕</div>
        )}

        {/* Lista */}
        <section className="reservations-section">
          {filteredReservations.length === 0 ? (
            <div className="empty-state">
              <p>No hay reservas {filterStatus !== 'all' ? 'en este estado' : ''}</p>
              <p className="empty-subtitle">Las reservas aparecerán aquí cuando los conductores realicen reservaciones</p>
            </div>
          ) : (
            <div className="reservations-list">
              {filteredReservations.map(reservation => {
                const deadlineInfo = getDeadlineInfo(reservation);
                const invoice = invoiceData[reservation.id];
                return (
                  <div key={reservation.id} className="reservation-card">
                    {/* Card Header */}
                    <div className="reservation-header">
                      <div className="reservation-info">
                        <h4>Reserva #{reservation.id}</h4>
                        <p className="reservation-driver">Conductor ID: {reservation.driverId}</p>
                        <p className="reservation-space">Espacio: {reservation.spaceId}</p>
                      </div>
                      <div className="status-badge" style={{ background: getStatusColor(reservation.status), color: '#fff' }}>
                        {getStatusLabel(reservation.status)}
                      </div>
                    </div>

                    {/* Detalles */}
                    <div className="reservation-details">
                      <div className="detail-row">
                        <span className="detail-label">📅 Inicio:</span>
                        <span className="detail-value">{formatDateTime(reservation.startTime)}</span>
                      </div>
                      {reservation.arrivalDeadline && (
                        <div className="detail-row">
                          <span className="detail-label">⏱ Plazo llegada:</span>
                          <span className="detail-value" style={{ color: deadlineInfo?.expired ? '#f44336' : '#FF9800', fontWeight: 'bold' }}>
                            {deadlineInfo?.expired ? '⚠ Plazo vencido' : deadlineInfo?.label}
                          </span>
                        </div>
                      )}
                      {reservation.driverConfirmedAt && (
                        <div className="detail-row">
                          <span className="detail-label">🚗 Conductor confirmó:</span>
                          <span className="detail-value">{formatDateTime(reservation.driverConfirmedAt)}</span>
                        </div>
                      )}
                      {reservation.ownerConfirmedAt && (
                        <div className="detail-row">
                          <span className="detail-label">✅ Propietario confirmó:</span>
                          <span className="detail-value">{formatDateTime(reservation.ownerConfirmedAt)}</span>
                        </div>
                      )}
                      {invoice && (
                        <div className="detail-row">
                          <span className="detail-label">🧾 Factura:</span>
                          <span className="detail-value">${invoice.amount} — {invoice.status}</span>
                        </div>
                      )}
                    </div>

                    {/* Acciones según estado */}
                    <div className="reservation-actions">
                      {/* DRIVER_CONFIRMED → propietario puede confirmar */}
                      {reservation.status === 'DRIVER_CONFIRMED' && (
                        <button className="btn-confirm" onClick={() => handleOwnerConfirm(reservation.id)}>
                          ✅ Confirmar Llegada
                        </button>
                      )}

                      {/* ACTIVE después del plazo → propietario puede cancelar */}
                      {reservation.status === 'ACTIVE' && reservation.canOwnerCancel && (
                        <button className="btn-cancel" onClick={() => handleCancel(reservation.id)}>
                          ✗ Cancelar (conductor no llegó)
                        </button>
                      )}

                      {/* OWNER_CONFIRMED → propietario genera factura */}
                      {reservation.status === 'OWNER_CONFIRMED' && (
                        <button className="btn-invoice" onClick={() => {
                          setInvoiceModal(reservation);
                          setInvoiceAmount('');
                          setInvoiceDesc('');
                        }}>
                          🧾 Generar Factura
                        </button>
                      )}

                      {/* INVOICED → ver URL de pago */}
                      {reservation.status === 'INVOICED' && invoice?.paymentUrl && (
                        <a className="btn-view-payment" href={invoice.paymentUrl} target="_blank" rel="noreferrer">
                          🔗 Ver link de pago
                        </a>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </main>

      {/* Modal Generar Factura */}
      {invoiceModal && (
        <div className="modal-overlay" onClick={() => setInvoiceModal(null)}>
          <div className="modal-box" onClick={e => e.stopPropagation()}>
            <h3>🧾 Generar Factura — Reserva #{invoiceModal.id}</h3>
            <p className="modal-sub">Conductor ID: {invoiceModal.driverId} · Espacio: {invoiceModal.spaceId}</p>
            <div className="modal-field">
              <label>Monto a cobrar (COP) *</label>
              <input
                type="number"
                min="0"
                step="0.01"
                placeholder="Ej: 15000"
                value={invoiceAmount}
                onChange={e => setInvoiceAmount(e.target.value)}
              />
            </div>
            <div className="modal-field">
              <label>Descripción (opcional)</label>
              <input
                type="text"
                placeholder="Ej: 2 horas de parqueo"
                value={invoiceDesc}
                onChange={e => setInvoiceDesc(e.target.value)}
              />
            </div>
            <div className="modal-actions">
              <button className="btn-cancel-modal" onClick={() => setInvoiceModal(null)}>Cancelar</button>
              <button className="btn-invoice" onClick={handleGenerateInvoice} disabled={invoiceLoading}>
                {invoiceLoading ? 'Generando...' : '🧾 Crear Factura'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
