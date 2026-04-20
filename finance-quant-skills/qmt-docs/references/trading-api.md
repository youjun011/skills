# QMT 交易函数API 完全参考

## 🚀 交易函数总览

| 函数 | 用途 | 返回值 |
|------|------|--------|
| `passorder` | 提交下单委托 | 委托编号 |
| `get_trade_detail_data` | 查询交易数据 | 数据列表 |

---

## 💰 一、passorder - 下单函数

### 函数签名

```python
passorder(
    buyorsell,                  # 买卖代码
    price_type,                 # 价格类型
    account,                    # 账号
    stock,                      # 股票代码
    order_type,                 # 订单类型
    stop_price,                 # 止价
    order_vol,                  # 成交数量
    [strategy_name, quicktrade, remark, C]  # 可选参数
)
```

### 参数详解

#### 1. buyorsell - 买卖代码

```python
# 股票账户（STOCK）
23  # 买入
24  # 卖出

# 两融账户（CREDIT）
33  # 融资买入
34  # 融券卖出
35  # 买入还款
36  # 卖出还券
```

#### 2. price_type - 价格订单类型

```python
1101  # 市价单（推荐）- 按市场最优价格成交
# 其他价格类型可参考交易所规定
```

#### 3. account - 账号

```python
# 账号必须与实际登录的账号相符
account = "123456"      # 正确的账号ID
account = "test"        # 回测账号
```

#### 4. stock - 股票代码

```python
# 格式: 代码.市场代码
stock = "600000.SH"    # 上海股票
stock = "000001.SZ"    # 深圳股票
```

#### 5. order_type - 订单类型

```python
5   # 普通下单
14  # 实盘下单
# 其他类型可参考QMT文档
```

#### 6. stop_price - 止价

```python
-1          # 不设置止价（推荐）
1000000     # 止损价格（如有需要）
```

#### 7. order_vol - 成交数量

```python
# 股票必须是100的整数倍
100         # 1手（100股）
1000        # 10手（1000股）
10000       # 100手（10000股）

# 计算正确的数量
available_cash = 10000  # 可用资金
price = 10.5           # 目标价格
vol = int(available_cash / price / 100) * 100  # 向下取整到100的倍数
```

#### 8. 可选参数 - strategy_name, quicktrade, remark, C

```python
# 参数 4: 策略名称
strategy_name = '双均线策略'

# 参数 5: 快速交易参数（关键！）
quicktrade = 0          # 逐K线模式（等待K线完成）
quicktrade = 2          # 立即下单模式（立刻执行）

# 参数 6: 备注
remark = '金叉买入信号'

# 参数 7: ContextInfo对象
C                       # 必须传入

# 完整调用
passorder(23, 1101, 'account', '600000.SH', 14, -1, 100, 
          '双均线', 0, '金叉买入', C)
```

### 使用示例

#### 示例1：简单买入

```python
def handlebar(C):
    # 买入信号
    if buy_signal:
        passorder(
            23,                 # 买入
            1101,               # 市价
            C.accountid,        # 账号
            C.stock,            # 股票
            5,                  # 订单类型
            -1,                 # 不设置止价
            100,                # 买入100股
            C                   # ContextInfo
        )
```

#### 示例2：完整的买入逻辑

```python
def handlebar(C):
    # 获取账户信息
    account = get_trade_detail_data('test', 'stock', 'account')[0]
    available_cash = int(account.m_dAvailable)
    
    # 获取行情
    data = C.get_market_data_ex(['close'], [C.stock], count=1, subscribe=False)
    current_price = data[C.stock].values[0][0]
    
    # 计算购买数量
    vol = int(available_cash * 0.95 / current_price / 100) * 100
    
    if vol >= 100:  # 确保至少1手
        msg = f"{C.stock} 于 {current_price} 买入 {vol} 股"
        passorder(
            23,                 # 买入
            1101,               # 市价单
            'test',             # 账号
            C.stock,            # 股票
            14,                 # 实盘订单类型
            -1,                 # 无止价
            vol,                # 数量
            '策略名称',
            0,                  # 逐K线
            msg,                # 备注
            C
        )
        print(msg)
```

