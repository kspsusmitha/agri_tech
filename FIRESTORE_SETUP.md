# Firestore Setup Guide for Product Management

## ✅ Migration Complete: Realtime Database → Firestore

The product management system has been migrated from Firebase Realtime Database to **Firestore** (Cloud Firestore). Products are now stored in Firestore with the farmer's username and email.

---

## 🔥 Firestore Setup Steps

### 1. Enable Firestore in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `plantdisease-e827d`
3. Navigate to **Firestore Database** in the left sidebar
4. Click **Create Database**
5. Choose **Start in test mode** (for development) or **Start in production mode** (for production)
6. Select your preferred location (e.g., `us-central1`)

### 2. Set Firestore Security Rules

Go to **Firestore Database** → **Rules** tab and add these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products collection
    match /products/{productId} {
      // Allow farmers to create their own products
      allow create: if request.auth != null 
        && request.resource.data.farmerId == request.auth.uid;
      
      // Allow farmers to read/update/delete their own products
      allow read, update, delete: if request.auth != null 
        && resource.data.farmerId == request.auth.uid;
      
      // Allow buyers to read approved products
      allow read: if resource.data.status == 'approved';
      
      // Allow admins to read/update all products
      allow read, update: if request.auth != null 
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

**Note**: Since we're using custom authentication (not Firebase Auth), you may need to adjust these rules. For now, use these simpler rules for development:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      // Allow read/write for all authenticated users (adjust for production)
      allow read, write: if request.auth != null;
      
      // Or for development/testing, allow all:
      // allow read, write: if true;
    }
  }
}
```

### 3. Create Indexes (if needed)

If you get index errors, Firestore will prompt you to create indexes. Click the link in the error message to create them automatically.

Common indexes needed:
- `products` collection:
  - `status` (ascending) + `createdAt` (descending)
  - `farmerId` (ascending) + `createdAt` (descending)
  - `farmerEmail` (ascending) + `createdAt` (descending)

---

## 📊 Firestore Data Structure

### Products Collection

**Collection**: `products`

**Document Structure**:
```json
{
  "id": "1234567890",
  "farmerId": "farmer_001",
  "farmerName": "John Doe",
  "farmerEmail": "john@example.com",
  "name": "Fresh Tomatoes",
  "description": "Organic tomatoes from local farm",
  "price": 2.50,
  "quantity": 100,
  "unit": "kg",
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "category": "Vegetables",
  "status": "pending", // pending, approved, rejected
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### Document Path
```
products/{productId}
```

---

## 🔑 Key Features

### ✅ Farmer Information Stored
- **farmerId**: Unique farmer ID
- **farmerName**: Farmer's username/name (from login session)
- **farmerEmail**: Farmer's email (from login session)

### ✅ Product Details
- All product information (name, description, price, etc.)
- Image URL (stored in Firebase Storage)
- Category and status
- Creation timestamp

### ✅ Queries Supported
- Get products by farmer ID
- Get products by farmer email
- Get all approved products (for buyers)
- Get pending products (for admin)
- Real-time updates with Stream

---

## 🚀 Usage in Code

### Add Product
```dart
final product = ProductModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  farmerId: farmerId,
  farmerName: farmerName, // From session
  farmerEmail: farmerEmail, // From session
  name: 'Product Name',
  description: 'Description',
  price: 10.0,
  quantity: 100,
  unit: 'kg',
  category: 'Vegetables',
  imageUrl: imageUrl,
  status: 'pending',
  createdAt: DateTime.now(),
);

await productService.addProduct(product);
```

### Get Farmer Products
```dart
// By farmer ID
final products = await productService.getFarmerProducts(farmerId);

// By farmer email
final products = await productService.getFarmerProductsByEmail(farmerEmail);
```

### Real-time Updates
```dart
productService.streamFarmerProducts(farmerId).listen((products) {
  // Update UI with new products
});
```

---

## 📝 Migration Notes

### What Changed
1. ✅ **Database**: Realtime Database → Firestore
2. ✅ **Service**: `ProductService` → `ProductFirestoreService`
3. ✅ **Model**: Added `farmerName` and `farmerEmail` fields
4. ✅ **Storage**: Images still stored in Firebase Storage (unchanged)

### What Stayed the Same
- ✅ Image upload to Firebase Storage
- ✅ Product listing UI
- ✅ Search and filtering
- ✅ Product CRUD operations

---

## 🧪 Testing Checklist

- [ ] Enable Firestore in Firebase Console
- [ ] Set Firestore security rules
- [ ] Run `flutter pub get` to install `cloud_firestore`
- [ ] Test adding a product (should save to Firestore)
- [ ] Verify farmer name and email are stored
- [ ] Test editing a product
- [ ] Test deleting a product
- [ ] Test search and filtering
- [ ] Check Firestore console to see products

---

## 🐛 Troubleshooting

### Error: "Cloud Firestore API has not been used"
- **Solution**: Enable Firestore in Firebase Console (Step 1)

### Error: "Missing or insufficient permissions"
- **Solution**: Update Firestore security rules (Step 2)

### Error: "The query requires an index"
- **Solution**: Click the link in the error to create the index automatically

### Products not showing
- Check Firestore console to see if products are being saved
- Check security rules allow reads
- Verify farmer ID/email is being passed correctly

---

## 📚 Additional Resources

- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Flutter Firestore Plugin](https://pub.dev/packages/cloud_firestore)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Last Updated**: Products now stored in Firestore with farmer username and email! 🎉
