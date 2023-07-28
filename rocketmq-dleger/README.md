<!--
 * @Author: Xuan.Zu
 * @Email: xuan.zu@js.design
 * @Date: 2023-02-10 12:06:15
 * @Description:
-->

# 简介

公司在架构层面想做一些列的优化达到一定的数据量的支撑，由此在与其他 MQ 做了一些列的对比发现 RocketMQ 更加适合公司的业务，并且 Rocket 相比较于其他的 MQ 更加牛逼，因此对 RocketMQ 做了相关的调研，以及高可用架构的方案实施，发现官方并没有做相应的 Helm Chart，只有二进制、Docker 部署，为了减少在生产应用后的维护成本，决定自己来维护一个 Chart，也锻炼写 Chart 的能力，其实 RocketMQ 的 chart 写起来蛮简单的，涉及的复杂层面几乎没有，直接堆就完了。

# 安装手册

> 主要需要三台节点来组成 Dleger 集群，broker Pod 不能调度到同一台节点上。

## 部署前置操作

> 修改 CoreDNS 配置容器 hosts 全局解析

```
        // 添加如下配置
        hosts {
          192.168.1.176 rocketmq-namesrv-0
          192.168.1.177 rocketmq-namesrv-1
          192.168.1.178 rocketmq-namesrv-2
          fallthrough	// 必须添加，否则影响解析
        }
```

> 重启 CoreDNS Pod

## 获取项目

```
# git clone https://github.com/Cairry/Charts.git
# cd rocketmq-dleger
```

## 安装应用

```
# helm upgrade -i -f values.yaml rocketmq .

# kubectl get po | grep rocketmq
rocketmq-broker-0                  2/2     Running   0          115s
rocketmq-broker-1                  2/2     Running   0          135s
rocketmq-broker-2                  2/2     Running   0          155s
rocketmq-console-b9f5b9b75-bgxms   1/1     Running   0          115s
rocketmq-console-b9f5b9b75-fm74c   1/1     Running   0          115s
rocketmq-console-b9f5b9b75-jnmp4   1/1     Running   0          115s
rocketmq-namesrv-0                 1/1     Running   0          115s
rocketmq-namesrv-1                 1/1     Running   0          95s
rocketmq-namesrv-2                 1/1     Running   0          77s

# kubectl get svc
NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                           AGE
rocketmq-broker-0           NodePort    10.233.12.39    <none>        10910:42920/TCP,20910:42910/TCP,42908:53111/TCP   14m
rocketmq-broker-1           NodePort    10.233.49.249   <none>        10910:42921/TCP,20910:42911/TCP,42908:49458/TCP   14m
rocketmq-broker-2           NodePort    10.233.37.160   <none>        10910:42922/TCP,20910:42912/TCP,42908:52440/TCP   14m
rocketmq-broker-metrics     ClusterIP   10.233.6.40     <none>        5557/TCP                                          14m
rocketmq-console            NodePort    10.233.54.32    <none>        8080:28080/TCP                                    14m
rocketmq-namesrv-0          NodePort    10.233.26.43    <none>        9876:29870/TCP                                    14m
rocketmq-namesrv-1          NodePort    10.233.46.239   <none>        9876:29871/TCP                                    14m
rocketmq-namesrv-2          NodePort    10.233.48.19    <none>        9876:29872/TCP                                    14m
rocketmq-namesrv-headless   ClusterIP   None            <none>        9876/TCP                                          14m
```

## 访问控制台

`http://${IP}:28080`

## 生产消费测试

```
# 终端一（生产）
[root@rocketmq-broker-0 bin]# export NAMESRV_ADDR=rocketmq-namesrv-headless:9876
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
[root@rocketmq-broker-0 bin]# export NAMESRV_ADDR=rocketmq-namesrv-headless:9876
[root@rocketmq-broker-0 bin]# ./tools.sh org.apache.rocketmq.example.quickstart.Consumer
···
ConsumeMessageThread_please_rename_unique_group_name_4_2 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=239, sysFlag=0, bornTimestamp=1683856120619, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120619, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000381E2, commitLogOffset=229858, bodyCRC=2109456513, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E72B03BE, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 53, 56], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_5 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=238, sysFlag=0, bornTimestamp=1683856120605, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120606, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F0000000000037E22, commitLogOffset=228898, bodyCRC=1947045034, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E71D03BA, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 53, 52], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_9 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=232, sysFlag=0, bornTimestamp=1683856120588, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120588, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000367A2, commitLogOffset=223138, bodyCRC=624619317, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E70C03A2, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 51, 48], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_10 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=231, sysFlag=0, bornTimestamp=1683856120585, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120585, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000363E2, commitLogOffset=222178, bodyCRC=1430420289, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E709039E, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 50, 54], transactionId='null'}]]
ConsumeMessageThread_please_rename_unique_group_name_4_6 Receive New Messages: [MessageExt [brokerName=broker-dledger, queueId=2, storeSize=192, queueOffset=228, sysFlag=0, bornTimestamp=1683856120577, bornHost=/10.233.64.116:60786, storeTimestamp=1683856120578, storeHost=/10.233.64.116:12911, msgId=0AE940740000326F00000000000358A2, commitLogOffset=219298, bodyCRC=274811310, reconsumeTimes=0, preparedTransactionOffset=0, toString()=Message{topic='TopicTest', flag=0, properties={MIN_OFFSET=0, MAX_OFFSET=250, CONSUME_START_TIME=1683856126496, UNIQ_KEY=7F00000100C43F99BD523AC0E7010392, CLUSTER=DefaultCluster, TAGS=TagA}, body=[72, 101, 108, 108, 111, 32, 82, 111, 99, 107, 101, 116, 77, 81, 32, 57, 49, 52], transactionId='null'}]]
```

