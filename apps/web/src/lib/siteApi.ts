export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8081';

export interface SiteContent {
  id?: number;
  type: 'REALISATIONS' | 'SERVICE' | 'PARAMETRE_GLOBAL';
  cle?: string;
  titre?: string;
  description?: string;
  imageUrl?: string;
  ordre?: number;
}

export interface ClientReview {
  id: number;
  chantierId: number;
  nomClient: string;
  note: number;
  commentaire: string;
  statut: 'EN_ATTENTE' | 'APPROUVE' | 'REJETE';
  dateCreation: string;
  datePublication?: string;
}

export function usableImageUrl(url: string | undefined, fallback: string): string {
  if (!url) return fallback;
  return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('/') ? url : fallback;
}

export async function fetchPublicRealisations(): Promise<SiteContent[]> {
  const response = await fetch(`${API_BASE_URL}/api/contenu-site/type/REALISATIONS`);
  if (!response.ok) throw new Error('Contenu public indisponible');
  return response.json();
}

export async function fetchPublicReviews(): Promise<ClientReview[]> {
  const response = await fetch(`${API_BASE_URL}/api/avis/public`);
  if (!response.ok) throw new Error('Avis publics indisponibles');
  return response.json();
}

export function authHeaders(): HeadersInit {
  const token = localStorage.getItem('elite_access_token');
  return token ? { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } : { 'Content-Type': 'application/json' };
}

export async function adminRequest(path: string, init: RequestInit = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers: { ...authHeaders(), ...(init.headers || {}) },
  });
  if (!response.ok) {
    const payload = await response.json().catch(() => ({}));
    throw new Error(payload.message || 'Action administrateur refusée');
  }
  return response.status === 204 ? null : response.json();
}
