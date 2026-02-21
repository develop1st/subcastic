import React, { useEffect, useMemo, useState } from 'react';
import { API_ORIGIN, DEFAULT_USER_ID, STREAM_PATH_TEMPLATE } from '@subcastic/shared';

const streamUrlFor = (userId) =>
  `${API_ORIGIN}${STREAM_PATH_TEMPLATE.replace(':user_id', encodeURIComponent(userId))}`;

export function App() {
  const [userId, setUserId] = useState(DEFAULT_USER_ID);
  const [data, setData] = useState(null);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  const streamUrl = useMemo(() => streamUrlFor(userId), [userId]);

  useEffect(() => {
    const abortController = new AbortController();

    const run = async () => {
      setIsLoading(true);
      setError('');

      try {
        const response = await fetch(streamUrl, { signal: abortController.signal });

        if (!response.ok) {
          throw new Error(`stream request failed with status ${response.status}`);
        }

        const payload = await response.json();
        setData(payload);
      } catch (err) {
        if (err.name !== 'AbortError') {
          setError(err.message);
          setData(null);
        }
      } finally {
        setIsLoading(false);
      }
    };

    run();

    return () => abortController.abort();
  }, [streamUrl]);

  return (
    <main style={{ fontFamily: 'Inter, system-ui, sans-serif', padding: '2rem', maxWidth: '800px' }}>
      <h1>Subcastic</h1>
      <p>Segment-first personal queue preview.</p>

      <label htmlFor="user-id-input" style={{ display: 'block', marginBottom: '1rem' }}>
        User ID:
        <input
          id="user-id-input"
          value={userId}
          onChange={(event) => setUserId(event.target.value || DEFAULT_USER_ID)}
          style={{ marginLeft: '0.5rem' }}
        />
      </label>

      <p>
        Stream endpoint: <code>{streamUrl}</code>
      </p>

      {isLoading && <p>Loading queue…</p>}
      {error && <p style={{ color: '#b00020' }}>Error: {error}</p>}

      {data?.queue?.length > 0 && (
        <ol>
          {data.queue.map((segment) => (
            <li key={segment.segment_id} style={{ marginBottom: '0.75rem' }}>
              <strong>{segment.metadata.title}</strong> <em>({segment.feed_id})</em>
              <div>{segment.metadata.description}</div>
            </li>
          ))}
        </ol>
      )}
    </main>
  );
}
