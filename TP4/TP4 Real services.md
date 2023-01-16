# TP4 : Real services

Dans ce TP4, on va s'approcher de plus en plus vers de la gestion de serveur, commen on le fait dans le monde réel.


Notes:
*logique s'oppose a physique en info*
*pomme -> compote ; 
compote /3 = pomme /3*
*PV -> VG -> LV*
*ide slower than sata*

Le but de ce TP :

➜ **monter un serveur de stockage** VM `storage.tp4.linux`

- le serveur de stockage possède une partition dédiée
- sur cette partition, plusieurs dossiers sont créés
- chaque dossier contient un site web
- ces dossiers sont partagés à travers le réseau pour rendre leur contenu disponible à notre serveur web

➜ **monter un serveur web** VM `web.tp4.linux`

- il accueillera deux sites web
- il ne sera (malheureusement) pas publié sur internet : c'est juste une VM
- les sites web sont stockés sur le serveur de stockage, le serveur web y accède à travers le réseau

---

➜ Plutôt que de monter des petits services de test, ou analyser les services déjà existants sur la machine, on va donc passer à l'étape supérieure et **monter des trucs vraiment utilisés dans le monde réel** :)

Rien de sorcier cela dit, et **à la fin vous aurez appris à monter un petit serveur Web.** Ce serait exactement la même chose si vous voulez publier un site web, et que vous voulez gérer vous-mêmes le serveur Web.

**Le serveur de stockage** c'est pour rendre le truc un peu plus fun (oui j'ai osé dire *fun*), et voir un service de plus, qui est utilisé dans le monde réel. En plus, il est parfaitement adapté pour pratiquer et s'exercer sur le partitionnement de façon pertinente.

➜ On aura besoin de deux VMs dans ce TP : 🖥️ **VM `web.tp4.linux`** et 🖥️ **VM `storage.tp4.linux`**.

> Pour une meilleure lisibilité, j'ai éclaté le TP en 3 parties.

## Checklist

