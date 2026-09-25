// අවශ්‍ය Packages ගෙන්වා ගැනීම
const express = require('express');
const cors = require('cors');
require('dotenv').config();

// Express App එක සෑදීම
const app = express();

// Middlewares
app.use(cors()); 
app.use(express.json({ limit: '50mb' })); 
app.use(express.urlencoded({ limit: '50mb', extended: true })); 

// අපි අලුතින් හදපු Routes මෙතනින් ගෙන්වා ගන්නවා
const authRoutes = require('./src/routes/authRoutes');
const providerRoutes = require('./src/routes/providerRoutes'); // අලුත් provider route එක
const bookingRoutes = require('./src/routes/bookingRoutes');
const reviewRoutes = require('./src/routes/reviewRoutes');
const adminRoutes = require('./src/routes/adminRoutes'); // Admin dashboard API routes
const categoryRoutes = require('./src/routes/categoryRoutes'); // Categories API routes
const messageRoutes = require('./src/routes/messageRoutes'); // Chat API routes

// මූලික API Route එක (Testing සඳහා)
app.get('/', (req, res) => {
    res.json({ message: "Welcome to Guide Lanka / Home Service API" });
});

// Routes සම්බන්ධ කිරීම
app.use('/api/auth', authRoutes);
app.use('/api/providers', providerRoutes); 
app.use('/api/bookings', bookingRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/admin', adminRoutes); // Admin routes mount කිරීම
app.use('/api/categories', categoryRoutes); // Category routes mount කිරීම
app.use('/api/messages', messageRoutes); // Chat routes mount කිරීම

// Server එක Start කිරීම
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    if (process.env.SMTP_USER) {
        console.log(`✉️ SMTP Email Service ready for: ${process.env.SMTP_USER}`);
    }
});