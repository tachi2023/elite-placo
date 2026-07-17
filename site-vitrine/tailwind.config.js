/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        anthracite: '#161618',
        'anthracite-clair': '#232326',
        or: '#D4AF37',
        'or-sombre': '#B5952F',
        erreur: '#CF6679',
        succes: '#4CAF50',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Outfit', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
