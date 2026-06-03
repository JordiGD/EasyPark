import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { parkingService, reviewService } from '../services/api';
import './Reviews.css';

export default function ReviewsPage() {
  const { parkingId } = useParams();
  const [reviews, setReviews] = useState([]);
  const [parking, setParking] = useState(null);
  const [averageRating, setAverageRating] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  // Cargar reseñas y datos del parqueadero
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

        // Obtener reseñas
        try {
          const reviewsResponse = await reviewService.getReviewsByParking(parkingId);
          setReviews(reviewsResponse.data || []);
        } catch (err) {
          console.error('Error al cargar reseñas:', err);
          setReviews([]);
        }

        // Obtener promedio de calificación
        try {
          const averageResponse = await reviewService.getAverageRating(parkingId);
          setAverageRating(averageResponse.data || 0);
        } catch (err) {
          console.error('Error al cargar promedio:', err);
          setAverageRating(0);
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

  // Renderizar estrellas
  const renderStars = (rating) => {
    return (
      <span className="stars">
        {'⭐'.repeat(rating)}
        {'☆'.repeat(5 - rating)}
      </span>
    );
  };

  if (loading) {
    return <div className="reviews-page loading">Cargando reseñas...</div>;
  }

  return (
    <div className="reviews-page">
      {/* Header */}
      <header className="reviews-header">
        <div className="header-content">
          <button
            className="btn-back"
            onClick={() => navigate('/dashboard')}
            title="Volver"
          >
            ← Volver
          </button>
          <div className="header-title">
            <h1>Reseñas: {parking?.name || 'Parqueadero'}</h1>
            <p className="parking-location">{parking?.address}</p>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="reviews-main">
        {/* Rating Summary */}
        <section className="rating-summary">
          <div className="rating-card">
            <div className="rating-number">{averageRating.toFixed(1)}</div>
            <div className="rating-stars">{renderStars(Math.round(averageRating))}</div>
            <div className="rating-count">
              {reviews.length} {reviews.length === 1 ? 'reseña' : 'reseñas'}
            </div>
          </div>
        </section>

        {error && <div className="error-message">{error}</div>}

        {/* Reviews List */}
        <section className="reviews-section">
          {reviews.length === 0 ? (
            <div className="empty-state">
              <p>No hay reseñas aún</p>
              <p className="empty-subtitle">Las reseñas aparecerán aquí cuando los conductores califiquen tu parqueadero</p>
            </div>
          ) : (
            <div className="reviews-list">
              {reviews.map((review) => (
                <div key={review.id} className="review-card">
                  <div className="review-header">
                    <div className="review-user">
                      <h4>{review.driverName}</h4>
                      <span className="review-date">
                        {new Date(review.createdAt).toLocaleDateString('es-ES', {
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                        })}
                      </span>
                    </div>
                  </div>

                  <div className="review-rating">
                    {renderStars(review.rating)}
                    <span className="rating-value">{review.rating}/5</span>
                  </div>

                  <div className="review-comment">
                    <p>{review.comment}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
