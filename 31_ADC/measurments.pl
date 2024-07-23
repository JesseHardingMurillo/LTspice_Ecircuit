#!/usr/bin/perl
# Este script genera un archivo de medidas para simulaciones en LTspice

# Modules used
use strict; # Usar pragmas estrictas para atrapar errores comunes
use warnings; # Activar advertencias para ayudar en la depuración

# Establecer el nombre del archivo de medidas de salida
my $meas_file = './meas_ADC_DAC.meas';

# Establecer el numero de bits
my $n_bits = 8;
#my @bits = reverse (0..($n_bits-1));

# Abrir el archivo de medidas en modo escritura
open(FH, '>', $meas_file) or die $!;

# Definir los eventos para los parámetros de subida y bajada
my @range_event = (0..4);

#Lista de mediciones del ATB
my @atb_measurments = ("quantization_step_size",
"quantization_level",
"quantization_level_range_from",
"quantization_level_range_to");

# Escribir una línea de prueba en el archivo de medidas
print FH "*------------------------------------------------------------------------------------------------------------------------","\n";
print FH "*ADC & DAC MEASURMENTS"."\n";
print FH "*------------------------------------------------------------------------------------------------------------------------","\n";

#PRINT PARAMETERS
#AUTOMATIZAR CALCULO**************************************************
print FH ".PARAM 	T_Interval  100U","\n";
print FH ".PARAM 	TD1 {T_Interval+TD2}","\n";
print FH ".PARAM 	TD2 10U","\n";
print FH ".MEAS TRAN VclkMax 					Max V(CLK)","\n";
print FH ".MEAS TRAN Vclk_counter_max 			Max V(clk_counter)","\n";
#print FH ".MEAS TRAN ATB			    Max V(ATB)"."\n";
print FH "*------------------------------------------------------------------------------------------------------------------------","\n";
foreach my $event (@range_event){  
	my $rise = $event+1;
	
	if ($event ==  4){
		print FH ".MEAS TRAN ______________________________________EVENT_$event\_______________________________________ PARAM 0","\n";
		print FH ".MEAS TRAN T_Edge_EV$event			FIND TIME WHEN V(CLK) = {VclkMax/2} FALL = $event ","\n";
		#Crear un lista de nombres y nodos que voy a medir
		print FH ".MEAS TRAN V_Ain_at_EV$event			AVG V(in) 			TRIG TIME={t_simulation_stop-TD1} Targ TIME={t_simulation_stop-TD2}". "\n";
		print FH ".MEAS TRAN V_Sample_at_EV$event		AVG V(in_sample) 	TRIG TIME={t_simulation_stop-TD1} Targ TIME={t_simulation_stop-TD2}". "\n"; 
		print FH ".MEAS TRAN V_Aout_at_EV$event			AVG V(out_dac) 		TRIG TIME={t_simulation_stop-TD1} Targ TIME={t_simulation_stop-TD2}". "\n"; 
		print FH ".MEAS TRAN V_VDD_at_EV$event			AVG V(VDD) 			TRIG TIME={t_simulation_stop-TD1} Targ TIME={t_simulation_stop-TD2}". "\n"; 
		
		print FH ".MEAS TRAN -----------------------DAC_EVENT_$event\---------------------- PARAM 0","\n";
		foreach my $bit (reverse (0..($n_bits-1))){
		print FH ".MEAS TRAN V_Dout$bit\_at_EV$event 	AVG V(out[$bit]) 	TRIG TIME={t_simulation_stop-TD1} Targ TIME={t_simulation_stop-TD2}". "\n"; 
		}
		
		# Construir la expresión ADC_DECIMAL dinámicamente
		my $adc_decimal_expr = ".MEAS TRAN ADC_DECIMAL_EV$event PARAM {";

		# Iterar sobre los bits de forma decreciente
		foreach my $bit (reverse (0..($n_bits-1))){
			# Calculo del peso para cada bit
			$adc_decimal_expr .= "V_Dout$bit\_at_EV$event * 2**$bit";
			$adc_decimal_expr .= " + " if $bit > 0;  # Agregar '+' excepto después del último término
		}		

		# Para cerrar el parentesis
		$adc_decimal_expr .= "}";
		print FH $adc_decimal_expr . "\n";
		
		print FH ".MEAS TRAN Quantization_error_left_EV$event PARAM {ABS(V_Sample_at_EV$event-(ADC_DECIMAL_EV$event\*V_VDD_at_EV$event\/2**$n_bits))} "."\n";
		print FH ".MEAS TRAN Quantization_error_right_EV$event PARAM {ABS(V_Sample_at_EV$event-((ADC_DECIMAL_EV$event+1)\*V_VDD_at_EV$event\/2**$n_bits))} "."\n";
		print FH "*------------------------------------------------------------------------------------------------------------------------","\n";
	}
	
	else{
		print FH ".MEAS TRAN ______________________________________EVENT_$event\_______________________________________ PARAM 0","\n";
		print FH ".MEAS TRAN T_Edge_EV$event			FIND TIME WHEN V(CLK) = {VclkMax/2} RISE = $rise ","\n";
		print FH ".MEAS TRAN V_Ain_at_EV$event			AVG V(in) 			TRIG TIME={T_Edge_EV$event-TD1} Targ TIME={T_Edge_EV$event-TD2}". "\n"; 
		print FH ".MEAS TRAN V_Sample_at_EV$event		AVG V(In_sample)  	TRIG TIME={T_Edge_EV$event-TD1} Targ TIME={T_Edge_EV$event-TD2}". "\n"; 
		print FH ".MEAS TRAN V_Aout_at_EV$event			AVG V(out_dac) 		TRIG TIME={T_Edge_EV$event-TD1} Targ TIME={T_Edge_EV$event-TD2}". "\n"; 
		print FH ".MEAS TRAN V_VDD_at_EV$event			AVG V(VDD) 			TRIG TIME={T_Edge_EV$event-TD1} Targ TIME={T_Edge_EV$event-TD2}". "\n"; 
			
		
		print FH ".MEAS TRAN -----------------------DAC_EVENT_$event\---------------------- PARAM 0","\n";
		
		foreach my $bit (reverse (0..($n_bits-1))){
			print FH ".MEAS TRAN V_Dout$bit\_at_EV$event 	AVG V(out[$bit]) 	TRIG TIME={T_Edge_EV$event-TD1} Targ TIME={T_Edge_EV$event-TD2}","\n";	
		}
		
		# Construir la expresión ADC_DECIMAL dinámicamente
		my $adc_decimal_expr = ".MEAS TRAN ADC_DECIMAL_EV$event PARAM {";

		# Iterar sobre los bits de forma decreciente
		foreach my $bit (reverse (0..($n_bits-1))){
			# Calculo del peso para cada bit
			$adc_decimal_expr .= "(V_Dout$bit\_at_EV$event*(2**$bit))";
			$adc_decimal_expr .= "+" if $bit > 0;  # Agregar '+' excepto después del último término
		}		

		# Para cerrar el parentesis
		$adc_decimal_expr .= "}";
		print FH $adc_decimal_expr . "\n";
		
		print FH ".MEAS TRAN Quantization_error_left_EV$event PARAM {ABS(V_Sample_at_EV$event-(ADC_DECIMAL_EV$event\*V_VDD_at_EV$event\/2**$n_bits))} "."\n";
		print FH ".MEAS TRAN Quantization_error_right_EV$event PARAM {ABS(V_Sample_at_EV$event-((ADC_DECIMAL_EV$event+1)\*V_VDD_at_EV$event\/2**$n_bits))} "."\n";
		print FH "*------------------------------------------------------------------------------------------------------------------------","\n";
	}
	}


close(FH);
print("Writting to file successfully!", "\n");
