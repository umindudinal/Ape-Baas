const supabase = require('../config/supabase');

// 1. අලුත් Review/Rating එකක් එකතු කිරීම
const addReview = async (req, res) => {
    console.log("👉 අලුත් Review එකක් ආවා:", req.body);
    const { booking_id, customer_id, provider_id, rating, comment } = req.body;

    if (!customer_id || !provider_id || !rating || !comment) {
        return res.status(400).json({ error: "කරුණාකර සියලුම විස්තර සහ Rating එක ලබා දෙන්න." });
    }

    if (rating < 1 || rating > 5) {
        return res.status(400).json({ error: "Rating එක 1 ත් 5 ත් අතර විය යුතුය." });
    }

    try {
        if (booking_id) {
            const { data: existingReview } = await supabase
                .from('reviews')
                .select('id')
                .eq('booking_id', booking_id)
                .maybeSingle();

            if (existingReview) {
                const { error: updateErr } = await supabase
                    .from('reviews')
                    .update({
                        rating: parseInt(rating),
                        comment: comment.trim()
                    })
                    .eq('id', existingReview.id);

                if (updateErr) throw updateErr;

                console.log("✅ Review එක සාර්ථකව යාවත්කාලීන වුණා!");
                return res.status(200).json({
                    success: true,
                    message: "ඔබගේ සමාලෝචනය (Review) සාර්ථකව යාවත්කාලීන කරන ලදී!"
                });
            }
        }

        const { data, error } = await supabase
            .from('reviews')
            .insert([
                {
                    booking_id: booking_id || null,
                    customer_id: customer_id,
                    provider_id: provider_id,
                    rating: parseInt(rating),
                    comment: comment.trim()
                }
            ]);

        if (error) {
            console.error("❌ Supabase Review Insert Error:", error);
            return res.status(400).json({ error: error.message });
        }

        console.log("✅ Review එක සාර්ථකව සේව් වුණා!");
        res.status(201).json({
            success: true,
            message: "ඔබගේ සමාලෝචනය (Review) සාර්ථකව එක් කරන ලදී!"
        });
    } catch (err) {
        console.error("❌ Review Add Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක්. නැවත උත්සාහ කරන්න." });
    }
};

// 2. අදාළ Provider ට හිමි සියලුම Reviews සහ Average Rating එක ලබා ගැනීම
const getProviderReviews = async (req, res) => {
    const { providerId } = req.params;

    try {
        const { data: reviews, error } = await supabase
            .from('reviews')
            .select(`
                id,
                rating,
                comment,
                created_at,
                customer_id,
                profiles:customer_id (full_name, profile_image_url)
            `)
            .eq('provider_id', providerId)
            .order('created_at', { ascending: false });

        if (error) {
            console.error("❌ Supabase Get Reviews Error:", error);
            return res.status(400).json({ error: error.message });
        }

        // Calculate Average Rating
        let totalRating = 0;
        const totalReviews = reviews ? reviews.length : 0;

        if (totalReviews > 0) {
            totalRating = reviews.reduce((sum, r) => sum + (r.rating || 0), 0);
        }

        const avgRating = totalReviews > 0 ? (totalRating / totalReviews).toFixed(1) : "0.0";

        res.json({
            success: true,
            average_rating: parseFloat(avgRating),
            total_reviews: totalReviews,
            reviews: reviews || []
        });

    } catch (err) {
        console.error("❌ Get Provider Reviews Error:", err);
        res.status(500).json({ error: "සර්වර් එකේ දෝෂයක් සිදුවිය." });
    }
};

module.exports = {
    addReview,
    getProviderReviews
};