#### 示例3：逐K线模式与立即下单模式

```python
# 逐K线模式 - 等待K线完成再下单
passorder(23, 1101, account, stock, 14, -1, 100, 
          'strategy', 0, 'msg', C)

# 立即下单模式 - 立刻下单
passorder(23, 1101, account, stock, 14, -1, 100, 
          'strategy', 2, 'msg', C)
```

---

## 📊 二、get_trade_detail_data - 查询交易数据

### 函数签名

```python
data = get_trade_detail_data(
    account,        # 账号
    account_type,   # 账户类型
    data_type       # 数据类型
)
```

### 参数说明

#### 1. account - 账号

```python
account = "123456"      # 正确的账号ID
account = "test"        # 回测或模拟账号
```

#### 2. account_type - 账户类型

```python
'stock'     # 股票账户
'credit'    # 两融账户（融资融券）
# 必须与实际账户类型相符
```

#### 3. data_type - 数据类型

| 数据类型 | 说明 | 返回格式 |
|---------|------|--------|
| 'account' | 账户信息 | 列表（通常只有1个元素） |
| 'position' | 持仓信息 | 列表（每个持仓一个元素） |
| 'order' | 委托信息 | 列表（每个委托一个元素） |
| 'deal' | 成交信息 | 列表（每个成交一个元素） |

### 返回数据结构

#### 账户信息 ('account')

```python
account = get_trade_detail_data('account_id', 'stock', 'account')
# account 是一个列表，通常只有1个元素

acc = account[0]  # 取第一个账户

# 常用字段
acc.m_dAvailable         # 可用现金（单位：分）
acc.m_dTotalAsset        # 总资产
acc.m_dFloatProfit       # 浮动盈亏
acc.m_dEnableBalance     # 可用余额
```

#### 持仓信息 ('position')

```python
positions = get_trade_detail_data('account_id', 'stock', 'position')
# positions 是列表，每个持仓一个元素

for pos in positions:
    pos.m_strAccountID  # str 资金账号
    pos.m_strExchangeID  # str 证券市场
    pos.m_strExchangeName  # str 市场名称
    pos.m_strProductID  # str 品种代码
    pos.m_strProductName  # str 品种名称
    pos.m_strInstrumentID  # str 证券代码
    pos.m_strInstrumentName  # str 证券名称
    pos.m_nHedgeFlag  # int EHedge_Flag_Type 类型，投保 ，股票不适用
    pos.m_nDirection  # int EEntrustBS，买卖方向 对于股票该值始终是48
    pos.m_strOpenDate  # str 开仓日期 股票此字段无效
    pos.m_strTradeID  # str 成交号，最初开仓位的成交
    pos.m_nVolume  # int 当前拥股/持仓量
    pos.m_dOpenPrice  # float 持仓成本 ；持仓成本 = (总买入金额 - 总卖出金额) / 剩余数量
    pos.m_strTradingDay  # str 在实盘运行中是当前交易日，在回测中是股票最后交易过的日期
    pos.m_dMargin  # float 使用的保证金，历史的直接用ctp的，新的自己用成本价存量系数算，股票不适用
    pos.m_dOpenCost  # float 开仓成本，等于成本价*第一次建仓的量，后续减持会影响，不算手续费，股票不适用
    pos.m_dSettlementPrice  # float 最新结算价/当前价
    pos.m_nCloseVolume  # int 平仓量（对于股票不适用）
    pos.m_dCloseAmount  # float 平仓额（对于股票不适用）
    pos.m_dFloatProfit  # float 浮动盈亏
    pos.m_dCloseProfit  # float 平仓盈亏（对于股票不适用）
    pos.m_dMarketValue  # float 市值/合约价值
    pos.m_dPositionCost  # float 持仓成本（对于股票不适用）
    pos.m_dPositionProfit  # float 持仓盈亏（对于股票不适用）
    pos.m_dLastSettlementPrice  # float 最新结算价（对于股票不适用）
    pos.m_dInstrumentValue  # float 合约价值（对于股票不适用）
    pos.m_bIsToday	bool	是否今仓
    pos.m_strStockHolder  # str 股东账号
    pos.m_nFrozenVolume  # int 冻结数量
    pos.m_nCanUseVolume  # int 可用数量
    pos.m_nOnRoadVolume  # int 在途股份
    pos.m_nYesterdayVolume  # int 昨夜拥股
    pos.m_dLastPrice  # float 最新价/当前价
    pos.m_dAvgOpenPrice  # float 开仓均价（对于股票不适用）
    pos.m_dProfitRate  # float 盈亏比例
    pos.m_eFutureTradeType  # int EFutureTradeType 类型，成交类型
    pos.m_strExpireDate  # str 到期日（针对逆回购）
    pos.m_strComTradeID  # str 组合成交号
    pos.m_nLegId  # int 组合序号
    pos.m_dTotalCost  # float 累计成本（自定义，股票信用用到）
    pos.m_dSingleCost  # float 单股成本（自定义，股票信用用
    pos.m_nCoveredVolume  # int 备兑数量，用于个股期权
    pos.m_eSideFlag  # int 持仓类型 ，用于个股期权，标记 '0' - 权利，'1' - 义务，'2' - '备兑'
    pos.m_dReferenceRate  # float 汇率，目前用于港股通
    pos.m_dStructFundVol  # float 分级基金可用（可分拆或可合并）
    pos.m_dRedemptionVolume  # float 分级基金可赎回量
    pos.m_nPREnableVolume  # int 申赎可用量（记录当日申购赎回的股票或基金数量）
    pos.m_dRealUsedMargin  # float 实时占用保证金，用于期权
    pos.m_dRoyalty  # float 权利金
    pos.m_dStockLastPrice  # float 标的证券最新价，用于期权
    pos.m_dStaticHoldMargin  # float 静态持仓占用保证金，用于期权
    pos.m_nOptCombUsedVolume  # int 期权组合占用数量
    pos.m_nEnableExerciseVolume  # int 能够行使的数量，用于个股期权
    pos.m_strAccountKey  # str 账号key，唯一区别不同账号的key
```

