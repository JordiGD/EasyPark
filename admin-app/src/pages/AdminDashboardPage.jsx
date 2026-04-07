import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { userService, driverService, ownerService } from '../services/api';
import './AdminDashboard.css';

export default function AdminDashboardPage() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalDrivers: 0,
    totalOwners: 0,
  });
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const adminData = localStorage.getItem('admin');
    if (adminData) {
      setAdmin(JSON.parse(adminData));
    } else {
      navigate('/login');
    }

    loadStats();
  }, [navigate]);

  const loadStats = async () => {
    setLoading(true);
    try {
      const [usersRes, driversRes, ownersRes] = await Promise.all([
        userService.getAllUsers().catch(() => ({ data: [] })),
        driverService.getAllDrivers().catch(() => ({ data: [] })),
        ownerService.getAllOwners().catch(() => ({ data: [] })),
      ]);

      setStats({
        totalUsers: usersRes.data?.length || 0,
        totalDrivers: driversRes.data?.length || 0,
        totalOwners: ownersRes.data?.length || 0,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('admin');
    navigate('/login');
  };

  return (
    <div className="admin-dashboard">
      {/* Header */}
      <header className="admin-header">
        <div className="admin-header-content">
          <div className="admin-logo">
            <span className="admin-logo-icon">⚙️</span>
            <span className="admin-logo-text">EasyPark Admin</span>
          </div>

          <nav className="admin-nav">
            <a href="/dashboard" className="admin-nav-link active">
              Dashboard
            </a>
            <a href="/users" className="admin-nav-link">
              Usuarios
            </a>
            <a href="/drivers" className="admin-nav-link">
              Conductores
            </a>
            <a href="/owners" className="admin-nav-link">
              Propietarios
            </a>
          </nav>

          <div className="admin-header-actions">
            <button className="admin-logout-btn" onClick={handleLogout}>
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="admin-main">
        {/* Welcome */}
        <section className="admin-welcome-section">
          <h1>Panel de Control 📊</h1>
          <p className="admin-welcome-subtitle">
            Bienvenido, {admin?.firstName || 'Administrador'}
          </p>
        </section>

        {/* Stats */}
        <section className="admin-stats-section">
          <div className="admin-stat-card">
            <div className="admin-stat-icon">👥</div>
            <div className="admin-stat-content">
              <h3>Total de Usuarios</h3>
              <p className="admin-stat-value">{stats.totalUsers}</p>
            </div>
          </div>

          <div className="admin-stat-card">
            <div className="admin-stat-icon">🚗</div>
            <div className="admin-stat-content">
              <h3>Conductores</h3>
              <p className="admin-stat-value">{stats.totalDrivers}</p>
            </div>
          </div>

          <div className="admin-stat-card">
            <div className="admin-stat-icon">🅿️</div>
            <div className="admin-stat-content">
              <h3>Propietarios</h3>
              <p className="admin-stat-value">{stats.totalOwners}</p>
            </div>
          </div>

          <div className="admin-stat-card">
            <div className="admin-stat-icon">⚙️</div>
            <div className="admin-stat-content">
              <h3>Sistema</h3>
              <p className="admin-stat-value">Activo</p>
            </div>
          </div>
        </section>

        {/* Quick Actions */}
        <section className="admin-actions-section">
          <h2>Acciones Rápidas</h2>
          <div className="admin-actions-grid">
            <a href="/users" className="admin-action-card">
              <div className="admin-action-icon">👥</div>
              <h3>Gestionar Usuarios</h3>
              <p>Ver y editar todos los usuarios</p>
            </a>

            <a href="/drivers" className="admin-action-card">
              <div className="admin-action-icon">🚗</div>
              <h3>Gestionar Conductores</h3>
              <p>Control de conductores registrados</p>
            </a>

            <a href="/owners" className="admin-action-card">
              <div className="admin-action-icon">🅿️</div>
              <h3>Gestionar Propietarios</h3>
              <p>Administrar propietarios de parqueaderos</p>
            </a>

            <a href="/settings" className="admin-action-card">
              <div className="admin-action-icon">⚙️</div>
              <h3>Configuración</h3>
              <p>Ajustes del sistema</p>
            </a>
          </div>
        </section>

        {/* System Info */}
        <section className="admin-info-section">
          <h2>Información del Sistema</h2>
          <div className="admin-info-box">
            <div className="admin-info-item">
              <span className="admin-info-label">Estado:</span>
              <span className="admin-info-value status-active">Active</span>
            </div>

            <div className="admin-info-item">
              <span className="admin-info-label">API URL:</span>
              <span className="admin-info-value">
                {process.env.REACT_APP_API_URL || 'http://localhost:8080'}
              </span>
            </div>

            <div className="admin-info-item">
              <span className="admin-info-label">Última Sincronización:</span>
              <span className="admin-info-value">Hace unos momentos</span>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="admin-footer">
        <p>&copy; 2024 EasyPark Admin. Todos los derechos reservados.</p>
      </footer>
    </div>
  );
}
