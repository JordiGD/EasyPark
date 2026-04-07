import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { userService } from '../services/api';
import './AdminAuth.css';

export default function AdminLoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const response = await userService.login(email, password);
      
      // Verificar que sea admin
      if (response.data.role !== 'admin') {
        setError('Acceso denegado. Solo administradores pueden acceder.');
        setLoading(false);
        return;
      }

      localStorage.setItem('token', response.data.token || 'admin-token');
      localStorage.setItem('admin', JSON.stringify(response.data));
      navigate('/dashboard');
    } catch (err) {
      setError(err.response?.data?.message || 'Email o contraseña incorrectos');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="admin-auth-container">
      <div className="admin-auth-card">
        <div className="admin-auth-header">
          <div className="admin-logo-icon">⚙️</div>
          <h1>EasyPark Admin</h1>
          <p className="admin-subtitle">Panel de Administración</p>
        </div>

        <form onSubmit={handleSubmit} className="admin-auth-form">
          <div className="admin-form-group">
            <label htmlFor="email">Email Administrador</label>
            <input
              id="email"
              type="email"
              placeholder="admin@easypark.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={loading}
              required
            />
          </div>

          <div className="admin-form-group">
            <label htmlFor="password">Contraseña</label>
            <div className="admin-password-input">
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={loading}
                required
              />
              <button
                type="button"
                className="admin-toggle-password"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? '🙈' : '👁️'}
              </button>
            </div>
          </div>

          {error && <div className="admin-error-message">{error}</div>}

          <button type="submit" className="admin-submit-btn" disabled={loading}>
            {loading ? 'Iniciando sesión...' : 'Acceder al Panel'}
          </button>
        </form>

        <div className="admin-security-note">
          <p>⚠️ Solo personal autorizado</p>
        </div>
      </div>
    </div>
  );
}
