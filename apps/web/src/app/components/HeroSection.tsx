import { useState } from "react";
import { Package } from "lucide-react";
import { OrderStatusCard } from "./OrderStatusCard";

interface HeroSectionProps {
  lang: "en" | "ar";
}

type TrackState = "idle" | "loading" | "result" | "not_found";

export interface TrackResult {
  orderId: string;
  status: "PENDING" | "PROCESSING" | "IN_DELIVERY" | "DELIVERED" | "CANCELLED";
  area: string;
  areaAr?: string;
  governorate: string;
  governorateAr?: string;
  driverName?: string;
  driverNameAr?: string;
  createdAt: string;
  updatedAt: string;
  statusHistory: { status: string; note?: string; createdAt: string }[];
}

const API_BASE = import.meta.env.VITE_API_URL ?? "";

async function fetchOrder(ref: string): Promise<TrackResult | null> {
  try {
    const clean = ref.replace(/^#/, "");
    const res = await fetch(`${API_BASE}/orders/track/${encodeURIComponent(clean)}`);
    if (res.status === 404) return null;
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json() as Promise<TrackResult>;
  } catch {
    return null;
  }
}

export function HeroSection({ lang }: HeroSectionProps) {
  const [input, setInput] = useState("");
  const [trackState, setTrackState] = useState<TrackState>("idle");
  const [orderData, setOrderData] = useState<TrackResult | null>(null);

  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";
  const isRtl = lang === "ar";

  const handleTrack = async () => {
    const trimmed = input.trim().toUpperCase();
    if (!trimmed) return;
    setTrackState("loading");
    setOrderData(null);

    const result = await fetchOrder(trimmed);
    if (result) {
      setOrderData(result);
      setTrackState("result");
    } else {
      setTrackState("not_found");
    }
  };

  const handleReset = () => {
    setTrackState("idle");
    setInput("");
    setOrderData(null);
  };

  return (
    <section
      id="hero"
      className="relative pt-16 overflow-hidden"
      style={{
        background: "linear-gradient(135deg, #1A3C6E 0%, #0D2347 100%)",
        minHeight: "min(100vh, 700px)",
      }}
      dir={isRtl ? "rtl" : "ltr"}
    >
      {/* Diagonal line texture */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage:
            "repeating-linear-gradient(22deg, rgba(255,255,255,0.07) 0px, rgba(255,255,255,0.07) 1px, transparent 1px, transparent 22px)",
        }}
      />

      <div className="relative max-w-[1200px] mx-auto px-4 py-16 md:py-24 flex flex-col items-center text-center">
        {/* Badge */}
        <div
          className="inline-flex items-center gap-2 mb-6 px-4 py-2 rounded-full border border-white/30 bg-white/10 text-white"
          style={{ fontFamily: ff, fontSize: "12px", backdropFilter: "blur(4px)" }}
        >
          🚚{" "}
          {lang === "ar" ? "سريع · موثوق · شفاف" : "Fast · Reliable · Transparent"}
        </div>

        {/* H1 */}
        <h1
          className="text-white mb-3 max-w-[560px]"
          style={{
            fontFamily: ff,
            fontSize: "clamp(28px, 6vw, 48px)",
            fontWeight: 800,
            lineHeight: 1.15,
          }}
        >
          {lang === "ar" ? "تتبّع شحنتك" : "Track Your Delivery"}
        </h1>

        {/* Subtitle */}
        <p
          className="mb-8 max-w-[420px]"
          style={{ fontFamily: ff, fontSize: "16px", color: "rgba(255,255,255,0.7)", lineHeight: 1.6 }}
        >
          {lang === "ar"
            ? "أدخل رقم مرجع BazZ لمتابعة حالة طلبك في الوقت الفعلي"
            : "Enter your BazZ reference number to see real-time status"}
        </p>

        {/* Tracking input card */}
        <div
          className="w-full max-w-[520px] bg-white rounded-[16px] p-4 md:p-5"
          style={{ boxShadow: "0 8px 32px rgba(0,0,0,0.16)" }}
        >
          <div className={`flex flex-col md:flex-row gap-3 ${isRtl ? "md:flex-row-reverse" : ""}`}>
            <div className="relative flex-1">
              <Package
                size={18}
                className="absolute top-1/2 -translate-y-1/2 text-[#1A3C6E]"
                style={{ [isRtl ? "right" : "left"]: "12px" }}
              />
              <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleTrack()}
                placeholder={lang === "ar" ? "مثال: BZ-2401" : "e.g. BZ-2401"}
                className="w-full border border-[#E2E8F0] rounded-[10px] py-3 outline-none focus:border-[#1A3C6E] focus:ring-2 focus:ring-[#1A3C6E]/20 bg-[#F5F7FA] text-[#1A202C] transition-all"
                style={{
                  fontFamily: ff,
                  fontSize: "14px",
                  paddingLeft: isRtl ? "12px" : "40px",
                  paddingRight: isRtl ? "40px" : "12px",
                }}
                dir="ltr"
              />
            </div>
            <button
              onClick={handleTrack}
              disabled={trackState === "loading"}
              className="bg-[#FFD700] text-[#1A3C6E] px-6 py-3 rounded-[10px] hover:bg-yellow-400 disabled:opacity-70 transition-all active:scale-95"
              style={{
                fontFamily: ff,
                fontSize: "14px",
                fontWeight: 700,
                boxShadow: "0 6px 16px rgba(26,60,110,0.15)",
                whiteSpace: "nowrap",
              }}
            >
              {trackState === "loading"
                ? lang === "ar" ? "جارٍ البحث..." : "Searching..."
                : lang === "ar" ? "تتبّع الطلب" : "Track Order"}
            </button>
          </div>
          <div className="mt-3 text-center">
            <a
              href="#help"
              onClick={(e) => {
                e.preventDefault();
                document.getElementById("help")?.scrollIntoView({ behavior: "smooth" });
              }}
              className="text-[#64748B] hover:text-[#1A3C6E] transition-colors"
              style={{ fontFamily: ff, fontSize: "12px" }}
            >
              {lang === "ar" ? "لا يوجد رقم مرجع؟ تواصل معنا ←" : "No reference number? Contact us →"}
            </a>
          </div>
        </div>

        {/* Order status result */}
        {trackState !== "idle" && (
          <div className="w-full max-w-[520px] mt-6">
            <OrderStatusCard
              state={trackState === "loading" ? "loading" : trackState === "result" ? "result" : "not_found"}
              order={orderData ?? undefined}
              lang={lang}
              onTryAgain={handleReset}
            />
          </div>
        )}
      </div>
    </section>
  );
}
