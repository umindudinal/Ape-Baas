import React, { useState, useEffect, useRef } from 'react';
import { 
  ShieldCheck, 
  Lock, 
  Mail, 
  Eye, 
  EyeOff, 
  ArrowRight, 
  ArrowLeft, 
  AlertCircle, 
  CheckCircle2, 
  User, 
  Phone, 
  UserPlus, 
  KeyRound, 
  RefreshCw,
  Check,
  X,
  Shield
} from 'lucide-react';
import { 
  adminLoginApi, 
  verifyAdminLoginOtpApi,
  resendAdminLoginOtpApi,
  registerAdminApi, 
  checkAdminSetupApi, 
  sendAdminOtpApi,
  sendAdminForgotPasswordApi,
  resendAdminResetOtpApi,
  resetAdminPasswordApi
} from '../services/api';

const LoginPage = ({ onLoginSuccess }) => {
  const [hasAdminExists, setHasAdminExists] = useState(false);
  const [isRegisterMode, setIsRegisterMode] = useState(false);
  const [isForgotMode, setIsForgotMode] = useState(false);
  
  // Registration Step: 1 = Details Form, 2 = 6-Digit OTP Verification
  const [regStep, setRegStep] = useState(1);
  // Login Step: 1 = Credentials Form, 2 = 2FA 6-Digit Login OTP Verification
  const [loginStep, setLoginStep] = useState(1);
  // Forgot Password Step: 1 = Enter Email, 2 = 6-Digit OTP & New Password
  const [forgotStep, setForgotStep] = useState(1);

  // Form State
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);

  // New Password State for Forgot Password
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmNewPassword, setShowConfirmNewPassword] = useState(false);

  // Password Strength Criteria for Registration
  const hasLength = password.length >= 8;
  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasNumber = /\d/.test(password);
  const hasSpecial = /[!@#$%^&*(),.?":{}|<>_\-]/.test(password);
  const strengthScore = [hasLength, hasUpper, hasLower, hasNumber, hasSpecial].filter(Boolean).length;
  const isPasswordStrong = strengthScore === 5;

  // Password Strength Criteria for Forgot Password
  const newHasLength = newPassword.length >= 8;
  const newHasUpper = /[A-Z]/.test(newPassword);
  const newHasLower = /[a-z]/.test(newPassword);
  const newHasNumber = /\d/.test(newPassword);
  const newHasSpecial = /[!@#$%^&*(),.?":{}|<>_\-]/.test(newPassword);
  const newStrengthScore = [newHasLength, newHasUpper, newHasLower, newHasNumber, newHasSpecial].filter(Boolean).length;
  const isNewPasswordStrong = newStrengthScore === 5;

  // OTP State (6 Digits)
  const [otpDigits, setOtpDigits] = useState(['', '', '', '', '', '']);
  const otpInputRefs = useRef([]);
  const [timerCount, setTimerCount] = useState(60);
  const [isResending, setIsResending] = useState(false);

  // Status & Feedback State
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  // Check if any admin already exists in Supabase DB
  useEffect(() => {
    async function checkStatus() {
      const exists = await checkAdminSetupApi();
      setHasAdminExists(exists);
      if (!exists) {
        setIsRegisterMode(true);
      } else {
        setIsRegisterMode(false);
      }
    }
    checkStatus();
  }, []);

  // Countdown timer for OTP resend (Register, Login 2FA, Forgot Password)
  useEffect(() => {
    let interval = null;
    const isWaitingOtp = (isRegisterMode && regStep === 2) || (!isRegisterMode && !isForgotMode && loginStep === 2) || (isForgotMode && forgotStep === 2);
    if (isWaitingOtp && timerCount > 0) {
      interval = setInterval(() => {
        setTimerCount((prev) => prev - 1);
      }, 1000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isRegisterMode, regStep, loginStep, isForgotMode, forgotStep, timerCount]);

  // Handle OTP 6-Digit Input changes
  const handleOtpChange = (index, value) => {
    if (!/^\d*$/.test(value)) return;

    const newDigits = [...otpDigits];
    newDigits[index] = value.slice(-1); // Take only single digit
    setOtpDigits(newDigits);

    // Auto-focus to next box if digit entered
    if (value && index < 5) {
      otpInputRefs.current[index + 1]?.focus();
    }
  };

  // Handle Backspace navigation in OTP
  const handleOtpKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !otpDigits[index] && index > 0) {
      otpInputRefs.current[index - 1]?.focus();
    }
  };

  // Handle Paste of complete 6-digit code
  const handleOtpPaste = (e) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData('text').trim();
    if (/^\d{6}$/.test(pastedData)) {
      const digits = pastedData.split('');
      setOtpDigits(digits);
      otpInputRefs.current[5]?.focus();
    }
  };

  // Resend OTP Code for Registration
  const handleResendRegisterOtp = async () => {
    if (timerCount > 0 || isResending) return;

    setIsResending(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await sendAdminOtpApi(email.trim(), fullName.trim());
    setIsResending(false);

    if (res.success) {
      setSuccessMessage('🔄 A new verification code (OTP) has been sent to your email address.');
      setTimerCount(60);
      setOtpDigits(['', '', '', '', '', '']);
      otpInputRefs.current[0]?.focus();
    } else {
      setErrorMessage(res.message || 'Failed to resend OTP code.');
    }
  };

  // Resend OTP Code for 2FA Login
  const handleResendLoginOtp = async () => {
    if (timerCount > 0 || isResending) return;

    setIsResending(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await resendAdminLoginOtpApi(email.trim());
    setIsResending(false);

    if (res.success) {
      setSuccessMessage('🔄 A new 2FA login code (OTP) has been sent to your email address.');
      setTimerCount(60);
      setOtpDigits(['', '', '', '', '', '']);
      otpInputRefs.current[0]?.focus();
    } else {
      setErrorMessage(res.message || 'Failed to resend login OTP code.');
    }
  };

  // Step 1: Send OTP to Email for Registration
  const handleSendOtpStep = async (e) => {
    e.preventDefault();
    if (!fullName.trim() || !email.trim() || !password.trim() || !confirmPassword.trim()) {
      setErrorMessage('Please fill in all required fields (Name, Email, Password, Confirm Password).');
      return;
    }

    if (!isPasswordStrong) {
      setErrorMessage('Password must be at least 8 characters long and contain uppercase, lowercase, numbers, and special characters.');
      return;
    }

    if (password !== confirmPassword) {
      setErrorMessage('Passwords do not match. Please re-enter to confirm.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await sendAdminOtpApi(email.trim(), fullName.trim());
    setIsLoading(false);

    if (res.success) {
      setRegStep(2);
      setTimerCount(60);
      setOtpDigits(['', '', '', '', '', '']);
      setSuccessMessage(`✉️ Verification code (OTP) sent to ${email.trim()}. Please check your email inbox.`);
      setTimeout(() => {
        otpInputRefs.current[0]?.focus();
      }, 100);
    } else {
      setErrorMessage(res.message || 'Failed to send email verification code.');
    }
  };

  // Step 2: Verify OTP & Create Admin Account
  const handleVerifyOtpAndRegister = async (e) => {
    e.preventDefault();
    const fullOtp = otpDigits.join('');
    if (fullOtp.length < 6) {
      setErrorMessage('Please enter the full 6-digit OTP code.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await registerAdminApi({
      full_name: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password.trim(),
      otp_code: fullOtp
    });

    setIsLoading(false);

    if (res.success) {
      setSuccessMessage('🎉 Email verified successfully! Super Admin account created.');
      setTimeout(() => {
        onLoginSuccess(res.user, rememberMe);
      }, 1200);
    } else {
      setErrorMessage(res.message || 'Invalid or expired OTP code.');
    }
  };

  // Step 1: Login Credentials Check -> Trigger 2FA Email OTP
  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      setErrorMessage('Please enter your email and password.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await adminLoginApi(email.trim(), password.trim());
    setIsLoading(false);

    if (res.success) {
      if (res.require_otp) {
        setLoginStep(2);
        setTimerCount(60);
        setOtpDigits(['', '', '', '', '', '']);
        setSuccessMessage(`🔐 2FA verification code sent to ${email.trim()}. Please check your inbox.`);
        setTimeout(() => {
          otpInputRefs.current[0]?.focus();
        }, 100);
      } else {
        onLoginSuccess(res.user, rememberMe);
      }
    } else {
      setErrorMessage(res.message || 'Invalid email or password.');
    }
  };

  // Step 2: Verify 2FA Login OTP and Enter Dashboard
  const handleVerifyLoginOtp = async (e) => {
    e.preventDefault();
    const fullOtp = otpDigits.join('');
    if (fullOtp.length < 6) {
      setErrorMessage('Please enter the full 6-digit Login OTP code.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await verifyAdminLoginOtpApi(email.trim(), fullOtp);
    setIsLoading(false);

    if (res.success) {
      setSuccessMessage('🎉 2FA verified successfully! Redirecting to Super Admin Dashboard...');
      setTimeout(() => {
        onLoginSuccess(res.user, rememberMe);
      }, 1000);
    } else {
      setErrorMessage(res.message || 'Invalid or expired Login OTP code.');
    }
  };

  // Step 1: Send Forgot Password OTP to Email
  const handleSendForgotOtpStep = async (e) => {
    e.preventDefault();
    if (!email.trim()) {
      setErrorMessage('Please enter your administrator email address.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await sendAdminForgotPasswordApi(email.trim());
    setIsLoading(false);

    if (res.success) {
      setForgotStep(2);
      setTimerCount(60);
      setOtpDigits(['', '', '', '', '', '']);
      setSuccessMessage(res.message || `✉️ Password recovery OTP sent to ${email.trim()}. Please check your inbox.`);
      setTimeout(() => {
        otpInputRefs.current[0]?.focus();
      }, 100);
    } else {
      setErrorMessage(res.message || 'No administrator account found with this email address.');
    }
  };

  // Resend OTP for Forgot Password
  const handleResendForgotOtp = async () => {
    if (timerCount > 0 || isResending) return;

    setIsResending(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await resendAdminResetOtpApi(email.trim());
    setIsResending(false);

    if (res.success) {
      setSuccessMessage('🔄 A new recovery code (OTP) has been sent to your email.');
      setTimerCount(60);
      setOtpDigits(['', '', '', '', '', '']);
      otpInputRefs.current[0]?.focus();
    } else {
      setErrorMessage(res.message || 'Failed to resend recovery code.');
    }
  };

  // Step 2: Verify OTP and Reset Password
  const handleResetPasswordSubmit = async (e) => {
    e.preventDefault();
    const fullOtp = otpDigits.join('');
    if (fullOtp.length < 6) {
      setErrorMessage('Please enter the complete 6-digit recovery code.');
      return;
    }

    if (!newPassword.trim() || !confirmNewPassword.trim()) {
      setErrorMessage('Please enter and confirm your new password.');
      return;
    }

    if (!isNewPasswordStrong) {
      setErrorMessage('New password must be at least 8 characters long and contain uppercase, lowercase, numbers, and special characters.');
      return;
    }

    if (newPassword !== confirmNewPassword) {
      setErrorMessage('New passwords do not match. Please re-enter to confirm.');
      return;
    }

    setIsLoading(true);
    setErrorMessage('');
    setSuccessMessage('');

    const res = await resetAdminPasswordApi(email.trim(), fullOtp, newPassword.trim());
    setIsLoading(false);

    if (res.success) {
      setSuccessMessage('🎉 Password reset successfully! Redirecting to Super Admin Dashboard...');
      setTimeout(() => {
        if (res.user) {
          onLoginSuccess(res.user, rememberMe);
        } else {
          setIsForgotMode(false);
          setForgotStep(1);
          setLoginStep(1);
          setPassword('');
        }
      }, 1200);
    } else {
      setErrorMessage(res.message || 'Invalid or expired recovery code.');
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-4 relative overflow-hidden selection:bg-amber-500 selection:text-slate-950">
      {/* Subtle Background Glow Elements */}
      <div className="absolute -top-40 -left-40 w-96 h-96 bg-amber-500/10 rounded-full blur-3xl pointer-events-none"></div>
      <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl pointer-events-none"></div>

      <div className="w-full max-w-md relative z-10 animate-in fade-in zoom-in-95 duration-500">
        {/* Header Branding */}
        <div className="text-center mb-6">
          <div className="inline-block relative mb-3">
            <img 
              src="/logo.png" 
              alt="Ape Baas Logo" 
              className="w-20 h-20 rounded-2xl object-contain shadow-lg shadow-amber-500/20 border-2 border-amber-500/40 p-1 bg-amber-500"
            />
          </div>
          <h1 className="text-2xl font-black tracking-tight text-slate-900 flex items-center justify-center gap-2">
            Ape Baas <span className="px-2 py-0.5 rounded-lg text-xs bg-amber-500 text-slate-950 font-black tracking-wider shadow-sm">PRO</span>
          </h1>
          <p className="text-xs text-amber-600 mt-1 font-bold">
            Ape Baas Admin Operations Portal • System Authorization
          </p>
        </div>

        {/* Card Form Container */}
        <div className="bg-white border border-slate-200/80 p-8 rounded-3xl shadow-xl shadow-slate-200/60 space-y-6">
          {/* Mode Switcher Tabs (Only visible when NO admin exists in database and not in forgot mode) */}
          {!hasAdminExists && !isForgotMode && (
            <div className="flex items-center p-1 rounded-xl bg-slate-100 border border-slate-200">
              <button
                type="button"
                onClick={() => { setIsRegisterMode(false); setIsForgotMode(false); setRegStep(1); setLoginStep(1); setErrorMessage(''); setSuccessMessage(''); setConfirmPassword(''); }}
                className={`flex-1 py-2 rounded-lg text-xs font-bold transition-all ${
                  !isRegisterMode
                    ? 'bg-amber-500 text-slate-950 font-extrabold shadow-sm'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                Sign In
              </button>
              <button
                type="button"
                onClick={() => { setIsRegisterMode(true); setIsForgotMode(false); setRegStep(1); setLoginStep(1); setErrorMessage(''); setSuccessMessage(''); setConfirmPassword(''); }}
                className={`flex-1 py-2 rounded-lg text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
                  isRegisterMode
                    ? 'bg-amber-500 text-slate-950 font-extrabold shadow-sm'
                    : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                <UserPlus className="w-3.5 h-3.5" />
                <span>Create Initial Admin</span>
              </button>
            </div>
          )}

          <div className="border-b border-slate-100 pb-3">
            <h2 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              {isForgotMode 
                ? (forgotStep === 1 ? 'Recover Admin Password' : 'Set New Password')
                : isRegisterMode 
                  ? (regStep === 1 ? 'Register Initial Super Admin' : 'Verify Email Address') 
                  : (loginStep === 1 ? 'Administrator Login' : 'Two-Factor Authentication (2FA)')}
            </h2>
            <p className="text-xs text-slate-500 mt-0.5">
              {isForgotMode
                ? (forgotStep === 1 
                    ? 'Enter your administrator email address to receive a 6-digit recovery code.' 
                    : `Enter the 6-digit recovery code sent to ${email} and set your new password.`)
                : isRegisterMode
                  ? (regStep === 1 
                      ? 'Enter your details to create the initial Super Admin account and receive OTP code.' 
                      : `Enter the 6-digit verification code sent to ${email}.`)
                  : (loginStep === 1
                      ? 'Enter your administrator email and password to log in.'
                      : `Enter the 6-digit 2FA login code sent to ${email}.`)}
            </p>
          </div>

          {/* Error Message Box */}
          {errorMessage && (
            <div className="p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-semibold flex items-center gap-2.5 animate-in fade-in slide-in-from-top-2">
              <AlertCircle className="w-4 h-4 shrink-0 text-rose-600" />
              <span>{errorMessage}</span>
            </div>
          )}

          {/* Success Message Box */}
          {successMessage && (
            <div className="p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold flex items-center gap-2.5 animate-in fade-in slide-in-from-top-2">
              <CheckCircle2 className="w-4 h-4 shrink-0 text-emerald-600" />
              <span>{successMessage}</span>
            </div>
          )}

          {/* REGISTER STEP 1: Admin Details Form */}
          {isRegisterMode && !isForgotMode && regStep === 1 && (
            <form onSubmit={handleSendOtpStep} className="space-y-4">
              {/* Full Name Field */}
              <div className="space-y-1.5 animate-in fade-in">
                <label className="text-xs font-bold text-slate-700 block">
                  Admin Full Name *
                </label>
                <div className="relative">
                  <User className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={fullName}
                    onChange={(e) => setFullName(e.target.value)}
                    placeholder="e.g. Umindu Dinal"
                    required
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              {/* Email Field */}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 block">
                  Admin Email Address (Verification Code Inbox) *
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="admin@example.com"
                    required
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              {/* Phone Field */}
              <div className="space-y-1.5 animate-in fade-in">
                <label className="text-xs font-bold text-slate-700 block">
                  Phone Number
                </label>
                <div className="relative">
                  <Phone className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    placeholder="0771234567"
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              {/* Password Field */}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 block">
                  Password (Strong Password) *
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    required
                    className="w-full pl-10 pr-10 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Password Strength Indicator & Requirements Checklist */}
              {password.length > 0 && (
                <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200 space-y-2.5 animate-in fade-in">
                  <div className="flex items-center justify-between text-[11px] font-bold">
                    <span className="text-slate-600 flex items-center gap-1.5">
                      <Shield className="w-3.5 h-3.5 text-amber-500" /> Password Security Level
                    </span>
                    <span className={
                      strengthScore <= 2 ? 'text-rose-600 font-bold' :
                      strengthScore <= 4 ? 'text-amber-600 font-bold' :
                      'text-emerald-600 font-extrabold'
                    }>
                      {strengthScore <= 2 ? 'Weak' :
                       strengthScore <= 4 ? 'Fair' :
                       'Strong ✓'}
                    </span>
                  </div>

                  {/* 5-Segment Strength Bar */}
                  <div className="grid grid-cols-5 gap-1.5 h-1.5">
                    {[1, 2, 3, 4, 5].map((seg) => (
                      <div
                        key={seg}
                        className={`rounded-full transition-all duration-300 ${
                          seg <= strengthScore
                            ? strengthScore <= 2
                              ? 'bg-rose-500 shadow-xs'
                              : strengthScore <= 4
                              ? 'bg-amber-500 shadow-xs'
                              : 'bg-emerald-500 shadow-xs'
                            : 'bg-slate-200'
                        }`}
                      />
                    ))}
                  </div>

                  {/* Live Criteria Checklist */}
                  <div className="grid grid-cols-2 gap-1.5 pt-1 text-[10.5px]">
                    <div className={`flex items-center gap-1.5 ${hasLength ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {hasLength ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>8+ Characters</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${hasUpper ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {hasUpper ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>Uppercase (A-Z)</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${hasLower ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {hasLower ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>Lowercase (a-z)</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${hasNumber && hasSpecial ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {hasNumber && hasSpecial ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>0-9 & Special (@#$)</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Confirm Password Field */}
              <div className="space-y-1.5 animate-in fade-in">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold text-slate-700 block">
                    Confirm Password *
                  </label>
                  {confirmPassword.length > 0 && (
                    <span className={`text-[10px] font-bold flex items-center gap-1 ${
                      password === confirmPassword ? 'text-emerald-600' : 'text-rose-600'
                    }`}>
                      {password === confirmPassword ? (
                        <>
                          <Check className="w-3 h-3 text-emerald-600" />
                          <span>Matched</span>
                        </>
                      ) : (
                        <>
                          <X className="w-3 h-3 text-rose-600" />
                          <span>Mismatch</span>
                        </>
                      )}
                    </span>
                  )}
                </div>
                <div className="relative">
                  <Lock className={`w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 transition-colors ${
                    confirmPassword.length > 0
                      ? password === confirmPassword ? 'text-emerald-600' : 'text-rose-500'
                      : 'text-slate-400'
                  }`} />
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    placeholder="••••••••••••"
                    required
                    className={`w-full pl-10 pr-10 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border transition-all font-medium placeholder:text-slate-400 focus:bg-white focus:outline-none ${
                      confirmPassword.length > 0
                        ? password === confirmPassword
                          ? 'border-emerald-500 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20'
                          : 'border-rose-500 focus:border-rose-500 focus:ring-2 focus:ring-rose-500/20'
                        : 'border-slate-300 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20'
                    }`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                  >
                    {showConfirmPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
                {confirmPassword.length > 0 && password !== confirmPassword && (
                  <p className="text-[10.5px] text-rose-600 font-medium flex items-center gap-1 pt-0.5 animate-in fade-in">
                    <AlertCircle className="w-3 h-3 shrink-0" />
                    <span>Passwords do not match.</span>
                  </p>
                )}
              </div>

              {/* Submit to Send OTP Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 mt-4 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Send Verification Code</span>
                    <ArrowRight className="w-4 h-4 stroke-[3]" />
                  </>
                )}
              </button>
            </form>
          )}

          {/* REGISTER STEP 2: 6-Digit Email OTP Verification UI */}
          {isRegisterMode && !isForgotMode && regStep === 2 && (
            <form onSubmit={handleVerifyOtpAndRegister} className="space-y-5 animate-in fade-in">
              <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-center">
                <div className="w-12 h-12 rounded-2xl bg-amber-100 border border-amber-300 text-amber-600 mx-auto flex items-center justify-center mb-2.5">
                  <KeyRound className="w-6 h-6" />
                </div>
                <div className="text-xs font-bold text-slate-700">
                  Registration Verification Code Sent To:
                </div>
                <div className="text-xs font-extrabold text-amber-700 mt-0.5 break-all">
                  {email}
                </div>
              </div>

              {/* 6-Digit OTP Boxes */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-700 block text-center">
                  Enter 6-Digit Verification Code (OTP)
                </label>
                <div className="flex items-center justify-center gap-2" onPaste={handleOtpPaste}>
                  {otpDigits.map((digit, idx) => (
                    <input
                      key={idx}
                      ref={(el) => (otpInputRefs.current[idx] = el)}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={(e) => handleOtpChange(idx, e.target.value)}
                      onKeyDown={(e) => handleOtpKeyDown(idx, e)}
                      className="w-11 h-12 text-center text-lg font-black text-slate-900 bg-slate-50 border border-slate-300 rounded-xl focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all shadow-sm"
                    />
                  ))}
                </div>
              </div>

              {/* Countdown Timer & Resend Option */}
              <div className="flex items-center justify-between text-xs pt-1 px-1">
                <span className="text-slate-500">
                  {timerCount > 0 ? (
                    <span className="text-amber-600 font-semibold">
                      ⏱️ Resend in {timerCount}s
                    </span>
                  ) : (
                    <span className="text-slate-500">Didn't receive code?</span>
                  )}
                </span>
                <button
                  type="button"
                  onClick={handleResendRegisterOtp}
                  disabled={timerCount > 0 || isResending}
                  className="font-bold text-amber-600 hover:text-amber-700 disabled:text-slate-400 disabled:cursor-not-allowed transition-colors flex items-center gap-1 cursor-pointer"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${isResending ? 'animate-spin' : ''}`} />
                  <span>Resend Code</span>
                </button>
              </div>

              {/* Submit Verification Button */}
              <button
                type="submit"
                disabled={isLoading || otpDigits.join('').length < 6}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <CheckCircle2 className="w-4 h-4 stroke-[3]" />
                    <span>Verify & Create Super Admin</span>
                  </>
                )}
              </button>

              {/* Back to Step 1 Button */}
              <button
                type="button"
                onClick={() => { setRegStep(1); setErrorMessage(''); setSuccessMessage(''); }}
                className="w-full py-2 text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                <span>Change Email / Edit Details</span>
              </button>
            </form>
          )}

          {/* SIGN IN STEP 1: Credentials Form */}
          {!isRegisterMode && !isForgotMode && loginStep === 1 && (
            <form onSubmit={handleLoginSubmit} className="space-y-4">
              {/* Email Field */}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 block">
                  Admin Email Address
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-amber-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="admin@example.com"
                    required
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              {/* Password Field */}
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 block">
                  Password
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-amber-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    required
                    className="w-full pl-10 pr-10 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                  >
                    {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Remember Me Checkbox & Forgot Password Link */}
              <div className="flex items-center justify-between pt-1">
                <label className="flex items-center gap-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="rounded border-slate-300 text-amber-500 focus:ring-amber-500 w-4 h-4 cursor-pointer"
                  />
                  <span className="text-xs text-slate-600 select-none">Remember session</span>
                </label>

                <button
                  type="button"
                  onClick={() => {
                    setIsForgotMode(true);
                    setForgotStep(1);
                    setErrorMessage('');
                    setSuccessMessage('');
                    setNewPassword('');
                    setConfirmNewPassword('');
                  }}
                  className="text-xs font-bold text-amber-600 hover:text-amber-700 transition-colors cursor-pointer"
                >
                  Forgot password?
                </button>
              </div>

              {/* Submit Button */}
              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 mt-2 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Next / Get 2FA Login Code</span>
                    <ArrowRight className="w-4 h-4 stroke-[3]" />
                  </>
                )}
              </button>
            </form>
          )}

          {/* SIGN IN STEP 2: 2FA Email Login OTP Verification UI */}
          {!isRegisterMode && !isForgotMode && loginStep === 2 && (
            <form onSubmit={handleVerifyLoginOtp} className="space-y-5 animate-in fade-in">
              <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-center">
                <div className="w-12 h-12 rounded-2xl bg-amber-100 border border-amber-300 text-amber-600 mx-auto flex items-center justify-center mb-2.5">
                  <KeyRound className="w-6 h-6" />
                </div>
                <div className="text-xs font-bold text-slate-700">
                  2FA Login Code Sent To:
                </div>
                <div className="text-xs font-extrabold text-amber-700 mt-0.5 break-all">
                  {email}
                </div>
              </div>

              {/* 6-Digit OTP Boxes */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-700 block text-center">
                  Enter 6-Digit 2FA Login Code (OTP)
                </label>
                <div className="flex items-center justify-center gap-2" onPaste={handleOtpPaste}>
                  {otpDigits.map((digit, idx) => (
                    <input
                      key={idx}
                      ref={(el) => (otpInputRefs.current[idx] = el)}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={(e) => handleOtpChange(idx, e.target.value)}
                      onKeyDown={(e) => handleOtpKeyDown(idx, e)}
                      className="w-11 h-12 text-center text-lg font-black text-slate-900 bg-slate-50 border border-slate-300 rounded-xl focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all shadow-sm"
                    />
                  ))}
                </div>
              </div>

              {/* Countdown Timer & Resend Option */}
              <div className="flex items-center justify-between text-xs pt-1 px-1">
                <span className="text-slate-500">
                  {timerCount > 0 ? (
                    <span className="text-amber-600 font-semibold">
                      ⏱️ Resend in {timerCount}s
                    </span>
                  ) : (
                    <span className="text-slate-500">Didn't receive code?</span>
                  )}
                </span>
                <button
                  type="button"
                  onClick={handleResendLoginOtp}
                  disabled={timerCount > 0 || isResending}
                  className="font-bold text-amber-600 hover:text-amber-700 disabled:text-slate-400 disabled:cursor-not-allowed transition-colors flex items-center gap-1 cursor-pointer"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${isResending ? 'animate-spin' : ''}`} />
                  <span>Resend Code</span>
                </button>
              </div>

              {/* Submit Verification Button */}
              <button
                type="submit"
                disabled={isLoading || otpDigits.join('').length < 6}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <CheckCircle2 className="w-4 h-4 stroke-[3]" />
                    <span>Verify & Enter Dashboard</span>
                  </>
                )}
              </button>

              {/* Back to Step 1 Button */}
              <button
                type="button"
                onClick={() => { setLoginStep(1); setErrorMessage(''); setSuccessMessage(''); }}
                className="w-full py-2 text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                <span>Change Login Credentials</span>
              </button>
            </form>
          )}

          {/* FORGOT PASSWORD STEP 1: Enter Email Form */}
          {isForgotMode && forgotStep === 1 && (
            <form onSubmit={handleSendForgotOtpStep} className="space-y-4 animate-in fade-in">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 block">
                  Registered Administrator Email
                </label>
                <div className="relative">
                  <Mail className="w-4 h-4 text-amber-500 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="admin@example.com"
                    required
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                </div>
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 mt-2 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <span>Send Recovery Code</span>
                    <ArrowRight className="w-4 h-4 stroke-[3]" />
                  </>
                )}
              </button>

              <button
                type="button"
                onClick={() => { setIsForgotMode(false); setForgotStep(1); setErrorMessage(''); setSuccessMessage(''); }}
                className="w-full py-2 text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                <span>Back to Sign In</span>
              </button>
            </form>
          )}

          {/* FORGOT PASSWORD STEP 2: 6-Digit OTP & New Password Form */}
          {isForgotMode && forgotStep === 2 && (
            <form onSubmit={handleResetPasswordSubmit} className="space-y-4 animate-in fade-in">
              <div className="p-4 rounded-2xl bg-amber-50 border border-amber-200 text-center">
                <div className="w-12 h-12 rounded-2xl bg-amber-100 border border-amber-300 text-amber-600 mx-auto flex items-center justify-center mb-2.5">
                  <KeyRound className="w-6 h-6" />
                </div>
                <div className="text-xs font-bold text-slate-700">
                  Password Recovery Code Sent To:
                </div>
                <div className="text-xs font-extrabold text-amber-700 mt-0.5 break-all">
                  {email}
                </div>
              </div>

              {/* 6-Digit OTP Boxes */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-slate-700 block text-center">
                  Enter 6-Digit Recovery Code (OTP)
                </label>
                <div className="flex items-center justify-center gap-2" onPaste={handleOtpPaste}>
                  {otpDigits.map((digit, idx) => (
                    <input
                      key={idx}
                      ref={(el) => (otpInputRefs.current[idx] = el)}
                      type="text"
                      inputMode="numeric"
                      maxLength={1}
                      value={digit}
                      onChange={(e) => handleOtpChange(idx, e.target.value)}
                      onKeyDown={(e) => handleOtpKeyDown(idx, e)}
                      className="w-11 h-12 text-center text-lg font-black text-slate-900 bg-slate-50 border border-slate-300 rounded-xl focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all shadow-sm"
                    />
                  ))}
                </div>
              </div>

              {/* Countdown Timer & Resend Option */}
              <div className="flex items-center justify-between text-xs pt-1 px-1">
                <span className="text-slate-500">
                  {timerCount > 0 ? (
                    <span className="text-amber-600 font-semibold">
                      ⏱️ Resend in {timerCount}s
                    </span>
                  ) : (
                    <span className="text-slate-500">Didn't receive code?</span>
                  )}
                </span>
                <button
                  type="button"
                  onClick={handleResendForgotOtp}
                  disabled={timerCount > 0 || isResending}
                  className="font-bold text-amber-600 hover:text-amber-700 disabled:text-slate-400 disabled:cursor-not-allowed transition-colors flex items-center gap-1 cursor-pointer"
                >
                  <RefreshCw className={`w-3.5 h-3.5 ${isResending ? 'animate-spin' : ''}`} />
                  <span>Resend Code</span>
                </button>
              </div>

              {/* New Password Field */}
              <div className="space-y-1.5 pt-1">
                <label className="text-xs font-bold text-slate-700 block">
                  New Password *
                </label>
                <div className="relative">
                  <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    placeholder="••••••••••••"
                    required
                    className="w-full pl-10 pr-10 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border border-slate-300 focus:bg-white focus:outline-none focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20 transition-all font-medium placeholder:text-slate-400"
                  />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword(!showNewPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                  >
                    {showNewPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Password Strength Checklist */}
              {newPassword.length > 0 && (
                <div className="p-3.5 rounded-2xl bg-slate-50 border border-slate-200 space-y-2.5 animate-in fade-in">
                  <div className="flex items-center justify-between text-[11px] font-bold">
                    <span className="text-slate-600 flex items-center gap-1.5">
                      <Shield className="w-3.5 h-3.5 text-amber-500" /> Password Security Level
                    </span>
                    <span className={
                      newStrengthScore <= 2 ? 'text-rose-600 font-bold' :
                      newStrengthScore <= 4 ? 'text-amber-600 font-bold' :
                      'text-emerald-600 font-extrabold'
                    }>
                      {newStrengthScore <= 2 ? 'Weak' :
                       newStrengthScore <= 4 ? 'Fair' :
                       'Strong ✓'}
                    </span>
                  </div>

                  <div className="grid grid-cols-5 gap-1.5 h-1.5">
                    {[1, 2, 3, 4, 5].map((seg) => (
                      <div
                        key={seg}
                        className={`rounded-full transition-all duration-300 ${
                          seg <= newStrengthScore
                            ? newStrengthScore <= 2
                              ? 'bg-rose-500 shadow-xs'
                              : newStrengthScore <= 4
                              ? 'bg-amber-500 shadow-xs'
                              : 'bg-emerald-500 shadow-xs'
                            : 'bg-slate-200'
                        }`}
                      />
                    ))}
                  </div>

                  <div className="grid grid-cols-2 gap-1.5 pt-1 text-[10.5px]">
                    <div className={`flex items-center gap-1.5 ${newHasLength ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {newHasLength ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>8+ Characters</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${newHasUpper ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {newHasUpper ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>Uppercase (A-Z)</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${newHasLower ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {newHasLower ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>Lowercase (a-z)</span>
                    </div>
                    <div className={`flex items-center gap-1.5 ${newHasNumber && newHasSpecial ? 'text-emerald-700 font-semibold' : 'text-slate-400'}`}>
                      {newHasNumber && newHasSpecial ? <Check className="w-3 h-3 text-emerald-600 shrink-0" /> : <X className="w-3 h-3 text-slate-400 shrink-0" />}
                      <span>0-9 & Special (@#$)</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Confirm New Password Field */}
              <div className="space-y-1.5">
                <div className="flex items-center justify-between">
                  <label className="text-xs font-bold text-slate-700 block">
                    Confirm New Password *
                  </label>
                  {confirmNewPassword.length > 0 && (
                    <span className={`text-[10px] font-bold flex items-center gap-1 ${
                      newPassword === confirmNewPassword ? 'text-emerald-600' : 'text-rose-600'
                    }`}>
                      {newPassword === confirmNewPassword ? (
                        <>
                          <Check className="w-3 h-3 text-emerald-600" />
                          <span>Matched</span>
                        </>
                      ) : (
                        <>
                          <X className="w-3 h-3 text-rose-600" />
                          <span>Mismatch</span>
                        </>
                      )}
                    </span>
                  )}
                </div>
                <div className="relative">
                  <Lock className={`w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 transition-colors ${
                    confirmNewPassword.length > 0
                      ? newPassword === confirmNewPassword ? 'text-emerald-600' : 'text-rose-500'
                      : 'text-slate-400'
                  }`} />
                  <input
                    type={showConfirmNewPassword ? 'text' : 'password'}
                    value={confirmNewPassword}
                    onChange={(e) => setConfirmNewPassword(e.target.value)}
                    placeholder="••••••••••••"
                    required
                    className={`w-full pl-10 pr-10 py-2.5 bg-slate-50 text-slate-900 text-xs rounded-xl border transition-all font-medium placeholder:text-slate-400 focus:bg-white focus:outline-none ${
                      confirmNewPassword.length > 0
                        ? newPassword === confirmNewPassword
                          ? 'border-emerald-500 focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20'
                          : 'border-rose-500 focus:border-rose-500 focus:ring-2 focus:ring-rose-500/20'
                        : 'border-slate-300 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/20'
                    }`}
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmNewPassword(!showConfirmNewPassword)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 cursor-pointer"
                  >
                    {showConfirmNewPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                  </button>
                </div>
              </div>

              {/* Submit Reset Button */}
              <button
                type="submit"
                disabled={isLoading || otpDigits.join('').length < 6 || !isNewPasswordStrong || newPassword !== confirmNewPassword}
                className="w-full py-3 px-4 rounded-xl bg-amber-500 hover:bg-amber-600 text-slate-950 font-black text-xs flex items-center justify-center gap-2 shadow-md shadow-amber-500/10 transition-all active:scale-[0.99] disabled:opacity-50 cursor-pointer"
              >
                {isLoading ? (
                  <div className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin"></div>
                ) : (
                  <>
                    <CheckCircle2 className="w-4 h-4 stroke-[3]" />
                    <span>Reset Password & Log In</span>
                  </>
                )}
              </button>

              {/* Back to Step 1 Button */}
              <button
                type="button"
                onClick={() => { setForgotStep(1); setErrorMessage(''); setSuccessMessage(''); }}
                className="w-full py-2 text-xs font-semibold text-slate-500 hover:text-slate-800 transition-colors flex items-center justify-center gap-1.5 cursor-pointer"
              >
                <ArrowLeft className="w-3.5 h-3.5" />
                <span>Change Email / Edit Details</span>
              </button>
            </form>
          )}

        </div>

        {/* Footer info */}
        <p className="text-center text-[11px] text-slate-500 mt-6">
          © {new Date().getFullYear()} Ape Baas Home Services. System Security Level 3.
        </p>
      </div>
    </div>
  );
};

export default LoginPage;
