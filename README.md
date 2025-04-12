# RTKanne
A RTK rover on a stick for blind people (Un rover RTK pour aveugles a fixer sur une canne)
English version below

![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/Canne.jpg)
Le projet RTKanne est un rover RTK pour aveugles et malvoyants qui peut se fixer sur une canne, on peut aussi assembler et utiliser le kit RTK2B d'Ardusimple qui est concu avec les memes composants, il peut fournir une précision de quelques centimètres a une application Android ou IOS. Le système est composé d'un récepteur GNSS Ublox ZED-F9R, un module bluetooth Ardusimple compatible Android/IOS une, batterie interne et utilise en France et dans certains pays d'Europe le reseau open source Centipede (centipede.fr) pour les corrections RTK (une connexion a internet via le smartphone est requise pour obtenir la connexion au serveur centipede.fr). Sur Android il faut utiliser l'application Bluetooth GNSS disponible sur le play store pour que toutes les applications Android puissent utiliser la precision RTK, sur IOS il faut que chaque application soit modifiée poue utiliser le RTK, l'application Sonarvision de guidage pour aveugle et malvoyant sera bientôt disponible avec une version RTK compatible avec RTKanne, actuellement seul SWmaps (qui n'est pas une application de guidage) sur IOS permet de tester le fonctionnement sur IOS, un programme de client Ntrip en swift est disponible ici permettant d'afficher les coordonnées GPS et l'état du rover pour faire des tests et permettre l'adaptation d'autre applications.

La précision de position RTK ne permet de résoudre qu'une partie du problème de navigation et de guidage d'un aveugle, on a bien une position précise mais il faut en plus un logiciel de navigation qui soit adapté a ce niveau de précision, par exemple Google maps pieton valide un point de navigation alors que l'on est dans un rayon d'une dizaine de mètres de ce point, cette imprécision dans la carte de navigation ne permet pas le guidage correct d'un aveugle même en RTK, il faut donc que le coe et le plan de navigation soient adaptés pour tirer pleinement profit d'un positionnement précis. Pour l'instant seule l'appli Sonarvision sur IOS a un guidage précis au mètre prés  pour les aveugles et malvoyant grâce au VPS (visual positionning system) et est en train d'ajouter le RTK a son application   

Voici la liste des piéces des différents projets o peux choisir entre le ZED-F9R avec IMU et le ZED-F9P sans IMU, dans le GNSS store on a le choix entre les féquences L1/L2 et L1/L5, le L1/L5 est censé etre plus robuste en milieu urbain ou foret. dans les kits Ardusimple , j'ai mis l'option avec header (connecteurs) soudés à 26 Euros 

