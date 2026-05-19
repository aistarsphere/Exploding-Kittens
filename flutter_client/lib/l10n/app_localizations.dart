import 'package:flutter/widgets.dart';
import '../models/card_model.dart';
import '../models/card_types.dart' as ct;
import 'app_strings.dart';
import 'strings_en.dart';
import 'strings_ar.dart';

class AppLocalizations {
  static AppStrings of(String lang) =>
      lang == 'ar' ? const StringsAr() : const StringsEn();

  static bool isRtl(String lang) => lang == 'ar';

  static TextDirection textDirection(String lang) =>
      lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  // Arabic card label/desc overrides (mirrors AR_CARD in i18n.ts)
  static const Map<CardType, ({String label, String desc})> _arCard = {
    CardType.EXPLODING_KITTEN: (label: 'قطة متفجرة',     desc: 'أظهرها فوراً. ستموت إن لم يكن لديك تفكيك.'),
    CardType.DEFUSE:           (label: 'تفكيك',           desc: 'ألغِ قطة متفجرة وأعد إدراجها في أي مكان.'),
    CardType.NOPE:             (label: 'لا',              desc: 'ألغِ أي حركة (عدا القطة والتفكيك). تُلعب خارج دورك.'),
    CardType.ATTACK:           (label: 'هجوم',            desc: 'أنهِ دورك. يأخذ اللاعب التالي دورين.'),
    CardType.SKIP:             (label: 'تخطي',            desc: 'أنهِ دورك دون سحب.'),
    CardType.FAVOR:            (label: 'طلب جميل',        desc: 'اختر لاعباً. سيعطيك بطاقة واحدة.'),
    CardType.SHUFFLE:          (label: 'خلط',             desc: 'اخلط مجموعة السحب.'),
    CardType.SEE_THE_FUTURE:   (label: 'رؤية المستقبل',   desc: 'اطلع على أعلى 3 بطاقات في مجموعة السحب.'),
    CardType.ALTER_THE_FUTURE: (label: 'تغيير المستقبل',  desc: 'اطلع على أعلى 3 بطاقات ورتّبها.'),
    CardType.DRAW_FROM_BOTTOM: (label: 'سحب من الأسفل',   desc: 'أنهِ دورك بسحب أسفل بطاقة.'),
    CardType.REVERSE:          (label: 'عكس',             desc: 'اعكس ترتيب الأدوار. ينهي دورك دون سحب.'),
    CardType.DOUBLE_SLAP:      (label: 'صفعة مزدوجة',     desc: 'أنهِ دورك. يأخذ اللاعب التالي دورين.'),
    CardType.TRIPLE_SLAP:      (label: 'صفعة ثلاثية',     desc: 'أنهِ دورك. يأخذ اللاعب التالي ثلاثة أدوار.'),
    CardType.CAT_TACO:         (label: 'قطة التاكو',      desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.'),
    CardType.CAT_BEARD:        (label: 'قطة الذقن',       desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.'),
    CardType.CAT_RAINBOW:      (label: 'قطة قوس قزح',    desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.'),
    CardType.CAT_POTATO:       (label: 'قطة البطاطا',     desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.'),
    CardType.CAT_MELON:        (label: 'قطة البطيخ',      desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.'),
    CardType.CAT_FERAL:        (label: 'القطة المتوحشة',  desc: 'قطة عشوائية — تحل محل أي قطة في الأزواج والثلاثيات.'),
  };

  static ({String label, String emoji, String desc}) getCardDisplay(CardType type, String lang) {
    final base = ct.meta[type]!;
    if (lang == 'ar') {
      final ar = _arCard[type];
      if (ar != null) return (label: ar.label, emoji: base.emoji, desc: ar.desc);
    }
    return (label: base.label, emoji: base.emoji, desc: base.desc);
  }
}
