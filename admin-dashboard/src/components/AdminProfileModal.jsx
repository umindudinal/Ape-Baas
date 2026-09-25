import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  X, 
  ShieldCheck, 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar, 
  Key, 
  CheckCircle2, 
  Lock, 
  Edit3, 
  Save, 
  LogOut,
  Sparkles,
  Server,
  Clock,
  ShieldAlert,
  Shield
} from 'lucide-react';
import { updateAdminProfileApi } from '../services/api';

const AdminProfileModal = ({ isOpen, onClose, currentUser, onUpdateUser, onLogout }) => {
  if (!isOpen) return null;

  const [isEditing, setIsEditing] = useState(false);
  const [fullName, setFullName] = useState(currentUser?.full_name || 'Umindu Dinal');
  const [email, setEmail] = useState(currentUser?.email || 'umindudinal@gmail.com');
  const [phone, setPhone] = useState(currentUser?.phone || '0779649818');
  const [avatar, setAvatar] = useState(
    currentUser?.avatar || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120"
  );
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);

  const handleSave = async (e) => {
    e.preventDefault();
    setIsSaving(true);
    setSaveSuccess(false);

    const updatedData = {
      ...currentUser,
      full_name: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatar: avatar.trim()
    };

    if (currentUser?.id) {
      await updateAdminProfileApi(currentUser.id, {
        full_name: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        avatar: avatar.trim()
      });
    }

    if (onUpdateUser) {
      onUpdateUser(updatedData);
    }

    setIsSaving(false);
    setSaveSuccess(true);
    setIsEditing(false);

    setTimeout(() => {
      setSaveSuccess(false);
    }, 3000);
  };

  const adminPermissions = [
    { title: 'User & Provider Moderation', desc: 'Add, approve, reject, block, or delete any customer or provider', active: true },
    { title: 'Identity Verification Review', desc: 'Inspect NIC and qualification certificates to grant verified badge', active: true },
    { title: 'Service Categories Control', desc: 'Create, edit, toggle visibility, and delete service categories', active: true },
    { title: 'Revenue & Job Analytics', desc: 'Full access to growth metrics, job statistics, and platform commissions', active: true },
    { title: 'Push Broadcast Notifications', desc: 'Send push notification broadcasts to mobile app users', active: true },
    { title: 'Database & System Security', desc: 'Level 3 Highest Security clearance with Supabase backend access', active: true }
  ];

  return createPortal(
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      
      {/* Modal Dialog Container */}
      <div className="relative w-full max-w-4xl max-h-[92vh] bg-white border border-slate-200 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Top Header Section (Header Title + Avatar Info + Action Buttons) */}
        <div className="relative bg-amber-50/60 border-b border-slate-200 p-6 sm:p-7 shrink-0 overflow-hidden">

          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-4 sm:top-5 right-4 sm:right-5 z-20 p-2 rounded-xl bg-white hover:bg-slate-100 text-slate-600 hover:text-slate-900 transition-all border border-slate-200 shadow-xs active:scale-95 cursor-pointer"
            title="Close Profile"
          >
            <X className="w-5 h-5" />
          </button>

          {/* Profile Header Row (Avatar + Name & Badges + Edit/SignOut Buttons) */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-5 relative z-10 sm:pr-12">
            
            {/* Left: Avatar Image & Admin Info */}
            <div className="flex items-center gap-4 sm:gap-5">
              <div className="relative shrink-0">
                <img
                  src={avatar}
                  alt="Admin Profile"
                  className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl object-cover border-2 border-amber-400 shadow-md bg-slate-100 ring-2 ring-amber-500/20"
                />
                <span className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full ring-4 ring-white shadow-md" title="System Online"></span>
              </div>

              <div className="space-y-1">
                <div className="flex items-center gap-2.5 flex-wrap">
                  <h2 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">{fullName}</h2>
                  <span className="px-2.5 py-0.5 rounded-lg text-xs font-extrabold bg-amber-500 text-slate-950 shadow-xs flex items-center gap-1">
                    <Sparkles className="w-3.5 h-3.5 text-slate-950" />
                    Super Admin PRO
                  </span>
                  <span className="px-2.5 py-0.5 rounded-lg text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    Active Session
                  </span>
                </div>
                <p className="text-xs text-slate-500 font-medium">
                  Ape Baas Administrator Operations & Account Profile
                </p>
              </div>
            </div>

            {/* Right: Action Buttons */}
            <div className="flex items-center gap-3 w-full sm:w-auto">
              {!isEditing ? (
                <button
                  type="button"
                  onClick={() => setIsEditing(true)}
                  className="flex-1 sm:flex-none px-4 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs flex items-center justify-center gap-2 shadow-xs transition-all active:scale-95 cursor-pointer"
                >
                  <Edit3 className="w-4 h-4" />
                  <span>Edit Profile</span>
                </button>
              ) : (
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="flex-1 sm:flex-none px-4 py-2.5 rounded-xl bg-white hover:bg-slate-100 text-slate-700 font-bold text-xs border border-slate-300 transition-all active:scale-95 cursor-pointer shadow-xs"
                >
                  Cancel
                </button>
              )}

              {onLogout && (
                <button
                  type="button"
                  onClick={onLogout}
                  className="flex-1 sm:flex-none px-4 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 font-bold text-xs border border-rose-200 flex items-center justify-center gap-2 transition-all active:scale-95 cursor-pointer"
                >
                  <LogOut className="w-4 h-4" />
                  <span>Sign Out</span>
                </button>
              )}
            </div>

          </div>

        </div>

        {/* Scrollable Body Content */}
        <div className="flex-1 overflow-y-auto p-6 sm:p-8 space-y-6">

          {saveSuccess && (
            <div className="p-3.5 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold flex items-center gap-2.5 animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-600" />
              <span>Admin profile details updated successfully!</span>
            </div>
          )}

          {/* Profile Edit Mode / Overview Mode */}
          {isEditing ? (
            <form onSubmit={handleSave} className="space-y-4">
              <div className="border-b border-slate-200 pb-3">
                <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-2">
                  <Edit3 className="w-4 h-4 text-amber-500" />
                  Edit Admin Details
                </h3>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Full Name</label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      required
                      className="w-full pl-9 pr-3.5 py-2.5 bg-slate-50 text-xs text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Email Address</label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      className="w-full pl-9 pr-3.5 py-2.5 bg-slate-50 text-xs text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Phone Number</label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      className="w-full pl-9 pr-3.5 py-2.5 bg-slate-50 text-xs text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-700">Avatar Image URL</label>
                  <input
                    type="text"
                    value={avatar}
                    onChange={(e) => setAvatar(e.target.value)}
                    placeholder="https://..."
                    className="w-full px-3.5 py-2.5 bg-slate-50 text-xs text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              <div className="pt-3 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="px-4 py-2.5 rounded-xl bg-slate-100 text-slate-700 text-xs font-semibold hover:bg-slate-200 transition-all cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isSaving}
                  className="px-5 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 text-xs font-bold flex items-center gap-2 shadow-xs transition-all cursor-pointer"
                >
                  {isSaving ? (
                    <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                  ) : (
                    <>
                      <Save className="w-4 h-4" />
                      <span>Save Profile Changes</span>
                    </>
                  )}
                </button>
              </div>
            </form>
          ) : (
            <div className="space-y-6">
              
              {/* Section 1: General & Contact Information */}
              <div>
                <div className="flex items-center gap-2 mb-3.5">
                  <User className="w-4 h-4 text-amber-500" />
                  <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                    General & Contact Information
                  </h3>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors">
                    <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                      <User className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">Full Name</p>
                      <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{fullName}</p>
                    </div>
                  </div>

                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                    <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                      <Mail className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">Email Address</p>
                      <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{email}</p>
                    </div>
                  </div>

                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                    <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                      <Phone className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">Phone Number</p>
                      <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">{phone}</p>
                    </div>
                  </div>

                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                    <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                      <MapPin className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">Region / Location</p>
                      <p className="text-xs font-bold text-slate-900 mt-0.5 truncate">Colombo, Sri Lanka (HQ)</p>
                    </div>
                  </div>

                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-amber-300 transition-colors min-w-0">
                    <div className="p-2.5 rounded-xl bg-amber-100 text-amber-700 border border-amber-200 shrink-0">
                      <Key className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">Admin User ID</p>
                      <p className="text-xs font-mono font-bold text-amber-700 mt-0.5 truncate">
                        {currentUser?.id || 'b59a99df-a048-4ebd-a4fe-70372989f0fb'}
                      </p>
                    </div>
                  </div>

                  <div className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3.5 hover:border-emerald-300 transition-colors min-w-0">
                    <div className="p-2.5 rounded-xl bg-emerald-100 text-emerald-700 border border-emerald-200 shrink-0">
                      <Shield className="w-4.5 h-4.5" />
                    </div>
                    <div className="min-w-0">
                      <p className="text-[11px] text-slate-500 font-medium">System Status & Access</p>
                      <p className="text-xs font-bold text-emerald-700 mt-0.5 flex items-center gap-1.5">
                        <CheckCircle2 className="w-3.5 h-3.5 shrink-0" />
                        <span>Super Admin Access</span>
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Section 2: System Permissions & Access Privileges */}
              <div>
                <div className="flex items-center gap-2 mb-3.5">
                  <ShieldAlert className="w-4 h-4 text-emerald-600" />
                  <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                    System Permissions & Access Privileges
                  </h3>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                  {adminPermissions.map((perm, idx) => (
                    <div key={idx} className="p-4 bg-slate-50 rounded-2xl border border-slate-200 flex items-start gap-3 hover:border-slate-300 transition-colors">
                      <CheckCircle2 className="w-4.5 h-4.5 text-emerald-600 shrink-0 mt-0.5" />
                      <div>
                        <p className="text-xs font-bold text-slate-900">{perm.title}</p>
                        <p className="text-[11px] text-slate-500 mt-0.5 leading-snug">{perm.desc}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Section 3: Database & Security Status Panel */}
              <div className="p-4 sm:p-5 rounded-2xl bg-slate-50 border border-slate-200 flex items-center justify-between flex-wrap gap-3 text-xs">
                <div className="flex items-center gap-3.5">
                  <Server className="w-5 h-5 text-amber-600 shrink-0" />
                  <div>
                    <p className="font-bold text-slate-900">Supabase Cloud Database Connected</p>
                    <p className="text-[11px] text-slate-500">Encrypted JWT Session • Real-time synchronization active</p>
                  </div>
                </div>
                <div className="flex items-center gap-1.5 text-slate-600 font-bold bg-white px-3.5 py-2 rounded-xl border border-slate-200 shadow-xs">
                  <Clock className="w-3.5 h-3.5 text-emerald-600" />
                  <span>Last login: Today</span>
                </div>
              </div>

            </div>
          )}

        </div>

      </div>
    </div>,
    document.body
  );
};

export default AdminProfileModal;
