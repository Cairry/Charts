<!--
 * @Author: Xuan.Zu
 * @Email: xuan.zu@js.design
 * @Date: 2023-02-27 18:00:08
 * @Description:
-->
# 安装Loki

# 字段描述
| 字段 | 描述 | 默认值 |
| -- | -- | -- |
| test_pod.image | 测试 pod 镜像 | `registry.js.design/grafana/bats/bats:v1.1.0` |
| test_pod.pullPolicy | 镜像拉取策略 | `IfNotPresent` |
| loki.enabled | 是否安装loki | `true` |
| loki.storage.max_look_back_period | 限制查询数据的时间 | `0` |
| loki.storage.retention_period | 存储保留时间 | `168h` |
| loki.storage.retention_deletes_enabled | 打开存储保留时间开关 | `true` |
| loki.storage.type | 日志存储类型,支持`filesystem`,`s3` | `filesystem` |
| loki.storage.s3 | s3 存储的url | `nil` |
| loki.image.repository | 镜像名称 | `registry.js.design/grafana/loki`|
| loki.image.tag| 镜像tag|`2.6.1`|
| loki.image.pullPolicy|镜像拉取策略 | `IfNotPresent` |
| loki.uri | Loki url | |
| loki.readinessProbe | 就绪探针| |
| loki.livenessProbe | 存活探针 | |
| loki.persistence.enabled | 是否应用持久化存储pvc | `true` |
| loki.persistence.storageClassName | 动态sc name | `local-path` |
| loki.persistence.existingClaim | 使用已存在的pvc | |
| promtail.enabled | 是否安装promtail | `true` |
| promtail.image.registry | 仓库名称 | `registry.js.design` |
| promtail.image.repository | 镜像名称 | `grafana/promtail`|
| promtail.image.tag | 标签名称 | `2.6.1`|
| promtail.image.pullPolicy | 拉取策略 | `IfNotPresent` |
| promtail.defaultVolumes | 本地挂载点 |`{}` |
| promtail.defaultVolumeMounts|容器挂载点| `{}`|
| promtail.config.logLevel | log 类型 | `info` |
| promtail.config.serverPort | 服务端口 | `3101` |
| promtail.config.client.url | loki 接口 | |

# 安装
```
# ls
charts  Chart.yaml  README.md  requirements.lock  requirements.yaml  templates  values.yaml

# helm install -f values.yaml loki .
NAME: loki
LAST DEPLOYED: Wed Mar  1 18:42:16 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
The Loki stack has been deployed to your cluster. Loki can now be added as a datasource in Grafana.

See http://docs.grafana.org/features/datasources/loki/ for more detail.

# kubectl get po
loki-0                                             1/1     Running     0          3m40s
loki-promtail-sfgpn                                1/1     Running     0          3m40s

# kubectl get svc
loki                              ClusterIP   10.109.212.34   <none>        3100/TCP            81s
loki-headless                     ClusterIP   None            <none>        3100/TCP            81s
loki-memberlist                   ClusterIP   None            <none>        7946/TCP            81s
```


# Loki-Stack Helm Chart

## Prerequisites

Make sure you have Helm [installed](https://helm.sh/docs/using_helm/#installing-helm).

## Get Repo Info

```console
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Deploy Loki and Promtail to your cluster

### Deploy with default config

```bash
helm upgrade --install loki grafana/loki-stack
```

### Deploy in a custom namespace

```bash
helm upgrade --install loki --namespace=loki-stack grafana/loki-stack
```

### Deploy with custom config

```bash
helm upgrade --install loki grafana/loki-stack --set "key1=val1,key2=val2,..."
```

## Deploy Loki and Fluent Bit to your cluster

```bash
helm upgrade --install loki grafana/loki-stack \
    --set fluent-bit.enabled=true,promtail.enabled=false
```

## Deploy Grafana to your cluster

The chart loki-stack contains a pre-configured Grafana, simply use `--set grafana.enabled=true`

To get the admin password for the Grafana pod, run the following command:

```bash
kubectl get secret --namespace <YOUR-NAMESPACE> loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

To access the Grafana UI, run the following command:

```bash
kubectl port-forward --namespace <YOUR-NAMESPACE> service/loki-grafana 3000:80
```

Navigate to <http://localhost:3000> and login with `admin` and the password output above.
Then follow the [instructions for adding the loki datasource](https://grafana.com/docs/grafana/latest/datasources/loki/), using the URL `http://loki:3100/`.

## Upgrade
### Version >= 2.8.0
Provide support configurable datasource urls [#1374](https://github.com/grafana/helm-charts/pull/1374)

### Version >= 2.7.0
Update promtail dependency to ^6.2.3 [#1692](https://github.com/grafana/helm-charts/pull/1692)

### Version >=2.6.0
Bumped grafana 8.1.6->8.3.4 [#1013](https://github.com/grafana/helm-charts/pull/1013)