import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  Grid, 
  Plus, 
  Edit3, 
  Eye, 
  EyeOff, 
  Search, 
  Sparkles, 
  Zap, 
  Wrench, 
  Hammer, 
  Wind, 
  Building, 
  Paintbrush, 
  Trees, 
  Sun,
  Camera, 
  Tv, 
  Home, 
  Bug, 
  Car, 
  Shirt, 
  Snowflake, 
  Layers, 
  Flame, 
  Droplets, 
  Scissors, 
  CloudRain, 
  Armchair, 
  Key, 
  ShieldAlert, 
  Trash2, 
  Waves, 
  Truck, 
  Cpu, 
  Thermometer, 
  Smartphone, 
  Image, 
  Maximize, 
  Volume2, 
  Shield, 
  Settings, 
  Square, 
  Box,
  Check
} from 'lucide-react';

const ICON_MAP = {
  Zap, Wrench, Hammer, Wind, Building, Paintbrush, Grid, Trees, Sparkles, Sun, Camera, Tv, Home, Bug, Car, Shirt, Snowflake, Layers, Flame, Layout: Grid, Droplets, Scissors, CloudRain, Armchair, Key, ShieldAlert, Trash2, Waves, Truck, Cpu, Thermometer, Smartphone, Image, Maximize2: Maximize, Maximize, Volume2, Shield, Settings, Square, Box
};

function getAutoIconForCategory(nameEn) {
  const text = (nameEn || '').toLowerCase();
  
  if (text.includes('solar') || text.includes('sun') || text.includes('energy')) return 'Sun';
  if (text.includes('paint') || text.includes('color') || text.includes('wall')) return 'Paintbrush';
  if (text.includes('plumb') || text.includes('pipe') || text.includes('water') || text.includes('tap') || text.includes('gully') || text.includes('tank') || text.includes('well') || text.includes('pump')) return 'Droplets';
  if (text.includes('electr') || text.includes('power') || text.includes('wire') || text.includes('light') || text.includes('bulb') || text.includes('generator')) return 'Zap';
  if (text.includes('ac') || text.includes('air') || text.includes('cool') || text.includes('fan') || text.includes('ventil') || text.includes('exhaust')) return 'Wind';
  if (text.includes('mason') || text.includes('tile') || text.includes('brick') || text.includes('slab') || text.includes('concrete') || text.includes('pavin') || text.includes('interlock') || text.includes('demolit')) return 'Grid';
  if (text.includes('carpenter') || text.includes('wood') || text.includes('roof') || text.includes('furniture') || text.includes('upholster') || text.includes('curtain') || text.includes('blinds') || text.includes('ceiling') || text.includes('gypsum') || text.includes('fenc')) return 'Hammer';
  if (text.includes('weld') || text.includes('metal') || text.includes('aluminum') || text.includes('iron') || text.includes('steel') || text.includes('fabricat') || text.includes('gutter') || text.includes('gas') || text.includes('fire')) return 'Flame';
  if (text.includes('clean') || text.includes('wash') || text.includes('dust') || text.includes('sweep') || text.includes('deep') || text.includes('garbage') || text.includes('debris')) return 'Sparkles';
  if (text.includes('cctv') || text.includes('security') || text.includes('camera') || text.includes('alarm') || text.includes('lock') || text.includes('key')) return 'Camera';
  if (text.includes('garden') || text.includes('tree') || text.includes('landscape') || text.includes('grass') || text.includes('lawn')) return 'Trees';
  if (text.includes('pest') || text.includes('bug') || text.includes('termite') || text.includes('insect')) return 'Bug';
  if (text.includes('car') || text.includes('auto') || text.includes('vehicle') || text.includes('moving') || text.includes('transport')) return 'Truck';
  if (text.includes('tv') || text.includes('antenna') || text.includes('dish')) return 'Tv';
  if (text.includes('it') || text.includes('computer') || text.includes('net') || text.includes('wifi') || text.includes('smart')) return 'Cpu';
  if (text.includes('glass') || text.includes('window')) return 'Maximize';
  
  return 'Wrench';
}

