"""cart 模块的单元测试：覆盖全部主要分支（满减/会员/优惠券/边界）。"""

import pytest

from src.cart import apply_coupon, describe, discount_for, final_total, subtotal


class TestSubtotal:
    def test_empty(self):
        assert subtotal([]) == 0.0

    def test_dict(self):
        assert subtotal({"a": 1.5, "b": 2.5}) == 4.0

    def test_tuples(self):
        assert subtotal([("a", 1.0), ("b", 2.0)]) == 3.0

    def test_plain_numbers(self):
        assert subtotal([1, 2, 3]) == 6


class TestDiscount:
    def test_under_100_no_discount(self):
        assert discount_for(50) == 50.0

    def test_100_tier(self):
        assert discount_for(100) == 90.0

    def test_300_tier(self):
        assert discount_for(300) == 250.0

    def test_member_discount(self):
        assert discount_for(200, member=True) == 171.0  # 200-10=190, *0.9=171

    def test_member_on_zero(self):
        assert discount_for(0, member=True) == 0.0

    def test_member_base_one(self):
        # 变异点覆盖：`base > 0` 的字面量 0→1（base=1 时行为不同：原 True→0.9，变异 False→1.0）
        assert discount_for(1, member=True) == 0.9

    def test_member_base_eleven(self):
        assert discount_for(11, member=True) == 9.9  # base=11 → 9.9


class TestCoupon:
    def test_no_coupon(self):
        assert apply_coupon(100) == 100.0

    def test_fixed10(self):
        assert apply_coupon(100, "FIXED10") == 90.0

    def test_fixed10_not_below_zero(self):
        assert apply_coupon(5, "FIXED10") == 0.0

    def test_unknown_code_ignored(self):
        assert apply_coupon(100, "MYSTERY") == 100.0


class TestFinalTotal:
    def test_plain(self):
        assert final_total([("a", 40), ("b", 60)]) == 90.0  # 100 档减 10

    def test_member_plus_coupon(self):
        assert final_total([("a", 150)], member=True, coupon_code="FIXED10") == 116.0  # 150-10=140,*0.9=126,-10=116

    def test_empty_cart(self):
        assert final_total([]) == 0.0


class TestDescribe:
    def test_free(self):
        assert describe(0) == "免费"

    def test_free_boundary_one(self):
        # 变异点覆盖：`amount <= 0` 的字面量 0→1（amount=1 时行为不同）
        assert describe(1) == "1.00 元"

    def test_small(self):
        assert describe(50.5) == "50.50 元"

    def test_small_boundary_99(self):
        assert describe(99) == "99.00 元"

    def test_large_boundary_100(self):
        # 变异点覆盖：`amount < 100` 的 < → <=（amount=100 时行为不同）
        assert describe(100) == "大额订单：100.00 元"

    def test_large(self):
        assert describe(120) == "大额订单：120.00 元"
