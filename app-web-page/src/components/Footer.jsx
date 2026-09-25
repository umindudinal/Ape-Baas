import React from 'react';
import { Smartphone, Download, QrCode, Phone, Mail, MapPin, Heart, ShieldCheck, ArrowRight, Sparkles, CheckCircle2, Clock, Globe, Shield } from 'lucide-react';
import logoImg from '../assets/logo.png';

export default function Footer() {
  return (
    <footer id="download" className="bg-[#001424] text-white pt-20 pb-10 relative overflow-hidden">
      
      {/* Ambient Deep Glow Background Effects */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-96 bg-linear-to-b from-emerald-950/20 via-transparent to-transparent pointer-events-none"></div>
      <div className="absolute top-1/3 left-1/4 w-150 h-150 bg-[#005E99]/10 rounded-full blur-[180px] pointer-events-none"></div>
      <div className="absolute bottom-10 right-10 w-96 h-96 bg-emerald-600/5 rounded-full blur-[150px] pointer-events-none"></div>

      {/* Top Download Card Banner */}
      <div className="max-w-7xl mx-auto px-6 mb-20 relative z-10">
        <div className="p-8 sm:p-12 rounded-3xl relative overflow-hidden flex flex-col lg:flex-row items-center justify-between gap-8 border border-[#004370]/80 shadow-2xl" style={{ borderRadius: '32px', background: 'linear-gradient(135deg, #00192C 0%, #002B49 100%)' }}>
          
          {/* Left Callouts */}
          <div className="max-w-2xl text-left">
            <span className="text-xs font-extrabold px-4 py-1.5 rounded-full bg-[#005E99]/40 text-emerald-300 border border-[#005E99]/60 uppercase tracking-wider mb-4 inline-flex items-center gap-2 shadow-xs">
              <Sparkles size={14} className="text-emerald-400" /> OFFICIAL APP RELEASE
            </span>
            <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white mb-4 tracking-tight leading-tight">
              Download <span className="font-sinhala-heading font-extrabold text-emerald-400">අපේ බාස්</span> <span className="text-emerald-300 font-sans font-bold text-2xl sm:text-3xl">(Ape Baas)</span> App Today
            </h2>
            <p className="text-slate-300 text-base sm:text-lg mb-8 leading-relaxed">
              Transform how you manage home maintenance in Sri Lanka. Install our official Android application to book background-checked local electricians, plumbers, AC pros, and solar specialists in seconds.
            </p>

            <div className="flex flex-wrap gap-4">
              <a 
                href="/ape_baas_v1.0.apk"
                download="ape_baas_v1.0.apk"
                className="btn-glow-emerald px-7 py-4 rounded-2xl font-extrabold flex items-center gap-3.5 no-underline shadow-xl text-sm text-white hover:scale-105 transition-all duration-300"
                style={{ borderRadius: '16px' }}
              >
                <Download size={22} />
                <div className="text-left leading-tight">
                  <div className="text-[11px] uppercase font-extrabold tracking-wider opacity-90">Download Android App</div>
                  <div className="text-sm font-extrabold">Direct APK Download (v1.0)</div>
                </div>
              </a>

              <div 
                className="px-6 py-4 rounded-2xl font-extrabold flex items-center gap-3 text-slate-400 bg-white/5 border border-slate-700/80 text-sm select-none"
                style={{ borderRadius: '16px' }}
              >
                <Smartphone size={22} className="text-slate-500" />
                <div className="text-left leading-tight">
                  <div className="text-[11px] uppercase font-extrabold tracking-wider opacity-80">Google Play Store</div>
                  <div className="text-sm font-extrabold text-slate-300">Coming Soon 🚀</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Scannable QR Box */}
          <div className="bg-[#002B49]/90 p-6 rounded-3xl border border-[#004370] text-center shrink-0 flex flex-col items-center shadow-2xl relative group" style={{ borderRadius: '28px' }}>
            <div className="w-40 h-40 bg-white p-3 rounded-2xl flex items-center justify-center shadow-lg relative overflow-hidden group-hover:scale-105 transition-transform duration-300">
              <img 
                src="https://api.qrserver.com/v1/create-qr-code/?size=300x300&color=002B49&data=https://apebaas.lk/ape_baas_v1.0.apk" 
                alt="Scan to Download අපේ බාස් App" 
                className="w-full h-full object-contain rounded-xl"
              />
            </div>
            <div className="text-xs font-extrabold text-white mt-3 flex items-center gap-1.5">
              <QrCode size={15} className="text-emerald-400" />
              <span>Scan QR Code to Download</span>
            </div>
            <span className="text-[11px] font-medium text-slate-400 mt-0.5">Direct APK Download Link</span>
          </div>

        </div>
      </div>

      {/* Main Footer Content Grid */}
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-10 lg:gap-12 pb-16 border-b border-slate-800/80 text-left">
          
          {/* Prominent Large Brand Header Column (5 cols) */}
          <div className="lg:col-span-5 space-y-6">
            
            {/* Large Prominent Logo Container */}
            <div className="flex items-center gap-4">
              <div className="w-20 h-20 sm:w-22 sm:h-22 rounded-3xl bg-white p-2.5 shadow-2xl shadow-emerald-950/50 border-2 border-emerald-500/30 flex items-center justify-center shrink-0 hover:scale-105 transition-transform duration-300" style={{ borderRadius: '22px' }}>
                <img src={logoImg} alt="අපේ බාස් (Ape Baas) Official Logo" className="w-full h-full object-contain rounded-xl" />
              </div>

              <div>
                <div className="flex items-center gap-2 mb-1">
                  <span className="font-sinhala-heading text-3xl sm:text-4xl font-extrabold text-white tracking-tight leading-none">
                    අපේ බාස්
                  </span>
                </div>
                <span className="text-base sm:text-lg font-bold text-emerald-400 tracking-wide font-sans block">
                  Ape Baas <span className="text-xs font-extrabold text-slate-400 bg-slate-800/80 px-2.5 py-0.5 rounded-full border border-slate-700 ml-1.5">Sri Lanka</span>
                </span>
                <span className="text-xs font-semibold text-slate-400 block mt-1">
                  #1 Digital Platform for On-Demand Local Services
                </span>
              </div>
            </div>

            <p className="text-slate-300 text-sm sm:text-base leading-relaxed max-w-md">
              ශ්‍රී ලංකාවේ ප්‍රමුඛතම දේශීය කාර්මික ශිල්පීන් සහ පාරිභෝගිකයින් සෘජුවම සම්බන්ධ කරන විශ්වාසනීයම Digital Platform එක. සියලුම අලුත්වැඩියාවන් සඳහා 100% NIC Verified කාර්මිකයන් විනාඩියකින් සොයාගන්න.
            </p>

            {/* Key Trust Highlights List */}
            <div className="space-y-2.5 pt-2">
              <div className="flex items-center gap-2.5 text-xs sm:text-sm text-emerald-300 font-extrabold">
                <ShieldCheck size={18} className="text-emerald-400 shrink-0" />
                <span>100% National ID & Police Verified Technicians</span>
              </div>
              <div className="flex items-center gap-2.5 text-xs sm:text-sm text-sky-300 font-extrabold">
                <Clock size={18} className="text-sky-400 shrink-0" />
                <span>24/7 Islandwide Emergency Repair Coverage</span>
              </div>
              <div className="flex items-center gap-2.5 text-xs sm:text-sm text-teal-300 font-extrabold">
                <Globe size={18} className="text-teal-400 shrink-0" />
                <span>Bilingual Platform Support (සිංහල & English)</span>
              </div>
            </div>

          </div>

          {/* Quick Navigation Links (2 cols) */}
          <div className="lg:col-span-2">
            <h4 className="text-base font-extrabold text-white mb-5 pb-2 border-b border-slate-800 flex items-center justify-between">
              <span>Navigation</span>
              <span className="w-8 h-0.5 bg-emerald-500 rounded-full"></span>
            </h4>
            <ul className="space-y-3 text-xs sm:text-sm text-slate-400" style={{ listStyle: 'none', padding: 0 }}>
              <li>
                <a href="#services" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>Service Categories</span>
                </a>
              </li>
              <li>
                <a href="#features" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>Why Choose Us</span>
                </a>
              </li>
              <li>
                <a href="#how-it-works" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>How It Works (60s)</span>
                </a>
              </li>
              <li>
                <a href="#app-showcase" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>App Screenshots</span>
                </a>
              </li>
              <li>
                <a href="#reviews" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>User Reviews</span>
                </a>
              </li>
              <li>
                <a href="#install-guide" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>Install APK Guide</span>
                </a>
              </li>
              <li>
                <a href="#faq" className="hover:text-emerald-400 transition-colors no-underline flex items-center gap-2 group">
                  <ArrowRight size={14} className="text-slate-600 group-hover:text-emerald-400 group-hover:translate-x-1 transition-all" />
                  <span>FAQ & Help</span>
                </a>
              </li>
            </ul>
          </div>

          {/* Popular Categories (2 cols) */}
          <div className="lg:col-span-2">
            <h4 className="text-base font-extrabold text-white mb-5 pb-2 border-b border-slate-800 flex items-center justify-between">
              <span>Categories</span>
              <span className="w-8 h-0.5 bg-emerald-500 rounded-full"></span>
            </h4>
            <ul className="space-y-2.5 text-xs sm:text-sm text-slate-400" style={{ listStyle: 'none', padding: 0 }}>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Solar Power Systems</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Electrical Repairs</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Plumbing & Piping</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>AC Service & Repair</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Carpentry Works</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Painting Services</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Deep House Cleaning</li>
              <li className="flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Masonry Repairs</li>
            </ul>
          </div>

          {/* Support Info & Contact Card (3 cols) */}
          <div className="lg:col-span-3">
            <h4 className="text-base font-extrabold text-white mb-5 pb-2 border-b border-slate-800 flex items-center justify-between">
              <span>Support & Contact</span>
              <span className="w-8 h-0.5 bg-emerald-500 rounded-full"></span>
            </h4>

            {/* Contact Details Card */}
            <div className="bg-slate-900/90 p-5 rounded-2xl border border-slate-800 space-y-3.5 shadow-md">
              <div className="flex items-start gap-3">
                <MapPin size={18} className="text-emerald-400 shrink-0 mt-0.5" />
                <div className="text-xs sm:text-sm text-slate-300">
                  <span className="font-extrabold text-white block">Head Office</span>
                  <span>අපේ බාස් (Ape Baas) HQ, Colombo, Sri Lanka</span>
                </div>
              </div>

              <div className="flex items-center gap-3 pt-1 border-t border-slate-800">
                <Phone size={18} className="text-emerald-400 shrink-0" />
                <div className="text-xs sm:text-sm text-slate-300">
                  <span className="font-extrabold text-white block">Hotline 24/7</span>
                  <span>+94 77 123 4567 / +94 11 234 5678</span>
                </div>
              </div>

              <div className="flex items-center gap-3 pt-1 border-t border-slate-800">
                <Mail size={18} className="text-emerald-400 shrink-0" />
                <div className="text-xs sm:text-sm text-slate-300">
                  <span className="font-extrabold text-white block">Email Support</span>
                  <a href="mailto:support@apebaas.lk" className="text-emerald-400 font-semibold hover:underline">support@apebaas.lk</a>
                </div>
              </div>
            </div>

          </div>

        </div>

        {/* Bottom Copyright & Security Footer */}
        <div className="pt-8 flex flex-col sm:flex-row items-center justify-between text-xs text-slate-400 gap-4">
          <div className="flex items-center gap-2">
            <span>© 2026</span>
            <span className="font-sinhala-heading font-extrabold text-emerald-400">අපේ බාස්</span>
            <span>(Ape Baas) Sri Lanka. All rights reserved.</span>
          </div>

          <div className="flex items-center gap-6">
            <span className="text-slate-500 hover:text-slate-300 cursor-pointer">Privacy Policy</span>
            <span className="text-slate-500 hover:text-slate-300 cursor-pointer">Terms of Service</span>
            <div className="flex items-center gap-1.5 text-slate-300 font-medium">
              <span>Made for Sri Lanka 🇱🇰 with</span>
              <Heart size={14} className="text-rose-500 fill-rose-500" />
            </div>
          </div>
        </div>

      </div>
    </footer>
  );
}
