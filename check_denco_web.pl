#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use HTML::TagParser;

my $VERSION = "Version 1.0";
my $AUTHOR = '(c) 2019 Stephen Furniss <steve@furnissathome.co.uk>';
my %opts;
getopts('hw:c:s:U:V', \%opts);

# Exit codes
my $STATE_OK = 0;
my $STATE_WARNING = 1;
my $STATE_CRITICAL = 2;
my $STATE_UNKNOWN = 3;

# Default values:
my $sensor_regex = 'TEMP';
my $target_url = 'http://192.168.0.4/http/index.html';

my $error = 0;
my $default_thresh_warn = 24;
my $default_thresh_crit = 30;
my $thresh_warn = '';
my $thresh_crit = '';
my $matched_pattern = 0;
my $message = '';
my %temp_hash;
my $temp_list = '';

my $ControlAirTemp;
my @ControlAirTempData;
my $ControlAirHumidity;
my @ControlAirHumidityData;
my $CoolingDemand;
my @CoolingDemandData;
my $HeatingDemand;
my @HeatingDemandData;
my $HumidityDemand;
my @HumidityDemandData;
my $DehumDemand;
my @DehumDemandData;
my $AirflowFail;
my @AirflowFailData;
my $FilterBlocked;
my @FilterBlockedData;
my $WaterDetection;
my @WaterDetectionData;
my $AuxiliaryAlarm;
my @AuxiliaryAlarmData;
my $HighControlTemp;
my @HighControlTempData;
my $LowControlTemp;
my @LowControlTempData;
my $HighControlHumidity;
my @HighControlHumidityData;
my $LowControlHumidity;
my @LowControlHumidityData;
my $KlixonTrip;
my @KlixonTripData;
my $Compressor1HPTrip;
my @Compressor1HPTripData;
my $Compressor2HPTrip;
my @Compressor2HPTripData;
my $Compressor3HPTrip;
my @Compressor3HPTripData;
my $Compressor4HPTrip;
my @Compressor4HPTripData;
my $Circuit1VRFHPTrip;
my @Circuit1VRFHPTripData;
my $Circuit2VRFHPTrip;
my @Circuit2VRFHPTripData;
my $Compressor1LPTrip;
my @Compressor1LPTripData;
my $Compressor2LPTrip;
my @Compressor2LPTripData;
my $Compressor3LPTrip;
my @Compressor3LPTripData;
my $Compressor4LPTrip;
my @Compressor4LPTripData;
my $Circuit1VRFLPTrip;
my @Circuit1VRFLPTripData;
my $Circuit2VRFLPTrip;
my @Circuit2VRFLPTripData;
my $DenconetCommsFailure;
my @DenconetCommsFailureData;
my $HumidifierCylinderExhausted;
my @HumidifierCylinderExhaustedData;
my $RefrigerantLeakDetection;
my @RefrigerantLeakDetectionData;


# Parse command line options
if ($opts{'h'}) {
	&print_help();
	exit($STATE_OK);
}

if (! defined $opts{'w'}) {
	# Warning not provided
	$thresh_warn = $default_thresh_warn;
} elsif ($opts{'w'} =~ /^\d+$/) {
	# Warning is an integer
	$thresh_warn = $opts{'w'};
} else {
	# Warning is not an integer
	print "Warning must be an integer\n";
}

if (! defined $opts{'c'}) {
	# Critical not provided
	$thresh_crit = $default_thresh_crit;
} elsif ($opts{'c'} =~ /^\d+$/) {
	# Critical is an integer
	if ($opts{'c'} <= $opts{'w'}) {
		print "Critical -c must be greater than Warning -w\n";
		exit($STATE_UNKNOWN);
	} else {
		$thresh_crit = $opts{'c'};
	}
} else {
	# Critical is not an integer
	print "Critical must be an integer\n";
}

