helm -n rook-ceph uninstall rook-ceph-cluster rook-operator;
kubectl get po -n rook-ceph --no-headers | awk '{print $1}' | xargs -i kubectl delete po -n rook-ceph {}
while kubectl get po -n rook-ceph --no-headers | wc -l;do
    if [[ ${kubectl get po -n rook-ceph --no-headers | wc -l} -ne 0 ]];then
        echo "[WARN]: 等待 Pod 删除";
        sleep 10;
    fi
    break
done
find /var/lib/kubelet -name "*rook*" | xargs rm -rf;
rm -rf /data/ceph;
kubectl delete cephclusters -n rook-ceph rook-ceph
kubectl delete ns rook-ceph --force;
kubectl label no $(kubectl get no --no-headers | awk '{print $1}') role-