// 购物车价格计算（落地3-TS demo，与 Python/Go demo 同逻辑，供跨语言验证）
export function subtotal(price: number, qty: number): number {
  if (qty <= 0) return 0;
  return price * qty;
}

export function discountFor(total: number, member: boolean): number {
  let base = total;
  if (total >= 300) base = total - 50;
  else if (total >= 100) base = total - 10;
  if (member && base > 0) return round2(base * 0.9);
  return round2(base);
}

export function applyCoupon(amount: number, code: string): number {
  if (code === "SAVE5") return round2(amount - 5);
  return round2(amount);
}

export function finalTotal(items: number[], member: boolean): number {
  return discountFor(items.reduce((a, b) => a + b, 0), member);
}

export function describeAmount(amount: number): string {
  if (amount <= 0) return "免费";
  if (amount < 100) return `${amount.toFixed(2)} 元`;
  return `大额订单：${amount.toFixed(2)} 元`;
}

function round2(v: number): number {
  return Math.round(v * 100) / 100;
}