![Checklist](./pics/checklist_is_here.jpg)

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux activé en mode *"permissive"* (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b1-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

## Sommaire

- [Partie 1 : Partitionnement du serveur de stockage](./part1/README.md)
- [Partie 2 : Serveur de partage de fichiers](./part2/README.md)
- [Partie 3 : Serveur web](./part3/README.md)

![glhf](./pics/glhf.png)

# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.

➜ **Ajouter un disque dur de 2G à la VM**


**Allons !**

![Part please](../pics/part_please.jpg)

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM

```
[fay@storage ~]$ lsblk
NAME        MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda           8:0    0  20G  0 disk
├─sda1        8:1    0   1G  0 part /boot
└─sda2        8:2    0  19G  0 part
  ├─rl-root 253:0    0  17G  0 lvm  /
  └─rl-swap 253:1    0   2G  0 lvm  [SWAP]
sdb           8:16   0   2G  0 disk
```
- créer un nouveau *volume group (VG)*
```
[fay@storage ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               rl
  PV Size               <19.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              4863
  Free PE               0
  Allocated PE          4863
  PV UUID               da3bUB-0gQn-KKTs-OzBt-QkAn-nqAO-60yoUW

  "/dev/sdb" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               SGZ8BZ-l8SV-OORx-v0vR-v92l-eTIV-iIzgcv
```
- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable
  - elle doit être dans le VG `storage`
  - elle doit occuper tout l'espace libre

```
[fay@storage ~]$ sudo lvcreate -l 100%FREE storage -n arthur
  Logical volume "arthur" created.

```

🌞 **Formater la partition**

- vous formaterez la partition en ext4 (avec une commande `mkfs`)

```
[fay@storage ~]$ sudo mkfs -t ext4 /dev/storage/arthur

mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: ddf7fd7d-f7ab-4280-b9e8-ddebf2fb7081
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
  - le chemin de la partition, vous pouvez le visualiser avec la commande `lvdisplay`

```
[fay@storage ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/storage/arthur
  LV Name                arthur
  VG Name                storage
  LV UUID                8UlJqJ-X2p1-f62Z-bwdF-bQpo-UHAO-p2j5Mo
  LV Write Access        read/write
  LV Creation host, time storage, 2023-01-10 16:55:48 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```


🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/storage`

```
[fay@storage ~]$ sudo mount /dev/storage/arthur /mnt/storage/
```
  - preuve avec une commande `df -h` que la partition est bien montée

```
[fay@storage ~]$ df -h | grep arthur

/dev/mapper/storage-arthur  2.0G   24K  1.9G   1% /mnt/storage
```

  - prouvez que vous pouvez lire et écrire des données sur cette partition

```
[fay@storage /]$ sudo vgdisplay | grep Access
  VG Access             read/write
  VG Access             read/write
```

- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement

Ok ! Za, z'est fait. On a un espace de stockage dédié pour stocker nos sites web.

**Passons à [la partie 2 : installation du serveur de partage de fichiers](./../part2/README.md).**

# Partie 2 : Serveur de partage de fichiers

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/files1/`
  - `/storage/files2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/files1/` est monté dans `/var/www/files1/`
  - le dossier `/storage/files2/` est monté dans `/var/www/files2/`

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

## Step 1: make the share directory
```
    sudo mkdir /var/nfs/general -p
```
## Step 2: Rights of folder
```
    ls -dl /var/nfs/general
    
    sudo chown nobody /var/nfs/general
```
## Step 3 — Configuring the NFS Exports on the Host Server


``` 
sudo nano /etc/exports

/var/nfs/general    10.3.1.2(rw,sync,no_subtree_check)
/home               10.3.1.2(rw,sync,no_root_squash,no_subtree_check)
``` 

## Step 4 Start Service NFS:

``` 
[fay@storage /]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: dis>
  Drop-In: /run/systemd/generkator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Mon 2023-01-16 15:56:25 CET; 9s ago
   
``` 

## Step 5: Firewall settings  

```
[fay@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
Warning: ALREADY_ENABLED: nfs
success
[fay@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[fay@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[fay@storage ~]$ sudo firewall-cmd --reload
success
```  
 
 ```
 [fay@storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client http mountd nfs rpc-bind ssh
  ```
 ## Step 6:  Creating Mount Points and Mounting Directories on the Client
 
 
```
sudo mkdir -p /nfs/general
sudo mkdir -p /nfs/home
```
  
### Mount:
```
sudo mount storage:/var/nfs/general /nfs/general
sudo mount storage:/home /nfs/home
```

### Verif:
```
fay@web ~]$ df -h
Filesystem                Size  Used Avail Use% Mounted on
devtmpfs                  889M     0  889M   0% /dev
tmpfs                     907M     0  907M   0% /dev/shm
tmpfs                     907M  8.6M  898M   1% /run
tmpfs                     907M     0  907M   0% /sys/fs/cgroup
/dev/mapper/rl-root        17G  2.2G   15G  13% /
/dev/sda1                1014M  255M  760M  26% /boot
tmpfs                     182M     0  182M   0% /run/user/1000
storage:/var/nfs/general   17G  2.2G   15G  13% /nfs/general
storage:/home              17G  2.2G   15G  13% /nfs/home
```

## Step 6 — Testing NFS Access

```
[fay@web ~]$ sudo touch /nfs/general/general.test
[fay@web ~]$ ls -l /nfs/general/general.test
-rw-r--r--. 1 nobody nobody 0 Jan 16 17:12 /nfs/general/general.test
```

```
    ls -l /nfs/home/home.test

Output
-rw-r--r--. 1 root root 0 Aug  8 18:26 /nfs/home/home.test
```

## mount boot (fstab file content)

```
...
storage/var/nfs/general    /nfs/general   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
storage:/home               /nfs/home      nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

### umount

```
cd ~
sudo umount /nfs/home
sudo umount /nfs/general
```

### Verif umount

```
df -h
```

```
[fay@web ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             889M     0  889M   0% /dev
tmpfs                907M     0  907M   0% /dev/shm
tmpfs                907M  8.5M  898M   1% /run
tmpfs                907M     0  907M   0% /sys/fs/cgroup
/dev/mapper/rl-root   17G  2.2G   15G  13% /
/dev/sda1           1014M  255M  760M  26% /boot
tmpfs                182M     0  182M   0% /run/user/1000
```
- contenu du fichier `/etc/exports` dans le compte-rendu notamment

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

> Je vous laisse vous inspirer de docs sur internet **[comme celle-ci](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9)** pour mettre en place un serveur NFS.

# Partie 3 : Serveur web

- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)

## 1. Intro NGINX

![gnignigggnnninx ?](../pics/ngnggngngggninx.jpg)

**NGINX (prononcé "engine-X") est un serveur web.** C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.

Un serveur web, c'est un programme qui écoute sur un port et qui attend des requêtes HTTP. Quand il reçoit une requête de la part d'un client, il renvoie une réponse HTTP qui contient le plus souvent de l'HTML, du CSS et du JS.

> Une requête HTTP c'est par exemple `GET /index.html` qui veut dire "donne moi le fichier `index.html` qui est stocké sur le serveur". Le serveur renverra alors le contenu de ce fichier `index.html`.

Ici on va pas DU TOUT s'attarder sur la partie dév web étou, une simple page HTML fera l'affaire.

Une fois le serveur web NGINX installé (grâce à un paquet), sont créés sur la machine :

- **un service** (un fichier `.service`)
  - on pourra interagir avec le service à l'aide de `systemctl`
- **des fichiers de conf**
  - comme d'hab c'est dans `/etc/` la conf
  - comme d'hab c'est bien rangé, donc la conf de NGINX c'est dans `/etc/nginx/`
  - question de simplicité en terme de nommage, le fichier de conf principal c'est `/etc/nginx/nginx.conf`
- **une racine web**
  - c'est un dossier dans lequel un site est stocké
  - c'est à dire là où se trouvent tous les fichiers PHP, HTML, CSS, JS, etc du site
  - ce dossier et tout son contenu doivent appartenir à l'utilisateur qui lance le service
- **des logs**
  - tant que le service a pas trop tourné c'est empty
  - les fichiers de logs sont dans `/var/log/`
  - comme d'hab c'est bien rangé donc c'est dans `/var/log/nginx/`
  - on peut aussi consulter certains logs avec `sudo journalctl -xe -u nginx`

> Chaque log est à sa place, on ne trouve pas la même chose dans chaque fichier ou la commande `journalctl`. La commande `journalctl` vous permettra de repérer les erreurs que vous glisser dans les fichiers de conf et qui empêche le démarrage correct de NGINX.

## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**

- installez juste NGINX (avec un `dnf install`) et passez à la suite
- référez-vous à des docs en ligne si besoin

## 3. Analyse

Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.

Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

```
[fay@web ~]$ sudo systemctl status nginx
[sudo] password for fay:
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-01-16 16:16:30 CET; 1h 11min ago
  Process: 923 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 915 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 911 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 930 (nginx)
    Tasks: 3 (limit: 11366)
   Memory: 13.6M
   CGroup: /system.slice/nginx.service
           ├─930 nginx: master process /usr/sbin/nginx
           ├─932 nginx: worker process
           └─933 nginx: worker process

Jan 16 16:16:30 web systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 16:16:30 web nginx[915]: nginx: the configuration file /etc/nginx/nginx.conf syntax>
Jan 16 16:16:30 web nginx[915]: nginx: configuration file /etc/nginx/nginx.conf test is su>
Jan 16 16:16:30 web systemd[1]: nginx.service: Failed to parse PID from file /run/nginx.pi>
Jan 16 16:16:30 web systemd[1]: Started The nginx HTTP and reverse proxy server.
```

🌞 **Analysez le service NGINX**

- avec une commande `ps`, déterminer sous quel utilisateur tourne le processus du service NGINX
  - utilisez un `| grep` pour isoler les lignes intéressantes

```
[fay@web ~]$ ps -ef | grep nginx | head -3
root         930       1  0 16:16 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        932     930  0 16:16 ?        00:00:00 nginx: worker process
nginx        933     930  0 16:16 ?        00:00:00 nginx: worker process
[fay@web ~]$
```
- avec une commande `ss`, déterminer derrière quel port écoute actuellement le serveur web
  - utilisez un `| grep` pour isoler les lignes intéressantes

```
[fay@web log]$ sudo ss -lnp | grep nginx
tcp   LISTEN 0      128                                                  0.0.0.0:12359             0.0.0.0:*     users:(("nginx",pid=1918,fd=8),("nginx",pid=1917,fd=8),("nginx",pid=1916,fd=8))
tcp   LISTEN 0      128                                                     [::]:12359              [::]:*     users:(("nginx",pid=1918,fd=9),("nginx",pid=1917,fd=9),("nginx",pid=1916,fd=9))****
```


- en regardant la conf, déterminer dans quel dossier se trouve la racine web
  - utilisez un `| grep` pour isoler les lignes intéressantes

fichier conf nginx custom server web : 

```
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

- inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus
  - ça va se faire avec un `ls` et les options appropriées

```
[fay@web /]$ cd var/www/
[fay@web www]$ ls -al
total 8
drwxr-xr-x.  5 root root   69 Jan 16 15:25 .
drwxr-xr-x. 22 root root 4096 Jan  2 18:06 ..
drwxr-xr-x.  2 root root    6 Jan 16 15:25 files1
drwxr-xr-x.  2 root root    6 Jan 16 15:25 files2
-rw-r--r--.  1 root root   38 Jan  2 18:50 index.html
drwxr-xr-x.  2 root root   24 Jan  2 20:50 tp2_linux
[fay@web www]$

```

## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

- vous avez reperé avec `ss` dans la partie d'avant le port à ouvrir

```
[fay@web ~]$ sudo firewall-cmd --add-port=12359/tcp --permanent
Warning: ALREADY_ENABLED: 12359:tcp
success

[fay@web ~]$ sudo firewall-cmd
--permanent
--add-services=http 

```

🌞 **Accéder au site web**

- avec votre navigateur sur VOTRE PC
  - ouvrez le navigateur vers l'URL : `http://<IP_VM>:<PORT>`
- vous pouvez aussi effectuer des requêtes HTTP depuis le terminal, plutôt qu'avec un navigateur
  - ça se fait avec la commande `curl`
  - et c'est ça que je veux dans le compte-rendu, pas de screen du navigateur :)


```
[fay@web ~]$ curl http://10.3.1.2:12359
<html>
    <body>
        <h1>MEOW mon premier serveur web</h1>
    </body>
</html>
```

> Si le port c'est 80, alors c'est la convention pour HTTP. Ainsi, il est inutile de le préciser dans l'URL, le navigateur le fait de lui-même. On peut juste saisir `http://<IP_VM>`.

🌞 **Vérifier les logs d'accès**

- trouvez le fichier qui contient les logs d'accès, dans le dossier `/var/log`
- les logs d'accès, c'est votre serveur web qui enregistre chaque requête qu'il a reçu
- c'est juste un fichier texte
- affichez les 3 dernières lignes des logs d'accès dans le contenu rendu, avec une commande `tail`

```
[fay@web log]$ sudo cat nginx/access.log | tail -3
10.3.1.2 - - [02/Jan/2023:20:51:14 +0100] "GET / HTTP/1.1" 200 235 "-" "curl/7.61.1" "-"
10.3.1.2 - - [02/Jan/2023:20:53:27 +0100] "GET / HTTP/1.1" 200 84 "-" "curl/7.61.1" "-"
10.3.1.2 - - [16/Jan/2023:17:46:14 +0100] "GET / HTTP/1.1" 200 84 "-" "curl/7.61.1" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

- une simple ligne à modifier, vous me la montrerez dans le compte rendu
  - faites écouter NGINX sur le port 8080

```
[fay@web log]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf | grep listen
        listen 8080;
        listen [::]:8080;
```
- redémarrer le service pour que le changement prenne effet
  - `sudo systemctl restart nginx`
  - vérifiez qu'il tourne toujours avec un ptit `systemctl status nginx`

```
[fay@web log]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2023-01-16 17:52:41 CET; 5s ago
  Process: 1915 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 1911 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 1909 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 1916 (nginx)
    Tasks: 3 (limit: 11366)
   Memory: 5.0M
   CGroup: /system.slice/nginx.service
           ├─1916 nginx: master process /usr/sbin/nginx
           ├─1917 nginx: worker process
           └─1918 nginx: worker process

Jan 16 17:52:41 web systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 16 17:52:41 web nginx[1911]: nginx: the configuration file /etc/nginx/nginx.conf synta>
Jan 16 17:52:41 web nginx[1911]: nginx: configuration file /etc/nginx/nginx.conf test is s>
Jan 16 17:52:41 web systemd[1]: Started The nginx HTTP and reverse proxy server.
```
- prouvez-moi que le changement a pris effet avec une commande `ss`
  - utilisez un `| grep` pour isoler les lignes intéressantes

```
[fay@web log]$ sudo ss -lnp | grep nginx
tcp   LISTEN 0      128                                                  0.0.0.0:8080             0.0.0.0:*     users:(("nginx",pid=1918,fd=8),("nginx",pid=1917,fd=8),("nginx",pid=1916,fd=8))
tcp   LISTEN 0      128                                                     [::]:8080                [::]:*     users:(("nginx",pid=1918,fd=9),("nginx",pid=1917,fd=9),("nginx",pid=1916,fd=9))****
```

- n'oubliez pas de fermer l'ancien port dans le firewall, et d'ouvrir le nouveau

```
sudo firewall-cmd --remove-port=12359/tcp --permanent
```
- prouvez avec une commande `curl` sur votre machine que vous pouvez désormais visiter le port 8080

```

[fay@web ~]$ curl http://10.3.1.2:8080
<html>
    <body>
        <h1>MEOW mon premier serveur web</h1>
    </body>
</html>


```
> Là c'est pas le port par convention, alors obligé de préciser le port quand on fait la requête avec le navigateur ou `curl` : `http://<IP_VM>:8080`.

---

🌞 **Changer l'utilisateur qui lance le service**

- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`
  - référez-vous au [mémo des commandes](../../cours/memos/commandes.md) pour la création d'utilisateur
  - l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à `/home/web`

```
[fay@web /]$ sudo passwd fayweb
```

```
[fay@web /]$ sudo usermod -m -d /home/web fayweb
```
- modifiez la conf de NGINX pour qu'il soit lancé avec votre nouvel utilisateur
  - utilisez `grep` pour me montrer dans le fichier de conf la ligne que vous avez modifié

```
[fay@web /]$ sudo cat /etc/nginx/nginx.conf | grep user
user fayweb;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
```
```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf | grep fayweb
        root /nfs/general/tp2_linux;
```
```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp4_linux.conf | grep fayweb
        root /nfs/general/tp4_linux;
```
- n'oubliez pas de redémarrer le service pour que le changement prenne effet


```
sudo systemctl restart nginx
```
- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur
  - utilisez un `| grep` pour isoler les lignes intéressantes
```
[fay@web /]$ sudo ps -ef | grep nginx
root        2276       1  0 18:58 ?        00:00:00 nginx: master process /usr/sbin/nginx
fayweb      2277    2276  0 18:58 ?        00:00:00 nginx: worker process
fayweb      2278    2276  0 18:58 ?        00:00:00 nginx: worker process
fay         2284    1599  0 18:59 pts/0    00:00:00 grep --color=auto nginx
[fay@web /]$
```
---

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

- configurez NGINX pour qu'il utilise une autre racine web que celle par défaut
```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf | grep nfs
        root /nfs/general/tp2_linux;
```

  - avec un `nano` ou `vim`, créez un fichier `/var/www/site_web_1/index.html` avec un contenu texte bidon

```
[fay@storage /]$ sudo cat /var/nfs/general/tp2_linux/index.html
<h1> Hello <h1>
[fay@storage /]$
```
  - dans la conf de NGINX, configurez la racine Web sur `/var/www/site_web_1/`
  - vous me montrerez la conf effectuée dans le compte-rendu, avec un `grep`

```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf | grep nfs
        froot /nfs/general/tp2_linux;
```

- n'oubliez pas de redémarrer le service pour que le changement prenne effet

```
sudo systemctl restart nginx
```
- prouvez avec un `curl` depuis votre hôte que vous accédez bien au nouveau site



> **Normalement le dossier `/var/www/site_web_1/` est un dossier créé à la Partie 2 du TP**, et qui se trouve en réalité sur le serveur `storage.tp4.linux`, notre serveur NFS.

![MAIS](../pics/nop.png)

## 6. Deux sites web sur un seul serveur

Dans la conf NGINX, vous avez du repérer un bloc `server { }` (si c'est pas le cas, allez le repérer, la ligne qui définit la racine web est contenu dans le bloc `server { }`).

Un bloc `server { }` permet d'indiquer à NGINX de servir un site web donné.

Si on veut héberger plusieurs sites web, il faut donc déclarer plusieurs blocs `server { }`.

**Pour éviter que ce soit le GROS BORDEL dans le fichier de conf**, et se retrouver avec un fichier de 150000 lignes, on met chaque bloc `server` dans un fichier de conf dédié.

Et le fichier de conf principal contient une ligne qui inclut tous les fichiers de confs additionnels.

🌞 **Repérez dans le fichier de conf**

- la ligne qui inclut des fichiers additionels contenus dans un dossier nommé `conf.d`
- vous la mettrez en évidence avec un `grep`

```
[fay@web /]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

> On trouve souvent ce mécanisme dans la conf sous Linux : un dossier qui porte un nom finissant par `.d` qui contient des fichiers de conf additionnels pour pas foutre le bordel dans le fichier de conf principal. On appelle ce dossier un dossier de *drop-in*.

🌞 **Créez le fichier de configuration pour le premier site**

- le bloc `server` du fichier de conf principal, vous le sortez
- et vous le mettez dans un fichier dédié
- ce fichier dédié doit se trouver dans le dossier `conf.d`
- ce fichier dédié doit porter un nom adéquat : `site_web_1.conf`

```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
        listen 8080;
        listen [::]:8080;

        root /nfs/general/tp2_linux;
        index index.html index.htm index.nginx-debian.html;

        server_name tp2_linux www.tp2_linux;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

🌞 **Créez le fichier de configuration pour le deuxième site**

- un nouveau fichier dans le dossier `conf.d`
- il doit porter un nom adéquat : `site_web_2.conf`
- copiez-collez le bloc `server { }` de l'autre fichier de conf
- changez la racine web vers `/var/www/site_web_2/`
- et changez le port d'écoute pour 8888
### FICHIERS DE CONF DES DEUX SITES:
```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp4_linux.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
        listen 8888;
        listen [::]:8888;

        root /nfs/general/tp4_linux;
        index index.html index.htm index.nginx-debian.html;

        server_name tp4_linux www.tp4_linux;

        location / {
                try_files $uri $uri/ =404;
        }
}

```

```
[fay@web ~]$ sudo cat /etc/nginx/conf.d/tp2_linux.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
        listen 8080;
        listen [::]:8080;

        root /nfs/general/tp2_linux;
        index index.html index.htm index.nginx-debian.html;

        server_name tp2_linux www.tp2_linux;

        location / {
                try_files $uri $uri/ =404;
        }
}
``` 

> N'oubliez pas d'ouvrir le port 8888 dans le firewall. Vous pouvez constater si vous le souhaitez avec un `ss` que NGINX écoute bien sur ce nouveau port.

🌞 **Prouvez que les deux sites sont disponibles**

- depuis votre PC, deux commandes `curl`
- pour choisir quel site visitez, vous choisissez un port spécifique

```
[fayweb@web ~]$ curl 10.3.1.2:8080; curl 10.3.1.2:8888
<h1> Hello <h1>
<h1> Hello <h1>
```

