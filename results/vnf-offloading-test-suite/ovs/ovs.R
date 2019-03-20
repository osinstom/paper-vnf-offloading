### OVS (Kernel) ###

dat = read.csv("C:/Users/advnet-lab/Documents/P4/paper-vnf-offloading/results/test1/ovs/results.csv", header = TRUE)
dat
attach(dat)

par(mfrow=c(1,1))

barplot(Framesize, Rx.Throughput..Gbps., 
        main='Kernel OVS performance',
        xlab='Packet size [Bytes]',
        ylab='Throughput [Gbps]',
        ylim=c(0,2000),
        names = Framesize)

?plot
plot(Framesize, Rx.Throughput..fps., 
     type='b',
     main='Kernel OVS performance',
     xlab='Packet size [Bytes]',
     ylab='Throughput [Mpps]')
detach(dat)
dat_iter = read.csv("C:/Users/advnet-lab/Documents/P4/paper-vnf-offloading/results/test1/ovs/iteration.csv", header = TRUE)
dat_iter
attach(dat_iter)
Min.Latency..ns.
Max.Latency..ns.
### OVS(Kernel) + VM ###

delay_74B <- Min.Latency..ns.[Framesize == 74]
delay_128B <- Min.Latency..ns.[Framesize == 128]
delay_256B <- Min.Latency..ns.[Framesize == 256]

boxplot(Min.Latency..ns.)


### OVS-DPDK ###

### OVS-DPDK + VM

