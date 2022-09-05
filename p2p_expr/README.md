# Transmission

## setup

https://stackoverflow.com/questions/18936994/transmission-remote-commands-are-erroring-with-unexpected-response-h1401-una

## use transmission
https://github.com/ashmckenzie/percheron-torrent/blob/b93a1a1df5614d448ec6880777a4fa7a1aa1d504/seeder/bin/seed.sh
https://antrikshy.com/code/seeding-torrents-using-transmission-cli

# create and seed torrent
https://superuser.com/questions/1687624/how-to-create-and-seed-new-torrent-files-for-bittorrent-using-transmisson-client

https://www.mankier.com/1/transmission-create


# Deluge
run deluge console https://github.com/tardfree/docker-deluge/blob/22487ccd42f4838a51847007d082e337d36a5cbf/apprun.sh


## install package 

snap install aria2c
apt-get install transmission-cli transmission-daemon


## setup sudo access

sudo update-alternatives --config editor


jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/run_p2p_seeder.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/run_p2p_leecher.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/p2p_seeder_cleanup.sh
jethros ALL = (ALL) NOPASSWD: /home/jethros/dev/pvn/utils/p2p_expr/p2p_leecher_cleanup.sh
