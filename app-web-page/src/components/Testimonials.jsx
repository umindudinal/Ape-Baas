import React, { useState, useEffect } from 'react';
import { Star, Quote, Sparkles, CheckCircle2, MessageSquarePlus, Send, ThumbsUp, MessageCircle, Loader2 } from 'lucide-react';
import { fetchReviewsFromSupabase, saveReviewToSupabase, DEFAULT_DATABASE_REVIEWS } from '../services/supabaseReviews';

export default function Testimonials() {
  // Load initial comments from localStorage (or fallback to database reviews)
  const [reviewsList, setReviewsList] = useState(() => {
    const saved = localStorage.getItem('apebaas_user_reviews');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed) && parsed.length > 0) {
          return parsed;
        }
      } catch (e) {
        return DEFAULT_DATABASE_REVIEWS;
      }
    }
    return DEFAULT_DATABASE_REVIEWS;
  });

  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showForm, setShowForm] = useState(false);

  // New Comment Form State
  const [name, setName] = useState('');
  const [city, setCity] = useState('');
  const [service, setService] = useState('AC Service Booking');
  const [quote, setQuote] = useState('');
  const [stars, setStars] = useState(5);
  const [hoverStars, setHoverStars] = useState(0);
  const [submitted, setSubmitted] = useState(false);

  // Load reviews from Supabase Cloud on page load
  useEffect(() => {
    async function loadCloudReviews() {
      setIsLoading(true);
      const cloudData = await fetchReviewsFromSupabase();
      if (cloudData && Array.isArray(cloudData) && cloudData.length > 0) {
        setReviewsList(cloudData);
        localStorage.setItem('apebaas_user_reviews', JSON.stringify(cloudData));
      }
      setIsLoading(false);
    }
    loadCloudReviews();
  }, []);

  // Persist reviews list to localStorage whenever updated
  useEffect(() => {
    localStorage.setItem('apebaas_user_reviews', JSON.stringify(reviewsList));
  }, [reviewsList]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name.trim() || !quote.trim() || isSubmitting) return;

    setIsSubmitting(true);

    const gradients = [
      "from-emerald-500 to-teal-600",
      "from-sky-500 to-blue-600",
      "from-purple-500 to-indigo-600",
      "from-amber-500 to-orange-600"
    ];
    const randomGradient = gradients[Math.floor(Math.random() * gradients.length)];

    const newReview = {
      id: Date.now(),
      quote: quote.trim(),
      name: name.trim(),
      city: city.trim() || "Sri Lanka",
      service: service,
      avatarBg: randomGradient,
      stars: stars,
      isRecent: true,
      date: new Date().toLocaleDateString('en-GB')
    };

    // Save directly to Supabase Database
    await saveReviewToSupabase(newReview);

    const updatedList = [newReview, ...reviewsList];
    setReviewsList(updatedList);
    setName('');
    setCity('');
    setQuote('');
    setStars(5);
    setSubmitted(true);
    setIsSubmitting(false);

    setTimeout(() => {
      setSubmitted(false);
      setShowForm(false);
    }, 3000);
  };

  return (
    <section id="reviews" className="pt-16 pb-16 scroll-mt-16 bg-slate-50 text-slate-900 relative overflow-hidden">

      {/* Background Soft Orbs */}
      <div className="absolute top-1/2 left-1/3 -translate-x-1/2 -translate-y-1/2 w-150 h-150 bg-[#002B49]/5 rounded-full blur-[130px] pointer-events-none"></div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">

        {/* Section Header & Form Toggle Button */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-16 text-left">
          <div className="max-w-2xl">
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-slate-200 text-[#002B49] text-xs font-extrabold uppercase tracking-wider mb-4 shadow-2xs">
              <Sparkles size={14} className="text-[#002B49]" /> User Comments & Reviews
            </div>
            <h2 className="font-display text-3xl sm:text-4xl lg:text-5xl font-extrabold text-[#002B49] tracking-tight leading-tight mb-4">
              What Users Say About <br /> <span className="font-sinhala-heading text-emerald-700 font-extrabold">අපේ බාස්</span>
            </h2>
            <p className="text-slate-600 text-base sm:text-lg">
              පරිශීලකයින් විසින් සෘජුවම එකතු කරන ලද අදහස් සහ Ratings මෙතැනින් බලන්න.
            </p>
          </div>

          <button
            onClick={() => setShowForm(!showForm)}
            className="btn-glow-emerald px-6 py-3.5 rounded-xl font-extrabold text-sm flex items-center gap-2.5 shrink-0 self-start md:self-auto cursor-pointer no-underline shadow-md"
            style={{ borderRadius: '14px' }}
          >
            <MessageSquarePlus size={18} />
            <span>{showForm ? 'Close Form' : 'Write a Review / අදහසක් එක් කරන්න'}</span>
          </button>
        </div>

        {/* Dynamic Comment / Review Form Box */}
        {showForm && (
          <div className="mb-16 glass-card p-8 rounded-3xl border border-slate-200 bg-white text-left shadow-2xl animate-fade-in" style={{ borderRadius: '26px' }}>
            <h3 className="text-xl font-extrabold text-[#002B49] mb-2 flex items-center gap-2">
              <MessageSquarePlus size={20} className="text-emerald-600" />
              <span>Share Your App Experience / ඔබේ අදහස පළ කරන්න</span>
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 mb-6">
              Your honest feedback helps us improve the newly launched අපේ බාස් (Ape Baas) mobile app.
            </p>

            {submitted ? (
              <div className="p-6 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-800 flex items-center gap-3 font-bold text-sm">
                <ThumbsUp size={22} className="text-emerald-600 shrink-0" />
                <span>ස්තූතියි! ඔබේ අදහස සාර්ථකව සටහන් විය.</span>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-5">

                {/* Star Rating Picker */}
                <div>
                  <label className="block text-xs font-extrabold text-[#002B49] uppercase tracking-wider mb-2">
                    Select Rating / ඇගයීම *
                  </label>
                  <div className="flex items-center gap-1.5">
                    {[1, 2, 3, 4, 5].map((starVal) => (
                      <button
                        type="button"
                        key={starVal}
                        onClick={() => setStars(starVal)}
                        onMouseEnter={() => setHoverStars(starVal)}
                        onMouseLeave={() => setHoverStars(0)}
                        className="p-1 rounded-lg hover:scale-115 transition-transform cursor-pointer focus:outline-none"
                      >
                        <Star
                          size={26}
                          className={`transition-colors ${(hoverStars || stars) >= starVal
                              ? 'fill-amber-400 text-amber-400'
                              : 'text-slate-300 fill-slate-100'
                            }`}
                        />
                      </button>
                    ))}
                    <span className="ml-3 text-xs font-extrabold text-slate-600 bg-slate-100 px-3 py-1 rounded-full border border-slate-200">
                      {stars} / 5 Stars
                    </span>
                  </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {/* Name Input */}
                  <div>
                    <label className="block text-xs font-extrabold text-[#002B49] uppercase tracking-wider mb-1.5">
                      Your Name / ඔබේ නම *
                    </label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Kasun Perera"
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none text-sm text-slate-900 bg-slate-50 font-medium"
                    />
                  </div>

                  {/* City Input */}
                  <div>
                    <label className="block text-xs font-extrabold text-[#002B49] uppercase tracking-wider mb-1.5">
                      City / නගරය
                    </label>
                    <input
                      type="text"
                      placeholder="e.g. Colombo, Kandy"
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none text-sm text-slate-900 bg-slate-50 font-medium"
                    />
                  </div>
                </div>

                {/* Service Dropdown */}
                <div>
                  <label className="block text-xs font-extrabold text-[#002B49] uppercase tracking-wider mb-1.5">
                    Service Category Used / ලබාගත් සේවාව
                  </label>
                  <select
                    value={service}
                    onChange={(e) => setService(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl border focus:border-[#002B49] focus:outline-none text-sm text-slate-900 bg-slate-50 font-medium"
                  >
                    <option value="AC Service Booking">AC Service Booking</option>
                    <option value="Electrical Repair">Electrical Repair</option>
                    <option value="Plumbing Service">Plumbing Service</option>
                    <option value="Solar Power Service">Solar Power Service</option>
                    <option value="Carpentry Works">Carpentry Works</option>
                    <option value="House Cleaning">House Cleaning</option>
                    <option value="Painting Service">Painting Service</option>
                    <option value="Masonry Repairs">Masonry Repairs</option>
                  </select>
                </div>

                {/* Comment Textarea */}
                <div>
                  <label className="block text-xs font-extrabold text-[#002B49] uppercase tracking-wider mb-1.5">
                    Your Review / Comment *
                  </label>
                  <textarea
                    rows={4}
                    required
                    placeholder="Write your experience..."
                    value={quote}
                    onChange={(e) => setQuote(e.target.value)}
                    className="w-full px-4 py-3 rounded-xl border border-slate-200 focus:outline-none text-sm text-slate-900 bg-slate-50 font-medium"
                  ></textarea>
                </div>

                {/* Submit Button */}
                <div className="flex justify-end pt-2">
                  <button
                    type="submit"
                    className="btn-glow-emerald px-8 py-3.5 rounded-xl font-extrabold text-sm flex items-center gap-2 shrink-0 cursor-pointer shadow-lg"
                    style={{ borderRadius: '12px' }}
                  >
                    <Send size={16} />
                    <span>Submit Review</span>
                  </button>
                </div>

              </form>
            )}

          </div>
        )}

        {/* Reviews Grid or Clean Empty State */}
        {reviewsList.length === 0 ? (
          <div className="glass-card p-12 rounded-3xl border border-dashed border-slate-300 bg-white text-center max-w-2xl mx-auto shadow-xs" style={{ borderRadius: '24px' }}>
            <div className="w-16 h-16 rounded-full bg-slate-100 text-[#002B49] border border-slate-200 mx-auto flex items-center justify-center mb-4">
              <MessageCircle size={32} className="text-emerald-600" />
            </div>
            <h3 className="font-extrabold text-xl text-[#002B49] mb-2">
              තවම කිසිදු කමෙන්ට් එකක් එක්කර නොමැත
            </h3>
            <p className="text-slate-600 text-sm mb-6 max-w-md mx-auto">
              අපේ බාස් (Ape Baas) ඇප් එක පිළිබඳ ඔබේ පළමු අදහස හෝ අත්දැකීම පළමුවෙන්ම පළ කරන්න!
            </p>
            <button
              onClick={() => setShowForm(true)}
              className="btn-glow-emerald px-6 py-3 rounded-xl font-extrabold text-sm inline-flex items-center gap-2 shadow-md cursor-pointer"
              style={{ borderRadius: '12px' }}
            >
              <MessageSquarePlus size={18} />
              <span>පළමු කමෙන්ට් එක එක් කරන්න (Write Review)</span>
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {reviewsList.map((item) => (
              <div
                key={item.id}
                className={`glass-card p-8 rounded-3xl border border-slate-200/90 bg-white flex flex-col justify-between text-left group shadow-xs hover:shadow-2xl hover:border-[#002B49]/40 transition-all duration-300 ${item.isRecent ? 'ring-2 ring-emerald-500/50 bg-emerald-50/20' : ''
                  }`}
                style={{ borderRadius: '24px' }}
              >
                <div>
                  {/* Header Stars & Quote */}
                  <div className="flex items-center justify-between mb-6">
                    <div className="flex items-center gap-1">
                      {[...Array(item.stars)].map((_, i) => (
                        <Star key={i} size={18} className="fill-amber-400 text-amber-400" />
                      ))}
                    </div>

                    <div className="flex items-center gap-2">
                      {item.isRecent && (
                        <span className="text-[10px] font-extrabold px-2 py-0.5 rounded-full bg-emerald-500 text-white shadow-xs">
                          New
                        </span>
                      )}
                      <Quote size={26} className="text-[#002B49]/20 group-hover:text-[#002B49]/40 transition-colors" />
                    </div>
                  </div>

                  <p className="text-slate-700 leading-relaxed text-sm sm:text-base mb-6 font-medium">
                    "{item.quote}"
                  </p>
                </div>

                {/* Reviewer Details */}
                <div className="pt-5 border-t border-slate-100 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-11 h-11 rounded-full bg-linear-to-br ${item.avatarBg} text-white font-display font-extrabold flex items-center justify-center text-sm shadow-md`}>
                      {item.name.charAt(0)}
                    </div>
                    <div>
                      <div className="font-extrabold text-[#002B49] text-sm flex items-center gap-1">
                        <span>{item.name}</span>
                        <CheckCircle2 size={13} className="text-emerald-600" />
                      </div>
                      <div className="text-xs text-slate-500 font-semibold mt-0.5">📍 {item.city}</div>
                    </div>
                  </div>

                  <span className="text-[10px] font-extrabold px-2.5 py-1 rounded-full bg-slate-100 text-[#002B49] border border-slate-200">
                    {item.service}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}

      </div>
    </section>
  );
}
