interface HowItWorksProps {
  lang: "en" | "ar";
}

const steps = [
  {
    icon: "🏪",
    titleEn: "Merchant Places Order",
    titleAr: "التاجر يثبّت الطلب",
    descEn: "The store creates your delivery through the BazZ merchant app",
    descAr: "يقوم المتجر بإنشاء طلب توصيلك عبر تطبيق BazZ للتجار",
    num: "1",
  },
  {
    icon: "🚗",
    titleEn: "Driver Picks Up",
    titleAr: "السائق يستلم الطلب",
    descEn: "A verified BazZ driver collects your package and heads your way",
    descAr: "يستلم سائق BazZ المعتمد الطرد وينطلق نحوك",
    num: "2",
  },
  {
    icon: "📦",
    titleEn: "You Receive It",
    titleAr: "تستلم طلبك",
    descEn: "Track live and receive at your door. Fast, safe, reliable.",
    descAr: "تتابع مباشرةً وتستلم على بابك. سريع، آمن، موثوق.",
    num: "3",
  },
];

export function HowItWorks({ lang }: HowItWorksProps) {
  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  const isRtl = lang === "ar";

  return (
    <section id="how-it-works" className="py-16 md:py-24 bg-white" dir={isRtl ? "rtl" : "ltr"}>
      <div className="max-w-[1200px] mx-auto px-4">
        {/* Label pill */}
        <div className="flex justify-center mb-4">
          <span
            className="px-4 py-1.5 rounded-full text-[#FFD700] bg-[#1A3C6E]"
            style={{ fontFamily: ff, fontSize: "12px", fontWeight: 700 }}
          >
            {lang === "ar" ? "العملية البسيطة" : "Simple Process"}
          </span>
        </div>

        {/* Heading */}
        <h2
          className="text-center mb-12 text-[#1A3C6E]"
          style={{ fontFamily: ff, fontSize: "clamp(22px, 4vw, 36px)", fontWeight: 800 }}
        >
          {lang === "ar" ? "ثلاث خطوات حتى بابك" : "Three steps to your door"}
        </h2>

        {/* Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {steps.map((step) => (
            <div
              key={step.num}
              className="relative bg-white rounded-[14px] border border-[#E2E8F0] p-6 hover:border-[#1A3C6E] transition-all"
              style={{ boxShadow: "0 2px 8px rgba(0,0,0,0.04)" }}
            >
              {/* Step number badge */}
              <div
                className="absolute top-4 flex items-center justify-center w-6 h-6 rounded-full bg-[#1A3C6E] text-white"
                style={{
                  [isRtl ? "right" : "left"]: "16px",
                  fontFamily: "Inter, sans-serif",
                  fontSize: "12px",
                  fontWeight: 700,
                }}
              >
                {step.num}
              </div>

              {/* Icon circle */}
              <div className="w-14 h-14 rounded-full bg-[#FFD700] flex items-center justify-center text-2xl mt-6 mb-4">
                {step.icon}
              </div>

              <h3
                className="mb-2 text-[#1A3C6E]"
                style={{ fontFamily: ff, fontSize: "16px", fontWeight: 700 }}
              >
                {lang === "ar" ? step.titleAr : step.titleEn}
              </h3>
              <p style={{ fontFamily: ff, fontSize: "14px", color: "#64748B", lineHeight: 1.6 }}>
                {lang === "ar" ? step.descAr : step.descEn}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
