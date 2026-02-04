# 🦙 Yerel LLM ve Ollama Kurulum Rehberi

Bu proje, yapay zeka destekli özelliklerini çalıştırmak için **Ollama** altyapısını ve **Llama** modellerini kullanmaktadır. Bu doküman, geliştirme ortamının neden bu şekilde kurgulandığını ve hem Windows hem de macOS için kurulum adımlarını içermektedir.

## 🚀 Mimari Kararlar: Neden Llama 3.2 ve Yerel Çalışma?

Projemizde "Yerel Geliştirme" ve "Sunucu (Production)" olmak üzere iki farklı model stratejisi izlemekteyiz. Bunun temel sebepleri donanım gereksinimleri ve maliyet optimizasyonudur.

### 1. Yerel Ortam (Localhost) - Llama 3.2 (3B)

Geliştirme aşamasında kendi bilgisayarlarımızda (Laptop/Desktop) **Llama 3.2 (3B)** modelini kullanıyoruz.

- **Boyut:** Yaklaşık **2.0 GB**.
- **Neden:** Bu model, standart bir bilgisayarın RAM ve GPU'sunu yormadan çok hızlı çalışır. Anlık tepki verir ve kodlama/test aşamasında bizi bekletmez. MacBook (M Serisi) ve standart Windows bilgisayarlarda akıcı bir deneyim sunar.

### 2. Sunucu Ortamı (Production) - Llama 4 Maverick (70B)

Canlı sunucuda ise modelin **70B (70 Milyar parametre)** versiyonunu (veya GPT-4 seviyesindeki muadillerini) kullanacağız.

- **Boyut:** Yaklaşık **40 GB - 70 GB** (VRAM gereksinimi).
- **Neden:** Bu model çok daha zekidir, karmaşık mantık yürütme yeteneğine sahiptir ancak çalıştırılması için güçlü veri merkezi GPU'larına ihtiyaç duyar.

**Özet:** Kendi bilgisayarımızda "hafif" modelle iskeleti kurup test ediyor, ağır yükü sunucudaki "dev" modele bırakıyoruz.

---

## 🛠️ Kurulum Adımları

Aşağıdaki adımları takiperek bilgisayarınızı yapay zeka geliştirme ortamına hazırlayabilirsiniz.

### 1. Ollama'yı Yükleme

Ollama, büyük dil modellerini (LLM) yerel bilgisayarınızda çalıştırmanızı sağlayan motorun adıdır.

#### 🍎 macOS Kullanıcıları İçin

1. [ollama.com/download](https://ollama.com/download) adresine gidin.
2. **"Download for macOS"** butonuna tıklayın.
3. İndirilen `.zip` dosyasını açın ve `Ollama` uygulamasını **Uygulamalar (Applications)** klasörüne sürükleyin.
4. Uygulamayı çalıştırın ve kurulum sihirbazını tamamlayın.
5. Terminali açın ve şu komutu yazarak kurulduğunu doğrulayın:

```bash
ollama --version

```

#### 🪟 Windows Kullanıcıları İçin

1. [ollama.com/download](https://ollama.com/download) adresine gidin.
2. **"Download for Windows"** butonuna tıklayın.
3. İndirilen `.exe` dosyasını çalıştırın ve kurulumu tamamlayın.
4. Kurulum bittikten sonra **PowerShell** veya **Komut İstemi'ni (CMD)** açın.
5. Şu komutu yazarak kurulduğunu doğrulayın:

```powershell
ollama --version

```

---

### 2. Llama 3.2 Modelini İndirme ve Çalıştırma

Ollama kurulduktan sonra, projemiz için gerekli olan 2GB'lık hafif modeli indireceğiz. Bu işlem internet hızınıza bağlı olarak birkaç dakika sürebilir.

**Terminal (macOS) veya PowerShell (Windows) üzerinde şu komutu çalıştırın:**

```bash
ollama run llama3.2

```

**Bu komut şunları yapar:**

1. Llama 3.2 modelinin "manifest" dosyasını çeker.
2. Yaklaşık 2.0 GB boyutundaki model dosyalarını indirir.
3. Modeli çalıştırır ve size sohbet edebileceğiniz bir alan açar.

Eğer `>>> Send a message` satırını görüyorsanız kurulum başarıyla tamamlanmıştır! 🎉
Çıkmak için `/bye` yazabilir veya `Ctrl + D` tuşlarına basabilirsiniz.

---

### 3. Arka Plan Testi (API Kontrolü)

Projemizdeki Python/Flutter uygulamaları Ollama ile **localhost** üzerinden haberleşecektir. Ollama çalıştığı sürece arka planda 11434 portunu dinler.

Tarayıcınızdan şu adrese giderek servisin çalışıp çalışmadığını kontrol edebilirsiniz:

👉 [http://localhost:11434](https://www.google.com/search?q=http://localhost:11434)

Ekranda sadece `Ollama is running` yazısını görüyorsanız her şey yolunda demektir.

---

### ⚠️ Sık Karşılaşılan Sorunlar

- **"Command not found" hatası:** Ollama'yı yükledikten sonra terminali kapatıp yeniden açmanız gerekebilir.
- **Yavaşlama:** Eğer model çalışırken bilgisayarınız çok yavaşlarsa, arka plandaki diğer ağır uygulamaları (oyun, render programları vb.) kapatın.
- **Port Hatası:** Eğer `11434` portu dolu hatası alırsanız, Ollama'nın zaten arka planda çalışıp çalışmadığını kontrol edin (Sağ alt/üst bardaki simgeye bakın).

---

### Sonraki Adım

Kurulum tamamlandıktan sonra projenin backend servisini (Python) başlatabilir ve Flutter arayüzünden modele bağlanabilirsiniz.