function renderCategoryIcon(iconName) {
  const IconComponent = ICON_MAP[iconName] || Wrench;
  return <IconComponent className="w-5 h-5" />;
}

const CategoriesPage = ({ categories, onAddCategory, onToggleCategoryStatus, onEditCategory, onDeleteCategory }) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All'); // 'All' | 'Active' | 'Hidden'
  
  // Modals state
  const [showAddModal, setShowAddModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(null);
  const [showDeleteModal, setShowDeleteModal] = useState(null);

  // Form State
  const [newCatSi, setNewCatSi] = useState('');
  const [newCatEn, setNewCatEn] = useState('');
  const [newCatIcon, setNewCatIcon] = useState('Wrench');
  const [newCatPrice, setNewCatPrice] = useState(3000);

  const filteredCategories = categories.filter(cat => {
    const matchesSearch = cat.nameSi.toLowerCase().includes(searchQuery.toLowerCase()) || 
                          cat.nameEn.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'All' || cat.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const handleCreateCategory = (e) => {
    e.preventDefault();
    if (!newCatEn) return;

    onAddCategory({
      id: `cat-${Date.now()}`,
      nameSi: newCatSi || newCatEn,
      nameEn: newCatEn,
      icon: newCatIcon,
      status: 'Active',
      providerCount: 0,
      basePrice: Number(newCatPrice)
    });

    setNewCatSi('');
    setNewCatEn('');
    setShowAddModal(false);
  };

  const handleUpdateCategory = (e) => {
    e.preventDefault();
    if (!showEditModal) return;

    onEditCategory(showEditModal.id, {
      nameSi: newCatSi || showEditModal.nameSi,
      nameEn: newCatEn || showEditModal.nameEn,
      icon: newCatIcon || showEditModal.icon,
      basePrice: Number(newCatPrice || showEditModal.basePrice)
    });

    setShowEditModal(null);
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Category Header Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-6 rounded-2xl bg-white border border-slate-200 shadow-xs">
        <div>
          <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
            <Grid className="w-6 h-6 text-amber-500" />
            App Service Categories ({categories.length} Total)
          </h3>
          <p className="text-xs text-slate-500 mt-1 font-medium">
            Add new categories, modify icons or display names, and toggle active/hidden status.
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="px-5 py-3 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs flex items-center gap-2 shadow-xs transition-all self-start md:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          <span>Add New Category</span>
        </button>
      </div>

      {/* Filter and Search Bar */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 bg-white p-4 rounded-2xl border border-slate-200 shadow-xs">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder={`Filter ${categories.length} categories...`}
            className="w-full pl-10 pr-4 py-2 text-xs bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium placeholder:text-slate-400"
          />
        </div>

        <div className="flex items-center gap-2">
          {['All', 'Active', 'Hidden'].map((status) => (
            <button
              key={status}
              onClick={() => setStatusFilter(status)}
              className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                statusFilter === status
                  ? 'bg-amber-500 text-slate-950 font-bold shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:text-slate-900 hover:bg-slate-200'
              }`}
            >
              {status === 'All' ? `All (${categories.length})` : status}
            </button>
          ))}
        </div>
      </div>

      {/* Categories Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filteredCategories.map((cat) => (
          <div
            key={cat.id}
            className={`p-4 rounded-2xl border transition-all duration-200 flex flex-col justify-between ${
              cat.status === 'Active'
                ? 'bg-white border-slate-200 hover:border-amber-400 hover:shadow-md hover:shadow-slate-200/50 shadow-xs'
                : 'bg-slate-50 border-slate-200 opacity-60'
            }`}
          >
            <div>
              <div className="flex items-center justify-between mb-3">
                <div className="w-10 h-10 rounded-xl bg-amber-100 border border-amber-300 text-amber-700 flex items-center justify-center shadow-xs">
                  {renderCategoryIcon(cat.icon)}
                </div>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                  cat.status === 'Active'
                    ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                    : 'bg-slate-100 text-slate-500 border-slate-200'
                }`}>
                  {cat.status}
                </span>
              </div>

              <h4 className="font-bold text-slate-900 text-sm leading-snug">{cat.nameEn}</h4>
              <p className="text-xs text-slate-500 font-medium mt-0.5">{cat.nameSi}</p>
            </div>

            <div className="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-xs">
              <div>
                <span className="text-slate-400 block text-[10px]">Pricing Model:</span>
                <span className="font-semibold text-slate-700">Direct Customer Deal</span>
              </div>
              <div className="flex items-center gap-1.5">
                <button
                  onClick={() => {
                    setShowEditModal(cat);
                    setNewCatSi(cat.nameSi);
                    setNewCatEn(cat.nameEn);
                    setNewCatIcon(cat.icon);
                  }}
                  className="p-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 transition-colors cursor-pointer"
                  title="Edit Category Details"
                >
                  <Edit3 className="w-3.5 h-3.5" />
                </button>
                <button
                  onClick={() => onToggleCategoryStatus(cat.id)}
                  className={`p-1.5 rounded-lg border transition-colors cursor-pointer ${
                    cat.status === 'Active'
                      ? 'bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100'
                      : 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                  }`}
                  title={cat.status === 'Active' ? 'Hide Category' : 'Show Category'}
                >
                  {cat.status === 'Active' ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                </button>
                <button
                  onClick={() => setShowDeleteModal(cat)}
                  className="p-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 transition-colors cursor-pointer"
                  title="Delete Category Permanently"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* CREATE CATEGORY MODAL */}
      {showAddModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[9999] animate-in fade-in">
          <form onSubmit={handleCreateCategory} className="bg-white border border-slate-200 rounded-3xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-200 pb-3">
              <h4 className="font-bold text-slate-900 text-base">
                Add New Service Category
              </h4>
              <button type="button" onClick={() => setShowAddModal(false)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <label className="text-slate-700 font-semibold block mb-1">Category Title (English):</label>
                <input
                  type="text"
                  required
                  value={newCatEn}
                  onChange={(e) => {
                    const val = e.target.value;
                    setNewCatEn(val);
                    setNewCatIcon(getAutoIconForCategory(val));
                  }}
                  placeholder="e.g. Solar Panel Service"
                  className="w-full p-2.5 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium placeholder:text-slate-400"
                />
              </div>

              <div>
                <label className="text-slate-700 font-semibold block mb-1">Category Title (Sinhala / Local Name):</label>
                <input
                  type="text"
                  value={newCatSi}
                  onChange={(e) => setNewCatSi(e.target.value)}
                  placeholder="e.g. Solar Service (Local name)"
                  className="w-full p-2.5 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium placeholder:text-slate-400"
                />
              </div>

              {/* Auto Generated Icon Preview */}
              <div className="p-3 rounded-2xl bg-amber-50 border border-amber-200 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center font-bold shadow-xs">
                    {renderCategoryIcon(newCatIcon)}
                  </div>
                  <div>
                    <span className="text-[10px] text-amber-800 font-bold uppercase tracking-wider block">Auto-Assigned Icon:</span>
                    <span className="text-xs text-slate-900 font-bold">{newCatIcon}</span>
                  </div>
                </div>
                <span className="text-[10px] text-amber-800 bg-amber-100 px-2.5 py-0.5 rounded-full border border-amber-300 font-bold">
                  Auto Detected ✨
                </span>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-3">
              <button type="button" onClick={() => setShowAddModal(false)} className="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold cursor-pointer">
                Cancel
              </button>
              <button type="submit" className="px-5 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs shadow-xs cursor-pointer">
                Create Category
              </button>
            </div>
          </form>
        </div>,
        document.body
      )}

      {/* EDIT CATEGORY MODAL */}
      {showEditModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[9999] animate-in fade-in">
          <form onSubmit={handleUpdateCategory} className="bg-white border border-slate-200 rounded-3xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-200 pb-3">
              <h4 className="font-bold text-slate-900 text-base">
                Edit Service Category
              </h4>
              <button type="button" onClick={() => setShowEditModal(null)} className="text-slate-400 hover:text-slate-600 cursor-pointer">✕</button>
            </div>

            <div className="space-y-3 text-xs">
              <div>
                <label className="text-slate-700 font-semibold block mb-1">Category Title (English):</label>
                <input
                  type="text"
                  value={newCatEn}
                  onChange={(e) => {
                    const val = e.target.value;
                    setNewCatEn(val);
                    setNewCatIcon(getAutoIconForCategory(val));
                  }}
                  className="w-full p-2.5 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium"
                />
              </div>

              <div>
                <label className="text-slate-700 font-semibold block mb-1">Category Title (Sinhala / Local Name):</label>
                <input
                  type="text"
                  value={newCatSi}
                  onChange={(e) => setNewCatSi(e.target.value)}
                  className="w-full p-2.5 bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium"
                />
              </div>

              {/* Auto Generated Icon Preview */}
              <div className="p-3 rounded-2xl bg-amber-50 border border-amber-200 flex items-center justify-between">
                <div className="flex items-center gap-2.5">
                  <div className="w-9 h-9 rounded-xl bg-amber-500 text-slate-950 flex items-center justify-center font-bold shadow-xs">
                    {renderCategoryIcon(newCatIcon)}
                  </div>
                  <div>
                    <span className="text-[10px] text-amber-800 font-bold uppercase tracking-wider block">Assigned Category Icon:</span>
                    <span className="text-xs text-slate-900 font-bold">{newCatIcon}</span>
                  </div>
                </div>
                <span className="text-[10px] text-amber-800 bg-amber-100 px-2.5 py-0.5 rounded-full border border-amber-300 font-bold">
                  Auto Detected ✨
                </span>
              </div>
            </div>

            <div className="flex items-center justify-end gap-3 pt-3">
              <button type="button" onClick={() => setShowEditModal(null)} className="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold cursor-pointer">
                Cancel
              </button>
              <button type="submit" className="px-5 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs shadow-xs cursor-pointer">
                Save Changes
              </button>
            </div>
          </form>
        </div>,
        document.body
      )}

      {/* DELETE CONFIRMATION POPUP MODAL */}
      {showDeleteModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[9999] animate-in fade-in duration-200">
          <div className="bg-white border border-slate-200 rounded-3xl max-w-md w-full p-6 space-y-5 shadow-2xl">
            <div className="flex items-center gap-3 border-b border-slate-200 pb-4">
              <div className="w-10 h-10 rounded-2xl bg-rose-50 border border-rose-200 text-rose-600 flex items-center justify-center font-bold">
                <Trash2 className="w-5 h-5" />
              </div>
              <div>
                <h4 className="font-bold text-slate-900 text-base">
                  Delete Service Category?
                </h4>
                <p className="text-xs text-slate-500 font-medium">
                  This action will permanently delete the category.
                </p>
              </div>
            </div>

            <div className="p-4 rounded-2xl bg-rose-50 border border-rose-200 text-xs text-rose-800 space-y-2">
              <p className="font-semibold">
                Are you sure you want to delete <span className="font-bold text-slate-900 underline">{showDeleteModal.nameEn}</span> ({showDeleteModal.nameSi})?
              </p>
              <p className="text-[11px] text-slate-600">
                It will be permanently removed from the Supabase Database and Admin Operations Portal.
              </p>
            </div>

            <div className="flex items-center justify-end gap-3 pt-2">
              <button
                type="button"
                onClick={() => setShowDeleteModal(null)}
                className="px-4 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold transition-colors cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => {
                  onDeleteCategory(showDeleteModal.id);
                  setShowDeleteModal(null);
                }}
                className="px-5 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-bold text-xs shadow-xs transition-all flex items-center gap-1.5 cursor-pointer"
              >
                <Trash2 className="w-4 h-4" />
                <span>Yes, Delete Category</span>
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}
    </div>
  );
};

export default CategoriesPage;
