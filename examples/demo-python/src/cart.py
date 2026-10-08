"""购物车折扣计算模块（落地3 demo：带分支的最小业务代码）。

设计意图：函数数量适中、每个函数都有 if/elif/and/or 分支，
让复杂度（CC）、覆盖率、变异测试都有东西可查可杀。
"""


def subtotal(items):
    """汇总商品价格。items: list[(name, price)] 或 list[price] 或 dict{name: price}。"""
    if not items:
        return 0.0
    if isinstance(items, dict):
        return sum(items.values())
    if isinstance(items[0], tuple):
        return sum(price for _, price in items)
    return sum(items)


def discount_for(total, member=False):
    """满减逻辑：满 300 减 50，满 100 减 10；会员再享 9 折（先满减再会员折）。"""
    if total >= 300:
        base = total - 50
    elif total >= 100:
        base = total - 10
    else:
        base = total
    if member and base > 0:
        return round(base * 0.9, 2)
    return round(base, 2)


def apply_coupon(total, coupon_code="NONE"):
    """优惠券：FIXED10 立减 10（不低于 0）；其它券码视为无效。"""
    if coupon_code == "FIXED10":
        return max(total - 10, 0.0)
    return total


def final_total(items, member=False, coupon_code="NONE"):
    """完整结算：汇总 → 满减/会员 → 优惠券。"""
    raw = subtotal(items)
    after_discount = discount_for(raw, member=member)
    return apply_coupon(after_discount, coupon_code)


def describe(amount):
    """金额文案：用于输出展示。"""
    if amount <= 0:
        return "免费"
    if amount < 100:
        return f"{amount:.2f} 元"
    return f"大额订单：{amount:.2f} 元"
