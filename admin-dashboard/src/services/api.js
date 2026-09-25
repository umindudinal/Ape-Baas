import axios from 'axios';

const API_BASE = window.location.hostname === 'localhost' ? 'http://localhost:5000/api/admin' : 'https://honda-baas-backend.vercel.app/api/admin';

export const adminLoginApi = async (email, password) => {
  try {
    const res = await axios.post(`${API_BASE}/login`, {
      email,
      password
    });
    if (res.data && res.data.success) {
      if (res.data.require_otp) {
        return {
          success: true,
          require_otp: true,
          email: res.data.email,
          message: res.data.message
        };
      }
      return {
        success: true,
        user: res.data.user,
        token: res.data.token
      };
    } else {
      return {
        success: false,
        message: res.data?.error || 'Admin login failed.'
      };
    }
  } catch (err) {
    const serverMessage = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ API adminLogin error:", serverMessage);
    return {
      success: false,
      message: serverMessage || 'No Admin account found with this email address.'
    };
  }
};

export const verifyAdminLoginOtpApi = async (email, otp_code) => {
  try {
    const res = await axios.post(`${API_BASE}/verify-login-otp`, {
      email,
      otp_code
    });
    if (res.data && res.data.success) {
      return {
        success: true,
        user: res.data.user,
        token: res.data.token,
        message: res.data.message
      };
    } else {
      return {
        success: false,
        message: res.data?.error || 'Login OTP verification failed.'
      };
    }
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ verifyAdminLoginOtpApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Invalid or expired login OTP code.'
    };
  }
};

export const resendAdminLoginOtpApi = async (email) => {
  try {
    const res = await axios.post(`${API_BASE}/resend-login-otp`, { email });
    return {
      success: true,
      message: res.data?.message || 'Login OTP code resent successfully.'
    };
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ resendAdminLoginOtpApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Failed to resend login OTP code.'
    };
  }
};

export const sendAdminForgotPasswordApi = async (email) => {
  try {
    const res = await axios.post(`${API_BASE}/forgot-password`, { email });
    if (res.data && res.data.success) {
      return {
        success: true,
        message: res.data.message || 'Password reset OTP has been sent to your email.'
      };
    }
    return {
      success: false,
      message: res.data?.error || 'Failed to send password reset code.'
    };
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ sendAdminForgotPasswordApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'No administrator account found with this email address.'
    };
  }
};

export const resendAdminResetOtpApi = async (email) => {
  try {
    const res = await axios.post(`${API_BASE}/resend-reset-otp`, { email });
    return {
      success: true,
      message: res.data?.message || 'Password reset code resent successfully.'
    };
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ resendAdminResetOtpApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Failed to resend reset OTP code.'
    };
  }
};

export const resetAdminPasswordApi = async (email, otp_code, new_password) => {
  try {
    const res = await axios.post(`${API_BASE}/reset-password`, {
      email,
      otp_code,
      new_password
    });
    if (res.data && res.data.success) {
      return {
        success: true,
        user: res.data.user,
        token: res.data.token,
        message: res.data.message || 'Password reset successfully!'
      };
    }
    return {
      success: false,
      message: res.data?.error || 'Password reset failed.'
    };
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ resetAdminPasswordApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Password reset failed. Invalid or expired OTP code.'
    };
  }
};

export const updateAdminProfileApi = async (adminId, profileData) => {
  try {
    const res = await axios.put(`${API_BASE}/profile/${adminId}`, profileData);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API updateAdminProfile error:", err.message);
    return { success: false, message: err.message };
  }
};

export const checkAdminSetupApi = async () => {
  try {
    const res = await axios.get(`${API_BASE}/check-setup`);
    if (res.data && res.data.success) {
      return res.data.hasAdmin;
    }
  } catch (err) {
    console.warn("⚠️ API checkAdminSetup error:", err.message);
  }
  return false;
};

export const sendAdminOtpApi = async (email, fullName) => {
  try {
    const res = await axios.post(`${API_BASE}/send-otp`, {
      email,
      full_name: fullName
    });
    return {
      success: true,
      message: res.data?.message || 'OTP code sent successfully to your email!'
    };
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ sendAdminOtpApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Failed to send OTP code to email address.'
    };
  }
};

export const registerAdminApi = async (adminData) => {
  try {
    const res = await axios.post(`${API_BASE}/register`, adminData);
    if (res.data && res.data.success) {
      return {
        success: true,
        user: res.data.user,
        token: res.data.token,
        message: res.data.message || 'Super Admin registered & verified successfully!'
      };
    } else {
      return {
        success: false,
        message: res.data?.error || 'Admin registration failed.'
      };
    }
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ registerAdminApi error:", errorMsg);
    return {
      success: false,
      message: errorMsg || 'Admin registration failed.'
    };
  }
};

