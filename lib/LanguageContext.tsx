'use client';

import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';
import { type Lang, type Translations, translations } from './i18n';

interface LangCtx {
  lang: Lang;
  setLang: (l: Lang) => void;
  tr: Translations;
}

const Ctx = createContext<LangCtx>({ lang: 'en', setLang: () => {}, tr: translations.en });

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>('en');

  useEffect(() => {
    const saved = localStorage.getItem('ek-lang') as Lang | null;
    if (saved === 'ar' || saved === 'en') setLangState(saved);
  }, []);

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  }, [lang]);

  function setLang(l: Lang) {
    setLangState(l);
    localStorage.setItem('ek-lang', l);
  }

  return (
    <Ctx.Provider value={{ lang, setLang, tr: translations[lang] }}>
      {children}
    </Ctx.Provider>
  );
}

export function useLang() {
  return useContext(Ctx);
}
