<!--
 * @Author: Xuan.Zu
 * @Email: xuan.zu@js.design
 * @Date: 2023-02-10 12:06:15
 * @Description: 
-->
# 简介
公司在架构层面想做一些列的优化达到一定的数据量的支撑，由此在与其他 MQ 做了一些列的对比发现RocketMQ更加适合公司的业务，并且Rocket相比较于其他的MQ更加牛逼，因此对RocketMQ做了相关的调研，以及高可用架构的方案实施，发现官方并没有做相应的 Helm Chart，只有二进制、Docker部署，为了减少在生产应用后的维护成本，决定自己来维护一个 Chart，也锻炼写Chart的能力，其实RocketMQ 的chart写起来蛮简单的，涉及的复杂层面几乎没有，直接堆就完了。

# 安装手册
> 主要需要三台节点来组成 Dleger 集群，且不能三个节点都运行到同一个Node上。
## 获取项目
```
# git clone https://github.com/Cairry/Charts.git
# cd rocketmq-dleger
```
## 准备目录并授权角色
```
## 创建组
groupadd rocketmq
## 增加用户并加入组
useradd -g rocketmq rocketmq
## 设置用户密码
echo "jsdesign" | passwd --stdin rocketmq
## 更改组的 gid
groupmod -g 3000 rocketmq
## 更改用户的 uid
usermod -u 3000 rocketmq
## 查看是否更改成功
id rocketmq
## 
chown rocketmq:rocketmq -R /opt/rocketmq
```
## 安装应用
```
# helm upgrade -i -f values.yaml rocketmq .

# kubectl get po | grep rocketmq
rocketmq-broker-0                                  1/1     Running   0          14m
rocketmq-broker-1                                  1/1     Running   0          21m
rocketmq-broker-2                                  1/1     Running   0          21m
rocketmq-console-67d5778f8-svmdk                   1/1     Running   0          21m
rocketmq-console-67d5778f8-vljj8                   1/1     Running   0          21m
rocketmq-console-67d5778f8-zkcjn                   1/1     Running   0          21m
rocketmq-namesrv-0                                 1/1     Running   0          21m
rocketmq-namesrv-1                                 1/1     Running   0          21m
rocketmq-namesrv-2                                 1/1     Running   0          21m
```