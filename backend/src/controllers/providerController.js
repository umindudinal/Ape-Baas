const supabase = require('../config/supabase');

const registerProviderDetails = async (req, res) => {
  const { 
    user_id, 
    service_category, 
    nic_number, 
    nic_front_url, 
    nic_back_url, 
    experience_years, 
    working_radius_km,
    district,
    city,
    address 
  } = req.body;

  try {
    // 1. provider_details table එකට දත්ත ඇතුළත් කිරීම (upsert මගින්)
    const { data, error } = await supabase
      .from('provider_details')
      .upsert([
        {
          id: user_id, 
          service_category,
          nic_number,
          nic_front_url,
          nic_back_url,
          experience_years,
          working_radius_km,
          is_verified: false // Admin අනුමත කරනතෙක් මෙය false වේ
        }
      ], { onConflict: 'id' });

    if (error) throw error;

    // 2. profiles table එකෙහි district සහ city කෙලින්ම upsert කිරීම
    const profileUpdates = { id: user_id };
    if (district) profileUpdates.district = district;
    if (city) profileUpdates.city = city;
    if (address) profileUpdates.address = address;

    if (Object.keys(profileUpdates).length > 1) {
      await supabase
        .from('profiles')
        .upsert(profileUpdates, { onConflict: 'id' });
    }

    res.status(200).json({ 
      success: true, 
      message: 'ඔබගේ විස්තර සාර්ථකව ඇතුළත් කරන ලදී. පද්ධති පරිපාලක විසින් අනුමත කරන තෙක් රැඳී සිටින්න.' 
    });
    
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

const getProviderDetails = async (req, res) => {
  const { providerId } = req.params;

  try {
    // 1. profiles table එකෙන් full_name, email, phone, address, profile_image_url ලබා ගැනීම
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', providerId)
      .maybeSingle();

    if (profileError) throw profileError;

    // 2. provider_details table එකෙන් service_category, nic_number, experience_years, working_radius_km, is_verified ලබා ගැනීම
    const { data: providerDetails, error: detailsError } = await supabase
      .from('provider_details')
      .select('*')
      .eq('id', providerId)
      .maybeSingle();

    if (detailsError) throw detailsError;

    // 3. reviews table එකෙන් සැබෑ Rating හා Reviews සංඛ්‍යාව ගණනය කිරීම
    const { data: reviews } = await supabase
      .from('reviews')
      .select('rating')
      .eq('provider_id', providerId);

    let totalRating = 0;
    const totalReviews = reviews ? reviews.length : 0;
    if (totalReviews > 0) {
      totalRating = reviews.reduce((sum, r) => sum + (Number(r.rating) || 0), 0);
    }
    const avgRating = totalReviews > 0 ? parseFloat((totalRating / totalReviews).toFixed(1)) : 0.0;

    // 4. දත්ත සියල්ලම එකතු කර (Merge) යැවීම
    const mergedData = {
      ...(profile || {}),
      ...(providerDetails || {}),
      rating: avgRating,
      average_rating: avgRating,
      total_reviews: totalReviews
    };

    res.status(200).json({ 
      success: true, 
      data: mergedData 
    });
  } catch (error) {
    console.error("❌ Get Provider Details Error:", error);
    res.status(400).json({ success: false, error: error.message });
  }
};

// සියලුම සේවා සපයන්නන්ගේ (Providers) ලැයිස්තුව ලබා ගැනීම
const getAllProviders = async (req, res) => {
  try {
    // 1. profiles table එකෙන් role = 'provider' අය ලබා ගැනීම
    const { data: providers, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('role', 'provider');

    if (error) throw error;

    // 2. provider_details table එකෙන් අමතර විස්තර ලබා ගැනීම
    const { data: details, error: detailsError } = await supabase
      .from('provider_details')
      .select('*');

    if (detailsError) throw detailsError;

    // 3. reviews table එකෙන් සියලුම reviews ලබා ගෙන Provider අනුව Average Rating ගණනය කිරීම
    const { data: reviews } = await supabase
      .from('reviews')
      .select('provider_id, rating');

    const reviewsMap = {};
    (reviews || []).forEach(r => {
      if (r.provider_id) {
        if (!reviewsMap[r.provider_id]) {
          reviewsMap[r.provider_id] = { total: 0, count: 0 };
        }
        reviewsMap[r.provider_id].total += (Number(r.rating) || 0);
        reviewsMap[r.provider_id].count += 1;
      }
    });

    const detailsMap = {};
    (details || []).forEach(d => {
      detailsMap[d.id] = d;
    });

    const result = (providers || []).map(p => {
      const d = detailsMap[p.id] || {};
      const r = reviewsMap[p.id] || { total: 0, count: 0 };
      const avgRating = r.count > 0 ? parseFloat((r.total / r.count).toFixed(1)) : 0.0;

      return {
        id: p.id,
        name: p.full_name || 'සේවා සපයන්නා',
        full_name: p.full_name || 'සේවා සපයන්නා',
        email: p.email,
        phone: p.phone,
        address: p.address,
        district: p.district || '',
        city: p.city || '',
        profile_image_url: p.profile_image_url,
        service_category: d.service_category || 'සඳහන් කර නැත',
        nic_number: d.nic_number,
        experience_years: d.experience_years || 0,
        working_radius_km: d.working_radius_km || 0,
        is_verified: d.is_verified || false,
        portfolio_images: d.portfolio_images || [],
        rating: avgRating,
        average_rating: avgRating,
        total_reviews: r.count
      };
    });

    res.status(200).json({
      success: true,
      data: result
    });

  } catch (error) {
    console.error("❌ Get All Providers Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// සේවා සපයන්නාගේ NIC ඉදිරිපස සහ පසුපස ඡායාරූප (NIC Documents) යාවත්කාලීන කිරීම
const updateProviderNicDocuments = async (req, res) => {
  const { provider_id, nic_front_url, nic_back_url } = req.body;

  try {
    if (!provider_id) {
      return res.status(400).json({ success: false, error: "Provider ID අවශ්‍ය වේ." });
    }

    // Check if provider_details record exists and if NIC is already verified
    const { data: existing } = await supabase
      .from('provider_details')
      .select('id, nic_front_url, nic_back_url, is_verified')
      .eq('id', provider_id)
      .maybeSingle();

    if (existing && existing.nic_front_url && existing.nic_back_url && existing.is_verified) {
      return res.status(400).json({
        success: false,
        error: "ඔබගේ ගිණුම දැනටමත් Verify කර ඇති බැවින් ජාතික හැඳුනුම්පත් ඡායාරූප නැවත වෙනස් කිරීමට නොහැක."
      });
    }

    if (existing) {
      const { error } = await supabase
        .from('provider_details')
        .update({
          ...(nic_front_url && { nic_front_url }),
          ...(nic_back_url && { nic_back_url }),
          verification_status: 'Pending',
          rejection_reason: null,
        })
        .eq('id', provider_id);
      if (error) throw error;
    } else {
      const { error } = await supabase
        .from('provider_details')
        .insert([
          {
            id: provider_id,
            nic_front_url: nic_front_url || '',
            nic_back_url: nic_back_url || '',
            is_verified: false,
            verification_status: 'Pending',
          }
        ]);
      if (error) throw error;
    }

    res.status(200).json({
      success: true,
      message: 'ඔබගේ ජාතික හැඳුනුම්පත් ඡායාරූප සාර්ථකව යවන ලදී. පරිපාලක (Admin) අනුමැතිය සඳහා යොමු කර ඇත.'
    });

  } catch (error) {
    console.error("❌ Update NIC Documents Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

// සේවා සපයන්නාගේ වැඩවල ඡායාරූප (Work Portfolio) යාවත්කාලීන කිරීම
const updateProviderPortfolio = async (req, res) => {
  const { provider_id, portfolio_images } = req.body;

  try {
    if (!provider_id || !Array.isArray(portfolio_images)) {
      return res.status(400).json({ success: false, error: "Provider ID සහ portfolio_images Array එක අවශ්‍ය වේ." });
    }

    const { data: existing } = await supabase
      .from('provider_details')
      .select('id')
      .eq('id', provider_id)
      .maybeSingle();

    if (existing) {
      const { error } = await supabase
        .from('provider_details')
        .update({ portfolio_images })
        .eq('id', provider_id);
      if (error) throw error;
    } else {
      const { error } = await supabase
        .from('provider_details')
        .insert([{ id: provider_id, portfolio_images }]);
      if (error) throw error;
    }

    res.status(200).json({
      success: true,
      message: 'ඔබ කළ වැඩවල ඡායාරූප (Portfolio) සාර්ථකව යාවත්කාලීන කරන ලදී!'
    });
  } catch (error) {
    console.error("❌ Update Portfolio Error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = { 
  registerProviderDetails, 
  getProviderDetails, 
  getAllProviders,
  updateProviderNicDocuments,
  updateProviderPortfolio
};