import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { userService } from '../services/api';
import './AdminUsers.css';

export default function AdminUsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    setLoading(true);
    try {
      const response = await userService.getAllUsers();
      setUsers(response.data || []);
    } catch (err) {
      setError('Error al cargar usuarios');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (userId) => {
    if (window.confirm('¿Estás seguro de que deseas eliminar este usuario?')) {
      try {
        await userService.deleteUser(userId);
        setUsers(users.filter((u) => u.id !== userId));
      } catch (err) {
        setError('Error al eliminar usuario');
      }
    }
  };

  const filteredUsers = users.filter(
    (user) =>
      user.firstName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.lastName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.email?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="admin-users-container">
      {/* Header */}
      <header className="admin-users-header">
        <div className="admin-users-header-content">
          <div className="admin-users-logo">
            <span className="admin-users-logo-icon">⚙️</span>
            <span>EasyPark Admin</span>
          </div>

          <nav className="admin-users-nav">
            <a href="/dashboard">Dashboard</a>
            <a href="/users" className="active">
              Usuarios
            </a>
            <a href="/drivers">Conductores</a>
            <a href="/owners">Propietarios</a>
          </nav>

          <button
            className="admin-users-logout"
            onClick={() => {
              localStorage.removeItem('token');
              navigate('/login');
            }}
          >
            Cerrar Sesión
          </button>
        </div>
      </header>

      {/* Content */}
      <main className="admin-users-main">
        <div className="admin-users-page">
          <h1>Gestión de Usuarios</h1>

          {/* Search Bar */}
          <div className="admin-users-search">
            <input
              type="text"
              placeholder="Buscar por nombre o email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Error Message */}
          {error && <div className="admin-users-error">{error}</div>}

          {/* Users Table */}
          {loading ? (
            <div className="admin-users-loading">Cargando usuarios...</div>
          ) : (
            <div className="admin-users-table-container">
              <table className="admin-users-table">
                <thead>
                  <tr>
                    <th>Nombre</th>
                    <th>Email</th>
                    <th>Teléfono</th>
                    <th>Rol</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.length > 0 ? (
                    filteredUsers.map((user) => (
                      <tr key={user.id}>
                        <td>{`${user.firstName} ${user.lastName}`}</td>
                        <td>{user.email}</td>
                        <td>{user.phone || '-'}</td>
                        <td>
                          <span className={`role-badge role-${user.role || 'user'}`}>
                            {user.role || 'Usuario'}
                          </span>
                        </td>
                        <td>
                          <button className="admin-users-edit-btn">Editar</button>
                          <button
                            className="admin-users-delete-btn"
                            onClick={() => handleDelete(user.id)}
                          >
                            Eliminar
                          </button>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan="5" className="admin-users-no-data">
                        No se encontraron usuarios
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
