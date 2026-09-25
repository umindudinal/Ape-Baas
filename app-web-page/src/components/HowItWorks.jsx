import React from 'react';
import { CheckCircle2, Smartphone, Users, Lock, ShieldCheck, MapPin, Zap } from 'lucide-react';

const steps = [
  {
    number: "01",
    title: "Select Service Category",
    titleSi: "සේවා වර්ගය තෝරාගන්න",
    desc: "Open the අපේ බාස් (Ape Baas) app and select Electrical, Plumbing, AC Repair, Solar, or any repair category you need.",
    highlight: "12+ Service categories",
    icon: Smartphone,
    colorGradient: "from-emerald-500 to-teal-600 shadow-emerald-500/25",
    iconColor: "text-emerald-600"
  },
  {
    number: "02",
    title: "Quick Phone OTP Login",
    titleSi: "OTP එකෙන් ඉක්මනින් ලොග් වන්න",
    desc: "Enter your mobile phone number to receive a 4-digit SMS OTP for fast, password-less secure access in under 30 seconds.",
    highlight: "Instant SMS verification",
    icon: Lock,
    colorGradient: "from-sky-500 to-blue-600 shadow-sky-500/25",
    iconColor: "text-sky-600"
  },
  {
    number: "03",
    title: "Discover Local Specialist",
    titleSi: "ළඟම සිටින බාස්ව තෝරාගන්න",
    desc: "Browse background-checked technicians near your location with verified National Identity Card (NIC) credentials.",
    highlight: "ID & NIC verified pros",
    icon: Users,
    colorGradient: "from-amber-500 to-orange-600 shadow-amber-500/25",
    iconColor: "text-amber-600"
  },
  {
    number: "04",
    title: "Connect & Complete Job",
    titleSi: "සම්බන්ධ වී වැඩේ නිම කරගන්න",
    desc: "Directly contact the technician to schedule a convenient visit time, complete your home repair, and pay upon job completion.",
    highlight: "Direct contact & scheduling",
    icon: ShieldCheck,
    colorGradient: "from-purple-500 to-indigo-600 shadow-purple-500/25",
    iconColor: "text-purple-600"
  }
];

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="pt-16 pb-16 scroll-mt-16 bg-slate-50 text-slate-900 relative overflow-hidden">
      
      {/* Background Soft Orbs */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-175 h-175 bg-[#002B49]/5 rounded-full blur-[140px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            <Zap size={14} className="text-[#002B49]" /> 4-Step Seamless Flow
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            How to Book a Service in <span className="gradient-title-text">60 Seconds</span>
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Simple, fast, and transparent process designed for busy Sri Lankan homeowners.
          </p>
        </div>

        {/* Steps Journey Grid with Connecting Flow Bar */}
        <div className="relative">
          
          {/* Connecting Flow Timeline Line on Desktop */}
          <div className="hidden lg:block absolute top-22 left-[10%] right-[10%] h-1 bg-linear-to-r from-emerald-400 via-sky-400 to-purple-400 z-0 rounded-full opacity-30 pointer-events-none"></div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 relative z-10">
            {steps.map((step, idx) => {
              const IconComponent = step.icon;
              return (
                <div 
                  key={idx}
                  className="glass-card p-8 rounded-3xl border border-slate-200/90 bg-white flex flex-col justify-between text-left relative overflow-hidden group shadow-xs hover:shadow-2xl hover:border-[#002B49]/40 transition-all duration-300"
                  style={{ borderRadius: '24px' }}
                >
                  <div>
                    {/* Colorful Step Number & Icon Header */}
                    <div className="flex items-center justify-between mb-6">
                      <div className={`w-16 h-16 rounded-2xl bg-linear-to-br ${step.colorGradient} text-white font-display text-2xl font-extrabold flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform duration-300`}>
                        {step.number}
                      </div>

                      <div className={`w-11 h-11 rounded-xl bg-slate-100 flex items-center justify-center ${step.iconColor}`}>
                        <IconComponent size={22} />
                      </div>
                    </div>

                    <h3 className="text-lg font-extrabold text-[#002B49] mb-0.5 group-hover:text-emerald-700 transition-colors">
                      {step.title}
                    </h3>
                    <div className="text-sm font-extrabold text-emerald-700 mb-3 font-sinhala">
                      {step.titleSi}
                    </div>

                    <p className="text-sm sm:text-base text-slate-700 font-medium leading-relaxed mb-6">
                      {step.desc}
                    </p>
                  </div>

                  {/* Bottom Step Highlight Badge */}
                  <div className="pt-4 border-t border-slate-100 flex items-center gap-2 text-xs sm:text-sm font-extrabold text-[#002B49]">
                    <CheckCircle2 size={16} className={step.iconColor} />
                    <span>{step.highlight}</span>
                  </div>
                </div>
              );
            })}
          </div>

        </div>

      </div>
    </section>
  );
}
