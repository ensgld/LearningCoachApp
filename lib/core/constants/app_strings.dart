class AppStrings {
  // Localized methods
  static String getAppName(String locale) =>
      locale == 'tr' ? 'Öğrenme Koçu' : 'Learning Coach';
  static String getNavHome(String locale) =>
      locale == 'tr' ? 'Ana Sayfa' : 'Home';
  static String getNavStudy(String locale) =>
      locale == 'tr' ? 'Çalış' : 'Study';
  static String getNavDocs(String locale) =>
      locale == 'tr' ? 'Dokümanlar' : 'Documents';
  static String getNavProfile(String locale) =>
      locale == 'tr' ? 'Profil' : 'Profile';
  static String getProfileSubtitle(String locale) =>
      locale == 'tr' ? 'Ayarlarınızı yönetin' : 'Manage your settings';
  static String getProfileSettings(String locale) =>
      locale == 'tr' ? 'Ayarlar' : 'Settings';
  static String getDailyGoalLabel(String locale) =>
      locale == 'tr' ? 'Günlük Hedef (dk)' : 'Daily Goal (min)';
  static String getNotificationsLabel(String locale) =>
      locale == 'tr' ? 'Bildirimler' : 'Notifications';
  static String getLanguageLabel(String locale) =>
      locale == 'tr' ? 'Dil / Language' : 'Language / Dil';
  static String getLogoutBtn(String locale) =>
      locale == 'tr' ? 'Çıkış Yap' : 'Logout';
  static String getLogoutTitle(String locale) =>
      locale == 'tr' ? 'Çıkış Yap' : 'Logout';
  static String getLogoutMessage(String locale) => locale == 'tr'
      ? 'Çıkış yapmak istediğinizden emin misiniz?'
      : 'Are you sure you want to logout?';
  static String getCancel(String locale) => locale == 'tr' ? 'İptal' : 'Cancel';
  static String getLanguageChanged(String locale, String lang) =>
      locale == 'tr' ? 'Dil değiştirildi: $lang' : 'Language changed: $lang';

  // Docs
  static String getDocsEmptyState(String locale) => locale == 'tr'
      ? 'Henüz doküman yok.\nPDF yükleyerek başlayın.'
      : 'No documents yet.\nStart by uploading a PDF.';
  static String getDocsUploadBtn(String locale) =>
      locale == 'tr' ? 'Doküman Yükle' : 'Upload Document';
  static String getDocStatusProcessing(String locale) =>
      locale == 'tr' ? 'İşleniyor' : 'Processing';
  static String getDocStatusReady(String locale) =>
      locale == 'tr' ? 'Hazır' : 'Ready';
  static String getDocStatusFailed(String locale) =>
      locale == 'tr' ? 'Hata' : 'Failed';
  static String getDocProcessingNotice(String locale) => locale == 'tr'
      ? 'Doküman işleniyor, birazdan hazır.'
      : 'Document is processing and will be ready soon.';
  static String getAskDocHint(String locale) =>
      locale == 'tr' ? 'Dokümana sor...' : 'Ask document...';
  static String getSourcesTitle(String locale) =>
      locale == 'tr' ? 'Kaynaklar' : 'Sources';

  // Study
  static String getStudyGoalLabel(String locale) =>
      locale == 'tr' ? 'Hedef Seçin' : 'Select Goal';
  static String getStudyDurationLabel(String locale) =>
      locale == 'tr' ? 'Süre (dk)' : 'Duration (min)';
  static String getStudyStartBtn(String locale) =>
      locale == 'tr' ? 'Başla' : 'Start';
  static String getQuizTitle(String locale) =>
      locale == 'tr' ? 'Kısa Quiz' : 'Quick Quiz';
  static String getQuizSubmitBtn(String locale) =>
      locale == 'tr' ? 'Tamamla' : 'Complete';

  // Coach
  static String getCoachChatTitle(String locale) =>
      locale == 'tr' ? 'Koç Sohbeti' : 'Coach Chat';
  static String getAskCoachHint(String locale) =>
      locale == 'tr' ? 'Koça sor...' : 'Ask coach...';

  // Kaizen
  static String getQuickKaizenTitle(String locale) =>
      locale == 'tr' ? 'Kaizen Check-in' : 'Kaizen Check-in';
  static String getDailyProgress(String locale) =>
      locale == 'tr' ? 'Günlük gelişim takibi' : 'Daily progress tracking';
  static String getWhatDidYesterday(String locale) =>
      locale == 'tr' ? 'Dün ne yaptım?' : 'What did I do yesterday?';
  static String getWhatBlockedMe(String locale) =>
      locale == 'tr' ? 'Beni ne engelledi?' : 'What blocked me?';
  static String getWhatWillDoBetter(String locale) => locale == 'tr'
      ? 'Bugün neyi daha iyi yapacağım?'
      : 'What will I do better today?';
  static String getSaveAndFinish(String locale) =>
      locale == 'tr' ? 'Kaydet ve Bitir' : 'Save and Finish';
  static String getKaizenSaved(String locale) => locale == 'tr'
      ? 'Kaizen kaydedildi! Yarın için başarılar.'
      : 'Kaizen saved! Good luck for tomorrow.';

  // Home
  static String getStudySubtitle(String locale) => locale == 'tr'
      ? 'Bugün hangi hedefe çalışalım?'
      : 'Which goal to study today?';
  static String getManageMaterialsSubtitle(String locale) =>
      locale == 'tr' ? 'Materyallerinizi yönetin' : 'Manage your materials';
  static String getCoachSubtitle(String locale) =>
      locale == 'tr' ? 'AI öğrenme asistanı' : 'AI learning assistant';
  static String getNextLevel(String locale) =>
      locale == 'tr' ? 'Sonraki seviyeye' : 'Next level';
  static String getDailyQuest(String locale) =>
      locale == 'tr' ? '📜 Günlük Görev' : '📜 Daily Quest';
  static String getTodayAdventure(String locale) => locale == 'tr'
      ? '⚔️ Bugünün Macerasına Hazır Ol!'
      : '⚔️ Ready for Today\'s Adventure!';
  static String getDailyProgressHint(String locale) => locale == 'tr'
      ? 'Günlük ilerleme kaydını tamamla!'
      : 'Complete daily progress record!';

  // Study Session
  static String getMinutes(String locale) =>
      locale == 'tr' ? 'dakika' : 'minutes';
  static String getGoalLabel(String locale) =>
      locale == 'tr' ? 'Hedef' : 'Goal';
  static String getSessionSummary(String locale, int minutes) => locale == 'tr'
      ? '$minutes dakikalık verimli bir çalışma tamamladın.'
      : 'You completed a productive $minutes-minute study session.';

  // Shop
  static String getShopTitle(String locale) =>
      locale == 'tr' ? '🛍️ Mağaza' : '🛍️ Shop';
  static String getPotsTab(String locale) =>
      locale == 'tr' ? '🪴 Saksılar' : '🪴 Pots';
  static String getBackgroundsTab(String locale) =>
      locale == 'tr' ? '🖼️ Arka Planlar' : '🖼️ Backgrounds';
  static String getPurchased(String locale) =>
      locale == 'tr' ? '🎉 Satın Alındı!' : '🎉 Purchased!';
  static String getBuyBtn(String locale) => locale == 'tr' ? 'Satın Al' : 'Buy';
  static String getInsufficientGold(String locale, int needed) => locale == 'tr'
      ? 'Bu eşyayı satın almak için $needed altına daha ihtiyacınız var!'
      : 'You need $needed more gold to buy this item!';

  // Shop Items
  static String getTerracottaPot(String locale) =>
      locale == 'tr' ? '🪴 Terracotta Saksı' : '🪴 Terracotta Pot';
  static String getCeramicPot(String locale) =>
      locale == 'tr' ? '🏺 Seramik Saksı' : '🏺 Ceramic Pot';
  static String getWoodenPot(String locale) =>
      locale == 'tr' ? '🪵 Ahşap Saksı' : '🪵 Wooden Pot';
  static String getGoldPot(String locale) =>
      locale == 'tr' ? '✨ Altın Saksı' : '✨ Gold Pot';
  static String getCrystalPot(String locale) =>
      locale == 'tr' ? '💎 Kristal Saksı' : '💎 Crystal Pot';
  static String getNightSky(String locale) =>
      locale == 'tr' ? '🌙 Gece Gökyüzü' : '🌙 Night Sky';
  static String getForestBg(String locale) =>
      locale == 'tr' ? '🌲 Orman Arka Planı' : '🌲 Forest Background';
  static String getOceanBg(String locale) =>
      locale == 'tr' ? '🌊 Okyanus Arka Planı' : '🌊 Ocean Background';
  static String getSunnyPark(String locale) =>
      locale == 'tr' ? '☀️ Güneşli Park' : '☀️ Sunny Park';
  static String getRainbow(String locale) =>
      locale == 'tr' ? '🌈 Gökkuşağı' : '🌈 Rainbow';
  static String getSleepingCat(String locale) =>
      locale == 'tr' ? '🐱 Uyuyan Kedi' : '🐱 Sleeping Cat';
  static String getChirpingBird(String locale) =>
      locale == 'tr' ? '🐦 Cıvıldayan Kuş' : '🐦 Chirping Bird';
  static String getButterfly(String locale) =>
      locale == 'tr' ? '🦋 Kelebek' : '🦋 Butterfly';
  static String getWiseOwl(String locale) =>
      locale == 'tr' ? '🦉 Bilge Baykuş' : '🦉 Wise Owl';
  static String getMiniDragon(String locale) =>
      locale == 'tr' ? '🐉 Mini Ejderha' : '🐉 Mini Dragon';

  // Helper method to get shop item name by ID
  static String getShopItemName(String itemId, String locale) {
    switch (itemId) {
      case 'pot_terracotta':
        return getTerracottaPot(locale);
      case 'pot_ceramic':
        return getCeramicPot(locale);
      case 'pot_wooden':
        return getWoodenPot(locale);
      case 'pot_gold':
        return getGoldPot(locale);
      case 'pot_crystal':
        return getCrystalPot(locale);
      case 'bg_night':
        return getNightSky(locale);
      case 'bg_forest':
        return getForestBg(locale);
      case 'bg_ocean':
        return getOceanBg(locale);
      case 'bg_sunny':
        return getSunnyPark(locale);
      case 'bg_rainbow':
        return getRainbow(locale);
      case 'comp_cat':
        return getSleepingCat(locale);
      case 'comp_bird':
        return getChirpingBird(locale);
      case 'comp_butterfly':
        return getButterfly(locale);
      case 'comp_owl':
        return getWiseOwl(locale);
      case 'comp_dragon':
        return getMiniDragon(locale);
      default:
        return itemId;
    }
  }

  // Document Detail
  static String getSummaryTitle(String locale) =>
      locale == 'tr' ? 'Özet' : 'Summary';
  static String getSummaryProcessing(String locale) =>
      locale == 'tr' ? 'Özet hazırlanıyor...' : 'Summary is being prepared...';

  // Session Running
  static String getTrainingMode(String locale) =>
      locale == 'tr' ? 'Eğitim Modu' : 'Training Mode';
  static String getFinishBtn(String locale) =>
      locale == 'tr' ? 'Bitir' : 'Finish';
  static String getGoalPrefix(String locale) =>
      locale == 'tr' ? '🎯 Hedef' : '🎯 Goal';

  // Adventure Log
  static String getAdventureLog(String locale) =>
      locale == 'tr' ? '📜 Macera Günlüğü' : '📜 Adventure Log';
  static String getTotalMinutes(String locale) =>
      locale == 'tr' ? 'dk Toplam' : 'min Total';
  static String getSessions(String locale) =>
      locale == 'tr' ? 'Seans' : 'Sessions';
  static String getAvgScore(String locale) =>
      locale == 'tr' ? 'Ort. Skor' : 'Avg. Score';

  // Coach Tip
  static String getCoachTip(String locale) =>
      locale == 'tr' ? 'Koçtan İpucu' : 'Coach Tip';
  static String getCoachTipTitle(String locale) =>
      locale == 'tr' ? '💡 Koçtan İpucu' : '💡 Coach Tip';
  static String getPomodoroTip(String locale) => locale == 'tr'
      ? 'Pomodoro tekniği ile dikkatinizi canlı tutun.'
      : 'Keep your focus alive with Pomodoro technique.';

  // Home Buttons
  static String getStartMission(String locale) =>
      locale == 'tr' ? '🎯 Göreve Başla' : '🎯 Start Mission';
  static String getQuickTask(String locale) =>
      locale == 'tr' ? '⚡ Hızlı Görev' : '⚡ Quick Task';

  // Garden & Stage Features
  static String getSeedTitle(String locale) =>
      locale == 'tr' ? '🌱 Tohum' : '🌱 Seed';
  static String getSeedStageTitle(String locale) =>
      locale == 'tr' ? 'Tohum' : 'Seed';
  static String getNewStart(String locale) =>
      locale == 'tr' ? '⚡ Yeni Başlangıç' : '⚡ New Start';
  static String getNewStartPower(String locale) =>
      locale == 'tr' ? 'Yeni Başlangıç' : 'New Start';
  static String getSeedDescription(String locale) => locale == 'tr'
      ? 'Yolculuğun başlangıcı. Her çalışma seni güçlendirir.'
      : 'The beginning of your journey. Every study strengthens you.';
  static String getTouchToSeeTree(String locale) => locale == 'tr'
      ? '🪴 Evrim Ağacını Görmek İçin Dokun'
      : '🪴 Touch to See Evolution Tree';

  // Stage titles with emoji
  static String getSeedStage(String locale) =>
      locale == 'tr' ? '🌱 Tohum' : '🌱 Seed';
  static String getSproutStage(String locale) =>
      locale == 'tr' ? '🌿 Filiz' : '🌿 Sprout';
  static String getBloomStage(String locale) =>
      locale == 'tr' ? '🌸 Çiçek' : '🌸 Bloom';
  static String getTreeStage(String locale) =>
      locale == 'tr' ? '🌳 Ağaç' : '🌳 Tree';
  static String getForestStage(String locale) =>
      locale == 'tr' ? '🌲 Orman' : '🌲 Forest';

  // Stage power names
  static String getNewBeginningPower(String locale) =>
      locale == 'tr' ? 'Yeni Başlangıç' : 'New Beginning';
  static String getFastGrowthPower(String locale) =>
      locale == 'tr' ? 'Hızlı Büyüme' : 'Fast Growth';
  static String getBloomingPower(String locale) =>
      locale == 'tr' ? 'Çiçek Açımı' : 'Blooming';
  static String getWisdomTreePower(String locale) =>
      locale == 'tr' ? 'Bilgelik Ağacı' : 'Wisdom Tree';
  static String getMasterForestPower(String locale) =>
      locale == 'tr' ? 'Usta Ormanı' : 'Master Forest';

  // Stage descriptions
  static String getSproutDescription(String locale) => locale == 'tr'
      ? 'Büyümeye başladın! Artık daha hızlı öğreniyorsun.'
      : 'You\'ve started growing! Now you learn faster.';
  static String getBloomDescription(String locale) => locale == 'tr'
      ? 'Tüm potansiyelini açığa çıkarıyorsun!'
      : 'You\'re unleashing your full potential!';
  static String getTreeDescription(String locale) => locale == 'tr'
      ? 'Güçlü ve köklü bir bilgesin artık.'
      : 'You\'re now a strong and rooted sage.';
  static String getForestDescription(String locale) => locale == 'tr'
      ? 'Efsanevi usta! Senin bilgin tüm ormanı besliyor.'
      : 'Legendary master! Your wisdom nourishes the entire forest.';

  // Bonus labels
  static String getGoldBonus(String locale) =>
      locale == 'tr' ? 'Altın' : 'Gold';

  // Shop item status
  static String getEquipped(String locale) =>
      locale == 'tr' ? '✓ Kuşanılmış' : '✓ Equipped';
  static String getEquip(String locale) => locale == 'tr' ? 'Kuşan' : 'Equip';
  static String getItemEquipped(String locale) =>
      locale == 'tr' ? 'kuşanıldı!' : 'equipped!';

  // Coach chat quick prompts
  static String getCreatePlan(String locale) =>
      locale == 'tr' ? 'Plan oluştur' : 'Create Plan';
  static String getGenerateQuiz(String locale) =>
      locale == 'tr' ? 'Quiz üret' : 'Generate Quiz';
  static String getStruggledToday(String locale) =>
      locale == 'tr' ? 'Bugün zorlandım' : 'Struggled Today';
  static String getMotivateMe(String locale) =>
      locale == 'tr' ? 'Motivasyon ver' : 'Motivate Me';
  static String getCoachGreeting(String locale) => locale == 'tr'
      ? 'Merhaba! Size nasıl yardımcı olabilirim?'
      : 'Hello! How can I help you?';

  // Upload options
  static String getUploadFile(String locale) =>
      locale == 'tr' ? 'Dosya Yükle' : 'Upload File';
  static String getUploadFileSubtitle(String locale) => locale == 'tr'
      ? 'PDF, DOCX, TXT dosyalarını yükle'
      : 'Upload PDF, DOCX, TXT files';
  static String getTakePhoto(String locale) =>
      locale == 'tr' ? 'Fotoğraf Çek' : 'Take Photo';
  static String getTakePhotoSubtitle(String locale) => locale == 'tr'
      ? 'Kamera ile doküman fotoğrafı çek'
      : 'Take document photo with camera';

  // Profile Shop
  static String getCustomizeAvatar(String locale) =>
      locale == 'tr' ? 'Avatarını özelleştir!' : 'Customize your avatar!';

  // Constants (default Turkish for backward compatibility)
  static const String appName = 'Öğrenme Koçu';
  static const String navHome = 'Ana Sayfa';
  static const String navStudy = 'Çalış';
  static const String navDocs = 'Dokümanlar';
  static const String navProfile = 'Profil';
  static const String homeGreeting = 'Merhaba, Öğrenci 👋';
  static const String todayPlanTitle = 'Bugünün Planı';
  static const String sessionStartBtn = 'Seans Başlat';
  static const String quickKaizenTitle = 'Kaizen Check-in';
  static const String quickKaizenSubtitle = '2 dk değerlendirme';
  static const String weeklyProgress = 'Haftalık İlerleme';
  static const String coachTipTitle = 'Koçtan İpucu';
  static const String studyGoalLabel = 'Hedef Seçin';
  static const String studyDurationLabel = 'Süre (dk)';
  static const String studyStartBtn = 'Başla';
  static const String timerPaused = 'Duraklatıldı';
  static const String timerRunning = 'Odaklan...';
  static const String sessionFinishBtn = 'Bitir';
  static const String quizTitle = 'Kısa Quiz';
  static const String quizSubmitBtn = 'Tamamla';
  static const String docsEmptyState =
      'Henüz doküman yok.\nPDF yükleyerek başlayın.';
  static const String docsUploadBtn = 'Doküman Yükle';
  static const String docsSearchHint = 'Doküman ara...';
  static const String docStatusProcessing = 'İşleniyor';
  static const String docStatusReady = 'Hazır';
  static const String docStatusFailed = 'Hata';
  static const String coachChatTitle = 'Koç Sohbeti';
  static const String askCoachHint = 'Koça sor...';
  static const String askDocHint = 'Dokümana sor...';
  static const String sourcesTitle = 'Kaynaklar';
  static const String profileSettings = 'Ayarlar';
  static const String dailyGoalLabel = 'Günlük Hedef (dk)';
  static const String notificationsLabel = 'Bildirimler';
  static const String languageLabel = 'Dil / Language';
}
