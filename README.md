# RTKanne
A RTK rover on a stick for blind people (Un rover RTK pour aveugles a fixer sur une canne)
English version below

![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/Canne.jpg)
![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/BlueRTK.jpg)
![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/BlueRTK1.jpg)

Le projet RTKanne est un rover RTK pour aveugles et malvoyants qui peut se fixer sur une canne ou être mis dans une pochette sur la poitrine avec le smartphone(boitier version BlueRTK) , on peut aussi assembler et utiliser le kit RTK2B d'Ardusimple qui est conçu avec le même récepteur, il peut fournir une précision de quelques centimètres a une application Android ou IOS. Le système est composé d'un récepteur GNSS Ublox ZED-F9P, ZED-X20P ou le PX122R Navspark un peu moins performant(j'ai fait des essais avec le ZED-F9R avec IMU mais je n'ai pas pu obtenir d'améliorations avec son IMU en mode piéton pour l'instant), un module bluetooth Ardusimple compatible Android/IOS ou un Bluetooth Xiao ESP32C3 compatible IOS, une batterie interne avec son chargeur BMS USB-C

Ce récepteur utilise le réseau NTRIP du réseau open source Centipede (centipede.fr) fonctionnant en France et dans certains pays d'Europe pour obtenir les corrections RTK (une connexion a internet via le smartphone est requise). Sur Android il faut utiliser l'application Bluetooth GNSS disponible sur le play store pour que toutes les applications Android puissent utiliser la précision RTK, sur IOS il faut que chaque application soit modifiée poue utiliser le RTK, l'application Sonarvision de guidage pour aveugle et malvoyant est disponible avec une option RTK compatible avec ce projet et fournit des trajets adapté au mètre près, actuellement SWmaps (qui n'est pas une application de guidage) permet aussi de tester le bon fonctionnement du récepteur sur IOS, un programme de client Ntrip en swift est disponible ici permettant d'afficher les coordonnées GPS et l'état du rover pour faire des tests et permettre l'adaptation du RTK sur d'autre applications.

La précision de position RTK ne permet de résoudre qu'une partie du problème de navigation et de guidage d'un aveugle, on a bien une position précise mais il faut en plus un logiciel de navigation qui soit adapté a ce niveau de précision, par exemple Google maps piéton valide un point de navigation alors que l'on est dans un rayon d'une dizaine de mètres de ce point, cette imprécision dans la carte de navigation et du trajet ne permet pas le guidage correct d'un aveugle même en RTK, il faut donc que le logiciel et le plan de navigation soient adaptés pour tirer pleinement profit d'un positionnement précis. Pour l'instant seule l'appli Sonarvision sur IOS a un guidage précis au mètre prés  pour les aveugles et malvoyant grâce au VPS (visual positionning system) ou au récepteur RTK   

Voici la liste des pièces des différents projets, dans le GNSS store on a le choix pour le ZED-F9P entre les fréquences L1/L2 et L1/L5, le L1/L5 est censé être plus robuste en milieu urbain ou foret mais pour une meilleure compatibilité avec le réseau Centipede le L1 L2 est recommandé sauf si vous avez une station L1 L5 près de chez vous. On peut aussi choisir le ZED-X20P qui est en triple fréquence L1 L2 L5, il est plus cher mais offre une meilleure qualité de réception en milieu perturbé et plus de précision en mode DGPS/HAS si il y a une coupure de réseau NTRIP (zone blanches GSM)  

Composants du rover RTKanne

