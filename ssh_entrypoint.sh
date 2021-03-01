#!/bin/bash
# Author: Ivan Do
#

# =============================== ==============================
# Text colors
C_RESET=" \e[1;0m "
C_BLACK=" -e \e[1;30m "
C_RED=" -e \e[1;31m "
C_GREEN=" -e \e[1;32m "
C_YELLOW=" -e \e[1;33m "
C_BLUE=" -e \e[1;34m "
C_MAGENTA=" -e \e[1;35m "
C_CYAN=" -e \e[1;36m "
C_WHITE=" -e \e[1;37m "

# Background colors
B_RESET=" \e[1;0m "
B_BLACK=" -e \e[1;40m "
B_RED=" -e \e[1;41m "
B_GREEN=" -e \e[1;42m "
B_YELLOW=" -e \e[1;43m "
B_BLUE=" -e \e[1;44m "
B_MAGENTA=" -e \e[1;45m "
B_CYAN=" -e \e[1;46m "
B_WHITE=" -e \e[1;47m "
# =============================================================================


echo "starting ssh as root"
gosu root service ssh start &
#gosu root /usr/sbin/sshd -D &

echo "starting tail user"
exec gosu jenkins tail -f /dev/null


