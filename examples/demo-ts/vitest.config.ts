import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    coverage: {
      provider: "v8",
      // crapper/mutator 读 target/coverage 或 coverage/**/lcov.info；必须输出 LCOV
      reporter: ["text", "lcov"],
      thresholds: { lines: 80 },
    },
  },
});