#### 委托信息 ('order')

```python
orders = get_trade_detail_data('account_id', 'stock', 'order')

for order in orders:
    order.m_strAccountID  # str 资金账号，账号，账号，资金账号
    order.m_strExchangeID  # str 证券市场
    order.m_strExchangeName  # str 交易市场
    order.m_strProductID  # str 品种代码
    order.m_strProductName  # str 品种名称
    order.m_strInstrumentID  # str 证券代码
    order.m_strInstrumentName  # str 证券名称，合约名称
    order.m_nRef  # int 订单编号
    order.m_strOrderRef  # str 内部委托号，下单引用等于股票的内部委托号
    order.m_nOrderPriceType  # int EBrokerPriceType 类型，例如市价单、限价单
    order.m_nDirection  # int EEntrustBS 类型，操作，多空，期货多空，股票买卖永远是 48，其他的 dir 同理
    order.m_nOffsetFlag  # int EOffset_Flag_Type类型，买卖/开平，用此字段区分股票买卖，期货开、平仓，期权买卖等
    order.m_nHedgeFlag  # int EHedge_Flag_Type 类型，投保
    order.m_dLimitPrice  # float 委托价格，限价单的限价，即报价
    order.m_nVolumeTotalOriginal  # int 委托数量，最初的委托数量
    order.m_nOrderSubmitStatus  # int EEntrustSubmitStatus 类型，报单状态，提交状态，股票中不需要报单状态
    order.m_strOrderSysID  # str 合同编号，委托号
    order.m_nOrderStatus  # int EEntrustStatus，委托状态
    order.m_nVolumeTraded  # int 成交数量，已成交量
    order.m_nVolumeTotal  # int 委托剩余量，当前总委托量，股票中表示总委托量减去成交量
    order.m_nErrorID  # int 状态ID
    order.m_strErrorMsg  # str 状态信息
    order.m_nTaskId  # int 任务号
    order.m_dFrozenMargin  # float 冻结金额，冻结保证金
    order.m_dFrozenCommission  # float 冻结手续费
    order.m_strInsertDate  # str 委托日期，报单日期
    order.m_strInsertTime  # str 委托时间
    order.m_dTradedPrice  # float 成交均价（股票）
    order.m_dCancelAmount  # float 已撤数量
    order.m_strOptName  # str 买卖标记，展示委托属性的中文
    order.m_dTradeAmount  # float 成交金额，期货的计算方式为均价乘以数量乘以合约乘数
    order.m_eEntrustType  # int EEntrustTypes，委托类别
    order.m_strCancelInfo  # str 废单原因
    order.m_strUnderCode  # str 标的证券代码
    order.m_eCoveredFlag  # int 备兑标记，'0’表示非备兑，'1’表示备兑
    order.m_dOrderPriceRMB  # float 委托价格（人民币），目前用于港股通
    order.m_dTradeAmountRMB  # float 成交金额（人民币），目前用于港股通
    order.m_dReferenceRate  # float 汇率，目前用于港股通
    order.m_strCompactNo  # str 合约编号
    order.m_eCashgroupProp  # int EXTCompactBrushSource类型，头寸来源
    order.m_dShortOccupedMargin  # float 预估在途占用保证金，用于期权
    order.m_strXTTrade  # str 是否是迅投交易
    order.m_strAccountKey  # str 账号key，唯一区别不同账号的key
    order.m_strRemark  # str 投资备注
```

