# Transmission

## setup

https://stackoverflow.com/questions/18936994/transmission-remote-commands-are-erroring-with-unexpected-response-h1401-una

## port:
```bash
sudo iptables -I INPUT -p tcp --dport 9000 -j ACCEPT
sudo ufw allow out 9000/tcp
```
https://superuser.com/questions/1084173/port-forwarding-transmission-torrent-client
https://askubuntu.com/questions/104477/why-isnt-transmission-working


## use transmission
https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
https://antrikshy.com/code/seeding-torrents-using-transmission-cli

## create and seed torrent
https://superuser.com/questions/1687624/how-to-create-and-seed-new-torrent-files-for-bittorrent-using-transmisson-client

https://www.mankier.com/1/transmission-create


## Error to fix
```
Sep 06 02:40:56 bt1 transmission-daemon[17559]: [2022-09-06 02:40:56.221] p2p_core_3_image_12.img Tracker error: "Tracker gave HTTP response code 0
Sep 06 02:40:57 bt1 transmission-daemon[17559]: [2022-09-06 02:40:57.220] p2p_core_3_image_7.img Tracker error: "Tracker gave HTTP response code 0
```

https://dietpi.com/forum/t/transmission-port-closed/13544/11


# Deluge
run deluge console https://github.com/tardfree/docker-deluge/blob/22487ccd42f4838a51847007d082e337d36a5cbf/apprun.sh


## install package 
```bash
snap install aria2c
apt-get install transmission-cli transmission-daemon
```


## setup sudo access
```bash
sudo update-alternatives --config editor
```


jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/run_p2p_seeder.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/run_p2p_leecher.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/p2p_seeder_cleanup.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/p2p_leecher_cleanup.sh
