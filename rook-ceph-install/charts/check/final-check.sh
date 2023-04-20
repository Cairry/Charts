#!/bin/bash
#this script is used to check the rook-ceph-cluster usability
. ./config.ini

ROOK_CEPH_TOOLS_POD_NAME=`kubectl get po -n ${RookNameSpace} |grep rook-ceph-tools|awk '{print $1}'`

KUBECTL_OPTIONS=" -n ${RookNameSpace} "
CEHCK_YAML="charts/check/ceph-volume-check.yaml"

trap 'kubectl delete -f ${CEHCK_YAML} &> /dev/null &' INT

#check ceph status
echo "=============check ceph status================"
kubectl $KUBECTL_OPTIONS exec $ROOK_CEPH_TOOLS_POD_NAME -- ceph status

#check ceph rdb usage
echo "=============check ceph rdb & cephfs usage================"
kubectl get deployment -n ${RookNameSpace} | grep -q ceph-check-deployment && kubectl delete -f ${CEHCK_YAML}
kubectl create -f ${CEHCK_YAML}
while true; do
    sleep 5
    (kubectl get po |grep ceph-check-deployment- |grep -q Running && \
     kubectl get po |grep ceph-check-deployment2- |grep -q Running) && break
done
sleep 3
RDB_TEST_POD_NAME=`kubectl get po |grep ceph-check-deployment- |awk '{print $1}'`
kubectl exec -it $RDB_TEST_POD_NAME -- /bin/sh -c "df -h" |grep -E 'cephfs-check-volume|rdb-check-volume'
kubectl exec -it $RDB_TEST_POD_NAME -- /bin/sh -c "echo rdb write OK > /rdb-check-volume/rdb-test"
kubectl exec -it $RDB_TEST_POD_NAME -- /bin/sh -c "echo cephfs write OK > /cephfs-check-volume/cephfs-test"
kubectl exec -it $RDB_TEST_POD_NAME -- /bin/sh -c "head /rdb-check-volume/rdb-test" |grep "rdb write OK"
RDB_TEST_POD2_NAME=`kubectl get po |grep ceph-check-deployment2- |awk '{print $1}'`
kubectl exec -it $RDB_TEST_POD2_NAME -- /bin/sh -c "head /cephfs-check-volume/cephfs-test" |grep "cephfs write OK"

echo "=============check ceph rdb & cephfs usage suscess================"

#check object storage user case
echo "=============check object storage user case================"
kubectl $KUBECTL_OPTIONS get CephObjectStoreUser || exit 1
OBJECT_USER_NAME=`kubectl $KUBECTL_OPTIONS get CephObjectStoreUser |grep -v NAME |head -1 |awk '{print $1}'`
OBJECT_STORE_NAME=`kubectl $KUBECTL_OPTIONS get CephObjectStore |grep -v NAME |head -1 |awk '{print $1}'`
echo "=============check object user message================"
kubectl $KUBECTL_OPTIONS exec $ROOK_CEPH_TOOLS_POD_NAME  -- bash -c "radosgw-admin user info --uid=$OBJECT_USER_NAME"

echo "=============check suscess, and deleting tests================"
kubectl delete -f ${CEHCK_YAML} > /dev/null

