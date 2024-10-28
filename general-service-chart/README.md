
### Global parameters

| Name                                   | Description      | Value     |
| -------------------------------------- | ---------------- | --------- |
| `image`                                | 镜像名称           | `""`     |
| `imageTag`                             | 镜像 Tag          | `""`     |
| `imagePullSecrets`                     | 镜像拉取密钥       | `""`      |
| `imagePullPolicy`                      | 镜像拉取策略       | `""`          |
| `nameOverride`                         | 名称覆盖           | `""`          |
| `fullnameOverride`                     | 全名称覆盖         | `""`          |
| `ControllerType`                       | 控制器类型         | `""`          |
| `replicas`                             | 副本数            | `""`          |
| `resources`                            | 资源限制           | `""`         |
| `nodeSelector`                         | 节点调度             | `""`          |
| `tolerations`                          | 污点容忍             | `""`          |
| `podAntiAffinityEnabled`               | 亲和性               | `""`          |
| `command`                              | 命令                 | `""`          |
| `envs`                                 | 环境变量             | `""`          |
| `podManagementPolicy`                  | 未知策略              | `""`          |

### 探针类

| Name                                   | Description      | Value     |
| -------------------------------------- | ---------------- | --------- |
| `healthCheck.port`                     | 探针端口           | `""`        |
| `healthCheck.livenessProbe.enabled`    | 是否开启探针        | `""`          |
| `healthCheck.livenessProbe.path`       | 探针路径             | `""``""`              |
| `healthCheck.livenessProbe.config.initialDelaySeconds`| 初始延迟秒数, k8s默认值为0，最小为0| `""`  |
| `healthCheck.livenessProbe.config.timeoutSeconds`| 检测超时，k8s默认值1，最小为1  | `""`   |
| `healthCheck.livenessProbe.config.periodSeconds`| 检测周期，k8s默认值10，最小为1  | `""`   |
| `healthCheck.livenessProbe.config.successThreshold`| 失败后成功次数，k8s默认值1，最小为1，只能设置为1 | `""`  |
| `healthCheck.livenessProbe.config.failureThreshold`| 失败后重试次数，k8s默认值3，最小为1  | `""`   |


### 存储类
| Name                                   | Description      | Value     |
| -------------------------------------- | ---------------- | --------- |
| `volumesConfigure.enabled`             | 开启持久化存储     | `""`          |
| `volumesConfigure.volumeMounts.config` | 挂载名称 (名称可自定义) |  `""`       |
| `volumesConfigure.volumeMounts.config.mountPath` | 容器挂载点 |   `""`      |
| `volumesConfigure.volumeMounts.config.subPath` | 容器子路径挂载 |  `""`       |
| `volumesConfigure.volumeMounts.config.readOnly` | 只读挂载 | `""`        |
| `volumesConfigure.volumes.config` | 挂载名称 (名称可自定义, 需要和 volumesConfigure.volumeMounts.config 名称对应) | `""`        |
| `volumesConfigure.volumes.config.configMap` | configMap 挂载方式 | `""`        |
| `volumesConfigure.volumes.config.configMap.name` | configMap 名称 | `""`        |
| `volumesConfigure.volumeClaimTemplates.enabled` | 开启 StatefulSet 持久化特性 | `""`        |
| `volumesConfigure.volumeClaimTemplates.name` | 挂载名称 | `""`        |
| `volumesConfigure.volumeClaimTemplates.accessModes` | 访问模式 |  `""`       |
| `volumesConfigure.volumeClaimTemplates.storageClassName` | CSI 名称 | `""`        |
| `volumesConfigure.volumeClaimTemplates.requestSize` | 存储请求大小 | `""`        |

### 配置挂载

| Name                                   | Description      | Value     |
| -------------------------------------- | ---------------- | --------- |
| `configMap.enabled` | 开启 configmap | `""`        |
| `configMap.data` | configmap data 下的数据内容 | `""`        |

### 服务发现

| Name                                   | Description      | Value     |
| -------------------------------------- | ---------------- | --------- |
| `services.enabled`                     | 开启 SVC | `""`        |
| `services.annotations`                 | SVC 注解 |  `""`       |
| `services.type`                        | SVC 暴露类型 |   `""`      |
| `services.ports`                       | SVC 端口暴露 |  `""`       |
| `ingress.enabled`                      | 开启 Ingress |  `""`       |
| `ingress.annotations`                  | Ingress 注解 |   `""`      |
| `ingress.defaultRules`                 | 开启默认路由 |  `""`       |
| `ingress.hostname`                     | 默认路由域名 |  `""`       |
| `ingress.hostname`                     | 默认路由路径 | `""`        |
| `ingress.extraPaths`                   | 自定义路径 |  `""`       |
| `ingress.extraPaths`                   | 自定义路由 |   `""`      |
| `ingress.tls.enabled`                  | 开启 TLS |  `""`       |
| `ingress.tls.extraTls`                  | TLS 配置 |   `""`      |