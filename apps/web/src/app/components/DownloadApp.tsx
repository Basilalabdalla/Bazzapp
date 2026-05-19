import { CheckCircle2, Smartphone } from "lucide-react";

interface DownloadAppProps {
  lang: "en" | "ar";
}

const features = [
  { en: "Live order tracking & status updates", ar: "تتبّع الطلبات مباشرةً وتحديثات الحالة" },
  { en: "Instant push notifications", ar: "إشعارات فورية" },
  { en: "Reports & analytics dashboard", ar: "لوحة تقارير وتحليلات" },
];

export function DownloadApp({ lang }: DownloadAppProps) {
  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  const isRtl = lang === "ar";

  return (
    <section id="download" className="py-16 md:py-24 bg-[#F5F7FA]" dir={isRtl ? "rtl" : "ltr"}>
      <div className="max-w-[1200px] mx-auto px-4">
        <div className="flex flex-col md:flex-row gap-12 items-center">
          {/* Left: Text */}
          <div className="flex-1 flex flex-col items-start">
            {/* Label pill */}
            <span
              className="px-4 py-1.5 rounded-full text-[#FFD700] bg-[#1A3C6E] mb-5"
              style={{ fontFamily: ff, fontSize: "12px", fontWeight: 700 }}
            >
              {lang === "ar" ? "لأصحاب الأعمال" : "For Business Owners"}
            </span>

            <h2
              className="text-[#1A3C6E] mb-4"
              style={{ fontFamily: ff, fontSize: "clamp(22px, 4vw, 36px)", fontWeight: 800, lineHeight: 1.2 }}
            >
              {lang === "ar" ? "أدر توصيلاتك من هاتفك" : "Run your deliveries from your phone"}
            </h2>

            <p
              className="mb-6 max-w-[440px]"
              style={{ fontFamily: ff, fontSize: "16px", color: "#64748B", lineHeight: 1.7 }}
            >
              {lang === "ar"
                ? "تطبيق BazZ للتجار يمنحك إدارة الطلبات في الوقت الفعلي، التتبع الحي، التحليلات، والإشعارات الفورية."
                : "The BazZ merchant app gives you real-time order management, live tracking, analytics, and instant notifications."}
            </p>

            {/* Feature list */}
            <ul className="space-y-3 mb-8">
              {features.map((f, i) => (
                <li key={i} className="flex items-center gap-3">
                  <CheckCircle2 size={18} className="text-[#2ECC71] flex-shrink-0" />
                  <span style={{ fontFamily: ff, fontSize: "15px", color: "#1A202C" }}>
                    {lang === "ar" ? f.ar : f.en}
                  </span>
                </li>
              ))}
            </ul>

            {/* App store buttons */}
            <div className={`flex gap-3 flex-wrap ${isRtl ? "flex-row-reverse" : ""}`}>
              {/* App Store */}
              <a
                href="#"
                onClick={(e) => e.preventDefault()}
                className="flex items-center gap-3 bg-[#000000] text-white px-5 py-3 rounded-[12px] hover:bg-gray-800 transition-colors h-12"
                style={{ boxShadow: "0 2px 8px rgba(0,0,0,0.15)" }}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98l-.09.06c-.22.14-2.2 1.28-2.18 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div>
                  <div style={{ fontFamily: "Inter, sans-serif", fontSize: "10px", opacity: 0.8 }}>Download on the</div>
                  <div style={{ fontFamily: "Inter, sans-serif", fontSize: "14px", fontWeight: 700 }}>App Store</div>
                </div>
              </a>

              {/* Google Play */}
              <a
                href="#"
                onClick={(e) => e.preventDefault()}
                className="flex items-center gap-3 bg-[#000000] text-white px-5 py-3 rounded-[12px] hover:bg-gray-800 transition-colors h-12"
                style={{ boxShadow: "0 2px 8px rgba(0,0,0,0.15)" }}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
                  <path d="M3.18 23.76a2.5 2.5 0 0 1-1.18-2.2V2.44A2.5 2.5 0 0 1 3.18.24l12.5 11.76-12.5 11.76zm1.48-1.96 10.52-9.88L4.66 2.04v19.76zm14.06-4.44-3.4-1.96-2.12 2 2.12 2 3.4-1.96a.74.74 0 0 0 0-1.08zM5.14 1.24l10.7 6.16-2.28 2.14L5.14 1.24zm0 21.52 8.42-8.3 2.28 2.14L5.14 22.76z" />
                </svg>
                <div>
                  <div style={{ fontFamily: "Inter, sans-serif", fontSize: "10px", opacity: 0.8 }}>Get it on</div>
                  <div style={{ fontFamily: "Inter, sans-serif", fontSize: "14px", fontWeight: 700 }}>Google Play</div>
                </div>
              </a>
            </div>
          </div>

          {/* Right: Phone mockup */}
          <div className="flex-1 flex justify-center">
            <div
              className="relative"
              style={{ width: "240px", height: "480px" }}
            >
              {/* Phone frame */}
              <div
                className="w-full h-full rounded-[36px] bg-[#1A3C6E] border-4 border-[#0D2347] flex flex-col overflow-hidden"
                style={{ boxShadow: "0 16px 48px rgba(26,60,110,0.3)" }}
              >
                {/* Status bar */}
                <div className="h-8 bg-[#0D2347] flex items-center justify-center">
                  <div className="w-16 h-1.5 bg-[#1A3C6E] rounded-full" />
                </div>

                {/* App header */}
                <div className="bg-[#1A3C6E] px-4 py-3">
                  <div className="text-white font-bold text-lg" style={{ fontFamily: "Inter, sans-serif" }}>
                    Baz<span className="text-[#FFD700]">Z</span>
                  </div>
                  <div className="text-white/60 text-xs mt-0.5" style={{ fontFamily: "Inter, sans-serif" }}>
                    Good morning 👋
                  </div>
                  {/* Stats row */}
                  <div className="grid grid-cols-4 gap-1 mt-3">
                    {[
                      { label: "Total", value: "248", color: "text-white" },
                      { label: "Done", value: "180", color: "text-[#2ECC71]" },
                      { label: "Cancel", value: "12", color: "text-[#E53935]" },
                      { label: "Rate", value: "94%", color: "text-[#FFD700]" },
                    ].map((s) => (
                      <div key={s.label} className="text-center">
                        <div className={`text-sm font-bold ${s.color}`} style={{ fontFamily: "Inter, sans-serif" }}>{s.value}</div>
                        <div className="text-white/50 text-[9px]" style={{ fontFamily: "Inter, sans-serif" }}>{s.label}</div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Order list */}
                <div className="flex-1 bg-[#F5F7FA] px-3 py-3 space-y-2 overflow-hidden">
                  {[
                    { id: "BZ-2401", name: "Ahmad Hassan", status: "Delivered", statusColor: "text-[#2ECC71]" },
                    { id: "BZ-2399", name: "Sara Mahmoud", status: "In Delivery", statusColor: "text-[#1A3C6E]" },
                    { id: "BZ-2398", name: "Omar Khalid", status: "Processing", statusColor: "text-[#64748B]" },
                  ].map((order) => (
                    <div
                      key={order.id}
                      className="bg-white rounded-[10px] p-2.5"
                      style={{ borderLeft: "3px solid #FFD700" }}
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="text-[#1A3C6E] text-xs font-bold" style={{ fontFamily: "Inter, sans-serif" }}>{order.id}</div>
                          <div className="text-[#64748B] text-[10px] mt-0.5" style={{ fontFamily: "Inter, sans-serif" }}>{order.name}</div>
                        </div>
                        <span className={`text-[9px] font-semibold ${order.statusColor}`} style={{ fontFamily: "Inter, sans-serif" }}>
                          {order.status}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>

                {/* FAB */}
                <div className="absolute bottom-12 right-4 w-10 h-10 rounded-full bg-[#FFD700] flex items-center justify-center shadow-lg">
                  <span className="text-[#1A3C6E] text-xl font-bold">+</span>
                </div>

                {/* Bottom bar */}
                <div className="h-10 bg-white border-t border-[#E2E8F0] flex items-center justify-around px-4">
                  <Smartphone size={16} className="text-[#1A3C6E]" />
                  <div className="w-1 h-1 rounded-full bg-[#94A3B8]" />
                  <div className="w-1 h-1 rounded-full bg-[#94A3B8]" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
