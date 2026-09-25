/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: {
          50: '#fffbeb',
          100: '#fef3c7',
          200: '#fde68a',
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f59e0b', // Primary Ape Baas Gold
          600: '#d97706',
          700: '#b45309',
          800: '#92400e',
          900: '#78350f',
          950: '#451a03',
          gold: '#F5A623',
          yellow: '#FFB800',
          navy: '#0B192C',
          darknavy: '#070F1E',
          midnight: '#050B14'
        }
      },
      fontFamily: {
        sans: ['Inter', 'Noto Sans Sinhala', 'sans-serif'],
      },
      boxShadow: {
        'brand-glow': '0 0 25px -5px rgba(245, 158, 11, 0.35)',
        'navy-glow': '0 0 30px -5px rgba(11, 25, 44, 0.6)',
      }
    },
  },
  plugins: [],
}