Composants du rover RTKanne
- Récepteur RTK avec centrale inertielle Ublox ZED-F9R, la centrale inertielle permet de compenser les pertes de réception en milieu urbain ( https://gnss.store/zed-f9r-dead-reckoning-gnss-modules/134-elt0117.html ) 249,99 Euros

ou

- Récepteur RTK sans centrale inertielle Ublox ZED-F9P https://gnss.store/zed-f9p-gnss-modules/273-200-elt0412.html#/61-gnss_module-l1_l2_zed_f9p 189,99 Euros
- Antenne multi fréquences pour drones afin d'avoir une antenne de petite taille avec une bonne qualité de réception ( https://gnss.store/gnss-rtk-multiband-antennas/28-elt0014.html ) 89 Euros
- Module bluetooth  BT+BLE bridge Ardusimple, compatible Android et IOS ( https://fr.ardusimple.com/product/ble-bridge/ ) 66 Euros
- Batterie Lithium polymère 1S (4,2V) de 1500mAh pour une dizaine d'heures d'autonomie, une batterie de plus grande capacité est possible.
- Régulateur 3,3V Pololu S9V11F3S5C3 avec coupure d'alimentation a 3V afin de préserver la batterie d'une décharge excessive.( https://www.pololu.com/product/2873 ) 10,85 $
- BMS 1S 1A USB-C TP4056 pour la recharge de la batterie interne ( https://www.otronic.nl/fr/chargeur-de-batterie-lithium-18650-avec-usb-c-5v-1.html ) 1,49 Euros
- Interrupteur ON/OFF ( https://www.ebay.fr/itm/251390016446 )
- Boitier imprimé 3D pouvant se fixer sur une canne ou etre porté dans une pochette exterieure a la ceinture ou au bras

Composants du kit rover RTK2B Ardusimple
 - Récepteur RTK avec centrale inertielle Ublox ZED-F9R, la centrale inertielle permet de compenser les pertes de réception en milieu urbain https://fr.ardusimple.com/product/simplertk2b-fusion/ 305 Euros

 OU
 
 - Récepteur RTK sans centrale inertielle Ublox ZED-F9P https://fr.ardusimple.com/product/simplertk2b/ 193 Euros
 - Module bluetooth  BT+BLE bridge Ardusimple, compatible Android et IOS  https://fr.ardusimple.com/product/ble-bridge/ 66 Euros
 - Boitier imprimé 3D https://fr.ardusimple.com/product/plastic-case-simplertk2b/ 49 Euros
 - Antenne multi fréquences pour drones afin d'avoir une antenne de petite taille avec une bonne qualité de réception https://fr.ardusimple.com/product/helical-antenna/ 99 Euros

   Kit Ardusimple RTK Handheld Surveyor, composants similaires au RTK2B mais livré en lot ce qui est moins cher que le kit RTK2B (livré non monté) Je n'ai pas monté ce kit mais on devrait pouvoir l'utiliser sans la poignée ou le support smartphone si l'on veut, on peut aussi utiliser un powerbank USB-C pour l'alimenter et économiser la batterie du téléphone.
   - https://fr.ardusimple.com/product/rtk-handheld-surveyor-kit/  399 euros
   - Manuel d'assemblage et mise en route avec SWmaps https://fr.ardusimple.com/user-manual-handheld-surveyor-kit/
   - Manuel de configuration U-center https://fr.ardusimple.com/how-to-configure-ublox-zed-f9p/


   Ce projet utilise le récepteur GNSS RTK L1/L2 Ublox ZED-F9R au lieu du ZED-F9P plus courant car il intègre en plus une IMU (centrale inertielle avec gyroscope et accéléromètre) pour compenser les pertes de signal GPS en milieu urbain ou sous un pont/tunnel, ce choix peut etre préferable si on habite dans une ville avec de grands immeubles, le récepteur avec IMU est environ 60 euros plus cher, sa précision est de 2 mètres d'erreur sur 100 mètres pendant une perte de signal satellite en supportant les mouvements et les vibrations si il est fixé sur une canne. Le récepteur devrait être configuré avec le logiciel [U-center](https://www.u-blox.com/en/product/u-center)avant de pouvoir l'utiliser avec le bluetooth et les applications

  Le positionnement RTK (real time kinematic) est un système qui utilise un récepteur mobile (le rover) et des stations (les bases, stations ou moutpoint) qui lui apportent les corrections de position nécessaire pour obtenir une précision pouvant aller jusqu'au centimètre. Pour obtenir une bonne précision il faut etre a moins de 40Km d'une base mais pour notre utilisation on peut aller jusqu'a 70Km, i faut donc une couverture complète du pays avec des stations de corrections et l'accès a ces services est payant par abonnement, depuis quelques années un réseau de stations open source et gratuit s'est développé grâce au agriculteurs: le réseau [centipede](https://docs.centipede.fr) , ce réseau permet de se connecter au stations via un client Ntrip, si il n'y a pas de station dans la région, on peut en construire une avec un faible cout et l'ajouter au réseau, ce qui a permit au réseau centipede de s'agrandir rapidement. Vous pourrez trouver toutes les informations pour construire et connecter sa base ou son rover sur [centipede.fr](https://docs.centipede.fr)

   Utilisation sur Android
  Pour utiliser en rover RTKanne sur Android et que le smartphone et toutes les applications utilisent la position RTK, vous devrez installer et utiliser l'application Bluetooth GNSS qui se trouve sur le playstore. Pour que Bluetooth GNSS puisse remplacer la position donnée par le récepteur GPS du smartphone par celle donnée par le rover (fonction appelée "Mock Location") vous devrez  passer Android en mode développeur. Une fois Bluetooth GNSS paramètré avec la connexion bluetooth, la connexion au serveur Ntrip centipede.fr et le choix de la station (ou Moutpoint) la plus proche choisi (il y a une fonction pour choisir la plus proche automatiquement), vous lancez la connexion avec le bouton en bas a droite et la position RTK sera utilisée par toutes les applications qui seront lancées ensuite, mais il faut garder bluetooth GNSS en fond de tache. 

	Utilisation sur IOS
   L'application Sonarvision est actuellement en cours de beta-test et devrait être disponible avec l'option RTK en avril 2025, pour tester le bon fonctionnement du Rover RTKanne, vous pouvez utiliser Swaps disponible sur l'apple store ou installer le code de Client Ntrip présent sur ce dépôt a l'aide de Xcode, il faut installer Xcode sur un Mac, charger et compiler le code de Client Ntrip, connecter l'iPhone en mode développeur au Mac pour créer cette application. Les paramètres Ntrip de centipede sont déjà configurés et on peut afficher les coordonnées de position, le nombre de satellites reçus, la précision de la position, l'état de la connexion a centipede.fr


	Schéma de connexion
    Le récepteur est connecté au module bluetooth par les connecteurs TX et RX en croisant les entrée/sortie TX>RX et RX>TX. Les 2 modules sont alimentés par la sortie 3,3volts du régulateur Pololu, celui ci est branché sur la sortie batterie du BMS via l'interrupteur. La batterie est aussi connectée au chargeur (BMS) USB-C. La batterie est logée dans le compartiment de l'autre coté du boitier.

Vous trouverez plus d'infos sur la configuration du récepteur dans le [Wiki](https://github.com/Francklin2/RTKanne/wiki)  

  ![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Schema_GNSS-RTK.jpg)  

  ![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/Boitier-ouvert.jpg)


# RTKanne
A RTK rover on a stick for blind people

  The RTKanne project is an RTK rover for blind and visually impaired people that can be attached to a cane, providing centimeter-level accuracy to an Android or iOS application. The system consists of a Ublox ZED-F9R GNSS receiver, an Ardusimple Bluetooth module compatible with Android/iOS, an internal battery, and uses the open-source Centipede network (centipede.fr) in France and some European countries for RTK corrections (an internet connection via smartphone is required to connect to the centipede.fr server). On Android, the Bluetooth GNSS application available on the Play Store must be used for all Android applications to utilize RTK precision. On iOS, each application needs to be modified to use RTK. The Sonarvision guidance app for blind and visually impaired people will soon be available with an RTK version compatible with RTKanne. Currently, only SWmaps (which is not a guidance application) on iOS allows testing on iOS. A Ntrip client program in Swift is available here to display GPS coordinates and rover status for testing and to facilitate adaptation of other applications.
RTK position accuracy only solves part of the navigation and guidance problem for a blind person. While we have an accurate position, we also need navigation software adapted to this level of precision. For example, Google Maps pedestrian mode validates a navigation point when you are within a radius of about ten meters from that point. This imprecision in the navigation map does not allow for correct guidance of a blind person even with RTK. Therefore, the code and navigation plan must be adapted to fully benefit from accurate positioning. Currently, only the Sonarvision app on iOS has precise guidance to the nearest meter for blind and visually impaired people thanks to VPS (visual positioning system) and is in the process of adding RTK to its application.
Rover components:
 - Ublox ZED-F9R RTK receiver with inertial measurement unit, which compensates for reception losses in urban environments  ( https://gnss.store/zed-f9r-dead-reckoning-gnss-modules/134-elt0117.html )
 - Multi-frequency antenna for drones to have a small antenna with good reception quality ( https://gnss.store/gnss-rtk-multiband-antennas/28-elt0014.html )
 - Ardusimple BT+BLE bridge Bluetooth module, compatible with Android and iOS ( https://www.ardusimple.com/product/ble-bridge/ )
 - 1S (4.2V) 1500mAh Lithium Polymer battery for about ten hours of autonomy, a higher capacity battery is possible
 - Pololu S9V11F3S5C3 3.3V regulator with power cut-off at 3V to protect the battery from excessive discharge ( https://www.pololu.com/product/2873 )
 - TP4056 1S 1A USB-C BMS for internal battery charging ( https://www.otronic.nl/fr/chargeur-de-batterie-lithium-18650-avec-usb-c-5v-1.html )
 - ON/OFF switch ( https://www.ebay.fr/itm/251390016446 )
 - 3D printed case that can be attached to a cane or worn in an external pouch on the belt or arm

This project uses the Ublox ZED-F9R L1/L2 RTK GNSS receiver instead of the more common ZED-F9P because it also integrates an IMU (inertial measurement unit with gyroscope and accelerometer) to compensate for GPS signal losses in urban environments or under bridges/tunnels. Its accuracy is 2 meters of error over 100 meters during satellite signal loss while supporting movements and vibrations when attached to a cane. The receiver should be configured with the U-center software before it can be used with Bluetooth and applications.
RTK (real-time kinematic) positioning is a system that uses a mobile receiver (the rover) and stations (bases, stations, or mountpoints) that provide the necessary position corrections to achieve accuracy up to the centimeter level. For good accuracy, you need to be within 40km of a base, but for our use, we can go up to 70km. Therefore, complete country coverage with correction stations is needed, and access to these services is usually paid by subscription. In recent years, an open-source and free network of stations has been developed thanks to farmers: the centipede network. This network allows connection to stations via an Ntrip client. If there is no station in the region, one can be built at a low cost and added to the network, which has allowed the centipede network to expand rapidly. You can find all the information to build and connect your base or rover on centipede.fr.

Using on Android:
To use RTKanne as a rover on Android and have the smartphone and all applications use the RTK position, you will need to install and use the Bluetooth GNSS application from the Play Store. For Bluetooth GNSS to replace the position given by the smartphone's GPS receiver with that given by the rover (a function called "Mock Location"), you will need to put Android in developer mode. Once Bluetooth GNSS is set up with the Bluetooth connection, the connection to the centipede.fr Ntrip server, and the choice of the nearest station (or Mountpoint) selected (there is a function to choose the nearest automatically), you start the connection with the button at the bottom right, and the RTK position will be used by all applications launched afterwards, but you need to keep Bluetooth GNSS running in the background.

Using on iOS:
The Sonarvision application is currently in beta testing and should be available with the RTK option in april 2025. To test the proper functioning of the RTKanne Rover, you can use SWmaps available on the App Store or install the Ntrip Client code present in this repository using Xcode. You need to install Xcode on a Mac, load and compile the Ntrip Client code, connect the iPhone in developer mode to the Mac to create this application. The Ntrip parameters for centipede are already configured, and you can display position coordinates, the number of satellites received, position accuracy, and the connection status to centipede.fr.

Connection diagram:

 ![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Schema_GNSS-RTK.jpg) 

The receiver is connected to the Bluetooth module via the TX and RX connectors, crossing the input/output TX>RX and RX>TX. Both modules are powered by the 3.3-volt output of the Pololu regulator, which is connected to the battery output of the BMS via the switch. The battery is also connected to the USB-C charger (BMS). The battery is housed in the compartment on the other side of the case.

You can find more information on receiver configuration in the [Wiki](https://github.com/Francklin2/RTKanne/wiki) 
     
  