#### 成交信息 ('deal')

```python
deals = get_trade_detail_data('account_id', 'stock', 'deal', 'strategyName')

for deal in deals:
    print(deal.m_strTradeID, '# str 成交编号', '-' * 80)
    print(deal.m_strAccountID, '# str 资金账号')
    print(deal.m_strInstrumentID, '# str 证券代码')
    print(deal.m_strInstrumentName, '# str 证券名称')
    print(deal.m_strExchangeID, '# str 证券市场（SH/SZ）')
    print(deal.m_strExchangeName, '# str 交易市场名称')
    print(deal.m_strProductID, '# str 品种代码')
    print(deal.m_strProductName, '# str 品种名称')
    print(deal.m_strOrderRef, '# str 下单引用，等于股票的内部委托号')
    print(deal.m_strOrderSysID, '# str 合同编号，报单编号，委托号')
    print(deal.m_nDirection, '# int EEntrustBS，买卖方向 对于股票该值始终是48')
    print(deal.m_nOffsetFlag, '# int EOffset_Flag_Type，买卖/开平，用此字段区分股票买卖，期货开、平仓，期权买卖等')
    print(deal.m_nHedgeFlag, '# int EHedge_Flag_Type 类型，投保')
    print(deal.m_dPrice, '# float 成交均价')
    print(deal.m_nVolume, '# int 成交量，期货单位手，股票做到股')
    print(deal.m_strTradeDate, '# str 成交日期')
    print(deal.m_strTradeTime, '# str 成交时间')
    print(deal.m_dCommission, '# float 手续费 (旧版本为 m_dComission)')
    print(deal.m_dTradeAmount, '# float 成交额，期货 = 均价 * 量 * 合约乘数')
    print(deal.m_nTaskId, '# int 任务号')
    print(deal.m_nOrderPriceType, '# int EBrokerPriceType 类型，例如市价单、限价单')
    print(deal.m_strOptName, '# str 买卖标记，展示委托属性的中文')
    print(deal.m_eEntrustType, '# int EEntrustTypes，委托类别')
    print(deal.m_eFutureTradeType, '# int EFutureTradeType 类型，成交类型')
    print(deal.m_nRealOffsetFlag, '# int EOffset_Flag_Type 类型，实际开平，主要是区分平今和平昨')
    print(deal.m_eCoveredFlag, "# int ECoveredFlag类型，备兑标记 '0' - 非备兑，'1' - 备兑")
    print(deal.m_nCloseTodayVolume, '# int 平今量，不显示')
    print(deal.m_dOrderPriceRMB, '# float 委托价格（人民币），目前用于港股通')
    print(deal.m_dPriceRMB, '# float 成交价格（人民币），目前用于港股通')
    print(deal.m_dTradeAmountRMB, '# float 成交金额（人民币），目前用于港股通')
    print(deal.m_dReferenceRate, '# float 汇率，目前用于港股通')
    print(deal.m_strXTTrade, '# str 是否是迅投交易')
    print(deal.m_strCompactNo, '# str 合约编号')
    print(deal.m_dCloseProfit, '# float 平仓盈亏，目前用于外盘')
    print(deal.m_strRemark, '# str 投资备注')
    print(deal.m_strAccountKey, '# str 账号key，唯一区别不同账号的key')
    print(deal.m_nRef, '# int 订单编号')
```

