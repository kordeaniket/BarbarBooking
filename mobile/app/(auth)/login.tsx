import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../../context/AuthContext';
import client from '../../api/client';
import { LogIn, Mail, Lock } from 'lucide-react-native';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const { login } = useAuth();
  const router = useRouter();

  const handleLogin = async (role: 'customer' | 'barber') => {
    if (!email || !password) {
      setError('Please fill in all fields');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const endpoint = role === 'customer' ? '/mobile/auth/customer/login' : '/mobile/auth/barber/login';
      const response = await client.post(endpoint, { email, password });
      await login(response.data, response.data.token);
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.logo}>BarberBook</Text>
          <Text style={styles.subtitle}>Premium Grooming Experiences</Text>
        </View>

        <View style={styles.form}>
          <Text style={styles.label}>Email Address</Text>
          <View style={styles.inputContainer}>
            <Mail size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Enter your email"
              placeholderTextColor="#64748b"
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              keyboardType="email-address"
            />
          </View>

          <Text style={styles.label}>Password</Text>
          <View style={styles.inputContainer}>
            <Lock size={20} color="#94a3b8" />
            <TextInput
              style={styles.input}
              placeholder="Enter your password"
              placeholderTextColor="#64748b"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
          </View>

          {error ? <Text style={styles.errorText}>{error}</Text> : null}

          <TouchableOpacity 
            style={[styles.loginButton, { backgroundColor: '#8b5cf6' }]} 
            onPress={() => handleLogin('customer')}
            disabled={loading}
          >
            {loading ? <ActivityIndicator color="#fff" /> : (
              <View style={styles.buttonContent}>
                <LogIn size={20} color="#fff" />
                <Text style={styles.buttonText}>Login as Customer</Text>
              </View>
            )}
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.loginButton, { backgroundColor: '#475569', marginTop: 12 }]} 
            onPress={() => handleLogin('barber')}
            disabled={loading}
          >
            <Text style={styles.buttonText}>Login as Barber</Text>
          </TouchableOpacity>

          <TouchableOpacity onPress={() => router.push('/(auth)/register')} style={styles.registerLink}>
            <Text style={styles.registerText}>Don't have an account? <Text style={styles.registerHighlight}>Register here</Text></Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#0f172a' },
  scrollContent: { flexGrow: 1, padding: 24, justifyContent: 'center' },
  header: { alignItems: 'center', marginBottom: 40 },
  logo: { fontSize: 32, fontWeight: '800', color: '#8b5cf6', letterSpacing: 1 },
  subtitle: { fontSize: 14, color: '#94a3b8', marginTop: 8 },
  form: { width: '100%' },
  label: { fontSize: 14, fontWeight: '600', color: '#f1f5f9', marginBottom: 8, marginTop: 16 },
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
  loginButton: {
    height: 56,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 32,
    shadowColor: '#8b5cf6',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  buttonContent: { flexDirection: 'row', alignItems: 'center' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: '700', marginLeft: 10 },
  registerLink: { marginTop: 24, alignItems: 'center' },
  registerText: { color: '#94a3b8', fontSize: 14 },
  registerHighlight: { color: '#8b5cf6', fontWeight: '700' },
});
