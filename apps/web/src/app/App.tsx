import { useState, useEffect } from "react";
import { Navbar } from "./components/Navbar";
import { HeroSection } from "./components/HeroSection";
import { HowItWorks } from "./components/HowItWorks";
import { DownloadApp } from "./components/DownloadApp";
import { WhyBazz } from "./components/WhyBazz";
import { HelpSupport } from "./components/HelpSupport";
import { Footer } from "./components/Footer";

type Lang = "en" | "ar";

export default function App() {
  const [lang, setLang] = useState<Lang>("en");

  useEffect(() => {
    document.documentElement.dir = lang === "ar" ? "rtl" : "ltr";
    document.documentElement.lang = lang;
    document.documentElement.style.fontFamily =
      lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  }, [lang]);

  return (
    <div
      className="min-h-screen bg-[#F5F7FA]"
      style={{
        fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif",
      }}
    >
      <Navbar lang={lang} onLangChange={setLang} />

      <main>
        <HeroSection lang={lang} />
        <HowItWorks lang={lang} />
        <DownloadApp lang={lang} />
        <WhyBazz lang={lang} />
        <HelpSupport lang={lang} />
      </main>

      <Footer lang={lang} onLangChange={setLang} />
    </div>
  );
}
