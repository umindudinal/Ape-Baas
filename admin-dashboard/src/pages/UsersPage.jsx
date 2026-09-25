import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import { 
  Users, 
  UserCheck, 
  ShieldAlert, 
  CheckCircle2, 
  XCircle, 
  Eye, 
  Search, 
  Lock, 
  Unlock, 
  Trash2,
  UserPlus
} from 'lucide-react';
import ProviderDetailsModal from '../components/ProviderDetailsModal';
import CustomerDetailsModal from '../components/CustomerDetailsModal';
import AddProviderModal from '../components/AddProviderModal';

function renderUserAvatar(user, sizeClass = "w-9 h-9") {
  const avatarSrc = user?.avatar || user?.profile_image_url || user?.profile_picture;
  
  if (avatarSrc && avatarSrc.trim() !== '') {
    let src = avatarSrc;
    if (!src.startsWith('http') && !src.startsWith('data:image')) {
      src = `data:image/jpeg;base64,${src}`;
    }
    return (
      <img
        src={src}
        alt={user.name || 'User'}
        className={`${sizeClass} rounded-full object-cover border border-amber-500/30 shrink-0 shadow-sm`}
        onError={(e) => {
          e.target.onerror = null;
          e.target.style.display = 'none';
          if (e.target.nextSibling) e.target.nextSibling.style.display = 'flex';
        }}
      />
    );
  }
  
  return (
    <div className={`${sizeClass} rounded-full bg-amber-500/15 text-amber-300 border border-amber-500/30 flex items-center justify-center font-bold text-xs shrink-0 uppercase shadow-sm`}>
      {user?.initials || (user?.name || 'US').split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
    </div>
  );
}

function renderCategoryList(categoryData, isBadgeStyle = true) {
  if (!categoryData) return <span className="text-slate-400 text-xs">-</span>;

  let categories = [];
  if (Array.isArray(categoryData)) {
    categories = categoryData;
  } else if (typeof categoryData === 'string') {
    categories = categoryData.split(',').map(c => c.trim()).filter(Boolean);
  } else {
    categories = [String(categoryData)];
  }

  if (categories.length === 0) return <span className="text-slate-400 text-xs">-</span>;

  return (
    <div className="flex flex-col gap-1.5 items-start">
      {categories.map((cat, index) => (
        <span 
          key={index} 
          className={
            isBadgeStyle 
              ? "px-2.5 py-1 rounded-lg bg-slate-100 border border-slate-200 text-slate-800 text-xs font-semibold shadow-xs whitespace-nowrap"
              : "px-2.5 py-0.5 rounded bg-amber-50 text-amber-800 text-xs font-bold whitespace-nowrap border border-amber-200"
          }
        >
          {cat}
        </span>
      ))}
    </div>
  );
}


const UsersPage = ({ 
  users, 
  verifications, 
  categories = [],
  onApproveProvider, 
  onRejectProvider, 
  onToggleUserStatus, 
  onDeleteUser,
  onAddProvider
}) => {
  const [activeSubTab, setActiveSubTab] = useState('verifications'); // 'verifications' | 'providers' | 'customers'
  const [searchFilter, setSearchFilter] = useState('');
  const [selectedDoc, setSelectedDoc] = useState(null); // Document Lightbox Modal
  const [selectedProvider, setSelectedProvider] = useState(null); // Provider Full Details Modal
  const [selectedCustomer, setSelectedCustomer] = useState(null); // Customer Full Details Modal
  const [showAddProviderModal, setShowAddProviderModal] = useState(false); // Add Provider Modal
  const [rejectReason, setRejectReason] = useState('');
  const [showRejectModal, setShowRejectModal] = useState(null);

  const pendingVerifications = verifications.filter(v => v.status === 'Pending');
  const rejectedVerifications = verifications.filter(v => v.status === 'Rejected');
  const providersList = users.filter(u => u.role === 'Provider' && (u.verified === true || u.status === 'Active'));
  const customersList = users.filter(u => u.role === 'Customer');

  const filteredProviders = providersList.filter(u => 
    u.name.toLowerCase().includes(searchFilter.toLowerCase()) || 
    (u.category && u.category.toLowerCase().includes(searchFilter.toLowerCase())) ||
    (u.phone && u.phone.includes(searchFilter))
  );

  const filteredCustomers = customersList.filter(u => 
    u.name.toLowerCase().includes(searchFilter.toLowerCase()) || 
    u.email.toLowerCase().includes(searchFilter.toLowerCase()) ||
    (u.phone && u.phone.includes(searchFilter))
  );

  const filteredRejected = rejectedVerifications.filter(v => 
    (v.providerName && v.providerName.toLowerCase().includes(searchFilter.toLowerCase())) || 
    (v.service && v.service.toLowerCase().includes(searchFilter.toLowerCase())) ||
    (v.phone && v.phone.includes(searchFilter))
  );

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Sub Tabs Navigation */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-2 rounded-2xl border border-slate-200 shadow-xs">
        <div className="flex items-center gap-2 flex-wrap sm:flex-nowrap">
          <button
            onClick={() => setActiveSubTab('verifications')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 ${
              activeSubTab === 'verifications'
                ? 'bg-amber-500 text-slate-950 shadow-xs font-black'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <ShieldAlert className="w-4 h-4" />
            <span>Pending Verifications</span>
            {pendingVerifications.length > 0 && (
              <span className={`px-2 py-0.5 rounded-full text-[10px] font-extrabold ${
                activeSubTab === 'verifications'
                  ? 'bg-slate-950 text-amber-300'
                  : 'bg-amber-100 text-amber-800'
              }`}>
                {pendingVerifications.length}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveSubTab('providers')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 ${
              activeSubTab === 'providers'
                ? 'bg-amber-500 text-slate-950 shadow-xs font-black'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <UserCheck className="w-4 h-4" />
            <span>Approved Providers</span>
            <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
              activeSubTab === 'providers' ? 'bg-slate-950 text-amber-300' : 'bg-slate-100 text-slate-700'
            }`}>
              {providersList.length}
            </span>
          </button>

          <button
            onClick={() => setActiveSubTab('rejected')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 ${
              activeSubTab === 'rejected'
                ? 'bg-rose-600 text-white shadow-sm font-black'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <XCircle className="w-4 h-4 text-rose-500" />
            <span>Rejected Providers</span>
            <span className="px-2 py-0.5 rounded-full bg-slate-100 text-slate-700 text-[10px] font-bold">
              {rejectedVerifications.length}
            </span>
          </button>

          <button
            onClick={() => setActiveSubTab('customers')}
            className={`px-4 py-2.5 rounded-xl font-semibold text-xs transition-all flex items-center gap-2 ${
              activeSubTab === 'customers'
                ? 'bg-amber-500 text-slate-950 shadow-xs font-black'
                : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'
            }`}
          >
            <Users className="w-4 h-4" />
            <span>All Customers</span>
            <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold ${
              activeSubTab === 'customers' ? 'bg-slate-950 text-amber-300' : 'bg-slate-100 text-slate-700'
            }`}>
              {customersList.length}
            </span>
          </button>
        </div>

        {/* Search & Actions inside subtab bar */}
        <div className="flex items-center gap-2 w-full sm:w-auto px-2">
          <div className="relative w-full sm:w-60">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchFilter}
              onChange={(e) => setSearchFilter(e.target.value)}
              placeholder="Search by name, phone..."
              className="w-full pl-8 pr-3 py-1.5 text-xs bg-slate-50 text-slate-900 rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 font-medium placeholder:text-slate-400"
            />
          </div>

          <button
            onClick={() => setShowAddProviderModal(true)}
            className="px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center gap-1.5 shadow-sm transition-all cursor-pointer whitespace-nowrap shrink-0"
            title="Add a new service provider directly"
          >
            <UserPlus className="w-4 h-4" />
            <span>+ Add Provider</span>
          </button>
        </div>
      </div>

      {/* SUBTAB 1: PENDING VERIFICATIONS QUEUE */}
      {activeSubTab === 'verifications' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
              <ShieldAlert className="w-5 h-5 text-amber-500" />
              NIC Identity Verification Queue
            </h3>
            <p className="text-xs text-slate-500 font-medium">
              Review photo identity documents before activating provider profile.
            </p>
          </div>

          {pendingVerifications.length === 0 ? (
            <div className="p-12 text-center rounded-2xl bg-white border border-slate-200 shadow-xs">
              <CheckCircle2 className="w-12 h-12 text-emerald-500 mx-auto mb-3" />
              <h4 className="text-base font-bold text-slate-900">
                All pending verifications completed!
              </h4>
              <p className="text-xs text-slate-500 mt-1 font-medium">
                New service providers registering will show up here.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {pendingVerifications.map((item) => (
                <div key={item.id} className="p-6 rounded-2xl bg-white border border-amber-200/80 hover:border-amber-400 transition-all shadow-sm space-y-4">
                  <div className="flex items-start justify-between">
                    <div className="flex items-center gap-3">
                      <img src={item.avatar} alt="Provider Avatar" className="w-12 h-12 rounded-xl object-cover border border-amber-300" />
                      <div>
                        <h4 className="font-bold text-slate-900 text-base leading-tight">{item.providerName}</h4>
                        <div className="mt-1">
                          {renderCategoryList(item.service, false)}
                        </div>
                      </div>
                    </div>
                    <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-amber-50 text-amber-700 border border-amber-200">
                      {item.status}
                    </span>
                  </div>

                  <div className="grid grid-cols-2 gap-2 text-xs text-slate-700 bg-slate-50 p-3 rounded-xl border border-slate-200">
                    <div>
                      <span className="text-slate-500 block">NIC Number:</span>
                      <span className="font-mono font-bold text-slate-900">{item.nicNumber}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block">District/City:</span>
                      <span className="font-semibold text-slate-800">{item.region}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block">Phone:</span>
                      <span className="font-medium text-slate-800">{item.phone}</span>
                    </div>
                    <div>
                      <span className="text-slate-500 block">Submitted:</span>
                      <span className="text-slate-600">{item.submittedDate}</span>
                    </div>
                  </div>

                  {/* Document Thumbnails Lightbox Trigger */}
                  <div className="space-y-2">
                    <label className="text-xs font-semibold text-slate-600 block">Verification Documents:</label>
                    <div className="grid grid-cols-2 gap-3">
                      <div 
                        onClick={() => setSelectedDoc({ title: 'NIC Front Image', url: item.nicFront })}
                        className="relative h-28 rounded-xl overflow-hidden border border-slate-200 cursor-pointer group bg-slate-100"
                      >
                        <img src={item.nicFront} alt="NIC Front" className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                        <div className="absolute inset-0 bg-slate-900/30 group-hover:bg-slate-900/10 transition-colors flex items-center justify-center">
                          <span className="text-[11px] font-bold text-white bg-slate-900/80 px-2.5 py-1 rounded-lg flex items-center gap-1 shadow-sm">
                            <Eye className="w-3 h-3" /> View NIC Front
                          </span>
                        </div>
                      </div>

                      <div 
                        onClick={() => setSelectedDoc({ title: 'NIC Back Image', url: item.nicBack })}
                        className="relative h-28 rounded-xl overflow-hidden border border-slate-200 cursor-pointer group bg-slate-100"
                      >
                        <img src={item.nicBack} alt="NIC Back" className="w-full h-full object-cover group-hover:scale-105 transition-transform" />
                        <div className="absolute inset-0 bg-slate-900/30 group-hover:bg-slate-900/10 transition-colors flex items-center justify-center">
                          <span className="text-[11px] font-bold text-white bg-slate-900/80 px-2.5 py-1 rounded-lg flex items-center gap-1 shadow-sm">
                            <Eye className="w-3 h-3" /> View NIC Back
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex items-center gap-3 pt-2">
                    <button
                      onClick={() => onApproveProvider(item.providerId)}
                      className="flex-1 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs flex items-center justify-center gap-2 shadow-xs transition-all cursor-pointer"
                    >
                      <CheckCircle2 className="w-4 h-4" />
                      <span>Approve Provider</span>
                    </button>
                    <button
                      onClick={() => setShowRejectModal(item.providerId)}
                      className="px-4 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 font-bold text-xs flex items-center gap-1 transition-all cursor-pointer"
                    >
                      <XCircle className="w-4 h-4 text-rose-600" />
                      <span>Reject</span>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* SUBTAB 2: APPROVED PROVIDERS TABLE */}
      {activeSubTab === 'providers' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
          <div className="p-4 border-b border-slate-200 flex items-center justify-between flex-wrap gap-3">
            <div>
              <h4 className="font-bold text-slate-900 text-sm">
                Registered Service Providers
              </h4>
              <p className="text-xs text-slate-500 mt-0.5">
                All approved and active service providers in the platform.
              </p>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-xs text-slate-500 font-medium">{filteredProviders.length} Providers Found</span>
              <button
                onClick={() => setShowAddProviderModal(true)}
                className="px-3.5 py-1.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs flex items-center gap-1.5 shadow-xs transition-all cursor-pointer"
              >
                <UserPlus className="w-3.5 h-3.5" />
                <span>+ Add Provider</span>
              </button>
            </div>
          </div>

          {filteredProviders.length === 0 ? (
            <div className="p-12 text-center text-slate-500 text-xs">
              <UserCheck className="w-10 h-10 text-slate-400 mx-auto mb-2 opacity-60" />
              <p className="font-bold text-slate-700">No approved service providers found</p>
              <p className="mt-1">Approving provider requests from the 'Pending Provider Verifications' queue will list them here.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-slate-700">
                <thead className="bg-slate-50 text-slate-600 uppercase font-bold border-b border-slate-200">
                  <tr>
                    <th className="p-4">Provider</th>
                    <th className="p-4">Category</th>
                    <th className="p-4">Region</th>
                    <th className="p-4">Performance</th>
                    <th className="p-4">Status</th>
                    <th className="p-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredProviders.map((prov) => (
                    <tr 
                      key={prov.id} 
                      onClick={() => setSelectedProvider(prov)}
                      className="hover:bg-slate-50 cursor-pointer transition-colors group"
                      title="Click to view all provider details"
                    >
                    <td className="p-4 flex items-center gap-3">
                      {renderUserAvatar(prov, "w-9 h-9")}
                      <div>
                        <p className="font-bold text-slate-900 text-sm group-hover:text-amber-600 transition-colors flex items-center gap-1.5">
                          <span>{prov.name}</span>
                          <Eye className="w-3.5 h-3.5 text-amber-500 opacity-0 group-hover:opacity-100 transition-opacity shrink-0" />
                        </p>
                        <p className="text-[11px] text-slate-500">{prov.phone} • {prov.email}</p>
                      </div>
                    </td>
                    <td className="p-4 font-medium text-slate-800">
                      {renderCategoryList(prov.category, true)}
                    </td>
                    <td className="p-4 text-slate-700 font-medium">{prov.region}</td>
                    <td className="p-4">
                      <span className="text-amber-500 font-bold">
                        ★ {Number(prov.rating) > 0 ? Number(prov.rating).toFixed(1) : 'New'}
                      </span>
                      <span className="text-slate-500 text-[11px] block">{prov.jobsCompleted || 0} Jobs Done</span>
                    </td>
                    <td className="p-4">
                      <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold border ${
                        prov.status === 'Active' 
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : 'bg-rose-50 text-rose-700 border-rose-200'
                      }`}>
                        {prov.status}
                      </span>
                    </td>
                    <td className="p-4 text-right space-x-2">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onToggleUserStatus(prov.id);
                        }}
                        className={`p-1.5 rounded-lg border text-xs font-semibold transition-all cursor-pointer ${
                          prov.status === 'Active'
                            ? 'bg-rose-50 text-rose-700 border-rose-200 hover:bg-rose-100'
                            : 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                        }`}
                        title={prov.status === 'Active' ? 'Suspend Account' : 'Activate Account'}
                      >
                        {prov.status === 'Active' ? <Lock className="w-4 h-4" /> : <Unlock className="w-4 h-4" />}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          )}
        </div>
      )}

      {/* SUBTAB 3: REJECTED PROVIDERS TABLE */}
      {activeSubTab === 'rejected' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
          <div className="p-4 border-b border-slate-200 flex items-center justify-between">
            <div>
              <h4 className="font-bold text-slate-900 text-sm flex items-center gap-2">
                <XCircle className="w-4 h-4 text-rose-500" />
                Rejected Provider Applications
              </h4>
              <p className="text-xs text-slate-500 mt-0.5">
                List of service provider applications rejected during document verification.
              </p>
            </div>
            <span className="text-xs text-slate-500 font-medium">{filteredRejected.length} Rejected Found</span>
          </div>

          {filteredRejected.length === 0 ? (
            <div className="p-12 text-center text-slate-500 text-xs">
              <XCircle className="w-10 h-10 text-slate-400 mx-auto mb-2 opacity-60" />
              <p className="font-bold text-slate-700">No rejected provider applications</p>
              <p className="mt-1">Applications rejected by administrators will appear here for review or re-approval.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs text-slate-700">
                <thead className="bg-slate-50 text-slate-600 uppercase font-bold border-b border-slate-200">
                  <tr>
                    <th className="p-4">Provider</th>
                    <th className="p-4">Category</th>
                    <th className="p-4">Region / Contact</th>
                    <th className="p-4">Rejection Reason</th>
                    <th className="p-4">Status</th>
                    <th className="p-4 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {filteredRejected.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50 transition-colors">
                      <td className="p-4 flex items-center gap-3">
                        {renderUserAvatar(item, "w-9 h-9")}
                        <div>
                          <p className="font-bold text-slate-900 text-sm">{item.providerName}</p>
                          <p className="text-[11px] text-slate-500">{item.email || item.phone}</p>
                        </div>
                      </td>
                      <td className="p-4 font-medium text-slate-800">
                        {renderCategoryList(item.service, true)}
                      </td>
                      <td className="p-4 text-slate-700">
                        <p className="font-semibold">{item.region}</p>
                        <p className="text-[11px] text-slate-500">{item.phone}</p>
                      </td>
                      <td className="p-4">
                        <span className="px-2.5 py-1 rounded-lg bg-rose-50 text-rose-700 border border-rose-200 font-medium">
                          {item.rejectionReason || 'Document verification declined'}
                        </span>
                      </td>
                      <td className="p-4">
                        <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                          {item.status}
                        </span>
                      </td>
                      <td className="p-4 text-right">
                        <button
                          onClick={() => onApproveProvider(item.providerId)}
                          className="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs inline-flex items-center gap-1.5 shadow-xs transition-all cursor-pointer"
                          title="Re-approve this provider"
                        >
                          <CheckCircle2 className="w-3.5 h-3.5" />
                          <span>Re-Approve</span>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* SUBTAB 4: CUSTOMERS TABLE */}
      {activeSubTab === 'customers' && (
        <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
          <div className="p-4 border-b border-slate-200 flex items-center justify-between">
            <h4 className="font-bold text-slate-900 text-sm">
              Registered Platform Customers
            </h4>
            <span className="text-xs text-slate-500 font-medium">{filteredCustomers.length} Customers Found</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-slate-700">
              <thead className="bg-slate-50 text-slate-600 uppercase font-bold border-b border-slate-200">
                <tr>
                  <th className="p-4">Customer</th>
                  <th className="p-4">Contact</th>
                  <th className="p-4">Region</th>
                  <th className="p-4">Total Bookings</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-right">Control</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredCustomers.map((cust) => (
                  <tr 
                    key={cust.id} 
                    onClick={() => setSelectedCustomer(cust)}
                    className="hover:bg-slate-50 cursor-pointer transition-colors group"
                    title="Click to view all customer details"
                  >
                    <td className="p-4 flex items-center gap-3">
                      {renderUserAvatar(cust, "w-9 h-9")}
                      <div>
                        <p className="font-bold text-slate-900 text-sm group-hover:text-amber-600 transition-colors flex items-center gap-1.5">
                          <span>{cust.name}</span>
                          <Eye className="w-3.5 h-3.5 text-amber-500 opacity-0 group-hover:opacity-100 transition-opacity shrink-0" />
                        </p>
                        <p className="text-[11px] text-slate-500">{cust.joinedDate || 'Customer'}</p>
                      </div>
                    </td>
                    <td className="p-4 text-slate-700">
                      <p className="font-semibold">{cust.phone}</p>
                      <p className="text-[11px] text-slate-500">{cust.email}</p>
                    </td>
                    <td className="p-4 text-slate-700 font-medium">{cust.region}</td>
                    <td className="p-4 font-bold text-amber-600">
                      {cust.totalBookings || 0} {Number(cust.totalBookings) === 1 ? 'Booking' : 'Bookings'}
                    </td>
                    <td className="p-4">
                      <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold border ${
                        cust.status === 'Active' 
                          ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                          : 'bg-rose-50 text-rose-700 border-rose-200'
                      }`}>
                        {cust.status}
                      </span>
                    </td>
                    <td className="p-4 text-right space-x-2">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onToggleUserStatus(cust.id);
                        }}
                        className="px-2.5 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 border border-slate-300 text-xs font-semibold cursor-pointer"
                      >
                        {cust.status === 'Active' ? 'Suspend' : 'Activate'}
                      </button>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onDeleteUser(cust.id);
                        }}
                        className="p-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-700 border border-rose-200 cursor-pointer"
                        title="Remove Account"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* DOCUMENT LIGHTBOX MODAL */}
      {selectedDoc && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[9999] animate-in fade-in">
          <div className="bg-white border border-slate-200 rounded-3xl max-w-2xl w-full p-6 space-y-4 shadow-2xl">
            <div className="flex items-center justify-between border-b border-slate-200 pb-3">
              <h4 className="font-bold text-slate-900 text-base">{selectedDoc.title}</h4>
              <button 
                onClick={() => setSelectedDoc(null)}
                className="p-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 cursor-pointer"
              >
                ✕
              </button>
            </div>
            <div className="rounded-2xl overflow-hidden border border-slate-200 bg-slate-50 max-h-[70vh] flex items-center justify-center p-2">
              <img src={selectedDoc.url} alt="Document" className="max-h-[65vh] w-auto object-contain rounded-lg" />
            </div>
            <div className="text-right">
              <button 
                onClick={() => setSelectedDoc(null)}
                className="px-5 py-2 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold text-xs shadow-xs cursor-pointer"
              >
                Close Viewer
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* REJECT MODAL */}
      {showRejectModal && createPortal(
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 z-[9999] animate-in fade-in">
          <div className="bg-white border border-slate-200 rounded-3xl max-w-md w-full p-6 space-y-4 shadow-2xl">
            <h4 className="font-bold text-slate-900 text-base">
              Reason for Rejecting Provider Verification
            </h4>
            <textarea
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              placeholder="e.g. NIC document image is unreadable or blurry..."
              className="w-full p-3 bg-slate-50 text-slate-900 border border-slate-300 rounded-xl text-xs focus:outline-none focus:border-rose-500 focus:bg-white h-28 font-medium"
            />
            <div className="flex items-center justify-end gap-3">
              <button
                onClick={() => setShowRejectModal(null)}
                className="px-4 py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold cursor-pointer"
              >
                Cancel
              </button>
              <button
                onClick={() => {
                  onRejectProvider(showRejectModal, rejectReason);
                  setShowRejectModal(null);
                  setRejectReason('');
                }}
                className="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white font-bold text-xs cursor-pointer shadow-sm shadow-rose-600/20"
              >
                Confirm Rejection
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* PROVIDER DETAILS MODAL */}
      <ProviderDetailsModal
        isOpen={!!selectedProvider}
        onClose={() => setSelectedProvider(null)}
        provider={selectedProvider}
        onToggleUserStatus={onToggleUserStatus}
        onApproveProvider={onApproveProvider}
        onDeleteUser={onDeleteUser}
      />

      {/* CUSTOMER DETAILS MODAL */}
      <CustomerDetailsModal
        isOpen={!!selectedCustomer}
        onClose={() => setSelectedCustomer(null)}
        customer={selectedCustomer}
        onToggleUserStatus={onToggleUserStatus}
        onDeleteUser={onDeleteUser}
      />

      {/* ADD PROVIDER MODAL */}
      <AddProviderModal
        isOpen={showAddProviderModal}
        onClose={() => setShowAddProviderModal(false)}
        categories={categories}
        onProviderCreated={(newProvider) => {
          if (onAddProvider) {
            onAddProvider(newProvider);
          }
        }}
      />
    </div>
  );
};

export default UsersPage;
