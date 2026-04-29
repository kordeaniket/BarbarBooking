import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { LogOut, User as UserIcon, Shield, ChevronRight } from 'lucide-react-native';

export default function Profile() {
  const { user, logout } = useAuth();

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>{user?.name.charAt(0)}</Text>
        </View>
        <Text style={styles.name}>{user?.name}</Text>
        <Text style={styles.email}>{user?.email}</Text>
        <View style={styles.roleBadge}>
          <Shield size={12} color="#8b5cf6" />
          <Text style={styles.roleText}>{user?.role.toUpperCase()}</Text>
        </View>
      </View>

      <View style={styles.menu}>
        <TouchableOpacity style={styles.menuItem}>
          <View style={styles.menuLeft}>
            <UserIcon size={20} color="#94a3b8" />
            <Text style={styles.menuText}>Edit Profile</Text>
          </View>
          <ChevronRight size={20} color="#475569" />
        </TouchableOpacity>

        <TouchableOpacity style={[styles.menuItem, styles.logoutItem]} onPress={logout}>
          <View style={styles.menuLeft}>
            <LogOut size={20} color="#ef4444" />
            <Text style={[styles.menuText, styles.logoutText]}>Logout</Text>
          </View>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  header: { padding: 40, paddingTop: 80, alignItems: 'center', backgroundColor: '#1e293b', borderBottomLeftRadius: 32, borderBottomRightRadius: 32 },
  avatar: { width: 80, height: 80, borderRadius: 40, backgroundColor: '#8b5cf6', justifyContent: 'center', alignItems: 'center', marginBottom: 16 },
  avatarText: { color: '#fff', fontSize: 32, fontWeight: '800' },
  name: { fontSize: 24, fontWeight: '800', color: '#f1f5f9' },
  email: { fontSize: 14, color: '#94a3b8', marginTop: 4 },
  roleBadge: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#8b5cf615', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 20, marginTop: 12, gap: 6 },
  roleText: { color: '#8b5cf6', fontSize: 12, fontWeight: '800' },
  menu: { padding: 24, marginTop: 20 },
  menuItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 20, borderBottomWidth: 1, borderBottomColor: '#1e293b' },
  menuLeft: { flexDirection: 'row', alignItems: 'center', gap: 16 },
  menuText: { fontSize: 16, color: '#f1f5f9', fontWeight: '600' },
  logoutItem: { borderBottomWidth: 0, marginTop: 20 },
  logoutText: { color: '#ef4444' },
});
