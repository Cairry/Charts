<!--
 * @Author: Xuan.Zu
 * @Email: xuan.zu@js.design
 * @Date: 2023-02-10 12:06:15
 * @Description:
-->
# 简介
公司在架构层面想做一些列的优化达到一定的数据量的支撑，由此在与其他 MQ 做了一些列的对比发现RocketMQ更加适合公司的业务，并且Rocket相比较于其他的MQ更加牛逼，因此对RocketMQ做了相关的调研，以及高可用架构的方案实施，发现官方并没有做相应的 Helm Chart，只有二进制、Docker部署，为了减少在生产应用后的维护成本，决定自己来维护一个 Chart，也锻炼写Chart的能力，其实RocketMQ 的chart写起来蛮简单的，涉及的复杂层面几乎没有，直接堆就完了。

# 安装手册
> 主要需要三台节点来组成 Dleger 集群，broker Pod 不能调度到同一台节点上。
## 获取项目
```
# git clone https://github.com/Cairry/Charts.git
# cd rocketmq-dleger
```
## 安装应用
> 由于服务启动顺序问题，broker服务需要重启2次后可正常Running，proxy服务需要等重启4次后可正常Running，如果超过这个次数说明服务有问题，再进一步排查。
```
# helm upgrade -i -f values.yaml rocketmq .

# kubectl get po | grep rocketmq
rocketmq-broker-0                  2/2     Running   2          115s
rocketmq-broker-1                  2/2     Running   2          135s
rocketmq-broker-2                  2/2     Running   2          155s
rocketmq-console-b9f5b9b75-bgxms   1/1     Running   0          115s
rocketmq-console-b9f5b9b75-fm74c   1/1     Running   0          115s
rocketmq-console-b9f5b9b75-jnmp4   1/1     Running   0          115s
rocketmq-namesrv-0                 1/1     Running   0          115s
rocketmq-namesrv-1                 1/1     Running   0          95s
rocketmq-namesrv-2                 1/1     Running   0          77s
rocketmq-proxy-c4f58c74d-bk5h9     1/1     Running   4          115s
rocketmq-proxy-c4f58c74d-gmn4d     0/1     Running   4          115s
rocketmq-proxy-c4f58c74d-jwzb6     1/1     Running   4          115s
```
## 访问控制台
`http://${IP}:27726`

## 生产消费测试
```
# 终端一（生产）
[root@rocketmq-broker-0 bin]# export NAMESRV_ADDR=rocketmq-proxy:9888
[root@rocketmq-broker-0 bin]# ./tools.sh org.apache.rocketmq.example.quickstart.Producer
···
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E74D03DD, offsetMsgId=0AE940740000326F0000000000039EF2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=1], queueOffset=247]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E74E03DE, offsetMsgId=0AE940740000326F0000000000039FE2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=2], queueOffset=247]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E74E03DF, offsetMsgId=0AE940740000326F000000000003A0D2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=3], queueOffset=247]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E74F03E0, offsetMsgId=0AE940740000326F000000000003A1C2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=0], queueOffset=248]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75003E1, offsetMsgId=0AE940740000326F000000000003A2B2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=1], queueOffset=248]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75103E2, offsetMsgId=0AE940740000326F000000000003A3A2, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=2], queueOffset=248]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75103E3, offsetMsgId=0AE940740000326F000000000003A492, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=3], queueOffset=248]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75203E4, offsetMsgId=0AE940740000326F000000000003A582, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=0], queueOffset=249]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75303E5, offsetMsgId=0AE940740000326F000000000003A672, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=1], queueOffset=249]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75303E6, offsetMsgId=0AE940740000326F000000000003A762, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=2], queueOffset=249]
SendResult [sendStatus=SEND_OK, msgId=7F00000100C43F99BD523AC0E75403E7, offsetMsgId=0AE940740000326F000000000003A852, messageQueue=MessageQueue [topic=TopicTest, brokerName=broker-dledger, queueId=3], queueOffset=249]
09:48:40.669 [NettyClientSelector_1] INFO RocketmqRemoting - closeChannel: close the connection to remote address[10.233.18.181:9888] result: true
09:48:40.672 [NettyClientSelector_1] INFO RocketmqRemoting - closeChannel: close the connection to remote address[10.233.18.181:9888] result: true
09:48:40.673 [NettyClientSelector_1] INFO RocketmqRemoting - closeChannel: close the connection to remote address[10.233.64.116:12911] result: true

# 终端二（消费）
[root@rocketmq-broker-0 bin]# export NAMESRV_ADDR=rocketmq-proxy:9888
[root@rocketmq-broker-0 bin]# ./tools.sh org.apache.rocketmq.example.quickstart.Consumer
···
ConsumeMessageThread_please_rename_unique_group_name_4_2 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=239, sysFlag=0, bornTimestamp=1683856120619, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120619, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000381E2, commitLogOffset=229858, bodyCRC=2109456513, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E72B03BE, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 53, 56], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_5 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=238, sysFlag=0, bornTimestamp=1683856120605, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120606, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F0000000000037E22, commitLogOffset=228898, bodyCRC=1947045034, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E71D03BA, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 53, 52], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_9 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=232, sysFlag=0, bornTimestamp=1683856120588, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120588, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000367A2, commitLogOffset=223138, bodyCRC=624619317, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E70C03A2, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 51, 48], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_10 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=231, sysFlag=0, bornTimestamp=1683856120585, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120585, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000363E2, commitLogOffset=222178, bodyCRC=1430420289, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E709039E, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 50, 54], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_6 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=228, sysFlag=0, bornTimestamp=1683856120577, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120578, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000358A2, commitLogOffset=219298, bodyCRC=274811310, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E7010392, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 49, 52], transactionId='null'}]]
```