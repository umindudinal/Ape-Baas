import { useState } from 'react';
import { Download, CheckCircle2, ChevronRight } from 'lucide-react';

import step1Img from '../assets/step_1.jpeg';
import step2Img from '../assets/step_2.jpeg';
import step3Img from '../assets/step_3.jpeg';
import step4Img from '../assets/step_4.jpeg';
import step5Img from '../assets/step_5.jpeg';

const installSteps = [
  {
    id: 1,
    stepNum: "Step 01",
    title: "Download APK File",
    titleSi: "APK ගොනුව භාගත කරන්න",
    desc: "Click the 'Download App (APK)' button on our website to download the official ape_baas_v1.0.apk file to your Android phone.",
    image: step1Img,
    badge: "1. Direct Download",
    color: "from-emerald-500 to-teal-600",
    badgeBg: "bg-emerald-50 text-emerald-800 border-emerald-200"
  },
  {
    id: 2,
    stepNum: "Step 02",
    title: "Open Downloaded File",
    titleSi: "භාගත වූ ගොනුව විවෘත කරන්න",
    desc: "Open your browser download list or tap the download complete notification on your phone's notification bar.",
    image: step2Img,
    badge: "2. Open File",
    color: "from-sky-500 to-blue-600",
    badgeBg: "bg-sky-50 text-sky-800 border-sky-200"
  },
  {
    id: 3,
    stepNum: "Step 03",
    title: "Allow Unknown Source",
    titleSi: "ආරක්ෂණ අවසරය (Settings) ලබාදෙන්න",
    desc: "If Android prompts a security alert, tap 'Settings' and switch ON 'Allow from this source' for your browser or file manager.",
    image: step3Img,
    badge: "3. Allow Permission",
    color: "from-amber-500 to-orange-600",
    badgeBg: "bg-amber-50 text-amber-800 border-amber-200"
  },
  {
    id: 4,
    stepNum: "Step 04",
    title: "Tap Install",
    titleSi: "Install බොත්තම ඔබන්න",
    desc: "Return to the installation dialog screen and tap the 'Install' button to place the app on your smartphone.",
    image: step4Img,
    badge: "4. Click Install",
    color: "from-purple-500 to-indigo-600",
    badgeBg: "bg-purple-50 text-purple-800 border-purple-200"
  },
  {
    id: 5,
    stepNum: "Step 05",
    title: "Open & Start Booking",
    titleSi: "ඇප් එක විවෘත කර භාවිතා කරන්න",
    desc: "Once installed, tap 'Open' to launch අපේ බාස් (Ape Baas), enter your phone number for instant OTP login, and find local pros!",
    image: step5Img,
    badge: "5. Ready to Use",
    color: "from-emerald-600 to-emerald-800",
    badgeBg: "bg-emerald-100 text-emerald-900 border-emerald-300"
  }
];

