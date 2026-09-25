import React, { useState } from 'react';
import { Search, Bell, AlertTriangle, CheckCircle2, LogOut, PanelLeft, PanelLeftClose } from 'lucide-react';

const Header = ({ 
  searchQuery, 
  setSearchQuery, 
  pendingVerificationsCount, 
  activeTab, 
  categoriesCount, 
  onLogout,
  isSidebarCollapsed,
  onToggleSidebar
}) => {
  const [showNotifications, setShowNotifications] = useState(false);

  const titleMap = {
    analytics: 'Dashboard Reports & Analytics',
    users: 'User & Provider Management',
    categories: `Service Category Management (${categoriesCount || 50} Total)`,
    bookings: 'Booking & Job Dispatching',
    reviews: 'Reviews & Dispute Moderation',
    notifications: 'Push Notification Center'
  };

  return (
    <header className="h-20 border-b border-slate-200/90 bg-white/90 backdrop-blur-xl px-6 lg:px-8 flex items-center justify-between sticky top-0 z-20 shadow-xs">
      {/* Title & Sidebar Toggle */}
      <div className="flex items-center gap-3 min-w-0">
        {onToggleSidebar && (
          <button
            onClick={onToggleSidebar}
            className="p-2 rounded-xl text-slate-500 hover:text-slate-900 hover:bg-slate-100 border border-slate-200 transition-all cursor-pointer shadow-xs shrink-0"
            title={isSidebarCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
          >
            {isSidebarCollapsed ? (
              <PanelLeft className="w-5 h-5 text-amber-600" />
            ) : (
              <PanelLeftClose className="w-5 h-5 text-slate-500" />
            )}
          </button>
        )}
        <div className="min-w-0">
          <h2 className="text-lg lg:text-xl font-black text-slate-900 tracking-tight flex items-center gap-2 truncate">
            {titleMap[activeTab]}
          </h2>
          <p className="text-xs text-amber-600 font-semibold truncate">
            Ape Baas Admin Operations Portal
          </p>
        </div>
      </div>

      {/* Right Controls */}
      <div className="flex items-center gap-4">
        {/* Universal Search Bar */}
        <div className="relative w-72">
          <Search className="w-4 h-4 text-amber-600 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search providers, jobs, categories..."
            className="w-full pl-10 pr-4 py-2 text-sm bg-slate-100/90 text-slate-900 placeholder-slate-400 rounded-xl border border-slate-200 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-1 focus:ring-amber-500 transition-all font-medium"
          />
        </div>

        {/* Notification Bell Dropdown */}
        <div className="relative">
          <button
            onClick={() => setShowNotifications(!showNotifications)}
            className="p-2.5 rounded-xl bg-slate-100 hover:bg-slate-200/80 text-amber-600 border border-slate-200 relative transition-all shadow-xs cursor-pointer"
          >
            <Bell className="w-5 h-5" />
            {pendingVerificationsCount > 0 && (
              <span className="absolute -top-1 -right-1 w-5 h-5 bg-amber-500 text-slate-950 text-[10px] font-black rounded-full flex items-center justify-center animate-pulse border-2 border-white shadow-sm">
                {pendingVerificationsCount}
              </span>
            )}
          </button>

          {showNotifications && (
            <div className="absolute right-0 mt-3 w-80 bg-white border border-slate-200 rounded-2xl shadow-2xl p-4 z-50 animate-in fade-in zoom-in-95 backdrop-blur-xl">
              <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-3">
                <h4 className="font-bold text-sm text-slate-900 flex items-center gap-2">
                  <Bell className="w-4 h-4 text-amber-600" />
                  System Notifications
                </h4>
                <span className="text-[11px] bg-amber-100 text-amber-800 border border-amber-200 px-2 py-0.5 rounded font-extrabold">
                  {pendingVerificationsCount} Pending
                </span>
              </div>

              <div className="space-y-2 max-h-64 overflow-y-auto">
                {pendingVerificationsCount > 0 ? (
                  <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl flex items-start gap-3">
                    <AlertTriangle className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                    <div>
                      <p className="text-xs font-bold text-amber-900">
                        Pending Provider Verifications
                      </p>
                      <p className="text-[11px] text-amber-800/80 mt-0.5">
                        {pendingVerificationsCount} service providers waiting for identity review.
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="p-3 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center gap-3">
                    <CheckCircle2 className="w-5 h-5 text-emerald-600 shrink-0" />
                    <p className="text-xs text-emerald-800 font-semibold">
                      All pending tasks cleared!
                    </p>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* Logout Button */}
        {onLogout && (
          <button
            onClick={onLogout}
            className="p-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 flex items-center gap-2 text-xs font-bold transition-all shadow-xs cursor-pointer"
            title="Log out of Admin Dashboard"
          >
            <LogOut className="w-4 h-4" />
            <span className="hidden sm:inline">Sign Out</span>
          </button>
        )}
      </div>
    </header>
  );
};

export default Header;
