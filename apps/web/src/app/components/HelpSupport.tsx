import { Phone } from "lucide-react";

interface HelpSupportProps {
  lang: "en" | "ar";
}

const socialLinks = [
  {
    name: "X",
    href: "#",
    color: "#000000",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-4.714-6.231-5.401 6.231H2.744l7.73-8.835L1.254 2.25H8.08l4.713 5.957 5.45-5.957zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
      </svg>
    ),
  },
  {
    name: "Instagram",
    href: "https://www.instagram.com/bazzmartapp",
    color: "#E1306C",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 1 0 0 12.324 6.162 6.162 0 0 0 0-12.324zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm6.406-11.845a1.44 1.44 0 1 0 0 2.881 1.44 1.44 0 0 0 0-2.881z" />
      </svg>
    ),
  },
  {
    name: "Facebook",
    href: "#",
    color: "#1877F2",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
        <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
      </svg>
    ),
  },
  {
    name: "WhatsApp",
    href: "#",
    color: "#25D366",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
        <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413z" />
      </svg>
    ),
  },
  {
    name: "Telegram",
    href: "#",
    color: "#229ED9",
    icon: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="white">
        <path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z" />
      </svg>
    ),
  },
];

export function HelpSupport({ lang }: HelpSupportProps) {
  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  const isRtl = lang === "ar";

  return (
    <section
      id="help"
      className="py-16 md:py-24 relative overflow-hidden"
      style={{ background: "linear-gradient(135deg, #1A3C6E 0%, #0D2347 100%)" }}
      dir={isRtl ? "rtl" : "ltr"}
    >
      {/* Texture */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage:
            "repeating-linear-gradient(22deg, rgba(255,255,255,0.04) 0px, rgba(255,255,255,0.04) 1px, transparent 1px, transparent 22px)",
        }}
      />

      <div className="relative max-w-[1200px] mx-auto px-4">
        <h2
          className="text-center text-white mb-10"
          style={{ fontFamily: ff, fontSize: "clamp(22px, 4vw, 36px)", fontWeight: 800 }}
        >
          {lang === "ar" ? "كيف يمكننا مساعدتك؟" : "How can we help?"}
        </h2>

        {/* Two cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-[640px] mx-auto mb-10">
          {/* Contact Us */}
          <div
            className="rounded-[16px] p-6 flex flex-col gap-3"
            style={{ background: "rgba(255,255,255,0.12)", backdropFilter: "blur(8px)", border: "1px solid rgba(255,255,255,0.15)" }}
          >
            <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ background: "rgba(255,255,255,0.15)" }}>
              <Phone size={22} className="text-white" />
            </div>
            <div>
              <h3 className="text-white" style={{ fontFamily: ff, fontSize: "18px", fontWeight: 800 }}>
                {lang === "ar" ? "تواصل معنا" : "Contact Us"}
              </h3>
              <p style={{ fontFamily: ff, fontSize: "13px", color: "rgba(255,255,255,0.7)" }}>
                {lang === "ar" ? "فريقنا متصل الآن" : "Our team is online"}
              </p>
            </div>
            <a
              href="tel:+962000000000"
              className="inline-block bg-white text-[#1A3C6E] px-4 py-2 rounded-[10px] text-sm text-center hover:bg-gray-100 transition-colors mt-1"
              style={{ fontFamily: ff, fontWeight: 700 }}
            >
              {lang === "ar" ? "اتصل بنا" : "Call Us"}
            </a>
          </div>

          {/* WhatsApp */}
          <div
            className="rounded-[16px] p-6 flex flex-col gap-3"
            style={{ background: "#E8F8EF" }}
          >
            <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ background: "#25D36620" }}>
              <svg width="24" height="24" viewBox="0 0 24 24" fill="#25D366">
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 0 1-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 0 1-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 0 1 2.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0 0 12.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 0 0 5.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 0 0-3.48-8.413z" />
              </svg>
            </div>
            <div>
              <h3 style={{ fontFamily: ff, fontSize: "18px", fontWeight: 800, color: "#1B6B3A" }}>
                {lang === "ar" ? "واتساب" : "WhatsApp Us"}
              </h3>
              <p style={{ fontFamily: ff, fontSize: "13px", color: "#4A9065" }}>
                {lang === "ar" ? "وكلاؤنا جاهزون للمساعدة" : "Our agents are ready to assist"}
              </p>
            </div>
            <a
              href="https://wa.me/962000000000"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-block px-4 py-2 rounded-[10px] text-sm text-center hover:opacity-90 transition-opacity mt-1"
              style={{ fontFamily: ff, fontWeight: 700, background: "#25D366", color: "white" }}
            >
              {lang === "ar" ? "أرسل رسالة" : "Send Message"}
            </a>
          </div>
        </div>

        {/* Social row */}
        <div className="flex flex-col items-center gap-4">
          <span className="text-white" style={{ fontFamily: ff, fontSize: "14px", fontWeight: 700 }}>
            {lang === "ar" ? "تابعنا" : "Follow Us"}
          </span>
          <div className="flex items-center gap-3 flex-wrap justify-center">
            {socialLinks.map((s) => (
              <a
                key={s.name}
                href={s.href}
                target="_blank"
                rel="noopener noreferrer"
                className="w-11 h-11 rounded-[12px] flex items-center justify-center hover:opacity-80 transition-opacity"
                style={{ background: s.color }}
                title={s.name}
              >
                {s.icon}
              </a>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
