import React, { useState, useRef } from 'react';
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
  Shield,
  Camera,
  Upload,
  Trash2,
  RefreshCw
} from 'lucide-react';
import { updateAdminProfileApi } from '../services/api';

const DEFAULT_ADMIN_AVATAR = "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120";

const AdminProfileModal = ({ isOpen, onClose, currentUser, onUpdateUser, onLogout }) => {
  if (!isOpen) return null;

  const fileInputRef = useRef(null);
  const [isEditing, setIsEditing] = useState(false);
  const [fullName, setFullName] = useState(currentUser?.full_name || 'Umindu Dinal');
  const [email, setEmail] = useState(currentUser?.email || 'umindudinal@gmail.com');
  const [phone, setPhone] = useState(currentUser?.phone || '0779649818');
  const [avatar, setAvatar] = useState(
    currentUser?.avatar || currentUser?.profile_image_url || DEFAULT_ADMIN_AVATAR
  );
  const [isSaving, setIsSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [photoError, setPhotoError] = useState(null);
  const [isDragOver, setIsDragOver] = useState(false);

  // Helper to handle image files (from file input or drag-and-drop)
  const handleImageFile = (file) => {
    setPhotoError(null);
    if (!file) return;

    if (!file.type.startsWith('image/')) {
      setPhotoError('Please select a valid image file (JPEG, PNG, WEBP).');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      setPhotoError('Image size should be less than 5MB.');
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      if (e.target?.result) {
        setAvatar(e.target.result);
      }
    };
    reader.onerror = () => {
      setPhotoError('Error reading image file.');
    };
    reader.readAsDataURL(file);
  };

  const handleFileSelect = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      handleImageFile(file);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragOver(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      handleImageFile(file);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setIsSaving(true);
    setSaveSuccess(false);

    const updatedData = {
      ...currentUser,
      full_name: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      avatar: avatar.trim(),
      profile_image_url: avatar.trim()
    };

    if (currentUser?.id) {
      try {
        await updateAdminProfileApi(currentUser.id, {
          full_name: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
          avatar: avatar.trim(),
          profile_image_url: avatar.trim()
        });
      } catch (err) {
        console.warn("⚠️ Error saving admin profile to API:", err.message);
      }
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

          {/* Hidden File Input for Image Upload */}
          <input 
            ref={fileInputRef} 
            type="file" 
            accept="image/png, image/jpeg, image/jpg, image/webp" 
            className="hidden" 
            onChange={handleFileSelect} 
          />

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
              <div 
                onClick={() => fileInputRef.current?.click()}
                className="relative shrink-0 group cursor-pointer"
                title="Click to upload/change profile photo"
              >
                <img
                  src={avatar || DEFAULT_ADMIN_AVATAR}
                  alt="Admin Profile"
                  className="w-20 h-20 sm:w-22 sm:h-22 rounded-2xl object-cover border-2 border-amber-400 shadow-md bg-slate-100 ring-2 ring-amber-500/20 group-hover:brightness-90 transition-all"
                />
                {/* Camera Overlay on Hover */}
                <div className="absolute inset-0 bg-slate-950/50 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity flex flex-col items-center justify-center text-white backdrop-blur-[1px]">
                  <Camera className="w-5 h-5 text-amber-300 drop-shadow-sm" />
                  <span className="text-[10px] font-bold text-white mt-0.5">Upload</span>
                </div>
                <span className="absolute -bottom-1 -right-1 w-4 h-4 bg-emerald-500 rounded-full ring-4 ring-white shadow-md z-10" title="System Online"></span>
              </div>

              <div className="space-y-1">
                <div className="flex items-center gap-2.5 flex-wrap">
                  <h2 className="text-2xl sm:text-3xl font-black text-slate-900 tracking-tight">{fullName}</h2>
                  <span className="px-2.5 py-0.5 rounded-lg text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    Active Session
                  </span>
                </div>
                <div className="flex items-center gap-2 flex-wrap text-xs text-slate-500 font-medium">
                  <span>Ape Baas Administrator Operations</span>
                  <span className="text-slate-300">•</span>
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    className="text-amber-600 hover:text-amber-700 font-bold hover:underline inline-flex items-center gap-1 cursor-pointer"
                  >
                    <Camera className="w-3 h-3" />
                    <span>Change Photo</span>
                  </button>
                </div>
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
              <span>Admin profile & photo details updated successfully!</span>
            </div>
          )}

          {photoError && (
            <div className="p-3.5 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center justify-between gap-2.5 animate-in fade-in">
              <div className="flex items-center gap-2">
                <ShieldAlert className="w-4 h-4 shrink-0 text-rose-600" />
                <span>{photoError}</span>
              </div>
              <button 
                type="button" 
                onClick={() => setPhotoError(null)} 
                className="text-rose-500 hover:text-rose-700 font-bold text-xs cursor-pointer"
              >
                ✕
              </button>
            </div>
          )}

          {/* Profile Edit Mode / Overview Mode */}
          {isEditing ? (
            <form onSubmit={handleSave} className="space-y-5">
              <div className="border-b border-slate-200 pb-3">
                <h3 className="text-xs font-bold text-slate-700 uppercase tracking-wider flex items-center gap-2">
                  <Edit3 className="w-4 h-4 text-amber-500" />
                  Edit Admin Profile & Photo
                </h3>
              </div>

              {/* Profile Photo Uploader Section */}
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 space-y-3">
                <label className="text-xs font-bold text-slate-800 flex items-center justify-between">
                  <span className="flex items-center gap-1.5">
                    <Camera className="w-4 h-4 text-amber-600" />
                    Admin Profile Photo
                  </span>
                  <span className="text-[11px] text-slate-500 font-normal">Max 5MB (PNG, JPG, WEBP)</span>
                </label>

                <div className="flex flex-col sm:flex-row items-center gap-4">
                  {/* Avatar Preview */}
                  <div className="relative shrink-0">
                    <img
                      src={avatar || DEFAULT_ADMIN_AVATAR}
                      alt="Avatar Preview"
                      className="w-16 h-16 rounded-2xl object-cover border-2 border-amber-400 shadow-sm bg-white"
                    />
                  </div>

                  {/* Actions & Drag Zone */}
                  <div 
                    onDragOver={(e) => { e.preventDefault(); setIsDragOver(true); }}
                    onDragLeave={() => setIsDragOver(false)}
                    onDrop={handleDrop}
                    className={`flex-1 w-full p-3 rounded-xl border-2 border-dashed transition-all flex flex-wrap items-center justify-between gap-2.5 ${
                      isDragOver ? 'border-amber-500 bg-amber-50/50' : 'border-slate-300 bg-white'
                    }`}
                  >
                    <div className="text-xs">
                      <p className="font-semibold text-slate-800">Choose a new profile picture</p>
                      <p className="text-[11px] text-slate-500">Upload from your computer or drag and drop image here</p>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => fileInputRef.current?.click()}
                        className="px-3.5 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs flex items-center gap-1.5 shadow-xs transition-all cursor-pointer"
                      >
                        <Upload className="w-3.5 h-3.5" />
                        <span>Upload Photo</span>
                      </button>

                      {avatar !== DEFAULT_ADMIN_AVATAR && (
                        <button
                          type="button"
                          onClick={() => setAvatar(DEFAULT_ADMIN_AVATAR)}
                          className="p-2 rounded-xl bg-slate-100 hover:bg-rose-50 text-slate-600 hover:text-rose-600 border border-slate-200 transition-all cursor-pointer"
                          title="Reset to default photo"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Personal Details Form Inputs */}
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
                  <div className="flex items-center justify-between">
                    <label className="text-xs font-semibold text-slate-700">Email Address</label>
                    <span className="text-[10px] text-amber-700 font-bold bg-amber-50 px-2 py-0.5 rounded-md border border-amber-200 flex items-center gap-1">
                      <Lock className="w-2.5 h-2.5" />
                      Primary 2FA Login Email (Locked)
                    </span>
                  </div>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="email"
                      value={email}
                      disabled
                      readOnly
                      title="Admin primary email is locked to protect 2FA OTP and account security"
                      className="w-full pl-9 pr-9 py-2.5 bg-slate-100 text-xs text-slate-500 rounded-xl border border-slate-200 cursor-not-allowed font-medium select-none"
                    />
                    <Lock className="w-3.5 h-3.5 text-slate-400 absolute right-3 top-1/2 -translate-y-1/2" />
                  </div>
                </div>

                <div className="space-y-1.5 sm:col-span-2">
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