### 常用查询模式

#### 查询账户可用现金

```python
def get_available_cash(account_id, account_type='stock'):
    """获取账户可用现金"""
    account = get_trade_detail_data(account_id, account_type, 'account')
    if not account:
        print("账户未连接")
        return 0
    
    # 金额单位为分，需要除以100变成元
    available = account[0].m_dAvailable / 100
    return available

# 使用
cash = get_available_cash('test')
print(f"可用现金: {cash:.2f} 元")
```

#### 查询持仓

```python
def get_holdings(account_id, account_type='stock'):
    """获取所有持仓"""
    positions = get_trade_detail_data(account_id, account_type, 'position')
    
    holdings_dict = {}
    for pos in positions:
        stock_code = f"{pos.m_strInstrumentID}.{pos.m_strExchangeID}"
        holdings_dict[stock_code] = {
            'total': pos.m_nVolume,
            'can_use': pos.m_nCanUseVolume,
            'price': pos.m_dLastPrice,
            'ProfitRate': pos.m_dProfitRate
        }
    
    return holdings_dict

# 使用
holdings = get_holdings('test')
for stock, info in holdings.items():
    print(f"{stock}: {info['total']} 股, 盈亏: {info['profit']:.2f}")
```

#### 查询最近成交

```python
def get_last_deals(account_id, count=10):
    """获取最近N笔成交记录"""
    deals = get_trade_detail_data(account_id, 'stock', 'deal')
    
    # 取最后 count 条
    recent_deals = deals[-count:] if deals else []
    
    for deal in recent_deals:
        direction = '买入' if deal.m_nTradeDir == 0 else '卖出'
        stock = f"{deal.m_strInstrumentID}.{deal.m_strExchangeID}"
        
        print(f"""
        时间: {deal.m_strTradeTime}
        品种: {stock}
        方向: {direction}
        价格: {deal.m_dTradedPrice}
        数量: {deal.m_nVolume}
        成交额: {deal.m_dTradedPrice * deal.m_nVolume:.2f}
        手续费: {deal.m_dCommission:.2f}
        """)
    
    return recent_deals
```

#### 查询待成交委托

```python
def get_pending_orders(account_id):
    """获取待成交的委托"""
    orders = get_trade_detail_data(account_id, 'stock', 'order')
    
    pending = []
    for order in orders:
        # 委托状态 1 或 2 表示未成交
        if order.m_nOrderStatus in [1, 2]:
            pending.append({
                'order_id': order.m_strOrderID,
                'stock': order.m_strInstrumentID,
                'vol': order.m_nOrderVolume,
                'price': order.m_dOrderPrice
            })
    
    return pending
```

---

## 📋 委托状态码对照表

| 状态码 | 状态名 | 说明 |
|------|--------|------|
| 0 | 未报 | 委托未发出 |
| 1 | 待报 | 正在发送委托 |
| 2 | 已报 | 委托已发送到交易所 |
| 3 | 已撤 | 委托已撤销 |
| 4 | 部成 | 委托部分成交 |
| 5 | 已成 | 委托全部成交 |
| 6 | 废单 | 委托无效（被拒绝） |
| 7 | 待撤 | 正在撤销委托 |

---

## 🚨 常见错误与解决

### 错误1：账户未连接

**症状**
```
get_trade_detail_data 返回空列表
```

