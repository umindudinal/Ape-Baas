import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  X, 
  UserPlus, 
  User, 
  Mail, 
  Phone, 
  Lock, 
  Eye, 
  EyeOff, 
  Wrench, 
  MapPin, 
  ShieldCheck, 
  CheckCircle2, 
  AlertCircle, 
  Sparkles, 
  Clock, 
  Compass, 
  CreditCard,
  Building,
  RefreshCw
} from 'lucide-react';
import { createProviderApi } from '../services/api';

const SRI_LANKA_DISTRICTS = [
  'Colombo', 'Gampaha', 'Kalutara', 
  'Kandy', 'Matale', 'Nuwara Eliya', 
  'Galle', 'Matara', 'Hambantota', 
  'Jaffna', 'Kilinochchi', 'Mannar', 'Vavuniya', 'Mullaitivu', 
  'Batticaloa', 'Ampara', 'Trincomalee', 
  'Kurunegala', 'Puttalam', 
  'Anuradhapura', 'Polonnaruwa', 
  'Badulla', 'Monaragala', 
  'Ratnapura', 'Kegalle'
];

const DEFAULT_CATEGORIES = [
  'Electrician Services',
  'Plumbing & Water Lines',
  'Carpentry & Woodwork',
  'AC Repair & Service',
  'Masonry & Construction',
  'House Painting',
  'Tile Laying & Flooring',
  'Gardening & Landscaping',
  'House Deep Cleaning',
  'Solar Panel Installation',
  'Appliance Repair',
  'Roofing & Ceiling'
];

