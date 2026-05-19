import { useEffect, useState } from "react";
import { Menu, X } from "lucide-react";
import { BazzLogo } from "./BazzLogo";

interface NavbarProps {
  lang: "en" | "ar";
  onLangChange: (lang: "en" | "ar") => void;
}

const t = {
  en: { trackOrder: "Track Order", downloadApp: "Download App", help: "Help" },
  ar: { trackOrder: "تتبّع الطلب", downloadApp: "تحميل التطبيق", help: "المساعدة" },
};

export function Navbar({ lang, onLangChange }: NavbarProps) {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 60);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const labels = t[lang];

  const scrollTo = (id: string) => {
    document.getElementById(id)?.scrollIntoView({ behavior: "smooth" });
    setMenuOpen(false);
  };

  return (
    <nav
      className="fixed top-0 left-0 right-0 z-50 bg-white border-b border-[#E2E8F0] transition-shadow duration-300"
      style={{ boxShadow: scrolled ? "0 2px 12px rgba(0,0,0,0.08)" : "none" }}
      dir={lang === "ar" ? "rtl" : "ltr"}
    >
      <div className="max-w-[1200px] mx-auto px-4 h-16 flex items-center justify-between">
        {/* Logo */}
        <button onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })} className="flex-shrink-0">
          <BazzLogo variant="colored" size="md" />
        </button>

        {/* Desktop center links */}
        <div className="hidden md:flex items-center gap-8">
          <button
            onClick={() => scrollTo("hero")}
            className="text-[#1A202C] hover:text-[#1A3C6E] transition-colors"
            style={{ fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif", fontSize: "15px" }}
          >
            {labels.trackOrder}
          </button>
          <button
            onClick={() => scrollTo("download")}
            className="text-[#1A202C] hover:text-[#1A3C6E] transition-colors"
            style={{ fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif", fontSize: "15px" }}
          >
            {labels.downloadApp}
          </button>
          <button
            onClick={() => scrollTo("help")}
            className="text-[#1A202C] hover:text-[#1A3C6E] transition-colors"
            style={{ fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif", fontSize: "15px" }}
          >
            {labels.help}
          </button>
        </div>

        {/* Right side */}
        <div className="flex items-center gap-3">
          {/* Language toggle */}
          <div className="flex items-center bg-[#F5F7FA] rounded-full p-0.5 border border-[#E2E8F0]">
            <button
              onClick={() => onLangChange("en")}
              className={`px-3 py-1 rounded-full text-xs font-semibold transition-all ${
                lang === "en"
                  ? "bg-[#FFD700] text-[#1A3C6E]"
                  : "text-[#64748B] hover:text-[#1A3C6E]"
              }`}
              style={{ fontFamily: "Inter, sans-serif" }}
            >
              EN
            </button>
            <button
              onClick={() => onLangChange("ar")}
              className={`px-3 py-1 rounded-full text-xs font-semibold transition-all ${
                lang === "ar"
                  ? "bg-[#FFD700] text-[#1A3C6E]"
                  : "text-[#64748B] hover:text-[#1A3C6E]"
              }`}
              style={{ fontFamily: "Cairo, sans-serif" }}
            >
              عربي
            </button>
          </div>

          {/* Desktop CTA */}
          <button
            onClick={() => scrollTo("download")}
            className="hidden md:block bg-[#FFD700] text-[#1A3C6E] px-4 py-2 rounded-[10px] text-sm hover:bg-yellow-400 transition-colors"
            style={{
              fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif",
              fontWeight: 800,
              boxShadow: "0 6px 16px rgba(26,60,110,0.15)",
            }}
          >
            {labels.downloadApp}
          </button>

          {/* Mobile hamburger */}
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="md:hidden text-[#1A3C6E] p-1"
          >
            {menuOpen ? <X size={22} /> : <Menu size={22} />}
          </button>
        </div>
      </div>

      {/* Mobile menu */}
      {menuOpen && (
        <div className="md:hidden bg-white border-t border-[#E2E8F0] px-4 py-4 flex flex-col gap-4">
          {[
            { label: labels.trackOrder, id: "hero" },
            { label: labels.downloadApp, id: "download" },
            { label: labels.help, id: "help" },
          ].map((item) => (
            <button
              key={item.id}
              onClick={() => scrollTo(item.id)}
              className="text-left text-[#1A202C] py-2 border-b border-[#E2E8F0] last:border-0 hover:text-[#1A3C6E] transition-colors"
              style={{ fontFamily: lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif", fontSize: "15px" }}
            >
              {item.label}
            </button>
          ))}
        </div>
      )}
    </nav>
  );
}
