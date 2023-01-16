# TP 3 : We do a little scripting

Aujourd'hui un TP pour appréhender un peu **le scripting**.

➜ **Le scripting dans GNU/Linux**, c'est simplement le fait d'écrire dans un fichier une suite de commande, qui seront exécutées les unes à la suite des autres lorsque l'on exécutera le script.

Plus précisément, on utilisera la syntaxe du shell `bash`. Et on a le droit à l'algo (des variables, des conditions `if`, des boucles `while`, etc).

➜ **Bon par contre, la syntaxe `bash`, elle fait mal aux dents.** Ca va prendre un peu de temps pour s'habituer.

![Bash syntax](./pics/bash_syntax.jpg)

Pour ça, vous prenez connaissance des deux ressources suivantes :

- [le cours sur le shell](../../cours/shell/README.md)
- [le cours sur le scripting](../../cours/scripting/README.md)
- le très bon https://devhints.io/bash pour tout ce qui est relatif à la syntaxe `bash`

➜ **L'emoji 🐚** est une aide qui indique une commande qui est capable de réaliser le point demandé

## Sommaire

- [TP 3 : We do a little scripting](#tp-3--we-do-a-little-scripting)
  - [Sommaire](#sommaire)
- [0. Un premier script](#0-un-premier-script)
- [I. Script carte d'identité](#i-script-carte-didentité)
  - [Rendu](#rendu)
- [II. Script youtube-dl](#ii-script-youtube-dl)
  - [Rendu](#rendu-1)
- [III. MAKE IT A SERVICE](#iii-make-it-a-service)
  - [Rendu](#rendu-2)
- [IV. Bonus](#iv-bonus)

# 0. Un premier script

➜ **Créer un fichier `test.sh` dans le dossier `/srv/` avec le contenu suivant** :

```bash
#!/bin/bash
# Simple test script

echo "Connecté actuellement avec l'utilisateur $(whoami)."
```



➜ **Modifier les permissions du script `test.sh`**

- si c'est pas déjà le cas, faites en sorte qu'il appartienne à votre utilisateur
  - 🐚 `chown`
- ajoutez la permission `x` pour votre utilisateur afin que vous puissiez exécuter le script
  - 🐚 `chmod`
```
[fay@TpLinux2 ~]$ sudo chown fay test.sh
[fay@TpLinux2 ~]$ sudo chmod +x test.sh
```

➜ **Exécuter le script** :

```bash
# Exécuter le script, peu importe le dossier où vous vous trouvez
$ /srv/test.sh

# Exécuter le script, depuis le dossier où il est stocké
$ cd /srv
$ ./test.sh
```

```
[fay@TpLinux2 ~]$ ./test.sh
Connecté actuellement avec l'utilisateur fay.
```
> **Vos scripts devront toujours se présenter comme ça** : muni d'un *shebang* à la ligne 1 du script, appartenir à un utilisateur spécifique qui possède le droit d'exécution sur le fichier.

# I. Script carte d'identité

Vous allez écrire **un script qui récolte des informations sur le système et les affiche à l'utilisateur.** Il s'appellera `idcard.sh` et sera stocké dans `/srv/idcard/idcard.sh`.

> `.sh` est l'extension qu'on donne par convention aux scripts réalisés pour être exécutés avec `sh` ou `bash`.

➜ **Testez les commandes à la main avant de les incorporer au script.**

➜ Ce que doit faire le script. Il doit afficher :

- le **nom de la machine**
  - 🐚 `hostnamectl`

```
[fay@TpLinux2 ~]$ hostnamectl | grep hostname | cut -d ':' -f2
 TpLinux2
```
- le **nom de l'OS** de la machine
  - regardez le fichier `/etc/redhat-release` ou `/etc/os-release`
  - 🐚 `source`

```
[fay@TpLinux2 ~]$ cat /etc/redhat-release
Rocky Linux release 8.7 (Green Obsidian)
```
- la **version du noyau** Linux utilisé par la machine
  - 🐚 `uname

```
[fay@TpLinux2 ~]$ uname -r
kernel version is 4.18.0-425.3.1.el8.x86_64
```
- l'**adresse IP** de la machine
  - 🐚 `ip`

```
[fay@TpLinux2 ~]$ ip a | grep inet | head -3 | tail -1 | cut -d ' ' -f6
10.3.1.2/24
```
- l'**état de la RAM**
  - 🐚 `free`
  - espace dispo en RAM (en Go, Mo, ou Ko)

```
[fay@TpLinux2 ~]$ free -m | grep Mem | cut -d ' ' -f29
1372
```
  - taille totale de la RAM (en Go, Mo, ou ko)
```
[fay@TpLinux2 ~]$ free -m | grep Mem | cut -d ' ' -f12
1812
```

- l'**espace restant sur le disque dur**, en Go (ou Mo, ou ko)
  - 🐚 `df`

```
[fay@TpLinux2 ~]$ df -H -t xfs | grep root | tr -s [:space:] ' '| cut -d ' ' -f4
16G
```
- le **top 5 des processus** qui pompent le plus de RAM sur la machine actuellement. Procédez par étape :
  - 🐚 `ps`
  - listez les process
```
[fay@TpLinux2 ~]$ ps -ef
```

  - affichez la RAM utilisée par chaque process

```
[fay@TpLinux2 ~]$ ps -e -o pid,uname,pmem,comm
```
  - triez par RAM utilisée
  -   - isolez les 5 premiers


```
[fay@TpLinux2 ~]$ ps -eo cmd= --sort=-%mem | cut -d '/' -f 4| head -5
sssd
platform-python -s
platform-python -Es
polkit-1
NetworkManager --no-daemon
```


- la **liste des ports en écoute** sur la machine, avec le programme qui est derrière

```
[fay@TpLinux2 ~]$ ss -lnp4H | tr -s ' '
udp UNCONN 0 0 127.0.0.1:323 0.0.0.0:*
tcp LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
tcp LISTEN 0 128 0.0.0.0:12359 0.0.0.0:*
```
  - préciser, en plus du numéro, s'il s'agit d'un port TCP ou UDP

```
[fay@TpLinux2 ~]$ ss -lnpt4H | tr -s ' '
LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
LISTEN 0 128 0.0.0.0:12359 0.0.0.0:*
```
```
[fay@TpLinux2 ~]$ ss -lnpu4H | tr -s ' '
UNCONN 0 0 127.0.0.1:323 0.0.0.0:*
```
  - 🐚 `ss`
- un **lien vers une image/gif** random de chat 
  - 🐚 `curl`
  - il y a de très bons sites pour ça hihi
  - avec [celui-ci](https://cataas.com/), une simple requête HTTP vers `https://cataas.com/cat` vous retourne l'URL d'une random image de chat
    - une requête sur cette adresse retourne directement l'image, il faut l'enregistret dans un fichier

```
[fay@TpLinux2 ~]$ curl -o cat.png https://cataas.com/cat
```
    - parfois le fichier est un JPG, parfois un PNG, parfois même un GIF
    - 🐚 `file` peut vous aider à déterminer le type de fichier

Pour vous faire manipuler les sorties/entrées de commandes, votre script devra sortir **EXACTEMENT** :

```
$ /srv/idcard/idcard.sh
Machine name : ...
OS ... and kernel version is ...
IP : ...
RAM : ... memory available on ... total memory
Disk : ... space left
Top 5 processes by RAM usage :
  - ...
  - ...
  - ...
  - ...
  - ...
Listening ports :
  - 22 tcp : sshd
  - ...
  - ...

Here is your random cat : ./cat.jpg
```

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

# II. Script youtube-dl

**Un petit script qui télécharge des vidéos Youtube.** Vous l'appellerez `yt.sh`. Il sera stocké dans `/srv/yt/yt.sh`.

**Pour ça on va avoir besoin d'une commande : `youtube-dl`.** Je vous laisse vous référer [à la doc officielle](https://github.com/ytdl-org/youtube-dl/blob/master/README.md#readme) pour voir comment récupérer cette commande sur votre machine.

Comme toujours, **PRENEZ LE TEMPS** de manipuler la commande et d'explorer un peu le `youtube-dl --help`.

Le contenu de votre script :

➜ **1. Permettre le téléchargement d'une vidéo youtube dont l'URL est passée au script**

- la vidéo devra être téléchargée dans le dossier `/srv/yt/downloads/`
  - le script doit s'assurer que ce dossier existe sinon il quitte
  - vous pouvez utiliser la commande `exit` pour que le script s'arrête
- plus précisément, chaque téléchargement de vidéo créera un dossier
  - `/srv/yt/downloads/<NOM_VIDEO>`
  - il vous faudra donc, avant de télécharger la vidéo, exécuter une commande pour récupérer son nom afin de créer le dossier en fonction
- la vidéo sera téléchargée dans
  - `/srv/yt/downloads/<NOM_VIDEO>/<NOM_VIDEO>.mp4`
- la description de la vidéo sera aussi téléchargée
  - dans `/srv/yt/downloads/<NOM_VIDEO>/description`
  - on peut récup la description avec une commande `youtube-dl`
- la commande `youtube-dl` génère du texte dans le terminal, ce texte devra être masqué
  - vous pouvez utiliser une redirection de flux vers `/dev/null`, c'est ce que l'on fait généralement pour se débarasser d'une sortie non-désirée

Il est possible de récupérer les arguments passés au script dans les variables `$1`, `$2`, etc.

```bash
$ cat script.sh
echo $1

$ ./script.sh toto
toto
```

➜ **2. Le script produira une sortie personnalisée**

- utilisez la commande `echo` pour écrire dans le terminal
- la sortie **DEVRA** être comme suit :

```bash
$ /srv/yt/yt.sh https://www.youtube.com/watch?v=sNx57atloH8
Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded. 
File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4`
```

➜ **3. A chaque vidéo téléchargée, votre script produira une ligne de log dans le fichier `/var/log/yt/download.log`**

- votre script doit s'assurer que le dossier `/var/log/yt/` existe, sinon il refuse de s'exécuter
- la ligne doit être comme suit :

```
[yy/mm/dd hh:mm:ss] Video <URL> was downloaded. File path : <PATH>`
```

Par exemple :

```
[21/11/12 13:22:47] Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded. File path : /srv/yt/downloads/tomato anxiety/tomato anxiety.mp4`
```

> Hint : La commande `date` permet d'afficher la date et de choisir à quel format elle sera affichée. Idéal pour générer des logs. [J'ai trouvé ce lien](https://www.geeksforgeeks.org/date-command-linux-examples/), premier résultat google pour moi, y'a de bons exemples (en bas de page surtout pour le formatage de la date en sortie).

## Rendu

📁 **Le script `/srv/yt/yt.sh`**

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

# III. MAKE IT A SERVICE

YES. Yet again. **On va en faire un [service](../../cours/notions/serveur/README.md#ii-service).**

L'idée :

➜ plutôt que d'appeler la commande à la main quand on veut télécharger une vidéo, **on va créer un service qui les téléchargera pour nous**

➜ le service devra **lire en permanence dans un fichier**

- s'il trouve une nouvelle ligne dans le fichier, il vérifie que c'est bien une URL de vidéo youtube
  - si oui, il la télécharge, puis enlève la ligne
  - sinon, il enlève juste la ligne

➜ **qui écrit dans le fichier pour ajouter des URLs ? Bah vous !**

- vous pouvez écrire une liste d'URL, une par ligne, et le service devra les télécharger une par une

---

Pour ça, procédez par étape :

- **partez de votre script précédent** (gardez une copie propre du premier script, qui doit être livré dans le dépôt git)
  - le nouveau script s'appellera `yt-v2.sh`
- **adaptez-le pour qu'il lise les URL dans un fichier** plutôt qu'en argument sur la ligne de commande
- **faites en sorte qu'il tourne en permanence**, et vérifie le contenu du fichier toutes les X secondes
  - boucle infinie qui :
    - lit un fichier
    - effectue des actions si le fichier n'est pas vide
    - sleep pendant une durée déterminée
- **il doit marcher si on précise une vidéo par ligne**
  - il les télécharge une par une
  - et supprime les lignes une par une

➜ **une fois que tout ça fonctionne, enfin, créez un service** qui lance votre script :

- créez un fichier `/etc/systemd/system/yt.service`. Il comporte :
  - une brève description
  - un `ExecStart` pour indiquer que ce service sert à lancer votre script
  - une clause `User=` pour indiquer que c'est l'utilisateur `yt` qui lance le script
    - créez l'utilisateur s'il n'existe pas
    - faites en sorte que le dossier `/srv/yt` et tout son contenu lui appartienne
    - le dossier de log doit lui appartenir aussi
    - l'utilisateur `yt` ne doit pas pouvoir se connecter sur la machine

```bash
[Unit]
Description=<Votre description>

[Service]
ExecStart=<Votre script>
User=yt

[Install]
WantedBy=multi-user.target
```

> Pour rappel, après la moindre modification dans le dossier `/etc/systemd/system/`, vous devez exécuter la commande `sudo systemctl daemon-reload` pour dire au système de lire les changements qu'on a effectué.

Vous pourrez alors interagir avec votre service à l'aide des commandes habituelles `systemctl` :

- `systemctl status yt`
- `sudo systemctl start yt`
- `sudo systemctl stop yt`

![Now witness](./pics/now_witness.png)

## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

📁 **Fichier `/etc/systemd/system/yt.service`**

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement
- un extrait de `journalctl -xe -u yt`

> Hé oui les commandes `journalctl` fonctionnent sur votre service pour voir les logs ! Et vous devriez constater que c'est vos `echo` qui pop. En résumé, **le STDOUT de votre script, c'est devenu les logs du service !**

🌟**BONUS** : get fancy. Livrez moi un gif ou un [asciinema](https://asciinema.org/) (PS : c'est le feu asciinema) de votre service en action, où on voit les URLs de vidéos disparaître, et les fichiers apparaître dans le fichier de destination

# IV. Bonus

Quelques bonus pour améliorer le fonctionnement de votre script :

➜ **en accord avec les règles de [ShellCheck](https://www.shellcheck.net/)**

- bonnes pratiques, sécurité, lisibilité

➜  **fonction `usage`**

- le script comporte une fonction `usage`
- c'est la fonction qui est appelée lorsque l'on appelle le script avec une erreur de syntaxe
- ou lorsqu'on appelle le `-h` du script

➜ **votre script a une gestion d'options :**

- `-q` pour préciser la qualité des vidéos téléchargées (on peut choisir avec `youtube-dl`)
- `-o` pour préciser un dossier autre que `/srv/yt/`
- `-h` affiche l'usage

➜ **si votre script utilise des commandes non-présentes à l'installation** (`youtube-dl`, `jq` éventuellement, etc.)

- vous devez TESTER leur présence et refuser l'exécution du script

➜  **si votre script a besoin de l'existence d'un dossier ou d'un utilisateur**

- vous devez tester leur présence, sinon refuser l'exécution du script

➜ **pour le téléchargement des vidéos**

- vérifiez à l'aide d'une expression régulière que les strings saisies dans le fichier sont bien des URLs de vidéos Youtube
