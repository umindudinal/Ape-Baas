import React, { useState } from 'react';
import { 
  CalendarCheck, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  MapPin, 
  Search, 
  RefreshCw
} from 'lucide-react';

const BookingsPage = ({ bookings, providers, onUpdateBookingStatus, onReassignProvider }) => {
  const [selectedStatus, setSelectedStatus] = useState('All'); // 'All' | 'Pending' | 'In Progress' | 'Completed' | 'Cancelled'
  const [searchQuery, setSearchQuery] = useState('');

  const filteredBookings = bookings.filter(b => {
    const matchesStatus = selectedStatus === 'All' || b.status === selectedStatus;
    const matchesSearch = b.customerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          b.providerName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          b.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          b.serviceTitle.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const getStatusBadge = (status) => {
    switch (status) {
      case 'Completed':
        return <span className="px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs font-bold flex items-center gap-1"><CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" /> Completed</span>;
      case 'In Progress':
        return <span className="px-2.5 py-1 rounded-full bg-sky-50 text-sky-700 border border-sky-200 text-xs font-bold flex items-center gap-1"><RefreshCw className="w-3.5 h-3.5 animate-spin text-sky-600" /> In Progress</span>;
      case 'Pending':
        return <span className="px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 border border-amber-200 text-xs font-bold flex items-center gap-1"><Clock className="w-3.5 h-3.5 text-amber-600" /> Pending</span>;
      case 'Cancelled':
        return <span className="px-2.5 py-1 rounded-full bg-rose-50 text-rose-700 border border-rose-200 text-xs font-bold flex items-center gap-1"><XCircle className="w-3.5 h-3.5 text-rose-600" /> Cancelled</span>;
      default:
        return null;
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Header & Status Filter Bar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-6 rounded-2xl bg-white border border-slate-200 shadow-xs">
        <div>
          <h3 className="text-xl font-bold text-slate-900 flex items-center gap-2">
            <CalendarCheck className="w-6 h-6 text-amber-500" />
            Booking & Job Dispatching
          </h3>
          <p className="text-xs text-slate-500 mt-1 font-medium">
            Monitor real-time job dispatches, reassign providers in case of no-show, and override job statuses.
          </p>
        </div>

        {/* Status Filter Buttons */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 md:pb-0">
          {['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'].map((status) => (
            <button
              key={status}
              onClick={() => setSelectedStatus(status)}
              className={`px-3.5 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${
                selectedStatus === status
                  ? 'bg-amber-500 text-slate-950 font-bold shadow-xs'
                  : 'bg-slate-100 text-slate-600 hover:text-slate-900 hover:bg-slate-200'
              }`}
            >
              {status}
            </button>
          ))}
        </div>
      </div>

      {/* Search Input */}
      <div className="relative max-w-md">
        <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search booking ID, customer or provider..."
          className="w-full pl-10 pr-4 py-2.5 text-xs bg-white text-slate-900 rounded-xl border border-slate-300 focus:outline-none focus:border-amber-500 shadow-xs placeholder:text-slate-400 font-medium"
        />
      </div>

      {/* Bookings List Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-slate-700">
            <thead className="bg-slate-50 text-slate-600 uppercase font-bold border-b border-slate-200">
              <tr>
                <th className="p-4">ID & Date</th>
                <th className="p-4">Customer</th>
                <th className="p-4">Assigned Provider</th>
                <th className="p-4">Service & Location</th>
                <th className="p-4">Payment Deal</th>
                <th className="p-4">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredBookings.map((b) => (
                <tr key={b.id} className="hover:bg-slate-50 transition-colors">
                  <td className="p-4">
                    <span className="font-mono font-bold text-amber-700 text-sm">{b.id}</span>
                    <span className="text-slate-500 text-[11px] block">{b.date} • {b.time}</span>
                  </td>
                  <td className="p-4">
                    <p className="font-bold text-slate-900 text-sm">{b.customerName}</p>
                    <p className="text-[11px] text-slate-500">{b.customerPhone}</p>
                  </td>
                  <td className="p-4">
                    <p className="font-bold text-amber-700">{b.providerName}</p>
                    <p className="text-[11px] text-slate-500">{b.providerPhone}</p>
                  </td>
                  <td className="p-4">
                    <p className="font-semibold text-slate-800">{b.serviceTitle}</p>
                    <p className="text-[11px] text-slate-500 flex items-center gap-1 mt-0.5">
                      <MapPin className="w-3 h-3 text-slate-400" /> {b.location}
                    </p>
                  </td>
                  <td className="p-4">
                    <span className="font-semibold text-slate-700 text-xs px-2.5 py-1 rounded-lg bg-slate-100 border border-slate-200 inline-block">
                      Direct Agreement
                    </span>
                    <span className="text-slate-400 text-[11px] block mt-0.5">Customer & Provider</span>
                  </td>
                  <td className="p-4">
                    {getStatusBadge(b.status)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default BookingsPage;
