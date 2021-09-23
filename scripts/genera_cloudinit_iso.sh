#!/bin/bash
# from: https://gist.github.com/leogallego/a614c61457ed22cb1d960b32de4a1b01


#
# genera la iso de cloud-init i incorpora les claus públiques de github del compte COMPTE: obligatori canviar-lo; 
# 

export VERSIO=01
export COMPTE=changemetelopidoporfavor

## meta-data
cat > meta-data <<EOF
instance-id: ubuntucloud-${VERSIO}
local-hostname: ubuntucloud${VERSIO}

EOF



## user-data
## contrassenya - test01 - $6$BndxC7Cu7Wu6u5I$GYGFvut8456DzNiQ2q2ZRhxyXSsTUvvQeWZ10imo3asAu7nFEGz0JjD.ZdqB16U3CdSuk9YhlxnapKE5kOBrm0 - mkpasswd --method=SHA-512 -s
## antiga - passwd: $6$p7eIF8oeovbO$FYmQletmACF4GWkiiheknPG0MZEJHUyuBLOlc9oYgAzXDnCCDgjM6bBVsTUQVqbzFcprYUiL9GzHHMt5U0D9s0
## openssl password -6
## no xuta la contrassenya sense el canvi - queda pendent de provar amb cometes simples

cat > user-data <<EOF
#cloud-config
users:
  - default
  - name: ${COMPTE}${VERSIO}
    passwd: test01
    lock_passwd: false
    shell: /bin/bash
    ssh_pwauth: False
    chpasswd: { expire: False }
    gecos: ${COMPTE}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, adm
    ssh_import_id: gh:${COMPTE}

chpasswd:
  list: |
    ${COMPTE}${VERSIO}:test01
  expire: False
EOF


seed_iso="my-seed.iso"
cloud-localds -v "$seed_iso" user-data meta-data
