/// Exercise Model
class ExerciseModel {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final ExerciseType type;
  final int duration; // in seconds
  final int repetitions; // number of repetitions
  final String? benefit; // Ne işe yarar?
  final Map<String, dynamic>? animationData;

  ExerciseModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.type,
    this.duration = 0,
    this.repetitions = 0,
    this.benefit,
    this.animationData,
  });
}

enum ExerciseType {
  blink, // Kelebek Gözler
  nearFar, // Yakın-Uzak
  figureEight, // Sekiz
  leftRight, // Sağa-Sola
  upDown, // Yukarı-Aşağı
  circle, // Daire
  rest, // Dinlenme
  cloud, // Bulut
  fastSlow, // Hızlı-Yavaş
  happy, // Mutlu Gözler
  fingerTracking, // Parmak Takibi
  peripheral, // Yan Görüş
  palming, // Palming
  breathing, // Nefes
  neckReset, // Boyun Reset
}

/// Exercise data for different profiles
class ExerciseData {
  static List<ExerciseModel> getChildExercises() {
    return [
      ExerciseModel(
        id: 'child_1',
        title: 'Kelebek Gözler',
        emoji: '🦋',
        description: 'Kelebek gibi kanat çırpalım!\nGözlerini yavaşça açıp kapat. 👁️',
        type: ExerciseType.blink,
        repetitions: 10,
        benefit: 'Gözleri nemlendirir ve rahatlatır',
      ),
      ExerciseModel(
        id: 'child_2',
        title: 'Yakın–Uzak Oyunu',
        emoji: '👆🌳',
        description: 'Parmağına bak. 👆\nŞimdi odanın sonuna bak. 🌳\nHadi tekrar!',
        type: ExerciseType.nearFar,
        repetitions: 5,
        benefit: 'Odaklanma becerisini geliştirir',
      ),
      ExerciseModel(
        id: 'child_3',
        title: 'Sihirli Sekiz',
        emoji: '✨',
        description: 'Gözlerinle havaya bir sekiz çiz.\nÇok yavaş ve sakin. ✨',
        type: ExerciseType.figureEight,
        duration: 30,
        benefit: 'Göz koordinasyonunu güçlendirir',
      ),
      ExerciseModel(
        id: 'child_4',
        title: 'Sağa–Sola Bakalım',
        emoji: '👀',
        description: 'Başın sabit!\nSadece gözlerinle sağa ve sola bak.',
        type: ExerciseType.leftRight,
        repetitions: 10,
        benefit: 'Göz kaslarını esnetir ve güçlendirir',
      ),
      ExerciseModel(
        id: 'child_5',
        title: 'Göz Asansörü',
        emoji: '🛗',
        description: 'Asansör yukarı çıkıyor. ⬆️\nŞimdi aşağı iniyor. ⬇️',
        type: ExerciseType.upDown,
        repetitions: 10,
        benefit: 'Dikey göz hareketlerini geliştirir',
      ),
      ExerciseModel(
        id: 'child_6',
        title: 'Yuvarlak Çiziyoruz',
        emoji: '⭕️',
        description: 'Gözlerinle kocaman bir daire çiz.\nŞimdi ters yöne!',
        type: ExerciseType.circle,
        repetitions: 10,
        benefit: 'Göz kaslarını gevşetir ve rahatlatır',
      ),
      ExerciseModel(
        id: 'child_7',
        title: 'Kaplumbağa Dinlenmesi',
        emoji: '🐢',
        description: 'Kaplumbağa gibi içine çekil.\nGözlerini kapat ve dinlen.',
        type: ExerciseType.rest,
        duration: 20,
        benefit: 'Gözleri dinlendirir ve yorgunluğu azaltır',
      ),
      ExerciseModel(
        id: 'child_8',
        title: 'Bulut Sayalım',
        emoji: '☁️',
        description: 'Tavana bak.\nBulutları say ve yavaş nefes al.',
        type: ExerciseType.cloud,
        duration: 30,
        benefit: 'Uzaktaki nesnelere odaklanmayı geliştirir',
      ),
      ExerciseModel(
        id: 'child_9',
        title: 'Hızlı & Yavaş',
        emoji: '⚡🐢',
        description: 'Beş kez hızlı kırp. ⚡\nBeş kez yavaş kırp. 🐢',
        type: ExerciseType.fastSlow,
        repetitions: 10,
        benefit: 'Göz kırpma refleksini düzenler',
      ),
      ExerciseModel(
        id: 'child_10',
        title: 'Mutlu Gözler',
        emoji: '😊',
        description: 'Gözlerini kapat.\nKocaman gülümse. 😄',
        type: ExerciseType.happy,
        duration: 10,
        benefit: 'Gözleri rahatlatır ve mutluluk hissi verir',
      ),
    ];
  }

