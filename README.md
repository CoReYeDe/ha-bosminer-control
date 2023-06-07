# HA-BOSMiner-Control

## Steuerung von Antminer S9 und S19-Minern über Home Assistant mit BOS-Firmware

Das Ziel dieses Projekts ist es, die Steuerung von Antminer S9-Minern mit der BOS-Firmware über die Home Assistant Plattform zu ermöglichen. Zukünftig ist geplant, auch S19-Miner zu unterstützen. Durch diese Integration können Benutzer ihre Bitcoin-Mining-Hardware einfach über die Home Assistant-Oberfläche verwalten.

Die Basis ist in diesem Fall (noch) kein HACS-Addon sondern eine Integration via Sensor- und CommandLine-Entitäten die via API die Daten des Miners auslesen und in HA zur Verfügung stellen, sowie ein Bash-Script zur Änderung von Konfigurationsparameter via SSH, direkt auf dem Miner.

###
Aktuell unterstützt und getestet werden AntMiner S9 mit BOS-Firmware
* 22.05
* 22.08.1-plus (2022-09-27-0-26ba61b9)
### Hauptfunktionen:
* volle Kontrolle und Anpassbarkeit der Rest-Calls, CLI-Commands und Sensoren
* Steuerung mehrerer Miner
* Konfiguration und Überwachung der Miner: Anpassung und Überwachung von Einstellungen wie Hashrate, Lüftergeschwindigkeit, Spannung und Temperatur über die Home Assistant-Oberfläche.
* Automatisierung und Benachrichtigungen: Erstellung von Automatisierungen basierend auf bestimmten Ereignissen, z. B. das Überschreiten von Schwellenwerten für die Hashrate oder Temperatur. Benachrichtigungen bei wichtigen Ereignissen per App oder E-Mail.
* Energieeffizienzoptimierung: Einstellung der Miner für eine optimierte Leistung und Energieeffizienz, um Betriebskosten zu senken und Umweltauswirkungen zu reduzieren.
### Zukünftige Pläne:

* Erweiterung der Unterstützung für S19-Miner, um auch diese leistungsstarken und energieeffizienten Modelle in das Home Assistant-System zu integrieren.
Das Projekt strebt danach, eine benutzerfreundliche Lösung für die Steuerung von Antminer S9- und S19-Minern mit BOS-Firmware über Home Assistant anzubieten. Durch die Integration dieser Mining-Hardware in eine etablierte Smart-Home-Plattform wird die Verwaltung und Überwachung des Mining-Prozesses vereinfacht und optimiert.

# Komponenten

## configuration.yaml
Enthält die notwendigen Helper für die TargetPower als InputNumber sowie einen InputText mit der IP-Adresse des Miners.
Ausserdem die shell_command-Entitäten um via HA das BashScript nutzen zu können.
## automations.yaml
Wenn das zB. Card-Example verwendet wird, sorgt diese Automatisierung dafür, dass 3 Sekunden nach Änderung der TargetPower diese auch im Miner gesetzt und dieser neugestartet wird.

## sensors.yaml
Enthält die notwendigen command_line-Sensoren für die Abfrage der Rest-API von BOS (https://docs.braiins.com/os/plus-en/Development/1_api.html#new-commands)
Die Daten werden als JSON in HA hinterlegt und die weiteren Template-Sensoren nutzen diese als Basis, um die eigentlichen Werte zu extrahieren und ebenfalls in HA verfügbar zu machen.

## ssh_scripts/control_miner.sh
Das Herzstück für die Steuerung des Miner auf Basis von SSH-Connect und Bearbeitung der BOS-TOML-Configuration-Files
Kann beliebig angepasst (andere BOS-Versionen) oder um weitere Konfigurationsmöglichkeiten erweitert werden
Aktuell implementiert und getestet:
* Änderung der TargetPower mit anschließendem Neustart des Miners
* Pause und Resume des Miners
## card-example.yaml
Hier ist ein Beispiel-Dashboard als Basis für eure UI-Integration
Verwendete Cards:
* stack-in-card (https://github.com/custom-cards/stack-in-card)
* conditional (https://www.home-assistant.io/dashboards/conditional/)
* mushroom-template-card (https://github.com/piitaya/lovelace-mushroom)
* mushroom-number-card (https://github.com/piitaya/lovelace-mushroom)

# Installation
* Je nachdem wie deine HA-Konfigurationen organisiert sind, muss der Inhalt der configuration.yaml, sensors.yaml, automations.yaml in deine Konfigurationen integriert werden
* card-example.yaml kann Copy&Paste ins Dashboard eingebaut werden
* ssh_scripts/control_miner.sh muss im Config-Ordner von HA abgelegt werden (Alternativer Pfad ab Config ist möglich, muss dann aber in der configuration.yaml angepasst werden) - Je nach HA-Hostsystem muss das Script mit chmod +x config/ssh_scripts/control_miner.sh ausführbar gemacht werden