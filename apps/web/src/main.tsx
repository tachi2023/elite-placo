import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import './App.css'
import App from './App.tsx'

if (import.meta.env.PROD && 'serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => undefined);
  });
}

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8081';

async function prewarmApi() {
  const candidates = [
    `${API_BASE_URL}/actuator/health`,
    `${API_BASE_URL}/api/health`,
    `${API_BASE_URL}/api/contenu-site/type/REALISATIONS`,
  ];

  for (const url of candidates) {
    try {
      const controller = new AbortController();
      const timeoutId = window.setTimeout(() => controller.abort(), 5000);
      const response = await fetch(url, {
        method: 'GET',
        cache: 'no-store',
        signal: controller.signal,
      });
      window.clearTimeout(timeoutId);

      if (response.ok) {
        return;
      }
    } catch {
      // Ignore and continue to the next candidate; the app remains usable even if the backend is still waking up.
    }
  }
}

void prewarmApi();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
