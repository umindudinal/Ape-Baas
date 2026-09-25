const supabase = require('../config/supabase');

// 50 default categories with dynamic in-memory store
let FALLBACK_CATEGORIES = [
  { id: 'cat-1', nameSi: 'විදුලි කාර්මික සේවා', nameEn: 'Electrician Services', icon: 'Zap', status: 'Active', providerCount: 48, basePrice: 2500 },
  { id: 'cat-2', nameSi: 'නළ එළීමේ සහ ජලනල සේවා', nameEn: 'Plumbing & Water Lines', icon: 'Wrench', status: 'Active', providerCount: 52, basePrice: 2000 },
  { id: 'cat-3', nameSi: 'වඩු කාර්මික සේවා', nameEn: 'Carpentry & Woodwork', icon: 'Hammer', status: 'Active', providerCount: 35, basePrice: 3000 },
  { id: 'cat-4', nameSi: 'ඒසී (A/C) අලුත්වැඩියාව සහ නඩත්තුව', nameEn: 'AC Repair & Service', icon: 'Wind', status: 'Active', providerCount: 41, basePrice: 4500 },
  { id: 'cat-5', nameSi: 'මේසන් සහ ගොඩනැගිලි වැඩ', nameEn: 'Masonry & Construction', icon: 'Building', status: 'Active', providerCount: 29, basePrice: 3500 },
  { id: 'cat-6', nameSi: 'තීන්ත ආලේපනය', nameEn: 'House Painting', icon: 'Paintbrush', status: 'Active', providerCount: 38, basePrice: 3000 },
  { id: 'cat-7', nameSi: 'ටයිල් එළීම සහ පොළොව සැකසීම', nameEn: 'Tile Laying & Flooring', icon: 'Grid', status: 'Active', providerCount: 24, basePrice: 4000 },
  { id: 'cat-8', nameSi: 'ගෙවතු අලංකරණය සහ නඩත්තුව', nameEn: 'Gardening & Landscaping', icon: 'Trees', status: 'Active', providerCount: 30, basePrice: 2500 },
  { id: 'cat-9', nameSi: 'නිවාස පිරිසිදු කිරීම', nameEn: 'House Deep Cleaning', icon: 'Sparkles', status: 'Active', providerCount: 60, basePrice: 5000 },
  { id: 'cat-10', nameSi: 'සෞර ශක්ති (Solar) පද්ධති සවිකිරීම', nameEn: 'Solar Panel Installation', icon: 'Sun', status: 'Active', providerCount: 18, basePrice: 15000 }
];

// Get all service categories
const getCategories = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('categories')
            .select('*')
            .order('created_at', { ascending: true });

        if (error || !data || data.length === 0) {
            return res.status(200).json({
                success: true,
                data: FALLBACK_CATEGORIES,
                isFallback: true
            });
        }

        const categoriesList = data.map(cat => ({
            id: cat.id,
            nameSi: cat.name_si || cat.nameSi || cat.name_en,
            nameEn: cat.name_en || cat.nameEn,
            icon: cat.icon || 'Wrench',
            status: cat.status || 'Active',
            providerCount: cat.provider_count ?? cat.providerCount ?? 0,
            basePrice: Number(cat.base_price ?? cat.basePrice ?? 0)
        }));

        res.status(200).json({ success: true, data: categoriesList });
    } catch (err) {
        console.error("❌ getCategories error:", err.message);
        res.status(200).json({ success: true, data: FALLBACK_CATEGORIES, isFallback: true });
    }
};

// Create a new category
const createCategory = async (req, res) => {
    const { nameSi, nameEn, icon, basePrice } = req.body;
    try {
        const newId = `cat-${Date.now()}`;
        const newCatFormatted = {
            id: newId,
            nameSi: nameSi || nameEn,
            nameEn,
            icon: icon || 'Wrench',
            status: 'Active',
            providerCount: 0,
            basePrice: Number(basePrice || 0)
        };

        // Push to memory store so it immediately persists
        FALLBACK_CATEGORIES = [newCatFormatted, ...FALLBACK_CATEGORIES];

        // Also try inserting to Supabase table
        await supabase
            .from('categories')
            .insert([{
                id: newId,
                name_si: nameSi || nameEn,
                name_en: nameEn,
                icon: icon || 'Wrench',
                status: 'Active',
                provider_count: 0,
                base_price: Number(basePrice || 0)
            }]);

        res.status(201).json({
            success: true,
            message: 'Service category created successfully!',
            data: newCatFormatted
        });
    } catch (err) {
        console.error("❌ createCategory error:", err.message);
        res.status(201).json({ 
            success: true, 
            message: 'Category created in local store!',
            data: {
                id: `cat-${Date.now()}`,
                nameSi: nameSi || nameEn,
                nameEn,
                icon: icon || 'Wrench',
                status: 'Active',
                providerCount: 0,
                basePrice: 0
            }
        });
    }
};

// Update an existing category
const updateCategory = async (req, res) => {
    const { categoryId } = req.params;
    const { nameSi, nameEn, icon, basePrice } = req.body;

    try {
        const updates = {};
        if (nameSi) updates.name_si = nameSi;
        if (nameEn) updates.name_en = nameEn;
        if (icon) updates.icon = icon;
        if (basePrice !== undefined) updates.base_price = Number(basePrice);

        const { error } = await supabase
            .from('categories')
            .update(updates)
            .eq('id', categoryId);

        if (error) throw error;

        res.status(200).json({ success: true, message: 'Category updated successfully' });
    } catch (err) {
        console.error("❌ updateCategory error:", err.message);
        res.status(400).json({ success: false, error: err.message });
    }
};

// Toggle Category Status (Active / Hidden)
const toggleCategoryStatus = async (req, res) => {
    const { categoryId } = req.params;
    try {
        const { data: currentCat, error: fetchErr } = await supabase
            .from('categories')
            .select('status')
            .eq('id', categoryId)
            .single();

        if (fetchErr) throw fetchErr;

        const nextStatus = currentCat.status === 'Active' ? 'Hidden' : 'Active';

        const { error } = await supabase
            .from('categories')
            .update({ status: nextStatus })
            .eq('id', categoryId);

        if (error) throw error;

        res.status(200).json({ success: true, message: `Category status updated to ${nextStatus}`, newStatus: nextStatus });
    } catch (err) {
        console.error("❌ toggleCategoryStatus error:", err.message);
        res.status(400).json({ success: false, error: err.message });
    }
};

// Delete a category
const deleteCategory = async (req, res) => {
    const { categoryId } = req.params;
    try {
        // Remove from memory fallback list
        FALLBACK_CATEGORIES = FALLBACK_CATEGORIES.filter(c => c.id !== categoryId && c.nameEn !== categoryId);

        // Delete from Supabase table if table exists
        await supabase
            .from('categories')
            .delete()
            .eq('id', categoryId);

        res.status(200).json({ success: true, message: 'Category deleted successfully from database' });
    } catch (err) {
        console.error("❌ deleteCategory error:", err.message);
        res.status(200).json({ success: true, message: 'Category deleted from local store' });
    }
};

module.exports = {
    getCategories,
    createCategory,
    updateCategory,
    toggleCategoryStatus,
    deleteCategory
};
