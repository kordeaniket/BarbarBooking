import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, ActivityIndicator, Alert, RefreshControl } from 'react-native';
import client from '../../api/client';
import { Check, X, Clock, User, Phone } from 'lucide-react-native';

interface Booking {
  _id: string;
  customer: { name: string; mobile: string };
  service: { name: string };
  date: string;
  startTime: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
}

export default function BarberDashboard() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    fetchBookings();
  }, []);

  const fetchBookings = async () => {
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

  const updateStatus = async (id: string, status: string) => {
    try {
      await client.put(`/mobile/bookings/${id}/status`, { status });
      Alert.alert('Success', `Booking ${status} successfully`);
      fetchBookings();
    } catch (err) {
      Alert.alert('Error', 'Failed to update status');
    }
  };

  const renderBookingItem = ({ item }: { item: Booking }) => (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <View style={styles.customerInfo}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>{item.customer.name.charAt(0)}</Text>
          </View>
          <View style={styles.nameContainer}>
            <Text style={styles.customerName}>{item.customer.name}</Text>
            <Text style={styles.serviceName}>{item.service.name}</Text>
          </View>
        </View>
        <View style={[styles.statusBadge, item.status === 'pending' ? styles.pendingBadge : styles.confirmedBadge]}>
          <Text style={[styles.statusText, item.status === 'pending' ? styles.pendingText : styles.confirmedText]}>
            {item.status.toUpperCase()}
          </Text>
        </View>
      </View>

      <View style={styles.timeInfo}>
        <View style={styles.infoRow}>
          <Clock size={16} color="#94a3b8" />
          <Text style={styles.infoText}>{item.startTime} • {new Date(item.date).toLocaleDateString()}</Text>
        </View>
        <View style={styles.infoRow}>
          <Phone size={16} color="#94a3b8" />
          <Text style={styles.infoText}>{item.customer.mobile}</Text>
        </View>
      </View>

      {item.status === 'pending' && (
        <View style={styles.actions}>
          <TouchableOpacity 
            style={[styles.actionButton, styles.rejectButton]} 
            onPress={() => updateStatus(item._id, 'cancelled')}
          >
            <X size={20} color="#ef4444" />
            <Text style={styles.rejectText}>Reject</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.actionButton, styles.acceptButton]} 
            onPress={() => updateStatus(item._id, 'confirmed')}
          >
            <Check size={20} color="#fff" />
            <Text style={styles.acceptText}>Accept</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Barber Dashboard</Text>
        <Text style={styles.subtitle}>Manage your appointments</Text>
      </View>

      {loading ? (
        <ActivityIndicator style={styles.loader} color="#8b5cf6" />
      ) : (
        <FlatList
          data={bookings}
          renderItem={renderBookingItem}
          keyExtractor={(item) => item._id}
          contentContainerStyle={styles.listContent}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={fetchBookings} tintColor="#8b5cf6" />}
          ListEmptyComponent={<Text style={styles.empty}>No bookings yet</Text>}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { padding: 24, paddingTop: 60, backgroundColor: '#1e293b' },
  title: { fontSize: 24, fontWeight: '800', color: '#f1f5f9' },
  subtitle: { fontSize: 14, color: '#94a3b8', marginTop: 4 },
  loader: { flex: 1, justifyContent: 'center' },
  listContent: { padding: 20 },
  card: { backgroundColor: '#1e293b', borderRadius: 20, padding: 20, marginBottom: 16, borderWidth: 1, borderColor: '#334155' },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  customerInfo: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 44, height: 44, borderRadius: 22, backgroundColor: '#8b5cf6', justifyContent: 'center', alignItems: 'center' },
  avatarText: { color: '#fff', fontSize: 18, fontWeight: '700' },
  nameContainer: { marginLeft: 12 },
  customerName: { color: '#f1f5f9', fontSize: 16, fontWeight: '700' },
  serviceName: { color: '#94a3b8', fontSize: 14 },
  statusBadge: { paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
  pendingBadge: { backgroundColor: '#fbbf2420' },
  confirmedBadge: { backgroundColor: '#10b98120' },
  statusText: { fontSize: 10, fontWeight: '800' },
  pendingText: { color: '#fbbf24' },
  confirmedText: { color: '#10b981' },
  timeInfo: { marginTop: 16, gap: 8 },
  infoRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  infoText: { color: '#94a3b8', fontSize: 14 },
  actions: { flexDirection: 'row', marginTop: 20, gap: 12 },
  actionButton: { flex: 1, height: 48, borderRadius: 12, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 8 },
  acceptButton: { backgroundColor: '#8b5cf6' },
  rejectButton: { backgroundColor: 'transparent', borderWidth: 1, borderColor: '#ef4444' },
  acceptText: { color: '#fff', fontWeight: '700' },
  rejectText: { color: '#ef4444', fontWeight: '700' },
  empty: { color: '#64748b', textAlign: 'center', marginTop: 40 },
});