**原因**
- 账户ID错误
- 账户未登录
- 账户类型不匹配

**解决**
```python
# 检查账户
account_list = get_trade_detail_data('test', 'stock', 'account')
if not account_list:
    print("账户未连接！请检查：")
    print("1. 账户ID是否正确")
    print("2. 账户是否已登录")
    print("3. 账户类型是否为 'stock'")
else:
    print(f"账户已连接，可用资金: {account_list[0].m_dAvailable}")
```

### 错误2：委托数量不是100的倍数

**症状**
```
委托返回废单
```

**原因**
- 股票必须是100股的整数倍（A股规则）

**解决**
```python
# ❌ 错误
vol = 50  # 不是100的倍数

# ✅ 正确
vol = int(cash / price / 100) * 100  # 确保是100的倍数
```

### 错误3：价格超过2%笼子

**症状**
```
实盘下单时废单
```

**原因**
- 股票价格限制：不能超过前收盘2%

**解决**
```python
# 获取前收盘和当前价
tick = C.get_full_tick([stock])
last_close = tick[stock]['lastClose']
current_price = tick[stock]['lastPrice']

# 计算价格范围
min_price = last_close * 0.98
max_price = last_close * 1.02

# 限制下单价格
if min_price <= order_price <= max_price:
    passorder(...)
else:
    print(f"价格 {order_price} 超出范围 {min_price}-{max_price}")
```

### 错误4：可用现金不足

**症状**
```
委托返回废单
```

**原因**
- 可用现金<委托金额

**解决**
```python
account = get_trade_detail_data('test', 'stock', 'account')[0]
available_cash = account.m_dAvailable

# 检查是否足够
required_cash = current_price * vol
if available_cash >= required_cash:
    passorder(...)
else:
    print(f"现金不足: 需要 {required_cash}, 可用 {available_cash}")
```

---

## 💡 最佳实践

### ✅ 下单最佳实践

```python
def safe_passorder(buy_sell, account, stock, vol, C):
    """安全的下单函数"""
    
    # 1. 检查参数
    if not account or not stock or vol < 100:
        print("参数错误")
        return False
    
    # 2. 检查账户
    account_info = get_trade_detail_data(account, 'stock', 'account')
    if not account_info:
        print("账户未连接")
        return False
    
    available_cash = account_info[0].m_dAvailable
    
    # 3. 获取行情
    tick = C.get_full_tick([stock])
    current_price = tick[stock]['lastPrice']
    
    # 4. 计算成本
    total_cost = current_price * vol
    
    # 5. 检查资金
    if available_cash < total_cost:
        print(f"资金不足: 需要 {total_cost}, 可用 {available_cash}")
        return False
    
    # 6. 下单
    msg = f"{stock} {['卖出','买入'][buy_sell==23]} {vol} 股 @ {current_price}"
    try:
        passorder(buy_sell, 1101, account, stock, 14, -1, vol, 
                  '交易策略', 0, msg, C)
        print(f"下单成功: {msg}")
        return True
    except Exception as e:
        print(f"下单异常: {e}")
        return False
```

### ❌ 常见错误

```python
# ❌ 错误1：直接下单不检查
passorder(23, 1101, account, stock, 14, -1, vol, C)

# ✅ 正确：先检查后下单
if check_before_order(account, stock, vol):
    passorder(23, 1101, account, stock, 14, -1, vol, C)

# ❌ 错误2：忽略返回值
result = passorder(...)

# ✅ 正确：检查返回值
if result:
    print("下单成功")
else:
    print("下单失败")

# ❌ 错误3：量太多一次下单
vol = 1000000  # 100万股

# ✅ 正确：分次下单
batch_size = 100000
for i in range(0, vol, batch_size):
    current_vol = min(batch_size, vol - i)
    passorder(...)
    time.sleep(1)  # 间隔下单
```

---

## 📚 相关资源

- ✅ [回测模型指南](./backtesting-guide.md) - 回测下单示例
- ✅ [实盘交易指南](./live-trading-guide.md) - 实盘下单示例
- ✅ [市场数据API](./market-data-api.md) - 行情查询

