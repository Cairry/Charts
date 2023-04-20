#!/bin/bash
. ./config.ini
ROOT_DIR="$(dirname $(readlink -f ${0}))"
implementyaml="values-produce.yaml" ##定义helm install -f的yaml文件
rook_ceph_operarot_path="$ROOT_DIR/charts/rook-operator"
rook_ceph_cluster_path="$ROOT_DIR/charts/rook-ceph-cluster"
Node_Labels_State=""

function main() {

	label_execution
	install_operator
	check_operator
	install_cluster
	check_cluster
	check_provisioner

}

# 输出颜色字体
function green_echo () {
    local what=$*
    echo -e "\e[1;32m[SUCC]: ${what} \e[0m"
}

function yellow_echo () {
    local what=$*
    echo -e "\e[1;33m[WARN]: ${what} \e[0m"
}

function red_echo () {
    local what=$*
    echo -e "\e[1;31m[ERROR]: ${what} \e[0m"
    exit 1
}

function label_execution () {
    for node in ${OSDNodeList}; do
        Node_Labels_State=($(kubectl get nodes -o=jsonpath='{.items[*].metadata.name}'))
        if [[ "${Node_Labels_State[*]}" == ${OSDNodeList[*]} ]]; then

            if [[ $(expr ${#OSDNodeList[@]} % 2) -eq 1 ]]; then
                kubectl label nodes ${node} ${LabelsKey}=${LabelsValue} --overwrite &> /dev/null
            else
                red_echo "部署的 OSD 节点不是奇数!"
            fi

        else
            red_echo "${LabelsKey}=${LabelsValue} 标签与配置"${ProjectDir}/config/hosts.ini"不符"
        fi
    done
}


function install_operator () {

	green_echo "部署 Operator"

    C1=$(Helm_Check rook-operator &> /dev/null && echo $? || echo $?)
	C2=$(kubectl get deployment --all-namespaces |grep rook-ceph-operator &> /dev/null && echo $? || echo $?)

	kubeletDirPath=$(df -h | grep kubelet | awk '{print $NF}' | awk -F 'pods' '{print $1}' | tail -n 1)
	[[ ${kubeletDirPath} == " " ]] && {
		red_echo "kubelet 默认路径获取失败!"
		exit 1
	}
	export kubeletDirPath=${kubeletDirPath%/}
	if [[ $C1 -eq 0 ]] || [[ $C2 -eq 0 ]]; then
	    red_echo "已存在rook-operator无法进行安装!"
	else
        ## 安装APP
		envsubst < $rook_ceph_operarot_path/${implementyaml} | helm upgrade -i -f - -n ${RookNameSpace} rook-operator $rook_ceph_operarot_path

        [[ $? -ne 0 ]] && {
            red_echo "Ceph Operator 安装失败!"
            exit 1
        }
    fi

}

function check_operator () {

	cmd="kubectl get pod -n ${RookNameSpace} | grep rook-ceph-operator|grep -i Running |grep -i 1/1"

    pod_status="$(eval ${cmd})"
    if [[ -z $pod_status ]]; then
        while [[ "$(kubectl get pod -n ${RookNameSpace} | grep rook-ceph-operator | wc -l)" != 1 ]]; do
            yellow_echo "正在等待 rook-operator Running"
            sleep 10
        done

	else
		pod_status="$(eval ${cmd})"
        w2=$(echo "$pod_status" | awk '{print $5}' | tr -d '[0-9][0-9]')
        if [[ "$w2" == "s" ||  "$w2" == "S" ]]; then
            while [[ "$(echo "$pod_status" | awk '{print $5}' | grep -i s | tr -d s)" -lt 60 ]]; do
                yellow_echo "给予 rook-operator 数据处理时间, 大于 1m 后即可完成"
                sleep 10
            done
        fi
    fi

}

function install_cluster () {

	green_echo "部署 Ceph 集群"

	C3=$(Helm_Check rook-ceph-cluster > /dev/null && echo $? || echo $?)
	C4=$(kubectl get pod --all-namespaces | grep rook-ceph-osd-[0-9] > /dev/null && echo $? || echo $?)

	export CephPath=$(echo ${CephPath})
    export replica=$(echo ${#OSDNodeList[@]})

    if [[ $C3 -eq 0 ]] || [[ $C4 -eq 0 ]]; then
        red_echo "已存在rook-cluster无法进行安装"
    else
        if [[ $replica -eq 1 ]];then
			sed -i "s#antiAffinity: true#antiAffinity: false#" $rook_ceph_cluster_path/${implementyaml} ##修改亲和配置
		fi

		# 获取cephMonitors-IP
		Iplist=($(kubectl get nodes ${OSDNodeList} -o wide --show-labels | grep ${LabelsKey}=${LabelsValue} | awk '{print $6}'))
		Iplist=$(printf '%s:6789,' "${Iplist[@]}")
		export MonIplist=${Iplist%,}

		# 判断mon地址是否生成
		[[ ${MonIplist} == "" ]] && {
			red_echo "Mon 地址池为空!"
			exit 1
		}
		envsubst < $rook_ceph_cluster_path/${implementyaml} | helm upgrade -i -f - -n ${RookNameSpace} rook-ceph-cluster $rook_ceph_cluster_path
        if [[ $? -ne 0 ]]; then
            red_echo "helm instll rook_ceph_cluster fail"
            exit 4
        fi
    fi

}

function check_cluster () {

	local Check1=false
	local Check2=false
	local Check3=false

	while [[ ${Check1} != true ]];do
		local PodName=(
			"rook-ceph-osd-[0-9]"
			"rook-ceph-rgw-"
		)
		for i in ${PodName[@]};do
			CephFocusPodState="kubectl get po -n ${RookNameSpace} |grep -E "${i}"|grep -i Running |grep 1/1|wc -l"
			[[ $(eval ${CephFocusPodState}) -ne ${replica} ]] && {
				yellow_echo "Check 1: 等待「${i}」Pod 启动!"
				sleep 30
				kubectl get po -n ${RookNameSpace} |grep -E "${i}"
			} || {
				green_echo "" $(eval ${CephFocusPodState})
				Check1=true
			}
		done
	done

	while [[ ${Check2} != true ]];do
		CephClusterHealthState="kubectl exec -it -n ${RookNameSpace} $(kubectl get po -n ${RookNameSpace} | grep "rook-ceph-tools-" | awk '{print $1}')  -- ceph health | tr -d '\r'"
		[[ $(eval ${CephClusterHealthState}) != "HEALTH_OK" ]] && {
			yellow_echo "Check 2: 正在检查 Ceph 集群状态"
			sleep 30
		} || {
			green_echo "" $(eval ${CephClusterHealthState})
			Check2=true
		}
	done

	while [[ ${Check3} != true ]];do
		CephCheckJobState="kubectl get po -n ${RookNameSpace} |grep  "ceph-check-job-"|grep -i Completed |grep 0/1|wc -l"
		[[ $(eval ${CephCheckJobState}) -ne 1 ]] && {
			echo -e  "\033[33mCehck 3: 正在检查 ceph-check-job是否执行结束\033[0m"
			sleep 15
		} || {
			cmd="kubectl get po -n ${RookNameSpace}  |grep ceph-check-job|awk '{print $1}' |xargs kubectl logs --tail 3 -n ${RookNameSpace}"
			green_echo "" $(eval ${cmd})
			Check3=true
		}
	done

	[[ ${Check1} && ${Check2} && ${Check3} == true ]] && {
		green_echo "Check 通过!"
		break
	}

}

function check_provisioner () {

	CephfsStatus=$(kubectl exec -it -n ${RookNameSpace} $(kubectl get po -n ${RookNameSpace} |grep "rook-ceph-tools-" |awk '{print $1}') -- ceph fs status &> /dev/null && echo $? || echo $?)
    if [[ ${CephfsStatus} -eq 0 ]]; then
        bash $ROOT_DIR/charts/check/final-check.sh
        if [[ $? -eq 0 ]]; then
            green_echo "已完成 Rook-Ceph 所有组件部署并且通过测试"
        else
            exit 4
        fi
    fi

}


main $@