if (defined $opts{'s'}) {
	if ($opts{'s'} ne '') {
		# Sensor argument provided:
		if (uc $opts{'s'} eq 'ALARMS'){
			#match to ALARMS
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'TEMP'){
			#no match to TEMP
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'HUMIDITY'){
			#no match to HUMIDITY
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'COOLDEMAND'){
			#no match to COOLDEMAND
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'HEATDEMAND'){
			#no match to HEATDEMAND
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'HUMIDDEMAND'){
			#no match to HUMIDDEMAND
			$matched_pattern = 1;
		}elsif (uc $opts{'s'} eq 'DEHUMDEMAND'){
			#no match to DEHUMDEMAND
			$matched_pattern = 1;
		}
		if ($matched_pattern == 0){
			print "Valid Sensor arguments are:- (TEMP: HUMIDITY: COOLDEMAND: HEATDEMAND: HUMIDDEMAND: DEHUMDEMAND: ALARMS)";
			exit($STATE_UNKNOWN);	
		}
		$sensor_regex = uc $opts{'s'};
	}
}

if (defined $opts{'U'}) {
    if ($opts{'U'} ne '') {
        # URL argument provided:
        $target_url = $opts{'U'};
    }
}

if (defined $opts{'V'}) {
    if ($opts{'V'} ne '') {
        # Version requested:
        print "$VERSION\n";
		exit($STATE_OK);
    }
}


################################
# loop for values from webpage #
################################
my $html = HTML::TagParser->new($target_url);
my $nrow = 0;

