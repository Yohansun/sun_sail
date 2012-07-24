Coding Guide
======

1. 尽量不写重复代码
2. 用class封装一组相关工作，如 TaobaoTradePuller TaobaoTradePusher
3. 不在 json.builder 中写不同类型的逻辑，在Decotator中处理这一逻辑
4. 先不考虑权限问题
5. 在 before_save 中检查更改的字段并触发远程接口操作
6. 需要筛选的field使用 as 定义，如：field :tid, type: String,       as: :order_id