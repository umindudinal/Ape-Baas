import React from 'react';
import { ShieldCheck, Clock, Users, Lock, Wrench, MapPin, ArrowUpRight } from 'lucide-react';
import SpotlightCard from './SpotlightCard';

const features = [
  {
    title: "100% Verified Technicians",
    desc: "Every technician undergoes mandatory National Identity Card (NIC), address, and background verification before joining.",
    icon: ShieldCheck,
    iconBg: "bg-emerald-100 text-emerald-600 border-emerald-200/80 shadow-emerald-500/10"
  },
  {
    title: "Fast 60-Second Booking",
    desc: "Simple, hassle-free booking with OTP phone login. Browse local service categories and request assistance in seconds.",
    icon: Clock,
    iconBg: "bg-amber-100 text-amber-600 border-amber-200/80 shadow-amber-500/10"
  },
  {
    title: "Dual Mode App (Homeowner & Baas)",
    desc: "One single mobile application tailored for both Homeowners hiring technicians and Service Providers finding repair jobs.",
    icon: Users,
    iconBg: "bg-purple-100 text-purple-600 border-purple-200/80 shadow-purple-500/10"
  },
  {
    title: "Password-less OTP Login",
    desc: "Quick, hassle-free login using your mobile phone number with instant SMS OTP verification without remembering passwords.",
    icon: Lock,
    iconBg: "bg-sky-100 text-sky-600 border-sky-200/80 shadow-sky-500/10"
  },
  {
    title: "12+ Repair & Service Categories",
    desc: "Find verified specialists for Electrical, Plumbing, AC Repair, Solar, Carpentry, Masonry, Cleaning, and Painting under one app.",
    icon: Wrench,
    iconBg: "bg-teal-100 text-teal-600 border-teal-200/80 shadow-teal-500/10"
  },
  {
    title: "Location-Based Matching",
    desc: "Discover background-checked local technicians closest to your location anywhere across Sri Lanka.",
    icon: MapPin,
    iconBg: "bg-rose-100 text-rose-600 border-rose-200/80 shadow-rose-500/10"
  }
];

export default function FeaturesSection() {
  return (
    <section id="features" className="pt-16 pb-16 scroll-mt-16 bg-white relative border-b border-slate-200">
      <div className="max-w-7xl mx-auto px-6">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-100 border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            Why Choose <span className="font-sinhala-heading font-extrabold text-emerald-700 mx-1">අපේ බාස්</span> (Ape Baas)
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            Built for Total Safety, <span className="gradient-title-text">Speed & Peace of Mind</span>
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            We eliminated the hassle of finding reliable local technicians with modern digital verification and direct communication.
          </p>
        </div>

        {/* Features Grid with Spotlight Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature, idx) => {
            const IconComponent = feature.icon;
            return (
              <SpotlightCard 
                key={idx}
                className="p-8 border border-slate-200/90 bg-white flex flex-col justify-between text-left group shadow-xs hover:shadow-xl hover:border-[#002B49]/40 transition-all duration-300"
                spotlightColor="rgba(0, 43, 73, 0.08)"
                style={{ borderRadius: '24px' }}
              >
                <div>
                  <div className={`w-14 h-14 rounded-2xl border flex items-center justify-center mb-6 shadow-md group-hover:scale-110 transition-transform duration-300 ${feature.iconBg}`}>
                    <IconComponent size={28} />
                  </div>

                  <h3 className="text-xl font-extrabold text-[#002B49] mb-3 group-hover:text-emerald-700 transition-colors">
                    {feature.title}
                  </h3>

                  <p className="text-sm sm:text-base text-slate-700 font-medium leading-relaxed">
                    {feature.desc}
                  </p>
                </div>

                <div className="pt-6 mt-6 border-t border-slate-100 flex items-center gap-1.5 text-xs font-extrabold text-[#002B49] group-hover:text-emerald-700 transition-colors">
                  <span>Learn more</span>
                  <ArrowUpRight size={15} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
                </div>
              </SpotlightCard>
            );
          })}
        </div>

      </div>
    </section>
  );
}