- Récepteur RTK L1/L2 Ublox ZED-F9P https://gnss.store/zed-f9p-gnss-modules/273-200-elt0412.html#/61-gnss_module-l1_l2_zed_f9p 189,99 Euros HT
- Antenne L1 L2 L5 pour drones afin d'avoir une antenne de petite taille avec une bonne qualité de réception ( https://gnss.store/gnss-rtk-multiband-antennas/28-elt0014.html ) 69 Euros
- Module bluetooth  BT+BLE bridge Ardusimple, compatible Android et IOS ( https://fr.ardusimple.com/product/ble-bridge/ ) 66 Euros
- Batterie Lithium polymère 1S (4,2V) de 1500mAh pour une dizaine d'heures d'autonomie, une batterie de plus grande capacité est possible.
- Régulateur 3,3V Pololu S9V11F3S5C3 avec coupure d'alimentation a 3V afin de préserver la batterie d'une décharge excessive.( https://www.pololu.com/product/2873 ) 10,85 $
- BMS 1S 1A USB-C TP4056 pour la recharge de la batterie interne ( https://www.otronic.nl/fr/chargeur-de-batterie-lithium-18650-avec-usb-c-5v-1.html ) 1,49 Euros
- Interrupteur ON/OFF ( https://www.ebay.fr/itm/251390016446 )
- Boitier imprimé 3D pouvant se fixer sur une canne 

Composants du rover BlueRTK (Boitier plus petit et amélioré pour poche ou pochette ventrale) 

- Récepteur RTK L1/L2/L3 Ublox ZED-X20P de chez [GNSS Store](https://gnss.store/high-precision-rtk-gnss-modules/415-elt0421.html)  229,99 Euros HT/ 282 Euros TTC avec port
- Antenne L1 L2 L5 Beitian BT 560 performances similaires a la Ublox 34 Euros chez [Aliexpress](https://fr.aliexpress.com/item/32991527632.html?pdp_npi=4%40dis%21EUR%21€%2016%2C69%21€%2015%2C69%21%21%2119.00%2117.86%21%40211b876717565823921947665ef2ad%2112000031416205032%21sh%21FR%210%21X&spm=a2g0o.store_pc_allItems_or_groupList.new_all_items_2007550542376.32991527632&gatewayAdapt=glo2fra)
- Module bluetooth Seeed Studio Xiao ESP32C3 7 Euros chez [Aliexpress](https://fr.aliexpress.com/item/1005007039705247.html?pdp_npi=4%40dis%21EUR%21€%200%2C16%21€%200%2C15%21%21%211.26%211.26%21%402103890117565830582966233e6eec%2112000049940483727%21sh%21FR%210%21X&spm=a2g0o.store_pc_allItems_or_groupList.new_all_items_2008969535028.1005007039705247&gatewayAdapt=glo2fra)
- Batterie Lithium Huawei HB434666RBC 1S (4,2V) de 1500mAh pour une 8 heures environ d'autonomie, [Aliexpress](https://fr.aliexpress.com/item/1005007779320044.html?spm=a2g0o.productlist.main.2.4820120fCAlR22&algo_pvid=2b236e09-1e44-4475-8715-a39067711af4&algo_exp_id=2b236e09-1e44-4475-8715-a39067711af4-20&pdp_ext_f=%7B%22order%22%3A%22112%22%2C%22eval%22%3A%221%22%7D&pdp_npi=6%40dis%21EUR%215.81%215.79%21%21%2147.12%2146.96%21%402103835e17565834234122746e262c%2112000042179133702%21sea%21FR%210%21ABX%211%210%21n_tag%3A-29910%3Bd%3A95973152%3Bm03_new_user%3A-29895&curPageLogUid=83VfqMqkhdjr&utparam-url=scene%3Asearch%7Cquery_from%3A%7Cx_object_id%3A1005007779320044%7C_p_origin_prod%3A)
- Régulateur 3,3V Pololu S9V11F3S5C3 avec coupure d'alimentation a 3V afin de préserver la batterie d'une décharge excessive.( https://www.pololu.com/product/2873 ) 10,85 $
- BMS 1S 1A USB-C TP4056 pour la recharge de la batterie interne ( https://www.otronic.nl/fr/chargeur-de-batterie-lithium-18650-avec-usb-c-5v-1.html ) 1,49 Euros
- Interrupteur ON/OFF ( https://www.ebay.fr/itm/251390016446 )
- Boitier imprimé 3D pouvant être porté dans une pochette extérieure

Composants du kit rover RTK2B Ardusimple
 
 - Récepteur RTK L1/L2 Ublox ZED-F9P https://fr.ardusimple.com/product/simplertk2b/ 193 Euros
 - Module bluetooth  BT+BLE bridge Ardusimple, compatible Android et IOS  https://fr.ardusimple.com/product/ble-bridge/ 66 Euros
 - Boitier imprimé 3D https://fr.ardusimple.com/product/plastic-case-simplertk2b/ 49 Euros
 - Antenne multi fréquences pour drones afin d'avoir une antenne de petite taille avec une bonne qualité de réception https://fr.ardusimple.com/product/helical-antenna/ 99 Euros
 -  Manuel BT+BLE bridge pour le connecter au ZED-F9 https://fr.ardusimple.com/btble-bridge-hookup-guide/

   Kit Ardusimple RTK Handheld Surveyor, composants similaires au RTK2B mais livré en lot ce qui est moins cher que le kit RTK2B (livré non monté) Je n'ai pas monté ce kit mais on devrait pouvoir l'utiliser sans la poignée ou le support smartphone si l'on veut, on peut aussi utiliser un powerbank USB-C pour l'alimenter et économiser la batterie du téléphone.
   - https://fr.ardusimple.com/product/rtk-handheld-surveyor-kit/  399 euros
   - Manuel d'assemblage et mise en route avec SWmaps https://fr.ardusimple.com/user-manual-handheld-surveyor-kit/
   - Manuel de configuration U-center https://fr.ardusimple.com/how-to-configure-ublox-zed-f9p/


   Ce projet utilisait au début le récepteur GNSS RTK L1/L2 Ublox ZED-F9R au lieu du ZED-F9P plus courant car il intègre en plus une IMU (centrale inertielle avec gyroscope et accéléromètre) pour compenser les pertes de signal GPS en milieu urbain ou sous un pont/tunnel, le récepteur avec IMU est environ 60 euros plus cher, sa précision est de 2 mètres d'erreur sur 100 mètres pendant une perte de signal sur un véhicule, néanmoins je n'ai pas pu obtenir de bons résultats en mode piéton pour l'instant du fait de mauvaise calibration et alignement de l'IMU sur un piéton, il est donc plutôt recommandé de choisir le ZED-F9P en L1/L2 ou un ZED-X20P L1 L2 L5. Le récepteur devrait être configuré avec le logiciel [U-center](https://www.u-blox.com/en/product/u-center)avant de pouvoir l'utiliser avec le bluetooth et les applications

  Le positionnement RTK (real time kinematic) est un système qui utilise un récepteur mobile (le rover) et des stations (les bases, stations ou moutpoint) qui lui apportent les corrections de position nécessaire pour obtenir une précision pouvant aller jusqu'au centimètre. Pour obtenir une bonne précision il faut etre a moins de 40Km d'une base mais pour notre utilisation on peut aller jusqu'a 70Km, il faut donc une couverture complète du pays avec des stations de corrections et l'accès a ces services est payant par abonnement, depuis quelques années un réseau de stations open source et gratuit s'est développé grâce au agriculteurs: le réseau [centipede](https://docs.centipede.fr) , ce réseau permet de se connecter au stations via un client Ntrip, si il n'y a pas de station dans la région, on peut en construire une avec un faible cout et l'ajouter au réseau, ce qui a permit au réseau centipede de s'agrandir rapidement. Vous pourrez trouver toutes les informations pour construire et connecter sa base ou son rover sur [centipede.fr](https://docs.centipede.fr) . Le réseau centipede est composé a environ 90% de stations au fréquences L1/L2, il est donc préférable de choisir un récepteur RTK en L1/L2 plutôt que la version L1/L5, il existe aussi des versions pro ZED-X20P triple bande L1/L2/L5 un peu plus couteuse (229 euros HT contre 189 euros HT) mais a la qualité de réception et une précision plus robuste  

   Utilisation sur Android
  Pour utiliser en rover RTKanne sur Android et que le smartphone et toutes les applications utilisent la position RTK, vous devrez installer et utiliser l'application Bluetooth GNSS qui se trouve sur le playstore. Pour que Bluetooth GNSS puisse remplacer la position donnée par le récepteur GPS du smartphone par celle donnée par le rover (fonction appelée "Mock Location") vous devrez  passer Android en mode développeur. Une fois Bluetooth GNSS paramètré avec la connexion bluetooth, la connexion au serveur Ntrip centipede.fr et le choix de la station (ou Moutpoint) la plus proche choisi (il y a une fonction pour choisir la plus proche automatiquement), vous lancez la connexion avec le bouton en bas a droite et la position RTK sera utilisée par toutes les applications qui seront lancées ensuite, mais il faut garder bluetooth GNSS en fond de tache. 

	Utilisation sur IOS
   L'application Sonarvision est disponible avec l'option RTK depuis mi 2025 avec de nouvelles fonctionnalités afin de profiter pleinement des possibilités du RTK comme l'enregistrement de traces GPX pour créer un parcours, pour tester le bon fonctionnement du Rover RTKanne, vous pouvez aussi utiliser SWmaps disponible sur l'apple store ou installer le code de Client Ntrip présent sur ce dépôt a l'aide de Xcode, il faut installer Xcode sur un Mac, charger et compiler le code de Client Ntrip, connecter l'iPhone en mode développeur au Mac pour créer cette application. Les paramètres Ntrip de centipede sont déjà configurés et on peut afficher les coordonnées de position, le nombre de satellites reçus, la précision de la position, l'état de la connexion a centipede.fr

	Schéma de connexion
    Le récepteur est connecté au module bluetooth par les connecteurs TX et RX en croisant les entrée/sortie TX>RX et RX>TX. Les 2 modules sont alimentés par la sortie 3,3volts du régulateur Pololu, celui ci est branché sur la sortie batterie du BMS via l'interrupteur. La batterie est aussi connectée au chargeur (BMS) USB-C. La batterie est logée dans le compartiment de l'autre coté du boitier.

Vous trouverez plus d'infos sur la configuration du récepteur dans le [Wiki](https://github.com/Francklin2/RTKanne/wiki)  


  ![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Schema_GNSS-RTK.jpg)  

  ![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/Boitier-ouvert.jpg)

<<<<<<< HEAD
![Github Logo](https://github.com/Francklin2/RTKanne/blob/main/Images/BlueRTK-ouvert.jpg)

   J'ai testé d'autres récepteur RTK Navspark PX1122R (L1/L2) et PX1125R (L1/L5) moins couteux dont le prix total du récepteur devrait se situer autour de 200 euros, cela fonctionne mais les résultats sur le terrain sont moins bon qu'avec les Ublox: le récepteur est un peu moins sensible et capte moins de satellites (20 contre 30) et le RTK est un peu moins stable en conditions difficile. Cela reste une solution low cost opérationnelle mais pour une navigation plus fiable je recommande plutôt les récepteurs Ublox.  les schémas de connexion pour les Navspark sont aussi disponibles dans le wiki

Le module Bluetooth Seeed studio Xiao ESP32C3 est une bonne alternative au Bluetooth BT+BLE Ardusimple si on n'utilise que IOS (ne ne se connecte pas a Bluetooth GNSS sur Android) il ne coute que 7 euros environ et fonctionne très bien. Il u a 2 versions du code: XIAO ESP32C3-BLE est optimisée pour les récepteurs Navspark tandis que la version XIAO ESP32C3-V2 est optimisée pour les récepteurs Ublox. 





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
     
  
