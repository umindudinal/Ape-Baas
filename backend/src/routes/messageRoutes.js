const express = require('express');
const router = express.Router();
const { sendMessage, getMessages, getConversations } = require('../controllers/messageController');

router.post('/send', sendMessage);
router.get('/history', getMessages);
router.get('/conversations/:userId', getConversations);

module.exports = router;
