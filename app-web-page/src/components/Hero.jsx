import React from 'react';
import { Smartphone, Download, ShieldCheck, Sparkles, Clock, CheckCircle2, MessageSquare, ArrowRight, Lock, Users, Wrench, Star } from 'lucide-react';
import customerHomeScreen from '../assets/coustomer home screen.jpeg';

export default function Hero() {
  return (
    <section id="hero" className="relative pt-10 sm:pt-12 pb-16 overflow-hidden bg-slate-50 text-slate-900" style={{ background: 'linear-gradient(180deg, #F4F7FA 0%, #FFFFFF 100%)' }}>
      
      {/* Ambient Gradient Glow Background Orbs */}
      <div className="absolute top-10 left-1/3 -translate-x-1/2 w-137.5 h-137.5 bg-[#002B49]/10 rounded-full blur-[130px] pointer-events-none"></div>
      <div className="absolute top-40 right-10 w-112.5 h-112.5 bg-emerald-400/10 rounded-full blur-[110px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Headline, Checkpoints & Download Actions */}
          <div className="lg:col-span-7 text-left">
            
            {/* Live Launch Badge with Glow Pulse */}
            <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full bg-white border border-[#002B49]/20 text-[#002B49] text-xs sm:text-sm font-extrabold mb-6 shadow-xs animate-pulse-glow" style={{ borderRadius: '9999px' }}>
              <span className="relative flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#002B49] opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-[#002B49]"></span>
              </span>
              <span>🚀 Official Release • Sri Lanka's #1 On-Demand Home Service App</span>
            </div>

            {/* Headline */}
            <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight leading-[1.12] mb-6 text-[#002B49]">
              Expert Home Repairs & Services with{' '}
              <span className="block mt-2 font-sinhala-heading text-4xl sm:text-5xl lg:text-6xl gradient-text-emerald font-extrabold tracking-wider drop-shadow-xs">
                අපේ බාස් <span className="font-sans text-3xl sm:text-4xl text-[#002B49]/85 font-bold ml-1 tracking-tight">(Ape Baas)</span>
              </span>
            </h1>

            {/* Subheadline */}
            <p className="text-base sm:text-lg text-slate-600 mb-6 max-w-2xl leading-relaxed">
              Book verified local electricians, plumbers, AC specialists, solar technicians, and cleaners in under 60 seconds. Fast, reliable & transparent.
            </p>

            {/* Key Value Points Checklist */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-8 text-xs sm:text-sm text-[#002B49] font-bold">
              <div className="flex items-center gap-2">
                <CheckCircle2 size={18} className="text-emerald-600 shrink-0" />
                <span>100% ID & NIC Verified Technicians</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 size={18} className="text-emerald-600 shrink-0" />
                <span>Fast Mobile OTP Login & Booking</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 size={18} className="text-emerald-600 shrink-0" />
                <span>100% Upfront Transparent Rates</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 size={18} className="text-emerald-600 shrink-0" />
                <span>Dual Mode for Homeowners & Baas</span>
              </div>
            </div>

            {/* Download CTA Group */}
            <div className="flex flex-wrap items-center gap-4 mb-10">
              <a 
                href="/ape_baas_v1.0.apk" 
                download="ape_baas_v1.0.apk"
                className="btn-glow-emerald px-7 py-4 rounded-xl text-base font-bold flex items-center gap-3.5 no-underline shadow-lg hover:scale-105 transition-transform"
                style={{ borderRadius: '14px' }}
              >
                <Download size={22} />
                <div className="text-left leading-tight">
                  <div className="text-xs uppercase opacity-95 font-extrabold tracking-wider">Download Android App</div>
                  <div className="text-sm sm:text-base font-extrabold">Direct APK Download (v1.0)</div>
                </div>
                <ArrowRight size={18} className="ml-1" />
              </a>

              <div className="flex items-center gap-3 px-5 py-3 rounded-xl border border-slate-200 bg-white/80 backdrop-blur-xs shadow-2xs">
                <Smartphone size={22} className="text-slate-400" />
                <div className="text-left">
                  <div className="text-[10px] uppercase font-bold text-slate-400">Google Play Store</div>
                  <div className="text-xs font-extrabold text-slate-700">Coming Soon 🚀</div>
                </div>
              </div>
            </div>

            {/* Trust Badges */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-6 border-t border-slate-200/80">
              <div className="p-3 rounded-xl bg-white border border-slate-200/90 text-left shadow-2xs">
                <div className="flex items-center gap-1.5 text-xs font-extrabold text-[#002B49]">
                  <Sparkles size={14} className="text-emerald-600" /> New Release
                </div>
                <div className="text-[11px] text-slate-500 font-semibold mt-0.5">Official Mobile App</div>
              </div>
              <div className="p-3 rounded-xl bg-white border border-slate-200/90 text-left shadow-2xs">
                <div className="flex items-center gap-1.5 text-xs font-extrabold text-[#002B49]">
                  <ShieldCheck size={14} className="text-emerald-600" /> Verified Pros
                </div>
                <div className="text-[11px] text-slate-500 font-semibold mt-0.5">NIC Checked</div>
              </div>
              <div className="p-3 rounded-xl bg-white border border-slate-200/90 text-left shadow-2xs">
                <div className="flex items-center gap-1.5 text-xs font-extrabold text-[#002B49]">
                  <Clock size={14} className="text-sky-600" /> Fast Booking
                </div>
                <div className="text-[11px] text-slate-500 font-semibold mt-0.5">Under 60 Seconds</div>
              </div>
              <div className="p-3 rounded-xl bg-white border border-slate-200/90 text-left shadow-2xs">
                <div className="flex items-center gap-1.5 text-xs font-extrabold text-[#002B49]">
                  <Smartphone size={14} className="text-purple-600" /> Dual Mode
                </div>
                <div className="text-[11px] text-slate-500 font-semibold mt-0.5">Customer & Baas</div>
              </div>
            </div>

          </div>

          {/* Right Column: Phone Showcase Mockup with Organic Staggered Floating Cards */}
          <div className="lg:col-span-5 relative flex flex-col items-center justify-center select-none py-8">
            
            {/* Floating Feature 1 - Top Left: Verified Technicians */}
            <div className="absolute -left-6 sm:-left-12 top-12 z-30 glass-card p-3 sm:p-3.5 rounded-2xl shadow-xl items-center gap-3 animate-float-slow hidden sm:flex border border-slate-200 bg-white/95 pointer-events-none -rotate-4" style={{ borderRadius: '16px' }}>
              <div className="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold shrink-0">
                <ShieldCheck size={22} />
              </div>
              <div className="text-left">
                <div className="text-xs font-extrabold text-[#002B49]">Verified Technicians</div>
                <div className="text-[10px] text-emerald-700 font-bold">100% NIC Checked</div>
              </div>
            </div>

            {/* Floating Feature 2 - Top Right: Dual Mode Mobile App */}
            <div className="absolute -right-6 sm:-right-12 top-20 z-30 glass-card p-3 sm:p-3.5 rounded-2xl shadow-xl items-center gap-3 animate-float-reverse hidden sm:flex border border-slate-200 bg-white/95 pointer-events-none rotate-4" style={{ borderRadius: '16px' }}>
              <div className="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold shrink-0">
                <Users size={20} />
              </div>
              <div className="text-left">
                <div className="text-xs font-extrabold text-[#002B49]">Dual Mode Mobile App</div>
                <div className="text-[10px] text-purple-700 font-bold">Customer & Baas Portal</div>
              </div>
            </div>

            {/* Floating Feature 3 - Bottom Left: Real User Reviews & Ratings */}
            <div className="absolute -left-6 sm:-left-10 bottom-16 z-30 glass-card p-3 sm:p-3.5 rounded-2xl shadow-xl items-center gap-3 animate-float-slow hidden sm:flex border border-slate-200 bg-white/95 pointer-events-none rotate-3" style={{ borderRadius: '16px' }}>
              <div className="w-10 h-10 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold shrink-0">
                <Star size={20} className="fill-amber-400 text-amber-500" />
              </div>
              <div className="text-left">
                <div className="text-xs font-extrabold text-[#002B49]">Real User Reviews & Ratings</div>
                <div className="text-[10px] text-amber-700 font-bold">Verified Community Feedback</div>
              </div>
            </div>

            {/* Samsung Galaxy M11 Device Mockup */}
            <div 
              className="relative w-72 sm:w-80 rounded-[18px] bg-slate-950 p-2 border-[3.5px] border-slate-800 shadow-2xl flex flex-col" 
              style={{ 
                borderRadius: '18px', 
                boxShadow: '0 25px 65px rgba(0, 43, 73, 0.35)'
              }}
            >
              {/* Screen View Container (720x1483 Aspect Ratio) */}
              <div className="w-full bg-slate-100 rounded-xl overflow-hidden relative border border-slate-300 shadow-inner aspect-720/1483">
                <img 
                  src={customerHomeScreen} 
                  alt="අපේ බාස් App on Samsung Galaxy M11" 
                  className="w-full h-full object-fill pointer-events-none"
                />
              </div>

              {/* Samsung Bottom Navigation Gesture Bar */}
              <div className="w-24 h-1 bg-slate-500/80 mx-auto rounded-full my-2"></div>
            </div>

          </div>

        </div>
      </div>
    </section>
  );
}
