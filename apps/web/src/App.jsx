import React from 'react';

export function App() {
  return (
    <main style={{ fontFamily: 'Inter, system-ui, sans-serif', padding: '2rem' }}>
      <h1>Subcastic</h1>
      <p>React frontend scaffolded for segment-first playback UX.</p>
      <p>
        Next step: fetch and render queue data from
        <code> GET /stream/:user_id</code>.
      </p>
    </main>
  );
}
