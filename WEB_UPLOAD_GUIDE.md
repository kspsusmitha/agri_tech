# Web Upload Guide - Product Listing

## ✅ Web Support Enabled

The product listing feature now fully supports web platform! You can upload products with images through your web browser.

## 🌐 Web-Specific Features

### Image Upload on Web
- **Gallery Only**: On web, only the gallery/file picker option is available (camera is not supported in browsers)
- **File Selection**: Click on the image area to open your file browser and select an image
- **Supported Formats**: JPG, PNG, and other common image formats
- **Automatic Compression**: Images are automatically compressed to 85% quality and max width of 1024px

### Firebase Storage
- ✅ Firebase Storage works seamlessly on web
- ✅ Images are uploaded to Firebase Storage
- ✅ Download URLs are automatically generated
- ✅ Images are displayed in product cards

## 🚀 How to Use on Web

### 1. Run the App on Web
```bash
flutter run -d chrome
# or
flutter run -d edge
# or
flutter run -d web-server
```

### 2. Navigate to Product Listing
1. Login as a Farmer
2. Go to Farmer Dashboard
3. Click on "Product Listing" or "My Products"

### 3. Add a Product
1. Click the "+" button or "Add Product"
2. Fill in product details:
   - Product Name
   - Description
   - Price
   - Quantity
   - Category
   - Unit
3. **Upload Image**:
   - Click on the image area (shows "Tap to add image")
   - On web, this will open your file browser
   - Select an image file
   - The image will appear in the preview
4. Click "Add" to save

### 4. Edit Product
1. Click "Edit" on any product card
2. Update any fields
3. To change image: Click on the image area and select a new file
4. Click "Update" to save changes

### 5. Search and Filter
- **Search Bar**: Type to search by product name or description
- **Category Filter**: Filter by Vegetables, Fruits, Grains, Dairy, or Other
- **Status Filter**: Filter by Pending, Approved, or Rejected

## 📋 Requirements

### Firebase Setup
1. **Firebase Storage**: Must be enabled in Firebase Console
2. **Storage Rules**: Set appropriate security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{farmerId}/{productId}.jpg {
      // Allow authenticated users to upload
      allow write: if request.auth != null;
      // Allow anyone to read
      allow read: if true;
    }
  }
}
```

### Browser Compatibility
- ✅ Chrome/Edge (Chromium-based)
- ✅ Firefox
- ✅ Safari
- ✅ Opera

## 🔧 Technical Details

### Platform Detection
The app automatically detects if it's running on web using `kIsWeb`:
- On web: Only shows gallery option (camera not available)
- On mobile/desktop: Shows both camera and gallery options

### Image Processing
- Images are converted to `Uint8List` bytes
- Uploaded to Firebase Storage as JPEG format
- Stored at: `products/{farmerId}/{productId}.jpg`
- Download URLs are stored in Firebase Realtime Database

### Error Handling
- If image upload fails, an error message is shown
- If image pick fails on web, a helpful error message is displayed
- All errors are logged to console for debugging

## 🐛 Troubleshooting

### Image Not Uploading
1. Check Firebase Storage is enabled
2. Check Storage security rules allow uploads
3. Check browser console for errors
4. Verify you're logged in as a farmer

### Image Not Displaying
1. Check Firebase Storage rules allow reads
2. Check image URL is stored correctly in database
3. Check browser console for CORS errors
4. Verify image was uploaded successfully

### File Picker Not Working
1. Check browser permissions
2. Try a different browser
3. Check browser console for errors
4. Ensure you're using a modern browser

## 📝 Notes

- **File Size**: Large images are automatically compressed
- **Image Quality**: Set to 85% for good quality/size balance
- **Max Width**: Images are resized to max 1024px width
- **Format**: All images are saved as JPEG (.jpg)

## ✅ Testing Checklist

- [ ] Can add product with image on web
- [ ] Can edit product and change image on web
- [ ] Can delete product (image also deleted)
- [ ] Search works correctly
- [ ] Filters work correctly
- [ ] Images display correctly in product cards
- [ ] Pull-to-refresh works
- [ ] Loading states show correctly

---

**Last Updated**: Product listing now fully supports web platform! 🎉
