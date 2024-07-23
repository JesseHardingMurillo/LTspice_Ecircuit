#!/usr/bin/perl

# Modules used
use strict;
use warnings;

#my $meas_file = './meas_from_perl.meas';
my $meas_file = './meas_for_bits.meas';

open(FH, '>', $meas_file) or die $!;
print FH "test_1"."\n";

my @node =("zero","one","two","three");
my @range_event_time = (1..4);
my $range_event_time_final = @range_event_time+1 ;




print FH ".meas tran v_trigger_max max(v(trigger))","\n";

foreach my $index (@range_event_time){
	my $index_plus=$index+1;
	print FH ".meas tran t_event_fall_$index find time when v(trigger)= v_trigger_max*0.5 fall=$index"."\n";
	print FH ".meas tran t_event_rise_$index find time when v(trigger)= v_trigger_max*0.5 rise=$index_plus"."\n";
}
print FH ".meas tran t_event_fall_$range_event_time_final  find time when v(trigger)= v_trigger_max*0.5 fall=$range_event_time_final "."\n";

#~ .meas tran v_two_t1 avg(v(b_zero))
#~ +trig TIME=(t_event_fall_1+0.1u)
#~ +targ TIME=(t_event_rise_1-0.1u)

foreach my $index_1 (0..$#node){
	foreach my $index_2 (@range_event_time){
		print FH ".meas tran v_$node[$index_1]_t$index_2 avg(v(b_$node[$index_1]))","\n";
		print FH "+trig TIME=(t_event_fall_$index_2 +0.1u)","\n";
		print FH "+targ TIME=(t_event_fall_$index_2 -0.1u)","\n";
	}
	print FH ".meas tran v_$node[$index_1]_t$range_event_time_final avg(v(b_$node[$index_1]))","\n";
	print FH "+trig TIME=(t_event_fall_$range_event_time_final +0.1u)","\n";
}
foreach my $index (1..4){
		print FH ".MEAS TRAN V_t$index\_B_TO_D PARAM ((2**3)*v_three_t$index+(2**2)*v_two_t$index+(2**1)*v_one_t$index+(2**0)*v_zero_t$index)","\n";


}

#~ .meas tran v_two_t1 avg(v(b_zero))
#~ +trig TIME=(t_event_fall_1+0.1u)
#~ +targ TIME=(t_event_rise_1-0.1u)

#~ foreach my $index_e (1..5){
	#~ print FH ".meas tran t_event_$index_e find time when v(trigger)= v_trigger_max*0.5 fall=$index_e","\n";
#~ }

#~ foreach my $index_1 (0..$#node){
	#~ foreach my $index_2 (1..5){
		#~ print FH ".meas tran v_$node[$index_1]_t$index_2 find  V(b_$node[$index_1]) when time=t_event_$index_2","\n";
	#~ }
#~ }


#~ foreach my $index_n (0..$#node){
	#~ print FH ".MEAS TRAN v_b_$index_n MAX V(B_$node[$index_n])","\n";
#~ }


#~ my @node =("zero","one","two","three");
#~ foreach my $index (0..$#node){
	#~ print FH ".MEAS TRAN v_b_$index MAX V(B_$node[$index])","\n";
#~ }

#~ print FH "test_1"."\n";
#~ foreach my $index (0..3){
	#~ print FH ".MEAS TRAN v_b_$index MAX V(B_$index)","\n";
#~ }
	
#print FH ";This is a measurement file","\n";
#print FH ".MEAS TRAN v_b_0 MAX V(B0)","\n";
#print FH ".MEAS TRAN v_b_1 MAX V(B1)","\n";
#print FH ".MEAS TRAN v_b_2 MAX V(B2)","\n";
#print FH ".MEAS TRAN v_b_3 MAX V(B3)","\n";

=begin
#~ print FH "Hello World";
print FH ";This is a measurement file","\n";
print FH ".MEAS TRAN v_vout_AVG AVG V(out)","\n";
print FH ".MEAS TRAN v_vin_AVG AVG V(in)","\n";
print FH ".MEAS TRAN time_start_meas FIND time WHEN V(out)=5 FALL=1","\n";
=end
=cut

print FH "","\n";

close(FH);

print ("Writting to file successfully!","\n");


