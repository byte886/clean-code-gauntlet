/** dependency-cruiser 配置：禁止循环依赖（最小架构约束）；"type":"module" 项目须用 .cjs */
module.exports = {
  forbidden: [
    { name: "no-circular", severity: "error", from: {}, to: { circular: true } },
  ],
  options: {
    doNotFollow: { path: "node_modules" },
  },
};
