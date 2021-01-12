#Управляющие переменные:
#  TARGET - имя хоста.
#  TUSER - имя пользователя
#  TKEY - путь к файлу с ключом для логина
#  TPORT - ключ -P и порт для соединения, например "-P 2222", или пусто, если порт по умолчанию.

TARGET=${TARGET:-wb6}
TUSER=${TUSER:-root}
TKEY=${TKEY:-"/home/ivan/my/sshkeys/zynq_root/id_rsa.ppk"}
