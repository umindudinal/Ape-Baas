import React from 'react';
import { createPortal } from 'react-dom';
import { 
  X, 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar, 
  CheckCircle2, 
  Lock, 
  Unlock, 
  Trash2, 
  ShoppingBag, 
  Shield, 
  Key, 
  Sparkles,
  Clock
} from 'lucide-react';

const CustomerDetailsModal = ({ 
  isOpen, 
  onClose, 
  customer, 
  onToggleUserStatus, 
  onDeleteUser 
}) => {
  if (!isOpen || !customer) return null;

  const isActive = customer.status === 'Active';

  return createPortal(
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      
      {/* Modal Dialog Box */}
      <div className="relative w-full max-w-4xl max-h-[92vh] bg-white border border-slate-200 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Cover Header Banner */}
        <div className="relative bg-amber-50/60 border-b border-slate-200 p-6 sm:p-7 shrink-0 overflow-hidden">

          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-4 sm:top-5 right-4 sm:right-5 z-20 p-2 rounded-xl bg-white hover:bg-slate-100 text-slate-600 hover:text-slate-900 transition-all border border-slate-200 shadow-xs active:scale-95 cursor-pointer"
            title="Close Profile"
          >
            <X className="w-5 h-5" />
          </button>

          {/* Profile Header Bar */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5 relative z-10 sm:pr-12">
            <div className="flex items-center gap-4 sm:gap-5">
              <div className="relative shrink-0">
                {customer.avatar ? (
                  <img
                    src={customer.avatar}
                    alt={customer.name}
                    className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl object-cover border-2 border-amber-400 shadow-md bg-slate-100 ring-2 ring-amber-500/20"
                  />
                ) : (
                  <div className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl bg-amber-100 text-amber-800 border-2 border-amber-400 flex items-center justify-center font-black text-2xl uppercase shadow-md ring-2 ring-amber-500/20">
                    {customer.initials || (customer.name || 'CU').slice(0, 2).toUpperCase()}
                  </div>
                )}
                <span className={`absolute -bottom-1 -right-1 w-4 h-4 rounded-full ring-4 ring-white ${
                  isActive ? 'bg-emerald-500' : 'bg-rose-500'
                }`} title={isActive ? 'Active Customer' : 'Suspended Customer'}></span>
              </div>

              <div className="space-y-1">
                <div className="flex items-center gap-2.5 flex-wrap">
                  <h2 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">{customer.name}</h2>
                  <span className={`px-2.5 py-0.5 rounded-lg text-xs font-bold border ${
                    isActive
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                      : 'bg-rose-50 text-rose-700 border-rose-200'
                  }`}>
                    ● {isActive ? 'Active Account' : 'Suspended'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 font-medium">
                  Ape Baas Registered Customer Account Profile
                </p>
              </div>
            </div>

            {/* Quick Actions */}
            <div className="flex items-center gap-3 w-full sm:w-auto">
              {onToggleUserStatus && (
                <button
                  type="button"
                  onClick={() => onToggleUserStatus(customer.id)}
                  className={`flex-1 sm:flex-none px-4 py-2.5 rounded-xl font-bold text-xs flex items-center justify-center gap-2 border transition-all active:scale-95 shadow-xs cursor-pointer ${
                    isActive
                      ? 'bg-rose-50 hover:bg-rose-100 text-rose-700 border-rose-200'
                      : 'bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border-emerald-200'
                  }`}
                >
                  {isActive ? (
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
                  type="button"
                  onClick={() => {
                    onDeleteUser(customer.id);
                    onClose();
                  }}
                  className="px-3.5 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold text-xs transition-all active:scale-95 cursor-pointer"
                  title="Remove Customer Account"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Scrollable Body Content */}
        <div className="flex-1 overflow-y-auto p-6 sm:p-8 space-y-6">

          {/* Section 1: General & Contact Information */}
          <div>
            <div className="flex items-center gap-2 mb-3.5">
              <User className="w-4 h-4 text-amber-500" />
              <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                General & Contact Details
              </h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <User className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Full Name</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{customer.name}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Mail className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Email Address</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{customer.email || 'N/A'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Phone className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Phone Number</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{customer.phone || 'N/A'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <MapPin className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">District / Location</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{customer.region || 'Hambantota (Tangalle)'}</p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Key className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Customer User ID</p>
                  <p className="text-xs font-mono font-bold text-amber-700 mt-0.5 truncate">
                    {customer.id || 'cust-user-001'}
                  </p>
                </div>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                  <Calendar className="w-4.5 h-4.5" />
                </div>
                <div className="min-w-0">
                  <p className="text-[11px] text-slate-500 font-medium">Account Created Date</p>
                  <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{customer.joinedDate || 'Jul 29, 2026'}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Section 2: Platform Activity & Booking Statistics */}
          <div>
            <div className="flex items-center gap-2 mb-3.5">
              <ShoppingBag className="w-4 h-4 text-emerald-600" />
              <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                Booking Activity & Service Usage
              </h3>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5">
              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-1">
                <p className="text-[11px] text-slate-500 font-medium">Total Requested Bookings</p>
                <p className="text-xl font-black text-amber-600">
                  {customer.totalBookings || 0} {Number(customer.totalBookings) === 1 ? 'Booking' : 'Bookings'}
                </p>
                <p className="text-[10px] text-slate-400">
                  {Number(customer.totalBookings) > 0
                    ? `${customer.completedBookings || 0} Completed • ${customer.pendingBookings || 0} Pending`
                    : 'Service requests placed via mobile app'}
                </p>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-1">
                <p className="text-[11px] text-slate-500 font-medium">Account Status</p>
                <p className={`text-xl font-black ${isActive ? 'text-emerald-600' : 'text-rose-600'}`}>
                  {isActive ? 'Active' : 'Suspended'}
                </p>
                <p className="text-[10px] text-slate-400">Customer platform access status</p>
              </div>

              <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 space-y-1">
                <p className="text-[11px] text-slate-500 font-medium">Customer Role</p>
                <p className="text-xl font-black text-slate-900">Platform Customer</p>
                <p className="text-[10px] text-slate-400">Mobile Home Service Requester</p>
              </div>
            </div>
          </div>

          {/* Section 3: System Security & Access Panel */}
          <div className="p-4 sm:p-5 rounded-2xl bg-slate-50 border border-slate-200 flex items-center justify-between flex-wrap gap-3 text-xs">
            <div className="flex items-center gap-3.5">
              <Shield className="w-5 h-5 text-amber-600 shrink-0" />
              <div>
                <p className="font-bold text-slate-900">Mobile App User Account Active</p>
                <p className="text-[11px] text-slate-500">Authenticated via Supabase Profiles Database</p>
              </div>
            </div>
            <div className="flex items-center gap-1.5 text-slate-600 font-bold bg-white px-3.5 py-2 rounded-xl border border-slate-200 shadow-xs">
              <Clock className="w-3.5 h-3.5 text-emerald-600" />
              <span>Last login: Recent</span>
            </div>
          </div>

        </div>

      </div>
    </div>,
    document.body
  );
};

export default CustomerDetailsModal;
