const SUPABASE_URL = "https://ovfqxlyowieggsveqhic.supabase.co";
const SUPABASE_KEY = "sb_publishable_GMCVy37M9B6oVbgLR_vLag_dKRzOoGV";

// Database එකේ දැනට තියෙන Reviews (Supabase Quota Exceeded හෝ Offline අවස්ථාවල පෙන්වීම සඳහා Fallback)
export const DEFAULT_DATABASE_REVIEWS = [
  {
    id: 1,
    name: "S L Dissanayaka",
    city: "Polonnaruwa",
    service: "Electrical Repair",
    quote: "ගෙදර main breaker එකේ දෝශයක් ඇවිත් ape baas එකෙන් electrician කෙනෙක් ගෙන්නුවා. පැයක් ඇතුලත ඇවිත් වැඩේ ඉක්මනටම කරලා දුන්නා. ගොඩක් විශ්වාසවන්තයි!",
    stars: 5,
    avatarBg: "from-purple-500 to-indigo-600",
    date: "02/09/2026"
  },
  {
    id: 3,
    name: "Nandani Walpita",
    city: "Horana",
    service: "AC Service Booking",
    quote: "AC එකේ cooling අඩු වෙලා තිබුණේ. පැය බාගයක් ඇතුලත technician ආවා. Service එක සුපිරි සහ සාධාරණ ගාස්තුවක් ගත්තේ.",
    stars: 5,
    avatarBg: "from-sky-500 to-blue-600",
    date: "02/09/2026"
  },
  {
    id: 4,
    name: "Methuli Binara",
    city: "Medirigiriya",
    service: "Solar Power Service",
    quote: "Solar panel cleaning සහ inverter check-up එකක් කරගත්තා. Professional විදියට වැඩේ කරලා දුන්නා. Excellent service!",
    stars: 5,
    avatarBg: "from-purple-500 to-indigo-800",
    date: "02/09/2026"
  }
];

/**
 * Fetch all comments from Supabase table 'comments'
 */
export async function fetchReviewsFromSupabase() {
  try {
    const res = await fetch(`${SUPABASE_URL}/rest/v1/comments?select=*&order=created_at.desc`, {
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    });

    if (!res.ok) {
      console.warn("Supabase comments table fetch status:", res.status, "- Fallback to default database reviews.");
      return DEFAULT_DATABASE_REVIEWS;
    }

    const data = await res.json();
    if (!Array.isArray(data) || data.length === 0) {
      return DEFAULT_DATABASE_REVIEWS;
    }

    // Map DB fields to Component format
    return data.map(item => ({
      id: item.id || Date.now(),
      name: item.name || "Anonymous",
      city: item.city || "Sri Lanka",
      service: item.service || "General Service",
      quote: item.quote || "",
      stars: item.stars || 5,
      avatarBg: item.avatar_bg || "from-emerald-500 to-teal-600",
      date: item.created_at ? new Date(item.created_at).toLocaleDateString('en-GB') : new Date().toLocaleDateString('en-GB')
    }));
  } catch (e) {
    console.error("Supabase fetch error:", e);
    return DEFAULT_DATABASE_REVIEWS;
  }
}

/**
 * Insert a new comment into Supabase table 'comments'
 */
export async function saveReviewToSupabase(reviewObj) {
  try {
    const payload = {
      name: reviewObj.name,
      city: reviewObj.city,
      service: reviewObj.service,
      quote: reviewObj.quote,
      stars: reviewObj.stars,
      avatar_bg: reviewObj.avatarBg,
      created_at: new Date().toISOString()
    };

    const res = await fetch(`${SUPABASE_URL}/rest/v1/comments`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      const errText = await res.text();
      console.warn("Supabase save error response:", res.status, errText);
      return false;
    }

    const insertedData = await res.json();
    return insertedData;
  } catch (e) {
    console.error("Supabase save exception:", e);
    return false;
  }
}
