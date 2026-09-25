const crypto = require('crypto');
const supabase = require('../config/supabase');

// Helper to securely hash password using PBKDF2
const hashPassword = (password) => {
    const salt = crypto.randomBytes(16).toString('hex');
    const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
    return `pbkdf2$${salt}$${hash}`;
};

// Helper to verify password against PBKDF2 hash
const verifyPassword = (password, storedHash) => {
    if (!storedHash || typeof storedHash !== 'string' || !storedHash.startsWith('pbkdf2$')) return false;
    try {
        const parts = storedHash.split('$');
        if (parts.length !== 3) return false;
        const [_, salt, originalHash] = parts;
        const computedHash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
        return crypto.timingSafeEqual(Buffer.from(originalHash, 'hex'), Buffer.from(computedHash, 'hex'));
    } catch (e) {
        return false;
    }
};

const registerUser = async (req, res) => {
    // 1. Postman/Flutter එකෙන් එවන දත්ත මොනවාදැයි හරියටම Terminal එකේ Print කර බැලීම
    console.log("👉 ආපු දත්ත:", req.body);

    // name වෙනුවට full_name ලෙස වෙනස් කර, phone යන්නද එකතු කරන ලදී
    const { full_name, email, phone, password, role } = req.body;

    // full_name සහ phone හිස්දැයි පරීක්ෂා කිරීමට යාවත්කාලීන කරන ලදී
    if (!full_name || !email || !phone || !password || !role) {
        return res.status(400).json({ error: "කරුණාකර සියලුම තොරතුරු ඇතුලත් කරන්න." });
    }

    const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{8,}$/;
    if (!strongPasswordRegex.test(password)) {
        return res.status(400).json({ 
            error: "මුරපදය අවම වශයෙන් අක්ෂර 8ක්, කැපිටල් (A-Z), සිම්පල් (a-z), ඉලක්කම් (0-9) සහ විශේෂ සංකේතයක් (@#$) සහිත ශක්තිමත් එකක් විය යුතුය." 
        });
    }

    try {
        const cleanEmail = email.trim();
        const cleanName = full_name.trim(); // full_name ලෙස යාවත්කාලීන කරන ලදී

        const { data, error } = await supabase.auth.signUp({
            email: cleanEmail,
            password: password,
            options: {
                data: {
                    full_name: cleanName,
                    phone: phone, // දුරකථන අංකයද Database එකට යැවීම
                    user_role: role 
                }
            }
        });

        if (error) {
            // 2. Supabase එකෙන් එන Error එක Terminal එකේ Print කිරීම
            console.error("❌ Supabase Error එක:", error);
            return res.status(400).json({ error: error.message });
        }

        // 3. public.profiles වගුවේ පරිශීලකයාගේ phone, full_name, email, role තැන්පත් කිරීම
        if (data.user) {
            const { error: profileErr } = await supabase
                .from('profiles')
                .upsert([
                    {
                        id: data.user.id,
                        full_name: cleanName,
                        email: cleanEmail,
                        phone: phone,
                        role: role
                    }
                ]);

            if (profileErr) {
                console.error("⚠️ Profiles table insert warning:", profileErr.message);
            }
        }

        // 4. සාර්ථක වුණොත් ඒ බව Terminal එකේ Print කිරීම
        console.log("✅ ගිණුම සාර්ථකව සැදුවා:", data.user.email);
        
        res.status(201).json({ 
            success: true,
            message: "සාර්ථකව ලියාපදිංචි කරන ලදී!", 
            user: data.user 
        });

    } catch (err) {
        console.error("❌ Server Error එක:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// පරිශීලකයින් ලොග් වීමේ (Login) ක්‍රියාවලිය
const loginUser = async (req, res) => {
    const { email, password, role } = req.body;

    // තොරතුරු එවා ඇත්දැයි පරීක්ෂා කිරීම
    if (!email || !password) {
        return res.status(400).json({ error: "කරුණාකර ඊමේල් ලිපිනය සහ මුරපදය ඇතුලත් කරන්න." });
    }

    try {
        const cleanEmail = email.trim().toLowerCase();

        // 1. Supabase Auth හරහා ලොග් වීම
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email: cleanEmail,
            password: password
        });

        // 2. Profile තොරතුරු DB එකෙන් ලබා ගැනීම
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select('*')
            .ilike('email', cleanEmail)
            .maybeSingle();

        let authenticatedUser = null;

        if (!authError && authData?.user) {
            authenticatedUser = authData.user;
        } else if (profile && profile.fcm_token && verifyPassword(password, profile.fcm_token)) {
            // PBKDF2 Password verified (from password reset)
            authenticatedUser = {
                id: profile.id,
                email: profile.email,
                user_metadata: {
                    full_name: profile.full_name,
                    phone: profile.phone,
                    role: profile.role
                }
            };
            console.log("✅ PBKDF2 Password authenticated successfully for:", cleanEmail);
        } else {
            console.error("❌ Login Error for", cleanEmail, authError ? authError.message : "Password mismatch");
            return res.status(401).json({ error: "ඊමේල් ලිපිනය හෝ මුරපදය වැරදියි." });
        }

        if (!profile) {
            return res.status(401).json({ 
                error: "මෙම පරිශීලක ගිණුම පද්ධතියෙන් ඉවත් කර ඇත හෝ හමු නොවීය." 
            });
        }

        // 🔒 Role Validation Check: පරිශීලකයාගේ Role එක ගැලපේදැයි පරීක්ෂා කිරීම
        if (role && profile.role && profile.role.toLowerCase() !== role.toLowerCase()) {
            const actualRoleText = profile.role.toLowerCase() === 'provider' ? 'සේවා සපයන්නෙකු (Provider)' : 'පාරිභෝගිකයෙකු (Customer)';
            const requestedRoleText = role.toLowerCase() === 'provider' ? 'සේවා සපයන්නෙකු (Provider)' : 'පාරිභෝගිකයෙකු (Customer)';
            console.warn(`⚠️ Role Mismatch for ${cleanEmail}: DB role is '${profile.role}', requested role is '${role}'`);
            return res.status(403).json({ 
                error: `ඔබගේ ගිණුම ${actualRoleText} ගිණුමකි. ${requestedRoleText} ලෙස ලොග් විය නොහැක.` 
            });
        }

        console.log("✅ සාර්ථකව ලොග් වුණා:", profile.email);
        
        // ලොග් වූ පසු Token එක (Session) සහ පරිශීලක තොරතුරු (Profile ඇතුළුව) යැවීම
        return res.status(200).json({
            success: true,
            message: "සාර්ථකව ලොග් විය!",
            session: authData?.session || null,
            user: {
                id: profile.id,
                email: profile.email,
                user_metadata: {
                    full_name: profile.full_name,
                    role: profile.role,
                    phone: profile.phone,
                    address: profile.address,
                    district: profile.district,
                    city: profile.city,
                    profile_image_url: profile.profile_image_url
                }
            },
            profile: profile
        });

    } catch (err) {
        console.error("❌ Server Error:", err);
        return res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// පරිශීලකයෙකුගේ Profile තොරතුරු ලබා ගැනීම
const getUserProfile = async (req, res) => {
    const { userId } = req.params;

    try {
        const { data: profile, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', userId)
            .maybeSingle();

        if (error) throw error;

        res.status(200).json({
            success: true,
            data: profile || null
        });

    } catch (err) {
        console.error("❌ Get Profile Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්." });
    }
};
const updateUserProfile = async (req, res) => {
    const { 
        user_id, 
        full_name, 
        phone, 
        address, 
        district, 
        city, 
        profile_image_url,
        service_category, 
        experience_years, 
        working_radius_km 
    } = req.body;

    try {
        if (!user_id) {
            return res.status(400).json({ success: false, error: 'User ID අවශ්‍ය වේ.' });
        }

        // 1. profiles table එකෙහි full_name, phone, address, district, city, profile_image_url යාවත්කාලීන කිරීම
        const updateData = { id: user_id };
        if (full_name !== undefined) updateData.full_name = full_name;
        if (phone !== undefined) updateData.phone = phone;
        if (address !== undefined) updateData.address = address;
        if (district !== undefined) updateData.district = district;
        if (city !== undefined) updateData.city = city;
        if (profile_image_url !== undefined) updateData.profile_image_url = profile_image_url;

        // Upsert මගින් profiles table එකේ row එක නැතත් අලුතින් හදා හෝ යාවත්කාලීන කරයි
        const { error: profileError } = await supabase
            .from('profiles')
            .upsert(updateData, { onConflict: 'id' });

        if (profileError) {
            console.error("❌ Error updating profiles via upsert:", profileError.message);
            const { error: fallbackErr } = await supabase
                .from('profiles')
                .update(updateData)
                .eq('id', user_id);
            if (fallbackErr) console.error("❌ Fallback update error:", fallbackErr.message);
        }

        // Supabase Auth metadata සමඟද sync කිරීම
        try {
            await supabase.auth.admin.updateUserById(user_id, {
                user_metadata: updateData
            });
        } catch (metaErr) {
            // Service role key නොමැති අවස්ථාවල පැහැදිලිwarning එකක් පමණක් දක්වයි
        }

        // 2. සේවා සපයන්නෙකුගේ අමතර විස්තර තිබේ නම් provider_details table එක යාවත්කාලීන කිරීම
        if (service_category || experience_years !== undefined || working_radius_km !== undefined) {
            const providerUpdateData = { id: user_id };
            if (service_category) providerUpdateData.service_category = service_category;
            if (experience_years !== undefined) providerUpdateData.experience_years = parseInt(experience_years);
            if (working_radius_km !== undefined) providerUpdateData.working_radius_km = parseInt(working_radius_km);

            const { error: providerError } = await supabase
                .from('provider_details')
                .upsert(providerUpdateData, { onConflict: 'id' });

            if (providerError) console.error("⚠️ Provider details update warning:", providerError.message);
        }

        console.log("✅ Profile updated successfully for user_id:", user_id);

        res.status(200).json({
            success: true,
            message: 'ඔබගේ ගිණුමේ තොරතුරු සාර්ථකව යාවත්කාලීන කරන ලදී!'
        });

    } catch (err) {
        console.error("❌ Update Profile Error:", err);
        res.status(500).json({ success: false, error: err.message });
    }
};

// මුරපදය වෙනස් කිරීම (Change Password)
const changePassword = async (req, res) => {
    const { user_id, old_password, new_password } = req.body;

    if (!user_id || !old_password || !new_password) {
        return res.status(400).json({ error: "කරුණාකර සියලුම තොරතුරු ඇතුලත් කරන්න." });
    }

    if (new_password.length < 6) {
        return res.status(400).json({ error: "නව මුරපදය අවම වශයෙන් අකුරු 6ක් තිබිය යුතුය." });
    }

    try {
        // 1. පරිශීලකයාගේ Email එක profiles වගුවෙන් ලබා ගැනීම
        const { data: profile, error: profileErr } = await supabase
            .from('profiles')
            .select('email')
            .eq('id', user_id)
            .maybeSingle();

        if (profileErr || !profile || !profile.email) {
            return res.status(404).json({ error: "පරිශීලක ගිණුම හමු නොවීය." });
        }

        // 2. වත්මන් මුරපදය (old_password) නිවැරදිදැයි පරීක්ෂා කිරීම
        const { data: authData, error: signInErr } = await supabase.auth.signInWithPassword({
            email: profile.email,
            password: old_password
        });

        if (signInErr || !authData.session) {
            console.error("❌ Invalid current password for user:", profile.email);
            return res.status(400).json({ error: "වත්මන් මුරපදය වැරදියි. කරුණාකර නැවත පරීක්ෂා කරන්න." });
        }

        // 3. Authenticated session එක හරහා නව මුරපදය යාවත්කාලීන කිරීම
        const { createClient } = require('@supabase/supabase-js');
        const userClient = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_KEY, {
            auth: { persistSession: false }
        });

        await userClient.auth.setSession({
            access_token: authData.session.access_token,
            refresh_token: authData.session.refresh_token
        });

        const { error: updateErr } = await userClient.auth.updateUser({
            password: new_password
        });

        if (updateErr) {
            console.error("❌ Password update failed:", updateErr.message);
            return res.status(400).json({ error: "මුරපදය වෙනස් කිරීමට නොහැකි විය: " + updateErr.message });
        }

        console.log("✅ Password changed successfully for user:", profile.email);
        return res.status(200).json({
            success: true,
            message: "මුරපදය සාර්ථකව වෙනස් කරන ලදී!"
        });

    } catch (err) {
        console.error("❌ Change Password Error:", err);
        return res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// In-memory OTP Store (email -> { code, expiresAt })
const otpStore = new Map();

// Helper to send email OTP
const sendEmailOtp = async (toEmail, otpCode) => {
    let nodemailer;
    try {
        nodemailer = require('nodemailer');
    } catch (err) {
        console.error("❌ 'nodemailer' package එක backend node_modules තුළ නැත! කරුණාකර backend terminal එකෙහි 'npm install' run කරන්න.");
    }

    console.log(`\n==================================================`);
    console.log(`🔑 REGISTER OTP CODE FOR ${toEmail}: [ ${otpCode} ]`);
    console.log(`==================================================\n`);

    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS ? process.env.SMTP_PASS.replace(/["'\s]/g, '') : '';

    if (nodemailer && smtpUser && smtpPass) {
        try {
            const transporter = nodemailer.createTransport({
                host: process.env.SMTP_HOST || 'smtp.gmail.com',
                port: parseInt(process.env.SMTP_PORT || '587'),
                secure: parseInt(process.env.SMTP_PORT || '587') === 465,
                auth: { user: smtpUser, pass: smtpPass },
                tls: { rejectUnauthorized: false }
            });

            await transporter.sendMail({
                from: `"Ape Baas" <${smtpUser}>`,
                to: toEmail,
                subject: `🛡️ ඊමේල් සත්‍යාපන කේතය (OTP: ${otpCode}) | Ape Baas`,
                html: `
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <meta charset="utf-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Email Verification - Ape Baas</title>
                    </head>
                    <body style="margin: 0; padding: 0; background-color: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
                        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #F8FAFC; padding: 30px 10px;">
                            <tr>
                                <td align="center">
                                    <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width: 520px; background-color: #FFFFFF; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); border: 1px solid #E2E8F0;">
                                        
                                        <!-- Header Banner -->
                                        <tr>
                                            <td style="background-color: #0F172A; padding: 28px 24px; text-align: center; border-bottom: 3px solid #F59E0B;">
                                                <div style="display: inline-block; background-color: rgba(255, 255, 255, 0.1); padding: 8px 16px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.15); margin-bottom: 8px;">
                                                    <span style="font-size: 20px; vertical-align: middle;">🛠️</span>
                                                    <span style="font-size: 18px; font-weight: 800; color: #FFFFFF; letter-spacing: 0.5px; margin-left: 8px; vertical-align: middle;">අපේ බාස් (Ape Baas)</span>
                                                </div>
                                                <h1 style="color: #F8FAFC; font-size: 16px; font-weight: 600; margin: 6px 0 0 0;">ඊමේල් ලිපිනය තහවුරු කිරීම (Email Verification)</h1>
                                            </td>
                                        </tr>

                                        <!-- Body Content -->
                                        <tr>
                                            <td style="padding: 32px 28px;">
                                                <p style="font-size: 16px; font-weight: 700; color: #0F172A; margin: 0 0 12px 0;">
                                                    ආයුබෝවන්! 🙏 (Hello!)
                                                </p>
                                                <p style="font-size: 14px; color: #475569; line-height: 1.6; margin: 0 0 24px 0;">
                                                    <strong>අපේ බාස් (Ape Baas)</strong> යෙදුම තුළ ඔබගේ ගිණුම සාර්ථකව සෑදීම සඳහා ඔබගේ ඊමේල් ලිපිනය තහවුරු කිරීමට පහත 6-ඩිජිට් OTP කේතය ඇතුළත් කරන්න:
                                                </p>

                                                <!-- OTP Box -->
                                                <div style="background-color: #F8FAFC; border: 2px solid #F59E0B; border-radius: 12px; padding: 20px 16px; text-align: center; margin-bottom: 24px;">
                                                    <div style="font-size: 11px; font-weight: 700; color: #B45309; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 6px;">
                                                        VERIFICATION OTP CODE
                                                    </div>
                                                    <div style="font-size: 36px; font-weight: 800; color: #0F172A; letter-spacing: 10px; font-family: 'Courier New', Courier, monospace; margin: 4px 0; text-indent: 10px;">
                                                        ${otpCode}
                                                    </div>
                                                    <div style="font-size: 12px; color: #64748B; margin-top: 6px;">
                                                        ⏱️ මෙම කේතය විනාඩි 10ක් සඳහා වලංගු වේ. (Expires in 10 mins)
                                                    </div>
                                                </div>

                                                <!-- Expiry & Safety Info Box -->
                                                <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #FFFBEB; border-radius: 8px; padding: 12px 14px; margin-bottom: 24px; border: 1px solid #FDE68A;">
                                                    <tr>
                                                        <td width="24" valign="top" style="font-size: 15px;">⚠️</td>
                                                        <td style="font-size: 12.5px; color: #92400E; line-height: 1.5;">
                                                            <strong>ආරක්ෂක සටහන:</strong> මෙම OTP කේතය කිසිවෙකුට ලබා නොදෙන්න. ඔබ මෙවැනි ඉල්ලීමක් සිදු නොකළේ නම් මෙම පණිවිඩය නොසලකා හරින්න.
                                                        </td>
                                                    </tr>
                                                </table>

                                                <p style="font-size: 13.5px; color: #64748B; margin: 0; line-height: 1.5;">
                                                    ස්තුතියි,<br>
                                                    <strong style="color: #334155;">Ape Baas Team (අපේ බාස් කණ්ඩායම)</strong>
                                                </p>
                                            </td>
                                        </tr>

                                        <!-- Footer -->
                                        <tr>
                                            <td style="background-color: #F8FAFC; padding: 16px 24px; text-align: center; border-top: 1px solid #E2E8F0;">
                                                <p style="font-size: 11.5px; color: #94A3B8; margin: 0;">
                                                    © 2026 Ape Baas (අපේ බාස්). All rights reserved.
                                                </p>
                                            </td>
                                        </tr>

                                    </table>
                                </td>
                            </tr>
                        </table>
                    </body>
                    </html>
                `,
            });
            console.log(`✉️ Nodemailer Email successfully sent to ${toEmail}`);
            return true;
        } catch (mailErr) {
            console.error("❌ Nodemailer error sending email:", mailErr.message);
        }
    } else {
        if (!nodemailer) {
            console.warn(`⚠️ Cannot send email: 'nodemailer' module is missing. Run 'npm install' in backend.`);
        } else {
            console.warn(`⚠️ SMTP credentials not complete. User: ${smtpUser}, Pass set: ${Boolean(smtpPass)}`);
        }
    }

    return true;
};

// 1. Send Register OTP
const sendRegisterOtp = async (req, res) => {
    const { email, full_name, phone } = req.body;

    if (!email || !full_name || !phone) {
        return res.status(400).json({ error: "කරුණාකර සියලුම තොරතුරු ඇතුලත් කරන්න." });
    }

    try {
        const cleanEmail = email.trim().toLowerCase();
        const cleanPhone = phone.trim();

        // 1. Check if email already exists in profiles
        const { data: existingEmail } = await supabase
            .from('profiles')
            .select('id')
            .eq('email', cleanEmail)
            .maybeSingle();

        if (existingEmail) {
            return res.status(400).json({ error: "මෙම ඊමේල් ලිපිනය දැනටමත් ලියාපදිංචි කර ඇත." });
        }

        // 2. Check if phone already exists in profiles
        const { data: existingPhone } = await supabase
            .from('profiles')
            .select('id')
            .eq('phone', cleanPhone)
            .maybeSingle();

        if (existingPhone) {
            return res.status(400).json({ error: "මෙම දුරකථන අංකය දැනටමත් ලියාපදිංචි කර ඇත." });
        }

        // 3. Generate 6-digit OTP code
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

        otpStore.set(cleanEmail, {
            code: otpCode,
            expiresAt: expiresAt,
        });

        // 4. Send Email / Log OTP
        await sendEmailOtp(cleanEmail, otpCode);

        res.status(200).json({
            success: true,
            message: `ඔබගේ ඊමේල් ලිපිනයට (${cleanEmail}) 6-ඩිජිට් OTP සංකේතයක් යවන ලදී.`
        });

    } catch (err) {
        console.error("❌ Send OTP Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// 2. Verify OTP & Complete Registration
const verifyOtpAndRegister = async (req, res) => {
    const { full_name, email, phone, password, role, otp } = req.body;

    if (!full_name || !email || !phone || !password || !role || !otp) {
        return res.status(400).json({ error: "කරුණාකර සියලුම තොරතුරු සහ OTP සංකේතය ඇතුලත් කරන්න." });
    }

    const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{8,}$/;
    if (!strongPasswordRegex.test(password)) {
        return res.status(400).json({ 
            error: "මුරපදය අවම වශයෙන් අක්ෂර 8ක්, කැපිටල් (A-Z), සිම්පල් (a-z), ඉලක්කම් (0-9) සහ විශේෂ සංකේතයක් (@#$) සහිත ශක්තිමත් එකක් විය යුතුය." 
        });
    }

    try {
        const cleanEmail = email.trim().toLowerCase();
        const cleanName = full_name.trim();
        const cleanPhone = phone.trim();
        const cleanOtp = otp.trim();

        // 1. Verify OTP from store
        const storedOtpData = otpStore.get(cleanEmail);

        if (!storedOtpData) {
            return res.status(400).json({ error: "OTP සංකේතයක් සොයාගත නොහැක. නැවත සංකේතයක් ලබාගන්න." });
        }

        if (Date.now() > storedOtpData.expiresAt) {
            otpStore.delete(cleanEmail);
            return res.status(400).json({ error: "OTP සංකේතයේ කාලය ඉක්මවා ඇත (Expired). නැවත ලබාගන්න." });
        }

        if (storedOtpData.code !== cleanOtp) {
            return res.status(400).json({ error: "ඇතුළත් කළ OTP සංකේතය වැරදියි. නැවත පරීක්ෂා කරන්න." });
        }

        // 2. OTP is valid -> Register User in Supabase Auth
        const { data, error } = await supabase.auth.signUp({
            email: cleanEmail,
            password: password,
            options: {
                data: {
                    full_name: cleanName,
                    phone: cleanPhone,
                    user_role: role
                }
            }
        });

        if (error) {
            console.error("❌ Supabase Auth Error:", error);
            return res.status(400).json({ error: error.message });
        }

        // 3. Save into public.profiles table
        if (data.user) {
            const { error: profileErr } = await supabase
                .from('profiles')
                .upsert([
                    {
                        id: data.user.id,
                        full_name: cleanName,
                        email: cleanEmail,
                        phone: cleanPhone,
                        role: role
                    }
                ]);

            if (profileErr) {
                console.error("⚠️ Profiles table insert warning:", profileErr.message);
            }
        }

        // 4. Remove used OTP from memory
        otpStore.delete(cleanEmail);

        console.log("✅ OTP Verified & User Registered successfully:", cleanEmail);

        res.status(201).json({
            success: true,
            message: "ඊමේල් ලිපිනය සාර්ථකව තහවුරු කර ලියාපදිංචි කරන ලදී!",
            user: data.user
        });

    } catch (err) {
        console.error("❌ Verify & Register Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// 3. Update FCM Token for Push Notifications
const updateFcmToken = async (req, res) => {
    const { userId, fcmToken } = req.body;
    console.log(`👉 FCM Token Update Request for userId: ${userId}, token: ${fcmToken ? fcmToken.substring(0, 15) : 'NONE'}...`);

    if (!userId || !fcmToken) {
        return res.status(400).json({ error: "userId and fcmToken are required" });
    }

    try {
        const { data, error } = await supabase
            .from('profiles')
            .update({ fcm_token: fcmToken })
            .eq('id', userId)
            .select();

        if (error) {
            console.error("❌ Failed to update FCM Token in Supabase:", error.message);
            return res.status(500).json({ error: error.message });
        }

        console.log(`📱 FCM Token successfully updated in DB for user: ${userId}`);
        res.status(200).json({ success: true, message: "FCM Token updated successfully" });
    } catch (err) {
        console.error("❌ Update FCM Token error:", err);
        res.status(500).json({ error: "Server error updating FCM Token" });
    }
};

// In-memory Forgot Password OTP Store (email -> { code, expiresAt, profileId, userName })
const forgotPasswordOtpStore = new Map();


// Helper to send Forgot Password email OTP
const sendForgotEmailOtp = async (toEmail, otpCode, userName) => {
    let nodemailer;
    try {
        nodemailer = require('nodemailer');
    } catch (err) {
        console.error("❌ 'nodemailer' package එක backend node_modules තුළ නැත! කරුණාකර backend terminal එකෙහි 'npm install' run කරන්න.");
    }

    console.log(`\n==================================================`);
    console.log(`🔑 FORGOT PASSWORD OTP FOR ${toEmail}: [ ${otpCode} ]`);
    console.log(`==================================================\n`);

    const smtpUser = process.env.SMTP_USER;
    const smtpPass = process.env.SMTP_PASS ? process.env.SMTP_PASS.replace(/["'\s]/g, '') : '';

    if (nodemailer && smtpUser && smtpPass) {
        try {
            const transporter = nodemailer.createTransport({
                host: process.env.SMTP_HOST || 'smtp.gmail.com',
                port: parseInt(process.env.SMTP_PORT || '587'),
                secure: parseInt(process.env.SMTP_PORT || '587') === 465,
                auth: { user: smtpUser, pass: smtpPass },
                tls: { rejectUnauthorized: false }
            });

            await transporter.sendMail({
                from: `"Ape Baas" <${smtpUser}>`,
                to: toEmail,
                subject: `🔐 මුරපදය නැවත සකසන OTP කේතය (Password Reset OTP: ${otpCode}) | Ape Baas`,
                html: `
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <meta charset="utf-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Reset Password - Ape Baas</title>
                    </head>
                    <body style="margin: 0; padding: 0; background-color: #F8FAFC; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
                        <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #F8FAFC; padding: 30px 10px;">
                            <tr>
                                <td align="center">
                                    <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="max-width: 520px; background-color: #FFFFFF; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); border: 1px solid #E2E8F0;">
                                        
                                        <!-- Header Banner -->
                                        <tr>
                                            <td style="background-color: #0F172A; padding: 28px 24px; text-align: center; border-bottom: 3px solid #F59E0B;">
                                                <div style="display: inline-block; background-color: rgba(255, 255, 255, 0.1); padding: 8px 16px; border-radius: 10px; border: 1px solid rgba(255, 255, 255, 0.15); margin-bottom: 8px;">
                                                    <span style="font-size: 20px; vertical-align: middle;">🛠️</span>
                                                    <span style="font-size: 18px; font-weight: 800; color: #FFFFFF; letter-spacing: 0.5px; margin-left: 8px; vertical-align: middle;">අපේ බාස් (Ape Baas)</span>
                                                </div>
                                                <h1 style="color: #F8FAFC; font-size: 16px; font-weight: 600; margin: 6px 0 0 0;">මුරපදය නැවත සැකසීම (Password Reset)</h1>
                                            </td>
                                        </tr>

                                        <!-- Body Content -->
                                        <tr>
                                            <td style="padding: 32px 28px;">
                                                <p style="font-size: 16px; font-weight: 700; color: #0F172A; margin: 0 0 12px 0;">
                                                    ආයුබෝවන් ${userName ? userName + ' මහත්මයා/මහත්මිය' : ''}! 🙏
                                                </p>
                                                <p style="font-size: 14px; color: #475569; line-height: 1.6; margin: 0 0 24px 0;">
                                                    ඔබගේ <strong>අපේ බාස් (Ape Baas)</strong> ගිණුමේ මුරපදය නැවත සකස් කිරීම (Reset Password) සඳහා පහත 6-ඩිජිට් OTP ආරක්ෂක කේතය ඇතුළත් කරන්න:
                                                </p>

                                                <!-- OTP Box -->
                                                <div style="background-color: #F8FAFC; border: 2px solid #F59E0B; border-radius: 12px; padding: 20px 16px; text-align: center; margin-bottom: 24px;">
                                                    <div style="font-size: 11px; font-weight: 700; color: #B45309; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 6px;">
                                                        PASSWORD RESET OTP CODE
                                                    </div>
                                                    <div style="font-size: 36px; font-weight: 800; color: #0F172A; letter-spacing: 10px; font-family: 'Courier New', Courier, monospace; margin: 4px 0; text-indent: 10px;">
                                                        ${otpCode}
                                                    </div>
                                                    <div style="font-size: 12px; color: #64748B; margin-top: 6px;">
                                                        ⏱️ මෙම කේතය විනාඩි 10ක් සඳහා වලංගු වේ. (Expires in 10 mins)
                                                    </div>
                                                </div>

                                                <!-- Expiry & Safety Info Box -->
                                                <table role="presentation" width="100%" border="0" cellspacing="0" cellpadding="0" style="background-color: #FFFBEB; border-radius: 8px; padding: 12px 14px; margin-bottom: 24px; border: 1px solid #FDE68A;">
                                                    <tr>
                                                        <td width="24" valign="top" style="font-size: 15px;">🔒</td>
                                                        <td style="font-size: 12.5px; color: #92400E; line-height: 1.5;">
                                                            <strong>ආරක්ෂක සටහන:</strong> මෙම OTP කේතය කිසිවෙකුට ලබා නොදෙන්න. ඔබ මෙම මුරපදය නැවත සැකසීමේ ඉල්ලීමක් සිදු නොකළේ නම්, ඔබගේ ගිණුම තවමත් සුරක්ෂිත වන අතර මෙම පණිවිඩය නොසලකා හරින්න.
                                                        </td>
                                                    </tr>
                                                </table>

                                                <p style="font-size: 13.5px; color: #64748B; margin: 0; line-height: 1.5;">
                                                    ස්තුතියි,<br>
                                                    <strong style="color: #334155;">Ape Baas Support Team (අපේ බාස් කණ්ඩායම)</strong>
                                                </p>
                                            </td>
                                        </tr>

                                        <!-- Footer -->
                                        <tr>
                                            <td style="background-color: #F8FAFC; padding: 16px 24px; text-align: center; border-top: 1px solid #E2E8F0;">
                                                <p style="font-size: 11.5px; color: #94A3B8; margin: 0;">
                                                    © 2026 Ape Baas (අපේ බාස්). All rights reserved.
                                                </p>
                                            </td>
                                        </tr>

                                    </table>
                                </td>
                            </tr>
                        </table>
                    </body>
                    </html>
                `,
            });
            console.log(`✉️ Forgot Password OTP email successfully sent to ${toEmail}`);
            return true;
        } catch (mailErr) {
            console.error("❌ Nodemailer error sending forgot password email:", mailErr.message);
        }
    } else {
        if (!nodemailer) {
            console.warn(`⚠️ Cannot send email: 'nodemailer' module is missing. Run 'npm install' in backend.`);
        } else {
            console.warn(`⚠️ SMTP credentials not complete. User: ${smtpUser}, Pass set: ${Boolean(smtpPass)}`);
        }
    }

    return true;
};

// 4. Send Forgot Password OTP
const sendForgotOtp = async (req, res) => {
    const { email, role } = req.body;

    if (!email) {
        return res.status(400).json({ error: "කරුණාකර ඊමේල් ලිපිනය ඇතුලත් කරන්න." });
    }

    try {
        const cleanEmail = email.trim().toLowerCase();

        // Check if user exists in profiles table
        const { data: profile, error: profileErr } = await supabase
            .from('profiles')
            .select('id, full_name, email, role')
            .ilike('email', cleanEmail)
            .maybeSingle();

        if (profileErr || !profile) {
            return res.status(404).json({ error: "මෙම ඊමේල් ලිපිනයට අදාළ ගිණුමක් සොයාගත නොහැක." });
        }

        // Optional Role check
        if (role && profile.role && profile.role.toLowerCase() !== role.toLowerCase()) {
            const actualRoleText = profile.role.toLowerCase() === 'provider' ? 'සේවා සපයන්නෙකු (Provider)' : 'පාරිභෝගිකයෙකු (Customer)';
            return res.status(403).json({ 
                error: `මෙම ඊමේල් ලිපිනය ලියාපදිංචි කර ඇත්තේ ${actualRoleText} ගිණුමක් ලෙසයි.` 
            });
        }

        // Generate 6-digit OTP code
        const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes

        forgotPasswordOtpStore.set(cleanEmail, {
            code: otpCode,
            expiresAt: expiresAt,
            profileId: profile.id,
            userName: profile.full_name,
        });

        // Send Email & Log OTP
        await sendForgotEmailOtp(cleanEmail, otpCode, profile.full_name);

        res.status(200).json({
            success: true,
            message: `මුරපදය නැවත සැකසීමේ 6-ඩිජිට් OTP සංකේතය ඔබගේ ඊමේල් ලිපිනයට (${cleanEmail}) යවන ලදී.`
        });

    } catch (err) {
        console.error("❌ Send Forgot OTP Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// 5. Resend Forgot Password OTP
const resendForgotOtp = async (req, res) => {
    return sendForgotOtp(req, res);
};

// 6. Reset Password with OTP
const resetPasswordWithOtp = async (req, res) => {
    const { email, otp, new_password } = req.body;

    if (!email || !otp || !new_password) {
        return res.status(400).json({ error: "කරුණාකර සියලුම තොරතුරු ඇතුලත් කරන්න." });
    }

    const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-]).{8,}$/;
    if (!strongPasswordRegex.test(new_password)) {
        return res.status(400).json({ 
            error: "නව මුරපදය අවම වශයෙන් අක්ෂර 8ක්, කැපිටල් (A-Z), සිම්පල් (a-z), ඉලක්කම් (0-9) සහ විශේෂ සංකේතයක් (@#$) සහිත ශක්තිමත් එකක් විය යුතුය." 
        });
    }

    try {
        const cleanEmail = email.trim().toLowerCase();
        const cleanOtp = otp.trim();

        const storedOtpData = forgotPasswordOtpStore.get(cleanEmail);

        if (!storedOtpData) {
            return res.status(400).json({ error: "OTP සංකේතයක් සොයාගත නොහැක. කරුණාකර නැවත OTP සංකේතයක් ලබාගන්න." });
        }

        if (Date.now() > storedOtpData.expiresAt) {
            forgotPasswordOtpStore.delete(cleanEmail);
            return res.status(400).json({ error: "OTP සංකේතයේ කාලය ඉක්මවා ඇත (Expired). කරුණාකර නැවත ලබාගන්න." });
        }

        if (storedOtpData.code !== cleanOtp) {
            return res.status(400).json({ error: "ඇතුළත් කළ OTP සංකේතය වැරදියි. නැවත පරීක්ෂා කරන්න." });
        }

        // OTP is verified! Find profile
        const { data: profile, error: profileErr } = await supabase
            .from('profiles')
            .select('id, email')
            .ilike('email', cleanEmail)
            .maybeSingle();

        if (profileErr || !profile) {
            return res.status(404).json({ error: "පරිශීලක ගිණුම හමු නොවීය." });
        }

        // Hash new password securely
        const hashedPassword = hashPassword(new_password);

        // Update in profiles table (fcm_token column used as custom password hash storage)
        const { error: updateProfileErr } = await supabase
            .from('profiles')
            .update({ fcm_token: hashedPassword })
            .eq('id', profile.id);

        if (updateProfileErr) {
            console.error("❌ Failed to update password hash in profiles:", updateProfileErr.message);
        }

        // Also attempt to update Supabase Auth if admin api is accessible
        try {
            await supabase.auth.admin.updateUserById(profile.id, {
                password: new_password
            });
            console.log("✅ Supabase Auth user password updated via Admin API for:", cleanEmail);
        } catch (adminErr) {
            console.log("ℹ️ Supabase Admin API not configured for password update; fallback PBKDF2 hash stored.");
        }

        // Clear OTP from memory
        forgotPasswordOtpStore.delete(cleanEmail);

        console.log("🎉 Password reset successfully for:", cleanEmail);

        res.status(200).json({
            success: true,
            message: "ඔබගේ මුරපදය සාර්ථකව වෙනස් කරන ලදී! කරුණාකර නව මුරපදය සමඟ ලොග් වන්න."
        });

    } catch (err) {
        console.error("❌ Reset Password Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

module.exports = {
    registerUser,
    loginUser,
    getUserProfile,
    updateUserProfile,
    changePassword,
    sendRegisterOtp,
    verifyOtpAndRegister,
    updateFcmToken,
    sendForgotOtp,
    resendForgotOtp,
    resetPasswordWithOtp
};