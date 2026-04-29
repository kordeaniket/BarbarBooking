import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';
import client from '../../api/client';
import { UserPlus, Mail, Lock, User, Phone } from 'lucide-react-native';

export default function Register() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    mobile: '',
    password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const router = useRouter();

  const handleRegister = async () => {
    if (!formData.name || !formData.email || !formData.mobile || !formData.password) {
      setError('Please fill in all fields');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const response = await client.post('/mobile/auth/customer/register', formData);
      await login(response.data, response.data.token);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.logo}>Join Us</Text>
          <Text style={styles.subtitle}>Create your customer account</Text>
        </View>

        <View style={styles.form}>
          <Text style={styles.label}>Full Name</Text>
          <View style={styles.inputContainer}>
            <User size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Enter your name"
              placeholderTextColor="#64748b"
              value={formData.name}
              onChangeText={(text) => setFormData({ ...formData, name: text })}
            />
          </View>

          <Text style={styles.label}>Email Address</Text>
          <View style={styles.inputContainer}>
            <Mail size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Enter your email"
              placeholderTextColor="#64748b"
              value={formData.email}
              onChangeText={(text) => setFormData({ ...formData, email: text })}
              autoCapitalize="none"
              keyboardType="email-address"
            />
          </View>

          <Text style={styles.label}>Mobile Number</Text>
          <View style={styles.inputContainer}>
            <Phone size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Enter your mobile"
              placeholderTextColor="#64748b"
              value={formData.mobile}
              onChangeText={(text) => setFormData({ ...formData, mobile: text })}
              keyboardType="phone-pad"
            />
          </View>

          <Text style={styles.label}>Password</Text>
          <View style={styles.inputContainer}>
            <Lock size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Create a password"
              placeholderTextColor="#64748b"
              value={formData.password}
              onChangeText={(text) => setFormData({ ...formData, password: text })}
              secureTextEntry
            />
          </View>

          {error ? <Text style={styles.errorText}>{error}</Text> : null}

          <TouchableOpacity 
            style={styles.registerButton} 
            onPress={handleRegister}
            disabled={loading}
          >
            {loading ? <ActivityIndicator color="#fff" /> : (
              <View style={styles.buttonContent}>
                <UserPlus size={20} color="#fff" />
                <Text style={styles.buttonText}>Register Account</Text>
              </View>
            )}
          </TouchableOpacity>

          <TouchableOpacity onPress={() => router.back()} style={styles.loginLink}>
            <Text style={styles.loginText}>Already have an account? <Text style={styles.loginHighlight}>Login here</Text></Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  scrollContent: { flexGrow: 1, padding: 24, justifyContent: 'center' },
  header: { alignItems: 'center', marginBottom: 32 },
  logo: { fontSize: 32, fontWeight: '800', color: '#8b5cf6' },
  subtitle: { fontSize: 14, color: '#94a3b8', marginTop: 8 },
  form: { width: '100%' },
  label: { fontSize: 14, fontWeight: '600', color: '#f1f5f9', marginBottom: 8, marginTop: 12 },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#1e293b',
    borderRadius: 12,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: '#334155',
  },
  input: { flex: 1, height: 50, color: '#f1f5f9', fontSize: 16, marginLeft: 12 },
  errorText: { color: '#ef4444', fontSize: 14, marginTop: 12, textAlign: 'center' },
  registerButton: {
    height: 56,
    backgroundColor: '#8b5cf6',
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 32,
  },
  buttonContent: { flexDirection: 'row', alignItems: 'center' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '700', marginLeft: 10 },
  loginLink: { marginTop: 24, alignItems: 'center' },
  loginText: { color: '#94a3b8', fontSize: 14 },
  loginHighlight: { color: '#8b5cf6', fontWeight: '700' },
});
