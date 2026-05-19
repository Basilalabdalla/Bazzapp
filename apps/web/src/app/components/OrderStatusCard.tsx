import { MapPin, Clock, Truck, CheckCircle2, Circle, XCircle } from "lucide-react";
import type { TrackResult } from "./HeroSection";

interface OrderStatusCardProps {
  state: "loading" | "result" | "not_found";
  order?: TrackResult;
  lang: "en" | "ar";
  onTryAgain?: () => void;
}

type OrderStatus = TrackResult["status"];

const statusConfig: Record<OrderStatus, { label: string; labelAr: string; bg: string; text: string; border: string }> = {
  PENDING:     { label: "Pending",     labelAr: "في الانتظار",   bg: "#FFF3CD", text: "#856404", border: "#F59E0B" },
  PROCESSING:  { label: "Processing",  labelAr: "قيد المعالجة", bg: "#CCE5FF", text: "#004085", border: "#1A3C6E" },
  IN_DELIVERY: { label: "In Delivery", labelAr: "في الطريق",    bg: "#FFD700", text: "#1A3C6E", border: "#FFD700" },
  DELIVERED:   { label: "Delivered",   labelAr: "تم التسليم",   bg: "#D4EDDA", text: "#155724", border: "#2ECC71" },
  CANCELLED:   { label: "Cancelled",   labelAr: "ملغى",         bg: "#F8D7DA", text: "#721C24", border: "#E53935" },
};

const steps = [
  { key: "PENDING",     en: "Placed",      ar: "تم الطلب" },
  { key: "PROCESSING",  en: "Processing",  ar: "معالجة"   },
  { key: "IN_DELIVERY", en: "In Delivery", ar: "في الطريق" },
  { key: "DELIVERED",   en: "Delivered",   ar: "تم التسليم" },
];

function getStepIndex(status: OrderStatus): number {
  const map: Record<OrderStatus, number> = {
    PENDING: 0, PROCESSING: 1, IN_DELIVERY: 2, DELIVERED: 3, CANCELLED: -1,
  };
  return map[status];
}

function formatDate(iso: string, lang: "en" | "ar"): string {
  return new Date(iso).toLocaleString(lang === "ar" ? "ar-JO" : "en-GB", {
    day: "numeric", month: "short", year: "numeric",
    hour: "2-digit", minute: "2-digit",
  });
}

