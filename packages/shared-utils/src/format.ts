/**
 * Format a Jordan phone number to a consistent display form.
 * Accepts: +962XXXXXXXXX or 07XXXXXXXX or 9XXXXXXXXX
 */
export function formatPhone(raw: string): string {
  const digits = raw.replace(/\D/g, '');
  if (digits.startsWith('962')) return `+${digits}`;
  if (digits.startsWith('0')) return `+962${digits.slice(1)}`;
  return `+962${digits}`;
}

/**
 * Format a JOD currency amount for display.
 * e.g. 12.5 → "12.500 JOD"
 */
export function formatCurrency(amount: number, locale: 'en' | 'ar' = 'en'): string {
  const formatted = amount.toFixed(3);
  return locale === 'ar' ? `${formatted} د.أ` : `${formatted} JOD`;
}
