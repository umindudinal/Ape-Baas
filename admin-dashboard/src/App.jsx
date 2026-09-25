import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import AdminProfileModal from './components/AdminProfileModal';

import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import UsersPage from './pages/UsersPage';
import CategoriesPage from './pages/CategoriesPage';
import BookingsPage from './pages/BookingsPage';
import ReviewsPage from './pages/ReviewsPage';
import NotificationsPage from './pages/NotificationsPage';

import { 
  fetchAdminStats, 
  fetchAdminUsers, 
  fetchAdminVerifications, 
  fetchAdminBookings,
  fetchAdminReviews,
  deleteAdminReviewApi,
  approveProviderApi,
  rejectProviderApi,
  fetchCategoriesApi,
  createCategoryApi,
  updateCategoryApi,
  toggleCategoryStatusApi,
  deleteCategoryApi,
  fetchBroadcastsApi,
  sendBroadcastApi
} from './services/api';

function App() {
  // Authentication State
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    return localStorage.getItem('admin_authenticated') === 'true';
  });
  const [currentUser, setCurrentUser] = useState(() => {
    const saved = localStorage.getItem('admin_user_data');
    return saved ? JSON.parse(saved) : null;
  });

  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);

  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(() => {
    return localStorage.getItem('admin_sidebar_collapsed') === 'true';
  });

  const toggleSidebar = () => {
    setIsSidebarCollapsed(prev => {
      const next = !prev;
      localStorage.setItem('admin_sidebar_collapsed', String(next));
      return next;
    });
  };

  const [activeTab, setActiveTab] = useState(() => {
    return localStorage.getItem('admin_active_tab') || 'analytics';
  });
  const [searchQuery, setSearchQuery] = useState('');
  const [toastMessage, setToastMessage] = useState(null);

  // Application State - Fully connected to Supabase backend API
  const [categories, setCategories] = useState([]);
  const [verifications, setVerifications] = useState([]);
  const [users, setUsers] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [reviews, setReviews] = useState([]);
  const [disputes, setDisputes] = useState([]);
  const [notifications, setNotifications] = useState([]);

  // Backend Stats
  const [backendStats, setBackendStats] = useState(null);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 4000);
  };

  const handleLoginSuccess = (userData, rememberMe) => {
    setIsAuthenticated(true);
    setCurrentUser(userData);
    if (rememberMe) {
      localStorage.setItem('admin_authenticated', 'true');
      localStorage.setItem('admin_user_data', JSON.stringify(userData));
    }
    showToast('👋 Welcome back, Super Admin!');
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setCurrentUser(null);
    localStorage.removeItem('admin_authenticated');
    localStorage.removeItem('admin_user_data');
    showToast('🔒 Logged out successfully.');
  };

  // Persist active tab to localStorage so F5 refresh stays on current page
  useEffect(() => {
    if (isAuthenticated) {
      localStorage.setItem('admin_active_tab', activeTab);
    }
  }, [activeTab, isAuthenticated]);

  // Load real API data from backend database with 5s real-time live updates
  useEffect(() => {
    async function loadBackendData() {
      const statsData = await fetchAdminStats();
      if (statsData) setBackendStats(statsData);

      const usersData = await fetchAdminUsers();
      if (usersData !== null) {
        setUsers(usersData);
      }

      const verificationsData = await fetchAdminVerifications();
      if (verificationsData !== null) {
        setVerifications(verificationsData);
      }

      const bookingsData = await fetchAdminBookings();
      if (bookingsData !== null) {
        setBookings(bookingsData);
      }

      const reviewsData = await fetchAdminReviews();
      if (reviewsData !== null) {
        setReviews(reviewsData);
      }

      const categoriesData = await fetchCategoriesApi();
      if (categoriesData && categoriesData.length > 0) {
        setCategories(prev => {
          // Merge API data with any local newly created categories
          const newLocalCats = prev.filter(p => !categoriesData.some(c => c.id === p.id || c.nameEn === p.nameEn));
          return [...newLocalCats, ...categoriesData];
        });
      }

      const broadcastsData = await fetchBroadcastsApi();
      if (broadcastsData && broadcastsData.length > 0) {
        setNotifications(broadcastsData.map(b => ({
          id: b.id,
          title: b.title,
          message: b.message,
          target: b.target,
          sentAt: b.created_at ? new Date(b.created_at).toLocaleString() : new Date().toLocaleString(),
          status: 'Delivered'
        })));
      }
    }

    loadBackendData();

    // Real-time background sync every 5 seconds
    const liveInterval = setInterval(() => {
      loadBackendData();
    }, 5000);

    return () => clearInterval(liveInterval);
  }, []);

  // --- Handlers for User Management ---
  const handleApproveProvider = async (providerId) => {
    await approveProviderApi(providerId);

    setVerifications(prev => prev.map(v => v.providerId === providerId ? { ...v, status: 'Approved' } : v));
    setUsers(prev => prev.map(u => u.id === providerId ? { ...u, status: 'Active', verified: true } : u));
    
    showToast('✅ Provider verification approved successfully!');
  };

  const handleRejectProvider = async (providerId, reason) => {
    await rejectProviderApi(providerId, reason);

    setVerifications(prev => prev.map(v => v.providerId === providerId ? { ...v, status: 'Rejected', rejectionReason: reason } : v));
    setUsers(prev => prev.map(u => u.id === providerId ? { ...u, status: 'Rejected', rejectionReason: reason } : u));
    showToast('⚠️ Provider verification request rejected.');
  };

  const handleToggleUserStatus = (userId) => {
    setUsers(prev => prev.map(u => {
      if (u.id === userId) {
        const nextStatus = u.status === 'Active' ? 'Blocked' : 'Active';
        showToast(`User account status updated to ${nextStatus}.`);
        return { ...u, status: nextStatus };
      }
      return u;
    }));
  };

  const handleDeleteUser = (userId) => {
    setUsers(prev => prev.filter(u => u.id !== userId));
    showToast('User account removed successfully.');
  };

  const handleProviderAdded = (newProvider) => {
    if (newProvider) {
      setUsers(prev => [newProvider, ...prev.filter(u => u.id !== newProvider.id)]);
      showToast(`🎉 Provider '${newProvider.name}' successfully registered!`);
    }
  };

  // --- Handlers for Category Management ---
  const handleAddCategory = async (newCat) => {
    setCategories(prev => [newCat, ...prev]);
    showToast(`🎉 New service category '${newCat.nameEn}' created.`);
    const res = await createCategoryApi(newCat);
    if (res && res.success && res.data) {
      setCategories(prev => prev.map(c => c.id === newCat.id ? { ...c, ...res.data } : c));
    }
  };

  const handleToggleCategoryStatus = async (catId) => {
    setCategories(prev => prev.map(c => {
      if (c.id === catId) {
        const newStatus = c.status === 'Active' ? 'Hidden' : 'Active';
        showToast(`Category status set to ${newStatus}.`);
        return { ...c, status: newStatus };
      }
      return c;
    }));
    await toggleCategoryStatusApi(catId);
  };

  const handleEditCategory = async (catId, updatedData) => {
    setCategories(prev => prev.map(c => c.id === catId ? { ...c, ...updatedData } : c));
    showToast('Service category details updated.');
    await updateCategoryApi(catId, updatedData);
  };

  const handleDeleteCategory = async (catId) => {
    setCategories(prev => prev.filter(c => c.id !== catId));
    showToast('🗑️ Service category deleted successfully.');
    await deleteCategoryApi(catId);
  };

  // --- Handlers for Booking Management ---
  const handleUpdateBookingStatus = (bookingId, newStatus) => {
    setBookings(prev => prev.map(b => b.id === bookingId ? { ...b, status: newStatus } : b));
    showToast(`Booking ${bookingId} status updated to ${newStatus}.`);
  };

  const handleReassignProvider = (bookingId, newProviderName, newProviderPhone) => {
    setBookings(prev => prev.map(b => b.id === bookingId ? { ...b, providerName: newProviderName, providerPhone: newProviderPhone, status: 'In Progress' } : b));
    showToast(`Booking ${bookingId} reassigned to ${newProviderName}!`);
  };

  // --- Handlers for Reviews & Disputes ---
  const handleDeleteReview = async (reviewId) => {
    await deleteAdminReviewApi(reviewId);
    setReviews(prev => prev.filter(r => r.id !== reviewId));
    showToast('Review comment deleted successfully.');
  };

  const handleResolveDispute = (disputeId) => {
    setDisputes(prev => prev.filter(d => d.id !== disputeId));
    showToast('Dispute marked as resolved.');
  };

  // --- Handlers for Notifications ---
  const handleSendNotification = async (newNtf) => {
    await sendBroadcastApi({
      title: newNtf.title,
      message: newNtf.message,
      target: newNtf.target
    });

    const broadcastsData = await fetchBroadcastsApi();
    if (broadcastsData && broadcastsData.length > 0) {
      setNotifications(broadcastsData.map(b => ({
        id: b.id,
        title: b.title,
        message: b.message,
        target: b.target,
        sentAt: b.created_at ? new Date(b.created_at).toLocaleString() : new Date().toLocaleString(),
        status: 'Delivered'
      })));
    } else {
      setNotifications(prev => [newNtf, ...prev]);
    }
    showToast(`🚀 Push broadcast sent to ${newNtf.target}!`);
  };

  const pendingVerificationsCount = verifications.filter(v => v.status === 'Pending').length;

  if (!isAuthenticated) {
    return <LoginPage onLoginSuccess={handleLoginSuccess} />;
  }

  const handleUpdateUser = (updatedUserData) => {
    setCurrentUser(updatedUserData);
    localStorage.setItem('admin_user_data', JSON.stringify(updatedUserData));
    showToast('👤 Admin profile updated successfully!');
  };

  return (
    <div className="flex min-h-screen bg-slate-50 text-slate-900 selection:bg-amber-500 selection:text-white font-sans">
      {/* Toast Notification Container */}
      {toastMessage && (
        <div className="fixed bottom-6 right-6 z-50 px-5 py-3 rounded-2xl bg-amber-500 text-slate-950 font-extrabold text-xs shadow-lg border border-amber-600 animate-in fade-in slide-in-from-bottom-5">
          {toastMessage}
        </div>
      )}

      {/* Admin Profile Modal */}
      <AdminProfileModal
        isOpen={isProfileModalOpen}
        onClose={() => setIsProfileModalOpen(false)}
        currentUser={currentUser}
        onUpdateUser={handleUpdateUser}
        onLogout={handleLogout}
      />

      {/* Left Navigation Sidebar Component */}
      <Sidebar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        pendingVerificationsCount={pendingVerificationsCount}
        categoriesCount={categories.length}
        currentUser={currentUser}
        onLogout={handleLogout}
        onOpenProfile={() => setIsProfileModalOpen(true)}
        isCollapsed={isSidebarCollapsed}
        onToggleCollapse={toggleSidebar}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 transition-all duration-300">
        <Header
          searchQuery={searchQuery}
          setSearchQuery={setSearchQuery}
          pendingVerificationsCount={pendingVerificationsCount}
          activeTab={activeTab}
          categoriesCount={categories.length}
          onLogout={handleLogout}
          isSidebarCollapsed={isSidebarCollapsed}
          onToggleSidebar={toggleSidebar}
        />

        <main className="p-8 max-w-7xl w-full mx-auto space-y-8 flex-1">
          {activeTab === 'analytics' && (
            <DashboardPage stats={backendStats} setActiveTab={setActiveTab} currentUser={currentUser} />
          )}

          {activeTab === 'users' && (
            <UsersPage
              users={users}
              verifications={verifications}
              categories={categories}
              onApproveProvider={handleApproveProvider}
              onRejectProvider={handleRejectProvider}
              onToggleUserStatus={handleToggleUserStatus}
              onDeleteUser={handleDeleteUser}
              onAddProvider={handleProviderAdded}
            />
          )}

          {activeTab === 'categories' && (
            <CategoriesPage
              categories={categories}
              onAddCategory={handleAddCategory}
              onToggleCategoryStatus={handleToggleCategoryStatus}
              onEditCategory={handleEditCategory}
              onDeleteCategory={handleDeleteCategory}
            />
          )}

          {activeTab === 'bookings' && (
            <BookingsPage
              bookings={bookings}
              providers={users.filter(u => u.role === 'Provider')}
              onUpdateBookingStatus={handleUpdateBookingStatus}
              onReassignProvider={handleReassignProvider}
            />
          )}

          {activeTab === 'reviews' && (
            <ReviewsPage
              reviews={reviews}
              disputes={disputes}
              onDeleteReview={handleDeleteReview}
              onResolveDispute={handleResolveDispute}
            />
          )}

          {activeTab === 'notifications' && (
            <NotificationsPage
              notifications={notifications}
              onSendNotification={handleSendNotification}
            />
          )}
        </main>
      </div>
    </div>
  );
}

export default App;
