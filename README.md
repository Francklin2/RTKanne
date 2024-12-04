# RTKanne
A RTK rover on a stick for blind people (Un rover RTK pour aveugle a fixer sur une canne)

Le projet RTKanne est un rover RTK pour aveugles et malvoyants qui peut se fixer sur une canne, il peut fournir une précision de quelques centimetres a une application Android ou IOS. Le systeme est composé d'un recepteur GNSS Ublox ZED-F9R, un module bluetooth Ardusimple compatible Android/IOS une, batterie interne et utilise en France et dans certains pays d'Europe le reseau open source Centipede (centipede.fr) pour les corrections RTK (une connexion a internet via le smartphone est requise pour obtenir la connexion au serveur centipede.fr). Sur Android il faut utiliser l'application Bluetooth GNSS disponible sur le play store pour que toutes les applications Android puissent utiliser la precision RTK, sur IOS il faut que chaque application soit modifiée poue utiliser le RTK, l'application Sonarvision de guidage pour aveugle et malvoyant sera bientot disponible avec une version RTK compatible avec RTKanne, actuellement seul SWmaps (qui n'est pas une application de guidage) sur IOS permet de tester le fonctionnement sur IOS, un programme de client Ntrip en swift est disponible ici permetant d'afficher les coordonnées GPS et l'état du rover pour faire des tests et permettre l'adaptation d'autre applications.

Composants du rover
- Recepteur RTK avec centrale inertielle Ublox ZED-F9R, la centrale inertielle permet de compenser les pertes de receptions en milieu urbain,
- Antenne multi frequences pour drones afin d'avoir une antenne de petite taille avec une bonne qualité sz reception
- Module bluetooth Ardusimple, compatible Android et IOS
- Batterie Lithium polymere 1S (4,2V) de 1500mAh pour une dizaine d'heures d'automonie, une batterie de plus grande capacité est possible.
- Régulateur Ubec 3,3V Pololu avec coupure d'limentation a 3V afin de prserver la batterie d'une décharge excessive.
- BMS 1S USB-C pour la recharge de la batterie interne
- Interupteur ON/OFF
- Boitier imprimé 3D pouvant se fixer sur une canne ou etre porté dans une pochette exterieure a la ceinture ou au bras 
