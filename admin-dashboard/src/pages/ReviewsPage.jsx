import React, { useState } from 'react';
import { 
  MessageSquare, 
  Star, 
  Trash2, 
  AlertTriangle, 
  CheckCircle2, 
  ShieldAlert
} from 'lucide-react';

const ReviewsPage = ({ reviews, disputes, onDeleteReview, onResolveDispute }) => {
  const [activeTab, setActiveTab] = useState('reviews'); // 'reviews' | 'disputes'
  const [starFilter, setStarFilter] = useState('All');

  const filteredReviews = reviews.filter(r => {
    if (starFilter === 'All') return true;
    if (starFilter === 'Spam') return r.isSpam;
    return r.rating === Number(starFilter);
  });

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Sub Tabs */}
      <div className="flex items-center justify-between bg-white p-2 rounded-2xl border border-slate-200 shadow-xs flex-wrap sm:flex-nowrap gap-3">
        <div className="flex items-center gap-2">
          <button
            onClick={() => setActiveTab('reviews')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 cursor-pointer ${
              activeTab === 'reviews'
                ? 'bg-amber-500 text-slate-950 font-bold shadow-xs'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <MessageSquare className="w-4 h-4" />
            <span>Customer Reviews & Ratings</span>
            <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
              activeTab === 'reviews' ? 'bg-slate-950 text-amber-300' : 'bg-slate-100 text-slate-700'
            }`}>
              {reviews.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab('disputes')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 cursor-pointer ${
              activeTab === 'disputes'
                ? 'bg-rose-600 text-white shadow-sm font-bold'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <ShieldAlert className="w-4 h-4 text-rose-500" />
            <span>Customer Disputes & Complaints</span>
            {disputes.length > 0 && (
              <span className="px-2 py-0.5 rounded-full bg-rose-100 text-rose-800 text-[10px] font-bold">
                {disputes.length}
              </span>
            )}
          </button>
        </div>

        {activeTab === 'reviews' && (
          <div className="flex items-center gap-1">
            {['All', '5', '4', '1', 'Spam'].map((f) => (
              <button
                key={f}
                onClick={() => setStarFilter(f)}
                className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all cursor-pointer ${
                  starFilter === f
                    ? 'bg-amber-100 text-amber-800 border border-amber-300 font-bold'
                    : 'text-slate-600 hover:text-slate-900 bg-slate-50'
                }`}
              >
                {f === 'All' ? 'All' : f === 'Spam' ? 'Spam ⚠️' : `${f} ★`}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* TAB 1: REVIEWS MODERATION */}
      {activeTab === 'reviews' && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {filteredReviews.map((rev) => (
            <div
              key={rev.id}
              className={`p-5 rounded-2xl border transition-all space-y-3 shadow-xs ${
                rev.isSpam
                  ? 'bg-rose-50/50 border-rose-200'
                  : 'bg-white border-slate-200'
              }`}
            >
              <div className="flex items-start justify-between">
                <div>
                  <h4 className="font-bold text-slate-900 text-sm">{rev.customerName}</h4>
                  <p className="text-xs text-slate-500 font-medium">
                    Provider: <span className="text-amber-700 font-bold">{rev.providerName}</span> ({rev.service})
                  </p>
                </div>
                <div className="flex items-center gap-1 bg-amber-50 px-2.5 py-1 rounded-lg border border-amber-200">
                  <Star className="w-3.5 h-3.5 fill-amber-500 text-amber-500" />
                  <span className="text-xs font-bold text-amber-800">{rev.rating}.0</span>
                </div>
              </div>

              <p className="text-xs text-slate-700 bg-slate-50 p-3 rounded-xl border border-slate-200 leading-relaxed italic">
                "{rev.comment}"
              </p>

              <div className="flex items-center justify-between pt-1 text-[11px] text-slate-400">
                <span>{rev.date}</span>
                <div className="flex items-center gap-2">
                  {rev.isSpam && (
                    <span className="px-2 py-0.5 rounded bg-rose-50 text-rose-700 font-bold border border-rose-200">
                      Flagged Spam
                    </span>
                  )}
                  <button
                    onClick={() => onDeleteReview(rev.id)}
                    className="p-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-semibold flex items-center gap-1 text-xs cursor-pointer"
                    title="Delete abusive or spam comment"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                    <span>Delete</span>
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* TAB 2: DISPUTES RESOLUTION CENTER */}
      {activeTab === 'disputes' && (
        <div className="space-y-4">
          <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 flex items-center gap-3">
            <AlertTriangle className="w-6 h-6 text-rose-600 shrink-0" />
            <div>
              <h4 className="font-bold text-rose-900 text-sm">
                Customer Dispute Resolution Center
              </h4>
              <p className="text-xs text-rose-700">
                Intervene and resolve conflicts between clients and service providers.
              </p>
            </div>
          </div>

          {disputes.length === 0 ? (
            <div className="p-12 text-center rounded-2xl bg-white border border-slate-200 shadow-xs">
              <CheckCircle2 className="w-12 h-12 text-emerald-500 mx-auto mb-3" />
              <h4 className="text-base font-bold text-slate-900">
                No open customer disputes!
              </h4>
            </div>
          ) : (
            <div className="space-y-4">
              {disputes.map((dsp) => (
                <div key={dsp.id} className="p-6 rounded-2xl bg-white border border-slate-200 shadow-xs space-y-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <span className="font-mono font-bold text-xs text-rose-700 px-2.5 py-0.5 rounded bg-rose-50 border border-rose-200">
                        {dsp.id} • Booking #{dsp.bookingId}
                      </span>
                      <h4 className="font-bold text-slate-900 text-base mt-2">{dsp.issueCategory}</h4>
                      <p className="text-xs text-slate-500 mt-0.5">
                        Customer: <span className="text-slate-800 font-semibold">{dsp.customerName}</span> | Provider: <span className="text-slate-800 font-semibold">{dsp.providerName}</span>
                      </p>
                    </div>
                    <span className="px-3 py-1 rounded-full bg-amber-50 text-amber-700 border border-amber-200 text-xs font-bold">
                      {dsp.status}
                    </span>
                  </div>

                  <div className="p-3 bg-slate-50 rounded-xl border border-slate-200 text-xs text-slate-700">
                    <span className="text-slate-500 block mb-1 font-semibold">Complaint Description:</span>
                    {dsp.description}
                  </div>

                  <div className="flex items-center justify-between pt-2">
                    <span className="text-xs text-slate-500">{dsp.createdAt}</span>
                    <button
                      onClick={() => onResolveDispute(dsp.id)}
                      className="px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs flex items-center gap-2 shadow-xs cursor-pointer"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Mark as Resolved</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default ReviewsPage;
