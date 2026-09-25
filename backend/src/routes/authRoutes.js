const express = require('express');
const {
    registerUser,
    loginUser,
    googleLogin,
    getUserProfile,
    updateUserProfile,
    changePassword,
    sendRegisterOtp,
    verifyOtpAndRegister,
    updateFcmToken,
    sendForgotOtp,
    resendForgotOtp,
    resetPasswordWithOtp
} = require('../controllers/authController');

const router = express.Router();

// ලියාපදිංචි වීම සඳහා OTP යැවීම (POST Request)
router.post('/send-otp', sendRegisterOtp);

// OTP තහවුරු කර ලියාපදිංචි වීම (POST Request)
router.post('/verify-and-register', verifyOtpAndRegister);

// මුරපදය අමතක වූ විට OTP යැවීම (POST Request)
router.post('/forgot-password', sendForgotOtp);

// මුරපදය අමතක වූ විට OTP නැවත යැවීම (POST Request)
router.post('/resend-forgot-otp', resendForgotOtp);

// OTP මගින් මුරපදය නැවත සකස් කිරීම (POST Request)
router.post('/reset-password', resetPasswordWithOtp);

// කෙලින්ම ලියාපදිංචි වීම සඳහා (POST Request)
router.post('/register', registerUser);

// ලොග් වීම සඳහා (POST Request)
router.post('/login', loginUser);

// Google Sign-In මගින් ලොග් වීම සඳහා (POST Request)
router.post('/google-login', googleLogin);

// Profile තොරතුරු ලබා ගැනීම සඳහා (GET Request)
router.get('/profile/:userId', getUserProfile);

// Profile තොරතුරු යාවත්කාලීන කිරීම සඳහා (PUT Request)
router.put('/profile/update', updateUserProfile);

// මුරපදය වෙනස් කිරීම සඳහා (POST Request)
router.post('/change-password', changePassword);

// FCM Device Token යාවත්කාලීන කිරීම සඳහා (POST Request)
router.post('/update-fcm-token', updateFcmToken);

module.exports = router;