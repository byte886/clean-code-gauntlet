// Package cart 购物车价格计算（落地3 Go 版：跨语言验证 + GitHub Actions 实测示例）
package cart

import "fmt"

// Subtotal 计算条目小计
func Subtotal(price, qty float64) float64 {
	if qty <= 0 {
		return 0
	}
	return price * qty
}

// DiscountFor 满减 + 会员折扣（返回值已是最终应付金额）
func DiscountFor(total float64, member bool) float64 {
	base := total
	if total >= 300 {
		base = total - 50
	} else if total >= 100 {
		base = total - 10
	}
	if member && base > 0 {
		return round2(base * 0.9)
	}
	return round2(base)
}

// ApplyCoupon 优惠券
func ApplyCoupon(amount float64, code string) float64 {
	if code == "SAVE5" {
		return round2(amount - 5)
	}
	return round2(amount)
}

// FinalTotal 最终合计
func FinalTotal(items []float64, member bool) float64 {
	total := 0.0
	for _, it := range items {
		total += it
	}
	return DiscountFor(total, member)
}

// Describe 金额描述
func Describe(amount float64) string {
	switch {
	case amount <= 0:
		return "免费"
	case amount < 100:
		return fmt.Sprintf("%.2f 元", amount)
	default:
		return fmt.Sprintf("大额订单：%.2f 元", amount)
	}
}

func round2(v float64) float64 {
	return float64(int(v*100+0.5)) / 100
}
