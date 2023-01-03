# TP2 : Appréhender l'environnement Linux


# I. Service SSH


## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**

- avec une commande `systemctl status`

```
[fay@localhost ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2022-12-09 16:34:55 CET; 13min ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 875 (sshd)
    Tasks: 1 (limit: 11366)
   Memory: 3.9M
   CGroup: /system.slice/sshd.service
           └─875 /usr/sbin/sshd -D -oCiphers=aes256-gcm@openssh.com,chacha20-poly1305@open>

Dec 09 16:34:55 localhost.localdomain systemd[1]: Starting OpenSSH server daemon...
Dec 09 16:34:55 localhost.localdomain sshd[875]: Server listening on 0.0.0.0 port 22.
Dec 09 16:34:55 localhost.localdomain sshd[875]: Server listening on :: port 22.
Dec 09 16:34:55 localhost.localdomain systemd[1]: Started OpenSSH server daemon.
Dec 09 16:44:50 localhost.localdomain sshd[2191]: Accepted password for fay from 10.3.1.1 >
Dec 09 16:44:50 localhost.localdomain sshd[2191]: pam_unix(sshd:session): session opened f>
``` 

🌞 **Analyser les processus liés au service SSH**

- afficher les processus liés au service `sshd`
  - vous pouvez afficher la liste des processus en cours d'exécution avec une commande `ps`
  - pour le compte-rendu, vous devez filtrer la sortie de la commande en ajoutant `| grep <TEXTE_RECHERCHE>` après une commande

```bash
[fay@TpLinux2 ~]$ ps -el | grep sshd
4 S     0     886       1  0  80   0 - 23107 -      ?        00:00:00 sshd
4 S     0    1568     886  0  80   0 - 38385 -      ?        00:00:00 sshd
5 S  1000    1572    1568  0  80   0 - 38385 -      ?        00:00:00 sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

- avec une commande `ss`
- isolez les lignes intéressantes avec un `| grep <TEXTE>`
```
sudo ss -ltunp | grep sshd
``` 

🌞 **Consulter les logs du service SSH**

- les logs du service sont consultables avec une commande `journalctl`
```
[fay@TpLinux2 ~]$ journalctl -xe -u sshd
~
~
-- Logs begin at Fri 2022-12-09 16:58:14 CET, end at Fri 2022-12-09 17:01:48 CET. --
Dec 09 16:58:19 TpLinux2 systemd[1]: Starting OpenSSH server daemon...
-- Subject: Unit sshd.service has begun start-up
-- Defined-By: systemd
-- Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit sshd.service has begun starting up.
Dec 09 16:58:19 TpLinux2 sshd[886]: Server listening on 0.0.0.0 port 22.
Dec 09 16:58:19 TpLinux2 sshd[886]: Server listening on :: port 22.
Dec 09 16:58:19 TpLinux2 systemd[1]: Started OpenSSH server daemon.
-- Subject: Unit sshd.service has finished start-up
-- Defined-By: systemd
-- Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit sshd.service has finished starting up.
--
-- The start-up result is done.
Dec 09 16:58:56 TpLinux2 sshd[1568]: Accepted password for fay from 10.3.1.1 port 51968 ss>
Dec 09 16:58:56 TpLinux2 sshd[1568]: pam_unix(sshd:session): session opened for user fay b>
```
- un fichier de log qui répertorie toutes les tentatives de connexion SSH existe
  - il est dans le dossier 

  - utilisez une commande `tail` pour visualiser les 10 dernière lignes de ce fichier
`/var/log`
```
[fay@TpLinux2 ~]$ tail -n 10 /var/log/secure
```

## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative au protocole SSH

🌞 **Identifier le fichier de configuration du serveur SSH**
```
[fay@TpLinux2 ssh]$ ls
moduli        sshd_config             ssh_host_ed25519_key      ssh_host_rsa_key.pub
ssh_config    ssh_host_ecdsa_key      ssh_host_ed25519_key.pub
ssh_config.d  ssh_host_ecdsa_key.pub  ssh_host_rsa_key
```

Take the sshd_config corresponding to the *SERVER* config 

(ssh_config is for the *CLIENT*)



🌞 **Modifier le fichier de conf**

- exécutez un `echo $RANDOM` pour demander à votre shell de vous fournir un nombre aléatoire
```
[fay@TpLinux2 ssh]$ echo $RANDOM
8430
```
- changez le port d'écoute du serveur SSH pour qu'il écoute sur ce numéro de port
  - dans le compte-rendu je veux un `cat` du fichier de conf
  - filtré par un `| grep` pour mettre en évidence la ligne que vous avez modifié

```
[fay@TpLinux2 ssh]$ sudo cat sshd_config | grep Port
#Port 22
#GatewayPorts no
```



- gérer le firewall
  - fermer l'ancien port
```
sudo firewall-cmd --remove-port=22/tcp --permanent
```

  - ouvrir le nouveau port

```
sudo firewall-cmd --add-port=8430/tcp --permanent
```
  - vérifier avec un `firewall-cmd --list-all` que le port est bien ouvert
    - vous filtrerez la sortie de la commande avec un `| grep TEXTE`

```

