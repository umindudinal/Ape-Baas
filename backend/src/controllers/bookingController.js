const supabase = require('../config/supabase');
const { sendPushNotification } = require('../config/firebase');

// අලුත් Booking එකක් සෑදීම
const createBooking = async (req, res) => {
    console.log("👉 අලුත් Booking ඉල්ලීමක් ආවා:", req.body);

    const { customer_id, provider_id, issue, address, date } = req.body;

    // දත්ත සියල්ලම එවා ඇත්දැයි පරීක්ෂා කිරීම
    if (!customer_id || !provider_id || !issue || !address || !date) {
        return res.status(400).json({ error: "කරුණාකර සියලුම විස්තර ඇතුළත් කරන්න." });
    }

    try {
        // Supabase එකේ 'bookings' table එකට දත්ත ඇතුළත් කිරීම
        const { data, error } = await supabase
            .from('bookings')
            .insert([
                {
                    customer_id: customer_id,
                    provider_id: provider_id,
                    issue: issue,
                    address: address,
                    service_date: date,
                    status: 'pending' // මුලින්ම ඉල්ලීම යවද්දී status එක 'pending' (රැඳී සිටින) වේ
                }
            ])
            .select();

        if (error) {
            console.error("❌ Database Error එක:", error);
            return res.status(400).json({ error: error.message });
        }

        // Trigger Push Notification to Service Provider
        try {
            console.log(`🔍 Looking up FCM token for provider_id: ${provider_id}`);
            const { data: providerProfile, error: profErr } = await supabase
                .from('profiles')
                .select('fcm_token')
                .eq('id', provider_id)
                .maybeSingle();

            console.log(`🔍 Provider Profile fetched:`, providerProfile, "Error:", profErr);

            const { data: customerProfile } = await supabase
                .from('profiles')
                .select('full_name')
                .eq('id', customer_id)
                .maybeSingle();

            if (providerProfile && providerProfile.fcm_token) {
                const custName = customerProfile?.full_name || 'පාරිභෝගිකයෙකු';
                const createdBookingId = data && data.length > 0 ? String(data[0].id) : '';
                console.log(`✉️ Sending FCM Push Notification to token: ${providerProfile.fcm_token.substring(0, 15)}...`);
                await sendPushNotification(
                    providerProfile.fcm_token,
                    '🛠️ අලුත් සේවා ඉල්ලීමක්! | හොඳ බාස්',
                    `${custName} විසින් නව සේවා ඉල්ලීමක් ඉදිරිපත් කර ඇත: ${issue}`,
                    { type: 'booking', bookingId: createdBookingId, recipientRole: 'provider' }
                );
            } else {
                console.log(`⚠️ Push notification skipped: Provider ${provider_id} has no fcm_token in DB!`);
            }
        } catch (pushErr) {
            console.warn("⚠️ Push notification error on booking create:", pushErr.message);
        }

        console.log("✅ Booking එක සාර්ථකව සේව් වුණා!");
        res.status(201).json({ 
            success: true, 
            message: "ඔබගේ ඉල්ලීම සාර්ථකව යවන ලදී!" 
        });

    } catch (err) {
        console.error("❌ Server Error එක:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// බාස් කෙනෙකුට ලැබී ඇති වැඩ (Bookings) ලබා ගැනීම
const getProviderBookings = async (req, res) => {
    const { providerId } = req.params;

    try {
        // අදාළ provider_id එකට ඇති, status එක 'pending' වන bookings ලබාගැනීම
        const { data: bookings, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('provider_id', providerId)
            .eq('status', 'pending')
            .order('created_at', { ascending: false });

        if (error) {
            console.error("❌ Database Error:", error);
            return res.status(400).json({ error: error.message });
        }

        const customerIds = (bookings || []).map(b => b.customer_id).filter(Boolean);
        let customerMap = {};
        if (customerIds.length > 0) {
            const { data: customers } = await supabase
                .from('profiles')
                .select('id, full_name, phone, profile_image_url')
                .in('id', customerIds);

            (customers || []).forEach(c => {
                customerMap[c.id] = c;
            });
        }

        const enrichedBookings = (bookings || []).map(b => {
            const customerInfo = customerMap[b.customer_id] || {};
            return {
                ...b,
                customer_name: customerInfo.full_name || 'පාරිභෝගිකයා',
                customer_phone: customerInfo.phone || '',
                customer_image_url: customerInfo.profile_image_url || '',
            };
        });

        res.status(200).json({ success: true, data: enrichedBookings });

    } catch (err) {
        console.error("❌ Server Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්." });
    }
};

// බාස් විසින් වැඩක් (Booking එකක්) භාරගැනීම
const acceptBooking = async (req, res) => {
    const { bookingId } = req.params;

    try {
        // 1. Get target booking details
        const { data: targetBooking, error: fetchErr } = await supabase
            .from('bookings')
            .select('provider_id, customer_id, issue')
            .eq('id', bookingId)
            .maybeSingle();

        if (fetchErr || !targetBooking) {
            return res.status(404).json({ error: "Booking එක සොයාගත නොහැක." });
        }

        const providerId = targetBooking.provider_id;

        // 2. Check if provider already has an active (accepted) booking
        const { data: activeBookings } = await supabase
            .from('bookings')
            .select('id')
            .eq('provider_id', providerId)
            .eq('status', 'accepted');

        if (activeBookings && activeBookings.length > 0) {
            return res.status(400).json({ 
                error: "ඔබ දැනටමත් වෙනත් සේවාවක් භාරගෙන (Active) ඇත. එම සේවාව අවසන් (Complete) කිරීමෙන් පසුව පමණක් නව සේවාවක් භාරගත හැක." 
            });
        }

        // 3. Update status to 'accepted'
        const { error } = await supabase
            .from('bookings')
            .update({ status: 'accepted' })
            .eq('id', bookingId);

        if (error) {
            console.error("❌ Database Error:", error);
            return res.status(400).json({ error: error.message });
        }

        // 4. Trigger Push Notification to Customer
        try {
            const { data: customerProfile } = await supabase
                .from('profiles')
                .select('fcm_token')
                .eq('id', targetBooking.customer_id)
                .maybeSingle();

            if (customerProfile && customerProfile.fcm_token) {
                sendPushNotification(
                    customerProfile.fcm_token,
                    '✅ සේවා ඉල්ලීම භාරගන්නා ලදී! | හොඳ බාස්',
                    `ඔබගේ සේවා ඉල්ලීම (${targetBooking.issue}) සේවා සපයන්නා විසින් සාර්ථකව භාරගන්නා ලදී.`,
                    { type: 'booking', bookingId: String(bookingId) }
                );
            }
        } catch (pushErr) {
            console.warn("⚠️ Push notification error on accept booking:", pushErr.message);
        }

        res.status(200).json({ 
            success: true, 
            message: "ඔබ මෙම සේවාව සාර්ථකව භාරගන්නා ලදී!" 
        });

    } catch (err) {
        console.error("❌ Server Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්." });
    }
};

// බාස් විසින් භාරගත් සහ අවසන් කළ වැඩ ලබා ගැනීම
const getMyJobs = async (req, res) => {
    const { providerId } = req.params;

    try {
        const { data: bookings, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('provider_id', providerId)
            .in('status', ['accepted', 'completed']) // භාරගත් සහ අවසන් කළ ඒවා පමණක්
            .order('created_at', { ascending: false });

        if (error) {
            console.error("❌ Database Error:", error);
            return res.status(400).json({ error: error.message });
        }

        const customerIds = (bookings || []).map(b => b.customer_id).filter(Boolean);
        const bookingIds = (bookings || []).map(b => b.id).filter(Boolean);

        let customerMap = {};
        if (customerIds.length > 0) {
            const { data: customers } = await supabase
                .from('profiles')
                .select('id, full_name, phone, profile_image_url')
                .in('id', customerIds);

            (customers || []).forEach(c => {
                customerMap[c.id] = c;
            });
        }

        let reviewMap = {};
        if (bookingIds.length > 0) {
            const { data: reviews } = await supabase
                .from('reviews')
                .select('*')
                .in('booking_id', bookingIds);

            (reviews || []).forEach(r => {
                reviewMap[r.booking_id] = r;
            });
        }

        const enrichedJobs = (bookings || []).map(b => {
            const customerInfo = customerMap[b.customer_id] || {};
            const reviewInfo = reviewMap[b.id] || null;
            return {
                ...b,
                customer_name: customerInfo.full_name || 'පාරිභෝගිකයා',
                customer_phone: customerInfo.phone || '',
                customer_image_url: customerInfo.profile_image_url || '',
                review: reviewInfo,
            };
        });

        res.status(200).json({ success: true, data: enrichedJobs });

    } catch (err) {
        console.error("❌ Server Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්." });
    }
};

// බාස් විසින් වැඩක් අවසන් කිරීම (Complete Booking)
const completeBooking = async (req, res) => {
    const { bookingId } = req.params;

    try {
        const { data, error } = await supabase
            .from('bookings')
            .update({ status: 'completed' })
            .eq('id', bookingId);

        if (error) {
            console.error("❌ Database Error:", error);
            return res.status(400).json({ error: error.message });
        }

        res.status(200).json({ 
            success: true, 
            message: "සේවාව සාර්ථකව අවසන් කරන ලදී!" 
        });

    } catch (err) {
        console.error("❌ Server Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්." });
    }
};

// පාරිභෝගිකයාගේ (Customer) සියලුම වෙන්කිරීම් (Bookings) ලබා ගැනීම
const getCustomerBookings = async (req, res) => {
    const { customerId } = req.params;

    try {
        // 1. bookings table එකෙන් පාරිභෝගිකයාගේ සියලුම bookings ලබා ගැනීම
        const { data: bookings, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('customer_id', customerId)
            .order('created_at', { ascending: false });

        if (error) throw error;

        // 2. profiles table එකෙන් සේවා සපයන්නන්ගේ (Providers) විස්තර ලබා ගැනීම
        const providerIds = (bookings || []).map(b => b.provider_id).filter(Boolean);
        const bookingIds = (bookings || []).map(b => b.id).filter(Boolean);

        let providerMap = {};
        if (providerIds.length > 0) {
            const { data: providers } = await supabase
                .from('profiles')
                .select('id, full_name, phone, profile_image_url')
                .in('id', providerIds);

            (providers || []).forEach(p => {
                providerMap[p.id] = p;
            });
        }

        let reviewMap = {};
        if (bookingIds.length > 0) {
            const { data: reviews } = await supabase
                .from('reviews')
                .select('*')
                .in('booking_id', bookingIds);

            (reviews || []).forEach(r => {
                reviewMap[r.booking_id] = r;
            });
        }

        const enrichedBookings = (bookings || []).map(b => {
            const providerInfo = providerMap[b.provider_id] || {};
            const reviewInfo = reviewMap[b.id] || null;
            return {
                ...b,
                provider_name: providerInfo.full_name || 'සේවා සපයන්නා',
                provider_phone: providerInfo.phone || 'නොමැත',
                provider_image_url: providerInfo.profile_image_url || '',
                provider: {
                    id: b.provider_id,
                    full_name: providerInfo.full_name || 'සේවා සපයන්නා',
                    phone: providerInfo.phone || 'නොමැත',
                    profile_image_url: providerInfo.profile_image_url || ''
                },
                review: reviewInfo,
            };
        });

        res.status(200).json({ success: true, data: enrichedBookings });

    } catch (err) {
        console.error("❌ Get Customer Bookings Error:", err);
        res.status(500).json({ success: false, error: err.message });
    }
};

module.exports = { 
    createBooking, 
    getProviderBookings, 
    acceptBooking, 
    getMyJobs, 
    completeBooking, 
    getCustomerBookings 
};
