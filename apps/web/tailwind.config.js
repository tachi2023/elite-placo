/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Design NOIR & OR — Élite Placo
        'noir': '#0A0A0B',
        'noir-clair': '#111113',
        'noir-surface': '#16161A',
        'or': '#C9A84C',
        'or-clair': '#E2C06B',
        'or-sombre': '#A8893C',
        'texte': '#F4EFE4',
        'texte-muted': '#9A9084',
        'bordure': '#2A2A2E',
        erreur: '#CF6679',
        succes: '#4CAF50',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Playfair Display', 'Cormorant Garamond', 'serif'],
      },
      keyframes: {
        shimmer: {
          '100%': { transform: 'translateX(100%)' },
        }
      },
      animation: {
        shimmer: 'shimmer 1.5s infinite',
      }
    },
  },
  plugins: [],
}
