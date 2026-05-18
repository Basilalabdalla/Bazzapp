import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Outfit', 'sans-serif'],
        display: ['Syne', 'sans-serif'],
        body: ['Outfit', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      colors: {
        bg: '#07080F',
        surface: '#0D1117',
        'surface-2': '#141920',
        'surface-3': '#1C2333',
        border: '#252D3F',
        accent: '#FFBE0B',
        orange: '#FF6B35',
        muted: '#64748B',
        text: '#EDF2FF',
        success: '#22C55E',
        info: '#3B82F6',
        warning: '#F59E0B',
        danger: '#EF4444',
      },
    },
  },
  plugins: [],
}

export default config
