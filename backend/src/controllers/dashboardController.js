import Barber from '../models/Barber.js';
import Customer from '../models/Customer.js';
import Booking from '../models/Booking.js';
import Transaction from '../models/Transaction.js';

// @desc    Get dashboard stats
// @route   GET /api/dashboard/stats
// @access  Private (Admin only)
export const getDashboardStats = async (req, res) => {
  try {
    const totalBarbers = await Barber.countDocuments();
    const totalCustomers = await Customer.countDocuments();

    // Simple today calculation
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const bookingsToday = await Booking.countDocuments({ date: { $gte: startOfToday } });

    // Mock revenue data for recharts (in a real app, aggregate from transactions)
    const revenueData = [
      { name: 'Mon', revenue: 4000 },
      { name: 'Tue', revenue: 3000 },
      { name: 'Wed', revenue: 2000 },
      { name: 'Thu', revenue: 2780 },
      { name: 'Fri', revenue: 1890 },
      { name: 'Sat', revenue: 2390 },
      { name: 'Sun', revenue: 3490 },
    ];

    res.json({
      totalBarbers,
      totalCustomers,
      bookingsToday,
      revenueData
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get recent activity
// @route   GET /api/dashboard/recent-activity
// @access  Private (Admin only)
export const getRecentActivity = async (req, res) => {
  try {
    const recentBookings = await Booking.find().sort({ createdAt: -1 }).limit(5).populate('customer', 'name');
    const recentTransactions = await Transaction.find().sort({ createdAt: -1 }).limit(5).populate('customer', 'name');

    res.json({
      recentBookings,
      recentTransactions
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