export default function AddProviderModal({ 
  isOpen, 
  onClose, 
  categories = [], 
  onProviderCreated 
}) {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [category, setCategory] = useState('');
  const [customCategory, setCustomCategory] = useState('');
  const [experienceYears, setExperienceYears] = useState('3');
  const [workingRadius, setWorkingRadius] = useState('25');
  const [district, setDistrict] = useState('Colombo');
  const [city, setCity] = useState('');
  const [address, setAddress] = useState('');
  const [nicNumber, setNicNumber] = useState('');
  const [isAutoApprove, setIsAutoApprove] = useState(true);

  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState(null);
  const [successMsg, setSuccessMsg] = useState(null);

  if (!isOpen) return null;

  // Category options list from props or defaults
  const categoryOptions = categories.length > 0 
    ? categories.map(c => c.nameEn || c.name_en || c.nameSi || c)
    : DEFAULT_CATEGORIES;

  // Helper to generate a secure random strong password
  const generateStrongPassword = () => {
    const chars = "abcdefghjkmnpqrstuvwxyz";
    const uppers = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    const numbers = "23456789";
    const symbols = "!@#$%^&*";
    
    let pass = "Baas@";
    for (let i = 0; i < 3; i++) pass += uppers.charAt(Math.floor(Math.random() * uppers.length));
    for (let i = 0; i < 2; i++) pass += numbers.charAt(Math.floor(Math.random() * numbers.length));
    for (let i = 0; i < 1; i++) pass += symbols.charAt(Math.floor(Math.random() * symbols.length));
    
    setPassword(pass);
    setShowPassword(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrorMsg(null);
    setSuccessMsg(null);

    // Form Validations
    if (!fullName.trim()) {
      setErrorMsg('කරුණාකර සේවා සපයන්නාගේ නම ඇතුළත් කරන්න (Full name is required).');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      setErrorMsg('වලංගු ඊමේල් ලිපිනයක් ඇතුළත් කරන්න (Valid email is required).');
      return;
    }
    if (!phone.trim()) {
      setErrorMsg('දුරකථන අංකය ඇතුළත් කරන්න (Phone number is required).');
      return;
    }
    if (!password.trim() || password.length < 8) {
      setErrorMsg('මුරපදය අවම වශයෙන් අක්ෂර 8ක් විය යුතුය (Password must be at least 8 characters).');
      return;
    }
    
    const selectedCategory = category === 'Other' ? customCategory.trim() : (category || categoryOptions[0]);
    if (!selectedCategory) {
      setErrorMsg('සේවා කාණ්ඩය (Category) තෝරන්න.');
      return;
    }

    setLoading(true);

    try {
      const payload = {
        full_name: fullName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        password: password.trim(),
        service_category: selectedCategory,
        experience_years: parseInt(experienceYears) || 1,
        working_radius_km: parseInt(workingRadius) || 20,
        district: district || 'Colombo',
        city: city.trim() || district || 'Colombo',
        address: address.trim(),
        nic_number: nicNumber.trim(),
        is_verified: isAutoApprove
      };

      const res = await createProviderApi(payload);

      if (res && res.success) {
        setSuccessMsg(res.message || '🎉 සේවා සපයන්නා සාර්ථකව පද්ධතියට එක් කරන ලදී!');
        
        if (onProviderCreated) {
          onProviderCreated(res.data);
        }

        // Reset fields after short delay
        setTimeout(() => {
          setFullName('');
          setEmail('');
          setPhone('');
          setPassword('');
          setCity('');
          setAddress('');
          setNicNumber('');
          setSuccessMsg(null);
          onClose();
        }, 1500);

      } else {
        setErrorMsg(res?.error || 'සේවා සපයන්නා එක් කිරීමට නොහැකි විය. නැවත උත්සාහ කරන්න.');
      }
    } catch (err) {
      setErrorMsg(err.message || 'Server error creating provider.');
    } finally {
      setLoading(false);
    }
  };

  return createPortal(
    <div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="relative w-full max-w-2xl max-h-[92vh] bg-white border border-slate-200 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
        
        {/* Modal Header */}
        <div className="px-6 py-5 bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border-b border-slate-700 text-white flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-500/20 border border-amber-500/40 flex items-center justify-center text-amber-400">
              <UserPlus className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-base font-bold text-white flex items-center gap-2">
                <span>Add New Service Provider</span>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-amber-400/20 text-amber-300 border border-amber-400/30">
                  Admin Direct
                </span>
              </h3>
              <p className="text-xs text-slate-300 mt-0.5">
                නව සේවා සපයන්නෙකු Dashboard එක හරහා පද්ධතියට ලියාපදිංචි කිරීම
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Scrollable Form Body */}
        <div className="p-6 overflow-y-auto space-y-6 flex-1 text-slate-800 text-xs">
          
          {errorMsg && (
            <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs flex items-center gap-2.5 font-medium animate-in fade-in">
              <AlertCircle className="w-4 h-4 shrink-0 text-rose-600" />
              <span>{errorMsg}</span>
            </div>
          )}

          {successMsg && (
            <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs flex items-center gap-2.5 font-bold animate-in fade-in">
              <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-600" />
              <span>{successMsg}</span>
            </div>
          )}

          <form id="add-provider-form" onSubmit={handleSubmit} className="space-y-5">
            
            {/* 1. Personal & Contact Information */}
            <div className="space-y-3">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <User className="w-3.5 h-3.5 text-amber-500" />
                <span>1. Personal & Login Details (මූලික විස්තර)</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Full Name (සම්පූර්ණ නම) <span className="text-rose-500">*</span>
                  </label>
                  <div className="relative">
                    <User className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      required
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="e.g. Sunil Perera / සුනිල් පෙරේරා"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Email Address (ඊමේල් ලිපිනය) <span className="text-rose-500">*</span>
                  </label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="e.g. provider@gmail.com"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Phone Number (දුරකථන අංකය) <span className="text-rose-500">*</span>
                  </label>
                  <div className="relative">
                    <Phone className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="tel"
                      required
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="e.g. 0771234567 or +94771234567"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="text-xs font-bold text-slate-700">
                      Password (මුරපදය) <span className="text-rose-500">*</span>
                    </label>
                    <button
                      type="button"
                      onClick={generateStrongPassword}
                      className="text-[11px] font-bold text-amber-600 hover:text-amber-700 flex items-center gap-1 cursor-pointer"
                    >
                      <Sparkles className="w-3 h-3" />
                      <span>Auto Generate</span>
                    </button>
                  </div>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type={showPassword ? "text" : "password"}
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Minimum 8 characters"
                      className="w-full pl-9 pr-9 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                    >
                      {showPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            {/* 2. Professional & Skill Details */}
            <div className="space-y-3 pt-2">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <Wrench className="w-3.5 h-3.5 text-amber-500" />
                <span>2. Service Category & Experience (සේවා වර්ගය සහ පළපුරුද්ද)</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Service Category (සේවා කාණ්ඩය) <span className="text-rose-500">*</span>
                  </label>
                  <select
                    value={category || categoryOptions[0]}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-semibold text-slate-900 cursor-pointer"
                  >
                    {categoryOptions.map((cat, idx) => (
                      <option key={idx} value={cat}>{cat}</option>
                    ))}
                    <option value="Other">+ Other / අලුත් සේවාවක් ලියන්න</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Experience (පළපුරුද්ද)
                  </label>
                  <div className="relative">
                    <Clock className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <select
                      value={experienceYears}
                      onChange={(e) => setExperienceYears(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900 cursor-pointer"
                    >
                      <option value="1">1 Year</option>
                      <option value="2">2 Years</option>
                      <option value="3">3 Years</option>
                      <option value="5">5+ Years</option>
                      <option value="10">10+ Years</option>
                      <option value="15">15+ Years</option>
                    </select>
                  </div>
                </div>
              </div>

              {category === 'Other' && (
                <div className="animate-in fade-in">
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Custom Category Name (නව සේවා කාණ්ඩයේ නම) <span className="text-rose-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={customCategory}
                    onChange={(e) => setCustomCategory(e.target.value)}
                    placeholder="e.g. CCTV & Security System Technician"
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                  />
                </div>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    NIC Number (ජාතික හැඳුනුම්පත් අංකය)
                  </label>
                  <div className="relative">
                    <CreditCard className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={nicNumber}
                      onChange={(e) => setNicNumber(e.target.value)}
                      placeholder="e.g. 199512345678 or 951234567V"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Working Radius (සේවා සපයන දුර)
                  </label>
                  <div className="relative">
                    <Compass className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <select
                      value={workingRadius}
                      onChange={(e) => setWorkingRadius(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900 cursor-pointer"
                    >
                      <option value="10">10 KM</option>
                      <option value="20">20 KM</option>
                      <option value="25">25 KM (Standard)</option>
                      <option value="35">35 KM</option>
                      <option value="50">50 KM (Wide Area)</option>
                      <option value="100">100 KM (Islandwide)</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            {/* 3. Location & Coverage */}
            <div className="space-y-3 pt-2">
              <div className="flex items-center gap-2 text-slate-900 font-bold text-xs uppercase tracking-wider pb-1 border-b border-slate-100">
                <MapPin className="w-3.5 h-3.5 text-amber-500" />
                <span>3. Location & Area (ප්‍රදේශය සහ ලිපිනය)</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    District (දිස්ත්‍රික්කය) <span className="text-rose-500">*</span>
                  </label>
                  <select
                    value={district}
                    onChange={(e) => setDistrict(e.target.value)}
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-semibold text-slate-900 cursor-pointer"
                  >
                    {SRI_LANKA_DISTRICTS.map((dist, idx) => (
                      <option key={idx} value={dist}>{dist}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    City / Town (නගරය)
                  </label>
                  <div className="relative">
                    <Building className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                    <input
                      type="text"
                      value={city}
                      onChange={(e) => setCity(e.target.value)}
                      placeholder="e.g. Maharagama, Nugegoda, Panadura"
                      className="w-full pl-9 pr-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                    />
                  </div>
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-slate-700 mb-1">
                    Street Address (ස්ථිර ලිපිනය)
                  </label>
                  <input
                    type="text"
                    value={address}
                    onChange={(e) => setAddress(e.target.value)}
                    placeholder="e.g. No. 45/2, Temple Road, Maharagama"
                    className="w-full px-3 py-2 text-xs bg-slate-50 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium text-slate-900"
                  />
                </div>
              </div>
            </div>

            {/* 4. Verification & Status Toggle */}
            <div className="p-4 rounded-2xl bg-amber-500/10 border border-amber-500/30 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center font-bold">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div>
                  <p className="text-xs font-bold text-slate-900">
                    Auto-Approve & Activate Profile
                  </p>
                  <p className="text-[11px] text-slate-600">
                    මෙය On කර තිබූ විට Provider ගිණුම සෑදූ විගස Verified Provider කෙනෙකු ලෙස Mobile App එකේ දිස්වේ.
                  </p>
                </div>
              </div>

              <input
                type="checkbox"
                checked={isAutoApprove}
                onChange={(e) => setIsAutoApprove(e.target.checked)}
                className="w-5 h-5 accent-amber-500 rounded cursor-pointer"
              />
            </div>

          </form>
        </div>

        {/* Modal Footer Actions */}
        <div className="px-6 py-4 bg-slate-50 border-t border-slate-200 flex items-center justify-end gap-3 shrink-0">
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            className="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold text-xs transition-colors cursor-pointer"
          >
            Cancel (අවලංගු කරන්න)
          </button>
          
          <button
            type="submit"
            form="add-provider-form"
            disabled={loading}
            className="px-6 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-extrabold text-xs shadow-md flex items-center gap-2 transition-all cursor-pointer disabled:opacity-50"
          >
            {loading ? (
              <>
                <RefreshCw className="w-4 h-4 animate-spin" />
                <span>Creating Provider...</span>
              </>
            ) : (
              <>
                <UserPlus className="w-4 h-4" />
                <span>Create Provider (ලියාපදිංචි කරන්න)</span>
              </>
            )}
          </button>
        </div>

      </div>
    </div>,
    document.body
  );
}
