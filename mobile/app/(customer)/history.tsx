import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet, ActivityIndicator, RefreshControl } from 'react-native';
import client from '../../api/client';
import { Clock, Calendar, CheckCircle2, XCircle, AlertCircle } from 'lucide-react-native';

interface Booking {
  _id: string;
  barber: { name: string; shopName: string };
  service: { name: string; defaultPrice: number };
  date: string;
  startTime: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
}

export default function History() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const response = await client.get('/mobile/bookings/history');
      setBookings(response.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const getStatusInfo = (status: string) => {
    switch (status) {
      case 'confirmed': return { color: '#10b981', icon: <CheckCircle2 size={14} color="#10b981" />, label: 'CONFIRMED' };
      case 'cancelled': return { color: '#ef4444', icon: <XCircle size={14} color="#ef4444" />, label: 'CANCELLED' };
      case 'completed': return { color: '#8b5cf6', icon: <CheckCircle2 size={14} color="#8b5cf6" />, label: 'COMPLETED' };
      default: return { color: '#fbbf24', icon: <AlertCircle size={14} color="#fbbf24" />, label: 'PENDING' };
    }
  };

  const renderBookingItem = ({ item }: { item: Booking }) => {
    const status = getStatusInfo(item.status);
    return (
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <View>
            <Text style={styles.shopName}>{item.barber.shopName}</Text>
            <Text style={styles.serviceName}>{item.service.name}</Text>
          </View>
          <View style={[styles.statusBadge, { backgroundColor: `${status.color}15` }]}>
            {status.icon}
            <Text style={[styles.statusText, { color: status.color }]}>{status.label}</Text>
          </View>
        </View>
        
        <View style={styles.divider} />
        
        <View style={styles.detailsRow}>
          <View style={styles.detailItem}>
            <Calendar size={14} color="#94a3b8" />
            <Text style={styles.detailText}>{new Date(item.date).toLocaleDateString()}</Text>
          </View>
          <View style={styles.detailItem}>
            <Clock size={14} color="#94a3b8" />
            <Text style={styles.detailText}>{item.startTime}</Text>
          </View>
          <Text style={styles.priceText}>₹{item.service.defaultPrice}</Text>
        </View>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>My Appointments</Text>
      </View>

      {loading ? (
        <ActivityIndicator style={styles.loader} color="#8b5cf6" />
      ) : (
        <FlatList
          data={bookings}
          renderItem={renderBookingItem}
          keyExtractor={(item) => item._id}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={fetchHistory} tintColor="#8b5cf6" />}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No bookings found</Text>
            </View>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { padding: 24, paddingTop: 60, backgroundColor: '#1e293b' },
  title: { fontSize: 24, fontWeight: '800', color: '#f1f5f9' },
  loader: { flex: 1, justifyContent: 'center' },
  listContent: { padding: 20 },
  card: {
    backgroundColor: '#1e293b',
    borderRadius: 16,
    marginBottom: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#334155',
  },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  shopName: { fontSize: 16, fontWeight: '700', color: '#f1f5f9' },
  serviceName: { fontSize: 14, color: '#94a3b8', marginTop: 2 },
  statusBadge: { flexDirection: 'row', alignItems: 'center', paddingHorizontal: 10, paddingVertical: 6, borderRadius: 8, gap: 6 },
  statusText: { fontSize: 10, fontWeight: '800' },
  divider: { height: 1, backgroundColor: '#334155', marginVertical: 16 },
  detailsRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  detailItem: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  detailText: { color: '#f1f5f9', fontSize: 13, fontWeight: '500' },
  priceText: { color: '#8b5cf6', fontSize: 16, fontWeight: '800' },
  emptyContainer: { alignItems: 'center', marginTop: 40 },
  emptyText: { color: '#64748b', fontSize: 16 },
});
