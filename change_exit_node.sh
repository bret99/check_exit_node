#!/bin/bash

cd /path_to_dir_with_exit_node_change.py/
sudo python3 exit_node_change.py
sudo service tor restart
notify-send -t 2000 "Restarting tor..."
