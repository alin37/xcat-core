# IBM(c) 2007 EPL license http://www.eclipse.org/legal/epl-v10.html

package xCAT::FSPinv;
use strict;
use Getopt::Long;
use xCAT::PPCcli qw(SUCCESS EXPECT_ERROR RC_ERROR NR_ERROR);
use xCAT::Usage;
use xCAT::PPCinv;
use xCAT::FSPUtils;
#use Data::Dumper;

##########################################
# Maps fsp-api attributes to text
##########################################
my @licmap = (
    ["ecnumber",               "Release Level  "],
    ["activated_level",        "Active Level   "],
    ["installed_level",        "Installed Level"],
    ["accepted_level",         "Accepted Level "],
    ["curr_ecnumber_a",        "Release Level A"],
    ["curr_level_a",           "Level A        "],
    ["curr_ecnumber_b",        "Release Level B"],
    ["curr_level_b",           "Level B        "],
    ["curr_ecnumber_primary",  "Release Level Primary"],
    ["curr_level_primary",     "Level Primary  "],
    ["curr_ecnumber_secondary","Release Level Secondary"],
    ["curr_level_secondary",   "Level Secondary"]
);

##########################################################################
# Parse the command line for options and operands 
##########################################################################
sub parse_args {
    xCAT::PPCinv::parse_args(@_);
}




##########################################################################
# Returns FSP/BPA firmware information
##########################################################################
sub firmware {

    my $request = shift;
    my $hash    = shift;
    my @result;
 
    # print "in FSPinv \n";
    #print Dumper($request);
    #print Dumper($hash);

    ####################################
    # FSPinv with firm command is grouped by hardware control point
    # In FSPinv, the hcp is the related fsp.  
    ####################################
    
    # Example of $hash.    
    #VAR1 = {
    #	          '9110-51A*1075ECF' => {
    #                                   'Server-9110-51A-SN1075ECF' => [
    #    	                                                          0,
    #		                                                          0,
    #                           									  '9110-51A*1075ECF',
    #							                            		  'fsp1_name',
    #				                            					  'fsp',
    #									                               0
    #									                               ]
    #					                }
    # 	   };

    while (my ($mtms,$h) = each(%$hash) ) {
        while (my ($name,$d) = each(%$h) ) {

            #####################################
            # Command only supported on FSP/BPA/LPARs 
            #####################################
            if ( @$d[4] !~ /^(fsp|bpa|lpar)$/ ) {
                push @result, 
                    [$name,"Information only available for CEC/BPA/LPAR",RC_ERROR];
                next; 
            }
	       #################
	       #For support on  Lpars, the flag need to be changed.
	       ##########
	       if(@$d[4] eq "lpar")	{
		        @$d[4] = "fsp";
			    @$d[0] = 0;
	       }
           my $values = xCAT::FSPUtils::fsp_api_action( $name, $d, "list_firmware_level");
           my $Rc = @$values[2];
   	       my $data = @$values[1];
           #print "values";
           #print Dumper($values); 
           #####################################
           # Return error
           #####################################
           if ( $Rc != SUCCESS ) {
                push @result, [$name,$data,$Rc];
                next; 
            }
            
	        #####################################
            # Format fsp-api results
            #####################################
            my $val;
            foreach $val ( @licmap ) {  
                if ( $data =~ /@$val[0]=(\w+)/ ) {
                    push @result, [$name,"@$val[1]: $1",$Rc];
                }
            }
        }
    }
    return( \@result );
}


##########################################################################
# Returns firmware version 
##########################################################################
sub firm {
    return( firmware(@_) );
}

##########################################################################
# Returns serial-number
##########################################################################
sub serial {
}

sub vpd {
}

sub bus {
}

sub config {
}

##########################################################################
# Returns machine-type-model
##########################################################################
sub model {
}

##########################################################################
# Returns all inventory information
##########################################################################
sub all {

    my @result = ( 
        @{vpd(@_)}, 
        @{bus(@_)}, 
        @{config(@_)},
        @{firmware(@_)} 
    );       
    return( \@result );
}


1;


