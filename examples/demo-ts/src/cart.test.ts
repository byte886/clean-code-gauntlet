import { describe, expect, it } from "vitest";
import { subtotal, discountFor, applyCoupon, finalTotal, describeAmount } from "./cart.js";

describe("subtotal", () => {
  it("基础与边界", () => {
    expect(subtotal(10, 3)).toBe(30);
    expect(subtotal(10, 0)).toBe(0);
    expect(subtotal(10, 1)).toBe(10); // 变异点：0 -> 1
    expect(subtotal(10, 2)).toBe(20); // 变异点：* -> /
  });
});

describe("discountFor", () => {
  it("满减与会员", () => {
    expect(discountFor(50, false)).toBe(50);
    expect(discountFor(99.99, false)).toBe(99.99);
    expect(discountFor(100, false)).toBe(90);
    expect(discountFor(200, false)).toBe(190);
    expect(discountFor(300, false)).toBe(250);
    expect(discountFor(0, true)).toBe(0);
    expect(discountFor(1, true)).toBe(0.9); // 变异点：0 -> 1
    expect(discountFor(11, true)).toBe(9.9);
    expect(discountFor(100, true)).toBe(81);
    expect(discountFor(400, true)).toBe(315);
  });
});

describe("applyCoupon", () => {
  it("优惠券", () => {
    expect(applyCoupon(100, "SAVE5")).toBe(95);
    expect(applyCoupon(100, "NONE")).toBe(100);
  });
});

describe("finalTotal", () => {
  it("合计", () => {
    expect(finalTotal([30, 40, 30], false)).toBe(90);
    expect(finalTotal([30, 40, 30], true)).toBe(81);
  });
});

describe("describeAmount", () => {
  it("金额描述", () => {
    expect(describeAmount(0)).toBe("免费");
    expect(describeAmount(1)).toBe("1.00 元"); // 变异点：0 -> 1
    expect(describeAmount(50.5)).toBe("50.50 元");
    expect(describeAmount(99)).toBe("99.00 元");
    expect(describeAmount(100)).toBe("大额订单：100.00 元"); // 变异点：< -> <=
    expect(describeAmount(120)).toBe("大额订单：120.00 元");
  });
});
