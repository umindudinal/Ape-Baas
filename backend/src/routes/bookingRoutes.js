const express = require('express');
const router = express.Router();
const { createBooking, getProviderBookings, acceptBooking, getMyJobs, completeBooking, getCustomerBookings } = require('../controllers/bookingController');

// POST /api/bookings
router.post('/', createBooking);

// GET /api/bookings/customer/:customerId (පාරිභෝගිකයාගේ වෙන්කිරීම් ලබාගැනීමට)
router.get('/customer/:customerId', getCustomerBookings);

// GET /api/bookings/provider/:providerId
router.get('/provider/:providerId', getProviderBookings);

// PUT /api/bookings/:bookingId/accept (වැඩක් භාරගැනීමට)
router.put('/:bookingId/accept', acceptBooking);

// PUT /api/bookings/:bookingId/complete (වැඩක් අවසන් කිරීමට)
router.put('/:bookingId/complete', completeBooking);

// GET /api/bookings/provider/:providerId/my-jobs (භාරගත්/අවසන් කළ වැඩ බැලීමට)
router.get('/provider/:providerId/my-jobs', getMyJobs);

module.exports = router;