import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { userService } from '../services/api';
import './UserProfile.css';

export default function UserProfilePage() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phoneNumber: '',
    password: '',
    newPassword: '',
    confirmPassword: '',
  });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [showPasswordFields, setShowPasswordFields] = useState(false);

  useEffect(() => {
    // Cargar datos del usuario desde localStorage
    const storedUser = localStorage.getItem('user');
    const email = localStorage.getItem('email');

    if (!storedUser || !email) {
      navigate('/login');
      return;
    }

    const userData = JSON.parse(storedUser);
    setUser(userData);
    setFormData({
      name: userData.name || '',
      email: userData.email || email,
      phoneNumber: userData.phoneNumber || '',
      password: '',
      newPassword: '',
      confirmPassword: '',
    });
    setLoading(false);
  }, [navigate]);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
    // Limpiar mensajes cuando el usuario edita
    setError('');
    setSuccess('');
  };

  const validateForm = () => {
    if (!formData.name.trim()) {
      setError('El nombre es requerido');
      return false;
    }
    if (!formData.email.trim()) {
      setError('El email es requerido');
      return false;
    }
    if (!formData.phoneNumber.trim()) {
      setError('El teléfono es requerido');
      return false;
    }

    // Validación de cambio de contraseña
    if (showPasswordFields) {
      if (!formData.password) {
        setError('Contraseña actual requerida para cambiar contraseña');
        return false;
      }
      if (!formData.newPassword) {
        setError('Nueva contraseña requerida');
        return false;
      }
      if (formData.newPassword.length < 6) {
        setError('La nueva contraseña debe tener al menos 6 caracteres');
        return false;
      }
      if (formData.newPassword !== formData.confirmPassword) {
        setError('Las contraseñas no coinciden');
        return false;
      }
    }

    return true;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setSaving(true);
    setError('');
    setSuccess('');

    try {
      // Preparar datos para enviar al backend
      const updateData = {
        userID: user.userID, // ID del usuario para identificar quién se actualiza
        name: formData.name,
        email: formData.email,
        phoneNumber: formData.phoneNumber,
        password: formData.newPassword || formData.password, // Si hay nueva contraseña, usar esa, sino usar la actual
        role: user.role,
      };

      // Llamar al servicio de actualización
      await userService.updateProfile(updateData);

      // Actualizar localStorage con los nuevos datos
      const updatedUser = {
        ...user,
        name: formData.name,
        email: formData.email,
        phoneNumber: formData.phoneNumber,
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));
      localStorage.setItem('email', formData.email);

      setUser(updatedUser);
      setSuccess('Perfil actualizado exitosamente');
      setShowPasswordFields(false);
      
      // Limpiar campos de contraseña
      setFormData((prev) => ({
        ...prev,
        password: '',
        newPassword: '',
        confirmPassword: '',
      }));

      // Opcional: redirigir al dashboard después de 2 segundos
      setTimeout(() => {
        navigate('/dashboard');
      }, 2000);
    } catch (err) {
      const errorMessage =
        err.response?.data?.message ||
        err.response?.data ||
        'Error al actualizar el perfil';
      setError(errorMessage);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="profile-container">
        <div className="loading">Cargando perfil...</div>
      </div>
    );
  }

  return (
    <div className="profile-container">
      <div className="profile-card">
        <div className="profile-header">
          <button
            className="back-btn"
            onClick={() => navigate('/dashboard')}
            title="Volver al dashboard"
          >
            ← Volver
          </button>
          <h1>Mi Perfil</h1>
        </div>

        <form onSubmit={handleSubmit} className="profile-form">
          {/* Información Básica */}
          <div className="form-section">
            <h2>Información Personal</h2>

            <div className="form-group">
              <label htmlFor="name">Nombre Completo</label>
              <input
                id="name"
                type="text"
                name="name"
                placeholder="Tu nombre"
                value={formData.name}
                onChange={handleInputChange}
                disabled={saving}
              />
            </div>

            <div className="form-group">
              <label htmlFor="email">Email</label>
              <input
                id="email"
                type="email"
                name="email"
                placeholder="tu@email.com"
                value={formData.email}
                onChange={handleInputChange}
                disabled={saving}
              />
            </div>

            <div className="form-group">
              <label htmlFor="phoneNumber">Teléfono</label>
              <input
                id="phoneNumber"
                type="tel"
                name="phoneNumber"
                placeholder="+57 123 456 7890"
                value={formData.phoneNumber}
                onChange={handleInputChange}
                disabled={saving}
              />
            </div>

            <div className="form-group">
              <label htmlFor="role">Rol</label>
              <input
                id="role"
                type="text"
                value={user?.role || 'OWNER'}
                disabled
                className="disabled-input"
              />
            </div>
          </div>

          {/* Cambiar Contraseña */}
          <div className="form-section">
            <div className="password-header">
              <h2>Seguridad</h2>
              <button
                type="button"
                className="toggle-password-btn"
                onClick={() => setShowPasswordFields(!showPasswordFields)}
              >
                {showPasswordFields ? '↑ Ocultar' : '↓ Cambiar Contraseña'}
              </button>
            </div>

            {showPasswordFields && (
              <>
                <div className="form-group">
                  <label htmlFor="currentPassword">Contraseña Actual</label>
                  <input
                    id="currentPassword"
                    type="password"
                    name="password"
                    placeholder="••••••••"
                    value={formData.password}
                    onChange={handleInputChange}
                    disabled={saving}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="newPassword">Nueva Contraseña</label>
                  <input
                    id="newPassword"
                    type="password"
                    name="newPassword"
                    placeholder="••••••••"
                    value={formData.newPassword}
                    onChange={handleInputChange}
                    disabled={saving}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="confirmPassword">Confirmar Nueva Contraseña</label>
                  <input
                    id="confirmPassword"
                    type="password"
                    name="confirmPassword"
                    placeholder="••••••••"
                    value={formData.confirmPassword}
                    onChange={handleInputChange}
                    disabled={saving}
                  />
                </div>
              </>
            )}
          </div>

          {/* Mensajes */}
          {error && <div className="error-message">{error}</div>}
          {success && <div className="success-message">{success}</div>}

          {/* Botones de Acción */}
          <div className="form-actions">
            <button
              type="button"
              className="btn-cancel"
              onClick={() => navigate('/dashboard')}
              disabled={saving}
            >
              Cancelar
            </button>
            <button type="submit" className="btn-save" disabled={saving}>
              {saving ? 'Guardando...' : 'Guardar Cambios'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
