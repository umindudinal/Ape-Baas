const express = require('express');
const router = express.Router();
const { addReview, getProviderReviews } = require('../controllers/reviewController');

// 1. Review එකක් එකතු කිරීම
router.post('/add', addReview);

// 2. Provider ගේ Reviews ලබා ගැනීම
router.get('/provider/:providerId', getProviderReviews);

module.exports = router;
