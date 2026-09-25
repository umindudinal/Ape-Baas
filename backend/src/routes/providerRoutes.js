const express = require('express');
const router = express.Router();
const { 
  registerProviderDetails, 
  getProviderDetails, 
  getAllProviders, 
  updateProviderNicDocuments,
  updateProviderPortfolio
} = require('../controllers/providerController');

// POST /api/providers/onboarding
router.post('/onboarding', registerProviderDetails);

// GET /api/providers/all (සියලුම සේවා සපයන්නන් ලබා ගැනීම)
router.get('/all', getAllProviders);

// GET /api/providers/details/:providerId
router.get('/details/:providerId', getProviderDetails);

// PUT /api/providers/nic-documents (NIC ඡායාරූප යාවත්කාලීන කිරීමට)
router.put('/nic-documents', updateProviderNicDocuments);

// PUT /api/providers/portfolio (වැඩවල ඡායාරූප යාවත්කාලීන කිරීමට)
router.put('/portfolio', updateProviderPortfolio);

module.exports = router;