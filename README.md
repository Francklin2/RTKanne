# RTKanne
A RTK rover on a stick for blind people (Un rover RTK pour aveugles a fixer sur une canne)

Le projet RTKanne est un rover RTK pour aveugles et malvoyants qui peut se fixer sur une canne, il peut fournir une précision de quelques centimètres a une application Android ou IOS. Le système est composé d'un récepteur GNSS Ublox ZED-F9R, un module bluetooth Ardusimple compatible Android/IOS une, batterie interne et utilise en France et dans certains pays d'Europe le reseau open source Centipede (centipede.fr) pour les corrections RTK (une connexion a internet via le smartphone est requise pour obtenir la connexion au serveur centipede.fr). Sur Android il faut utiliser l'application Bluetooth GNSS disponible sur le play store pour que toutes les applications Android puissent utiliser la precision RTK, sur IOS il faut que chaque application soit modifiée poue utiliser le RTK, l'application Sonarvision de guidage pour aveugle et malvoyant sera bientôt disponible avec une version RTK compatible avec RTKanne, actuellement seul SWmaps (qui n'est pas une application de guidage) sur IOS permet de tester le fonctionnement sur IOS, un programme de client Ntrip en swift est disponible ici permettant d'afficher les coordonnées GPS et l'état du rover pour faire des tests et permettre l'adaptation d'autre applications.

La précision de position RTK ne permet de résoudre qu'une partie du problème de navigation et de guidage d'un aveugle, on a bien une position précise mais il faut en plus un logiciel de navigation qui soit adapté a ce niveau de précision, par exemple Google maps pieton valide un point de navigation alors que l'on est dans un rayon d'une dizaine de mètres de ce point, cette imprécision dans la carte de navigation ne permet pas le guidage correct d'un aveugle même en RTK, il faut donc que le coe et le plan de navigation soient adaptés pour tirer pleinement profit d'un positionnement précis. Pour l'instant seule l'appli Sonarvision sur IOS a un guidage précis au mètre prés  pour les aveugles et malvoyant grâce au VPS (visual positionning system) et est en train d'ajouter le RTK a son application   

Composants du rover
- Récepteur RTK avec centrale inertielle Ublox ZED-F9R, la centrale inertielle permet de compenser les pertes de réception en milieu urbain ( https://gnss.store/zed-f9r-dead-reckoning-gnss-modules/134-elt0117.html )
- Antenne multi fréquences pour drones afin d'avoir une antenne de petite taille avec une bonne qualité de réception ( https://gnss.store/gnss-rtk-multiband-antennas/28-elt0014.html )
- Module bluetooth  BT+BLE bridge Ardusimple, compatible Android et IOS ( https://www.ardusimple.com/product/ble-bridge/ )
- Batterie Lithium polymère 1S (4,2V) de 1500mAh pour une dizaine d'heures d'autonomie, une batterie de plus grande capacité est possible.
- Régulateur 3,3V Pololu S9V11F3S5C3 avec coupure d'alimentation a 3V afin de préserver la batterie d'une décharge excessive.( https://www.pololu.com/product/2873 )
- BMS 1S 1A USB-C pour la recharge de la batterie interne
- Interrupteur ON/OFF
- Boitier imprimé 3D pouvant se fixer sur une canne ou etre porté dans une pochette exterieure a la ceinture ou au bras

  Ce projet utilise le récepteur GNSS RTK L1/L2 Ublox ZED-F9R au lieu du ZED-F9P plus courant car il intègre une IMU (centrale inertielle) avec gyroscope et accéléromètre pour compenser les pertes de signal GPS en milieu urbain ou sous un pont/tunnel, sa précision est de 2 mètres d'erreur sur 100 mètres en supportant les mouvements et les vibrations si il est fixé sur une canne.

  Le positionnement RTK (real time kinematic) est un système qui utilise un récepteur mobile (le rover) et des stations (les bases, stations ou moutpoint) qui lui apportent les corrections de position nécessaire pour obtenir une précision pouvant aller jusqu'au centimètre. Pour obtenir une bonne précision il faut etre a moins de 40Km d'une base mais pour notre utilisation on peut aller jusqu'a 70Km, i faut donc une couverture complète du pays avec des stations de corrections et l'accès a ces services est payant par abonnement, depuis quelques années un réseau de stations open source et gratuit s'est développé grâce au agriculteurs: le réseau centipede, ce réseau permet de se connecter au stations via un client Ntrip, si il n'y a pas de station dans la région, on peut en construire une avec un faible cout et l'ajouter au réseau, ce qui a permit a centipede de s'agrandir rapidement. Vous pourrez trouver toutes les informations pour construire et connecter sa base ou son rover sur centipede.fr

   Utilisation sur Android
  Pour utiliser e rover RTKanne sur Android et que le smartphone et toutes les applications utilisent la position RTK, vous devrez installer et utiliser l'application Bluetooth GNSS qui se trouve sur le playstore. Pour que Bluetooth GNSS puisse remplacer la position donnée par le récepteur GPS du smartphone par celle donnée par le rover (fonction appelée "Mock Location") vous devrez  passer Android en mode developpeur. Une fois Bluetooth GNSS paramètré avec la connexion bluetooth, la connexion au serveur Ntrip centipede.fr et le choix de la station (ou Moutpoint) la plus proche choisi (il y a une fonction pour choisir la plus proche automatiquement), vous lancez la connexion avec le bouton en bas a droite et la position RTK sera utilisée par toutes les applications qui seront lancées ensuite, mais il faut garder bluetooth GNSS en fond de tache. 

	Utilisation sur IOS
   L'application Sonarvision est actuellement en cours de beta-test et devrait être disponible avec l'option RTK fin 2024/début 2025, pour tester le bon fonctionnement du Rover RTKanne, vous pouvez utiliser Swaps disponible sur l'apple store ou installer le code de Client Ntrip présent sur ce dépôt a l'aide de Xcode, il faut installer Xcode sur un Mac, charger et compiler le code de Client Ntrip, connecter l'iPhone en mode développeur au Mac pour créer cette application. Les paramètres Ntrip de centipede sont déjà configurés et on peut afficher les coordonnées de position, le nombre de satellites reçus, la précision de la position, l'état de la connexion a centipede.fr

	Schéma de connexion
    Le récepteur est connecté au module bluetooth par les connecteurs TX et RX en croisant les entrée/sortie TX>RX et RX>TX. Les2 modules sont alimentés par la sortie 3,3volts du régulateur Pololu, celui ci est branché sur la batterie via l'interrupteur. La batterie est aussi connectée au chargeur (BMS) USB-C 

![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Schema_GNSS-RTK.jpg)    
     
  
