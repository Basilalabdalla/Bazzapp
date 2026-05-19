import { MapPin, BarChart2, Bell, Globe2 } from "lucide-react";

interface WhyBazzProps {
  lang: "en" | "ar";
}

const features = [
  {
    icon: MapPin,
    color: "#1A3C6E",
    titleEn: "Real-Time Tracking",
    titleAr: "تتبّع في الوقت الفعلي",
    descEn: "Watch your orders move live on the map",
    descAr: "شاهد طلباتك تتحرك مباشرةً على الخريطة",
  },
  {
    icon: BarChart2,
    color: "#FFD700",
    titleEn: "Smart Analytics",
    titleAr: "تحليلات ذكية",
    descEn: "Orders, drivers, and area performance reports",
    descAr: "تقارير الطلبات والسائقين وأداء المناطق",
  },
  {
    icon: Bell,
    color: "#2ECC71",
    titleEn: "Push Notifications",
    titleAr: "إشعارات فورية",
    descEn: "Get notified the moment order status changes",
    descAr: "احصل على إشعار فور تغيّر حالة الطلب",
  },
  {
    icon: Globe2,
    color: "#E53935",
    titleEn: "Bilingual",
    titleAr: "ثنائي اللغة",
    descEn: "Full Arabic and English support throughout",
    descAr: "دعم كامل للعربية والإنجليزية في كل مكان",
  },
];

export function WhyBazz({ lang }: WhyBazzProps) {
  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  const isRtl = lang === "ar";

  return (
    <section id="why-bazz" className="py-16 md:py-24 bg-white" dir={isRtl ? "rtl" : "ltr"}>
      <div className="max-w-[1200px] mx-auto px-4">
        <h2
          className="text-center mb-12 text-[#1A3C6E]"
          style={{ fontFamily: ff, fontSize: "clamp(22px, 4vw, 36px)", fontWeight: 800 }}
        >
          {lang === "ar" ? "لماذا يختار التجار BazZ" : "Why merchants choose BazZ"}
        </h2>

        <div className="grid grid-cols-2 gap-4 md:gap-6">
          {features.map((f) => {
            const Icon = f.icon;
            return (
              <div
                key={f.titleEn}
                className="bg-white rounded-[14px] border border-[#E2E8F0] p-5 hover:border-[#1A3C6E] transition-all group"
                style={{ boxShadow: "0 2px 8px rgba(0,0,0,0.04)" }}
              >
                <div
                  className="w-11 h-11 rounded-full flex items-center justify-center mb-4"
                  style={{ background: `${f.color}20` }}
                >
                  <Icon size={20} style={{ color: f.color }} />
                </div>
                <h3
                  className="mb-2 text-[#1A3C6E]"
                  style={{ fontFamily: ff, fontSize: "15px", fontWeight: 700 }}
                >
                  {lang === "ar" ? f.titleAr : f.titleEn}
                </h3>
                <p style={{ fontFamily: ff, fontSize: "13px", color: "#64748B", lineHeight: 1.6 }}>
                  {lang === "ar" ? f.descAr : f.descEn}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
