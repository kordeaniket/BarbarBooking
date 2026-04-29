import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Image, ScrollView, TouchableOpacity, ActivityIndicator, Alert } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import client from '../../../api/client';
import { ArrowLeft, MapPin, Scissors, Clock, CreditCard, ChevronRight } from 'lucide-react-native';

interface Service {
  _id: string;
  name: string;
  defaultPrice: number;
  durationMinutes: number;
}

interface Barber {
  _id: string;
  name: string;
  shopName: string;
  location: { city: string; address: string };
  profilePhoto?: string;
  services: Service[];
}

export default function BarberDetails() {
  const { id } = useLocalSearchParams();
  const [barber, setBarber] = useState<Barber | null>(null);
  const [selectedService, setSelectedService] = useState<Service | null>(null);
  const [loading, setLoading] = useState(true);
  const [bookingLoading, setBookingLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    fetchBarber();
  }, [id]);

  const fetchBarber = async () => {
    try {
      const response = await client.get(`/mobile/barbers/${id}`);
      setBarber(response.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleBooking = async (paymentType: 'cash' | 'online') => {
    if (!selectedService) {
      Alert.alert('Selection Required', 'Please select a service first.');
      return;
    }

    setBookingLoading(true);
    try {
      const bookingData = {
        barberId: barber?._id,
        serviceId: selectedService._id,
        date: new Date().toISOString(), // Simplified: Today
        startTime: '10:00 AM', // Simplified
        paymentType,
        amount: selectedService.defaultPrice
      };

      await client.post('/mobile/bookings', bookingData);
      
      Alert.alert(
        'Success!', 
        paymentType === 'online' ? 'Booking requested. (Payment integration demo)' : 'Booking requested. Pay at shop.',
        [{ text: 'View History', onPress: () => router.push('/(customer)/history') }]
      );
    } catch (err: any) {
      Alert.alert('Error', err.response?.data?.message || 'Failed to create booking');
    } finally {
      setBookingLoading(false);
    }
  };

  if (loading) return <View style={styles.center}><ActivityIndicator color="#8b5cf6" /></View>;
  if (!barber) return <View style={styles.center}><Text style={styles.error}>Barber not found</Text></View>;

  return (
    <View style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.imageContainer}>
          {barber.profilePhoto ? (
            <Image source={{ uri: `http://10.0.2.2:5000${barber.profilePhoto}` }} style={styles.image} />
          ) : (
            <View style={styles.placeholderImage}><Scissors size={48} color="#475569" /></View>
          )}
          <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
            <ArrowLeft size={24} color="#fff" />
          </TouchableOpacity>
        </View>

        <View style={styles.content}>
          <Text style={styles.shopName}>{barber.shopName}</Text>
          <View style={styles.locationContainer}>
            <MapPin size={16} color="#94a3b8" />
            <Text style={styles.locationText}>{barber.location.city}, {barber.location.address}</Text>
          </View>

          <Text style={styles.sectionTitle}>Services Offered</Text>
          <View style={styles.servicesList}>
            {barber.services.map((service) => (
              <TouchableOpacity 
                key={service._id} 
                style={[styles.serviceItem, selectedService?._id === service._id && styles.selectedService]}
                onPress={() => setSelectedService(service)}
              >
                <View>
                  <Text style={[styles.serviceName, selectedService?._id === service._id && styles.selectedText]}>{service.name}</Text>
                  <View style={styles.serviceMeta}>
                    <Clock size={12} color="#64748b" />
                    <Text style={styles.serviceDuration}>{service.durationMinutes} mins</Text>
                  </View>
                </View>
                <Text style={[styles.servicePrice, selectedService?._id === service._id && styles.selectedText]}>₹{service.defaultPrice}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </ScrollView>

      {selectedService && (
        <View style={styles.footer}>
          <View style={styles.totalContainer}>
            <Text style={styles.totalLabel}>Total Amount</Text>
            <Text style={styles.totalAmount}>₹{selectedService.defaultPrice}</Text>
          </View>
          <View style={styles.buttonGroup}>
            <TouchableOpacity 
              style={[styles.bookButton, styles.secondaryButton]} 
              onPress={() => handleBooking('cash')}
              disabled={bookingLoading}
            >
              <Text style={styles.secondaryButtonText}>Pay at Shop</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.bookButton, styles.primaryButton]} 
              onPress={() => handleBooking('online')}
              disabled={bookingLoading}
            >
              {bookingLoading ? <ActivityIndicator color="#fff" /> : (
                <>
                  <CreditCard size={18} color="#fff" />
                  <Text style={styles.primaryButtonText}>Pay Now</Text>
                </>
              )}
            </TouchableOpacity>
          </View>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  center: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#0f172a' },
  error: { color: '#ef4444', fontSize: 16 },
  imageContainer: { height: 300, width: '100%' },
  image: { width: '100%', height: '100%' },
  placeholderImage: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#1e293b' },
  backButton: { position: 'absolute', top: 50, left: 20, width: 40, height: 40, borderRadius: 20, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center' },
  content: { padding: 24, marginTop: -24, backgroundColor: '#0f172a', borderTopLeftRadius: 32, borderTopRightRadius: 32 },
  shopName: { fontSize: 26, fontWeight: '800', color: '#f1f5f9' },
  locationContainer: { flexDirection: 'row', alignItems: 'center', marginTop: 8 },
  locationText: { color: '#94a3b8', fontSize: 14, marginLeft: 6 },
  sectionTitle: { fontSize: 18, fontWeight: '700', color: '#f1f5f9', marginTop: 32, marginBottom: 16 },
  servicesList: { gap: 12 },
  serviceItem: { 
    flexDirection: 'row', 
    justifyContent: 'space-between', 
    alignItems: 'center', 
    padding: 16, 
    backgroundColor: '#1e293b', 
    borderRadius: 16,
    borderWidth: 1,
    borderColor: '#334155'
  },
  selectedService: { borderColor: '#8b5cf6', backgroundColor: '#8b5cf615' },
  serviceName: { fontSize: 16, fontWeight: '600', color: '#f1f5f9' },
  servicePrice: { fontSize: 16, fontWeight: '700', color: '#8b5cf6' },
  selectedText: { color: '#8b5cf6' },
  serviceMeta: { flexDirection: 'row', alignItems: 'center', marginTop: 4 },
  serviceDuration: { fontSize: 12, color: '#64748b', marginLeft: 4 },
  footer: { 
    padding: 24, 
    backgroundColor: '#1e293b', 
    borderTopLeftRadius: 24, 
    borderTopRightRadius: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.2,
    shadowRadius: 10,
    elevation: 10,
  },
  totalContainer: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 },
  totalLabel: { color: '#94a3b8', fontSize: 14 },
  totalAmount: { color: '#f1f5f9', fontSize: 22, fontWeight: '800' },
  buttonGroup: { flexDirection: 'row', gap: 12 },
  bookButton: { flex: 1, height: 56, borderRadius: 16, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 8 },
  primaryButton: { backgroundColor: '#8b5cf6' },
  secondaryButton: { backgroundColor: '#334155', borderWidth: 1, borderColor: '#475569' },
  primaryButtonText: { color: '#fff', fontSize: 16, fontWeight: '700' },
  secondaryButtonText: { color: '#f1f5f9', fontSize: 16, fontWeight: '600' },
});
