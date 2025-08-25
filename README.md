# bitbithabit

Sebuah aplikasi pelacak kebiasaan (habit tracker) yang modern dan minimalis, dibangun dengan Flutter sebagai Proyek Ujian Akhir Semester (UAS). Aplikasi ini memungkinkan pengguna untuk mendefinisikan, melacak, dan menganalisis berbagai jenis kebiasaan harian dengan visualisasi data yang interaktif.

## Deskripsi & Fitur

**bitbithabit** dirancang untuk membantu pengguna membangun dan mempertahankan kebiasaan positif melalui pendekatan yang fleksibel dan visual. Tidak seperti aplikasi pelacak biasa, bitbithabit mendukung berbagai tipe habit sesuai kebutuhan pengguna.

Fitur utama dari aplikasi ini meliputi:

🎨 **Kustomisasi Habit Penuh**: Setiap habit dapat diberi nama dan warna unik untuk identifikasi visual yang mudah.

🧱 **Tiga Tipe Habit Fleksibel**:
- **Binary**: Untuk kebiasaan sederhana yang hanya memiliki status selesai/tidak (contoh: "Minum Vitamin").
- **Kuantitatif (Mencapai Target)**: Untuk kebiasaan yang diukur dengan target (contoh: "Lari dengan target 5 km").
- **Kuantitatif (Di Bawah Batas)**: Untuk mengontrol kebiasaan yang ingin dikurangi (contoh: "Merokok dengan batas maksimal 3 batang").

📅 **Tampilan Grid Interaktif**: Antarmuka utama menampilkan semua habit dalam format tabel dengan tanggal yang dapat digulir secara horizontal, memungkinkan pengguna melihat dan mencatat progres dengan cepat.

📊 **Halaman Summary & Insight**: Setiap habit memiliki halaman ringkasan (summary) sendiri yang menampilkan statistik performa per bulan, seperti:
- Streak (rangkaian) di bulan tersebut.
- Tingkat penyelesaian bulanan.
- Statistik keseluruhan (streak saat ini, streak tertinggi, dan performa total).
- Kalender bulanan visual (heatmap) untuk melihat konsistensi.

🗂️ **Arsip Habit**: Pengguna dapat mengarsipkan habit yang sedang tidak aktif tanpa harus menghapusnya, menjaga tampilan utama tetap bersih dan fokus.

## Plugin FlutterGems yang Digunakan

Proyek ini memenuhi persyaratan dengan menggunakan beberapa plugin modern dan populer dari FlutterGems:

- **flutter_riverpod**: Sebagai solusi state management utama untuk mengelola state aplikasi secara reaktif dan efisien.
- **go_router**: Untuk sistem navigasi deklaratif yang kuat, memungkinkan alur perpindahan antar halaman yang kompleks namun tetap terstruktur.
- **hive / hive_flutter**: Sebagai database lokal NoSQL yang super cepat untuk menyimpan semua data habit dan log progres langsung di perangkat.
- **shared_preferences**: Untuk menyimpan data sederhana (key-value) seperti tanggal pertama kali aplikasi dibuka.
- **intl**: Untuk fungsionalitas internasionalisasi, terutama dalam memformat tanggal agar sesuai dengan lokal Bahasa Indonesia (id_ID).
- **flutter_colorpicker**: Menyediakan UI widget untuk fitur pemilihan warna kustom saat membuat atau mengedit habit.
- **uuid**: Utilitas untuk menghasilkan ID unik (UUID v4) untuk setiap habit baru.

## Inspirasi

Proyek ini sangat terinspirasi oleh fungsionalitas dan desain dari aplikasi open-source **mhabit** oleh FriesI23.

[Lihat proyek mhabit di GitHub](https://github.com/FriesI23/mhabit).

## Petunjuk Instalasi & Build

### Prerequisites

Pastikan Anda telah menginstal dan mengkonfigurasi environment berikut di mesin Anda:

- **Flutter SDK**: Versi 3.19 atau yang lebih baru.
- **Dart SDK**: Versi 3.3 atau yang lebih baru.
- **Android Studio** atau **Visual Studio Code** dengan ekstensi Flutter.
- **Perangkat Android** (Emulator atau Fisik) untuk menjalankan aplikasi.

### Instalasi

1. Clone repositori ini:
   ```bash
   git clone <URL_REPOSITORI_ANDA>
   ```

2. Masuk ke direktori proyek:
   ```bash
   cd bitbithabit
   ```

3. Install semua dependensi:
   ```bash
   flutter pub get
   ```

### Menjalankan Aplikasi

1. **Generate file untuk Hive**:
   
   Karena proyek ini menggunakan Hive, Anda wajib menjalankan perintah ini sebelum menjalankan aplikasi untuk pertama kali, atau setiap kali ada perubahan pada file model (`habit.dart`, `habit_log.dart`).
   
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Jalankan aplikasi dalam mode debug**:
   
   Pastikan perangkat Anda terhubung, lalu jalankan:
   
   ```bash
   flutter run
   ```

### Build APK untuk Release

Untuk membuat file APK yang siap untuk diinstal di perangkat Android, jalankan perintah berikut:

```bash
flutter build apk --release
```

File APK akan tersedia di direktori `build/app/outputs/flutter-apk/app-release.apk`.