import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  X, 
  UserCheck, 
  Phone, 
  Mail, 
  MapPin, 
  Star, 
  CheckCircle2, 
  ShieldAlert, 
  Award, 
  Calendar, 
  Eye, 
  Lock, 
  Unlock, 
  Trash2,
  Grid,
  FileText,
  BadgeCheck,
  Maximize2
} from 'lucide-react';

function getFormattedImageUrl(src) {
  if (!src || typeof src !== 'string' || src.trim() === '') return null;
  const clean = src.trim();
  if (clean.startsWith('http://') || clean.startsWith('https://') || clean.startsWith('data:image')) {
    return clean;
  }
  return `data:image/jpeg;base64,${clean}`;
}

const ProviderDetailsModal = ({ 
  isOpen, 
  onClose, 
  provider, 
  onToggleUserStatus, 
  onApproveProvider,
  onDeleteUser
}) => {
  if (!isOpen || !provider) return null;

  const [selectedDoc, setSelectedDoc] = useState(null);

  const categories = Array.isArray(provider.category)
    ? provider.category
    : typeof provider.category === 'string'
    ? provider.category.split(',').map(c => c.trim()).filter(Boolean)
    : [provider.category || 'General Maintenance'];

  const isVerified = provider.verified || provider.status === 'Active' || provider.status === 'Approved';

  const frontImg = getFormattedImageUrl(provider.nicFront || provider.nic_front_url || provider.nic_front);
  const backImg = getFormattedImageUrl(provider.nicBack || provider.nic_back_url || provider.nic_back);

  return createPortal(
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      
      {/* Modal Dialog Container */}
      <div className="relative w-full max-w-4xl max-h-[92vh] bg-white border border-slate-200 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Top Header Section */}
        <div className="relative bg-amber-50/60 border-b border-slate-200 p-6 sm:p-7 shrink-0 overflow-hidden">

          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-4 sm:top-5 right-4 sm:right-5 z-20 p-2 rounded-xl bg-white hover:bg-slate-100 text-slate-600 hover:text-slate-900 transition-all border border-slate-200 shadow-xs active:scale-95 cursor-pointer"
            title="Close"
          >
            <X className="w-5 h-5" />
          </button>

          {/* Provider Header Info Bar */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5 relative z-10 sm:pr-12">
            <div className="flex items-center gap-4 sm:gap-5">
              <div className="relative shrink-0">
                {provider.avatar ? (
                  <img
                    src={provider.avatar}
                    alt={provider.name}
                    className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl object-cover border-2 border-amber-400 shadow-md bg-slate-100 ring-2 ring-amber-500/20"
                  />
                ) : (
                  <div className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl bg-amber-100 text-amber-800 border-2 border-amber-400 flex items-center justify-center font-black text-2xl uppercase shadow-md ring-2 ring-amber-500/20">
                    {provider.initials || (provider.name || 'SP').slice(0, 2).toUpperCase()}
                  </div>
                )}
                {isVerified && (
                  <span className="absolute -bottom-1 -right-1 p-1 bg-emerald-500 text-white rounded-full ring-4 ring-white shadow-md" title="Verified Provider">
                    <BadgeCheck className="w-4 h-4" />
                  </span>
                )}
              </div>

              <div className="space-y-1">
                <div className="flex items-center gap-2.5 flex-wrap">
                  <h2 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">{provider.name}</h2>
                  <span className={`px-2.5 py-0.5 rounded-lg text-xs font-bold border ${
                    provider.status === 'Active' || provider.status === 'Approved'
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                      : provider.status === 'Blocked'
                      ? 'bg-rose-50 text-rose-700 border-rose-200'
                      : 'bg-amber-50 text-amber-700 border-amber-200'
                  }`}>
                    ● {provider.status || 'Active'} Provider
                  </span>
                </div>
                <p className="text-xs text-slate-500 font-medium flex items-center gap-2 flex-wrap">
                  <span>Registered Service Professional</span>
                  <span>•</span>
                  <span className="text-amber-600 font-bold flex items-center gap-1">
                    <Star className="w-3.5 h-3.5 fill-amber-500 text-amber-500" />
                    {Number(provider.rating) > 0 ? (
                      <span>{Number(provider.rating).toFixed(1)} ({provider.totalReviews || 1} {provider.totalReviews === 1 ? 'Review' : 'Reviews'} • {provider.jobsCompleted || 0} {provider.jobsCompleted === 1 ? 'Job' : 'Jobs'} Completed)</span>
                    ) : (
                      <span>New Provider ({provider.jobsCompleted || 0} Jobs Completed)</span>
                    )}
                  </span>
                </p>
              </div>
            </div>

            {/* Quick Action Controls */}
            <div className="flex items-center gap-3 w-full sm:w-auto">
              {onToggleUserStatus && (
                <button
                  onClick={() => onToggleUserStatus(provider.id)}
                  className={`flex-1 sm:flex-none px-4 py-2.5 rounded-xl font-bold text-xs flex items-center justify-center gap-2 border transition-all active:scale-95 shadow-xs cursor-pointer ${
                    provider.status === 'Active' || provider.status === 'Approved'
                      ? 'bg-rose-50 hover:bg-rose-100 text-rose-700 border-rose-200'
                      : 'bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border-emerald-200'
                  }`}
                >
                  {provider.status === 'Active' || provider.status === 'Approved' ? (
                    <>
                      <Lock className="w-4 h-4" />
                      <span>Suspend Account</span>
                    </>
                  ) : (
                    <>
                      <Unlock className="w-4 h-4" />
                      <span>Activate Account</span>
                    </>
                  )}
                </button>
              )}

              {onDeleteUser && (
                <button
                  onClick={() => {
                    onDeleteUser(provider.id);
                    onClose();
                  }}
                  className="px-3 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold text-xs transition-all active:scale-95 cursor-pointer"
                  title="Remove Provider Account"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Scrollable Body Content */}
        <div className="flex-1 overflow-y-auto p-6 sm:p-8 space-y-6">

          {/* Section 1: General Contact & Location Information */}
          <div>
            <div className="flex items-center gap-2 mb-3.5">
              <FileText className="w-4 h-4 text-amber-500" />
              <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                Personal & Contact Details
              </h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Phone className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Phone Number</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{provider.phone || 'N/A'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Mail className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Email Address</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{provider.email || 'N/A'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <MapPin className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Operating Region / District</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{provider.region || 'Polonnaruwa'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Award className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">NIC Number</p>
                  <p className="text-xs font-mono font-bold text-amber-700 mt-0.5 truncate">{provider.nic || '200207803325'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Calendar className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Joined Platform Date</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{provider.joinedDate || 'Recently'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-emerald-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-emerald-100 text-emerald-700 border border-emerald-200 shrink-0">
                  <CheckCircle2 className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Verification Status</p>
                  <p className="text-xs font-bold text-emerald-700 mt-0.5 flex items-center gap-1">
                    <span>●</span> {isVerified ? 'Approved & Verified' : 'Pending Verification'}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Section 2: Service Categories & Specializations */}
          <div>
            <div className="flex items-center gap-2 mb-3.5">
              <Grid className="w-4 h-4 text-amber-500" />
              <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                Services Provided & Specializations
              </h3>
            </div>

            <div className="p-5 bg-slate-50 rounded-2xl border border-slate-200">
              <div className="flex flex-wrap gap-2.5">
                {categories.map((cat, idx) => (
                  <span
                    key={idx}
                    className="px-3.5 py-1.5 rounded-xl bg-amber-100 border border-amber-300 text-amber-900 text-xs font-bold shadow-xs flex items-center gap-2"
                  >
                    <CheckCircle2 className="w-3.5 h-3.5 text-amber-600" />
                    <span>{cat}</span>
                  </span>
                ))}
              </div>
            </div>
          </div>

          {/* Section 3: Identity & Qualification Documents */}
          <div>
            <div className="flex items-center gap-2 mb-3.5">
              <ShieldAlert className="w-4 h-4 text-amber-500" />
              <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                Verification Documents
              </h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {/* NIC Front Image Card */}
              {frontImg ? (
                <div 
                  onClick={() => setSelectedDoc({ title: `${provider.name} - NIC Front Image`, url: frontImg, type: 'NIC Front' })}
                  className="relative h-48 rounded-2xl overflow-hidden border border-slate-200 bg-slate-50 p-2 cursor-pointer group hover:border-amber-400 transition-all shadow-xs flex items-center justify-center"
                >
                  <img 
                    src={frontImg} 
                    alt="NIC Front" 
                    className="max-h-full max-w-full object-contain rounded-xl group-hover:scale-105 transition-transform duration-300" 
                  />
                  <div className="absolute inset-0 bg-slate-900/30 group-hover:bg-slate-900/10 transition-colors flex items-center justify-center">
                    <span className="px-4 py-2.5 rounded-xl bg-slate-900/90 text-white text-xs font-bold flex items-center gap-2 shadow-md">
                      <Maximize2 className="w-4 h-4 text-amber-400" /> View NIC Front Image
                    </span>
                  </div>
                </div>
              ) : (
                <div className="h-48 rounded-2xl border border-dashed border-slate-300 bg-slate-50 flex flex-col items-center justify-center p-4 text-center">
                  <ShieldAlert className="w-8 h-8 text-amber-500/60 mb-2" />
                  <p className="text-xs font-bold text-slate-700">NIC Front Image Not Uploaded</p>
                  <p className="text-[11px] text-slate-400 mt-1">National ID card front image not uploaded.</p>
                </div>
              )}

              {/* NIC Back Image Card */}
              {backImg ? (
                <div 
                  onClick={() => setSelectedDoc({ title: `${provider.name} - NIC Back Image`, url: backImg, type: 'NIC Back' })}
                  className="relative h-48 rounded-2xl overflow-hidden border border-slate-200 bg-slate-50 p-2 cursor-pointer group hover:border-amber-400 transition-all shadow-xs flex items-center justify-center"
                >
                  <img 
                    src={backImg} 
                    alt="NIC Back" 
                    className="max-h-full max-w-full object-contain rounded-xl group-hover:scale-105 transition-transform duration-300" 
                  />
                  <div className="absolute inset-0 bg-slate-900/30 group-hover:bg-slate-900/10 transition-colors flex items-center justify-center">
                    <span className="px-4 py-2.5 rounded-xl bg-slate-900/90 text-white text-xs font-bold flex items-center gap-2 shadow-md">
                      <Maximize2 className="w-4 h-4 text-amber-400" /> View NIC Back Image
                    </span>
                  </div>
                </div>
              ) : (
                <div className="h-48 rounded-2xl border border-dashed border-slate-300 bg-slate-50 flex flex-col items-center justify-center p-4 text-center">
                  <ShieldAlert className="w-8 h-8 text-amber-500/60 mb-2" />
                  <p className="text-xs font-bold text-slate-700">NIC Back Image Not Uploaded</p>
                  <p className="text-[11px] text-slate-400 mt-1">National ID card back image not uploaded.</p>
                </div>
              )}
            </div>
          </div>

        </div>

      </div>

      {/* COMPACT CLEAN DOCUMENT LIGHTBOX MODAL */}
      {selectedDoc && (
        <div className="fixed inset-0 z-[100] bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in duration-200">
          <div className="bg-white border border-slate-200 rounded-3xl max-w-2xl w-full p-6 space-y-4 shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-slate-200 pb-3.5">
              <h4 className="font-bold text-slate-900 text-sm sm:text-base flex items-center gap-2">
                <FileText className="w-4.5 h-4.5 text-amber-500 shrink-0" />
                <span>{selectedDoc.title}</span>
              </h4>
              <button 
                onClick={() => setSelectedDoc(null)}
                className="p-1.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-600 transition-all border border-slate-200 cursor-pointer"
                title="Close"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Image Preview Box */}
            <div className="rounded-2xl overflow-hidden border border-slate-200 bg-slate-50 max-h-[60vh] flex items-center justify-center p-3">
              <img 
                src={selectedDoc.url} 
                alt="Document View" 
                className="max-h-[55vh] w-auto object-contain rounded-xl shadow-md" 
              />
            </div>

            {/* Footer */}
            <div className="flex items-center justify-between pt-1">
              <p className="text-[11px] text-slate-500 font-medium hidden sm:block">
                National Identity Card (NIC) Verification Image
              </p>
              <button 
                onClick={() => setSelectedDoc(null)}
                className="w-full sm:w-auto px-5 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs transition-all shadow-xs cursor-pointer"
              >
                Close Viewer
              </button>
            </div>
          </div>
        </div>
      )}

    </div>,
    document.body
  );
};

export default ProviderDetailsModal;
