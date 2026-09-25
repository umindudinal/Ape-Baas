import React from 'react';
import { 
  Users, 
  UserCheck, 
  Clock, 
  CalendarCheck, 
  DollarSign, 
  AlertTriangle,
  TrendingUp,
  Layers,
  Award
} from 'lucide-react';
import { 
  AreaChart, 
  Area, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer, 
  BarChart, 
  Bar, 
  Cell 
} from 'recharts';

const DashboardPage = ({ stats, setActiveTab, currentUser }) => {
  const adminDisplayName = currentUser?.full_name || currentUser?.name || 'Umindu Dinal';
  // Dynamic Chart Data from Supabase API with smart fallbacks
  const bookingGrowthData = stats?.bookingGrowthData && stats.bookingGrowthData.some(d => d.bookings > 0 || d.revenue > 0)
    ? stats.bookingGrowthData
    : [
        { day: 'Mon', bookings: 0, revenue: 0 },
        { day: 'Tue', bookings: 0, revenue: 0 },
        { day: 'Wed', bookings: 0, revenue: 0 },
        { day: 'Thu', bookings: 0, revenue: 0 },
        { day: 'Fri', bookings: 0, revenue: 0 },
        { day: 'Sat', bookings: 0, revenue: 0 },
        { day: 'Sun', bookings: 0, revenue: 0 },
      ];

  const categoryDistribution = stats?.categoryDistribution && stats.categoryDistribution.length > 0
    ? stats.categoryDistribution
    : [
        { name: 'Electrical Work', value: 40, color: '#f59e0b' },
        { name: 'Plumbing', value: 30, color: '#0ea5e9' },
        { name: 'A/C Repair', value: 20, color: '#10b981' },
        { name: 'Masonry', value: 10, color: '#f97316' },
      ];

  const statusBreakdown = stats?.statusBreakdown || [
    { name: 'Completed', count: 0, fill: '#10b981' },
    { name: 'In Progress', count: 0, fill: '#f59e0b' },
    { name: 'Pending', count: 0, fill: '#38bdf8' },
    { name: 'Cancelled', count: 0, fill: '#ef4444' },
  ];

  const topCategoryName = stats?.topCategory || categoryDistribution[0]?.name || 'General Maintenance';

  const kpiCards = [
    {
      title: 'Total Customers',
      value: stats?.totalCustomers ?? 0,
      change: 'Registered Customers',
      icon: Users,
      color: 'bg-amber-500 text-slate-950',
      badgeBg: 'bg-amber-50 text-amber-700 border-amber-200',
      tab: 'users'
    },
    {
      title: 'Active Providers',
      value: stats?.activeProviders ?? stats?.totalProviders ?? 0,
      change: `${stats?.pendingVerifications || 0} pending review`,
      icon: UserCheck,
      color: 'bg-emerald-600 text-white',
      badgeBg: 'bg-emerald-50 text-emerald-700 border-emerald-200',
      tab: 'users'
    },
    {
      title: 'Pending Verifications',
      value: stats?.pendingVerifications ?? 0,
      change: stats?.pendingVerifications > 0 ? 'Requires review' : 'All up to date',
      icon: Clock,
      color: 'bg-orange-500 text-white',
      badgeBg: 'bg-orange-50 text-orange-700 border-orange-200',
      tab: 'users'
    },
    {
      title: 'Total Jobs Booked',
      value: stats?.totalBookings ?? 0,
      change: `${stats?.pendingBookings || 0} pending • ${stats?.completedBookings || 0} done`,
      icon: CalendarCheck,
      color: 'bg-sky-600 text-white',
      badgeBg: 'bg-sky-50 text-sky-700 border-sky-200',
      tab: 'bookings'
    },
    {
      title: 'Successful Completions',
      value: stats?.completedBookings ?? stats?.statusBreakdown?.find(s => s.name === 'Completed')?.count ?? 0,
      change: `Rs. ${stats?.completedRevenue ? stats.completedRevenue.toLocaleString() : '0'} completed`,
      icon: Award,
      color: 'bg-emerald-500 text-white',
      badgeBg: 'bg-emerald-50 text-emerald-700 border-emerald-200',
      tab: 'bookings'
    },
    {
      title: 'Platform Reviews',
      value: `${stats?.totalReviews ?? 0} (★ ${stats?.averageRating ?? '5.0'})`,
      change: stats?.activeDisputes > 0 ? `${stats.activeDisputes} disputes` : 'Excellent service rating',
      icon: AlertTriangle,
      color: 'bg-rose-500 text-white',
      badgeBg: 'bg-rose-50 text-rose-700 border-rose-200',
      tab: 'reviews'
    }
  ];

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Top Banner Overview */}
      <div className="p-6 rounded-3xl bg-amber-50/60 border border-amber-200/80 relative overflow-hidden flex flex-col md:flex-row md:items-center justify-between gap-6 shadow-xs">
        <div className="relative z-10">
          <h3 className="text-2xl font-black text-slate-900 tracking-tight">
            Welcome back, {adminDisplayName} !
          </h3>
          <p className="text-sm text-slate-600 max-w-xl mt-1 font-medium">
            Monitor real-time customer requests, provider verification statuses, and platform commission growth.
          </p>
        </div>
        <div className="flex items-center gap-3 relative z-10 flex-wrap">
          <div className="px-5 py-3.5 rounded-2xl bg-white border border-amber-200 shadow-xs text-center min-w-[120px]">
            <p className="text-[11px] font-semibold text-slate-500">Gross Job Value</p>
            <p className="text-lg font-black text-slate-900">
              Rs. {Number(stats?.totalRevenue || 0).toLocaleString()}
            </p>
          </div>
          <div className="px-5 py-3.5 rounded-2xl bg-white border border-amber-200 shadow-xs text-center min-w-[120px]">
            <p className="text-[11px] font-semibold text-slate-500">Platform Commission (15%)</p>
            <p className="text-lg font-black text-amber-600">
              Rs. {Number(stats?.totalCommission || 0).toLocaleString()}
            </p>
          </div>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {kpiCards.map((kpi, idx) => {
          const Icon = kpi.icon;
          return (
            <div
              key={idx}
              onClick={() => setActiveTab && kpi.tab && setActiveTab(kpi.tab)}
              className="p-5 rounded-2xl bg-white border border-slate-200 hover:border-amber-400 hover:shadow-md hover:shadow-slate-200/60 cursor-pointer transition-all duration-200 group relative overflow-hidden active:scale-[0.98] shadow-xs"
              title={`Click to view ${kpi.title}`}
            >
              <div className="flex items-center justify-between">
                <span className={`text-xs px-2.5 py-1 rounded-full font-bold border ${kpi.badgeBg}`}>
                  {kpi.change}
                </span>
                <div className={`w-11 h-11 rounded-xl ${kpi.color} flex items-center justify-center shadow-xs group-hover:scale-110 transition-transform`}>
                  <Icon className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-4">
                <p className="text-xs font-bold text-slate-500 uppercase tracking-wider group-hover:text-amber-600 transition-colors">
                  {kpi.title}
                </p>
                <h4 className="text-2xl font-black text-slate-900 mt-1 tracking-tight">
                  {kpi.value}
                </h4>
              </div>
            </div>
          );
        })}
      </div>

      {/* Main Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Weekly Booking & Revenue Area Chart */}
        <div className="lg:col-span-2 p-6 rounded-2xl bg-white border border-slate-200 shadow-xs">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h4 className="text-base font-bold text-slate-900 flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-amber-500" />
                Daily Booking & Revenue Growth
              </h4>
              <p className="text-xs text-slate-500 font-medium">
                Total customer job requests over the past 7 days
              </p>
            </div>
            <span className="text-xs font-bold px-3 py-1 rounded-lg bg-amber-50 text-amber-700 border border-amber-200">
              LKR Revenue
            </span>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={bookingGrowthData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="day" stroke="#94a3b8" tickLine={false} />
                <YAxis stroke="#94a3b8" tickLine={false} />
                <Tooltip
                  contentStyle={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0', borderRadius: '12px', color: '#0f172a', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
                  formatter={(val, name) => name === 'revenue' ? [`Rs. ${val.toLocaleString()}`, 'Revenue'] : [val, 'Bookings']}
                />
                <Area type="monotone" dataKey="revenue" stroke="#f59e0b" strokeWidth={3} fillOpacity={0.2} fill="#f59e0b" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Category Popularity Breakdown */}
        <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-xs flex flex-col justify-between">
          <div>
            <h4 className="text-base font-bold text-slate-900 flex items-center gap-2 mb-1">
              <Layers className="w-5 h-5 text-amber-500" />
              Top Popular Service Categories
            </h4>
            <p className="text-xs text-slate-500 font-medium mb-4">
              Most booked categories this month
            </p>

            <div className="space-y-3">
              {categoryDistribution.map((cat, i) => (
                <div key={i} className="space-y-1">
                  <div className="flex items-center justify-between text-xs font-semibold">
                    <span className="text-slate-700 flex items-center gap-2">
                      <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: cat.color }}></span>
                      {cat.name}
                    </span>
                    <span className="text-slate-500">{cat.value}%</span>
                  </div>
                  <div className="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                    <div className="h-full rounded-full transition-all duration-500" style={{ width: `${cat.value}%`, backgroundColor: cat.color }}></div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="mt-6 p-4 rounded-xl bg-amber-50/70 border border-amber-200/70 flex items-center gap-3">
            <Award className="w-8 h-8 text-amber-600 shrink-0" />
            <div>
              <p className="text-xs font-bold text-slate-900">
                Rank 1: {topCategoryName}
              </p>
              <p className="text-[11px] text-slate-600 font-medium">
                Most popular service category requested by customers.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Booking Status Distribution Bar Chart */}
      <div className="p-6 rounded-2xl bg-white border border-slate-200 shadow-xs">
        <h4 className="text-base font-bold text-slate-900 mb-4">
          Booking Status Breakdown
        </h4>
        <div className="h-64 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={statusBreakdown} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="name" stroke="#94a3b8" />
              <YAxis stroke="#94a3b8" />
              <Tooltip contentStyle={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0', borderRadius: '12px', color: '#0f172a', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }} />
              <Bar dataKey="count" radius={[8, 8, 0, 0]}>
                {statusBreakdown.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default DashboardPage;
