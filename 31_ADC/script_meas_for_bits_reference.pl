#!/usr/bin/perl
# Este script genera un archivo de medidas para simulaciones en LTspice

# Modules used
use strict; # Usar pragmas estrictas para atrapar errores comunes
use warnings; # Activar advertencias para ayudar en la depuración

# Establecer el nombre del archivo de medidas de salida
my $meas_file = './../dac_8bits/meas_for_4bits.meas';

# Abrir el archivo de medidas en modo escritura
open(FH, '>', $meas_file) or die $!;

# Escribir una línea de prueba en el archivo de medidas
print FH "*DAC_TEST"."\n";

# Definir los nombres de los nodos del circuito
my @node = ("out_dac_4bits", "out_dac_4bits_r2r");
my @node2 = ("a0", "a1","a2", "a3");

# Definir los eventos para los parámetros de subida y bajada
my @range_event_time = (1..16); 

# Escribir una medida para obtener el valor máximo del voltaje 'trigger'
print FH ".meas tran v_trigger_max max(v(trigger))","\n";

# Obtener mediciones del tiempo de subida y bajada del voltaje 'trigger'
foreach my $index_t (@range_event_time){
    # Medir el tiempo de bajada
    print FH ".meas tran t_event_fall_$index_t find time when v(trigger)= (v_trigger_max/2) fall=$index_t"."\n";

}

# Obtener mediciones del voltaje de salida con respecto a los eventos de tiempo de subida y bajada
foreach my $index_t (@range_event_time){  
	my $step =  $index_t-1;
	print FH ".meas tran ______input_$step\_______ PARAM 0=0 ","\n";                                                      
    foreach my $index_n (0..$#node2){
		print FH ".meas tran v_$node2[$index_n]_t$step FIND V($node2[$index_n]) when time=t_event_fall_$index_t","\n";
    }
    # Convertir de binario a decimal
    print FH ".MEAS TRAN V_t$step\_B_TO_D PARAM ((2**3)*v_a3_t$step+(2**2)*v_a2_t$step+(2**1)*v_a1_t$step+(2**0)*v_a0_t$step)/5","\n";
    
    print FH ".meas tran ______out_$step\_______ PARAM 0=0 ","\n"; 
     foreach my $index_n (0..$#node){
		print FH ".meas tran v_$node[$index_n]_t$step FIND V($node[$index_n]) when time=t_event_fall_$index_t  ","\n";
    }
}


# Cerrar el archivo de medidas
close(FH);

# Indicar que el proceso de escritura en el archivo fue exitoso
print ("Writting to file successfully!","\n");
