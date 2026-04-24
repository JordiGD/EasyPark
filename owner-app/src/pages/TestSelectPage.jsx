import React, { useState } from 'react';

export default function TestSelectPage() {
  const [selected, setSelected] = useState('tunja');

  return (
    <div style={{ padding: '40px', maxWidth: '600px', margin: '0 auto' }}>
      <h1>Test de Selects</h1>
      
      <div style={{ marginBottom: '20px' }}>
        <label>
          Prueba 1 - Select Simple:
          <br/>
          <select 
            value={selected} 
            onChange={(e) => setSelected(e.target.value)}
            style={{
              padding: '10px',
              fontSize: '16px',
              border: '2px solid red',
              width: '100%',
              marginTop: '10px'
            }}
          >
            <option value="tunja">Tunja</option>
            <option value="bogota">Bogotá</option>
            <option value="medellin">Medellín</option>
          </select>
        </label>
      </div>

      <div style={{ marginBottom: '20px' }}>
        <p>Seleccionado: <strong>{selected}</strong></p>
      </div>

      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: '1fr 1fr 1fr', 
        gap: '10px',
        border: '2px solid blue',
        padding: '20px'
      }}>
        <div>
          <label>
            Ciudad:
            <br/>
            <select style={{ width: '100%', padding: '8px', marginTop: '5px' }}>
              <option>Tunja</option>
            </select>
          </label>
        </div>
        <div>
          <label>
            Departamento:
            <br/>
            <select style={{ width: '100%', padding: '8px', marginTop: '5px' }}>
              <option>Boyacá</option>
            </select>
          </label>
        </div>
        <div>
          <label>
            País:
            <br/>
            <select style={{ width: '100%', padding: '8px', marginTop: '5px' }}>
              <option>Colombia</option>
            </select>
          </label>
        </div>
      </div>

      <p style={{ marginTop: '20px', color: 'red' }}>
        Si NO ves los selects (especialmente en el grid azul), entonces es un problema de CSS del proyecto.
      </p>
    </div>
  );
}
