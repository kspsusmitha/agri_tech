import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  // Initialize Firebase Realtime Database
  // IMPORTANT: Make sure Realtime Database is enabled in Firebase Console
  // Get your database URL from: Firebase Console -> Realtime Database -> Data tab
  // Update the databaseURL below with your actual URL
  
  // Common URL formats (update with your actual URL):
  // New: https://plantdisease-e827d-default-rtdb.<REGION>.firebasedatabase.app
  // Legacy: https://plantdisease-e827d.firebaseio.com
  
  // Your Firebase Realtime Database URL
  static const String databaseURL = 'https://plantdisease-e827d-default-rtdb.firebaseio.com';
  
  late final DatabaseReference _database;
  
  AuthService() {
    try {
      // Initialize with explicit URL
      final firebaseDatabase = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: databaseURL,
      );
      _database = firebaseDatabase.ref();
      debugPrint('✅ [Auth Service] Database initialized with URL: $databaseURL');
    } catch (e) {
      debugPrint('❌ [Auth Service] Failed to initialize with URL: $e');
      debugPrint('   Database URL: $databaseURL');
      debugPrint('   Please check FIREBASE_REALTIME_DATABASE_SETUP.md for setup instructions');
      rethrow;
    }
  }
  
  // Predefined admin credentials
  static const String adminEmail = 'admin@farmtech.com';
  static const String adminPassword = 'admin123';
  
  /// Register a new user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? address,
  }) async {
    try {
      // Validate role
      if (!['farmer', 'buyer'].contains(role.toLowerCase())) {
        return {
          'success': false,
          'message': 'Invalid role. Only farmer and buyer can register.',
        };
      }

      // Check if email already exists
      final emailExists = await _checkEmailExists(email, role);
      if (emailExists) {
        return {
          'success': false,
          'message': 'Email already registered. Please login instead.',
        };
      }

      // Generate user ID
      final userId = _database.child('users').child(role.toLowerCase()).push().key!;
      
      // Create user model
      final user = UserModel(
        id: userId,
        name: name,
        email: email.toLowerCase().trim(),
        password: password, // In production, hash this password
        phone: phone,
        role: role.toLowerCase(),
        address: address,
        createdAt: DateTime.now(),
      );

      // Save to Realtime Database
      // Structure: users/{role}/{userId}
      await _database.child('users').child(role.toLowerCase()).child(userId).set(
        user.toJson(),
      );

      debugPrint('✅ [Auth Service] User registered: $email as $role');
      
      return {
        'success': true,
        'message': 'Registration successful!',
        'user': user.copyWithoutPassword(),
      };
    } catch (e) {
      debugPrint('❌ [Auth Service] Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final emailLower = email.toLowerCase().trim();
      
      // Check admin credentials first
      if (role.toLowerCase() == 'admin') {
        if (emailLower == adminEmail && password == adminPassword) {
          // Create admin user model
          final adminUser = UserModel(
            id: 'admin_001',
            name: 'Admin',
            email: adminEmail,
            password: adminPassword,
            phone: '0000000000',
            role: 'admin',
            createdAt: DateTime.now(),
          );
          
          debugPrint('✅ [Auth Service] Admin login successful');
          return {
            'success': true,
            'message': 'Login successful!',
            'user': adminUser.copyWithoutPassword(),
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid admin credentials',
          };
        }
      }

      // For farmer and buyer, check Realtime Database
      final usersSnapshot = await _database
          .child('users')
          .child(role.toLowerCase())
          .get();

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;
        
        // Find user with matching email and password
        for (var entry in usersData.entries) {
          final userData = entry.value as Map<dynamic, dynamic>;
          final userEmail = (userData['email'] as String?)?.toLowerCase().trim();
          final userPassword = userData['password'] as String?;
          
          if (userEmail == emailLower && userPassword == password) {
            final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
            debugPrint('✅ [Auth Service] Login successful: $email as $role');
            return {
              'success': true,
              'message': 'Login successful!',
              'user': user.copyWithoutPassword(),
            };
          }
        }
      }

      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    } catch (e) {
      debugPrint('❌ [Auth Service] Login error: $e');
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  /// Check if email exists
  Future<bool> _checkEmailExists(String email, String role) async {
    try {
      final usersSnapshot = await _database
          .child('users')
          .child(role.toLowerCase())
          .get();

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>;
        final emailLower = email.toLowerCase().trim();
        
        for (var entry in usersData.entries) {
          final userData = entry.value as Map<dynamic, dynamic>;
          final userEmail = (userData['email'] as String?)?.toLowerCase().trim();
          if (userEmail == emailLower) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ [Auth Service] Check email error: $e');
      return false;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId, String role) async {
    try {
      final snapshot = await _database
          .child('users')
          .child(role.toLowerCase())
          .child(userId)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [Auth Service] Get user error: $e');
      return null;
    }
  }
}
