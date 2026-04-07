import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ownerService } from '../services/api';
import './Dashboard.css';

export default function DashboardPage() {
  const [parkings, setParkings] = useState([]);
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) {
      setUser(JSON.parse(userData));
    } else {
      navigate('/login');
    }
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="dashboard-header">
        <div className="header-content">
          <div className="logo">
            <span className="logo-icon">🅿️</span>
            <span className="logo-text">EasyPark</span>
          </div>

          <nav className="nav-menu">
            <Link to="/dashboard" className="nav-link active">
              Dashboard
            </Link>
            <Link to="/parkings" className="nav-link">
              Mis Parqueaderos
            </Link>
            <Link to="/profile" className="nav-link">
              Mi Perfil
            </Link>
          </nav>

          <div className="header-actions">
            <button className="logout-btn" onClick={handleLogout}>
              Cerrar Sesión
            </button>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="dashboard-main">
        {/* Welcome Section */}
        <section className="welcome-section">
          <h1>¡Bienvenido, {user?.firstName}! 👋</h1>
          <p className="welcome-subtitle">
            Gestiona tus parqueaderos y maximiza tus ganancias
          </p>
        </section>

        {/* Stats Cards */}
        <section className="stats-section">
          <div className="stat-card">
            <div className="stat-icon">🏢</div>
            <div className="stat-content">
              <h3>Parqueaderos</h3>
              <p className="stat-value">0</p>
              <p className="stat-label">Activos</p>
            </div>
          </div>

          <div className="stat-card">
            <div className="stat-icon">🚗</div>
            <div className="stat-content">
              <h3>Espacios</h3>
              <p className="stat-value">0</p>
              <p className="stat-label">Disponibles</p>
            </div>
          </div>

          <div className="stat-card">
            <div className="stat-icon">💰</div>
            <div className="stat-content">
              <h3>Ingresos</h3>
              <p className="stat-value">$0</p>
              <p className="stat-label">Este mes</p>
            </div>
          </div>

          <div className="stat-card">
            <div className="stat-icon">📊</div>
            <div className="stat-content">
              <h3>Ocupación</h3>
              <p className="stat-value">0%</p>
              <p className="stat-label">Promedio</p>
            </div>
          </div>
        </section>

        {/* Quick Actions */}
        <section className="quick-actions-section">
          <h2>Acciones Rápidas</h2>
          <div className="actions-grid">
            <Link to="/parkings/new" className="action-card">
              <div className="action-icon">➕</div>
              <h3>Nuevo Parqueadero</h3>
              <p>Registra un nuevo parqueadero</p>
            </Link>

            <Link to="/parkings" className="action-card">
              <div className="action-icon">📋</div>
              <h3>Ver Parqueaderos</h3>
              <p>Gestiona tus espacios</p>
            </Link>

            <Link to="/profile" className="action-card">
              <div className="action-icon">⚙️</div>
              <h3>Configuración</h3>
              <p>Edita tu información</p>
            </Link>
          </div>
        </section>

        {/* Recent Activity */}
        <section className="activity-section">
          <h2>Actividad Reciente</h2>
          <div className="activity-list">
            <p className="no-activity">No hay actividad aún</p>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="dashboard-footer">
        <p>&copy; 2024 EasyPark. Todos los derechos reservados.</p>
      </footer>
    </div>
  );
}
