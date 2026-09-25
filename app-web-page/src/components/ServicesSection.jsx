import React from 'react';
import { Sun, Zap, Wrench, Wind, Hammer, Paintbrush, Sparkles, LayoutGrid, ArrowUpRight } from 'lucide-react';
import SpotlightCard from './SpotlightCard';

const services = [
  {
    id: "solar",
    name: "Solar Power Systems",
    nameSi: "සූර්ය බලශක්ති සේවා",
    desc: "Solar panel mounting, inverter diagnostics, grid-tie maintenance & panel washing.",
    tag: "Clean Energy",
    icon: Sun,
    iconBg: "bg-amber-100 text-amber-600 border-amber-200/80 shadow-amber-500/10",
    badgeBg: "bg-amber-50 text-amber-800 border-amber-200"
  },
  {
    id: "electrical",
    name: "Electrical Repairs & Wiring",
    nameSi: "විදුලි අලුත්වැඩියා",
    desc: "Circuit breaker tripping fix, 3-phase power balance, switch socket fitting & rewiring.",
    tag: "24/7 Emergency",
    icon: Zap,
    iconBg: "bg-yellow-100 text-yellow-600 border-yellow-200/80 shadow-yellow-500/10",
    badgeBg: "bg-yellow-50 text-yellow-800 border-yellow-200"
  },
  {
    id: "plumbing",
    name: "Plumbing & Water Piping",
    nameSi: "ජල නල & පයිප්ප රෙපයාර්",
    desc: "Water leakage fix, pipe unclogging, water pump repair, tap & storage tank fitting.",
    tag: "Top Rated",
    icon: Wrench,
    iconBg: "bg-sky-100 text-sky-600 border-sky-200/80 shadow-sky-500/10",
    badgeBg: "bg-sky-50 text-sky-800 border-sky-200"
  },
  {
    id: "ac",
    name: "AC Service & Chemical Wash",
    nameSi: "ඒසී සේවාවන් & රෙපයාර්",
    desc: "Deep chemical unit pressure cleaning, R410/R32 gas top-up, cooling fault repair.",
    tag: "Popular",
    icon: Wind,
    iconBg: "bg-cyan-100 text-cyan-600 border-cyan-200/80 shadow-cyan-500/10",
    badgeBg: "bg-cyan-50 text-cyan-800 border-cyan-200"
  },
  {
    id: "carpentry",
    name: "Carpentry & Furniture Works",
    nameSi: "වඩු කාර්මික සේවා",
    desc: "Door/window frame fitting, custom kitchen cupboards, bed & wooden furniture restoration.",
    tag: "Master Craftsmen",
    icon: Hammer,
    iconBg: "bg-orange-100 text-orange-600 border-orange-200/80 shadow-orange-500/10",
    badgeBg: "bg-orange-50 text-orange-800 border-orange-200"
  },
  {
    id: "painting",
    name: "Painting & Waterproofing",
    nameSi: "තීන්ත ආලේපනය",
    desc: "Interior & exterior wall painting, wall putty finish, weather coat & slab waterproofing.",
    tag: "Premium Finish",
    icon: Paintbrush,
    iconBg: "bg-emerald-100 text-emerald-600 border-emerald-200/80 shadow-emerald-500/10",
    badgeBg: "bg-emerald-50 text-emerald-800 border-emerald-200"
  },
  {
    id: "cleaning",
    name: "Deep Cleaning & Gully Service",
    nameSi: "නිවෙස් පිරිසිදු කිරීම්",
    desc: "Full home sanitization, sofa steam wash, water tank cleaning & gully bowser clearance.",
    tag: "Hygiene Guaranteed",
    icon: Sparkles,
    iconBg: "bg-purple-100 text-purple-600 border-purple-200/80 shadow-purple-500/10",
    badgeBg: "bg-purple-50 text-purple-800 border-purple-200"
  },
  {
    id: "masonry",
    name: "Masonry & Civil Repairs",
    nameSi: "මේසන් & ගොඩනැගිලි රෙපයාර්",
    desc: "Floor & wall tile laying, brickwork, wall plastering, concrete crack & leak sealing.",
    tag: "Construction",
    icon: LayoutGrid,
    iconBg: "bg-indigo-100 text-indigo-600 border-indigo-200/80 shadow-indigo-500/10",
    badgeBg: "bg-indigo-50 text-indigo-800 border-indigo-200"
  }
];

export default function ServicesSection() {
  return (
    <section id="services" className="pt-16 pb-16 scroll-mt-16 bg-slate-50 text-slate-900 relative">
      <div className="max-w-7xl mx-auto px-6">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            Service Categories
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            Everything Your Home Needs, <span className="gradient-title-text">Delivered On-Demand</span>
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Directly connect with background-checked local specialists for any home maintenance or repair job on <strong className="font-sinhala-heading font-extrabold text-emerald-700">අපේ බාස්</strong> (Ape Baas) app.
          </p>
        </div>

        {/* Services Grid with Spotlight Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {services.map((service) => {
            const IconComponent = service.icon;
            return (
              <SpotlightCard 
                key={service.id}
                className="p-7 border border-slate-200/90 bg-white flex flex-col justify-between group text-left shadow-xs hover:shadow-xl hover:border-[#002B49]/40 transition-all duration-300"
                spotlightColor="rgba(0, 43, 73, 0.08)"
                style={{ borderRadius: '24px' }}
              >
                <div>
                  {/* Top Bar: Colorful Icon Container & Tag Badge */}
                  <div className="flex items-center justify-between mb-6">
                    <div className={`w-14 h-14 rounded-2xl border flex items-center justify-center shadow-md group-hover:scale-110 transition-transform duration-300 ${service.iconBg}`}>
                      <IconComponent size={28} />
                    </div>

                    <span className={`text-xs font-extrabold px-3 py-1 rounded-full border ${service.badgeBg}`}>
                      {service.tag}
                    </span>
                  </div>

                  {/* Title & Sinhala Subtitle */}
                  <h3 className="text-lg font-extrabold text-[#002B49] mb-0.5 group-hover:text-emerald-700 transition-colors">
                    {service.name}
                  </h3>
                  <div className="text-sm font-extrabold text-emerald-700 mb-3 font-sinhala">
                    {service.nameSi}
                  </div>

                  {/* Description */}
                  <p className="text-sm text-slate-700 leading-relaxed font-medium mb-6">
                    {service.desc}
                  </p>
                </div>

                {/* Footer Link with Direct APK Download Action */}
                <a 
                  href="/ape_baas_v1.0.apk"
                  download="ape_baas_v1.0.apk"
                  className="pt-4 border-t border-slate-100 flex items-center justify-between text-xs font-extrabold text-[#002B49] group-hover:text-emerald-700 transition-colors no-underline"
                >
                  <span>Find {service.name.split(' ')[0]} Baas</span>
                  <ArrowUpRight size={16} className="group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-transform" />
                </a>

              </SpotlightCard>
            );
          })}
        </div>

      </div>
    </section>
  );
}
