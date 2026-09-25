const supabase = require('../config/supabase');
const { sendPushNotification } = require('../config/firebase');

// Memory store fallback in case Supabase 'messages' table is not yet created
const inMemoryMessages = [];

// Send a new chat message
const sendMessage = async (req, res) => {
    const { sender_id, receiver_id, booking_id, text } = req.body;

    if (!sender_id || !receiver_id || !text || text.trim() === '') {
        return res.status(400).json({ error: 'sender_id, receiver_id and text are required.' });
    }

    const newMessage = {
        id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
        sender_id: sender_id,
        receiver_id: receiver_id,
        booking_id: booking_id || null,
        text: text.trim(),
        created_at: new Date().toISOString(),
    };

    // Helper to send FCM notification asynchronously
    const triggerChatPush = async () => {
        try {
            const { data: receiverProfile } = await supabase
                .from('profiles')
                .select('fcm_token')
                .eq('id', receiver_id)
                .maybeSingle();

            const { data: senderProfile } = await supabase
                .from('profiles')
                .select('full_name')
                .eq('id', sender_id)
                .maybeSingle();

            if (receiverProfile && receiverProfile.fcm_token) {
                const senderName = senderProfile?.full_name || 'පරිශීලකයෙකු';
                sendPushNotification(
                    receiverProfile.fcm_token,
                    `💬 ${senderName} ගෙන් නව පණිවිඩයක් | හොඳ බාස්`,
                    text.trim().length > 60 ? text.trim().substring(0, 60) + '...' : text.trim(),
                    { type: 'chat', senderId: sender_id, bookingId: String(booking_id || '') }
                );
            }
        } catch (e) {
            console.warn("⚠️ Chat push error:", e.message);
        }
    };

    try {
        const { data, error } = await supabase
            .from('messages')
            .insert([
                {
                    sender_id: sender_id,
                    receiver_id: receiver_id,
                    booking_id: booking_id || null,
                    text: text.trim(),
                }
            ])
            .select();

        triggerChatPush();

        if (error) {
            console.log("ℹ️ Supabase messages table fallback to in-memory:", error.message);
            inMemoryMessages.push(newMessage);
            return res.status(201).json({
                success: true,
                message: "පණිවිඩය සාර්ථකව යවන ලදී!",
                data: newMessage
            });
        }

        return res.status(201).json({
            success: true,
            message: "පණිවිඩය සාර්ථකව යවන ලදී!",
            data: data && data.length > 0 ? data[0] : newMessage
        });
    } catch (err) {
        console.error("❌ Send Message Error:", err);
        inMemoryMessages.push(newMessage);
        triggerChatPush();
        return res.status(201).json({
            success: true,
            message: "පණිවිඩය සාර්ථකව යවන ලදී!",
            data: newMessage
        });
    }
};

// Get chat history between two users
const getMessages = async (req, res) => {
    const { user1, user2 } = req.query;

    if (!user1 || !user2) {
        return res.status(400).json({ error: 'user1 and user2 query parameters are required.' });
    }

    try {
        const { data, error } = await supabase
            .from('messages')
            .select('*')
            .or(`and(sender_id.eq.${user1},receiver_id.eq.${user2}),and(sender_id.eq.${user2},receiver_id.eq.${user1})`)
            .order('created_at', { ascending: true });

        if (error) {
            console.log("ℹ️ Fetching messages from in-memory fallback");
            const dbFallback = inMemoryMessages.filter(
                m => (m.sender_id === user1 && m.receiver_id === user2) ||
                     (m.sender_id === user2 && m.receiver_id === user1)
            ).sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

            return res.json({ success: true, messages: dbFallback });
        }

        // Combine with any in-memory fallback messages if present
        const dbFallback = inMemoryMessages.filter(
            m => (m.sender_id === user1 && m.receiver_id === user2) ||
                 (m.sender_id === user2 && m.receiver_id === user1)
        );

        const allMessages = [...(data || []), ...dbFallback].sort(
            (a, b) => new Date(a.created_at) - new Date(b.created_at)
        );

        return res.json({ success: true, messages: allMessages });
    } catch (err) {
        console.error("❌ Get Messages Error:", err);
        const dbFallback = inMemoryMessages.filter(
            m => (m.sender_id === user1 && m.receiver_id === user2) ||
                 (m.sender_id === user2 && m.receiver_id === user1)
        ).sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

        return res.json({ success: true, messages: dbFallback });
    }
};

// Get all chat conversations list for a user
const getConversations = async (req, res) => {
    const { userId } = req.params;

    try {
        // Fetch profiles to map user details
        const { data: profiles } = await supabase.from('profiles').select('id, full_name, profile_image_url, role');
        const profileMap = {};
        if (profiles) {
            profiles.forEach(p => {
                profileMap[p.id] = p;
            });
        }

        // Fetch messages involving this user
        let messagesList = [];

        const { data, error } = await supabase
            .from('messages')
            .select('*')
            .or(`sender_id.eq.${userId},receiver_id.eq.${userId}`)
            .order('created_at', { ascending: false });

        if (!error && data) {
            messagesList = data;
        }

        const fallback = inMemoryMessages.filter(m => m.sender_id === userId || m.receiver_id === userId);
        messagesList = [...messagesList, ...fallback].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

        // Group by partner ID
        const conversationsMap = {};
        messagesList.forEach(msg => {
            const partnerId = msg.sender_id === userId ? msg.receiver_id : msg.sender_id;
            if (!conversationsMap[partnerId]) {
                const partnerProfile = profileMap[partnerId] || {};
                conversationsMap[partnerId] = {
                    partnerId: partnerId,
                    partnerName: partnerProfile.full_name || 'පරිශීලකයා',
                    partnerImage: partnerProfile.profile_image_url || '',
                    partnerRole: partnerProfile.role || '',
                    lastMessage: msg.text,
                    time: msg.created_at,
                    bookingId: msg.booking_id,
                };
            }
        });

        const conversations = Object.values(conversationsMap);
        res.json({ success: true, conversations: conversations });
    } catch (err) {
        console.error("❌ Get Conversations Error:", err);
        res.status(500).json({ error: "Server Error" });
    }
};

module.exports = {
    sendMessage,
    getMessages,
    getConversations,
};