for my $tr ( $html->getElementsByTagName("p" ) ) {
		if ($nrow == 12) {
				$ControlAirTemp = $tr->innerText();
		}elsif ($nrow == 43) {
                @ControlAirTempData = split /&/, $tr->innerText();
        }elsif ($nrow == 13) {
                $ControlAirHumidity = $tr->innerText();
        }elsif ($nrow == 44) {
				@ControlAirHumidityData = split /&/, $tr->innerText();
		}elsif ($nrow == 14) {
				$CoolingDemand = $tr->innerText();
		}elsif ($nrow == 45) {
				@CoolingDemandData = split /&/, $tr->innerText();
		}elsif ($nrow == 15) {
				$HeatingDemand = $tr->innerText();
		}elsif ($nrow == 46) {
				@HeatingDemandData = split /&/, $tr->innerText();
		}elsif ($nrow == 16) {
				$HumidityDemand = $tr->innerText();
		}elsif ($nrow == 47) {
				@HumidityDemandData = split /&/, $tr->innerText();
		}elsif ($nrow == 17) {
				$DehumDemand = $tr->innerText();
		}elsif ($nrow == 48) {
				@DehumDemandData = split /&/, $tr->innerText();
		}elsif ($nrow == 19) {
				$AirflowFail = $tr->innerText();
		}elsif ($nrow == 49) {
				@AirflowFailData = split /&/, $tr->innerText();
				if ($AirflowFailData[0] == 1){
					$error++;
					$message .= " $AirflowFail:";
				}
		}elsif ($nrow == 20) {
				$FilterBlocked = $tr->innerText();
		}elsif ($nrow == 50) {
				@FilterBlockedData = split /&/, $tr->innerText();
				if ($FilterBlockedData[0] == 1){
					$error++;
					$message .= " $FilterBlocked:";
				}
		}elsif ($nrow == 21) {
				$WaterDetection = $tr->innerText();
		}elsif ($nrow == 51) {
				@WaterDetectionData = split /&/, $tr->innerText();
				if ($WaterDetectionData[0] == 1){
					$error++;
					$message .= " $WaterDetection:";
				}
		}elsif ($nrow == 22) {
				$AuxiliaryAlarm = $tr->innerText();
		}elsif ($nrow == 52) {
				@AuxiliaryAlarmData = split /&/, $tr->innerText();
				if ($AuxiliaryAlarmData[0] == 1){
					$error++;
					$message .= " $AuxiliaryAlarm:";
				}
		}elsif ($nrow == 23) {
				$HighControlTemp = $tr->innerText();
		}elsif ($nrow == 53) {
				@HighControlTempData = split /&/, $tr->innerText();
				if ($HighControlTempData[0] == 1){
					$error++;
					$message .= " $HighControlTemp:";
				}
		}elsif ($nrow == 24) {
				$LowControlTemp = $tr->innerText();
		}elsif ($nrow == 54) {
				@LowControlTempData = split /&/, $tr->innerText();
				if ($LowControlTempData[0] == 1){
					$error++;
					$message .= " $LowControlTemp:";
				}
		}elsif ($nrow == 25) {
				$HighControlHumidity = $tr->innerText();
		}elsif ($nrow == 55) {
				@HighControlHumidityData = split /&/, $tr->innerText();
				if ($HighControlHumidityData[0] == 1){
					$error++;
					$message .= " $HighControlHumidity:";
				}
		}elsif ($nrow == 26) {
				$LowControlHumidity = $tr->innerText();
		}elsif ($nrow == 56) {
				@LowControlHumidityData = split /&/, $tr->innerText();
				if ($LowControlHumidityData[0] == 1){
					$error++;
					$message .= " $LowControlHumidity:";
				}
		}elsif ($nrow == 27) {
				$KlixonTrip = $tr->innerText();
		}elsif ($nrow == 57) {
				@KlixonTripData = split /&/, $tr->innerText();
				if ($KlixonTripData[0] == 1){
					$error++;
					$message .= " $KlixonTrip:";
				}
		}elsif ($nrow == 28) {
				$Compressor1HPTrip = $tr->innerText();
		}elsif ($nrow == 58) {
				@Compressor1HPTripData = split /&/, $tr->innerText();
				if ($Compressor1HPTripData[0] == 1){
					$error++;
					$message .= " $Compressor1HPTrip:";
				}
		}elsif ($nrow == 29) {
				$Compressor2HPTrip = $tr->innerText();
		}elsif ($nrow == 59) {
				@Compressor2HPTripData = split /&/, $tr->innerText();
				if ($Compressor2HPTripData[0] == 1){
					$error++;
					$message .= " $Compressor2HPTrip:";
				}
		}elsif ($nrow == 30) {
				$Compressor3HPTrip = $tr->innerText();
		}elsif ($nrow == 60) {
				@Compressor3HPTripData = split /&/, $tr->innerText();
				if ($Compressor3HPTripData[0] == 1){
					$error++;
					$message .= " $Compressor3HPTrip:";
				}
		}elsif ($nrow == 31) {
				$Compressor4HPTrip = $tr->innerText();
		}elsif ($nrow == 61) {
				@Compressor4HPTripData = split /&/, $tr->innerText();
				if ($Compressor4HPTripData[0] == 1){
					$error++;
					$message .= " $Compressor4HPTrip:";
				}
		}elsif ($nrow == 32) {
				$Circuit1VRFHPTrip = $tr->innerText();
		}elsif ($nrow == 62) {
				@Circuit1VRFHPTripData = split /&/, $tr->innerText();
				if ($Circuit1VRFHPTripData[0] == 1){
					$error++;
					$message .= " $Circuit1VRFHPTrip:";
				}
		}elsif ($nrow == 33) {
				$Circuit2VRFHPTrip = $tr->innerText();
		}elsif ($nrow == 63) {
				@Circuit2VRFHPTripData = split /&/, $tr->innerText();
				if ($Circuit2VRFHPTripData[0] == 1){
					$error++;
					$message .= " $Circuit2VRFHPTrip:";
				}
		}elsif ($nrow == 34) {
				$Compressor1LPTrip = $tr->innerText();
		}elsif ($nrow == 64) {
				@Compressor1LPTripData = split /&/, $tr->innerText();
				if ($Compressor1LPTripData[0] == 1){
					$error++;
					$message .= " $Compressor1LPTrip:";
				}
		}elsif ($nrow == 35) {
				$Compressor2LPTrip = $tr->innerText();
		}elsif ($nrow == 65) {
				@Compressor2LPTripData = split /&/, $tr->innerText();
				if ($Compressor2LPTripData[0] == 1){
					$error++;
					$message .= " $Compressor2LPTrip:";
				}
		}elsif ($nrow == 36) {
				$Compressor3LPTrip = $tr->innerText();
		}elsif ($nrow == 66) {
				@Compressor3LPTripData = split /&/, $tr->innerText();
				if ($Compressor3LPTripData[0] == 1){
					$error++;
					$message .= " $Compressor3LPTrip:";
				}
		}elsif ($nrow == 37) {
				$Compressor4LPTrip = $tr->innerText();
		}elsif ($nrow == 67) {
				@Compressor4LPTripData = split /&/, $tr->innerText();
				if ($Compressor4LPTripData[0] == 1){
					$error++;
					$message .= " $Compressor4LPTrip:";
				}
		}elsif ($nrow == 38) {
				$Circuit1VRFLPTrip = $tr->innerText();
		}elsif ($nrow == 68) {
				@Circuit1VRFLPTripData = split /&/, $tr->innerText();
				if ($Circuit1VRFLPTripData[0] == 1){
					$error++;
					$message .= " $Circuit1VRFLPTrip:";
				}
		}elsif ($nrow == 39) {
				$Circuit2VRFLPTrip = $tr->innerText();
		}elsif ($nrow == 69) {
				@Circuit2VRFLPTripData = split /&/, $tr->innerText();
				if ($Circuit2VRFLPTripData[0] == 1){
					$error++;
					$message .= " $Circuit2VRFLPTrip:";
				}
		}elsif ($nrow == 40) {
				$DenconetCommsFailure = $tr->innerText();
		}elsif ($nrow == 70) {
				@DenconetCommsFailureData = split /&/, $tr->innerText();
				if ($DenconetCommsFailureData[0] == 1){
					$error++;
					$message .= " $DenconetCommsFailure:";
				}
		}elsif ($nrow == 41) {
				$HumidifierCylinderExhausted = $tr->innerText();
		}elsif ($nrow == 71) {
				@HumidifierCylinderExhaustedData = split /&/, $tr->innerText();
				if ($HumidifierCylinderExhaustedData[0] == 1){
					$error++;
					$message .= " $HumidifierCylinderExhausted:";
				}
		}elsif ($nrow == 42) {
				$RefrigerantLeakDetection = $tr->innerText();
		}elsif ($nrow == 72) {
				@RefrigerantLeakDetectionData = split /&/, $tr->innerText();
				if ($RefrigerantLeakDetectionData[0] == 1){
					$error++;
					$message .= " $RefrigerantLeakDetection:";
				}
		}
	##########################################################
	# Uncomment this print statement to identify row numbers #
	##########################################################
	#print "Row [$nrow], Value [" . $tr->innerText() . "]\n";
	
    $nrow++;
}