[fay@TpLinux2 ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 8430/tcp
  forward-ports:
  source-ports:
```
🌞 **Redémarrer le service**

`sudo systemctl restart sshd`

🌞 **Effectuer une connexion SSH sur le nouveau port**

- depuis votre PC
- il faudra utiliser une option à la commande `ssh` pour vous connecter à la VM

```
ssh [username]@[ip-address] -p [port-number]

ssh fay@10.3.1.2 -p 8430
```

> Je vous conseille de remettre le port par défaut une fois que cette partie est terminée.

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées

![Such a hacker](./pics/such_a_hacker.png)

# II. Service HTTP


## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**

- je vous laisse faire votre recherche internet
- n'oubliez pas de préciser que c'est pour "Rocky 9"

Install the nginx package with dnf install:

```
sudo dnf install nginx
```

🌞 **Démarrer le service NGINX**

After the installation is finished, run the following commands to enable and start the web server:
```

sudo systemctl enable nginx
sudo systemctl start nginx


```


🌞 **Déterminer sur quel port tourne NGINX**


```
[fay@TpLinux2 /]$ sudo ss -alpnt | grep nginx
LISTEN 0      128          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=12440,fd=8),("nginx",pid=12439,fd=8),("nginx",pid=12438,fd=8))
LISTEN 0      128             [::]:80           [::]:*    users:(("nginx",pid=12440,fd=9),("nginx",pid=12439,fd=9),("nginx",pid=12438,fd=9))

```
- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées
- ouvrez le port concerné dans le firewall


Run the following command to permanently enable HTTP connections on port 80:
```
sudo firewall-cmd --permanent --add-service=http

sudo firewall-cmd --permanent --add-port 80/tcp
```


🌞 **Déterminer les processus liés à l'exécution de NGINX**

- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées

```
[fay@TpLinux2 /]$ ps -ef | grep nginx
root       12438       1  0 16:41 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      12439   12438  0 16:41 ?        00:00:00 nginx: worker process
nginx      12440   12438  0 16:41 ?        00:00:00 nginx: worker process
fay        12640    1614  0 17:20 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

- y'a un serveur Web qui tourne là ?
```
[fay@TpLinux2 /]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-01-02 16:41:41 CET; 4min 42s ago
  Process: 12436 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 12435 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 12433 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 12438 (nginx)
    Tasks: 3 (limit: 11366)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─12438 nginx: master process /usr/sbin/nginx
           ├─12439 nginx: worker process
           └─12440 nginx: worker process

Jan 02 16:41:41 TpLinux2 systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 02 16:41:41 TpLinux2 nginx[12435]: nginx: the configuration file /etc/nginx/nginx.conf>
Jan 02 16:41:41 TpLinux2 nginx[12435]: nginx: configuration file /etc/nginx/nginx.conf tes>
Jan 02 16:41:41 TpLinux2 systemd[1]: Started The nginx HTTP and reverse proxy server.
```
- bah... visitez le site web ?
  - ouvrez votre navigateur (sur votre PC) et visitez `http://10.3.1.2:80`
  - vous pouvez aussi (toujours sur votre PC) utiliser la commande `curl` depuis un terminal pour faire une requête HTTP
```
[fay@TpLinux2 ~]$ curl 10.3.1.2:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3429  100  3429    0     0  1674k      0 --:--:-- --:--:-- --:--:-- 3348k
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <title>Test Page for the Nginx HTTP Server on Rocky Linux</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">

```


## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

- faites un `ls -al <PATH_VERS_LE_FICHIER>` pour le compte-rendu
```
[fay@TpLinux2 ~]$ ls -al /etc/nginx/
total 84
drwxr-xr-x.  4 root root 4096 Jan  2 16:40 .
drwxr-xr-x. 81 root root 8192 Jan  2 17:32 ..
drwxr-xr-x.  2 root root    6 Jun 10  2021 conf.d
drwxr-xr-x.  2 root root    6 Jun 10  2021 default.d
-rw-r--r--.  1 root root 1077 Jun 10  2021 fastcgi.conf
-rw-r--r--.  1 root root 1077 Jun 10  2021 fastcgi.conf.default
-rw-r--r--.  1 root root 1007 Jun 10  2021 fastcgi_params
-rw-r--r--.  1 root root 1007 Jun 10  2021 fastcgi_params.default
-rw-r--r--.  1 root root 2837 Jun 10  2021 koi-utf
-rw-r--r--.  1 root root 2223 Jun 10  2021 koi-win
-rw-r--r--.  1 root root 5170 Jun 10  2021 mime.types
-rw-r--r--.  1 root root 5170 Jun 10  2021 mime.types.default
-rw-r--r--.  1 root root 2469 Jun 10  2021 nginx.conf
-rw-r--r--.  1 root root 2656 Jun 10  2021 nginx.conf.default
-rw-r--r--.  1 root root  636 Jun 10  2021 scgi_params
-rw-r--r--.  1 root root  636 Jun 10  2021 scgi_params.default
-rw-r--r--.  1 root root  664 Jun 10  2021 uwsgi_params
-rw-r--r--.  1 root root  664 Jun 10  2021 uwsgi_params.default
-rw-r--r--.  1 root root 3610 Jun 10  2021 win-utf

```
🌞 **Trouver dans le fichier de conf**

- les lignes qui permettent de faire tourner un site web d'accueil (la page moche que vous avez vu avec votre navigateur)
  - ce que vous cherchez, c'est un bloc `server { }` dans le fichier de conf

```
[fay@TpLinux2 ~]$ cat /etc/nginx/nginx.conf | grep -A 15 server
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        
        
    /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2 default_server;
#        listen       [::]:443 ssl http2 default_server;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}

```

- une ligne qui parle d'inclure d'autres fichiers de conf
```
[fay@TpLinux2 ~]$ cat /etc/nginx/nginx.conf | grep -A 15 server | grep include | head -1
        include /etc/nginx/default.d/*.conf;

```
  - bah ouais, on stocke pas toute la conf dans un seul fichier, sinon ça serait le bordel

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

- bon on est pas en cours de design ici, alors on va faire simplissime
- créer un sous-dossier dans `/var/www/`
```
    [fay@TpLinux2 var]$ sudo mkdir www
    [fay@TpLinux2 www]$ sudo mkdir tp2_linux
```

  - par convention, on stocke les sites web dans `/var/www/`
  - votre dossier doit porter le nom `tp2_linux`
- dans ce dossier `/var/www/tp2_linux`, créez un fichier `index.html`
  - il doit contenir `<h1>MEOW mon premier serveur web</h1>`
  `
  [fay@TpLinux2 /]$ sudo nano var/www/tp2_linux/index.html
  `

🌞 **Adapter la conf NGINX**

- dans le fichier de conf principal
  - vous supprimerez le bloc `server {}` repéré plus tôt pour que NGINX ne serve plus le site par défaut
  `[fay@TpLinux2 /]$ sudo nano /etc/nginx/nginx.conf
`
  - redémarrez NGINX pour que les changements prennent effet
```
[fay@TpLinux2 /]$ sudo systemctl restart nginx

```
- créez un nouveau fichier de conf

Choose Port:
```
[fay@TpLinux2 default.d]$ echo $RANDOM
12359

```

Add conf file : 

```
[fay@TpLinux2 /]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf
[sudo] password for fay:
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
        listen 12359;
        listen [::]:12359;

        root /var/www/tp2_linux;
        index index.html index.htm index.nginx-debian.html;

        server_name tp2_linux www.tp2_linux;

        location / {
                try_files $uri $uri/ =404;
        }
}


```

  - redémarrez NGINX pour que les changements prennent effet
  - le contenu doit être le suivant :

