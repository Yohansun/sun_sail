系统优化
=======================

--------------------
* **一键开始** 关于同步的放在一个类里面,  使用 `third_party_sync` 同步某个平台,比如:

        class TaobaoSync > BaseSync
          include TaobaoProductsSync
          include TaobaoRefundsSync
          # ....
        
          def processes(gp,items)
            send(":processes_#{gp}",items)
          end
          
          def process(gp,item)
            send(:"process_#{gp}",item)
          end
        end
        
        module TaobaoProductsSync
          def self.included(base)
            base.class_eval do
              group :taobao_products do
                options do |option|
                  option[:batch] = true
                  option[:total_page] = Proc.new {|response| response['total_page']}
                  # ....
                end
                # .....
              end
            end
          end
        
          def processes_taobao_products(items)
            TaobaoProduct.create_or_update(items)
          end
        end
        
        # 一键开始使用同步所有淘宝数据
        TaobaoSync.new(trade_source).sync
        # 指定部分内容同步
        TaobaoSync.new(trade_source).sync(only: [:taobao_products,:skus])