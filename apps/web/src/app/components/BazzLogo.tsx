interface BazzLogoProps {
  variant?: "colored" | "white";
  size?: "sm" | "md" | "lg";
}

export function BazzLogo({ variant = "colored", size = "md" }: BazzLogoProps) {
  const sizes = { sm: "text-xl", md: "text-2xl", lg: "text-4xl" };
  const dotSize = { sm: "w-1 h-1", md: "w-1.5 h-1.5", lg: "w-2 h-2" };

  const mainColor = variant === "white" ? "text-white" : "text-[#1A3C6E]";
  const goldColor = variant === "white" ? "text-[#FFD700]" : "text-[#FFD700]";

  return (
    <div className="relative inline-flex items-center select-none">
      <span
        className={`${sizes[size]} font-extrabold tracking-tight relative`}
        style={{ fontFamily: "Inter, sans-serif" }}
      >
        <span className={mainColor}>Baz</span>
        <span className={`${goldColor} relative inline-block`}>
          Z
          {/* 4 red dots at each corner of the Z */}
          <span className={`absolute -top-0.5 -left-0.5 ${dotSize[size]} rounded-full bg-[#E53935]`} />
          <span className={`absolute -top-0.5 -right-0.5 ${dotSize[size]} rounded-full bg-[#E53935]`} />
          <span className={`absolute -bottom-0.5 -left-0.5 ${dotSize[size]} rounded-full bg-[#E53935]`} />
          <span className={`absolute -bottom-0.5 -right-0.5 ${dotSize[size]} rounded-full bg-[#E53935]`} />
        </span>
      </span>
    </div>
  );
}
