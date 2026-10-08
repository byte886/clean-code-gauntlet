// 购物车价格计算（落地3-Rust demo，与 Python/Go/TS demo 同逻辑，供跨语言验证）

/// 小计：单价 × 数量；数量非正返回 0
pub fn subtotal(price: f64, qty: i32) -> f64 {
    if qty <= 0 {
        return 0.0;
    }
    price * qty as f64
}

/// 折扣：满减（300-50 / 100-10）+ 会员 9 折
pub fn discount_for(total: f64, member: bool) -> f64 {
    let mut base = total;
    if total >= 300.0 {
        base = total - 50.0;
    } else if total >= 100.0 {
        base = total - 10.0;
    }
    if member && base > 0.0 {
        return round2(base * 0.9);
    }
    round2(base)
}

/// 优惠券：SAVE5 减 5 元
pub fn apply_coupon(amount: f64, code: &str) -> f64 {
    if code == "SAVE5" {
        return round2(amount - 5.0);
    }
    round2(amount)
}

/// 合计：满减 + 会员
pub fn final_total(items: &[f64], member: bool) -> f64 {
    let sum: f64 = items.iter().sum();
    discount_for(sum, member)
}

/// 金额描述
pub fn describe_amount(amount: f64) -> String {
    if amount <= 0.0 {
        return "免费".to_string();
    }
    if amount < 100.0 {
        return format!("{:.2} 元", amount);
    }
    format!("大额订单：{:.2} 元", amount)
}

fn round2(v: f64) -> f64 {
    (v * 100.0).round() / 100.0
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn subtotal_ok() {
        assert_eq!(subtotal(10.0, 3), 30.0);
        assert_eq!(subtotal(10.0, 0), 0.0);
        assert_eq!(subtotal(10.0, 1), 10.0); // 变异点：0 -> 1
        assert_eq!(subtotal(10.0, 2), 20.0); // 变异点：* -> /
    }

    #[test]
    fn discount_ok() {
        assert_eq!(discount_for(50.0, false), 50.0);
        assert_eq!(discount_for(99.99, false), 99.99);
        assert_eq!(discount_for(100.0, false), 90.0);
        assert_eq!(discount_for(200.0, false), 190.0);
        assert_eq!(discount_for(300.0, false), 250.0);
        assert_eq!(discount_for(0.0, true), 0.0);
        assert_eq!(discount_for(1.0, true), 0.9); // 变异点：0 -> 1
        assert_eq!(discount_for(11.0, true), 9.9);
        assert_eq!(discount_for(100.0, true), 81.0);
        assert_eq!(discount_for(400.0, true), 315.0);
    }

    #[test]
    fn coupon_ok() {
        assert_eq!(apply_coupon(100.0, "SAVE5"), 95.0);
        assert_eq!(apply_coupon(100.0, "NONE"), 100.0);
    }

    #[test]
    fn final_ok() {
        assert_eq!(final_total(&[30.0, 40.0, 30.0], false), 90.0);
        assert_eq!(final_total(&[30.0, 40.0, 30.0], true), 81.0);
    }

    #[test]
    fn describe_ok() {
        assert_eq!(describe_amount(0.0), "免费");
        assert_eq!(describe_amount(1.0), "1.00 元"); // 变异点：0 -> 1
        assert_eq!(describe_amount(50.5), "50.50 元");
        assert_eq!(describe_amount(99.0), "99.00 元");
        assert_eq!(describe_amount(100.0), "大额订单：100.00 元"); // 变异点：< -> <=
        assert_eq!(describe_amount(120.0), "大额订单：120.00 元");
    }
}
