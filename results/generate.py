import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
plt.style.use('seaborn-paper')

# data = np.genfromtxt('vnf-offloading-test-suite/ovs/results.csv', delimiter=',')
data_ovs_kernel = pd.read_csv("vnf-offloading-test-suite/ovs/results.csv")
data_ovs_dpdk = pd.read_csv("vnf-offloading-test-suite/ovs-dpdk/PHY-OVS-PHY-2-RX-QUEUE/results.csv")
data_ovs_dpdk_1rx = pd.read_csv("vnf-offloading-test-suite/ovs-dpdk/PHY-OVS-PHY-1-RX-QUEUE/results.csv")
data_vm = pd.read_csv("vnf-offloading-test-suite/ovs-dpdk-PHY-VM-PHY/testpmd/results.csv")
data_docker = pd.read_csv("vnf-offloading-test-suite/ovs-dpdk-PHY-Docker-PHY/first-trial-1Core-cross-NUMA/results.csv")
xticks = data_ovs_kernel['Framesize']

fig, ax = plt.subplots()
ax.set_title('XX')
ax.minorticks_on()
ax.set_xlabel('Packet size [B]')
ax.set_ylabel('Throughput [Gbps]')
plt.xticks(data_ovs_kernel['Framesize'])
ax.plot(xticks, data_ovs_kernel['Rx Throughput (Gbps)'], linewidth=3, marker='o', label='OVS (Kernel)')
ax.plot(data_ovs_dpdk['Framesize'], data_ovs_dpdk['Rx Throughput (Gbps)'], linewidth=3, marker='o', label='OVS DPDK')
ax.plot(xticks, data_ovs_dpdk_1rx['Rx Throughput (Gbps)'], linewidth=3, marker='o', label='OVS DPDK (1 RX)')
ax.plot(xticks, data_vm['Rx Throughput (Gbps)'], linewidth=3, marker='o', label='PHY-VM-PHY (OVS-DPDK)')
ax.plot(xticks, data_docker['Rx Throughput (Gbps)'], linewidth=3, marker='o', label='PHY-Docker-PHY (OVS-DPDK)')

# ax.plot(x1, y1, color='red', linewidth=3, marker='o')
# ax1.set_facecolor('tab:gray')
ax.grid(linestyle='--')
ax.legend(loc='upper left')

plt.show()