# Firebase Hızlı Başlangıç / Quick Start

## ⚠️ ÖNEMLİ: Firebase SDK Eklemeden Önce

Şu anda kod Firebase SDK olmadan derlenmeyecek. Lütfen aşağıdaki adımları takip edin:

## Adım 1: Firebase SDK Ekleme (Xcode)

1. Xcode'da projenizi açın
2. **File > Add Package Dependencies...** menüsüne gidin
3. Şu URL'yi girin: `https://github.com/firebase/firebase-ios-sdk`
4. "Add Package" butonuna tıklayın
5. Versiyon seçin: **"Up to Next Major Version"** ve **10.0.0** veya daha yeni
6. Şu paketleri seçin:
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseFirestore** 
   - ✅ **FirebaseCore**
7. "Add Package" butonuna tıklayın
8. Paketlerin indirilmesini bekleyin

## Adım 2: Target'a Ekleme

1. Project Navigator'da projenize tıklayın
2. Target'ınızı seçin (Cullinvoice)
3. **General** sekmesine gidin
4. **Frameworks, Libraries, and Embedded Content** bölümüne gidin
5. Şunların eklendiğinden emin olun:
   - FirebaseAuth.framework
   - FirebaseFirestore.framework
   - FirebaseCore.framework
6. Eğer yoksa, "+" butonuna tıklayıp ekleyin

## Adım 3: Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add project" veya mevcut bir proje seçin
3. iOS uygulamasını ekleyin
4. Bundle ID'nizi girin (Xcode'da General sekmesinde bulabilirsiniz)
5. `GoogleService-Info.plist` dosyasını indirin
6. Dosyayı Xcode projenize sürükleyin (Cullinvoice klasörüne)
7. "Copy items if needed" seçeneğini işaretleyin

## Adım 4: Build ve Test

1. Xcode'da **Product > Clean Build Folder** (Cmd+Shift+K)
2. **Product > Build** (Cmd+B)
3. Hata yoksa başarılı!

## Sorun Giderme

### "Unable to find module dependency: 'FirebaseFirestore'"
- Firebase SDK'nın eklendiğinden emin olun (Adım 1)
- Xcode'u yeniden başlatın
- Clean Build Folder yapın

### "GoogleService-Info.plist not found"
- Dosyanın projeye eklendiğinden emin olun
- Target'a eklendiğinden emin olun (File Inspector'da target checkbox'ı işaretli olmalı)

### Build hatası: "No such module"
- Package Dependencies'te Firebase'in göründüğünden emin olun
- Xcode'u yeniden başlatın
- Derived Data'yı temizleyin: Xcode > Settings > Locations > Derived Data > Delete

---

## Türkçe

### Adım 1: Firebase SDK Ekleme (Xcode)

1. Xcode'da projenizi açın
2. **File > Add Package Dependencies...** menüsüne gidin
3. Şu URL'yi girin: `https://github.com/firebase/firebase-ios-sdk`
4. "Add Package" butonuna tıklayın
5. Versiyon seçin: **"Up to Next Major Version"** ve **10.0.0** veya daha yeni
6. Şu paketleri seçin:
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseFirestore** 
   - ✅ **FirebaseCore**
7. "Add Package" butonuna tıklayın
8. Paketlerin indirilmesini bekleyin

### Adım 2: Target'a Ekleme

1. Project Navigator'da projenize tıklayın
2. Target'ınızı seçin (Cullinvoice)
3. **General** sekmesine gidin
4. **Frameworks, Libraries, and Embedded Content** bölümüne gidin
5. Şunların eklendiğinden emin olun:
   - FirebaseAuth.framework
   - FirebaseFirestore.framework
   - FirebaseCore.framework
6. Eğer yoksa, "+" butonuna tıklayıp ekleyin

### Adım 3: Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
2. "Add project" veya mevcut bir proje seçin
3. iOS uygulamasını ekleyin
4. Bundle ID'nizi girin (Xcode'da General sekmesinde bulabilirsiniz)
5. `GoogleService-Info.plist` dosyasını indirin
6. Dosyayı Xcode projenize sürükleyin (Cullinvoice klasörüne)
7. "Copy items if needed" seçeneğini işaretleyin

### Adım 4: Build ve Test

1. Xcode'da **Product > Clean Build Folder** (Cmd+Shift+K)
2. **Product > Build** (Cmd+B)
3. Hata yoksa başarılı!

