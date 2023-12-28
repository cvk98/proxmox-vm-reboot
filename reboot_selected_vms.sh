#!/bin/bash
# Set the VMID range
START_VMID=204
END_VMID=239

# The cycle of switching off and on of each VM in a given range
for (( VMID=$START_VMID; VMID<=$END_VMID; VMID++ ))
do
  NODE=$(pvesh get /cluster/resources --type vm --output-format=json | jq --raw-output ".[] | select(.vmid == ${VMID}) | .node")

  if [ -n "$NODE" ]; then
    echo "Restarting VM with VMID: $VMID on node: $NODE"

    # Sending the shutdown command
    pvesh create /nodes/${NODE}/qemu/${VMID}/status/shutdown

    # We are waiting for the VM to stop
    while true
    do
        STATUS=$(pvesh get /nodes/${NODE}/qemu/${VMID}/status/current --output-format=json | jq --raw-output ".status")

        if [ "${STATUS}" == "stopped" ]; then
            break
        fi

        sleep 5
    done

    # Starting the VM
    pvesh create /nodes/${NODE}/qemu/${VMID}/status/start
  fi
done
