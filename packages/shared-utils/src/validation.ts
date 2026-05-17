/**
 * Validate a Jordan mobile number.
 * Valid prefixes: 077, 078, 079 (Zain / Orange / Umniah)
 */
export function isValidJordanPhone(phone: string): boolean {
  return /^(\+962|0)?(77|78|79)\d{7}$/.test(phone.replace(/\s/g, ''));
}

/**
 * Validate a BazZ order ID format: #BZ-XXXX
 */
export function isValidOrderId(id: string): boolean {
  return /^#BZ-\d{4,}$/.test(id);
}