  static List<ExerciseModel> getAdultExercises() {
    return [
      // 1. Bilinçli Göz Kırpma (5 tekrar)
      ExerciseModel(
        id: 'adult_1',
        title: 'Bilinçli Göz Kırpma',
        emoji: '👁️', // Liste sayfasında gösterilecek
        description: 'Yavaşça gözlerini kapat, bir saniye bekle, aç. Bunu beş kez tekrarla.',
        type: ExerciseType.blink,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Gözleri nemlendirir ve kuruluğu önler',
      ),
      // 2. Yukarı–Aşağı Tarama (eski 5)
      ExerciseModel(
        id: 'adult_5',
        title: 'Yukarı–Aşağı Tarama',
        emoji: '↕️', // Liste sayfasında gösterilecek
        description: 'Sadece gözlerinle yukarı ve aşağı bak. Bunu on kez tekrarla.',
        type: ExerciseType.upDown,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Göz kaslarını esnetir, dikey hareket kabiliyetini artırır',
      ),
      // 3. Sağ–Sol Tarama (eski 6)
      ExerciseModel(
        id: 'adult_6',
        title: 'Sağ–Sol Tarama',
        emoji: '↔️', // Liste sayfasında gösterilecek
        description: 'Başın sabit. Gözlerle sağa ve sola bak, bunu beşer kez tekrarla.',
        type: ExerciseType.leftRight,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Yatay göz hareketlerini geliştirir, okuma hızını artırabilir',
      ),
      // 4. Dairesel Göz Hareketi (eski 7)
      ExerciseModel(
        id: 'adult_7',
        title: 'Dairesel Göz Hareketi',
        emoji: '⭕', // Liste sayfasında gösterilecek
        description: 'Gözlerini kapat. Saat yönünde büyük bir daire çiz, bunu beş kere yap. Sonra ters yönde çiz.',
        type: ExerciseType.circle,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Göz kaslarını gevşetir, kan dolaşımını artırır',
      ),
      // 5. Hayali Sekiz (eski 8)
      ExerciseModel(
        id: 'adult_8',
        title: 'Hayali Sekiz',
        emoji: '∞', // Liste sayfasında gösterilecek
        description: 'Gözlerini kapat ve yavaşça sonsuzluk işareti çiz.',
        type: ExerciseType.figureEight,
        duration: 0, // Counter gösterilmeyecek
        benefit: 'Göz koordinasyonunu geliştirir, göz kaslarını güçlendirir',
      ),
      // 6. Yakın–Uzak Odak (eski 3)
      ExerciseModel(
        id: 'adult_3',
        title: 'Yakın–Uzak Odak',
        emoji: '👆', // Liste sayfasında gösterilecek
        description: 'On saniye parmağına bak. Şimdi yirmi saniye uzak bir noktaya bak. Bunu üç kez tekrarla.',
        type: ExerciseType.nearFar,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Odak kaslarını güçlendirir, yakın görme yorgunluğunu azaltır',
      ),
      // 7. Parmak Takibi (eski 4)
      ExerciseModel(
        id: 'adult_4',
        title: 'Parmak Takibi',
        emoji: '👆', // Liste sayfasında gösterilecek
        description: 'Kol mesafesinde tuttuğun işaret parmağını yavaşça burnuna değene kadar yaklaştır. Yavaşça uzaklaştır. Bunu on kez yap.',
        type: ExerciseType.fingerTracking,
        repetitions: 0, // Counter gösterilmeyecek
        benefit: 'Göz koordinasyonunu geliştirir, şaşılık farkındalığı sağlar',
      ),
      // 8. Yan Görüş Farkındalığı (eski 9)
      ExerciseModel(
        id: 'adult_9',
        title: 'Yan Görüş Farkındalığı',
        emoji: '👁️',
        description: 'Başını oynatma.\nGözlerinle kenarları fark et.',
        type: ExerciseType.peripheral,
        benefit: 'Periferik görüşü geliştirir, çevresel farkındalığı artırır',
      ),
      // 9. Palming (eski 10)
      ExerciseModel(
        id: 'adult_10',
        title: 'Palming',
        emoji: '🤲',
        description: 'Avuçlarını birbirine sürterek ısıt gözlerini bastırmadan kapat. Yaklaşık bir dakika yap.',
        type: ExerciseType.palming,
        duration: 0, // Counter gösterilmeyecek
        benefit: 'Gözleri derinlemesine dinlendirir, göz yorgunluğunu azaltır',
      ),
      // 10. Göz Kapalı Nefes (eski 11)
      ExerciseModel(
        id: 'adult_11',
        title: 'Göz Kapalı Nefes',
        emoji: '🫁',
        description: 'Gözleri kapat.\nÜç kere derin nefes al–ver.\nHiç bir şey düşünmemeye çalış.',
        type: ExerciseType.breathing,
        benefit: 'Zihni sakinleştirir, göz kaslarını gevşetir',
      ),
      // 11. Boyun–Göz Reset (eski 12)
      ExerciseModel(
        id: 'adult_12',
        title: 'Boyun–Göz Reset',
        emoji: '💆',
        description: 'Omuzlarını bırak.\nGözlerini kapat.\nİşaret parmaklarınla şakaklarına masaj yap.\nDinlendiğini hissedene kadar devam et.',
        type: ExerciseType.neckReset,
        benefit: 'Baş ağrısını hafifletir, boyun ve göz gerginliğini azaltır',
      ),
    ];
  }

