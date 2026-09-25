const express = require('express');
const router = express.Router();
const {
    getAdminStats,
    getAdminUsers,
    getAdminVerifications,
    approveProviderVerification,
    rejectProviderVerification,
    getAdminBookings,
    getAdminReviews,
    deleteAdminReview,
    toggleUserStatus,
    deleteUserAccount,
    broadcastNotification,
    getBroadcastNotifications,
    adminLogin,
    verifyAdminLoginOtp,
    resendAdminLoginOtp,
    sendAdminRegisterOtp,
    registerAdminAccount,
    checkAdminSetupStatus,
    updateAdminProfile,
    sendAdminResetOtp,
    resendAdminResetOtp,
    resetAdminPassword,
    createProviderAccount
} = require('../controllers/adminController');

router.get('/check-setup', checkAdminSetupStatus);
router.post('/login', adminLogin);
router.post('/verify-login-otp', verifyAdminLoginOtp);
router.post('/resend-login-otp', resendAdminLoginOtp);
router.post('/forgot-password', sendAdminResetOtp);
router.post('/resend-reset-otp', resendAdminResetOtp);
router.post('/reset-password', resetAdminPassword);
router.post('/send-otp', sendAdminRegisterOtp);
router.post('/register', registerAdminAccount);
router.put('/profile/:adminId', updateAdminProfile);
router.get('/stats', getAdminStats);
router.get('/users', getAdminUsers);
router.post('/providers/create', createProviderAccount);
router.get('/verifications', getAdminVerifications);
router.post('/verifications/:providerId/approve', approveProviderVerification);
router.post('/verifications/:providerId/reject', rejectProviderVerification);
router.get('/bookings', getAdminBookings);
router.get('/reviews', getAdminReviews);
router.delete('/reviews/:reviewId', deleteAdminReview);
router.post('/users/:userId/toggle-status', toggleUserStatus);
router.delete('/users/:userId', deleteUserAccount);
router.post('/notifications/broadcast', broadcastNotification);
router.get('/notifications/broadcast', getBroadcastNotifications);

module.exports = router;