```nginx
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;

  root /var/www/tp2_linux;
}
```



restart:
```
[fay@TpLinux2 default.d]$ sudo systemctl restart nginx

```
🌞 **Visitez votre super site web**

```
[fay@TpLinux2 /]$ curl 10.3.1.2:12359
<html>
    <body>
        <h1>MEOW mon premier serveur web</h1>
    </body>
</html>

```



# III. Your own services

Dans cette partie, on va créer notre propre service :)

HE ! Vous vous souvenez de `netcat` ou `nc` ? Le ptit machin de notre premier cours de réseau ? C'EST L'HEURE DE LE RESORTIR DES PLACARDS.

## 1. Au cas où vous auriez oublié

Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre `nc` en main.

➜ Dans la VM

- `nc -l 8888`
  `[fay@TpLinux2 ~]$ nc -l 8888
ajaidz`

➜ Allumez une autre VM vite fait

- `nc <IP_PREMIERE_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens
```
[fay@TpLinux2 ~]$ nc 10.3.1.2 8888
ajaidz
```


## 2. Analyse des services existants

Un service c'est quoi concrètement ? C'est juste un processus, que le système lance, et dont il s'occupe après.

Il est défini dans un simple fichier texte, qui contient une info primordiale : la commande exécutée quand on "start" le service.

Il est possible de définir beaucoup d'autres paramètres optionnels afin que notre service s'exécute dans de bonnes conditions.

🌞 **Afficher le fichier de service SSH**

- vous pouvez obtenir son chemin avec un `systemctl status <SERVICE>`

```
[fay@TpLinux2 ~]$ sudo systemctl status sshd | head -2
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
```
- mettez en évidence la ligne qui commence par `ExecStart=`
  - encore un `cat <FICHIER> | grep <TEXTE>`
```
[fay@TpLinux2 ~]$ sudo cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
[sudo] password for fay:
ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
```
test1
```
[fay@TpLinux2 ~]$ sudo /usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
[fay@TpLinux2 ~]$
```
test2
```
[fay@TpLinux2 ~]$ sudo systemctl start sshd
[fay@TpLinux2 ~]$
```
  - c'est la ligne qui définit la commande lancée lorsqu'on "start" le service
    - taper `systemctl start <SERVICE>` ou exécuter cette commande à la main, c'est (presque) pareil

🌞 **Afficher le fichier de service NGINX**

- mettez en évidence la ligne qui commence par `ExecStart=`

```
[fay@TpLinux2 ~]$ sudo systemctl status nginx | head -2
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
```

```
[fay@TpLinux2 ~]$ sudo cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

![Create service](./pics/create_service.png)

Bon ! On va créer un petit service qui lance un `nc`. Et vous allez tout de suite voir pourquoi c'est pratique d'en faire un service et pas juste le lancer à la min.

Ca reste un truc pour s'exercer, c'pas non plus le truc le plus utile de l'année que de mettre un `nc` dans un service n_n

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

- son contenu doit être le suivant (nice & easy)

```service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l <PORT>
```
```
[fay@TpLinux2 ~]$ sudo nano /etc/systemd/system/tp2_nc.service
```

> Vous remplacerez `<PORT>` par un numéro de port random obtenu avec la même méthode que précédemment.
```
[fay@TpLinux2 ~]$ echo $RANDOM
16360
```
🌞 **Indiquer au système qu'on a modifié les fichiers de service**

- la commande c'est `sudo systemctl daemon-reload`

```
[fay@TpLinux2 ~]$ sudo systemctl daemon-reload
[fay@TpLinux2 ~]$
```

🌞 **Démarrer notre service de ouf**

- avec une commande `systemctl start`

```
[fay@TpLinux2 ~]$ systemctl start tp2_nc.service
==== AUTHENTICATING FOR org.freedesktop.systemd1.manage-units ====
Authentication is required to start 'tp2_nc.service'.
Authenticating as: fay
Password:
==== AUTHENTICATION COMPLETE ====
```

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`

```
[fay@TpLinux2 ~]$ systemctl status tp2_nc.service | head -3
● tp2_nc.service - Super netcat tout fou
   Loaded: loaded (/etc/systemd/system/tp2_nc.service; static; vendor preset: disabled)
   Active: active (running) since Mon 2023-01-02 22:42:12 CET; 52s ago
