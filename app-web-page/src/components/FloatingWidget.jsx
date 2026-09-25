import React, { useState, useEffect } from 'react';
import { ArrowUp, Smartphone } from 'lucide-react';

export default function FloatingWidget() {
  const [showScrollTop, setShowScrollTop] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setShowScrollTop(window.scrollY > 300);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  return (
    <div className="fixed bottom-6 right-6 z-50 flex items-center gap-3 pointer-events-auto">
      
      {/* Floating Download Mini CTA Badge */}
      <a
        href="#download"
        className="hidden sm:flex btn-glow-emerald px-4 py-2.5 rounded-full text-xs font-extrabold items-center gap-2 no-underline shadow-xl animate-bounce"
        style={{ borderRadius: '9999px', animationDuration: '3s' }}
      >
        <Smartphone size={16} />
        <span>Get <span className="font-sinhala-heading font-extrabold">අපේ බාස්</span> App</span>
      </a>

      {/* Back To Top Floating Button */}
      {showScrollTop && (
        <button
          onClick={scrollToTop}
          className="w-12 h-12 rounded-full bg-[#002B49] text-white border border-slate-700 shadow-2xl flex items-center justify-center cursor-pointer hover:bg-emerald-600 hover:scale-110 transition-all duration-300"
          style={{ background: '#002B49', cursor: 'pointer' }}
          title="Scroll Back to Top"
        >
          <ArrowUp size={20} />
        </button>
      )}

    </div>
  );
}
