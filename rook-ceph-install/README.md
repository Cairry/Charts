# FileStore存储模式
## 修改配置
```
# vi ./config.ini
# 名称空间
RookNameSpace='rook-ceph'
# 添加Ceph osd 节点，每个osd节点对应一个mgr、mon节点等
OSDNodeList=(
    node1
    node2
    node3
)
# 存储目录
CephPath="/data/ceph/data"
# 节点标签，用于调度到指定的服务器上
LabelsKey="role"
LabelsValue="storage-node"
```
## 安装服务
```
# bash install.sh
```
### 测试存储可用性
```
NameSpace=rook-ceph
token=$(kubectl -n rook-ceph get secret rook-ceph-admin-keyring -o yaml|grep keyring:|awk '{print $2}'|xargs echo |base64 -d|grep "key ="|awk '{print $3}')
echo $token >/tmp/mon-key.txt
    MONIPLIST=($(kubectl get nodes -o wide --show-labels |grep role=storage-node|awk '{print $6}'))
    MONIPLIST=$(printf '%s:6789,' "${MONIPLIST[@]}")
    MONIPLIST=${MONIPLIST%,}
    echo $MONIPLIST >/tmp/mon.txt
token=$(cat /tmp/mon-key.txt)
cephadd=$(cat /tmp/mon.txt)
mkdir   /ceph/volumes -p
mount -t ceph  -o name=admin,secret=$token $cephadd:/ /ceph/volumes
```
## 清除服务
> 会清除所有数据，包括本地存储目录下数据以及标签等
```
# bash reset.sh
```
