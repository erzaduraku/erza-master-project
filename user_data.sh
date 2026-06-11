set -e

echo "User Data started at $(date)" >> /var/log/user-data.log

dnf update -y
dnf install -y httpd git

cd /tmp
rm -rf webapp
git clone https://github.com/erzaduraku/group1-master-webapp webapp
cp /tmp/webapp/index.html /var/www/html/
cp /tmp/webapp/style.css /var/www/html/

chown -R apache:apache /var/www/html/
systemctl enable httpd
systemctl start httpd

echo "User Data completed at $(date)" >> /var/log/user-data.log