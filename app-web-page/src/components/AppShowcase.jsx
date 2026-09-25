import React, { useState } from 'react';
import { Check, Smartphone, ShieldCheck, UserCheck, Lock, ArrowRight, Sparkles } from 'lucide-react';

import customerHomeImg from '../assets/coustomer home screen.jpeg';
import providerHomeImg from '../assets/provider home screen.jpeg';
import loginScreenImg from '../assets/login screen.png';
import roleSelectionImg from '../assets/role selection screen.png';

const appScreens = [
  {
    id: 0,
    title: "Role Selection",
    titleSi: "ගිණුම් මාදිලිය තෝරාගැනීම",
    tag: "Unified Dual Mode",
    icon: UserCheck,
    gradient: "from-purple-500 to-indigo-600 shadow-purple-500/25",
    badgeBg: "bg-purple-50 text-purple-800 border-purple-200",
    desc: "Choose between Customer and Service Provider mode seamlessly within the same unified mobile application.",
    features: [
      "One single app for both Homeowners and Technicians",
      "Easy mode switching with custom tailored dashboards",
      "NIC background verification workflow for providers"
    ],
    image: roleSelectionImg
  },
  {
    id: 1,
    title: "Easy Login & OTP",
    titleSi: "පහසු OTP පිවිසුම",
    tag: "30-Second Access",
    icon: Lock,
    gradient: "from-amber-500 to-orange-600 shadow-amber-500/25",
    badgeBg: "bg-amber-50 text-amber-800 border-amber-200",
    desc: "Simple, fast mobile login with phone number verification designed for instant booking without complicated passwords.",
    features: [
      "Under 30-second mobile phone OTP verification",
      "Secure encrypted user session & profile protection",
      "No password hassle - instant SMS verification anytime"
    ],
    image: loginScreenImg
  },
  {
    id: 2,
    title: "Customer Dashboard",
    titleSi: "පාරිභෝගික මුහුණත",
    tag: "Homeowner Portal",
    icon: Smartphone,
    gradient: "from-emerald-500 to-teal-600 shadow-emerald-500/25",
    badgeBg: "bg-emerald-50 text-emerald-800 border-emerald-200",
    desc: "Browse 12+ home service categories, search for specific repair jobs, and view background-checked local specialists near your location.",
    features: [
      "Instant category search with local technician matching",
      "Direct phone contact with background-checked specialists",
      "Clear transparent service category browsing"
    ],
    image: customerHomeImg
  },
  {
    id: 3,
    title: "Provider Dashboard",
    titleSi: "බාස්ලා සඳහා මුහුණත",
    tag: "Technician Partner Hub",
    icon: ShieldCheck,
    gradient: "from-sky-500 to-blue-600 shadow-sky-500/25",
    badgeBg: "bg-sky-50 text-sky-800 border-sky-200",
    desc: "Background-checked service providers receive instant job requests, manage active repair bookings, and update availability status.",
    features: [
      "Real-time customer job requests near technician's location",
      "Direct customer phone connection for fast agreement",
      "Easy availability & profile status management"
    ],
    image: providerHomeImg
  }
];

export default function AppShowcase() {
  const [activeTab, setActiveTab] = useState(0);
  const currentScreen = appScreens[activeTab];

  return (
    <section id="app-showcase" className="pt-16 pb-16 scroll-mt-16 bg-white text-slate-900 relative border-y border-slate-200 overflow-hidden">
      
      {/* Background Soft Orbs */}
      <div className="absolute top-1/3 right-10 w-125 h-125 bg-[#002B49]/5 rounded-full blur-[130px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-14">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-100 border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            <Sparkles size={14} className="text-[#002B49]" /> Mobile App Showcase
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            Real Mobile Screenshots of <br /> <span className="font-sinhala-heading text-emerald-700 font-extrabold">අපේ බාස්</span>
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Experience our official Flutter mobile application designed specifically for Sri Lankan homeowners and service providers.
          </p>
        </div>

        {/* Colorful Tab Navigation Buttons */}
        <div className="flex flex-wrap justify-center gap-3 mb-14">
          {appScreens.map((screen) => {
            const IconComp = screen.icon;
            const isActive = activeTab === screen.id;
            return (
              <button
                key={screen.id}
                onClick={() => setActiveTab(screen.id)}
                className={`px-5 py-3 rounded-full text-xs sm:text-sm font-extrabold transition-all duration-200 cursor-pointer flex items-center gap-2.5 ${
                  isActive
                    ? `bg-linear-to-r ${screen.gradient} text-white scale-105 shadow-md`
                    : 'bg-slate-50 text-slate-700 hover:bg-slate-100 hover:text-[#002B49] border border-slate-200'
                }`}
                style={{ borderRadius: '9999px' }}
              >
                <IconComp size={16} />
                <span>{screen.title}</span>
              </button>
            );
          })}
        </div>

        {/* Showcase Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          
          {/* Left Column: Active Tab Details & Per-Tab Features */}
          <div className="lg:col-span-6 text-left order-2 lg:order-1">
            <div className="flex items-center gap-2 mb-4">
              <span className={`text-xs font-extrabold px-3 py-1 rounded-full border uppercase tracking-wider ${currentScreen.badgeBg}`}>
                {currentScreen.tag}
              </span>
              <span className="text-xs sm:text-sm font-extrabold text-[#002B49] bg-slate-100 px-3 py-1 rounded-full border border-slate-200/80 font-sinhala">
                {currentScreen.titleSi}
              </span>
            </div>

            <h3 className="font-display text-3xl font-extrabold text-[#002B49] mb-4">
              {currentScreen.title}
            </h3>

            <p className="text-slate-600 text-base sm:text-lg leading-relaxed mb-8">
              {currentScreen.desc}
            </p>

            {/* Per-Tab Key Feature Checkpoints */}
            <div className="space-y-4 mb-8">
              {currentScreen.features.map((feat, idx) => (
                <div key={idx} className="flex items-center gap-3 text-[#002B49] font-bold text-sm sm:text-base">
                  <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <Check size={16} />
                  </div>
                  <span>{feat}</span>
                </div>
              ))}
            </div>

            {/* CTA Direct Download Button */}
            <a 
              href="/ape_baas_v1.0.apk"
              download="ape_baas_v1.0.apk"
              className="btn-glow-emerald px-7 py-3.5 rounded-xl font-extrabold text-sm inline-flex items-center gap-2.5 no-underline shadow-md"
              style={{ borderRadius: '12px' }}
            >
              <span>Download App APK & Try {currentScreen.title}</span>
              <ArrowRight size={16} />
            </a>
          </div>

          {/* Right Column: Phone Mockup Frame (Matches exact size of Installation Guide) */}
          <div className="lg:col-span-6 flex justify-center items-center order-1 lg:order-2">
            <div className="relative w-56 sm:w-64 max-w-full rounded-[22px] bg-slate-950 p-2 border-[3.5px] border-slate-800 shadow-xl flex flex-col items-center" style={{ borderRadius: '22px', boxShadow: '0 22px 55px rgba(0, 43, 73, 0.28)' }}>
              {/* Screen Display Container */}
              <div className="w-full rounded-[15px] overflow-hidden relative border border-slate-700/60 shadow-md">
                <img 
                  src={currentScreen.image} 
                  alt={currentScreen.title} 
                  className="w-full h-auto block object-contain"
                />
              </div>

              {/* Bottom Gesture Bar */}
              <div className="w-14 h-1 bg-slate-500/80 rounded-full my-1.5 shrink-0"></div>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
