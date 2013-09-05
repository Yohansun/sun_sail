## 部署自动执行更新的rake脚本.

* 所有需要部署自动执行的放入 `lib/tasks/magic_order` 文件中. 格式如下.

* 注意新建的rake文件中任务必须加上 `namespace :magic_order` 文件名必须是任务的名. 加上namespace的格式为 `rake magic_order:foo`

        namespace :magic_order
          task :foo => :environment do
            ...
          end
        end