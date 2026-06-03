import React, { useState, useEffect } from 'react';
import api from '../services/api';
import './Subscriptions.css';

const SubscriptionsPage = () => {
  const [tabIndex, setTabIndex] = useState(0);
  const [plans, setPlans] = useState([]);
  const [parkings, setParkings] = useState([]);
  const [selectedParking, setSelectedParking] = useState(null);
  const [subscriptions, setSubscriptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const [newPlan, setNewPlan] = useState({
    name: '',
    description: '',
    monthlyPrice: '',
    discountPercentage: '',
    maxDailyHours: '',
    monthlyHours: '',
    features: ''
  });

  const [newSubscription, setNewSubscription] = useState({
    driverEmail: '',
    planId: '',
    paymentMethod: 'CREDIT_CARD',
    autoRenew: true
  });

  useEffect(() => {
    fetchParkings();
  }, []);

  useEffect(() => {
    if (selectedParking) {
      fetchPlansByParking(selectedParking);
      fetchSubscriptionsByParking(selectedParking);
    }
  }, [selectedParking]);

  const fetchPlansByParking = async (parkingId) => {
    try {
      setLoading(true);
      const response = await api.subscriptionService.getActivePlansByParking(parkingId);
      setPlans(response.data);
      setLoading(false);
    } catch (err) {
      setError('Error al cargar planes: ' + err.message);
      setLoading(false);
    }
  };

  const fetchParkings = async () => {
    try {
      const response = await api.parkingService.getAllParkings();
      setParkings(response.data);
      if (response.data.length > 0) {
        setSelectedParking(response.data[0].id);
      }
    } catch (err) {
      setError('Error al cargar parqueaderos: ' + err.message);
    }
  };

  const fetchSubscriptionsByParking = async (parkingId) => {
    try {
      setLoading(true);
      const response = await api.subscriptionService.getSubscriptionsByParking(parkingId);
      setSubscriptions(response.data);
      setLoading(false);
    } catch (err) {
      setError('Error al cargar suscripciones: ' + err.message);
      setLoading(false);
    }
  };

  const handleCreatePlan = async (e) => {
    e.preventDefault();
    if (!selectedParking) {
      setError('Debes seleccionar un parqueadero');
      return;
    }
    try {
      setLoading(true);
      const features = newPlan.features
        .split(',')
        .map(f => f.trim())
        .filter(f => f.length > 0);

      const planData = {
        ...newPlan,
        parkingId: selectedParking,
        monthlyPrice: parseFloat(newPlan.monthlyPrice),
        discountPercentage: parseInt(newPlan.discountPercentage),
        maxDailyHours: newPlan.maxDailyHours ? parseInt(newPlan.maxDailyHours) : null,
        monthlyHours: newPlan.monthlyHours ? parseInt(newPlan.monthlyHours) : null,
        features: JSON.stringify(features)
      };

      await api.subscriptionService.createPlan(planData);
      setSuccess('Plan creado exitosamente');
      setNewPlan({
        name: '',
        description: '',
        monthlyPrice: '',
        discountPercentage: '',
        maxDailyHours: '',
        monthlyHours: '',
        features: ''
      });
      fetchPlansByParking(selectedParking);
      setLoading(false);
    } catch (err) {
      setError('Error al crear plan: ' + err.message);
      setLoading(false);
    }
  };

  const handleCreateSubscription = async (e) => {
    e.preventDefault();
    try {
      setLoading(true);
      setError('');
      
      // Buscar el driver por email
      let driverId;
      try {
        const userResponse = await api.userService.getUserByEmail(newSubscription.driverEmail);
        // La respuesta puede tener estructura diferente, necesitamos obtener el driver ID
        // Asumiendo que user tiene un campo con el ID del driver
        driverId = userResponse.data.userId || userResponse.data.id || userResponse.data.driverId;
        
        if (!driverId) {
          setError('No se encontró el ID del conductor. Por favor intenta con otro email.');
          setLoading(false);
          return;
        }
      } catch (err) {
        setError('No se encontró usuario con ese email. Verifica el correo e intenta nuevamente.');
        setLoading(false);
        return;
      }

      const subscriptionData = {
        driverEmail: newSubscription.driverEmail,
        parkingId: parseInt(selectedParking),
        planId: parseInt(newSubscription.planId),
        paymentMethod: newSubscription.paymentMethod,
        autoRenew: newSubscription.autoRenew
      };

      await api.subscriptionService.createSubscriptionByEmail(subscriptionData);
      setSuccess('Suscripción asignada exitosamente');
      setNewSubscription({
        driverEmail: '',
        planId: '',
        paymentMethod: 'CREDIT_CARD',
        autoRenew: true
      });
      fetchSubscriptionsByParking(selectedParking);
      setLoading(false);
    } catch (err) {
      setError('Error al asignar suscripción: ' + err.message);
      setLoading(false);
    }
  };

  const handleCancelSubscription = async (subscriptionId) => {
    if (window.confirm('¿Cancelar esta suscripción?')) {
      try {
        setLoading(true);
        await api.subscriptionService.cancelSubscription(subscriptionId);
        setSuccess('Suscripción cancelada');
        fetchSubscriptionsByParking(selectedParking);
        setLoading(false);
      } catch (err) {
        setError('Error: ' + err.message);
        setLoading(false);
      }
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'ACTIVE':
        return '#4CAF50';
      case 'EXPIRED':
        return '#999999';
      case 'CANCELLED':
        return '#F44336';
      case 'PAUSED':
        return '#FF9800';
      default:
        return '#2196F3';
    }
  };

  return (
    <div className="subscriptions-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
        <h1>Gestión de Suscripciones por Parqueadero</h1>
        <button 
          onClick={() => window.history.back()} 
          style={{
            padding: '10px 20px',
            backgroundColor: '#6c757d',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer',
            fontSize: '14px'
          }}
        >
          ← Volver
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">{success}</div>}

      <div style={{ background: '#f9f9f9', padding: '15px', borderRadius: '8px', marginBottom: '20px' }}>
        <label style={{ fontWeight: 'bold', marginRight: '10px' }}>Parqueadero:</label>
        <select
          value={selectedParking || ''}
          onChange={(e) => setSelectedParking(parseInt(e.target.value))}
          style={{ padding: '8px 12px', fontSize: '14px', borderRadius: '4px', minWidth: '250px' }}
        >
          {parkings.map((parking) => (
            <option key={parking.id} value={parking.id}>
              {parking.name} - {parking.address}
            </option>
          ))}
        </select>
      </div>

      <div className="tabs">
        <button className={`tab-button ${tabIndex === 0 ? 'active' : ''}`} onClick={() => setTabIndex(0)}>
          Planes
        </button>
        <button className={`tab-button ${tabIndex === 1 ? 'active' : ''}`} onClick={() => setTabIndex(1)}>
          Crear Plan
        </button>
        <button className={`tab-button ${tabIndex === 2 ? 'active' : ''}`} onClick={() => setTabIndex(2)}>
          Asignar Suscripción
        </button>
        <button className={`tab-button ${tabIndex === 3 ? 'active' : ''}`} onClick={() => setTabIndex(3)}>
          Suscriptores ({subscriptions.length})
        </button>        <button onClick={() => window.location.href = '/'} style={{ marginLeft: 'auto', padding: '8px 16px', backgroundColor: '#666', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
          ← Volver al Inicio
        </button>      </div>

      {tabIndex === 0 && (
        <div className="tab-content">
          <h2>Planes Disponibles</h2>
          <div className="plans-grid">
            {plans.map((plan) => (
              <div key={plan.id} className="plan-card">
                <h3>{plan.name}</h3>
                <p className="plan-description">{plan.description}</p>
                <div className="plan-price">${plan.monthlyPrice.toFixed(2)}/mes</div>
                <div className="plan-features"><strong>Descuento:</strong> {plan.discountPercentage}%</div>
                {plan.maxDailyHours && <div className="plan-features"><strong>Horas/día:</strong> {plan.maxDailyHours}</div>}
                {plan.monthlyHours && <div className="plan-features"><strong>Horas/mes:</strong> {plan.monthlyHours}</div>}
              </div>
            ))}
          </div>
        </div>
      )}

      {tabIndex === 1 && (
        <div className="tab-content">
          <h2>Crear Nuevo Plan</h2>
          <form onSubmit={handleCreatePlan} className="subscription-form">
            <input type="text" placeholder="Nombre" value={newPlan.name} onChange={(e) => setNewPlan({ ...newPlan, name: e.target.value })} required />
            <textarea placeholder="Descripción" value={newPlan.description} onChange={(e) => setNewPlan({ ...newPlan, description: e.target.value })} required />
            <input type="number" step="0.01" placeholder="Precio Mensual" value={newPlan.monthlyPrice} onChange={(e) => setNewPlan({ ...newPlan, monthlyPrice: e.target.value })} required />
            <input type="number" placeholder="% Descuento" value={newPlan.discountPercentage} onChange={(e) => setNewPlan({ ...newPlan, discountPercentage: e.target.value })} required />
            <input type="number" placeholder="Horas/Día (opcional)" value={newPlan.maxDailyHours} onChange={(e) => setNewPlan({ ...newPlan, maxDailyHours: e.target.value })} />
            <input type="number" placeholder="Horas/Mes (opcional)" value={newPlan.monthlyHours} onChange={(e) => setNewPlan({ ...newPlan, monthlyHours: e.target.value })} />
            <input type="text" placeholder="Características (coma separadas)" value={newPlan.features} onChange={(e) => setNewPlan({ ...newPlan, features: e.target.value })} />
            <button type="submit" className="btn-primary" disabled={loading}>{loading ? 'Creando...' : 'Crear Plan'}</button>
          </form>
        </div>
      )}

      {tabIndex === 2 && (
        <div className="tab-content">
          <h2>Asignar Suscripción</h2>
          <p><strong>Parqueadero:</strong> {parkings.find(p => p.id === selectedParking)?.name}</p>
          <form onSubmit={handleCreateSubscription} className="subscription-form">
            <input type="email" placeholder="Email del Conductor" value={newSubscription.driverEmail} onChange={(e) => setNewSubscription({ ...newSubscription, driverEmail: e.target.value })} required />
            <select value={newSubscription.planId} onChange={(e) => setNewSubscription({ ...newSubscription, planId: e.target.value })} required>
              <option value="">Seleccionar Plan</option>
              {plans.map((plan) => (<option key={plan.id} value={plan.id}>{plan.name} - ${plan.monthlyPrice.toFixed(2)}/mes</option>))}
            </select>
            <select value={newSubscription.paymentMethod} onChange={(e) => setNewSubscription({ ...newSubscription, paymentMethod: e.target.value })}>
              <option value="CREDIT_CARD">Tarjeta</option>
              <option value="BANK_ACCOUNT">Banco</option>
              <option value="WALLET">Billetera</option>
            </select>
            <label><input type="checkbox" checked={newSubscription.autoRenew} onChange={(e) => setNewSubscription({ ...newSubscription, autoRenew: e.target.checked })} /> Renovación Automática</label>
            <button type="submit" className="btn-primary" disabled={loading}>{loading ? 'Asignando...' : 'Asignar'}</button>
          </form>
        </div>
      )}

      {tabIndex === 3 && (
        <div className="tab-content">
          <h2>Suscriptores</h2>
          <p><strong>Parqueadero:</strong> {parkings.find(p => p.id === selectedParking)?.name}</p>
          {subscriptions.length > 0 ? (
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead><tr style={{ background: '#f5f5f5' }}>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Driver</th>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Plan</th>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Estado</th>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Pago</th>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Renovación</th>
                <th style={{ padding: '10px', textAlign: 'left', borderBottom: '2px solid #ddd' }}>Acciones</th>
              </tr></thead>
              <tbody>
                {subscriptions.map((sub) => (
                  <tr key={sub.id} style={{ borderBottom: '1px solid #ddd' }}>
                    <td style={{ padding: '10px' }}>{sub.driverId}</td>
                    <td style={{ padding: '10px' }}>{sub.planName}</td>
                    <td style={{ padding: '10px' }}><span style={{ background: getStatusColor(sub.status), color: 'white', padding: '4px 8px', borderRadius: '4px' }}>{sub.status}</span></td>
                    <td style={{ padding: '10px' }}>{sub.paymentMethod}</td>
                    <td style={{ padding: '10px' }}>{new Date(sub.renewalDate).toLocaleDateString()}</td>
                    <td style={{ padding: '10px' }}>{sub.status === 'ACTIVE' && <button className="btn-cancel" onClick={() => handleCancelSubscription(sub.id)} disabled={loading}>Cancelar</button>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <p>No hay suscripciones</p>
          )}
        </div>
      )}
    </div>
  );
};

export default SubscriptionsPage;