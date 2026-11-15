// बारह ज्योतिर्लिंग की जानकारी।
// यहाँ सिर्फ़ वही बातें हैं जो आम तौर पर मानी जाती हैं।
// आधिकारिक वेबसाइट का लिंग (link) सिर्फ़ तभी है जब वह जाँचकर पक्का हो गया।

class Jyotirlinga {
  final String id;
  final String name;
  final String place;
  final String info;
  final String importance;
  final String? link;
  final String linkLabel;
  final String ytQuery;
  const Jyotirlinga({
    required this.id,
    required this.name,
    required this.place,
    required this.info,
    required this.importance,
    required this.ytQuery,
    this.link,
    this.linkLabel = '',
  });
}

const List<Jyotirlinga> jyotirlingas = [
  Jyotirlinga(
    id: 'somnath',
    name: 'सोमनाथ',
    place: 'प्रभास पाटन, वेरावल, गुजरात',
    info: 'अरब सागर के किनारे बना यह मंदिर बारह ज्योतिर्लिंगों में पहला माना जाता है।',
    importance:
        'कथा के अनुसार चंद्र देव (सोम) ने यहाँ शिव जी की आराधना करके शाप से मुक्ति पाई, '
        'इसीलिए यह स्थान "सोमनाथ" कहलाया। मंदिर कई बार टूटा और फिर बनाया गया। '
        'वर्तमान मंदिर 1951 में प्रतिष्ठित हुआ।',
    link: 'https://somnath.org',
    linkLabel: 'श्री सोमनाथ ट्रस्ट की वेबसाइट',
    ytQuery: 'Somnath Temple live darshan',
  ),
  Jyotirlinga(
    id: 'mallikarjuna',
    name: 'मल्लिकार्जुन',
    place: 'श्रीशैलम, आंध्र प्रदेश',
    info: 'कृष्णा नदी के पास श्रीशैलम पर्वत पर स्थित है। यहाँ शिव जी मल्लिकार्जुन और '
        'माता पार्वती भ्रमराम्बा रूप में पूजी जाती हैं।',
    importance:
        'यह स्थान ज्योतिर्लिंग भी है और शक्तिपीठ भी माना जाता है, इसलिए इसका महत्व विशेष है।',
    ytQuery: 'Srisailam Mallikarjuna Swamy live darshan',
  ),
  Jyotirlinga(
    id: 'mahakaleshwar',
    name: 'महाकालेश्वर',
    place: 'उज्जैन, मध्य प्रदेश',
    info: 'क्षिप्रा नदी के तट पर स्थित है। दक्षिणमुखी होना इस ज्योतिर्लिंग की खास पहचान मानी जाती है।',
    importance:
        'उज्जैन को प्राचीन काल से पवित्र नगरी माना गया है। यहाँ की सुबह की भस्म आरती बहुत प्रसिद्ध है। '
        'हर 12 साल में उज्जैन में सिंहस्थ कुंभ भी होता है।',
    ytQuery: 'Mahakaleshwar Ujjain live darshan',
  ),
  Jyotirlinga(
    id: 'omkareshwar',
    name: 'ओंकारेश्वर',
    place: 'खंडवा जिला, मध्य प्रदेश',
    info: 'नर्मदा नदी के बीच मांधाता (शिवपुरी) द्वीप पर स्थित है। कहा जाता है कि इस द्वीप का आकार ॐ जैसा है।',
    importance:
        'यहाँ ओंकारेश्वर और ममलेश्वर, दोनों रूपों की पूजा की मान्यता है। '
        'नर्मदा के घाट पर स्नान और दर्शन का विशेष महत्व बताया जाता है।',
    link: 'https://shriomkareshwar.org',
    linkLabel: 'श्री ओंकारेश्वर ट्रस्ट की वेबसाइट',
    ytQuery: 'Omkareshwar Jyotirlinga live darshan',
  ),
  Jyotirlinga(
    id: 'kedarnath',
    name: 'केदारनाथ',
    place: 'रुद्रप्रयाग, उत्तराखंड',
    info: 'हिमालय में मंदाकिनी नदी के पास, लगभग 3,583 मीटर की ऊँचाई पर स्थित है।',
    importance:
        'यह छोटा चार धाम और पंच केदार में गिना जाता है। सर्दियों में बर्फ़ के कारण मंदिर के कपाट बंद रहते हैं, '
        'इसलिए दर्शन साल के लगभग छह महीने ही हो पाते हैं।',
    link: 'https://badrinath-kedarnath.gov.in',
    linkLabel: 'बद्रीनाथ-केदारनाथ मंदिर समिति की वेबसाइट',
    ytQuery: 'Kedarnath live darshan',
  ),
  Jyotirlinga(
    id: 'bhimashankar',
    name: 'भीमाशंकर',
    place: 'पुणे जिला, महाराष्ट्र',
    info: 'सह्याद्रि पर्वत के घने जंगल में स्थित है। भीमा नदी का उद्गम यहीं से माना जाता है।',
    importance:
        'कथा के अनुसार शिव जी ने यहाँ भीम नाम के असुर का अंत किया था। '
        'आसपास का क्षेत्र वन्यजीव अभयारण्य भी है।',
    link: 'https://shreebhimashankar.com/en/',
    linkLabel: 'श्री क्षेत्र भीमाशंकर ट्रस्ट की वेबसाइट',
    ytQuery: 'Bhimashankar Temple live darshan',
  ),
  Jyotirlinga(
    id: 'kashi',
    name: 'काशी विश्वनाथ',
    place: 'वाराणसी, उत्तर प्रदेश',
    info: 'गंगा नदी के तट पर स्थित है। काशी को सबसे प्राचीन जीवित नगरों में गिना जाता है।',
    importance:
        'मान्यता है कि काशी शिव जी को अत्यंत प्रिय है और यहाँ दर्शन तथा गंगा स्नान का विशेष महत्व है। '
        'श्री काशी विश्वनाथ धाम का नया परिसर 2021 में खोला गया।',
    ytQuery: 'Kashi Vishwanath live darshan',
  ),
  Jyotirlinga(
    id: 'trimbakeshwar',
    name: 'त्र्यंबकेश्वर',
    place: 'नासिक जिला, महाराष्ट्र',
    info: 'ब्रह्मगिरि पर्वत के पास स्थित है, जहाँ से गोदावरी नदी का उद्गम माना जाता है।',
    importance:
        'यहाँ के लिंग में तीन छोटे लिंग हैं, जिन्हें ब्रह्मा, विष्णु और महेश का रूप माना जाता है।',
    link: 'https://trimbakeshwartrust.com',
    linkLabel: 'श्री त्र्यंबकेश्वर देवस्थान ट्रस्ट की वेबसाइट',
    ytQuery: 'Trimbakeshwar live darshan',
  ),
  Jyotirlinga(
    id: 'vaidyanath',
    name: 'वैद्यनाथ',
    place: 'देवघर, झारखंड',
    info: 'देवघर का बैद्यनाथ धाम सबसे ज़्यादा माना जाने वाला वैद्यनाथ ज्योतिर्लिंग है। '
        'यह शक्तिपीठ के रूप में भी प्रसिद्ध है।',
    importance:
        'श्रावण मास में लाखों कांवड़िये सुल्तानगंज से गंगाजल लेकर यहाँ जल चढ़ाने आते हैं। '
        'कुछ परंपराएँ परली (महाराष्ट्र) और बैजनाथ (हिमाचल प्रदेश) को भी वैद्यनाथ मानती हैं।',
    link: 'https://deoghar.nic.in/tourist-place/baidyanath-temple/',
    linkLabel: 'देवघर जिला प्रशासन का पेज',
    ytQuery: 'Baidyanath Dham Deoghar live darshan',
  ),
  Jyotirlinga(
    id: 'nageshwar',
    name: 'नागेश्वर',
    place: 'द्वारका के पास, गुजरात',
    info: 'गुजरात में द्वारका के निकट दारुकावन क्षेत्र में माना जाता है। नाम का अर्थ है नागों के ईश्वर।',
    importance:
        'इसे विष और विषैले जीवों से रक्षा करने वाले शिव रूप से जोड़ा जाता है। '
        'नागेश्वर के स्थान को लेकर औंढा नागनाथ (महाराष्ट्र) और जागेश्वर (उत्तराखंड) की भी मान्यताएँ हैं।',
    link: 'https://gujarattourism.com/saurashtra/devbhoomi-dwarka/nageshwar-jyotirlinga.html',
    linkLabel: 'गुजरात पर्यटन का पेज',
    ytQuery: 'Nageshwar Jyotirlinga Dwarka darshan',
  ),
  Jyotirlinga(
    id: 'rameshwaram',
    name: 'रामेश्वरम',
    place: 'रामनाथपुरम जिला, तमिलनाडु',
    info: 'पंबन द्वीप पर समुद्र के किनारे स्थित है। यह चार धामों में से एक माना जाता है।',
    importance:
        'मान्यता है कि श्रीराम ने यहाँ शिव जी की स्थापना करके पूजा की थी। '
        'मंदिर का लंबा गलियारा (कॉरिडोर) और 22 तीर्थ कुंड प्रसिद्ध हैं।',
    ytQuery: 'Rameshwaram Ramanathaswamy temple live darshan',
  ),
  Jyotirlinga(
    id: 'grishneshwar',
    name: 'घृष्णेश्वर',
    place: 'वेरुळ (एलोरा) के पास, संभाजीनगर (पहले औरंगाबाद), महाराष्ट्र',
    info: 'एलोरा की गुफाओं के निकट स्थित है और बारह ज्योतिर्लिंगों की सूची में अंतिम गिना जाता है।',
    importance:
        'कथा के अनुसार घुश्मा नाम की शिवभक्त स्त्री की भक्ति से प्रसन्न होकर शिव जी यहाँ प्रकट हुए। '
        'वर्तमान मंदिर का जीर्णोद्धार अहिल्याबाई होल्कर ने कराया था।',
    link:
        'https://www.incredibleindia.gov.in/en/maharashtra/chhatrapati-sambhaji-nagar/grishneshwar-temple',
    linkLabel: 'भारत सरकार (Incredible India) का पेज',
    ytQuery: 'Grishneshwar Jyotirlinga darshan',
  ),
];

/// Google Maps में खोजने के लिए हर ज्योतिर्लिंग का पता।
const Map<String, String> jyotirMapQuery = {
  'somnath': 'Somnath Temple, Veraval, Gujarat',
  'mallikarjuna': 'Mallikarjuna Swamy Temple, Srisailam',
  'mahakaleshwar': 'Mahakaleshwar Jyotirlinga Temple, Ujjain',
  'omkareshwar': 'Omkareshwar Temple, Khandwa, Madhya Pradesh',
  'kedarnath': 'Kedarnath Temple, Uttarakhand',
  'bhimashankar': 'Bhimashankar Temple, Pune, Maharashtra',
  'kashi': 'Kashi Vishwanath Temple, Varanasi',
  'trimbakeshwar': 'Trimbakeshwar Shiva Temple, Nashik',
  'vaidyanath': 'Baidyanath Temple, Deoghar, Jharkhand',
  'nageshwar': 'Nageshwar Jyotirlinga Temple, Dwarka, Gujarat',
  'rameshwaram': 'Ramanathaswamy Temple, Rameswaram',
  'grishneshwar': 'Grishneshwar Temple, Ellora, Maharashtra',
};