  static List<ExerciseModel> getOfficeExercises() {
    return [
      ExerciseModel(
        id: 'office_1',
        title: '20-20-20 Kuralı',
        emoji: '⏰',
        description: 'Her 20 dakikada bir\n20 saniye uzağa bakın',
        type: ExerciseType.nearFar,
        duration: 20,
        benefit: 'Ekran yorgunluğunu önler, göz kaslarını gevşetir',
      ),
      ExerciseModel(
        id: 'office_2',
        title: 'Göz Kırpma',
        emoji: '👁️',
        description: 'Ekrana bakarken göz kırpma azalır\nBilinçli olarak kırpın',
        type: ExerciseType.blink,
        repetitions: 15,
        benefit: 'Göz kuruluğunu önler, gözleri nemlendirir',
      ),
      ExerciseModel(
        id: 'office_3',
        title: 'Göz Egzersizi',
        emoji: '∞',
        description: 'Ekrandan uzaklaşın\nGözlerinizle sekiz çizin',
        type: ExerciseType.figureEight,
        duration: 30,
        benefit: 'Göz koordinasyonunu geliştirir, yorgunluğu azaltır',
      ),
      ExerciseModel(
        id: 'office_4',
        title: 'Yatay Bakış',
        emoji: '↔️',
        description: 'Ekrandan gözlerinizi ayırın\nSağa ve sola bakın',
        type: ExerciseType.leftRight,
        repetitions: 10,
        benefit: 'Yatay göz hareketlerini geliştirir',
      ),
      ExerciseModel(
        id: 'office_5',
        title: 'Dikey Bakış',
        emoji: '↕️',
        description: 'Gözlerinizi yukarı ve aşağı hareket ettirin\nEkran yorgunluğunu azaltır',
        type: ExerciseType.upDown,
        repetitions: 10,
        benefit: 'Dikey göz hareketlerini geliştirir, ekran yorgunluğunu azaltır',
      ),
      ExerciseModel(
        id: 'office_6',
        title: 'Dairesel Hareket',
        emoji: '⭕',
        description: 'Gözlerinizle daire çizin\nKan dolaşımını artırır',
        type: ExerciseType.circle,
        repetitions: 10,
        benefit: 'Göz kaslarını gevşetir, kan dolaşımını artırır',
      ),
      ExerciseModel(
        id: 'office_7',
        title: 'Palming',
        emoji: '🤲',
        description: 'Gözlerinizi kapatın\nAvuçlarınızla örtün ve dinlenin',
        type: ExerciseType.rest,
        duration: 30,
        benefit: 'Gözleri derinlemesine dinlendirir',
      ),
      ExerciseModel(
        id: 'office_8',
        title: 'Uzak Bakış',
        emoji: '🌅',
        description: 'Pencereye bakın\nUzaktaki nesnelere odaklanın',
        type: ExerciseType.cloud,
        duration: 30,
        benefit: 'Uzaktaki nesnelere odaklanmayı geliştirir',
      ),
      ExerciseModel(
        id: 'office_9',
        title: 'Hızlı Kırpma',
        emoji: '⚡',
        description: 'Gözlerinizi nemlendirin\nHızlıca kırpın',
        type: ExerciseType.fastSlow,
        repetitions: 15,
        benefit: 'Gözleri hızlıca nemlendirir',
      ),
      ExerciseModel(
        id: 'office_10',
        title: 'Göz Masajı',
        emoji: '💆',
        description: 'Gözlerinizi kapatın\nRahatlayın ve nefes alın',
        type: ExerciseType.happy,
        duration: 15,
        benefit: 'Gözleri rahatlatır ve stresi azaltır',
      ),
    ];
  }
}
