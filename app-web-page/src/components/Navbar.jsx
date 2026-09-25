import React, { useState, useEffect } from 'react';
import { Smartphone, Menu, X, ShieldCheck, Wrench, Calculator, Layers, Star, HelpCircle, ArrowRight, Download } from 'lucide-react';
import logoImg from '../assets/logo.png';
import Magnet from './Magnet';

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState('hero');

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 15);

      if (window.scrollY < 200) {
        setActiveSection('hero');
        return;
      }

      const sections = ['services', 'features', 'how-it-works', 'app-showcase', 'install-guide', 'reviews', 'faq'];
      const targetPoint = window.innerHeight / 3;

      let currentActive = 'hero';
      for (const section of sections) {
        const el = document.getElementById(section);
        if (el) {
          const rect = el.getBoundingClientRect();
          if (rect.top <= targetPoint && rect.bottom >= 120) {
            currentActive = section;
          }
        }
      }

      setActiveSection(currentActive);
    };

    window.addEventListener('scroll', handleScroll);
    handleScroll();
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (e, id) => {
    e.preventDefault();
    const element = document.getElementById(id);
    if (element) {
      const yOffset = -70;
      const y = element.getBoundingClientRect().top + window.pageYOffset + yOffset;
      window.scrollTo({ top: y, behavior: 'smooth' });
    }
    setMobileMenuOpen(false);
  };

  const navItems = [
    { id: 'services', label: 'Services', icon: Wrench },
    { id: 'features', label: 'Why Us', icon: ShieldCheck },
    { id: 'how-it-works', label: 'How It Works', icon: Layers },
    { id: 'app-showcase', label: 'App Preview', icon: Smartphone },
    { id: 'install-guide', label: 'How to Install', icon: Download },
    { id: 'reviews', label: 'Reviews', icon: Star },
    { id: 'faq', label: 'FAQ', icon: HelpCircle }
  ];

  return (
    <header className="sticky top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-xl border-b border-slate-200/90 shadow-md transition-all duration-300">
      
      {/* Top Gradient Accent Line */}
      <div className="h-1 w-full bg-linear-to-r from-[#002B49] via-emerald-500 to-[#002B49]"></div>

      <div className="max-w-7xl mx-auto px-6 py-3">
        <div className="flex items-center justify-between">
          
          {/* Brand Logo & Title */}
          <a 
            href="#hero" 
            onClick={(e) => scrollToSection(e, 'hero')}
            className="flex items-center gap-3.5 no-underline group"
          >
            <div className="w-11 h-11 rounded-2xl bg-white p-1 shadow-md shadow-slate-200 border border-slate-200 group-hover:scale-105 transition-transform flex items-center justify-center shrink-0">
              <img src={logoImg} alt="අපේ බාස් (Ape Baas) Logo" className="w-full h-full object-contain rounded-xl" />
            </div>
            <div className="text-left">
              <div className="flex items-center gap-2">
                <span className="font-sinhala-heading text-xl sm:text-2xl font-extrabold tracking-tight text-[#002B49] block leading-none">
                  අපේ බාස්
                </span>
                <span className="text-xs font-bold text-[#002B49] bg-slate-100 px-2.5 py-0.5 rounded-full border border-slate-200">
                  Ape Baas
                </span>
              </div>
              <span className="text-xs font-extrabold text-slate-500 uppercase tracking-wider flex items-center gap-1 mt-0.5">
                <ShieldCheck size={13} className="text-emerald-600" /> Official Mobile App
              </span>
            </div>
          </a>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center gap-1 bg-slate-100/90 p-1.5 rounded-full border border-slate-200/80 shadow-2xs">
            {navItems.map((item) => {
              const isActive = activeSection === item.id;
              return (
                <a
                  key={item.id}
                  href={`#${item.id}`}
                  onClick={(e) => scrollToSection(e, item.id)}
                  className={`px-4 py-2 rounded-full text-xs font-extrabold transition-all duration-200 no-underline ${
                    isActive 
                      ? 'bg-[#002B49] text-white shadow-md scale-105' 
                      : 'text-slate-700 hover:text-[#002B49] hover:bg-white/90'
                  }`}
                  style={{ borderRadius: '9999px' }}
                >
                  {item.label}
                </a>
              );
            })}
          </nav>

          {/* Right Direct Download CTA Button */}
          <div className="hidden md:flex items-center gap-3">
            <a 
              href="/ape_baas_v1.0.apk"
              download="ape_baas_v1.0.apk"
              className="btn-glow-emerald px-6 py-2.5 rounded-full text-xs sm:text-sm font-extrabold flex items-center gap-2.5 no-underline hover:scale-105 transition-transform shadow-md"
              style={{ borderRadius: '9999px' }}
            >
              <Download size={17} />
              <span>Download App (APK)</span>
              <ArrowRight size={15} />
            </a>
          </div>

          {/* Mobile Hamburger Toggle */}
          <button 
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="lg:hidden text-[#002B49] focus:outline-none p-2.5 rounded-2xl bg-slate-100 border border-slate-200"
            style={{ background: 'none', cursor: 'pointer' }}
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>

        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="lg:hidden max-w-7xl mx-auto px-6 pb-6 pt-2">
          <div className="glass-card border border-slate-200 rounded-3xl p-6 shadow-2xl flex flex-col gap-2 text-left bg-white/98 backdrop-blur-xl">
            <div className="text-xs font-extrabold text-slate-400 uppercase tracking-wider mb-2 px-3">
              Navigation Menu
            </div>
            
            {navItems.map((item) => {
              const IconComponent = item.icon;
              const isActive = activeSection === item.id;
              return (
                <a
                  key={item.id}
                  href={`#${item.id}`}
                  onClick={(e) => scrollToSection(e, item.id)}
                  className={`flex items-center justify-between p-3.5 rounded-2xl font-extrabold text-sm no-underline transition-all ${
                    isActive
                      ? 'bg-[#002B49] text-white shadow-md'
                      : 'hover:bg-slate-100 text-[#002B49] border border-transparent hover:border-slate-200'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-xl flex items-center justify-center ${
                      isActive ? 'bg-white/20 text-white' : 'bg-slate-100 text-[#002B49]'
                    }`}>
                      <IconComponent size={16} />
                    </div>
                    <span>{item.label}</span>
                  </div>
                  <ArrowRight size={16} className={isActive ? 'text-white' : 'text-slate-400'} />
                </a>
              );
            })}

            <div className="pt-4 border-t border-slate-100 mt-2">
              <a 
                href="/ape_baas_v1.0.apk" 
                download="ape_baas_v1.0.apk"
                onClick={() => setMobileMenuOpen(false)}
                className="btn-glow-emerald w-full text-center py-3.5 rounded-2xl flex items-center justify-center gap-2.5 no-underline text-sm font-extrabold shadow-md"
                style={{ borderRadius: '16px' }}
              >
                <Download size={18} />
                <span>Download අපේ බාස් App (APK)</span>
              </a>
            </div>

          </div>
        </div>
      )}
    </header>
  );
}
