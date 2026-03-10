# 函数重构示例

## 示例：300行函数拆分为4个子函数

### 重构前（原函数约300行）

```cpp
void SpdUtil::loadInDevPTData(PointElem& pointDat, Pin* pin, PowerCircElem& data)
{
    if (pin == nullptr || pin->type == "Fiber") return;

    // 初始化电缆和缆芯信息
    Cable* pCurCable = nullptr;
    Core* pCurCore = nullptr;
    bool isLastCabCore = false;
    if (pin->pParentCore && pin->pParentCore->pCable)
    {
        pCurCable = pin->pParentCore->pCable;
        pCurCore = pin->pParentCore;
        isLastCabCore = (pCurCore == &pCurCable->lstcore.last());
    }

    // 强制设置电缆间端子名称为2
    if (pin->name == "1")
    {
        setPinGroup(pin->pParentDev);
        if (pin->pGroupPin && pin->pGroupPin->name == "2")
            pin = pin->pGroupPin;
    }

    if (pin->pParentDev)
        setPinGroup(pin->pParentDev);
    pin = pin->pGroupPin;
    if (pin == nullptr) return;

    // 初始化BFS队列
    QQueue<SearchNode> queue;
    QSet<Pin*> visited;
    SearchNode startNode;
    startNode.pCurPin = pin;
    startNode.pathDevs.append(pin);
    queue.enqueue(startNode);
    visited.insert(pin);

    // 获取当前柜信息
    Device* ptmpDev = pin->pParentDev;
    if (ptmpDev == nullptr) return;
    Cubicle* pCurCub = ptmpDev->pParentCub;
    bool isPTBCub = pCurCub && pCurCub->desc.contains(fromgbk("并列"));

    // 获取前一电缆和装置
    Cable* pPreCable = nullptr;
    Cable* pPreCable2 = nullptr;
    Device* pPreDev = nullptr;
    if (data.mpCubElems.contains(pCurCub))
    {
        pPreCable = data.mpCubElems[pCurCub].pPreCab;
        pPreDev = data.mpCubElems[pCurCub].pPreDev;
        pPreCable2 = data.mpCubElems[pCurCub].pPreCab2;
    }

    // ========== BFS搜索阶段 ==========
    QVector<SearchNode> validPaths;
    while (!queue.isEmpty())
    {
        // ... 约100行BFS搜索逻辑
    }

    // ========== 路径选择阶段 ==========
    if (validPaths.isEmpty()) return;
    std::sort(validPaths.begin(), validPaths.end(), ...);
    SearchNode* shortestPath = nullptr;
    
    // ... 约80行路径选择逻辑

    // ========== 处理选中路径 ==========
    for (int i = 0; i < shortestPath->pathDevs.size(); i++)
    {
        // ... 约70行路径处理逻辑
    }
}
```

**问题分析**：
- 函数过长（约300行）
- 职责混杂（初始化、搜索、选择、处理全在一起）
- 魔数（`devCnt >= 2`、`devCnt = 1`）
- 指针悬挂风险（`shortestPath = &node`）

---

### 重构后

#### 1. 上下文结构体

```cpp
struct SearchContext
{
    Pin* pStartPin = nullptr;           // 搜索起点端子
    Cubicle* pCurCub = nullptr;         // 当前屏柜
    bool isPTBCub = false;              // 是否为并列柜
    Cable* pCurCable = nullptr;         // 当前电缆
    Core* pCurCore = nullptr;           // 当前缆芯
    bool isLastCabCore = false;         // 是否为电缆最后缆芯
    Cable* pPreCable = nullptr;         // 前一电缆
    Cable* pPreCable2 = nullptr;        // 前一电缆2
    Device* pPreDev = nullptr;          // 前一装置
};
```

#### 2. 常量定义

```cpp
constexpr int MAX_DEVICE_COUNT = 2;
constexpr int DEVICE_COUNT_RESET = 1;
```

#### 3. 子函数

```cpp
// 初始化搜索上下文（约45行）
SearchContext initSearchContext(Pin* pin, PowerCircElem& data);

// BFS搜索获取所有有效路径（约95行）
QVector<SearchNode> bfsSearchPaths(SearchContext& ctx, PowerCircElem& data);

// 选择最佳路径，返回路径索引（约80行）
int selectBestPath(QVector<SearchNode>& validPaths, const SearchContext& ctx, const PowerCircElem& data);

// 处理选中的路径（约70行）
bool processSelectedPath(const SearchNode& path, PointElem& pointDat, PowerCircElem& data, const SearchContext& ctx);
```

#### 4. 主函数（17行）

```cpp
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
    processSelectedPath(validPaths[selectedIndex], pointDat, data, ctx, m_lstComnDev);
}
```

---

### 重构效果对比

| 指标 | 重构前 | 重构后 |
|------|--------|--------|
| 主函数行数 | ~300行 | **17行** |
| 最大嵌套深度 | 5层 | 3层 |
| 可测试性 | 差（难以单测） | **好（可独立测试每个子函数）** |
| 可读性 | 差（需通读300行） | **好（一目了然）** |
| 魔数 | 多处 | **消除** |
| 指针安全 | 有悬挂风险 | **安全（使用索引）** |

---

## 关键技巧总结

1. **先识别分界点**：注释、变量块、循环块都是天然的分界
2. **封装上下文**：多个相关变量用结构体封装
3. **命名要描述意图**：`initSearchContext` 比 `processStep1` 更清晰
4. **主函数只调度**：变成"指挥官"而非"执行者"
5. **子函数限域**：优先用匿名命名空间限制可见性