function SkeletonShimmer() {
  return (
    <div className="bg-white rounded-[16px] p-5 shadow-[0_2px_8px_rgba(0,0,0,0.04)] overflow-hidden">
      <div className="animate-pulse space-y-4">
        <div className="flex justify-between items-center">
          <div className="h-5 bg-gray-200 rounded w-28" />
          <div className="h-6 bg-gray-200 rounded-full w-20" />
        </div>
        <div className="h-4 bg-gray-200 rounded w-40" />
        <div className="h-3 bg-gray-200 rounded w-32" />
        <div className="h-4 bg-gray-200 rounded w-36" />
        <div className="flex justify-between pt-2">
          {[0, 1, 2, 3].map((i) => (
            <div key={i} className="flex flex-col items-center gap-1">
              <div className="w-6 h-6 rounded-full bg-gray-200" />
              <div className="h-2 bg-gray-200 rounded w-10" />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export function OrderStatusCard({ state, order, lang, onTryAgain }: OrderStatusCardProps) {
  const ff = lang === "ar" ? "Cairo, sans-serif" : "Inter, sans-serif";

  if (state === "loading") return <SkeletonShimmer />;

  if (state === "not_found") {
    return (
      <div className="bg-white rounded-[16px] p-6 shadow-[0_2px_8px_rgba(0,0,0,0.04)] text-center space-y-4">
        <XCircle className="mx-auto text-[#E53935]" size={48} />
        <p className="text-[#1A202C]" style={{ fontFamily: ff, fontSize: "15px", fontWeight: 600 }}>
          {lang === "ar" ? "لم يتم العثور على الطلب" : "Order not found"}
        </p>
        <p className="text-[#64748B]" style={{ fontFamily: ff, fontSize: "13px" }}>
          {lang === "ar"
            ? "يرجى التحقق من رقم المرجع والمحاولة مجدداً"
            : "Please check your reference number and try again."}
        </p>
        <button
          onClick={onTryAgain}
          className="bg-[#1A3C6E] text-white px-6 py-2 rounded-[10px] hover:bg-[#0D2347] transition-colors"
          style={{ fontFamily: ff, fontSize: "14px", fontWeight: 700 }}
        >
          {lang === "ar" ? "حاول مجدداً" : "Try Again"}
        </button>
      </div>
    );
  }

  if (!order) return null;

  const cfg = statusConfig[order.status];
  const stepIdx = getStepIndex(order.status);
  const displayArea = lang === "ar" ? (order.areaAr ?? order.area) : order.area;
  const displayGov  = lang === "ar" ? (order.governorateAr ?? order.governorate) : order.governorate;
  const displayDriver = lang === "ar" ? (order.driverNameAr ?? order.driverName) : order.driverName;

  return (
    <div
      className="bg-white rounded-[16px] p-5 shadow-[0_2px_8px_rgba(0,0,0,0.04)]"
      style={{ borderLeft: `4px solid ${cfg.border}` }}
      dir={lang === "ar" ? "rtl" : "ltr"}
    >
      {/* Row 1: orderId + status chip */}
      <div className="flex items-center justify-between mb-3">
        <span style={{ fontFamily: ff, fontSize: "16px", fontWeight: 700, color: "#1A3C6E" }}>
          {order.orderId}
        </span>
        <span
          className="px-3 py-1 rounded-full text-xs"
          style={{ fontFamily: ff, fontWeight: 700, background: cfg.bg, color: cfg.text }}
        >
          {lang === "ar" ? cfg.labelAr : cfg.label}
        </span>
      </div>

      {/* Row 2: Area */}
      <div className="flex items-center gap-2 mb-2">
        <MapPin size={14} className="text-[#64748B] flex-shrink-0" />
        <span style={{ fontFamily: ff, fontSize: "14px", color: "#64748B" }}>
          {displayArea}, {displayGov}
        </span>
      </div>

      {/* Row 3: Date */}
      <div className="flex items-center gap-2 mb-2">
        <Clock size={13} className="text-[#64748B] flex-shrink-0" />
        <span style={{ fontFamily: ff, fontSize: "12px", color: "#64748B" }}>
          {formatDate(order.updatedAt, lang)}
        </span>
      </div>

      {/* Row 4: Driver */}
      <div className="flex items-center gap-2 mb-4">
        <Truck size={14} className={displayDriver ? "text-[#1A3C6E]" : "text-[#F59E0B]"} />
        <span style={{ fontFamily: ff, fontSize: "13px", color: displayDriver ? "#1A202C" : "#F59E0B", fontWeight: displayDriver ? 500 : 600 }}>
          {displayDriver ?? (lang === "ar" ? "في انتظار السائق" : "Awaiting Driver")}
        </span>
      </div>

      {/* Progress stepper (hidden for cancelled) */}
      {order.status !== "CANCELLED" && (
        <div className="relative">
          <div className="absolute top-3 left-3 right-3 h-0.5 bg-[#E2E8F0]" />
          <div
            className="absolute top-3 left-3 h-0.5 bg-[#FFD700] transition-all duration-500"
            style={{ width: `${(stepIdx / 3) * 100}%` }}
          />
          <div className="relative flex justify-between">
            {steps.map((step, idx) => {
              const done = idx <= stepIdx;
              return (
                <div key={step.key} className="flex flex-col items-center gap-1" style={{ width: "25%" }}>
                  <div
                    className="w-6 h-6 rounded-full flex items-center justify-center z-10 relative"
                    style={{ background: done ? "#FFD700" : "#E2E8F0" }}
                  >
                    {done
                      ? <CheckCircle2 size={16} className="text-[#1A3C6E]" />
                      : <Circle size={16} className="text-[#94A3B8]" />}
                  </div>
                  <span
                    className="text-center leading-tight"
                    style={{
                      fontFamily: ff,
                      fontSize: "10px",
                      color: done ? "#1A3C6E" : "#94A3B8",
                      fontWeight: done ? 600 : 400,
                    }}
                  >
                    {lang === "ar" ? step.ar : step.en}
                  </span>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Cancelled banner */}
      {order.status === "CANCELLED" && (
        <div
          className="mt-2 rounded-[8px] p-3 text-center"
          style={{ background: "#F8D7DA", fontFamily: ff, fontSize: "13px", color: "#721C24", fontWeight: 600 }}
        >
          {lang === "ar" ? "تم إلغاء هذا الطلب" : "This order has been cancelled"}
        </div>
      )}
    </div>
  );
}
