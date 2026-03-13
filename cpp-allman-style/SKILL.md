---
name: cpp-allman-style
description: C++ 代码风格规范，使用 Allman 风格（花括号独占一行）。当编写或修改 C++ 代码时自动应用此规范。
---

# C++ 代码风格规范（Allman 风格）

## 花括号格式

左花括号独占一行，与语句对齐：

```cpp
// ✅ 正确
for (int i = 0; i < n; i++)
{
    doSomething();
}

if (condition)
{
    doA();
    doB();
}

// ✅ 单行语句可省略花括号
if (x < 0)
    return;

while (running)
    process();
```

## Lambda 表达式

短则紧凑，长则换行：

```cpp
// ✅ 短 lambda - 紧凑写法
auto fn = [&](int x) { return x * 2; };
auto pred = [](const Item& i) { return i.active; };

// ✅ 长 lambda - 换行
auto process = [&](const Device& dev)
{
    QString result;
    for (const auto& pin : dev.pins)
    {
        result += pin.name;
    }
    return result;
};
```

## 初始化列表

两种写法都可接受：

```cpp
// 紧凑写法
static const QSet<QString> types = {"A", "B", "C"};

// 换行写法
static const QSet<QString> types = {
    "A", "B", "C"
};
```

## 函数定义

```cpp
// ✅ 正确
void processData(const Data& input)
{
    // 实现
}

// ❌ 避免
void processData(const Data& input) {
    // 实现
}
```

## 类和结构体

```cpp
// ✅ 正确
class MyClass
{
public:
    MyClass();
    ~MyClass();

private:
    int m_value;
};

struct DataNode
{
    QString name;
    int value;
};
```

## 控制语句

```cpp
// ✅ 正确
if (a > b)
{
    result = a;
}
else
{
    result = b;
}

// ✅ 单行可省略花括号
if (ptr == nullptr)
    return false;

// ✅ for 循环
for (const auto& item : list)
{
    process(item);
}
```
