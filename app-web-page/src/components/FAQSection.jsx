import React, { useState } from 'react';
import { ChevronDown, HelpCircle, PhoneCall } from 'lucide-react';

const faqs = [
  {
    category: "Homeowners",
    q: "Is the අපේ බාස් (Ape Baas) Mobile App free to download and search?",
    qSi: "අපේ බාස් ඇප් එක භාගත කිරීම සහ භාවිතය නොමිලේම සපයනවාද?",
    a: "Yes! Downloading the official APK file, searching for background-checked local technicians, and browsing 12+ service categories is 100% free for all users."
  },
  {
    category: "Homeowners",
    q: "How do I register a customer account in 30 seconds?",
    qSi: "පාරිභෝගික ගිණුමක් ආරම්භ කරන්නේ කෙසේද?",
    a: "All you need is your mobile phone number! Enter your number to receive an instant 4-digit SMS OTP, verify it, and your account is ready to use without remembering any passwords."
  },
  {
    category: "Homeowners",
    q: "How do I find or contact a local technician?",
    qSi: "බාස් කෙනෙකු සොයාගන්නේ හෝ සම්බන්ධ වන්නේ කෙසේද?",
    a: "Simply open the app, choose your service category (Electrical, Plumbing, AC, Solar, etc.), view nearby verified specialists, and contact them directly to schedule work."
  },
  {
    category: "Technicians",
    q: "How can local technicians join as Service Providers?",
    qSi: "බාස්ලා සහ සේවා සපයන්නන් ඇප් එකට එකතු වන්නේ කෙසේද?",
    a: "Skilled technicians can download the app, select 'Provider Mode', and submit their National Identity Card (NIC), address, and skill credentials for verification."
  },
  {
    category: "Payments & Safety",
    q: "How are job payments handled?",
    qSi: "අලුත්වැඩියා කටයුතු සඳහා ගෙවීම් සිදුවන්නේ කෙසේද?",
    a: "You discuss and agree on the payment estimate directly with the technician upon job completion with 100% transparency and zero hidden app fees."
  },
  {
    category: "Payments & Safety",
    q: "Are the registered technicians verified for safety?",
    qSi: "ලියාපදිංචි බාස්ලාගේ ආරක්‍ෂාව සහ සත්‍යාපනය පරීක්ෂා කර තිබේද?",
    a: "Yes! Every technician undergoes mandatory National Identity Card (NIC), address, and background verification before being approved for jobs on the platform."
  }
];

export default function FAQSection() {
  const [openIndex, setOpenIndex] = useState(0);
  const [activeCategory, setActiveCategory] = useState("All");

  const filteredFaqs = activeCategory === "All" 
    ? faqs 
    : faqs.filter(f => f.category === activeCategory);

  const toggleFAQ = (index) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section id="faq" className="pt-16 pb-16 scroll-mt-16 bg-white text-slate-900 relative border-t border-slate-200 overflow-hidden">
      
      {/* Background Soft Glow */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-150 h-150 bg-[#002B49]/5 rounded-full blur-[140px] pointer-events-none"></div>

      <div className="max-w-4xl mx-auto px-6 relative z-10">
        
        {/* Section Header */}
        <div className="text-center max-w-3xl mx-auto mb-12">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-slate-100 border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
            <HelpCircle size={14} className="text-[#002B49]" /> Frequently Asked Questions
          </div>
          <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
            Got Questions About <span className="font-sinhala-heading text-emerald-700 font-extrabold">අපේ බාස්</span> App?
          </h2>
          <p className="text-slate-600 text-base sm:text-lg">
            Everything you need to know about using Sri Lanka's newest digital home service platform.
          </p>
        </div>

        {/* Category Filter Pills */}
        <div className="flex flex-wrap justify-center gap-2.5 mb-12">
          {["All", "Homeowners", "Technicians", "Payments & Safety"].map((cat) => (
            <button
              key={cat}
              onClick={() => {
                setActiveCategory(cat);
                setOpenIndex(0);
              }}
              className={`px-4.5 py-2.5 rounded-full text-xs font-extrabold transition-all cursor-pointer ${
                activeCategory === cat
                  ? 'bg-[#002B49] text-white shadow-md'
                  : 'bg-slate-100 text-slate-700 hover:bg-slate-200 hover:text-[#002B49] border border-slate-200'
              }`}
              style={{ borderRadius: '9999px' }}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* FAQ Accordion List */}
        <div className="space-y-4 text-left mb-16">
          {filteredFaqs.map((item, idx) => {
            const isOpen = openIndex === idx;
            return (
              <div 
                key={idx}
                className={`glass-card rounded-2xl border transition-all duration-200 overflow-hidden shadow-2xs ${
                  isOpen 
                    ? 'border-l-4 border-l-[#002B49] border-slate-300 bg-slate-50/70 shadow-md' 
                    : 'border-slate-200 bg-white hover:border-slate-300'
                }`}
                style={{ borderRadius: '18px' }}
              >
                {/* Question Row */}
                <button
                  onClick={() => toggleFAQ(idx)}
                  className="w-full p-6 text-left flex items-center justify-between gap-4 font-extrabold text-base sm:text-lg text-[#002B49] cursor-pointer hover:text-emerald-700 transition-colors"
                  style={{ background: 'none', border: 'none' }}
                >
                  <div className="flex items-center gap-3">
                    <div className={`w-8 h-8 rounded-lg flex items-center justify-center shrink-0 ${
                      isOpen ? 'bg-[#002B49] text-white' : 'bg-slate-100 text-[#002B49]'
                    }`}>
                      <HelpCircle size={18} />
                    </div>
                    <div>
                      <div className="text-base sm:text-lg font-extrabold text-[#002B49]">{item.q}</div>
                      <div className="text-xs sm:text-sm font-extrabold text-emerald-700 font-sinhala mt-1">{item.qSi}</div>
                    </div>
                  </div>
                  <ChevronDown 
                    size={20} 
                    className={`text-slate-400 transition-transform duration-300 shrink-0 ${
                      isOpen ? 'rotate-180 text-[#002B49]' : ''
                    }`} 
                  />
                </button>

                {/* Answer Content - Smooth CSS Grid Transition */}
                <div 
                  className={`grid transition-all duration-500 ease-in-out ${
                    isOpen ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'
                  }`}
                >
                  <div className="overflow-hidden">
                    <div className="px-6 pb-6 pt-3 text-slate-600 text-sm sm:text-base leading-relaxed border-t border-slate-200/60 sm:pl-17">
                      {item.a}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Still Have Questions Support Banner */}
        <div className="p-8 rounded-3xl bg-slate-50 border border-slate-200 flex flex-col sm:flex-row items-center justify-between gap-6 text-left shadow-xs" style={{ borderRadius: '24px' }}>
          <div>
            <h4 className="font-extrabold text-lg text-[#002B49] mb-1">
              Still Have Questions About අපේ බාස් (Ape Baas)?
            </h4>
            <p className="text-xs sm:text-sm text-slate-600">
              Our support team is available 24/7 to assist with your app download & booking questions.
            </p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <a 
              href="tel:+94771234567"
              className="btn-glow-emerald px-5 py-2.5 rounded-xl text-xs font-extrabold flex items-center gap-2 no-underline"
              style={{ borderRadius: '12px' }}
            >
              <PhoneCall size={15} />
              <span>Call Support</span>
            </a>
          </div>
        </div>

      </div>
    </section>
  );
}
