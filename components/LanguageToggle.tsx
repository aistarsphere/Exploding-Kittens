'use client';

import { useLang } from '@/lib/LanguageContext';
import styles from './LanguageToggle.module.css';

export default function LanguageToggle() {
  const { lang, setLang } = useLang();
  return (
    <button
      className={styles.toggle}
      onClick={() => setLang(lang === 'en' ? 'ar' : 'en')}
      title={lang === 'en' ? 'Switch to Arabic' : 'Switch to English'}
    >
      {lang === 'en' ? 'عربي' : 'EN'}
    </button>
  );
}