export default function InstallationGuide() {
  const [activeStep, setActiveStep] = useState(0);
  const currentStep = installSteps[activeStep];

  return (
    <section id="install-guide" className="pt-16 pb-16 scroll-mt-16 bg-slate-50 text-slate-900 relative border-b border-slate-200 overflow-hidden">
      
      {/* Background Glow Orbs */}
      <div className="absolute top-1/2 left-1/4 -translate-x-1/2 -translate-y-1/2 w-150 h-150 bg-[#002B49]/5 rounded-full blur-[140px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-14">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-slate-200 text-[#002B49] text-xs sm:text-sm font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            <Download size={15} className="text-emerald-600" /> Easy 5-Step Android Guide
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            How to Install <span className="font-sinhala-heading text-emerald-700 font-extrabold">අපේ බාස්</span> APK on Your Phone
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Follow this quick 5-step visual guide to safely install our official Android application on your smartphone.
          </p>
        </div>

        {/* 5-Step Progress Buttons Bar */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3 mb-12">
          {installSteps.map((step, index) => {
            const isActive = activeStep === index;
            return (
              <button
                key={step.id}
                onClick={() => setActiveStep(index)}
                className={`p-3.5 rounded-2xl border text-left transition-all duration-200 cursor-pointer flex flex-col justify-between ${
                  isActive
                    ? 'bg-[#002B49] text-white border-[#002B49] shadow-lg scale-105'
                    : 'bg-white text-slate-700 hover:bg-slate-100 border-slate-200'
                }`}
                style={{ borderRadius: '18px' }}
              >
                <div className="flex items-center justify-between mb-2">
                  <span className={`text-[10px] sm:text-xs font-extrabold uppercase px-2 py-0.5 rounded-md ${
                    isActive ? 'bg-white/20 text-white' : 'bg-slate-100 text-slate-600'
                  }`}>
                    {step.stepNum}
                  </span>
                  {isActive && <CheckCircle2 size={16} className="text-emerald-400" />}
                </div>

                <div className="font-extrabold text-xs sm:text-sm leading-snug line-clamp-1">
                  {step.title}
                </div>
                <div className={`text-[11px] font-extrabold font-sinhala line-clamp-1 mt-0.5 ${
                  isActive ? 'text-emerald-300' : 'text-emerald-700'
                }`}>
                  {step.titleSi}
                </div>
              </button>
            );
          })}
        </div>

        {/* Active Step Showcase Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center bg-white p-8 sm:p-12 rounded-3xl border border-slate-200/90 shadow-xl" style={{ borderRadius: '32px' }}>
          
          {/* Left Column: Phone Frame with Step Image */}
          <div className="lg:col-span-6 flex justify-center items-center">
            <div className="relative w-56 sm:w-64 max-w-full rounded-[22px] bg-slate-950 p-2 border-[3.5px] border-slate-800 shadow-xl flex flex-col items-center" style={{ borderRadius: '22px', boxShadow: '0 22px 55px rgba(0, 43, 73, 0.28)' }}>
              {/* Screenshot Image Container - Hugging exact image */}
              <div className="w-full rounded-[15px] overflow-hidden relative border border-slate-700/60 shadow-md">
                <img 
                  src={currentStep.image} 
                  alt={currentStep.title} 
                  className="w-full h-auto block object-contain"
                />
              </div>
              {/* Phone Gesture Bar */}
              <div className="w-14 h-1 bg-slate-500/80 rounded-full my-1.5 shrink-0"></div>
            </div>
          </div>

          {/* Right Column: Step Description & Navigation Actions */}
          <div className="lg:col-span-6 text-left">
            <div className="flex items-center gap-2 mb-4">
              <span className={`text-xs font-extrabold px-3 py-1 rounded-full border uppercase tracking-wider ${currentStep.badgeBg}`}>
                {currentStep.stepNum} • {currentStep.badge}
              </span>
            </div>

            <h3 className="font-display text-2xl sm:text-3xl font-extrabold text-[#002B49] mb-1">
              {currentStep.title}
            </h3>

            <div className="text-base sm:text-lg font-extrabold text-emerald-700 font-sinhala mb-4">
              {currentStep.titleSi}
            </div>

            <p className="text-slate-700 text-sm sm:text-base leading-relaxed font-medium mb-8">
              {currentStep.desc}
            </p>

            {/* Next / Previous Navigation & Direct Download CTA */}
            <div className="flex flex-wrap items-center gap-4 pt-6 border-t border-slate-100">
              <a 
                href="/ape_baas_v1.0.apk"
                download="ape_baas_v1.0.apk"
                className="btn-glow-emerald px-6 py-3.5 rounded-xl font-extrabold text-sm inline-flex items-center gap-2.5 no-underline shadow-md"
                style={{ borderRadius: '12px' }}
              >
                <Download size={18} />
                <span>Download APK (v1.0)</span>
              </a>

              <div className="flex items-center gap-2 ml-auto">
                <button
                  disabled={activeStep === 0}
                  onClick={() => setActiveStep(prev => Math.max(0, prev - 1))}
                  className="px-4 py-2.5 rounded-xl border border-slate-200 text-slate-700 font-extrabold text-xs disabled:opacity-40 disabled:cursor-not-allowed hover:bg-slate-100 cursor-pointer"
                  style={{ borderRadius: '10px' }}
                >
                  Previous
                </button>
                <button
                  disabled={activeStep === installSteps.length - 1}
                  onClick={() => setActiveStep(prev => Math.min(installSteps.length - 1, prev + 1))}
                  className="px-4 py-2.5 rounded-xl bg-[#002B49] text-white font-extrabold text-xs disabled:opacity-40 disabled:cursor-not-allowed hover:bg-[#00192C] cursor-pointer flex items-center gap-1"
                  style={{ borderRadius: '10px' }}
                >
                  <span>Next Step</span>
                  <ChevronRight size={15} />
                </button>
              </div>
            </div>

          </div>

        </div>

      </div>
    </section>
  );
}
