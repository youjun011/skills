---
name: function-refactoring
description: 重构过长函数，拆分为职责单一的小函数。适用于函数超过100行、圈复杂度过高、难以测试和维护的场景。当用户要求优化函数、拆分函数、降低复杂度时使用。
---

# 函数重构技能

## 核心原则

**单一职责**：一个函数只做一件事，每个子函数控制在50行以内。

## 重构流程

### 第一步：评估函数质量

快速扫描函数，识别问题：

| 问题类型 | 识别标志 | 严重程度 |
|---------|---------|---------|
| 函数过长 | 超过100行 | 高 |
| 圈复杂度高 | 嵌套超过3层、分支超过5个 | 高 |
| 职责混杂 | 多个不相关的代码块 | 高 |
| 魔数泛滥 | 硬编码数字无注释 | 中 |
| 变量命名随意 | tmXxx、tempXxx 等 | 中 |
| 重复模式 | 相似的代码块出现多次 | 中 |

### 第二步：识别逻辑分段

寻找函数内的"天然分界点"：

1. **注释分隔**：如 `// === BFS搜索阶段 ===`
2. **变量初始化块**：函数开头的一系列变量声明
3. **循环/条件块**：独立的while/for/if逻辑块
4. **返回前处理**：函数末尾的结果处理逻辑

### 第三步：提取上下文结构体

当多个变量需要跨函数传递时，创建上下文结构体：

```cpp
// 重构前：多个散落的变量
Cable* pCurCable = nullptr;
Core* pCurCore = nullptr;
bool isLastCabCore = false;
Cubicle* pCurCub = nullptr;
// ... 更多变量

// 重构后：封装为结构体
struct SearchContext {
    Cable* pCurCable = nullptr;
    Core* pCurCore = nullptr;
    bool isLastCabCore = false;
    Cubicle* pCurCub = nullptr;
    // ... 相关变量
};
```

**原则**：相关的变量放一起，按职责分组。

### 第四步：拆分子函数

按职责提取子函数，命名要**描述做什么而非怎么做**：

| 坏命名 | 好命名 |
|--------|--------|
| `processStep1()` | `initSearchContext()` |
| `doLoop()` | `bfsSearchPaths()` |
| `handleResult()` | `selectBestPath()` |

**常见拆分模式**：

```
原函数结构:
├── 初始化变量
├── 主逻辑循环
├── 结果选择
└── 结果处理

拆分后:
├── initXxxContext()    // 初始化
├── executeXxxLogic()   // 主逻辑
├── selectXxxResult()   // 结果选择
└── processXxxResult()  // 结果处理
```

### 第五步：消除魔数

```cpp
// 重构前
if (devCnt >= 2 && devCnt > 2) devCnt = 1;

// 重构后
constexpr int MAX_DEVICE_COUNT = 2;
constexpr int DEVICE_COUNT_RESET = 1;

if (devCnt >= MAX_DEVICE_COUNT && devCnt > MAX_DEVICE_COUNT) 
    devCnt = DEVICE_COUNT_RESET;
```

### 第六步：重构主函数

主函数变为"调度者"，只负责调用子函数：

```cpp
// 重构后的主函数示例
void SpdUtil::loadInDevPTData(PointElem& pointDat, Pin* pin, PowerCircElem& data)
{
    // 1. 初始化搜索上下文
    SearchContext ctx = initSearchContext(pin, data);
    if (ctx.pStartPin == nullptr) return;

    // 2. BFS搜索获取所有有效路径
    QVector<SearchNode> validPaths = bfsSearchPaths(ctx, data);
    if (validPaths.isEmpty()) return;

    // 3. 选择最佳路径
    int selectedIndex = selectBestPath(validPaths, ctx, data);
    if (selectedIndex < 0) return;

    // 4. 处理选中的路径
    processSelectedPath(validPaths[selectedIndex], pointDat, data, ctx);
}
```

## 子函数存放位置

根据可见性需求选择：

| 场景 | 存放位置 | 说明 |
|------|---------|------|
| 仅当前CPP使用 | 匿名命名空间 | `namespace { ... }` |
| 类内部复用 | private成员函数 | 头文件声明 |
| 跨类复用 | 独立工具函数 | 单独头文件 |

**推荐**：优先使用匿名命名空间，限制作用域。

## 检查清单

重构完成后逐项检查：

- [ ] 主函数是否在50行以内
- [ ] 每个子函数是否职责单一
- [ ] 是否消除了魔数
- [ ] 变量命名是否清晰
- [ ] 是否修复了潜在的指针/内存问题
- [ ] 子函数是否放在合适的作用域

## 常见问题处理

### Q: 子函数需要访问类的私有成员怎么办？

**方案1**：将上下文结构体作为参数传递
```cpp
struct ProcessContext {
    QList<Device>& lstComnDev;  // 引用类成员
};
```

**方案2**：将需要的数据作为参数传入
```cpp
bool processSelectedPath(..., QList<Device>& lstComnDev);
```

### Q: 拆分后性能会下降吗？

不会。现代编译器会内联小函数，性能影响可忽略。可读性和可维护性的收益远大于微小的性能开销。

### Q: 如何处理复杂的条件分支？

提取为独立的判断函数：
```cpp
// 重构前
if ((a && b) || (c && d) || (e && !f)) { ... }

// 重构后
if (shouldProcessCondition(a, b, c, d, e, f)) { ... }
```

## 示例对比

详见 [examples.md](examples.md)