export const fetchAdminStats = async () => {
  try {
    const res = await axios.get(`${API_BASE}/stats`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchAdminStats error:", err.message);
  }
  return null;
};

export const fetchAdminUsers = async () => {
  try {
    const res = await axios.get(`${API_BASE}/users`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchAdminUsers error:", err.message);
  }
  return [];
};

export const fetchAdminVerifications = async () => {
  try {
    const res = await axios.get(`${API_BASE}/verifications`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchAdminVerifications error:", err.message);
  }
  return [];
};

export const approveProviderApi = async (providerId) => {
  try {
    const res = await axios.post(`${API_BASE}/verifications/${providerId}/approve`);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API approveProvider error:", err.message);
    return { success: false, message: err.message };
  }
};

export const rejectProviderApi = async (providerId, reason) => {
  try {
    const res = await axios.post(`${API_BASE}/verifications/${providerId}/reject`, { reason });
    return res.data;
  } catch (err) {
    console.warn("⚠️ API rejectProvider error:", err.message);
    return { success: false, message: err.message };
  }
};

export const fetchAdminBookings = async () => {
  try {
    const res = await axios.get(`${API_BASE}/bookings`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchAdminBookings error:", err.message);
  }
  return [];
};

export const fetchAdminReviews = async () => {
  try {
    const res = await axios.get(`${API_BASE}/reviews`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchAdminReviews error:", err.message);
  }
  return [];
};

export const deleteAdminReviewApi = async (reviewId) => {
  try {
    const res = await axios.delete(`${API_BASE}/reviews/${reviewId}`);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API deleteAdminReview error:", err.message);
    return { success: false, message: err.message };
  }
};

export const deleteUserApi = async (userId) => {
  try {
    const res = await axios.delete(`${API_BASE}/users/${userId}`);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API deleteUser error:", err.message);
    return { success: false, message: err.message };
  }
};

export const deleteProviderApi = async (providerId) => {
  return deleteUserApi(providerId);
};

// --- Category Management APIs ---
const CATEGORY_API = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
  ? 'http://localhost:5000/api/categories'
  : `http://${window.location.hostname}:5000/api/categories`;

export const fetchCategoriesApi = async () => {
  try {
    const res = await axios.get(CATEGORY_API);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchCategories error:", err.message);
  }
  return null;
};

export const createCategoryApi = async (categoryData) => {
  try {
    const res = await axios.post(CATEGORY_API, categoryData);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API createCategory error:", err.message);
    return { success: false, message: err.message };
  }
};

export const updateCategoryApi = async (categoryId, categoryData) => {
  try {
    const res = await axios.put(`${CATEGORY_API}/${categoryId}`, categoryData);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API updateCategory error:", err.message);
    return { success: false, message: err.message };
  }
};

export const toggleCategoryStatusApi = async (categoryId) => {
  try {
    const res = await axios.patch(`${CATEGORY_API}/${categoryId}/toggle-status`);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API toggleCategoryStatus error:", err.message);
    return { success: false, message: err.message };
  }
};

export const deleteCategoryApi = async (categoryId) => {
  try {
    const res = await axios.delete(`${CATEGORY_API}/${categoryId}`);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API deleteCategory error:", err.message);
    return { success: false, message: err.message };
  }
};

export const fetchBroadcastsApi = async () => {
  try {
    const res = await axios.get(`${API_BASE}/notifications/broadcast`);
    if (res.data && res.data.success) {
      return res.data.data;
    }
  } catch (err) {
    console.warn("⚠️ API fetchBroadcasts error:", err.message);
  }
  return null;
};

export const sendBroadcastApi = async (broadcastData) => {
  try {
    const res = await axios.post(`${API_BASE}/notifications/broadcast`, broadcastData);
    return res.data;
  } catch (err) {
    console.warn("⚠️ API sendBroadcast error:", err.message);
    return { success: false, message: err.message };
  }
};

export const createProviderApi = async (providerData) => {
  try {
    const res = await axios.post(`${API_BASE}/providers/create`, providerData);
    return res.data;
  } catch (err) {
    const errorMsg = err.response?.data?.error || err.response?.data?.message || err.message;
    console.warn("⚠️ API createProvider error:", errorMsg);
    return { success: false, error: errorMsg || 'Failed to create provider account.' };
  }
};

