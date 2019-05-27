function wait_ssh {
WAITIME=0
while true; do
if $(echo "sven" >/dev/tcp/$1/22) &>/dev/null; then
break
else
VMNAME=$(echo $1 |grep -oE 'director|classroom')
rht-vmctl start ${VMNAME}
[[ $WAITIME-gt 300 ]] && break
fi
sleep 60
WAITIME=$(expr $WAITIME + 5 )
done
}
echo y |rht-vmctl reset classroom
wait_ssh classroom
echo y |rht-vmctl reset all
htpasswd -bc /content/courses/do407/ansible2.3/materials/httpd.htpasswd ansi ansible
cat > /content/courses/do407/ansible2.3/materials/httpd.htacess <<EOF
AuthType "Basic"
AuthName "Password Required"
AuthUserFile "/var/www/html/protected/.htpasswd"
Require valid-user
EOF
echo block > /content/courses/do407/ansible2.3/materials/inaccess.html
wget -P /etc/yum.repos.d/ http://172.25.254.254/content/courses/do407/ansible2.3/materials/ansible.repo
yum -y install ansible >/dev/null
ansible-galaxy init examfun
cat >> examfun/vars/main.yml <<EOF
staff:
   -su1
   -su2
guests:
   -sg1
   -sg2
webclients:
    -sw1
    -sw2
EOF
tar -czf /content/courses/do407/ansible2.3/materials/do407fun.tar.gz examfun
zip -e -P drone /content/courses/do407/ansible2.3/materials/vault.zip anaconda-ks.cfg
for i in server{a..d} workstation; do
  wait_ssh $i
  ssh root@$i "useradd -G wheel ansible && echo redhat | passwd --stdin ansible"
ssh root@$i "sed -i '/^%wheel/s/ALL$/NOPASSWD: ALL/' /etc/sudoers"
done
ssh root@workstation "mkdir ~ansible/.ssh \
&& cp .ssh/{config,lab_rsa} ~ansible/.ssh \
&& chown -R ansible:ansible ~ansible/.ssh && chmod 700 ~ansible/.ssh"
ssh root@workstation "mkdir -p /opt/ansible/inventory \
&& wget -O /opt/ansible/inventory/dynamic http://materials/dynamic/inventoryw.py"
ssh root@workstation 'echo -e "#!/bin/bash\ntouch file" > /usr/local/bin/runme.sh'
ssh root@workstation "echo ans > /var/tmp/ans.txt"
ssh ansible@workstation