```

- vérifier que `nc` écoute bien derrière un port avec un `ss`
  - vous filtrerez avec un `| grep` la sortie de la commande pour n'afficher que les lignes intéressantes

```
[fay@TpLinux2 ~]$ systemctl status tp2_nc.service | head -3
● tp2_nc.service - Super netcat tout fou
   Loaded: loaded (/etc/systemd/system/tp2_nc.service; static; vendor preset: disabled)
   Active: active (running) since Mon 2023-01-02 22:42:12 CET; 52s ago
[fay@TpLinux2 ~]$ sudo ss -ltunp | grep nc
tcp   LISTEN 0      10           0.0.0.0:16360      0.0.0.0:*    users:(("nc",pid=1988,fd=4))
tcp   LISTEN 0      10              [::]:16360         [::]:*    users:(("nc",pid=1988,fd=3))
```
- vérifer que juste ça marche en vous connectant au service depuis une autre VM
  - allumez une autre VM vite fait et vous tapez une commande `nc` pour vous connecter à la première

```
[fay@TpLinux2 ~]$ nc 10.3.1.2 16360
jahdhjz
azdjzaiod

```

> **Normalement**, dans ce TP, vous vous connectez depuis votre PC avec un `nc` vers la VM, mais bon. Vos supers OS Windows/MacOS chient un peu sur les conventions de réseau, et ça marche pas super super en utilisant un `nc` directement sur votre machine. Donc voilà, allons au plus simple : allumez vite fait une deuxième qui servira de client pour tester la connexion à votre service `tp2_nc`.

➜ Si vous vous connectez avec le client, que vous envoyez éventuellement des messages, et que vous quittez `nc` avec un CTRL+C, alors vous pourrez constater que le service s'est stoppé

- bah oui, c'est le comportement de `nc` ça ! 
- le client se connecte, et quand il se tire, ça ferme `nc` côté serveur aussi
- faut le relancer si vous voulez retester !
```
[fay@TpLinux2 ~]$ sudo systemctl restart tp2_nc.service
[fay@TpLinux2 ~]$
```

🌞 **Les logs de votre service**

- mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !
- `sudo journalctl -xe -u tp2_nc` pour visualiser les logs de votre service
- `sudo journalctl -xe -u tp2_nc -f ` pour visualiser **en temps réel** les logs de votre service
  - `-f` comme follow (on "suit" l'arrivée des logs en temps réel)
- dans le compte-rendu je veux
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique le démarrage du service

```
[fay@TpLinux2 ~]$ sudo journalctl -xe -u tp2_nc | grep Started -A 5| head -6
Jan 02 22:42:12 TpLinux2 systemd[1]: Started Super netcat tout fou.
-- Subject: Unit tp2_nc.service has finished start-up
-- Defined-By: systemd
-- Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit tp2_nc.service has finished starting up.
```
  - une commande `journalctl` filtrée avec `grep` qui affiche un message reçu qui a été envoyé par le client

```
[fay@TpLinux2 ~]$ sudo journalctl -xe -u tp2_nc | grep zfzef -A 2| head -3
Jan 02 22:57:58 TpLinux2 nc[2044]: zfzef
Jan 02 22:58:01 TpLinux2 systemd[1]: tp2_nc.service: Succeeded.
-- Subject: Unit succeeded
```
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique l'arrêt du service

```
[fay@TpLinux2 ~]$ sudo journalctl -xe -u tp2_nc | grep Stopped -A 5| head -8
Jan 02 22:57:47 TpLinux2 systemd[1]: Stopped Super netcat tout fou.
-- Subject: Unit tp2_nc.service has finished shutting down
-- Defined-By: systemd
-- Support: https://lists.freedesktop.org/mailman/listinfo/systemd-devel
--
-- Unit tp2_nc.service has finished shutting down.
```

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine
  - comme ça, quand un client se co, puis se tire, le service se relancera tout seul
  - ajoutez `Restart=always` dans la section `[Service]` de votre service

```
[fay@TpLinux2 ~]$ sudo nano /etc/systemd/system/tp2_nc.service
```
  - n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)

```
[fay@TpLinux2 ~]$ sudo systemctl daemon-reload
```