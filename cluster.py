#!/usr/bin/python
"""
This is the most simple example to showcase Containernet.
"""
from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel
setLogLevel('info')

net = Containernet(controller=Controller)
info('*** Adding controller\n')
net.addController('c0')
info('*** Adding docker containers\n')

info('*** Adding root switch\n')
s1 = net.addSwitch('s1')

info('*** Adding left tree nodes\n')
s2 = net.addSwitch('s2')
d21 = net.addDocker('d21', ip='10.0.0.21', dimage="test2")
d22 = net.addDocker('d22', ip='10.0.0.22', dimage="test2")

info('*** Adding right tree nodes\n')
s3 = net.addSwitch('s3')
d31 = net.addDocker('d31', ip='10.0.0.31', dimage="test2")
d32 = net.addDocker('d32', ip='10.0.0.32', dimage="test2")

info('*** Creating links\n')
net.addLink(s1, s2, cls=TCLink, delay='50ms', bw=1)
net.addLink(s1, s3, cls=TCLink, delay='50ms', bw=1)

net.addLink(s2, d21, cls=TCLink, delay='10ms', bw=5)
net.addLink(s2, d22, cls=TCLink, delay='10ms', bw=5)

net.addLink(s3, d31, cls=TCLink, delay='10ms', bw=5)
net.addLink(s3, d32, cls=TCLink, delay='10ms', bw=5)


info('*** Starting network\n')
net.start()
d21.cmd('ifconfig d21-eth0 10.0.0.21')
d22.cmd('ifconfig d22-eth0 10.0.0.22')
d31.cmd('ifconfig d31-eth0 10.0.0.31')
d32.cmd('ifconfig d32-eth0 10.0.0.32')

info('*** Testing connectivity\n')
net.ping([d21, d22, d31, d32])

info('*** Setup nodes\n')
d21.cmd('export MY_ROLE="master"')

for host in net.hosts:
    host.cmd('/usr/sbin/sshd -D &')

for host in net.hosts:
    host.cmd('export HADOOP_HOSTS="10.0.0.21 master,10.0.0.22 slave22,10.0.0.31 slave31,10.0.0.32 slave32"')


for host in reversed(net.hosts):
    host.cmd('/$HADOOP_HOME/etc/hadoop/start.sh > result')

info('*** Running CLI\n')
CLI(net)
info('*** Stopping network')
net.stop()

