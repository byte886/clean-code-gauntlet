package cart

import "testing"

func TestSubtotal(t *testing.T) {
	if got := Subtotal(10, 3); got != 30 {
		t.Errorf("Subtotal(10,3)=%v, want 30", got)
	}
	if got := Subtotal(10, 0); got != 0 {
		t.Errorf("Subtotal(10,0)=%v, want 0", got)
	}
	if got := Subtotal(10, 1); got != 10 {
		t.Errorf("Subtotal(10,1)=%v, want 10", got)
	}
	if got := Subtotal(10, 2); got != 20 {
		t.Errorf("Subtotal(10,2)=%v, want 20", got)
	}
}

func TestDiscountFor(t *testing.T) {
	cases := []struct {
		total  float64
		member bool
		want   float64
	}{
		{50, false, 50}, {99.99, false, 99.99}, {100, false, 90},
		{200, false, 190}, {300, false, 250}, {0, true, 0},
		{1, true, 0.9}, {11, true, 9.9}, {100, true, 81}, {400, true, 315},
	}
	for _, c := range cases {
		if got := DiscountFor(c.total, c.member); got != c.want {
			t.Errorf("DiscountFor(%v,%v)=%v, want %v", c.total, c.member, got, c.want)
		}
	}
}

func TestApplyCoupon(t *testing.T) {
	if got := ApplyCoupon(100, "SAVE5"); got != 95 {
		t.Errorf("ApplyCoupon SAVE5 = %v, want 95", got)
	}
	if got := ApplyCoupon(100, "NONE"); got != 100 {
		t.Errorf("ApplyCoupon NONE = %v, want 100", got)
	}
}

func TestFinalTotal(t *testing.T) {
	if got := FinalTotal([]float64{30, 40, 30}, false); got != 90 {
		t.Errorf("FinalTotal = %v, want 90", got)
	}
	if got := FinalTotal([]float64{30, 40, 30}, true); got != 81 {
		t.Errorf("FinalTotal member = %v, want 81", got)
	}
}

func TestDescribe(t *testing.T) {
	cases := []struct {
		amt  float64
		want string
	}{
		{0, "免费"}, {1, "1.00 元"}, {50.5, "50.50 元"},
		{99, "99.00 元"}, {100, "大额订单：100.00 元"}, {120, "大额订单：120.00 元"},
	}
	for _, c := range cases {
		if got := Describe(c.amt); got != c.want {
			t.Errorf("Describe(%v)=%q, want %q", c.amt, got, c.want)
		}
	}
}
