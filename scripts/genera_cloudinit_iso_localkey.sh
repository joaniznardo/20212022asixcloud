#!/bin/bash
# from: https://gist.github.com/leogallego/a614c61457ed22cb1d960b32de4a1b01

## ATENCIÓ: invocar amb "bash genera_cloudinit_iso_localkey.sh" 

#
# genera la iso de cloud-init i incorpora les claus públiques de github del compte COMPTE: obligatori canviar-lo; 
# 
export CLAU=~/.ssh/id_rsa3
export PUBLICA=$CLAU.pub

if [ -f "$PUBLICA" ]; 
  then 
    echo "clau pública existent";
  else 
    echo "generant clau publica";
    ssh-keygen -q -t rsa -f "$CLAU" -C "generada automaticament; fer backup" -N "";
fi
CLAUPUBLICA=$(cat $PUBLICA);  
   

export VERSIO=01
export COMPTE=alumne

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
    passwd: $6$p7eIF8oeovbO$FYmQletmACF4GWkiiheknPG0MZEJHUyuBLOlc9oYgAzXDnCCDgjM6bBVsTUQVqbzFcprYUiL9GzHHMt5U0D9s0
    lock_passwd: false
    shell: /bin/bash
    ssh_pwauth: False
    chpasswd: { expire: False }
    gecos: ${COMPTE}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, adm
    ssh_authorized_keys:
      - ${CLAUPUBLICA}
chpasswd:
  list: |
    ${COMPTE}${VERSIO}:test01
  expire: False


package_update: true
runcmd:
 - [ apt, install, language-pack-ca* ]
 - [ locale-gen, ca_ES.UTF-8 ]
 - [ localectl, set-locale, LANG=ca_ES.UTF-8 ]
 - [ localectl, set-x11-keymap, es, cat ]
 - [ localectl, set-keymap, es-cat ]
 - [ systemctl, restart, console-setup.service ]
power_state:
  delay: now
  mode: reboot
  message: Bye Bye
  timeout: 30
  condition: True
EOF

seed_iso="my-seed.iso"
cloud-localds -v "$seed_iso" user-data meta-data

