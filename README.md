check_public_IP.sh is to get user public IP, check_tor_exit_node.sh is to get tor exit node.

check_tor_exit_node.sh should be run after 'sudo service tor start'.

Prerequisites:

1.install libnotify-bin;

2.install proxychains4;

3.install whois;

4.one should install country flags and insert the path to flags directory in lines 22,28,33.

Sometimes requests to ifconfig.me is blocked; one may substitute ifconfig.me to ip.me in line 19 in both files.
