import React from 'react';
import { 
  BarChart3, 
  Users, 
  Grid, 
  CalendarCheck, 
  MessageSquare, 
  Bell, 
  LogOut,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';

const Sidebar = ({ 
  activeTab, 
  setActiveTab, 
  pendingVerificationsCount, 
  categoriesCount, 
  currentUser, 
  onLogout, 
  onOpenProfile,
  isCollapsed = false,
  onToggleCollapse
}) => {
  const navItems = [
    {
      id: 'analytics',
      label: 'Reports & Analytics',
      icon: BarChart3,
      badge: null
    },
    {
      id: 'users',
      label: 'User Management',
      icon: Users,
      badge: pendingVerificationsCount > 0 ? pendingVerificationsCount : null,
      badgeColor: 'bg-amber-100 text-amber-900 border-amber-300'
    },
    {
      id: 'categories',
      label: 'Service Categories',
      icon: Grid,
      badge: categoriesCount ? `${categoriesCount}` : null
    },
    {
      id: 'bookings',
      label: 'Booking & Jobs',
      icon: CalendarCheck,
      badge: null
    },
    {
      id: 'reviews',
      label: 'Reviews & Complaints',
      icon: MessageSquare,
      badge: null
    },
    {
      id: 'notifications',
      label: 'Push Notifications',
      icon: Bell,
      badge: null
    }
  ];

  return (
    <aside 
      className={`${
        isCollapsed ? 'w-20' : 'w-72'
      } bg-white border-r border-slate-200/90 flex flex-col justify-between h-screen sticky top-0 backdrop-blur-xl z-30 select-none shadow-xs transition-all duration-300 ease-in-out`}
    >
      {/* Top Brand Header */}
      <div>
        <div className={`p-4 border-b border-slate-200/80 flex items-center ${isCollapsed ? 'justify-center' : 'justify-between'} bg-slate-50/70 h-20 transition-all`}>
          {!isCollapsed ? (
            <div className="flex items-center gap-3 min-w-0">
              <div className="relative shrink-0">
                <img 
                  src="/logo.png" 
                  alt="Ape Baas Logo" 
                  className="w-10 h-10 rounded-xl object-contain shadow-md shadow-amber-500/20 border border-amber-500/30 p-0.5 bg-amber-500"
                />
              </div>
              <div className="min-w-0">
                <h1 className="font-black text-base text-slate-900 leading-tight flex items-center gap-1.5 tracking-tight truncate">
                  Ape Baas <span className="text-[10px] px-1.5 py-0.5 rounded bg-amber-500 text-slate-950 font-black tracking-wider shadow-sm">PRO</span>
                </h1>
                <p className="text-xs text-amber-600 font-semibold truncate">Admin Operations</p>
              </div>
            </div>
          ) : (
            <div 
              className="relative group cursor-pointer" 
              onClick={onToggleCollapse} 
              title="Expand Sidebar"
            >
              <img 
                src="/logo.png" 
                alt="Ape Baas Logo" 
                className="w-10 h-10 rounded-xl object-contain shadow-md shadow-amber-500/20 border border-amber-500/30 p-0.5 bg-amber-500 group-hover:scale-105 transition-transform"
              />
            </div>
          )}

          {/* Collapse Toggle Button (When expanded) */}
          {onToggleCollapse && (
            <button
              onClick={onToggleCollapse}
              className={`p-1.5 rounded-lg text-slate-400 hover:text-slate-800 hover:bg-slate-200/70 border border-slate-200 transition-all cursor-pointer ${
                isCollapsed ? 'hidden' : 'block shrink-0'
              }`}
              title="Collapse Sidebar"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
          )}
        </div>

        {/* Navigation Menu */}
        <nav className="p-3 space-y-1.5">
          {!isCollapsed && (
            <div className="px-3 py-2 text-[11px] font-bold text-slate-400 uppercase tracking-wider">
              Main Modules
            </div>
          )}
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                title={isCollapsed ? `${item.label}${item.badge ? ` (${item.badge})` : ''}` : undefined}
                className={`w-full flex items-center ${
                  isCollapsed ? 'justify-center px-0 py-3' : 'justify-between px-3.5 py-3'
                } rounded-xl font-medium text-sm transition-all duration-200 group cursor-pointer relative ${
                  isActive
                    ? 'bg-amber-500 text-slate-950 font-bold shadow-sm border border-amber-500'
                    : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100/90 font-semibold'
                }`}
              >
                <div className={`flex items-center ${isCollapsed ? 'justify-center' : 'gap-3 min-w-0'}`}>
                  <div className="relative shrink-0">
                    <Icon className={`w-5 h-5 transition-transform duration-200 ${isActive ? 'text-slate-950 scale-110 stroke-[2.5]' : 'text-slate-400 group-hover:text-amber-600'}`} />
                    {isCollapsed && item.badge && (
                      <span className="absolute -top-1.5 -right-1.5 w-2.5 h-2.5 bg-amber-500 rounded-full ring-2 ring-white animate-pulse" />
                    )}
                  </div>
                  {!isCollapsed && (
                    <span className={`truncate ${isActive ? 'font-bold text-slate-950' : 'font-medium'}`}>
                      {item.label}
                    </span>
                  )}
                </div>

                {!isCollapsed && item.badge && (
                  <span className={`text-xs px-2 py-0.5 rounded-full font-extrabold border shrink-0 ${
                    isActive
                      ? 'bg-slate-950/20 text-slate-950 border-slate-950/30'
                      : item.badgeColor || 'bg-amber-100 text-amber-800 border-amber-200'
                  }`}>
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>
      </div>

      {/* Bottom Profile / Collapse Control */}
      <div className="p-3 border-t border-slate-200/80 bg-slate-50/80 space-y-2">
        {/* Expand toggle when collapsed */}
        {isCollapsed && onToggleCollapse && (
          <button
            onClick={onToggleCollapse}
            className="w-full flex items-center justify-center p-2 rounded-xl text-slate-400 hover:text-slate-800 hover:bg-white border border-slate-200 transition-all cursor-pointer shadow-xs"
            title="Expand Sidebar"
          >
            <ChevronRight className="w-5 h-5 text-amber-600" />
          </button>
        )}

        {/* Profile Avatar Card */}
        <div 
          onClick={onOpenProfile}
          className={`p-2.5 rounded-xl bg-white hover:bg-slate-50 border border-slate-200 hover:border-amber-500/50 flex items-center ${
            isCollapsed ? 'justify-center' : 'justify-between'
          } cursor-pointer transition-all duration-200 group shadow-xs hover:shadow-sm`}
          title={isCollapsed ? `${currentUser?.full_name || 'Super Admin'} (Admin Profile)` : "Admin Profile / View Details"}
        >
          <div className="flex items-center gap-3 min-w-0">
            <div className="relative shrink-0">
              <img
                src={currentUser?.avatar || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120"}
                alt="Admin Avatar"
                className="w-9 h-9 rounded-full object-cover border-2 border-amber-400/60 group-hover:border-amber-500 transition-colors"
              />
              <span className="absolute bottom-0 right-0 w-2.5 h-2.5 bg-emerald-500 rounded-full ring-2 ring-white"></span>
            </div>
            {!isCollapsed && (
              <div className="text-left min-w-0">
                <p className="text-xs font-bold text-slate-800 group-hover:text-amber-600 transition-colors truncate">
                  {currentUser?.full_name || 'Super Admin'}
                </p>
                <p className="text-[11px] text-emerald-600 font-bold flex items-center gap-1">
                  <span>●</span> System Online
                </p>
              </div>
            )}
          </div>

          {!isCollapsed && onLogout && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onLogout();
              }}
              className="p-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-600 border border-rose-200 transition-all shrink-0 ml-2 cursor-pointer"
              title="Sign Out / Logout"
            >
              <LogOut className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
