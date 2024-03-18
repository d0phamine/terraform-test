#cloud-config
package_update: true
packages:
  - ${webserver}
runcmd:
  - echo "<h2>Bye Bye ${f_name} ${l_name}</h2>" > /var/www/html/index.html
  - echo "%{ for name in names ~} <p>Hello to ${name} from ${f_name}</p><br> %{ endfor ~}" >> /var/www/html/index.html
  - echo "<h2>Hello world ${f_name}</h2>" >> /var/www/html/index.html
  - sudo service apache2 start
  - sudo chkconfig apache2 on
