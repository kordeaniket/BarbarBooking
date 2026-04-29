import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, Image, TextInput, ActivityIndicator, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import client from '../../api/client';
import { Search, MapPin, Star, Scissors } from 'lucide-react-native';

interface Service {
  _id: string;
  name: string;
  defaultPrice: number;
}

interface Barber {
  _id: string;
  name: string;
  shopName: string;
  location: { city: string; address: string };
  profilePhoto?: string;
  services: Service[];
}

export default function CustomerHome() {
  const [barbers, setBarbers] = useState<Barber[]>([]);
  const [filteredBarbers, setFilteredBarbers] = useState<Barber[]>([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const router = useRouter();

  useEffect(() => {
    fetchBarbers();
  }, []);

  const fetchBarbers = async () => {
    try {
      const response = await client.get('/mobile/barbers');
      setBarbers(response.data);
      setFilteredBarbers(response.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const onRefresh = () => {
    setRefreshing(true);
    fetchBarbers();
  };

  const handleSearch = (text: string) => {
    setSearch(text);
    if (!text) {
      setFilteredBarbers(barbers);
      return;
    }
    const filtered = barbers.filter(b => 
      b.shopName.toLowerCase().includes(text.toLowerCase()) || 
      b.location.city.toLowerCase().includes(text.toLowerCase())
    );
    setFilteredBarbers(filtered);
  };

  const renderBarberItem = ({ item }: { item: Barber }) => (
    <TouchableOpacity 
      style={styles.card} 
      onPress={() => router.push({ pathname: '/(customer)/barber/[id]', params: { id: item._id } })}
    >
      <View style={styles.imageContainer}>
        {item.profilePhoto ? (
          <Image source={{ uri: `http://10.0.2.2:5000${item.profilePhoto}` }} style={styles.image} />
        ) : (
          <View style={styles.placeholderImage}>
            <Scissors size={32} color="#475569" />
          </View>
        )}
      </View>
      <View style={styles.info}>
        <View style={styles.cardHeader}>
          <Text style={styles.shopName}>{item.shopName}</Text>
          <View style={styles.rating}>
            <Star size={14} color="#fbbf24" fill="#fbbf24" />
            <Text style={styles.ratingText}>4.8</Text>
          </View>
        </View>
        <Text style={styles.barberName}>{item.name}</Text>
        <View style={styles.locationContainer}>
          <MapPin size={14} color="#94a3b8" />
          <Text style={styles.locationText}>{item.location.city}, {item.location.address}</Text>
        </View>
        <View style={styles.servicesContainer}>
          {item.services.slice(0, 3).map((s, idx) => (
            <View key={s._id} style={styles.serviceBadge}>
              <Text style={styles.serviceBadgeText}>{s.name}</Text>
            </View>
          ))}
          {item.services.length > 3 && (
            <Text style={styles.moreServices}>+{item.services.length - 3} more</Text>
          )}
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Find a Barber</Text>
        <View style={styles.searchContainer}>
          <Search size={20} color="#94a3b8" />
          <TextInput
            style={styles.searchInput}
            placeholder="Search by shop or city"
            placeholderTextColor="#64748b"
            value={search}
            onChangeText={handleSearch}
          />
        </View>
      </View>

      {loading ? (
        <ActivityIndicator style={styles.loader} color="#8b5cf6" />
      ) : (
        <FlatList
          data={filteredBarbers}
          renderItem={renderBarberItem}
          keyExtractor={(item) => item._id}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#8b5cf6" />}
          ListEmptyComponent={
            <View style={styles.emptyContainer}>
              <Text style={styles.emptyText}>No barbers found in this area</Text>
            </View>
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { padding: 24, paddingTop: 60, backgroundColor: '#1e293b', borderBottomLeftRadius: 24, borderBottomRightRadius: 24 },
  title: { fontSize: 24, fontWeight: '800', color: '#f1f5f9', marginBottom: 16 },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#0f172a',
    borderRadius: 12,
    paddingHorizontal: 12,
    height: 48,
  },
  searchInput: { flex: 1, color: '#f1f5f9', fontSize: 16, marginLeft: 10 },
  loader: { flex: 1, justifyContent: 'center' },
  listContent: { padding: 20 },
  card: {
    backgroundColor: '#1e293b',
    borderRadius: 16,
    marginBottom: 20,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#334155',
  },
  imageContainer: { height: 160, backgroundColor: '#334155' },
  image: { width: '100%', height: '100%' },
  placeholderImage: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  info: { padding: 16 },
  cardHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  shopName: { fontSize: 18, fontWeight: '700', color: '#f1f5f9' },
  rating: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#334155', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 8 },
  ratingText: { color: '#fbbf24', fontSize: 12, fontWeight: '700', marginLeft: 4 },
  barberName: { fontSize: 14, color: '#94a3b8', marginTop: 2 },
  locationContainer: { flexDirection: 'row', alignItems: 'center', marginTop: 8 },
  locationText: { color: '#64748b', fontSize: 12, marginLeft: 4 },
  servicesContainer: { flexDirection: 'row', flexWrap: 'wrap', marginTop: 12 },
  serviceBadge: { backgroundColor: '#8b5cf620', paddingHorizontal: 8, paddingVertical: 4, borderRadius: 6, marginRight: 8, marginBottom: 4 },
  serviceBadgeText: { color: '#8b5cf6', fontSize: 10, fontWeight: '600' },
  moreServices: { color: '#64748b', fontSize: 10, marginTop: 4 },
  emptyContainer: { alignItems: 'center', marginTop: 40 },
  emptyText: { color: '#64748b', fontSize: 16 },
});
