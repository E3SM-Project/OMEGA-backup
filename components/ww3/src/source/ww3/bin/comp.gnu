#!/bin/sh
# --------------------------------------------------------------------------- #
# comp  : Compiler script for use in ad3 (customized for hardware and         #
#         optimization). Note that this script will not be replaced if part   #
#         of WAVEWATCH III is re-installed. Used by ad3.                      #
#                                                                             #
# use   : comp name                                                           #
#           name: name of source code file without the extension.             #
#                                                                             #
# error codes :  1 : input error                                              #
#                2 : no environment file $ww3_env found.                      #
#                3 : error in creating scratch directory.                     #
#                4 : w3adc error.                                             #
#                5 : compiler error.                                          #
#                                                                             #
# remarks :                                                                   #
#                                                                             #
#  - This script runs from the scratch directory, where it should remain.     #
#                                                                             #
#  - For this script to interact with ad3, it needs to generate / leave       #
#    following files :                                                        #
#       $name.f90   : Source code (generated by ad3).                         #
#       $name.o     : Object module.                                          #
#       $name.l     : Listing file.                                           #
#       comp.stat   : status file of compiler, containing number of errors    #
#                     and number of warnings (generated by comp).             #
#                                                                             #
#  - Upon (first) installation of WAVEWATCH III the user needs to check the   #
#    following parts of this script :                                         #
#      sec. 2.b : Provide correct compiler/options.                           #
#      sec. 3.a : Provide correct error capturing.                            #
#      sec. 3.d : Remove unnecessary files.                                   #
#                                                                             #
#  - This version is made for the GNU compilers on any architecture.          #
#                                                                             #
#                                                      Timothy J. Campbell    #
#                                                      October 2009           #
# --------------------------------------------------------------------------- #
# 1. Preparations                                                             #
# --------------------------------------------------------------------------- #
# 1.a Check and process input

  if [ "$#" != '1' ]
  then
    echo "usage: comp name" ; exit 1
  fi
  name="$1"

# 1.b Initial clean-up - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

  rm -f $name.l
  rm -f $name.o
  rm -f comp.stat

# --------------------------------------------------------------------------- #
# 2. Compile                                                                  #
# --------------------------------------------------------------------------- #
# Add here the correct compiler call including command line options
# Note: - do not invoke a link step
#       - if possible, generate a listing $name.l
#       - make sure the compiler point to the proper directory where the 
#         modules are stored ($m_path), see examples below.

# 2.a Determine file extension - - - - - - - - - - - - - - - - - - - - - - - - 
#     .f90 assumes free format, .f assumes fixed format, change if necessary
# *** file extension (fext) is set and exported by calling program (ad3) ***

# 2.b Perform compilation  - - - - - - - - - - - - - - - - - - - - - - - - - - 
#     Save compiler exit code in $OK
#
# Gnu compiler on Linux ------------------------------------------------------
# 2.b.1 Build options and determine compiler name
#       Note that all but GrADS output is forced to big endian data

# Notes re: changing compilers (important)
# ...1) run cleaner scrip to get rid of old .mod and .o files
# ...2) change switch or remove makefile to force creation of new makefile 
# ...3) use -c {compiler name} in run_test

# Gnu:
#     -Idir : where to search for .mod files
#     -Jdir or -Mdir : where to put .mod files

  # compilation options
  opt="-c -O3 -fno-second-underscore -ffree-line-length-none -fconvert=big-endian -J$path_m"
# opt="$opt -I$HOME/g2lib -I/opt/local/include"

  # mpi implementation
  if [ "$mpi_mod" = 'yes' ]
  then
    comp=mpif90
  else
    comp=gfortran
  fi

  # open mpi implementation
  if [ "$omp_mod" = 'yes' ]
  then
    opt="$opt -fopenmp"
  fi

  # oasis coupler include dir
  if [ "$oasis_mod" = 'yes' ]
  then
    opt="$opt -I$OASISDIR/build/lib/psmile.MPI1"
  fi

  # palm coupler include dir
  if [ "$palm_mod" = 'yes' ]
  then
    opt="$opt -I$PALM_LIBDIR -I$PALM_DIR"
  fi

  # netcdf include dir
  if [ "$netcdf_compile" = 'yes' ]
  then
    case $WWATCH3_NETCDF in
      NC3) opt="$opt -I$NETCDF_INCDIR" ;;
      NC4) if [ "$mpi_mod" = 'no' ]; then comp="`$NETCDF_CONFIG --fc`"; fi
           opt="$opt -I`$NETCDF_CONFIG --includedir`" ;;
    esac
  fi

  # ftn include dir
  opt="$opt -I$path_i"

# 2.b.2 Compile

  $comp $opt                             $name.$fext > $name.out 2> $name.err
  OK="$?"

# 2.b.2 Process listing

  if [ -s $name.lst ] 
  then
     mv $name.lst $name.l
  fi

# 2.b.3 Add test output to listing for later viewing

  if [ -s $name.l ] 
  then
    echo '------------' >> $name.l
    echo "$comp $opt"   >> $name.l
    echo '------------' >> $name.l
    cat $name.out       >> $name.l 2> /dev/null
    echo '------------' >> $name.l
    cat $name.err       >> $name.l 2> /dev/null
    echo '------------' >> $name.l
  fi

# --------------------------------------------------------------------------- #
# 3. Postprocessing                                                           #
# --------------------------------------------------------------------------- #
# 3.a Capture errors
#     nr_err : number of errors.
#     nr_war : number of errors.

  nr_err='0'
  nr_war='0'

  if [ -s $name.err ]
  then
    nr_err=`grep 'error' $name.err | wc -l | awk '{ print $1 }'`
    nr_war=`grep 'warning' $name.err | wc -l | awk '{ print $1 }'`
  else
    if [ "$OK" != '0' ]
    then
      nr_err='1'
    fi
  fi

# 3.b Make file comp.stat  - - - - - - - - - - - - - - - - - - - - - - - - - - 

  echo "ERROR    $nr_err"   > comp.stat
  echo "WARNING  $nr_war"  >> comp.stat

# 3.c Prepare listing  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#     if compiler does not provide listing, make listing from source code
#     and compiler messages. Second input line for w3list identifies if
#     comment lines are to be numbered.

  if [ ! -f $name.l ]
  then
    echo "$name.$fext" > w3list.inp
    echo "T"          >> w3list.inp
    w3list < w3list.inp 2> /dev/null
    rm -f w3list.inp
    mv w3list.out $name.l
    echo '------------' >> $name.l
    echo "$comp $opt"   >> $name.l
    echo '------------' >> $name.l
    cat $name.out >> $name.l #2> /dev/null
    echo '------------' >> $name.l
    cat $name.err >> $name.l #2> /dev/null
    echo '------------' >> $name.l
  fi

# 3.d Remove unwanted files  - - - - - - - - - - - - - - - - - - - - - - - - -
#     include here unwanted files generated by the compiler

  rm -f $name.out
  rm -f $name.err

# end of comp --------------------------------------------------------------- #