if ($sensor_regex eq 'TEMP'){
	if($ControlAirTempData[0] <= $thresh_warn){
			print "OK: $ControlAirTemp $ControlAirTempData[0]°C|'Temp C'=$ControlAirTempData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($ControlAirTempData[0] <= $thresh_crit){
			print "WARNING: $ControlAirTemp $ControlAirTempData[0]°C|'Temp C'=$ControlAirTempData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $ControlAirTemp $ControlAirTempData[0]°C|'Temp C'=$ControlAirTempData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'HUMIDITY'){
	if($ControlAirHumidityData[0] <= $thresh_warn){
			print "OK: $ControlAirHumidity $ControlAirHumidityData[0]%|'Humidity'=$ControlAirHumidityData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($ControlAirHumidityData[0] <= $thresh_crit){
			print "WARNING: $ControlAirHumidity $ControlAirHumidityData[0]%|'Humidity'=$ControlAirHumidityData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $ControlAirHumidity $ControlAirHumidityData[0]%|'Humidity'=$ControlAirHumidityData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'COOLDEMAND'){
	if($CoolingDemandData[0] <= $thresh_warn){
			print "OK: $CoolingDemand $CoolingDemandData[0]%|'Cooling Demand'=$CoolingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($CoolingDemandData[0] <= $thresh_crit){
			print "WARNING: $CoolingDemand $CoolingDemandData[0]%|'Cooling Demand'=$CoolingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $CoolingDemand $CoolingDemandData[0]%|'Cooling Demand'=$CoolingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'HEATDEMAND'){
	if($HeatingDemandData[0] <= $thresh_warn){
			print "OK: $HeatingDemand $HeatingDemandData[0]%|'Heating Demand'=$HeatingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($HeatingDemandData[0] <= $thresh_crit){
			print "WARNING: $HeatingDemand $HeatingDemandData[0]%|'Heating Demand'=$HeatingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $HeatingDemand $HeatingDemandData[0]%|'Heating Demand'=$HeatingDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'HUMIDDEMAND'){
	if($HumidityDemandData[0] <= $thresh_warn){
			print "OK: $HumidityDemand $HumidityDemandData[0]%|'Humidity Demand'=$HumidityDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($HumidityDemandData[0] <= $thresh_crit){
			print "WARNING: $HumidityDemand $HumidityDemandData[0]%|'Humidity Demand'=$HumidityDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $HumidityDemand $HumidityDemandData[0]%|'Humidity Demand'=$HumidityDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'DEHUMDEMAND'){
	if($DehumDemandData[0] <= $thresh_warn){
			print "OK: $DehumDemand $DehumDemandData[0]%|'Dehum Demand'=$DehumDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_OK);
			
	}elsif ($DehumDemandData[0] <= $thresh_crit){
			print "WARNING: $DehumDemand $DehumDemandData[0]%|'Dehum Demand'=$DehumDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_WARNING);
	}else {
			print "CRITICAL: $DehumDemand $DehumDemandData[0]%|'Dehum Demand'=$DehumDemandData[0];$thresh_warn;$thresh_crit";
			exit($STATE_CRITICAL);
	}
}

if ($sensor_regex eq 'ALARMS'){
	if ($error ne 0){
		if($message eq ' Denconet Comms Failure:'){
			print "WARNING:$message";
			exit($STATE_WARNING);
		}elsif ($message eq ' Filter Blocked:'){
			print "WARNING:$message";
			exit($STATE_WARNING);
		}elsif ($message eq ' Auxiliary Alarm:'){
			print "WARNING:$message";
			exit($STATE_WARNING);
		}elsif ($message eq ' Humidifier Cylinder Exhausted:'){
			print "WARNING:$message";
			exit($STATE_WARNING);
		}
		print "CRITICAL:$message";
		exit($STATE_CRITICAL);
	}else {
		print "OK: No Alarms";
		exit($STATE_OK);
	}
}

###################################
# Start Subs:
###################################
sub print_help() {
        print << "EOF";
		
Monitor temperature of Denco Aircon Units

$VERSION
$AUTHOR

Options:
-h
   Print detailed help screen
-s 'STRING'
   Select what to monitor. 
   
   The following keyword are valid:-
   
   (TEMP: HUMIDITY: COOLDEMAND: HEATDEMAND: HUMIDDEMAND: DEHUMDEMAND: ALARMS)
   
   for example TEMP would return the value for 'Control Air Temperature'. Default is TEMP.
   
-w INTEGER
   If not set default is $default_thresh_warn
-c INTEGER
   if not set default is $default_thresh_crit
-U 'STRING'
   Set to target URL of the Denco Aircon unit e.g. http://192.168.0.4/http/index.html
-V
   List script version

EOF
}
