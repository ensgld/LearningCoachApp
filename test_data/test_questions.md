# Test Soruları ve Senaryoları

## Genel Chat Soruları
Bu soruların amacı genel bilgi ve sohbet yeteneğini test etmektir.
1. İstanbul'un fethi ne zaman gerçekleşti ve hangi padişah tarafından yapıldı?
2. Kuantum dolanıklığı nedir? Basitçe açıklar mısın?
3. Bana Python ile bir Fibonacci dizisi hesaplayan fonksiyon yazar mısın?
4. Motivasyonumu kaybettim, bana çalışmak için 3 neden söyler misin?
5. Dünyanın en derin çukuru neresidir ve derinliği ne kadardır?
6. Yapay zeka gelecekte meslekleri nasıl etkileyecek?
7. Sağlıklı beslenmek için günde kaç öğün yemeliyim?
8. Bana kısa ve komik bir fıkra anlatır mısın?
9. "Sefiller" kitabının yazarı kimdir?
10. Mars'a insanlı yolculuk ne zaman mümkün olabilir?

---

## Koç Tavsiyesi (Coach Tip) Senaryoları
Aşağıdaki metinler, uygulamanın arka planda `CoachTipCard` üzerinden gönderdiği prompt yapılarını simüle eder. Test ederken bu metinleri Chat ekranına yapıştırarak veya API request body olarak kullanarak test edebilirsiniz.

### Senaryo 1: Yeni Başlayan (Hiç Veri Yok)
```text
Merhaba Koç, benim "Learning Coach" asistanımsın. İşte bugünkü durumum:

👤 **Kullanıcı Profili:**
- Seviye: 1 (TOHUM)
- XP: 0 / 100
- Toplam Altın: 0

📅 **Bugünkü Özet:**
- Toplam Çalışma: 0 dakika
- Oturum Sayısı: 0

Henüz detaylı bir çalışma kaydım yok.

Lütfen bu verilere dayanarak bana özel, motive edici ve gelişim odaklı bir tavsiye ver. Eğer verimsiz geçtiyse nazikçe uyar, iyiyse kutla.
```

### Senaryo 2: Verimli Bir Gün (Çok Çalışmış)
```text
Merhaba Koç, benim "Learning Coach" asistanımsın. İşte bugünkü durumum:

👤 **Kullanıcı Profili:**
- Seviye: 5 (FİDAN)
- XP: 450 / 500
- Toplam Altın: 320

📅 **Bugünkü Özet:**
- Toplam Çalışma: 180 dakika
- Oturum Sayısı: 4

📝 **Oturum Detayları:**
- **09:00** | Matematik Çalışması (50 dk) | Quiz Başarısı: %85 | ⚡ Verimli (Erken bitti)
- **11:00** | Tarih Okuması (40 dk)
- **14:00** | Fizik Problemleri (60 dk) | 🐢 Biraz uzadı
- **16:00** | İngilizce Kelime (30 dk) | Quiz Başarısı: %95

Lütfen bu verilere dayanarak bana özel, motive edici ve gelişim odaklı bir tavsiye ver. Eğer verimsiz geçtiyse nazikçe uyar, iyiyse kutla.
```

### Senaryo 3: Zorlanan Kullanıcı (Düşük Başarı)
```text
Merhaba Koç, benim "Learning Coach" asistanımsın. İşte bugünkü durumum:

👤 **Kullanıcı Profili:**
- Seviye: 3 (FİLİZ)
- XP: 210 / 300
- Toplam Altın: 150

📅 **Bugünkü Özet:**
- Toplam Çalışma: 45 dakika
- Oturum Sayısı: 2

📝 **Oturum Detayları:**
- **10:00** | Kimya Konu Anlatımı (30 dk) | Quiz Başarısı: %40
- **13:30** | Biyoloji Testi (15 dk) | Quiz Başarısı: %30

Lütfen bu verilere dayanarak bana özel, motive edici ve gelişim odaklı bir tavsiye ver. Eğer verimsiz geçtiyse nazikçe uyar, iyiyse kutla.
```