## 程序客户端连接

> 由于是本地开发环境需要在本地修改 hosts 解析到相关域名，如果是 k8s 集群内部则不需要该操作，因为前面修改过 CoreDNS 全局解析。

```
$ sudo vi /etc/hosts
192.168.1.176 rocketmq-namesrv-0 rocketmq-broker-0
192.168.1.177 rocketmq-namesrv-1 rocketmq-broker-1
192.168.1.178 rocketmq-namesrv-2 rocketmq-broker-2
```

运行程序

```
package main

import (
	"context"
	"fmt"
	"os"

	"github.com/apache/rocketmq-client-go/v2"
	"github.com/apache/rocketmq-client-go/v2/admin"
	"github.com/apache/rocketmq-client-go/v2/consumer"
	"github.com/apache/rocketmq-client-go/v2/primitive"
	"github.com/apache/rocketmq-client-go/v2/producer"
)

var (
	hostPoint = []string{"192.168.1.176:29870","192.168.1.177:29871","192.168.1.178:29872"}
)

func main() {
	// 1. 创建主题，这一步可以省略，在send的时候如果没有topic，也会进行创建。
	CreateTopic("testTopic01")
	// 2.生产者向主题中发送消息
	SendSyncMessage("hello world2022send test ，rocketmq go client!  too，是的")
	// 3.消费者订阅主题并消费
	SubcribeMessage()
}

func CreateTopic(topicName string) {
	endPoint := hostPoint
	// 创建主题
	testAdmin, err := admin.NewAdmin(admin.WithResolver(primitive.NewPassthroughResolver(endPoint)))
	if err != nil {
		fmt.Printf("connection error: %s\n", err.Error())
	}
	err = testAdmin.CreateTopic(context.Background(), admin.WithTopicCreate(topicName))
	if err != nil {
		fmt.Printf("createTopic error: %s\n", err.Error())
	}
}

func SendSyncMessage(message string) {
	// 发送消息
	endPoint := hostPoint
	// 创建一个producer实例
	p, _ := rocketmq.NewProducer(
		producer.WithNameServer(endPoint),
		producer.WithRetry(2),
		producer.WithGroupName("ProducerGroupName"),
	)
	// 启动
	err := p.Start()
	if err != nil {
		fmt.Printf("start producer error: %s", err.Error())
		os.Exit(1)
	}

	// 发送消息
	result, err := p.SendSync(context.Background(), &primitive.Message{
		Topic: "testTopic01",
		Body:  []byte(message),
	})

	if err != nil {
		fmt.Printf("send message error: %s\n", err.Error())
	} else {
		fmt.Printf("send message seccess: result=%s\n", result.String())
	}
}

func SubcribeMessage() {
	// 订阅主题、消费
	endPoint := hostPoint
	// 创建一个consumer实例
	c, err := rocketmq.NewPushConsumer(consumer.WithNameServer(endPoint),
		consumer.WithConsumerModel(consumer.Clustering),
		consumer.WithGroupName("ConsumerGroupName"),
	)

	// 订阅topic
	err = c.Subscribe("testTopic01", consumer.MessageSelector{}, func(ctx context.Context, msgs ...*primitive.MessageExt) (consumer.ConsumeResult, error) {
		for i := range msgs {
			fmt.Printf("subscribe callback : %v \n", msgs[i])
		}
		return consumer.ConsumeSuccess, nil
	})

	if err != nil {
		fmt.Printf("subscribe message error: %s\n", err.Error())
	}

	// 启动consumer
	err = c.Start()

	if err != nil {
		fmt.Printf("consumer start error: %s\n", err.Error())
		os.Exit(-1)
	}

	err = c.Shutdown()
	if err != nil {
		fmt.Printf("shutdown Consumer error: %s\n", err.Error())
	}
}
```

返回

```
INFO[0000] the MessageQueue changed, version also updated  changeTo=1684321477905051000 changedFrom=1684321477851802000
INFO[0000] The PullThresholdForTopic is changed          changeTo=5120 changedFrom=25600
INFO[0000] The PullThresholdSizeForTopic is changed      changeTo=2560 changedFrom=12800
INFO[0000] push consumer close pullConsumer listener.    consumerGroup=ConsumerGroupName
INFO[0000] push consumer quit pullMessage for dropped queue.  consumerGroup=ConsumerGroupName
INFO[0000] push consumer quit pullMessage for dropped queue.  consumerGroup=ConsumerGroupName
INFO[0000] push consumer quit pullMessage for dropped queue.  consumerGroup=ConsumerGroupName
INFO[0000] update offset to broker success               MessageQueue="MessageQueue [topic=testTopic01, brokerName=broker-dledger, queueId=2]" consumerGroup=ConsumerGroupName offset=0
INFO[0000] push consumer quit pullMessage for dropped queue.  consumerGroup=ConsumerGroupName
INFO[0000] push consumer quit pullMessage for dropped queue.  consumerGroup=ConsumerGroupName
INFO[0000] update offset to broker success               MessageQueue="MessageQueue [topic=testTopic01, brokerName=broker-dledger, queueId=3]" consumerGroup=ConsumerGroupName offset=0
INFO[0000] update offset to broker success               MessageQueue="MessageQueue [topic=%RETRY%ConsumerGroupName, brokerName=broker-dledger, queueId=0]" consumerGroup=ConsumerGroupName offset=0
INFO[0000] update offset to broker success               MessageQueue="MessageQueue [topic=testTopic01, brokerName=broker-dledger, queueId=0]" consumerGroup=ConsumerGroupName offset=0
INFO[0000] update offset to broker success               MessageQueue="MessageQueue [topic=testTopic01, brokerName=broker-dledger, queueId=1]" consumerGroup=ConsumerGroupName offset=2

```
