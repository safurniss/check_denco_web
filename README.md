# check_denco_web
Nagios check for Denco Air Conditioning units

+++ Installation +++

Copy the perl file to your libexec folder on the Nagios server.
Set permissions on the perl file to 0755.

+++ Usage +++

$USER1$/check_denco_web.pl $ARG1$ $ARG2$ $ARG3$ $ARG4$

$ARG1$ -w = warning value (can be blank)

$ARG2$ -c = critical value (can be blank)

$ARG3$ -U = URL target (URL of the Denco aircon web page)

$ARG4$ -s = SENSOR to check (TEMP: HUMIDITY: COOLDEMAND: HEATDEMAND: HUMIDDEMAND: DEHUMDEMAND: ALARMS)


All Sensors except ALARMS can accept warning and critical values. The URL must be supplied or it will default to http://192.168.0.4

+++ Examples +++

check_denco_web.pl -w 24 -c 45 -U http://192.168.0.4/http/index.html -s TEMP

check_denco_web.pl -w 24 -c 45 -U http://192.168.0.4/http/index.html -s HUMIDITY

check_denco_web.pl -U http://192.168.0.4/http/index.html -s ALARMS

+++ ALARMS Monitored +++

The following alarm statuses are monitored and will create a critical alert if any have a status of "1" with the exception of "Filter Blocked, Auxiliary Alarm, Denconet Comms Failure, Humidifier Cylinder Exhausted" which will go warning:-

Airflow Fail

Filter Blocked

Water Detection

Auxiliary Alarm

High Control Temperature

Low Control Temperature

High Control Humidity

Low Control Humidity

Klixon Trip

Compressor 1 HP Trip

Compressor 2 HP Trip

Compressor 3 HP Trip

Compressor 4 HP Trip

Circuit 1 (VRF) HP Trip

Circuit 2 (VRF) HP Trip

Compressor 1 LP Trip

Compressor 2 LP Trip

Compressor 3 LP Trip

Compressor 4 LP Trip

Circuit 1 (VRF) LP Trip

Circuit 2 (VRF) LP Trip

Denconet Comms Failure

Humidifier Cylinder Exhausted

Refrigerant Leak Detection
