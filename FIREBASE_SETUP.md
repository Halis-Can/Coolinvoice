# Firebase Setup Instructions / Firebase Kurulum Talimatları

## English

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard
4. Enable **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable **Email/Password** provider
5. Enable **Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Start in **test mode** (you can add security rules later)
   - Choose a location close to your users

### Step 2: Add iOS App to Firebase

1. In Firebase Console, click the iOS icon (or "Add app")
2. Register your app:
   - **Bundle ID**: Find this in Xcode under your target's General tab (e.g., `com.yourcompany.Cullinvoice`)
   - **App nickname**: Cullinvoice (optional)
   - **App Store ID**: (optional, leave blank for now)
3. Download `GoogleService-Info.plist`
4. Add the file to your Xcode project:
   - Drag `GoogleService-Info.plist` into the `Cullinvoice` folder in Xcode
   - Make sure "Copy items if needed" is checked
   - Make sure it's added to the target

### Step 3: Add Firebase SDK via Swift Package Manager

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Click "Add Package"
4. **IMPORTANT:** Select version **10.0.0 or later** (or latest stable version)
5. Select these products:
   - ✅ **FirebaseAuth** (required)
   - ✅ **FirebaseFirestore** (required)
   - ✅ **FirebaseCore** (required)
   - ❌ **FirebaseFirestoreSwift** (NOT needed - we use manual encoding)
6. Click "Add Package"
7. Wait for Xcode to resolve and download the packages
8. Make sure all packages are added to your target in "Frameworks, Libraries, and Embedded Content"

### Step 4: Configure Firestore Security Rules

Go to Firestore Database > Rules and use:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 5: Test the Integration

1. Build and run the app
2. You should see the login screen
3. Create an account or sign in
4. Your data will now sync across all devices!

---

## Türkçe

### Adım 1: Firebase Projesi Oluştur

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add project" (Proje ekle) butonuna tıklayın veya mevcut bir proje seçin
3. Kurulum sihirbazını takip edin
4. **Authentication** (Kimlik Doğrulama) etkinleştirin:
   - Authentication > Sign-in method (Giriş yöntemi) bölümüne gidin
   - **Email/Password** (E-posta/Şifre) sağlayıcısını etkinleştirin
5. **Firestore Database** (Firestore Veritabanı) etkinleştirin:
   - Firestore Database bölümüne gidin
   - "Create database" (Veritabanı oluştur) butonuna tıklayın
   - **Test mode** (Test modu) ile başlatın (güvenlik kurallarını daha sonra ekleyebilirsiniz)
   - Kullanıcılarınıza yakın bir konum seçin

### Adım 2: iOS Uygulamasını Firebase'e Ekle

1. Firebase Console'da iOS simgesine (veya "Add app" butonuna) tıklayın
2. Uygulamanızı kaydedin:
   - **Bundle ID**: Bunu Xcode'da target'ınızın General sekmesinde bulun (örn: `com.yourcompany.Cullinvoice`)
   - **App nickname**: Cullinvoice (isteğe bağlı)
   - **App Store ID**: (isteğe bağlı, şimdilik boş bırakın)
3. `GoogleService-Info.plist` dosyasını indirin
4. Dosyayı Xcode projenize ekleyin:
   - `GoogleService-Info.plist` dosyasını Xcode'da `Cullinvoice` klasörüne sürükleyin
   - "Copy items if needed" (Gerekirse öğeleri kopyala) seçeneğinin işaretli olduğundan emin olun
   - Target'a eklendiğinden emin olun

### Adım 3: Swift Package Manager ile Firebase SDK Ekle

1. Xcode'da **File > Add Package Dependencies...** (Dosya > Paket Bağımlılıkları Ekle...) menüsüne gidin
2. Şu adresi girin: `https://github.com/firebase/firebase-ios-sdk`
3. "Add Package" (Paket Ekle) butonuna tıklayın
4. Şu ürünleri seçin:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseFirestoreSwift
   - ✅ FirebaseCore
5. "Add Package" (Paket Ekle) butonuna tıklayın

### Adım 4: Firestore Güvenlik Kurallarını Yapılandır

Firestore Database > Rules (Kurallar) bölümüne gidin ve şunu kullanın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar yalnızca kendi verilerine erişebilir
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Adım 5: Entegrasyonu Test Et

1. Uygulamayı derleyin ve çalıştırın
2. Giriş ekranını görmelisiniz
3. Bir hesap oluşturun veya giriş yapın
4. Verileriniz artık tüm cihazlarda senkronize olacak!

---

## Önemli Notlar / Important Notes

- **Offline Support**: Firebase Firestore otomatik olarak offline desteği sağlar. İnternet bağlantısı olmadığında veriler yerel olarak saklanır ve bağlantı geri geldiğinde senkronize edilir.
- **Real-time Updates**: Tüm değişiklikler gerçek zamanlı olarak tüm cihazlara yansır.
- **Security**: Güvenlik kurallarını production'a geçmeden önce gözden geçirmeyi unutmayın.

