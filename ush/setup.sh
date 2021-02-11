#
#-----------------------------------------------------------------------
#
# This file defines and then calls a function that sets a secondary set
# of parameters needed by the various scripts that are called by the 
# FV3SAR rocoto community workflow.  This secondary set of parameters is 
# calculated using the primary set of user-defined parameters in the de-
# fault and custom experiment/workflow configuration scripts (whose file
# names are defined below).  This script then saves both sets of parame-
# ters in a global variable definitions file (really a bash script) in 
# the experiment directory.  This file then gets sourced by the various 
# scripts called by the tasks in the workflow.
#
#-----------------------------------------------------------------------
#
function setup() {
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
local scrfunc_fp=$( readlink -f "${BASH_SOURCE[0]}" )
local scrfunc_fn=$( basename "${scrfunc_fp}" )
local scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Get the name of this function.
#
#-----------------------------------------------------------------------
#
local func_name="${FUNCNAME[0]}"
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
cd_vrfy ${scrfunc_dir}
#
#-----------------------------------------------------------------------
#
# Source bash utility functions.
#
#-----------------------------------------------------------------------
#
. ./source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Source other necessary files.
#
#-----------------------------------------------------------------------
#
. ./set_cycle_dates.sh
. ./set_gridparams_GFDLgrid.sh
. ./set_gridparams_JPgrid.sh
. ./link_fix.sh
. ./set_fix_filenames.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -u +x; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Set the names of the default and local workflow/experiment configura-
# tion scripts.
#
#-----------------------------------------------------------------------
#
DEFAULT_EXPT_CONFIG_FN="config_defaults.sh"
EXPT_CONFIG_FN="config.sh"
#
#-----------------------------------------------------------------------
#
# Source the default configuration file containing default values for
# the experiment/workflow variables.
#
#-----------------------------------------------------------------------
#
. ./${DEFAULT_EXPT_CONFIG_FN}
#
#-----------------------------------------------------------------------
#
# If a user-specified configuration file exists, source it.  This file
# contains user-specified values for a subset of the experiment/workflow 
# variables that override their default values.  Note that the user-
# specified configuration file is not tracked by the repository, whereas
# the default configuration file is tracked.
#
#-----------------------------------------------------------------------
#
if [ -f "${EXPT_CONFIG_FN}" ]; then
#
# We require that the variables being set in the user-specified configu-
# ration file have counterparts in the default configuration file.  This
# is so that we do not introduce new variables in the user-specified 
# configuration file without also officially introducing them in the de-
# fault configuration file.  Thus, before sourcing the user-specified 
# configuration file, we check that all variables in the user-specified
# configuration file are also assigned default values in the default 
# configuration file.
#
  . ./compare_config_scripts.sh
#
# Now source the user-specified configuration file.
#
  . ./${EXPT_CONFIG_FN}
#
fi
#
#-----------------------------------------------------------------------
#
# Source the script defining the valid values of experiment variables.
#
#-----------------------------------------------------------------------
#
. ./valid_param_vals.sh

#
#-----------------------------------------------------------------------
#
# Add model config settings
#
#-----------------------------------------------------------------------
#
CONFDIR=../conf
mdl_extrns_cfg_fp="${CONFDIR}/fcst_model.cfg"

fcst_model_name=$( get_fcst_model_name ./${EXPT_CONFIG_FN} ) || \
  print_err_msg_exit "\
  Call to function get_fcst_model_name failed."

get_fcst_model_info ${mdl_extrns_cfg_fp} "${fcst_model_name}" \
  build_opt ccpp_suite require_tasks

mdl_build_opts=( ${build_opt} )
is_element_of mdl_build_opts "CCPP=Y" && USE_CCPP="TRUE" || USE_CCPP="FALSE"
[ ! -z "${ccpp_suite}" ] && CCPP_PHYS_SUITE="${ccpp_suite}"

mdl_require_tasks=( ${require_tasks:-none} )
is_element_of mdl_require_tasks "airquality" && ENABLE_AQ="TRUE" || ENABLE_AQ="FALSE"
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_ENVIR is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "RUN_ENVIR" "valid_vals_RUN_ENVIR"
#
#-----------------------------------------------------------------------
#
# Make sure that VERBOSE is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "VERBOSE" "valid_vals_VERBOSE"
#
# Set VERBOSE to either "TRUE" or "FALSE" so we don't have to consider
# other valid values later on.
#
VERBOSE=${VERBOSE^^}
if [ "$VERBOSE" = "TRUE" ] || \
   [ "$VERBOSE" = "YES" ]; then
  VERBOSE="TRUE"
elif [ "$VERBOSE" = "FALSE" ] || \
     [ "$VERBOSE" = "NO" ]; then
  VERBOSE="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that USE_CRON_TO_RELAUNCH is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "USE_CRON_TO_RELAUNCH" "valid_vals_USE_CRON_TO_RELAUNCH"
#
# Set USE_CRON_TO_RELAUNCH to either "TRUE" or "FALSE" so we don't have to consider
# other valid values later on.
#
USE_CRON_TO_RELAUNCH=${USE_CRON_TO_RELAUNCH^^}
if [ "${USE_CRON_TO_RELAUNCH}" = "TRUE" ] || \
   [ "${USE_CRON_TO_RELAUNCH}" = "YES" ]; then
  USE_CRON_TO_RELAUNCH="TRUE"
elif [ "${USE_CRON_TO_RELAUNCH}" = "FALSE" ] || \
     [ "${USE_CRON_TO_RELAUNCH}" = "NO" ]; then
  USE_CRON_TO_RELAUNCH="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_MAKE_GRID is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "RUN_TASK_MAKE_GRID" "valid_vals_RUN_TASK_MAKE_GRID"
#
# Set RUN_TASK_MAKE_GRID to either "TRUE" or "FALSE" so we don't have to
# consider other valid values later on.
#
RUN_TASK_MAKE_GRID=${RUN_TASK_MAKE_GRID^^}
if [ "${RUN_TASK_MAKE_GRID}" = "TRUE" ] || \
   [ "${RUN_TASK_MAKE_GRID}" = "YES" ]; then
  RUN_TASK_MAKE_GRID="TRUE"
elif [ "${RUN_TASK_MAKE_GRID}" = "FALSE" ] || \
     [ "${RUN_TASK_MAKE_GRID}" = "NO" ]; then
  RUN_TASK_MAKE_GRID="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_MAKE_SFC_CLIMO is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "RUN_TASK_MAKE_SFC_CLIMO" "valid_vals_RUN_TASK_MAKE_SFC_CLIMO"
#
# Set RUN_TASK_MAKE_SFC_CLIMO to either "TRUE" or "FALSE" so we don't
# have to consider other valid values later on.
#
RUN_TASK_MAKE_SFC_CLIMO=${RUN_TASK_MAKE_SFC_CLIMO^^}
if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "TRUE" ] || \
   [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "YES" ]; then
  RUN_TASK_MAKE_SFC_CLIMO="TRUE"
elif [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" ] || \
     [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "NO" ]; then
  RUN_TASK_MAKE_SFC_CLIMO="FALSE"
fi
#
# If RUN_TASK_MAKE_SFC_CLIMO is set to "FALSE", make sure that the di-
# rectory SFC_CLIMO_DIR that should contain the pre-generated surface 
# climatology files exists.
#
if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" ] && \
   [ ! -d "${SFC_CLIMO_DIR}" ]; then
  print_err_msg_exit "\
The directory (SFC_CLIMO_DIR) that should contain the pre-generated sur-
face climatology files does not exist:
  SFC_CLIMO_DIR = \"${SFC_CLIMO_DIR}\""
fi
#
# If RUN_TASK_MAKE_SFC_CLIMO is set to "TRUE" and the variable specify-
# ing the directory in which to look for pregenerated grid and orography
# files (i.e. SFC_CLIMO_DIR) is not empty, then for clarity reset the 
# latter to an empty string (because it will not be used).
#
if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "TRUE" ] && \
   [ -n "${SFC_CLIMO_DIR}" ]; then
  SFC_CLIMO_DIR=""
fi
#
#-----------------------------------------------------------------------
#
# Make sure that DOT_OR_USCORE is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "DOT_OR_USCORE" "valid_vals_DOT_OR_USCORE"
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_ADD_AQM_LBCS is set to a valid value.
#
#-----------------------------------------------------------------------
#
if [ ! -z "${RUN_TASK_ADD_AQM_ICS}" ]; then
  check_var_valid_value \
    "RUN_TASK_ADD_AQM_ICS" "valid_vals_RUN_TASK_ADD_AQM_ICS"
  RUN_TASK_ADD_AQM_ICS=${RUN_TASK_ADD_AQM_ICS^^}
  if [ "${RUN_TASK_ADD_AQM_ICS}" = "TRUE" ] || \
     [ "${RUN_TASK_ADD_AQM_ICS}" = "YES" ]; then
    RUN_TASK_ADD_AQM_ICS="TRUE"
  elif [ "${RUN_TASK_ADD_AQM_ICS}" = "FALSE" ] || \
       [ "${RUN_TASK_ADD_AQM_ICS}" = "NO" ]; then
    RUN_TASK_ADD_AQM_ICS="FALSE"
  fi
#
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_ADD_AQM_LBCS is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "RUN_TASK_ADD_AQM_LBCS" "valid_vals_RUN_TASK_ADD_AQM_LBCS"
RUN_TASK_ADD_AQM_LBCS=${RUN_TASK_ADD_AQM_LBCS^^}
if [ "${RUN_TASK_ADD_AQM_LBCS}" = "TRUE" ] || \
   [ "${RUN_TASK_ADD_AQM_LBCS}" = "YES" ]; then
  RUN_TASK_ADD_AQM_LBCS="TRUE"
elif [ "${RUN_TASK_ADD_AQM_LBCS}" = "FALSE" ] || \
     [ "${RUN_TASK_ADD_AQM_LBCS}" = "NO" ]; then
  RUN_TASK_ADD_AQM_LBCS="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_RUN_NEXUS is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "RUN_TASK_RUN_NEXUS" "valid_vals_RUN_TASK_RUN_NEXUS"
RUN_TASK_RUN_NEXUS=${RUN_TASK_RUN_NEXUS^^}
if [ "${RUN_TASK_RUN_NEXUS}" = "TRUE" ] || \
   [ "${RUN_TASK_RUN_NEXUS}" = "YES" ]; then
  RUN_TASK_RUN_NEXUS="TRUE"
elif [ "${RUN_TASK_RUN_NEXUS}" = "FALSE" ] || \
     [ "${RUN_TASK_RUN_NEXUS}" = "NO" ]; then
  RUN_TASK_RUN_NEXUS="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RUN_TASK_RUN_POST is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "RUN_TASK_RUN_POST" "valid_vals_RUN_TASK_RUN_POST"
RUN_TASK_RUN_POST=${RUN_TASK_RUN_POST^^}
if [ "${RUN_TASK_RUN_POST}" = "TRUE" ] || \
   [ "${RUN_TASK_RUN_POST}" = "YES" ]; then
  RUN_TASK_RUN_POST="TRUE"
elif [ "${RUN_TASK_RUN_POST}" = "FALSE" ] || \
     [ "${RUN_TASK_RUN_POST}" = "NO" ]; then
  RUN_TASK_RUN_POST="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Convert machine name to upper case if necessary.  Then make sure that
# MACHINE is set to a valid value.
#
#-----------------------------------------------------------------------
#
MACHINE=$( printf "%s" "$MACHINE" | sed -e 's/\(.*\)/\U\1/' )
check_var_valid_value "MACHINE" "valid_vals_MACHINE"
#
#-----------------------------------------------------------------------
#
# Set the number of cores per node, the job scheduler, and the names of
# several queues.  These queues are defined in the default and local 
# workflow/experiment configuration script.
#
#-----------------------------------------------------------------------
#
case $MACHINE in
#
"WCOSS_C")
#
  print_err_msg_exit "\
Don't know how to set several parameters on MACHINE=\"$MACHINE\".
Please specify the correct parameters for this machine in the setup script.  
Then remove this message and rerun." 
  NCORES_PER_NODE=""
  SCHED=""
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-""}
  QUEUE_HPSS=${QUEUE_HPSS:-""}
  QUEUE_FCST=${QUEUE_FCST:-""}
  ;;
#
"WCOSS")
#
  print_err_msg_exit "\
Don't know how to set several parameters on MACHINE=\"$MACHINE\".
Please specify the correct parameters for this machine in the setup script.  
Then remove this message and rerun."

  NCORES_PER_NODE=""
  SCHED=""
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-""}
  QUEUE_HPSS=${QUEUE_HPSS:-""}
  QUEUE_FCST=${QUEUE_FCST:-""}
  ;;
#
"WCOSS_DELL_P3")
#
  NCORES_PER_NODE=24
  SCHED="lsf"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-"dev"}
  QUEUE_HPSS=${QUEUE_HPSS:-"dev_transfer"}
  QUEUE_HPSS_TAG="queue"       # lsf does not support "partition" tag
  QUEUE_HPSS_RSRC="<memory>2000M</memory><native>-R affinity[core]</native>"
  QUEUE_FCST=${QUEUE_FCST:-"dev"}
  ;;
#
"THEIA")
#
  NCORES_PER_NODE=24
  SCHED="slurm"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
  QUEUE_HPSS=${QUEUE_HPSS:-"service"}
  QUEUE_FCST=${QUEUE_FCST:-""}
  ;;
#
"HERA")
#
  NCORES_PER_NODE=24
  SCHED="slurm"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
  QUEUE_HPSS=${QUEUE_HPSS:-"service"}
  QUEUE_FCST=${QUEUE_FCST:-""}
  ;;
#
"JET")
#
  NCORES_PER_NODE=24
  SCHED="slurm"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-"batch"}
  QUEUE_HPSS=${QUEUE_HPSS:-"service"}
  QUEUE_FCST=${QUEUE_FCST:-"batch"}
  ;;
#
"ODIN")
#
  NCORES_PER_NODE=24
  SCHED="slurm"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-""}
  QUEUE_HPSS=${QUEUE_HPSS:-""}
  QUEUE_FCST=${QUEUE_FCST:-""}
  ;;
#
"CHEYENNE")
#
  NCORES_PER_NODE=36
  SCHED="pbspro"
  QUEUE_DEFAULT=${QUEUE_DEFAULT:-"regular"}
  QUEUE_HPSS=${QUEUE_HPSS:-"regular"}
  QUEUE_HPSS_TAG="queue"       # pbspro does not support "partition" tag
  QUEUE_FCST=${QUEUE_FCST:-"regular"}
#
esac
#
#-----------------------------------------------------------------------
#
# Verify that the ACCOUNT variable is not empty.  If it is, print out an
# error message and exit.
#
#-----------------------------------------------------------------------
#
if [ -z "$ACCOUNT" ]; then
  print_err_msg_exit "\
The variable ACCOUNT cannot be empty:
  ACCOUNT = \"$ACCOUNT\""
fi
#
#-----------------------------------------------------------------------
#
# Set the grid type (GTYPE).  In general, in the FV3 code, this can take
# on one of the following values: "global", "stretch", "nest", and "re-
# gional".  The first three values are for various configurations of a
# global grid, while the last one is for a regional grid.  Since here we
# are only interested in a regional grid, GTYPE must be set to "region-
# al".
#
#-----------------------------------------------------------------------
#
GTYPE="regional"
TILE_RGNL="7"
#
#-----------------------------------------------------------------------
#
# Make sure that GTYPE is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "GTYPE" "valid_vals_GTYPE"
#
#-----------------------------------------------------------------------
#
# If running in NCO mode, a valid EMC grid must be specified.  Make sure 
# EMC_GRID_NAME is set to a valid value.
#
# Note: It is probably best to eventually eliminate EMC_GRID_NAME as a
# user-specified variable and just go with PREDEF_GRID_NAME.
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then
  err_msg="\
The EMC grid specified in EMC_GRID_NAME is not supported:
  EMC_GRID_NAME = \"${EMC_GRID_NAME}\""
  check_var_valid_value \
    "EMC_GRID_NAME" "valid_vals_EMC_GRID_NAME" "${err_msg}"
fi
#
# Map the specified EMC grid to one of the predefined grids.
#
case "${EMC_GRID_NAME}" in
  "ak")
    PREDEF_GRID_NAME="EMC_AK"
    ;;
  "conus")
    PREDEF_GRID_NAME="EMC_CONUS_3km"
    ;;
  "conus_c96")
    PREDEF_GRID_NAME="EMC_CONUS_coarse"
    ;;
  "conus_orig"|"guam"|"hi"|"pr")
    print_err_msg_exit "\
A predefined grid (PREDEF_GRID_NAME) has not yet been defined for this
EMC grid (EMC_GRID_NAME):
  EMC_GRID_NAME = \"${EMC_GRID_NAME}\""
    ;;
esac
#
#-----------------------------------------------------------------------
#
# Make sure PREDEF_GRID_NAME is set to a valid value.
#
#-----------------------------------------------------------------------
#
if [ ! -z ${PREDEF_GRID_NAME} ]; then
  err_msg="\
The predefined regional grid specified in PREDEF_GRID_NAME is not sup-
ported:
  PREDEF_GRID_NAME = \"${PREDEF_GRID_NAME}\""
  check_var_valid_value \
    "PREDEF_GRID_NAME" "valid_vals_PREDEF_GRID_NAME" "${err_msg}"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that PREEXISTING_DIR_METHOD is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "PREEXISTING_DIR_METHOD" "valid_vals_PREEXISTING_DIR_METHOD"
#
#-----------------------------------------------------------------------
#
# Make sure USE_CCPP is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "USE_CCPP" "valid_vals_USE_CCPP"
#
# Set USE_CCPP to either "TRUE" or "FALSE" so we don't have to consider
# other valid values later on.
#
USE_CCPP=${USE_CCPP^^}
if [ "$USE_CCPP" = "TRUE" ] || \
   [ "$USE_CCPP" = "YES" ]; then
  USE_CCPP="TRUE"
elif [ "$USE_CCPP" = "FALSE" ] || \
     [ "$USE_CCPP" = "NO" ]; then
  USE_CCPP="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# If USE_CCPP is set to "TRUE", make sure CCPP_PHYS_SUITE is set to a 
# valid value.
#
#-----------------------------------------------------------------------
#
if [ "${USE_CCPP}" = "TRUE" ] && [ ! -z ${CCPP_PHYS_SUITE} ]; then
  err_msg="\
The CCPP physics suite specified in CCPP_PHYS_SUITE is not supported:
  CCPP_PHYS_SUITE = \"${CCPP_PHYS_SUITE}\""
  check_var_valid_value \
    "CCPP_PHYS_SUITE" "valid_vals_CCPP_PHYS_SUITE" "${err_msg}"
fi
#
#-----------------------------------------------------------------------
#
# If using CCPP with the GFS_2017_gfdlmp physics suite, only allow 
# "GSMGFS" and "FV3GFS" as the external models for ICs and LBCs.
#
#-----------------------------------------------------------------------
#
if [ "${USE_CCPP}" = "TRUE" ] && \
   [ "${CCPP_PHYS_SUITE}" = "FV3_GFS_2017_gfdlmp" ]; then

  if [ "${EXTRN_MDL_NAME_ICS}" != "GSMGFS" -a \
       "${EXTRN_MDL_NAME_ICS}" != "FV3GFS" ] || \
     [ "${EXTRN_MDL_NAME_LBCS}" != "GSMGFS" -a \
       "${EXTRN_MDL_NAME_LBCS}" != "FV3GFS" ]; then
    print_info_msg "$VERBOSE" "
The following combination of physics suite and external model(s) for ICs 
and LBCs is not allowed:
  CCPP_PHYS_SUITE = \"${CCPP_PHYS_SUITE}\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\"
For this physics suite, the only external models that the workflow cur-
rently allows are \"GSMGFS\" and \"FV3GFS\"." 
  fi

fi
#
#-----------------------------------------------------------------------
#
# Check that DATE_FIRST_CYCL and DATE_LAST_CYCL are strings consisting 
# of exactly 8 digits.
#
#-----------------------------------------------------------------------
#
DATE_OR_NULL=$( printf "%s" "${DATE_FIRST_CYCL}" | \
                sed -n -r -e "s/^([0-9]{8})$/\1/p" )
if [ -z "${DATE_OR_NULL}" ]; then
  print_err_msg_exit "\
DATE_FIRST_CYCL must be a string consisting of exactly 8 digits of the 
form \"YYYYMMDD\", where YYYY is the 4-digit year, MM is the 2-digit 
month, DD is the 2-digit day-of-month, and HH is the 2-digit hour-of-
day.
  DATE_FIRST_CYCL = \"${DATE_FIRST_CYCL}\""
fi

DATE_OR_NULL=$( printf "%s" "${DATE_LAST_CYCL}" | \
                sed -n -r -e "s/^([0-9]{8})$/\1/p" )
if [ -z "${DATE_OR_NULL}" ]; then
  print_err_msg_exit "\
DATE_LAST_CYCL must be a string consisting of exactly 8 digits of the 
form \"YYYYMMDD\", where YYYY is the 4-digit year, MM is the 2-digit 
month, DD is the 2-digit day-of-month, and HH is the 2-digit hour-of-
day.
  DATE_LAST_CYCL = \"${DATE_LAST_CYCL}\""
fi
#
#-----------------------------------------------------------------------
#
# Check that all elements of CYCL_HRS are strings consisting of exactly
# 2 digits that are between "00" and "23", inclusive.
#
#-----------------------------------------------------------------------
#
CYCL_HRS_str=$(printf "\"%s\" " "${CYCL_HRS[@]}")
CYCL_HRS_str="( $CYCL_HRS_str)"

i=0
for CYCL in "${CYCL_HRS[@]}"; do

  CYCL_OR_NULL=$( printf "%s" "$CYCL" | sed -n -r -e "s/^([0-9]{2})$/\1/p" )

  if [ -z "${CYCL_OR_NULL}" ]; then
    print_err_msg_exit "\
Each element of CYCL_HRS must be a string consisting of exactly 2 digits
(including a leading \"0\", if necessary) specifying an hour-of-day.  Ele-
ment #$i of CYCL_HRS (where the index of the first element is 0) does not
have this form:
  CYCL_HRS = $CYCL_HRS_str
  CYCL_HRS[$i] = \"${CYCL_HRS[$i]}\""
  fi

  if [ "${CYCL_OR_NULL}" -lt "0" ] || \
     [ "${CYCL_OR_NULL}" -gt "23" ]; then
    print_err_msg_exit "\
Each element of CYCL_HRS must be an integer between \"00\" and \"23\", in-
clusive (including a leading \"0\", if necessary), specifying an hour-of-
day.  Element #$i of CYCL_HRS (where the index of the first element is 0) 
does not have this form:
  CYCL_HRS = $CYCL_HRS_str
  CYCL_HRS[$i] = \"${CYCL_HRS[$i]}\""
  fi

  i=$(( $i+1 ))

done
#
#-----------------------------------------------------------------------
#
# Call a function to generate the array ALL_CDATES containing the cycle
# dates/hours for which to run forecasts.  The elements of this array
# will have the form YYYYMMDDHH.  They are the starting dates/times of
# the forecasts that will be run in the experiment.  Then set NUM_CYCLES
# to the number of elements in this array.
#
#-----------------------------------------------------------------------
#
set_cycle_dates \
  date_start="${DATE_FIRST_CYCL}" \
  date_end="${DATE_LAST_CYCL}" \
  cycle_hrs="${CYCL_HRS_str}" \
  output_varname_all_cdates="ALL_CDATES" \
  output_varname_cycle_inc="CYCL_INC"

NUM_CYCLES="${#ALL_CDATES[@]}"
if [ ${#ALL_CDATES[@]} -gt 1 ]; then
  RUN_TASK_ADD_AQM_ICS="${RUN_TASK_ADD_AQM_ICS:-TRUE}"
else
  RUN_TASK_ADD_AQM_ICS="${RUN_TASK_ADD_AQM_ICS:-FALSE}"
fi
#
#-----------------------------------------------------------------------
#
# Disable air quality tasks if the forecast model does not require them.
# Air quality workflow tasks are enabled by default.
#
#-----------------------------------------------------------------------
#
if [ "${ENABLE_AQ}" == "FALSE" ]; then
  RUN_TASK_ADD_AQM_ICS="FALSE"
  RUN_TASK_ADD_AQM_LBCS="FALSE"
  RUN_TASK_RUN_NEXUS="FALSE"
  print_info_msg "
Disabling air quality tasks since forecast model does not require them."
fi
#
#-----------------------------------------------------------------------
#
# Make sure RESTART_INTERVAL is set to an integer value if present
#
#-----------------------------------------------------------------------
#
if ! [[ "${RESTART_INTERVAL:-0}" =~ ^[0-9]+$ ]]; then
  print_err_msg_exit "\
RESTART_INTERVAL must be set to an integer number of hours.
  RESTART_INTERVAL = \"${RESTART_INTERVAL}\""
fi
#
#-----------------------------------------------------------------------
#
# Make sure that RESTART_WORKFLOW is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value \
  "RESTART_WORKFLOW" "valid_vals_RESTART_WORKFLOW"
RESTART_WORKFLOW=${RESTART_WORKFLOW^^}
if [ "${RESTART_WORKFLOW}" = "TRUE" ] || \
   [ "${RESTART_WORKFLOW}" = "YES" ]; then
  RESTART_WORKFLOW="TRUE"
elif [ "${RESTART_WORKFLOW}" = "FALSE" ] || \
     [ "${RESTART_WORKFLOW}" = "NO" ]; then
  RESTART_WORKFLOW="FALSE"
fi
#
#
#-----------------------------------------------------------------------
#
# Set various directories.
#
# HOMErrfs:
# Top directory of the clone of the FV3SAR workflow git repository.
#
# USHDIR:
# Directory containing the shell scripts called by the workflow.
#
# SCRIPTSDIR:
# Directory containing the ex scripts called by the workflow.
#
# JOBSSDIR:
# Directory containing the jjobs scripts called by the workflow.
#
# SORCDIR:
# Directory containing various source codes.
#
# PARMDIR:
# Directory containing parameter files, template files, etc.
#
# EXECDIR:
# Directory containing various executable files.
#
# JEDI_DIR:
# Directory of JEDI clone and build
#
# TEMPLATE_DIR:
# Directory in which templates of various FV3SAR input files are locat-
# ed.
#
# UFS_WTHR_MDL_DIR:
# Directory in which the (NEMS-enabled) FV3SAR application is located.
# This directory includes subdirectories for FV3, NEMS, and FMS.  If
# USE_CCPP is set to "TRUE", it also includes a subdirectory for CCPP.
#
# FIXgsm:
# System directory in which the fixed (i.e. time-independent) files that
# are needed to run the FV3SAR model are located.
#
# SFC_CLIMO_INPUT_DIR:
# Directory in which the sfc_climo_gen code looks for surface climatolo-
# gy input files.
#
# FIXupp:
# System directory from which to copy necessary fixed files for UPP.
#
# FIXgsd:
# System directory from which to copy GSD physics-related fixed files 
# needed when running CCPP.
#
#-----------------------------------------------------------------------
#

#
# The current script should be located in the ush subdirectory of the 
# workflow directory.  Thus, the workflow directory is the one above the
# directory of the current script.  Get the path to this latter directo-
# ry and save it in HOMErrfs.
#
HOMErrfs=${scrfunc_dir%/*}

CONFDIR="$HOMErrfs/conf"
USHDIR="$HOMErrfs/ush"
SCRIPTSDIR="$HOMErrfs/scripts"
JOBSDIR="$HOMErrfs/jobs"
SORCDIR="$HOMErrfs/sorc"
PARMDIR="$HOMErrfs/parm"
MODULES_DIR="$HOMErrfs/modulefiles"
EXECDIR="$HOMErrfs/exec"
JEDI_DIR="$HOMErrfs/sorc/JEDI"
FIXrrfs="$HOMErrfs/fix"
FIXupp="$FIXrrfs/fix_upp"
FIXgsd="$FIXrrfs/fix_gsd"
TEMPLATE_DIR="$USHDIR/templates"

case $MACHINE in

"WCOSS_C")
  FIXgsm="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_am"
  SFC_CLIMO_INPUT_DIR=""
  ;;

"WCOSS")
  FIXgsm="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix/fix_am"
  SFC_CLIMO_INPUT_DIR=""
  ;;

"WCOSS_DELL_P3")
  FIXgsm=${FIXgsm:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_am"}
  TOPO_DIR=${TOPO_DIR:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_orog"}
  SFC_CLIMO_INPUT_DIR=${SFC_CLIMO_INPUT_DIR:-"/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix/fix_sfc_climo"}
  AQM_CONFIG_DIR=${AQM_CONFIG_DIR:-"/gpfs/dell2/emc/modeling/noscrub/Jianping.Huang/fv3sar/aqm/epa/data"}
  AQM_EMIS_DIR=${AQM_EMIS_DIR:-"/gpfs/dell2/emc/modeling/noscrub/Jianping.Huang/fv3sar/aqm/bio"}
  NEXUS_INPUT_DIR=${NEXUS_INPUT_DIR:-"/gpfs/dell2/emc/modeling/noscrub/$USER/emissions"}
  EXPT_BASEDIR=/gpfs/dell1/ptmp/$USER/expt_dirs
  ;;

"THEIA")
  FIXgsm="/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix/fix_am"
  SFC_CLIMO_INPUT_DIR="/scratch4/NCEPDEV/da/noscrub/George.Gayno/climo_fields_netcdf"
  ;;

"HERA")
  FIXgsm="/scratch1/NCEPDEV/global/glopara/fix/fix_am"
  SFC_CLIMO_INPUT_DIR="/scratch1/NCEPDEV/da/George.Gayno/ufs_utils.git/climo_fields_netcdf"
  AQM_CONFIG_DIR=${AQM_CONFIG_DIR:-"/scratch1/NCEPDEV/nems/Raffaele.Montuoro/dev/aqm/epa/data"}
  AQM_EMIS_DIR=${AQM_EMIS_DIR:-"/scratch1/NCEPDEV/nems/Raffaele.Montuoro/dev/fv3sar/data/bio"}
  AQM_LBCS_DIR=${AQM_LBCS_DIR:-"/scratch2/NAGAPE/arl/Barry.Baker/boundary_conditions"}
  NEXUS_INPUT_DIR=${NEXUS_INPUT_DIR:-"/scratch2/NAGAPE/arl/Barry.Baker/emissions"}
  DA_OBS_DIR=${DA_OBS_DIR:-"/scratch1/NCEPDEV/da/Cory.R.Martin/Datasets/Observations/RRFS-CMAQ"}
  ;;

"JET")
  FIXgsm="/lfs3/projects/hpc-wof1/ywang/regional_fv3/fix/fix_am"
  SFC_CLIMO_INPUT_DIR="/lfs1/HFIP/hwrf-data/git/fv3gfs/fix/fix_sfc_climo"
  ;;

"ODIN")
  FIXgsm="/scratch/ywang/fix/theia_fix/fix_am"
  SFC_CLIMO_INPUT_DIR="/scratch1/NCEPDEV/da/George.Gayno/ufs_utils.git/climo_fields_netcdf"
  ;;
"CHEYENNE")
  FIXgsm="/glade/p/ral/jntp/UFS_CAM/fix/fix_am"
  SFC_CLIMO_INPUT_DIR="/glade/p/ral/jntp/UFS_CAM/fix/climo_fields_netcdf"
  ;;

*)
  print_err_msg_exit "\
Directories have not been specified for this machine:
  MACHINE = \"$MACHINE\""
  ;;

esac
#
#-----------------------------------------------------------------------
#
# Set the base directories in which codes obtained from external reposi-
# tories (using the manage_externals tool) are placed.  Obtain the rela-
# tive paths to these directories by reading them in from the manage_ex-
# ternals configuration file.  (Note that these are relative to the lo-
# cation of the configuration file.)  Then form the full paths to these
# directories.  Finally, make sure that each of these directories actu-
# ally exists.
#
#-----------------------------------------------------------------------
#
mng_extrns_cfg_fn="$HOMErrfs/Externals.cfg"
mdl_extrns_cfg_fn="$HOMErrfs/conf/fcst_model.cfg"

model_name=$( get_fcst_model_name $EXPT_CONFIG_FN )
get_fcst_model_info ${mdl_extrns_cfg_fn} "${model_name}" external_name
#
# Get the base directory of the FV3 forecast model code.
#
property_name="local_path"
UFS_WTHR_MDL_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

UFS_WTHR_MDL_DIR="$HOMErrfs/${UFS_WTHR_MDL_DIR}"
if [ ! -d "${UFS_WTHR_MDL_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the FV3 source code should be located
(UFS_WTHR_MDL_DIR) does not exist:
  UFS_WTHR_MDL_DIR = \"${UFS_WTHR_MDL_DIR}\"
Please clone the external repository containing the code in this directory,
build the executable, and then rerun the workflow."
fi
#
# Get the base directory of the UFS_UTILS codes (except for chgres).
#
external_name="ufs_utils"
UFS_UTILS_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

UFS_UTILS_DIR="$HOMErrfs/${UFS_UTILS_DIR}"
if [ ! -d "${UFS_UTILS_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the UFS utilities source codes should be lo-
cated (UFS_UTILS_DIR) does not exist:
  UFS_UTILS_DIR = \"${UFS_UTILS_DIR}\"
Please clone the external repository containing the code in this direct-
ory, build the executables, and then rerun the workflow."
fi
#
# Get the base directory of the chgres code.
#
external_name="ufs_utils_chgres"
CHGRES_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

CHGRES_DIR="$HOMErrfs/${CHGRES_DIR}"
if [ ! -d "${CHGRES_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the chgres source code should be located 
(CHGRES_DIR) does not exist:
  CHGRES_DIR = \"${CHGRES_DIR}\"
Please clone the external repository containing the code in this direct-
ory, build the executable, and then rerun the workflow."
fi
#
# Get the base directory of the EMC_post code.
#
external_name="EMC_post"
EMC_POST_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

EMC_POST_DIR="$HOMErrfs/${EMC_POST_DIR}"
if [ ! -d "${EMC_POST_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the EMC_post source code should be located
(EMC_POST_DIR) does not exist:
  EMS_POST_DIR = \"${EMC_POST_DIR}\"
Please clone the external repository containing the code in this directory,
build the executable, and then rerun the workflow."
fi
#
# Get the base directory of the NEXUS code if required
#
external_name="arl_nexus"
ARL_NEXUS_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

ARL_NEXUS_DIR="$HOMErrfs/${ARL_NEXUS_DIR}"
if [ ! -d "${ARL_NEXUS_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the arl_nexus source code should be located
(ARL_NEXUS_DIR) does not exist:
  ARL_NEXUS_DIR = \"${ARL_NEXUS_DIR}\"
Please clone the external repository containing the code in this directory,
build the executable, and then rerun the workflow."
fi
#
# Get the base directory of the JEDI code if required
#
external_name="jedi-fv3-bundle"
JEDI_DIR=$( \
get_manage_externals_config_property \
"${mng_extrns_cfg_fn}" "${external_name}" "${property_name}" ) || \
print_err_msg_exit "\
Call to function get_manage_externals_config_property failed."

JEDI_DIR="$HOMErrfs/${JEDI_DIR}"
if [ ! -d "${JEDI_DIR}" ]; then
  print_err_msg_exit "\
The base directory in which the JEDI source code should be located
(JEDI_DIR) does not exist:
  JEDI_DIR = \"${JEDI_DIR}\"
Please clone the external repository containing the code in this directory,
build the executable, and then rerun the workflow."
fi
#
#-----------------------------------------------------------------------
#
# Set the names of the various tasks in the rocoto workflow XML.
#
#-----------------------------------------------------------------------
#
MAKE_GRID_TN="make_grid"
MAKE_OROG_TN="make_orog"
MAKE_SFC_CLIMO_TN="make_sfc_climo"
ADD_AQM_ICS_TN="add_aqm_ics"
ADD_AQM_LBCS_TN="add_aqm_lbcs"
GET_EXTRN_ICS_TN="get_extrn_ics"
GET_EXTRN_LBCS_TN="get_extrn_lbcs"
MAKE_ICS_TN="make_ics"
MAKE_LBCS_TN="make_lbcs"
RUN_NEXUS_TN="run_nexus"
RUN_CHEM_ANAL="run_chem_anal"
RUN_FCST_TN="run_fcst"
RUN_POST_TN="run_post"
#
#-----------------------------------------------------------------------
#
# The forecast length (in integer hours) cannot contain more than 3 cha-
# racters.  Thus, its maximum value is 999.  Check whether the specified
# forecast length exceeds this maximum value.  If so, print out a warn-
# ing and exit this script.
#
#-----------------------------------------------------------------------
#
FCST_LEN_HRS_MAX="999"
if [ "$FCST_LEN_HRS" -gt "$FCST_LEN_HRS_MAX" ]; then
  print_err_msg_exit "\
Forecast length is greater than maximum allowed length:
  FCST_LEN_HRS = $FCST_LEN_HRS
  FCST_LEN_HRS_MAX = $FCST_LEN_HRS_MAX"
fi
#
#-----------------------------------------------------------------------
#
# Check whether the forecast length (FCST_LEN_HRS) is evenly divisible
# by the BC update interval (LBC_UPDATE_INTVL_HRS).  If not, print out a
# warning and exit this script.  If so, generate an array of forecast
# hours at which the boundary values will be updated.
#
#-----------------------------------------------------------------------
#
rem=$(( ${FCST_LEN_HRS}%${LBC_UPDATE_INTVL_HRS} ))

if [ "$rem" -ne "0" ]; then
  print_err_msg_exit "\
The forecast length (FCST_LEN_HRS) is not evenly divisible by the later-
al boundary conditions update interval (LBC_UPDATE_INTVL_HRS):
  FCST_LEN_HRS = $FCST_LEN_HRS
  LBC_UPDATE_INTVL_HRS = $LBC_UPDATE_INTVL_HRS
  rem = FCST_LEN_HRS%%LBC_UPDATE_INTVL_HRS = $rem"
fi
#
#-----------------------------------------------------------------------
#
# Set the array containing the forecast hours at which the lateral 
# boundary conditions (LBCs) need to be updated.  Note that this array
# does not include the 0-th hour (initial time).
#
#-----------------------------------------------------------------------
#
LBC_UPDATE_FCST_HRS=($( seq ${LBC_UPDATE_INTVL_HRS} \
                            ${LBC_UPDATE_INTVL_HRS} \
                            ${FCST_LEN_HRS} ))
#
#-----------------------------------------------------------------------
#
# If PREDEF_GRID_NAME is set to a non-empty string, set or reset parame-
# ters according to the predefined domain specified.
#
#-----------------------------------------------------------------------
#
if [ ! -z "${PREDEF_GRID_NAME}" ]; then
  . $USHDIR/set_predef_grid_params.sh
fi
#
#-----------------------------------------------------------------------
#
# For a "GFDLgrid" type of grid, make sure GFDLgrid_RES is set to a va-
# lid value.
#
#-----------------------------------------------------------------------
#
if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then
  err_msg="\
The number of grid cells per tile in each horizontal direction specified
in GFDLgrid_RES is not supported:
  GFDLgrid_RES = \"${GFDLgrid_RES}\""
  check_var_valid_value "GFDLgrid_RES" "valid_vals_GFDLgrid_RES" "${err_msg}"
fi
#
#-----------------------------------------------------------------------
#
# If the base directory (EXPT_BASEDIR) in which the experiment subdirec-
# tory (EXPT_SUBDIR) will be located is not set or is set to an empty 
# string, set it to a default location that is at the same level as the
# workflow directory (HOMErrfs).  Then create EXPT_BASEDIR if it doesn't
# already exist.
#
#-----------------------------------------------------------------------
#
EXPT_BASEDIR="${EXPT_BASEDIR:-${HOMErrfs}/../expt_dirs}"
EXPT_BASEDIR="$( readlink -f -m ${EXPT_BASEDIR} )"
mkdir_vrfy -p "${EXPT_BASEDIR}"
#
#-----------------------------------------------------------------------
#
# If the experiment subdirectory name (EXPT_SUBDIR) is set to an empty
# string, print out an error message and exit.
#
#-----------------------------------------------------------------------
#
if [ -z "${EXPT_SUBDIR}" ]; then
  print_err_msg_exit "\
The name of the experiment subdirectory (EXPT_SUBDIR) cannot be empty:
  EXPT_SUBDIR = \"${EXPT_SUBDIR}\""
fi
#
#-----------------------------------------------------------------------
#
# Set the full path to the experiment directory.  Then check if it al-
# ready exists and if so, deal with it as specified by PREEXISTING_DIR_-
# METHOD.
#
#-----------------------------------------------------------------------
#
# May have to make setting of EXPTDIR dependent on RUN_ENVIR later on.
EXPTDIR="${EXPT_BASEDIR}/${EXPT_SUBDIR}"
check_for_preexist_dir $EXPTDIR ${PREEXISTING_DIR_METHOD}

LOGDIR="${EXPTDIR}/log"
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  FIXam="${FIXrrfs}/fix_am"
  FIXsar="${FIXrrfs}/fix_sar/${EMC_GRID_NAME}"
  COMROOT="$PTMP/com"
#
# In NCO mode (i.e. if RUN_ENVIR set to "nco"), it is assumed that before
# running the experiment generation script, the path specified in FIXam 
# already exists and is either itself the directory in which various fixed
# files (but not the ones containing the regional grid and the orography
# and surface climatology on that grid) are located, or it is a symlink 
# to such a directory.  Resolve any symlinks in the path specified by 
# FIXam and check that this is the case.
#
  path_resolved=$( readlink -m "$FIXam" )
  if [ ! -d "${path_resolved}" ]; then
    print_err_msg_exit "\
In NCO mode (RUN_ENVIR set to \"nco\"), the path specified by FIXam after
resolving all symlinks (path_resolved) must point to an existing directory
before an experiment can be generated.  In this case, path_resolved is
not a directory or does not exist:
  RUN_ENVIR = \"${RUN_ENVIR}\"
  FIXam = \"$FIXam\"
  path_resolved = \"${path_resolved}\"
Please correct and then rerun the experiment generation script."
  fi
#
# In NCO mode (i.e. if RUN_ENVIR set to "nco"), it is assumed that before
# running the experiment generation script, the path specified in FIXsar 
# already exists and is either itself the directory in which the fixed 
# grid, orography, and surface climatology files are located, or it is a
# symlink to such a directory.  Resolve any symlinks in the path specified
# by FIXsar and check that this is the case.
#
  path_resolved=$( readlink -m "$FIXsar" )
  if [ ! -d "${path_resolved}" ]; then
    print_err_msg_exit "\
In NCO mode (RUN_ENVIR set to \"nco\"), the path specified by FIXsar after
resolving all symlinks (path_resolved) must point to an existing directory
before an experiment can be generated.  In this case, path_resolved is
not a directory or does not exist:
  RUN_ENVIR = \"${RUN_ENVIR}\"
  FIXsar = \"$FIXsar\"
  path_resolved = \"${path_resolved}\"
Please correct and then rerun the experiment generation script."
  fi

else

  FIXam="${EXPTDIR}/fix_am"
  FIXsar="${EXPTDIR}/fix_sar"
  COMROOT=""

fi
#
#-----------------------------------------------------------------------
#
# The FV3 forecast model needs the following input files in the run di-
# rectory to start a forecast:
#
#   (1) The data table file
#   (2) The diagnostics table file
#   (3) The field table file
#   (4) The FV3 namelist file
#   (5) The model configuration file
#   (6) The NEMS configuration file
#
# If using CCPP, it also needs:
#
#   (7) The CCPP physics suite definition file
#
# The workflow contains templates for the first six of these files.  
# Template files are versions of these files that contain placeholder
# (i.e. dummy) values for various parameters.  The experiment/workflow 
# generation scripts copy these templates to appropriate locations in 
# the experiment directory (either the top of the experiment directory
# or one of the cycle subdirectories) and replace the placeholders in
# these copies by actual values specified in the experiment/workflow 
# configuration file (or derived from such values).  The scripts then
# use the resulting "actual" files as inputs to the forecast model.
#
# Note that the CCPP physics suite defintion file does not have a cor-
# responding template file because it does not contain any values that
# need to be replaced according to the experiment/workflow configura-
# tion.  If using CCPP, this file simply needs to be copied over from 
# its location in the forecast model's directory structure to the ex-
# periment directory.
#
# Below, we first set the names of the templates for the first six files
# listed above.  We then set the full paths to these template files.  
# Note that some of these file names depend on the physics suite while
# others do not.
#
#-----------------------------------------------------------------------
#
dot_ccpp_phys_suite_or_null=""
if [ "${USE_CCPP}" = "TRUE" ]; then
  dot_ccpp_phys_suite_or_null=".${CCPP_PHYS_SUITE}"
fi

DATA_TABLE_TMPL_FN="${DATA_TABLE_FN}"
DIAG_TABLE_TMPL_FN="${DIAG_TABLE_FN}${dot_ccpp_phys_suite_or_null}"
FIELD_TABLE_TMPL_FN="${FIELD_TABLE_FN}${dot_ccpp_phys_suite_or_null}"
MODEL_CONFIG_TMPL_FN="${MODEL_CONFIG_FN}${dot_ccpp_phys_suite_or_null}"
NEMS_CONFIG_TMPL_FN="${NEMS_CONFIG_FN}"

DATA_TABLE_TMPL_FP="${TEMPLATE_DIR}/${DATA_TABLE_TMPL_FN}"
DIAG_TABLE_TMPL_FP="${TEMPLATE_DIR}/${DIAG_TABLE_TMPL_FN}"
FIELD_TABLE_TMPL_FP="${TEMPLATE_DIR}/${FIELD_TABLE_TMPL_FN}"
FV3_NML_BASE_FP="${TEMPLATE_DIR}/${FV3_NML_FN}"
get_fcst_model_info ${mdl_extrns_cfg_fn} "${model_name}" input_dir parse_files
# Get full path
mdl_input_path=$( readlink -f "${input_dir}" )

# If empty, try adding workflow base path
if [ -z "${mdl_input_path}" ]; then
  mdl_input_path=$( readlink -f "${HOMErrfs}/${input_dir}" )
fi

# If still empty bail out
if [ -z "${mdl_input_path}" ]; then
  print_err_msg_exit "\
  Could not retrieve full path to model input files"
fi
#
for file in ${parse_files}; do
  case "${file}" in
    ${FV3_NML_FN%.*}.*)
      FV3_NML_BASE_FP="${mdl_input_path}/${file}"
  esac
done
FV3_NML_CONFIG_FP="${TEMPLATE_DIR}/${FV3_NML_CONFIG}"
MODEL_CONFIG_TMPL_FP="${TEMPLATE_DIR}/${MODEL_CONFIG_TMPL_FN}"
NEMS_CONFIG_TMPL_FP="${TEMPLATE_DIR}/${NEMS_CONFIG_TMPL_FN}"
#
#-----------------------------------------------------------------------
#
# If using CCPP, set:
#
# 1) the variable CCPP_PHYS_SUITE_FN to the name of the CCPP physics 
#    suite definition file.
# 2) the variable CCPP_PHYS_SUITE_IN_CCPP_FP to the full path of this 
#    file in the forecast model's directory structure.
# 3) the variable CCPP_PHYS_SUITE_FP to the full path of this file in 
#    the experiment directory.
#
# Note that the experiment/workflow generation scripts will copy this
# file from CCPP_PHYS_SUITE_IN_CCPP_FP to CCPP_PHYS_SUITE_FP.  Then, for
# each cycle, the forecast launch script will create a link in the cycle
# run directory to the copy of this file at CCPP_PHYS_SUITE_FP.
#
# Note that if not using CCPP, the variables described above will get 
# set to null strings.
#
#-----------------------------------------------------------------------
#
CCPP_PHYS_SUITE_FN=""
CCPP_PHYS_SUITE_IN_CCPP_FP=""
CCPP_PHYS_SUITE_FP=""

if [ "${USE_CCPP}" = "TRUE" ]; then
  CCPP_PHYS_SUITE_FN="suite_${CCPP_PHYS_SUITE}.xml"
  CCPP_PHYS_SUITE_IN_CCPP_FP="${UFS_WTHR_MDL_DIR}/FV3/ccpp/suites/${CCPP_PHYS_SUITE_FN}"
  CCPP_PHYS_SUITE_FP="${EXPTDIR}/${CCPP_PHYS_SUITE_FN}"
fi
#
#-----------------------------------------------------------------------
#
# Set the full paths to those forecast model input files that are cycle-
# independent, i.e. they don't include information about the cycle's 
# starting day/time.  These are:
#
#   * The data table file [(1) in the list above)]
#   * The field table file [(3) in the list above)]
#   * The FV3 namelist file [(4) in the list above)]
#   * The NEMS configuration file [(6) in the list above)]
#
# Since they are cycle-independent, the experiment/workflow generation
# scripts will place them in the main experiment directory (EXPTDIR).
# The script that runs each cycle will then create links to these files
# in the run directories of the individual cycles (which are subdirecto-
# ries under EXPTDIR).  
# 
# The remaining two input files to the forecast model, i.e.
#
#   * The diagnostics table file [(2) in the list above)]
#   * The model configuration file [(5) in the list above)]
#
# contain parameters that depend on the cycle start date.  Thus, custom
# versions of these two files must be generated for each cycle and then
# placed directly in the run directories of the cycles (not EXPTDIR).
# For this reason, the full paths to their locations vary by cycle and
# cannot be set here (i.e. they can only be set in the loop over the 
# cycles in the rocoto workflow XML file).
#
#-----------------------------------------------------------------------
#
DATA_TABLE_FP="${EXPTDIR}/${DATA_TABLE_FN}"
FIELD_TABLE_FP="${EXPTDIR}/${FIELD_TABLE_FN}"
FV3_NML_FP="${EXPTDIR}/${FV3_NML_FN%.*}"
NEMS_CONFIG_FP="${EXPTDIR}/${NEMS_CONFIG_FN}"
#
#-----------------------------------------------------------------------
#
# Set the full path to the script that can be used to (re)launch the 
# workflow.  Also, if USE_CRON_TO_RELAUNCH is set to TRUE, set the line
# to add to the cron table to automatically relaunch the workflow every
# CRON_RELAUNCH_INTVL_MNTS minutes.  Otherwise, set the variable con-
# taining this line to a null string.
#
#-----------------------------------------------------------------------
#
WFLOW_LAUNCH_SCRIPT_FP="$USHDIR/${WFLOW_LAUNCH_SCRIPT_FN}"
WFLOW_LAUNCH_LOG_FP="$EXPTDIR/${WFLOW_LAUNCH_LOG_FN}"
if [ "${USE_CRON_TO_RELAUNCH}" = "TRUE" ]; then
  CRONTAB_LINE="*/${CRON_RELAUNCH_INTVL_MNTS} * * * * cd $EXPTDIR && \
./${WFLOW_LAUNCH_SCRIPT_FN} >> ./${WFLOW_LAUNCH_LOG_FN} 2>&1"
else
  CRONTAB_LINE=""
fi
#
#-----------------------------------------------------------------------
#
# Define the various work subdirectories under the main work directory.
# Each of these corresponds to a different step/substep/task in the pre-
# processing, as follows:
#
# GRID_DIR:
# Directory in which the grid files will be placed (if RUN_TASK_MAKE_-
# GRID is set to "TRUE") or searched for (if RUN_TASK_MAKE_GRID is set
# to "FALSE").
#
# OROG_DIR:
# Directory in which the orography files will be placed (if RUN_TASK_-
# MAKE_OROG is set to "TRUE") or searched for (if RUN_TASK_MAKE_OROG is
# set to "FALSE").
#
# SFC_CLIMO_DIR:
# Directory in which the surface climatology files will be placed (if
# RUN_TASK_MAKE_SFC_CLIMO is set to "TRUE") or searched for (if RUN_-
# TASK_MAKE_SFC_CLIMO is set to "FALSE").
#
#----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  if [ "${RUN_TASK_MAKE_GRID}" = "TRUE" ] || \
     [ "${RUN_TASK_MAKE_GRID}" = "FALSE" -a \
       "${GRID_DIR}" != "$FIXsar" ]; then

    msg="
When RUN_ENVIR is set to \"nco\", it is assumed that grid files already
exist in the directory specified by FIXsar.  Thus, the grid file genera-
tion task must not be run (i.e. RUN_TASK_MAKE_GRID must be set to 
FALSE), and the directory in which to look for the grid files (i.e. 
GRID_DIR) must be set to FIXsar.  Current values for these quantities
are:
  RUN_TASK_MAKE_GRID = \"${RUN_TASK_MAKE_GRID}\"
  GRID_DIR = \"${GRID_DIR}\"
Resetting RUN_TASK_MAKE_GRID to \"FALSE\" and GRID_DIR to the contents
of FIXsar.  Reset values are:"

    RUN_TASK_MAKE_GRID="FALSE"
    GRID_DIR="$FIXsar"

    msg="$msg""
  RUN_TASK_MAKE_GRID = \"${RUN_TASK_MAKE_GRID}\"
  GRID_DIR = \"${GRID_DIR}\"
"

    print_info_msg "$msg"
  
  fi

  if [ "${RUN_TASK_MAKE_OROG}" = "TRUE" ] || \
     [ "${RUN_TASK_MAKE_OROG}" = "FALSE" -a \
       "${OROG_DIR}" != "$FIXsar" ]; then

    msg="
When RUN_ENVIR is set to \"nco\", it is assumed that orography files al-
ready exist in the directory specified by FIXsar.  Thus, the orography 
file generation task must not be run (i.e. RUN_TASK_MAKE_OROG must be 
set to FALSE), and the directory in which to look for the orography 
files (i.e. OROG_DIR) must be set to FIXsar.  Current values for these
quantities are:
  RUN_TASK_MAKE_OROG = \"${RUN_TASK_MAKE_OROG}\"
  OROG_DIR = \"${OROG_DIR}\"
Resetting RUN_TASK_MAKE_OROG to \"FALSE\" and OROG_DIR to the contents
of FIXsar.  Reset values are:"

    RUN_TASK_MAKE_OROG="FALSE"
    OROG_DIR="$FIXsar"

    msg="$msg""
  RUN_TASK_MAKE_OROG = \"${RUN_TASK_MAKE_OROG}\"
  OROG_DIR = \"${OROG_DIR}\"
"

    print_info_msg "$msg"
  
  fi

  if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "TRUE" ] || \
     [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" -a \
       "${SFC_CLIMO_DIR}" != "$FIXsar" ]; then

    msg="
When RUN_ENVIR is set to \"nco\", it is assumed that surface climatology
files already exist in the directory specified by FIXsar.  Thus, the 
surface climatology file generation task must not be run (i.e. RUN_-
TASK_MAKE_SFC_CLIMO must be set to FALSE), and the directory in which to
look for the surface climatology files (i.e. SFC_CLIMO_DIR) must be set
to FIXsar.  Current values for these quantities are:
  RUN_TASK_MAKE_SFC_CLIMO = \"${RUN_TASK_MAKE_SFC_CLIMO}\"
  SFC_CLIMO_DIR = \"${SFC_CLIMO_DIR}\"
Resetting RUN_TASK_MAKE_SFC_CLIMO to \"FALSE\" and SFC_CLIMO_DIR to the
contents of FIXsar.  Reset values are:"

    RUN_TASK_MAKE_SFC_CLIMO="FALSE"
    SFC_CLIMO_DIR="$FIXsar"

    msg="$msg""
  RUN_TASK_MAKE_SFC_CLIMO = \"${RUN_TASK_MAKE_SFC_CLIMO}\"
  SFC_CLIMO_DIR = \"${SFC_CLIMO_DIR}\"
"

    print_info_msg "$msg"
  
  fi

else
#
#-----------------------------------------------------------------------
#
# If RUN_TASK_MAKE_GRID is set to "FALSE", the workflow will look for 
# the pre-generated grid files in GRID_DIR.  In this case, make sure 
# that GRID_DIR exists.  Otherwise, set it to a predefined location un-
# der the experiment directory (EXPTDIR).
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_GRID}" = "FALSE" ]; then
    if [ ! -d "${GRID_DIR}" ]; then
      print_err_msg_exit "\
The directory (GRID_DIR) that should contain the pre-generated grid 
files does not exist:
  GRID_DIR = \"${GRID_DIR}\""
    fi
  else
    GRID_DIR="$EXPTDIR/grid"
  fi
#
#-----------------------------------------------------------------------
#
# If RUN_TASK_MAKE_OROG is set to "FALSE", the workflow will look for 
# the pre-generated orography files in OROG_DIR.  In this case, make 
# sure that OROG_DIR exists.  Otherwise, set it to a predefined location
# under the experiment directory (EXPTDIR).
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_OROG}" = "FALSE" ]; then
    if [ ! -d "${OROG_DIR}" ]; then
      print_err_msg_exit "\
The directory (OROG_DIR) that should contain the pre-generated orography
files does not exist:
  OROG_DIR = \"${OROG_DIR}\""
    fi
  else
    OROG_DIR="$EXPTDIR/orog"
  fi
#
#-----------------------------------------------------------------------
#
# If RUN_TASK_MAKE_SFC_CLIMO is set to "FALSE", the workflow will look 
# for the pre-generated surface climatology files in SFC_CLIMO_DIR.  In
# this case, make sure that SFC_CLIMO_DIR exists.  Otherwise, set it to
# a predefined location under the experiment directory (EXPTDIR).
#
#-----------------------------------------------------------------------
#
  if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" ]; then

    if [ ! -d "${SFC_CLIMO_DIR}" ]; then
      print_err_msg_exit "\
The directory (SFC_CLIMO_DIR) that should contain the pre-generated orography
files does not exist:
  SFC_CLIMO_DIR = \"${SFC_CLIMO_DIR}\""
    fi

  else
    SFC_CLIMO_DIR="$EXPTDIR/sfc_climo"
  fi

fi
#
#-----------------------------------------------------------------------
#
# Make sure EXTRN_MDL_NAME_ICS is set to a valid value.
#
#-----------------------------------------------------------------------
#
err_msg="\
The external model specified in EXTRN_MDL_NAME_ICS that provides initial
conditions (ICs) and surface fields to the FV3SAR is not supported:
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\""
check_var_valid_value \
  "EXTRN_MDL_NAME_ICS" "valid_vals_EXTRN_MDL_NAME_ICS" "${err_msg}"
#
#-----------------------------------------------------------------------
#
# Make sure EXTRN_MDL_NAME_LBCS is set to a valid value.
#
#-----------------------------------------------------------------------
#
err_msg="\
The external model specified in EXTRN_MDL_NAME_ICS that provides lateral
boundary conditions (LBCs) to the FV3SAR is not supported:
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\""
check_var_valid_value \
  "EXTRN_MDL_NAME_LBCS" "valid_vals_EXTRN_MDL_NAME_LBCS" "${err_msg}"
#
#-----------------------------------------------------------------------
#
# Make sure FV3GFS_FILE_FMT_ICS is set to a valid value.
#
#-----------------------------------------------------------------------
#
if [ "${EXTRN_MDL_NAME_ICS}" = "FV3GFS" ]; then
  err_msg="\
The file format for FV3GFS external model files specified in FV3GFS_-
FILE_FMT_ICS is not supported:
  FV3GFS_FILE_FMT_ICS = \"${FV3GFS_FILE_FMT_ICS}\""
  check_var_valid_value \
    "FV3GFS_FILE_FMT_ICS" "valid_vals_FV3GFS_FILE_FMT_ICS" "${err_msg}"
fi
#
#-----------------------------------------------------------------------
#
# Make sure FV3GFS_FILE_FMT_LBCS is set to a valid value.
#
#-----------------------------------------------------------------------
#
if [ "${EXTRN_MDL_NAME_LBCS}" = "FV3GFS" ]; then
  err_msg="\
The file format for FV3GFS external model files specified in FV3GFS_-
FILE_FMT_LBCS is not supported:
  FV3GFS_FILE_FMT_LBCS = \"${FV3GFS_FILE_FMT_LBCS}\""
  check_var_valid_value \
    "FV3GFS_FILE_FMT_LBCS" "valid_vals_FV3GFS_FILE_FMT_LBCS" "${err_msg}"
fi
#
#-----------------------------------------------------------------------
#
# If the run environment is "nco", the external model for both the ICs
# and the LBCs should be either the FV3GFS or the GSMGFS.
#
#-----------------------------------------------------------------------
#
if [ "${RUN_ENVIR}" = "nco" ]; then

  if [ "${EXTRN_MDL_NAME_ICS}" != "FV3GFS" ] && \
     [ "${EXTRN_MDL_NAME_ICS}" != "GSMGFS" ]; then
    print_err_msg_exit "\
When RUN_ENVIR set to \"nco\", the external model used for the initial
conditions and surface fields must be either \"FV3GFS\" or \"GSMGFS\":
  RUN_ENVIR = \"${RUN_ENVIR}\"
  EXTRN_MDL_NAME_ICS = \"${EXTRN_MDL_NAME_ICS}\""
  fi

  if [ "${EXTRN_MDL_NAME_LBCS}" != "FV3GFS" ] && \
     [ "${EXTRN_MDL_NAME_LBCS}" != "GSMGFS" ]; then
    print_err_msg_exit "\
When RUN_ENVIR set to \"nco\", the external model used for the initial
conditions and surface fields must be either \"FV3GFS\" or \"GSMGFS\":
  RUN_ENVIR = \"${RUN_ENVIR}\"
  EXTRN_MDL_NAME_LBCS = \"${EXTRN_MDL_NAME_LBCS}\""
  fi

fi
#
#-----------------------------------------------------------------------
#
# Set cycle-independent parameters associated with the external models
# from which we will obtain the ICs and LBCs.
#
#-----------------------------------------------------------------------
#
. ./set_extrn_mdl_params.sh
















#
#-----------------------------------------------------------------------
#
# Any regional model must be supplied lateral boundary conditions (in
# addition to initial conditions) to be able to perform a forecast.  In
# the FV3SAR model, these boundary conditions (BCs) are supplied using a
# "halo" of grid cells around the regional domain that extend beyond the
# boundary of the domain.  The model is formulated such that along with
# files containing these BCs, it needs as input the following files (in
# NetCDF format):
#
# 1) A grid file that includes a halo of 3 cells beyond the boundary of
#    the domain.
# 2) A grid file that includes a halo of 4 cells beyond the boundary of
#    the domain.
# 3) A (filtered) orography file without a halo, i.e. a halo of width
#    0 cells.
# 4) A (filtered) orography file that includes a halo of 4 cells beyond
#    the boundary of the domain.
#
# Note that the regional grid is referred to as "tile 7" in the code.
# We will let:
#
# * NH0 denote the width (in units of number of cells on tile 7) of
#   the 0-cell-wide halo, i.e. NH0 = 0;
#
# * NH3 denote the width (in units of number of cells on tile 7) of
#   the 3-cell-wide halo, i.e. NH3 = 3; and
#
# * NH4 denote the width (in units of number of cells on tile 7) of
#   the 4-cell-wide halo, i.e. NH4 = 4.
#
# We define these variables next.
#
#-----------------------------------------------------------------------
#
NH0=0
NH3=3
NH4=4
#
#-----------------------------------------------------------------------
#
# Make sure GRID_GEN_METHOD is set to a valid value.
#
#-----------------------------------------------------------------------
#
err_msg="\
The horizontal grid generation method specified in GRID_GEN_METHOD is 
not supported:
  GRID_GEN_METHOD = \"${GRID_GEN_METHOD}\""
check_var_valid_value \
  "GRID_GEN_METHOD" "valid_vals_GRID_GEN_METHOD" "${err_msg}"
#
#-----------------------------------------------------------------------
#
# Set parameters according to the type of horizontal grid generation me-
# thod specified.  First consider GFDL's global-parent-grid based me-
# thod.
#
#-----------------------------------------------------------------------
#
if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then

  set_gridparams_GFDLgrid \
    lon_of_t6_ctr="${GFDLgrid_LON_T6_CTR}" \
    lat_of_t6_ctr="${GFDLgrid_LAT_T6_CTR}" \
    res_of_t6g="${GFDLgrid_RES}" \
    stretch_factor="${GFDLgrid_STRETCH_FAC}" \
    refine_ratio_t6g_to_t7g="${GFDLgrid_REFINE_RATIO}" \
    istart_of_t7_on_t6g="${GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G}" \
    iend_of_t7_on_t6g="${GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G}" \
    jstart_of_t7_on_t6g="${GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G}" \
    jend_of_t7_on_t6g="${GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G}" \
    output_varname_lon_of_t7_ctr="LON_CTR" \
    output_varname_lat_of_t7_ctr="LAT_CTR" \
    output_varname_nx_of_t7_on_t7g="NX" \
    output_varname_ny_of_t7_on_t7g="NY" \
    output_varname_halo_width_on_t7g="NHW" \
    output_varname_stretch_factor="STRETCH_FAC" \
    output_varname_istart_of_t7_with_halo_on_t6sg="ISTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG" \
    output_varname_iend_of_t7_with_halo_on_t6sg="IEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG" \
    output_varname_jstart_of_t7_with_halo_on_t6sg="JSTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG" \
    output_varname_jend_of_t7_with_halo_on_t6sg="JEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG"
#
#-----------------------------------------------------------------------
#
# Now consider Jim Purser's map projection/grid generation method.
#
#-----------------------------------------------------------------------
#
elif [ "${GRID_GEN_METHOD}" = "JPgrid" ]; then

  set_gridparams_JPgrid \
    lon_ctr="${JPgrid_LON_CTR}" \
    lat_ctr="${JPgrid_LAT_CTR}" \
    nx="${JPgrid_NX}" \
    ny="${JPgrid_NY}" \
    halo_width="${JPgrid_WIDE_HALO_WIDTH}" \
    delx="${JPgrid_DELX}" \
    dely="${JPgrid_DELY}" \
    alpha="${JPgrid_ALPHA_PARAM}" \
    kappa="${JPgrid_KAPPA_PARAM}" \
    output_varname_lon_ctr="LON_CTR" \
    output_varname_lat_ctr="LAT_CTR" \
    output_varname_nx="NX" \
    output_varname_ny="NY" \
    output_varname_halo_width="NHW" \
    output_varname_stretch_factor="STRETCH_FAC" \
    output_varname_del_angle_x_sg="DEL_ANGLE_X_SG" \
    output_varname_del_angle_y_sg="DEL_ANGLE_Y_SG" \
    output_varname_neg_nx_of_dom_with_wide_halo="NEG_NX_OF_DOM_WITH_WIDE_HALO" \
    output_varname_neg_ny_of_dom_with_wide_halo="NEG_NY_OF_DOM_WITH_WIDE_HALO"

fi
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
RES_IN_FIXSAR_FILENAMES=""

if [ "${RUN_ENVIR}" != "nco" ]; then
  mkdir_vrfy -p "$FIXsar"
fi
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#
# Is this if-statement still necessary?
if [ "${RUN_ENVIR}" = "nco" ]; then

  glob_pattern="C*_mosaic.nc"
  cd_vrfy $FIXsar
  num_files=$( ls -1 ${glob_pattern} 2>/dev/null | wc -l )

  if [ "${num_files}" -ne "1" ]; then
    print_err_msg_exit "\
Exactly one file must exist in directory FIXsar matching the globbing
pattern glob_pattern:
  FIXsar = \"${FIXsar}\"
  glob_pattern = \"${glob_pattern}\"
  num_files = ${num_files}"
  fi

  fn=$( ls -1 ${glob_pattern} )
  RES_IN_FIXSAR_FILENAMES=$( printf "%s" $fn | sed -n -r -e "s/^C([0-9]*)_mosaic.nc/\1/p" )
echo "RES_IN_FIXSAR_FILENAMES = ${RES_IN_FIXSAR_FILENAMES}"

  if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ] && \
     [ "${GFDLgrid_RES}" -ne "${RES_IN_FIXSAR_FILENAMES}" ]; then
    print_err_msg_exit "\
The resolution extracted from the fixed file names (RES_IN_FIXSAR_FILENAMES)
does not match the resolution specified by GFDLgrid_RES:
  GFDLgrid_RES = ${GFDLgrid_RES}
  RES_IN_FIXSAR_FILENAMES = ${RES_IN_FIXSAR_FILENAMES}"
  fi

#  RES_equiv=$( ncdump -h "${grid_fn}" | grep -o ":RES_equiv = [0-9]\+" | grep -o "[0-9]")
#  RES_equiv=${RES_equiv//$'\n'/}
#printf "%s\n" "RES_equiv = $RES_equiv"
#  CRES_equiv="C${RES_equiv}"
#printf "%s\n" "CRES_equiv = $CRES_equiv"
#
#  RES="$RES_equiv"
#  CRES="$CRES_equiv"

else
#
#-----------------------------------------------------------------------
#
# If the grid file generation task in the workflow is going to be
# skipped (because pregenerated files are available), create links in
# the FIXsar directory to the pregenerated grid files.
#
#-----------------------------------------------------------------------
#
  res_in_grid_fns=""
  if [ "${RUN_TASK_MAKE_GRID}" = "FALSE" ]; then

    link_fix \
      verbose="$VERBOSE" \
      file_group="grid" \
      output_varname_res_in_filenames="res_in_grid_fns" || \
    print_err_msg_exit "\
  Call to function to create links to grid files failed."

    RES_IN_FIXSAR_FILENAMES="${res_in_grid_fns}"

  fi
#
#-----------------------------------------------------------------------
#
# If the orography file generation task in the workflow is going to be
# skipped (because pregenerated files are available), create links in
# the FIXsar directory to the pregenerated orography files.
#
#-----------------------------------------------------------------------
#
  res_in_orog_fns=""
  if [ "${RUN_TASK_MAKE_OROG}" = "FALSE" ]; then

    link_fix \
      verbose="$VERBOSE" \
      file_group="orog" \
      output_varname_res_in_filenames="res_in_orog_fns" || \
    print_err_msg_exit "\
  Call to function to create links to orography files failed."

    if [ ! -z "${RES_IN_FIXSAR_FILENAMES}" ] && \
       [ "${res_in_orog_fns}" -ne "${RES_IN_FIXSAR_FILENAMES}" ]; then
      print_err_msg_exit "\
  The resolution extracted from the orography file names (res_in_orog_fns)
  does not match the resolution in other groups of files already consi-
  dered (RES_IN_FIXSAR_FILENAMES):
    res_in_orog_fns = ${res_in_orog_fns}
    RES_IN_FIXSAR_FILENAMES = ${RES_IN_FIXSAR_FILENAMES}"
    else
      RES_IN_FIXSAR_FILENAMES="${res_in_orog_fns}"
    fi

  fi
#
#-----------------------------------------------------------------------
#
# If the surface climatology file generation task in the workflow is
# going to be skipped (because pregenerated files are available), create
# links in the FIXsar directory to the pregenerated surface climatology
# files.
#
#-----------------------------------------------------------------------
#
  res_in_sfc_climo_fns=""
  if [ "${RUN_TASK_MAKE_SFC_CLIMO}" = "FALSE" ]; then

    link_fix \
      verbose="$VERBOSE" \
      file_group="sfc_climo" \
      output_varname_res_in_filenames="res_in_sfc_climo_fns" || \
    print_err_msg_exit "\
  Call to function to create links to surface climatology files failed."

    if [ ! -z "${RES_IN_FIXSAR_FILENAMES}" ] && \
       [ "${res_in_sfc_climo_fns}" -ne "${RES_IN_FIXSAR_FILENAMES}" ]; then
      print_err_msg_exit "\
  The resolution extracted from the surface climatology file names (res_-
  in_sfc_climo_fns) does not match the resolution in other groups of files
  already considered (RES_IN_FIXSAR_FILENAMES):
    res_in_sfc_climo_fns = ${res_in_sfc_climo_fns}
    RES_IN_FIXSAR_FILENAMES = ${RES_IN_FIXSAR_FILENAMES}"
    else
      RES_IN_FIXSAR_FILENAMES="${res_in_sfc_climo_fns}"
    fi

  fi

fi
#
#-----------------------------------------------------------------------
#
# The variable CRES is needed in constructing various file names.  If 
# not running the make_grid task, we can set it here.  Otherwise, it 
# will get set to a valid value by that task.
#
#-----------------------------------------------------------------------
#
CRES=""
if [ "${RUN_TASK_MAKE_GRID}" = "FALSE" ]; then
  CRES="C${RES_IN_FIXSAR_FILENAMES}"
fi





#
#-----------------------------------------------------------------------
#
# Make sure that QUILTING is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "QUILTING" "valid_vals_QUILTING"
#
# Set QUILTING to either "TRUE" or "FALSE" so we don't have to consider
# other valid values later on.
#
QUILTING=${QUILTING^^}
if [ "$QUILTING" = "TRUE" ] || \
   [ "$QUILTING" = "YES" ]; then
  QUILTING="TRUE"
elif [ "$QUILTING" = "FALSE" ] || \
     [ "$QUILTING" = "NO" ]; then
  QUILTING="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Make sure that PRINT_ESMF is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "PRINT_ESMF" "valid_vals_PRINT_ESMF"
#
# Set PRINT_ESMF to either "TRUE" or "FALSE" so we don't have to consider
# other valid values later on.
#
PRINT_ESMF=${PRINT_ESMF^^}
if [ "${PRINT_ESMF}" = "TRUE" ] || \
   [ "${PRINT_ESMF}" = "YES" ]; then
  PRINT_ESMF="TRUE"
elif [ "${PRINT_ESMF}" = "FALSE" ] || \
     [ "${PRINT_ESMF}" = "NO" ]; then
  PRINT_ESMF="FALSE"
fi
#
#-----------------------------------------------------------------------
#
# Calculate PE_MEMBER01.  This is the number of MPI tasks used for the
# forecast, including those for the write component if QUILTING is set
# to "TRUE".
#
#-----------------------------------------------------------------------
#

# reload layout settings from user config file to override defaults
for var in LAYOUT_X LAYOUT_Y WRTCMP_write_groups WRTCMP_write_tasks_per_group ; do
  line=$( grep "^ *${var}=" "${EXPT_CONFIG_FN}" 2>/dev/null )
  [ ! -z "$line" ] && eval "$line"
done

PE_MEMBER01=$(( LAYOUT_X*LAYOUT_Y ))
if [ "$QUILTING" = "TRUE" ]; then
  PE_MEMBER01=$(( ${PE_MEMBER01} + ${WRTCMP_write_groups}*${WRTCMP_write_tasks_per_group} ))
fi

print_info_msg "$VERBOSE" "
The number of MPI tasks for the forecast (including those for the write
component if it is being used) are:
  PE_MEMBER01 = ${PE_MEMBER01}"
#
#-----------------------------------------------------------------------
#
# Make sure that the number of cells in the x and y direction are divi-
# sible by the MPI task dimensions LAYOUT_X and LAYOUT_Y, respectively.
#
#-----------------------------------------------------------------------
#
rem=$(( NX%LAYOUT_X ))
if [ $rem -ne 0 ]; then
  print_err_msg_exit "\
The number of grid cells in the x direction (NX) is not evenly divisible
by the number of MPI tasks in the x direction (LAYOUT_X):
  NX = $NX
  LAYOUT_X = ${LAYOUT_X}"
fi

rem=$(( NY%LAYOUT_Y ))
if [ $rem -ne 0 ]; then
  print_err_msg_exit "\
The number of grid cells in the y direction (NY) is not evenly divisible
by the number of MPI tasks in the y direction (LAYOUT_Y):
  NY = $NY
  LAYOUT_Y = ${LAYOUT_Y}"
fi

print_info_msg "$VERBOSE" "
The MPI task layout is:
  LAYOUT_X = ${LAYOUT_X}
  LAYOUT_Y = ${LAYOUT_Y}"
#
#-----------------------------------------------------------------------
#
# Make sure that, for a given MPI task, the number columns (which is 
# equal to the number of horizontal cells) is divisible by BLOCKSIZE.
#
#-----------------------------------------------------------------------
#
nx_per_task=$(( NX/LAYOUT_X ))
ny_per_task=$(( NY/LAYOUT_Y ))
num_cols_per_task=$(( $nx_per_task*$ny_per_task ))

rem=$(( num_cols_per_task%BLOCKSIZE ))
if [ $rem -ne 0 ]; then
  prime_factors_num_cols_per_task=$( factor $num_cols_per_task | sed -r -e 's/^[0-9]+: (.*)/\1/' )
  print_err_msg_exit "\
The number of columns assigned to a given MPI task must be divisible by
BLOCKSIZE:
  nx_per_task = NX/LAYOUT_X = $NX/${LAYOUT_X} = ${nx_per_task}
  ny_per_task = NY/LAYOUT_Y = $NY/${LAYOUT_Y} = ${ny_per_task}
  num_cols_per_task = nx_per_task*ny_per_task = ${num_cols_per_task}
  BLOCKSIZE = $BLOCKSIZE
  rem = num_cols_per_task%%BLOCKSIZE = $rem
The prime factors of num_cols_per_task are (useful for determining a va-
lid BLOCKSIZE): 
  prime_factors_num_cols_per_task: ${prime_factors_num_cols_per_task}"
fi
#
#-----------------------------------------------------------------------
#
# Initialize the full path to the template file containing placeholder 
# values for the write component parameters.  Then, if the write component
# is going to be used to write output files to disk (i.e. if QUILTING is
# set to "TRUE"), set the full path to this file.  This file will be 
# appended to the NEMS configuration file (MODEL_CONFIG_FN), and placeholder
# values will be replaced with actual ones.  
#
#-----------------------------------------------------------------------
#
WRTCMP_PARAMS_TMPL_FP=""

if [ "$QUILTING" = "TRUE" ]; then
#
# First, make sure that WRTCMP_output_grid is set to a valid value.
#
  err_msg="\
The coordinate system used by the write-component output grid specified
in WRTCMP_output_grid is not supported:
  WRTCMP_output_grid = \"${WRTCMP_output_grid}\""
  check_var_valid_value \
    "WRTCMP_output_grid" "valid_vals_WRTCMP_output_grid" "${err_msg}"
#
# Now set the name of the write-component template file.
#
  wrtcmp_params_tmpl_fn=${wrtcmp_params_tmpl_fn:-"wrtcmp_${WRTCMP_output_grid}"}
#
# Finally, set the full path to the write component template file and
# make sure that the file exists.
#
  WRTCMP_PARAMS_TMPL_FP="${TEMPLATE_DIR}/${wrtcmp_params_tmpl_fn}"
  if [ ! -f "${WRTCMP_PARAMS_TMPL_FP}" ]; then
    print_err_msg_exit "\
The write-component template file does not exist or is not a file:
  WRTCMP_PARAMS_TMPL_FP = \"${WRTCMP_PARAMS_TMPL_FP}\""
  fi

fi
#
#-----------------------------------------------------------------------
#
# If the write component is going to be used, make sure that the number
# of grid cells in the y direction (NY) is divisible by the number of
# write tasks per group.  This is because the NY rows of the grid must
# be distributed evenly among the write_tasks_per_group tasks in a given
# write group, i.e. each task must receive the same number of rows.  
# This implies that NY must be evenly divisible by WRTCMP_write_tasks_-
# per_group.  If it isn't, the write component will hang or fail.  We
# check for this below.
#
#-----------------------------------------------------------------------
#
if [ "$QUILTING" = "TRUE" ]; then

  rem=$(( NY%WRTCMP_write_tasks_per_group ))

  if [ $rem -ne 0 ]; then
    print_err_msg_exit "\
The number of grid points in the y direction on the regional grid (ny_-
T7) must be evenly divisible by the number of tasks per write group 
(WRTCMP_write_tasks_per_group):
  NY = $NY
  WRTCMP_write_tasks_per_group = $WRTCMP_write_tasks_per_group
  NY%%write_tasks_per_group = $rem"
  fi

fi
#
#-----------------------------------------------------------------------
#
# Calculate the number of nodes (NUM_NODES) to request from the job
# scheduler.  This is just PE_MEMBER01 dividied by the number of cores
# per node (NCORES_PER_NODE) rounded up to the nearest integer, i.e.
#
#   NUM_NODES = ceil(PE_MEMBER01/NCORES_PER_NODE)
#
# where ceil(...) is the ceiling function, i.e. it rounds its floating
# point argument up to the next larger integer.  Since in bash division
# of two integers returns a truncated integer and since bash has no
# built-in ceil(...) function, we perform the rounding-up operation by
# adding the denominator (of the argument of ceil(...) above) minus 1 to
# the original numerator, i.e. by redefining NUM_NODES to be
#
#   NUM_NODES = (PE_MEMBER01 + NCORES_PER_NODE - 1)/NCORES_PER_NODE
#
#-----------------------------------------------------------------------
#
NUM_NODES=$(( (PE_MEMBER01 + NCORES_PER_NODE - 1)/NCORES_PER_NODE ))
#
#-----------------------------------------------------------------------
#
# Make sure that OZONE_PARAM_NO_CCPP is set to a valid value.
#
#-----------------------------------------------------------------------
#
check_var_valid_value "OZONE_PARAM_NO_CCPP" "valid_vals_OZONE_PARAM_NO_CCPP"
#
#-----------------------------------------------------------------------
#
# Call the function that sets the ozone parameterization being used, the
# number of global fixed files in the FIXgsm and/or FIXam directories 
# (each should have the same number), and the arrays containing the names
# of these files. 
#
#-----------------------------------------------------------------------
#
set_fix_filenames \
  ccpp_phys_suite_fp="${CCPP_PHYS_SUITE_IN_CCPP_FP}" \
  ozone_param_no_ccpp="${OZONE_PARAM_NO_CCPP}" \
  output_varname_ozone_param="OZONE_PARAM" \
  output_varname_num_fixam_files="NUM_FIXam_FILES" \
  output_varname_fixgsm_fns="FIXgsm_FILENAMES" \
  output_varname_fixam_fns="FIXam_FILENAMES"
#
#-----------------------------------------------------------------------
#
# Create a new experiment directory.  Note that at this point we are 
# guaranteed that there is no preexisting experiment directory.
#
#-----------------------------------------------------------------------
#
mkdir_vrfy -p "$EXPTDIR"
#
#-----------------------------------------------------------------------
#
# Generate the shell script that will appear in the experiment directory 
# (EXPTDIR) and will contain definitions of variables needed by the va-
# rious scripts in the workflow.  We refer to this as the experiment/
# workflow global variable definitions file.  We will create this file 
# by:
#
# 1) Copying the default workflow/experiment configuration file (speci-
#    fied by DEFAULT_EXPT_CONFIG_FN and located in the shell script di-
#    rectory specified by USHDIR) to the experiment directory and rena-
#    ming it to the name specified by GLOBAL_VAR_DEFNS_FN.
#
# 2) Resetting the default variable values in this file to their current
#    values.  This is necessary because these variables may have been 
#    reset by the user-specified configuration file (if one exists in 
#    USHDIR) and/or by this setup script, e.g. because predef_domain is
#    set to a valid non-empty value.
#
# 3) Appending to the variable definitions file any new variables intro-
#    duced in this setup script that may be needed by the scripts that
#    perform the various tasks in the workflow (and which source the va-
#    riable defintions file).
#
# First, set the full path to the variable definitions file and copy the
# default configuration script into it.
#
#-----------------------------------------------------------------------
#
GLOBAL_VAR_DEFNS_FP="$EXPTDIR/$GLOBAL_VAR_DEFNS_FN"
cp_vrfy $USHDIR/${DEFAULT_EXPT_CONFIG_FN} ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
#
#
#-----------------------------------------------------------------------
#

# Read all lines of GLOBAL_VAR_DEFNS file into the variable line_list.
line_list=$( sed -r -e "s/(.*)/\1/g" ${GLOBAL_VAR_DEFNS_FP} )
#
# Loop through the lines in line_list and concatenate lines ending with
# the line bash continuation character "\".
#
rm_vrfy ${GLOBAL_VAR_DEFNS_FP}
while read crnt_line; do
  printf "%s\n" "${crnt_line}" >> ${GLOBAL_VAR_DEFNS_FP}
done <<< "${line_list}"
#
#-----------------------------------------------------------------------
#
# The following comment block needs to be updated because now line_list
# may contain lines that are not assignment statements (e.g. it may con-
# tain if-statements).  Such lines are ignored in the while-loop below.
#
# Reset each of the variables in the variable definitions file to its 
# value in the current environment.  To accomplish this, we:
#
# 1) Create a list of variable settings by stripping out comments, blank
#    lines, extraneous leading whitespace, etc from the variable defini-
#    tions file (which is currently identical to the default workflow/
#    experiment configuration script) and saving the result in the vari-
#    able line_list.  Each line of line_list will have the form
#
#      VAR=...
#
#    where the VAR is a variable name and ... is the value from the de-
#    fault configuration script (which does not necessarily correspond
#    to the current value of the variable).
#
# 2) Loop through each line of line_list.  For each line, we extract the
#    variable name (and save it in the variable var_name), get its value
#    from the current environment (using bash indirection, i.e. 
#    ${!var_name}), and use the set_file_param() function to replace the
#    value of the variable in the variable definitions script (denoted 
#    above by ...) with its current value. 
#
#-----------------------------------------------------------------------
#
# Also should remove trailing whitespace...
line_list=$( sed -r \
             -e "s/^([ ]*)([^ ]+.*)/\2/g" \
             -e "/^#.*/d" \
             -e "/^$/d" \
             ${GLOBAL_VAR_DEFNS_FP} )

print_info_msg "$VERBOSE" "
The variable \"line_list\" contains:

${line_list}
"
#
#-----------------------------------------------------------------------
#
# Add a comment at the beginning of the variable definitions file that
# indicates that the first section of that file is (mostly) the same as
# the configuration file.
#
#-----------------------------------------------------------------------
#
read -r -d '' str_to_insert << EOM
#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# Section 1:
# This section is a copy of the default workflow/experiment configura-
# tion file config_defaults.sh in the shell scripts directory USHDIR ex-
# cept that variable values have been updated to those set by the setup
# script (setup.sh).
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#
EOM
#
# Replace all occurrences of actual newlines in the variable str_to_in-
# sert with escaped backslash-n.  This is needed for the sed command be-
# low to work properly (i.e. to avoid it failing with an "unterminated
# `s' command" message).
#
str_to_insert=${str_to_insert//$'\n'/\\n}
#
# Insert str_to_insert into GLOBAL_VAR_DEFNS_FP right after the line
# containing the name of the interpreter.
#
REGEXP="(^#!.*)"
sed -i -r -e "s|$REGEXP|\1\n\n$str_to_insert\n|g" ${GLOBAL_VAR_DEFNS_FP}






#
# Loop through the lines in line_list.
#
while read crnt_line; do
#
# Try to obtain the name of the variable being set on the current line.
# This will be successful only if the line consists of one or more char-
# acters representing the name of a variable (recall that in generating
# the variable line_list, all leading spaces in the lines in the file 
# have been stripped out), followed by an equal sign, followed by zero
# or more characters representing the value that the variable is being
# set to.
#
  var_name=$( printf "%s" "${crnt_line}" | sed -n -r -e "s/^([^ ]*)=.*/\1/p" )
#echo
#echo "============================"
#printf "%s\n" "var_name = \"${var_name}\""
#
# If var_name is not empty, then a variable name was found in the cur-
# rent line in line_list.
#
  if [ ! -z $var_name ]; then

    print_info_msg "$VERBOSE" "
var_name = \"${var_name}\""
#
# If the variable specified in var_name is set in the current environ-
# ment (to either an empty or non-empty string), get its value and in-
# sert it in the variable definitions file on the line where that varia-
# ble is defined.  Note that 
#
#   ${!var_name+x}
#
# will retrun the string "x" if the variable specified in var_name is 
# set (to either an empty or non-empty string), and it will return an
# empty string if the variable specified in var_name is unset (i.e. un-
# defined).
#
    if [ ! -z ${!var_name+x} ]; then
#
# The variable may be a scalar or an array.  Thus, we first treat it as
# an array and obtain the number of elements that it contains.
#
      array_name_at="${var_name}[@]"
      array=("${!array_name_at}")
      num_elems="${#array[@]}"
#
# We will now set the variable var_value to the string that needs to be
# placed on the right-hand side of the assignment operator (=) on the 
# appropriate line in variable definitions file.  How this is done de-
# pends on whether the variable is a scalar or an array.
#
# If the variable contains only one element, then it is a scalar.  (It
# could be a 1-element array, but it is simpler to treat it as a sca-
# lar.)  In this case, we enclose its value in double quotes and save
# the result in var_value.
#
      if [ "$num_elems" -eq 1 ]; then
        var_value="${!var_name}"
        var_value="\"${var_value}\""
#
# If the variable contains more than one element, then it is an array.
# In this case, we build var_value in two steps as follows:
#
# 1) Generate a string containing each element of the array in double
#    quotes and followed by a space.
#
# 2) Place parentheses around the double-quoted list of array elements
#    generated in the first step.  Note that there is no need to put a
#    space before the closing parenthesis because in step 1, we have al-
#    ready placed a space after the last element.
#
      else

        arrays_on_one_line="TRUE"
        arrays_on_one_line="FALSE"

        if [ "${arrays_on_one_line}" = "TRUE" ]; then
          var_value=$(printf "\"%s\" " "${!array_name_at}")
#          var_value=$(printf "\"%s\" \\\\\\ \\\n" "${!array_name_at}")
        else
#          var_value=$(printf "%s" "\\\\\\n")
          var_value="\\\\\n"
          for (( i=0; i<${num_elems}; i++)); do
#            var_value=$(printf "%s\"%s\" %s" "${var_value}" "${array[$i]}" "\\\\\\n")
            var_value="${var_value}\"${array[$i]}\" \\\\\n"
#            var_value="${var_value}\"${array[$i]}\" "
          done
        fi
        var_value="( $var_value)"

      fi
#
# If the variable specified in var_name is not set in the current envi-
# ronment (to either an empty or non-empty string), get its value and 
# insert it in the variable definitions file on the line where that va-
# riable is defined.
#
    else

      print_info_msg "
The variable specified by \"var_name\" is not set in the current envi-
ronment:
  var_name = \"${var_name}\"
Setting its value in the variable definitions file to an empty string."

      var_value="\"\""

    fi
#
# Now place var_value on the right-hand side of the assignment statement
# on the appropriate line in variable definitions file.
#
    set_file_param "${GLOBAL_VAR_DEFNS_FP}" "${var_name}" "${var_value}"
#
# If var_name is empty, then a variable name was not found in the cur-
# rent line in line_list.  In this case, print out a warning and move on
# to the next line.
#
  else

    print_info_msg "
Could not extract a variable name from the current line in \"line_list\"
(probably because it does not contain an equal sign with no spaces on 
either side):
  crnt_line = \"${crnt_line}\"
  var_name = \"${var_name}\"
Continuing to next line in \"line_list\"."

  fi

done <<< "${line_list}"
#
#-----------------------------------------------------------------------
#
# Append additional variable definitions (and comments) to the variable
# definitions file.  These variables have been set above using the vari-
# ables in the default and local configuration scripts.  These variables
# are needed by various tasks/scripts in the workflow.
#
#-----------------------------------------------------------------------
#
{ cat << EOM >> ${GLOBAL_VAR_DEFNS_FP}

#
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
# Section 2:
# This section defines variables that have been derived from the ones
# above by the setup script (setup.sh) and which are needed by one or
# more of the scripts that perform the workflow tasks (those scripts
# source this variable definitions file).
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------
#

#
#-----------------------------------------------------------------------
#
# Workflow launcher script and cron table line.
#
#-----------------------------------------------------------------------
#
WFLOW_LAUNCH_SCRIPT_FP="${WFLOW_LAUNCH_SCRIPT_FP}"
WFLOW_LAUNCH_LOG_FP="${WFLOW_LAUNCH_LOG_FP}"
CRONTAB_LINE="${CRONTAB_LINE}"
#
#-----------------------------------------------------------------------
#
# Directories.
#
#-----------------------------------------------------------------------
#
HOMErrfs="$HOMErrfs"
CONFDIR="$CONFDIR"
USHDIR="$USHDIR"
SCRIPTSDIR="$SCRIPTSDIR"
JOBSDIR="$JOBSDIR"
SORCDIR="$SORCDIR"
PARMDIR="$PARMDIR"
MODULES_DIR="${MODULES_DIR}"
EXECDIR="$EXECDIR"
FIXrrfs="$FIXrrfs"
FIXam="$FIXam"
FIXsar="$FIXsar"
FIXgsm="$FIXgsm"
FIXupp="$FIXupp"
FIXgsd="$FIXgsd"
COMROOT="$COMROOT"
TEMPLATE_DIR="${TEMPLATE_DIR}"
UFS_WTHR_MDL_DIR="${UFS_WTHR_MDL_DIR}"
UFS_UTILS_DIR="${UFS_UTILS_DIR}"
CHGRES_DIR="${CHGRES_DIR}"
SFC_CLIMO_INPUT_DIR="${SFC_CLIMO_INPUT_DIR}"
JEDI_DIR="$JEDI_DIR"

EXPTDIR="$EXPTDIR"
LOGDIR="$LOGDIR"
GRID_DIR="${GRID_DIR}"
OROG_DIR="${OROG_DIR}"
SFC_CLIMO_DIR="${SFC_CLIMO_DIR}"
#
#-----------------------------------------------------------------------
#
# Files.
#
#-----------------------------------------------------------------------
#
GLOBAL_VAR_DEFNS_FP="${GLOBAL_VAR_DEFNS_FP}"

DATA_TABLE_TMPL_FN="${DATA_TABLE_TMPL_FN}"
DIAG_TABLE_TMPL_FN="${DIAG_TABLE_TMPL_FN}"
FIELD_TABLE_TMPL_FN="${FIELD_TABLE_TMPL_FN}"
MODEL_CONFIG_TMPL_FN="${MODEL_CONFIG_TMPL_FN}"
NEMS_CONFIG_TMPL_FN="${NEMS_CONFIG_TMPL_FN}"

DATA_TABLE_TMPL_FP="${DATA_TABLE_TMPL_FP}"
DIAG_TABLE_TMPL_FP="${DIAG_TABLE_TMPL_FP}"
FIELD_TABLE_TMPL_FP="${FIELD_TABLE_TMPL_FP}"
FV3_NML_BASE_FP="${FV3_NML_BASE_FP}"
FV3_NML_CONFIG_FP="${FV3_NML_CONFIG_FP}"
MODEL_CONFIG_TMPL_FP="${MODEL_CONFIG_TMPL_FP}"
NEMS_CONFIG_TMPL_FP="${NEMS_CONFIG_TMPL_FP}"

CCPP_PHYS_SUITE_FN="${CCPP_PHYS_SUITE_FN}"
CCPP_PHYS_SUITE_IN_CCPP_FP="${CCPP_PHYS_SUITE_IN_CCPP_FP}"
CCPP_PHYS_SUITE_FP="${CCPP_PHYS_SUITE_FP}"

DATA_TABLE_FP="${DATA_TABLE_FP}"
FIELD_TABLE_FP="${FIELD_TABLE_FP}"
FV3_NML_FP="${FV3_NML_FP}"
NEMS_CONFIG_FP="${NEMS_CONFIG_FP}"

WRTCMP_PARAMS_TMPL_FP="${WRTCMP_PARAMS_TMPL_FP}"
#
#-----------------------------------------------------------------------
#
# Names of the tasks in the rocoto workflow XML.
#
#-----------------------------------------------------------------------
#
MAKE_GRID_TN="${MAKE_GRID_TN}"
MAKE_OROG_TN="${MAKE_OROG_TN}"
MAKE_SFC_CLIMO_TN="${MAKE_SFC_CLIMO_TN}"
ADD_AQM_ICS_TN="${ADD_AQM_ICS_TN}"
ADD_AQM_LBCS_TN="${ADD_AQM_LBCS_TN}"
GET_EXTRN_ICS_TN="${GET_EXTRN_ICS_TN}"
GET_EXTRN_LBCS_TN="${GET_EXTRN_LBCS_TN}"
MAKE_ICS_TN="${MAKE_ICS_TN}"
MAKE_LBCS_TN="${MAKE_LBCS_TN}"
RUN_NEXUS_TN="${RUN_NEXUS_TN}"
RUN_FCST_TN="${RUN_FCST_TN}"
RUN_POST_TN="${RUN_POST_TN}"
#
#-----------------------------------------------------------------------
#
# Grid configuration parameters needed regardless of grid generation me-
# thod used.
#
#-----------------------------------------------------------------------
#
GTYPE="$GTYPE"
TILE_RGNL="${TILE_RGNL}"
NH0="${NH0}"
NH3="${NH3}"
NH4="${NH4}"

LON_CTR="${LON_CTR}"
LAT_CTR="${LAT_CTR}"
NX="${NX}"
NY="${NY}"
NHW="${NHW}"
STRETCH_FAC="${STRETCH_FAC}"

RES_IN_FIXSAR_FILENAMES="${RES_IN_FIXSAR_FILENAMES}"
#
# If running the make_grid task, CRES will be set to a null string du-
# the grid generation step.  It will later be set to an actual value af-
# ter the make_grid task is complete.
#
CRES="$CRES"
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to append new variable definitions to variable 
definitions file returned with a nonzero status."
#
#-----------------------------------------------------------------------
#
# Append to the variable definitions file the defintions of grid parame-
# ters that are specific to the grid generation method used.
#
#-----------------------------------------------------------------------
#
if [ "${GRID_GEN_METHOD}" = "GFDLgrid" ]; then

  { cat << EOM >> ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Grid configuration parameters for a regional grid generated from a
# global parent cubed-sphere grid.  This is the method originally sug-
# gested by GFDL since it allows GFDL's nested grid generator to be used
# to generate a regional grid.  However, for large regional domains, it
# results in grids that have an unacceptably large range of cell sizes
# (i.e. ratio of maximum to minimum cell size is not sufficiently close
# to 1).
#
#-----------------------------------------------------------------------
#
ISTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="${ISTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG}"
IEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="${IEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG}"
JSTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="${JSTART_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG}"
JEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG="${JEND_OF_RGNL_DOM_WITH_WIDE_HALO_ON_T6SG}"
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to append grid parameters to variable definitions
file returned with a nonzero status."

elif [ "${GRID_GEN_METHOD}" = "JPgrid" ]; then

  { cat << EOM >> ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Grid configuration parameters for a regional grid generated indepen-
# dently of a global parent grid.  This method was developed by Jim Pur-
# ser of EMC and results in very uniform grids (i.e. ratio of maximum to
# minimum cell size is very close to 1).
#
#-----------------------------------------------------------------------
#
DEL_ANGLE_X_SG="${DEL_ANGLE_X_SG}"
DEL_ANGLE_Y_SG="${DEL_ANGLE_Y_SG}"
NEG_NX_OF_DOM_WITH_WIDE_HALO="${NEG_NX_OF_DOM_WITH_WIDE_HALO}"
NEG_NY_OF_DOM_WITH_WIDE_HALO="${NEG_NY_OF_DOM_WITH_WIDE_HALO}"
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to append grid parameters to variable definitions
file returned with a nonzero status."

fi
#
#-----------------------------------------------------------------------
#
# Continue appending variable defintions to the variable definitions 
# file.
#
#-----------------------------------------------------------------------
#
FIXgsm_FILENAMES_str=$( printf "\"%s\" \\\\\n" "${FIXgsm_FILENAMES[@]}" )
FIXam_FILENAMES_str=$( printf "\"%s\" \\\\\n" "${FIXam_FILENAMES[@]}" )

{ cat << EOM >> ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Name of the ozone parameterization.  If USE_CCPP is set to "FALSE", 
# then this will be equal to OZONE_PARAM_NO_CCPP.  If USE_CCPP is set to
# "TRUE", then the value this gets set to depends on the CCPP physics
# suite being used.
#
#-----------------------------------------------------------------------
#
OZONE_PARAM="${OZONE_PARAM}"
#
#-----------------------------------------------------------------------
#
# Number of files expected in the FIXam directory.
#
#-----------------------------------------------------------------------
#
NUM_FIXam_FILES="${NUM_FIXam_FILES}"
#
#-----------------------------------------------------------------------
#
# The names of the files in the FIXgsm system directory and the FIXam
# directory (located in the experiment directory).
#
#-----------------------------------------------------------------------
#
FIXgsm_FILENAMES=( \\
${FIXgsm_FILENAMES_str}
)

FIXam_FILENAMES=( \\
${FIXam_FILENAMES_str}
)
#
#-----------------------------------------------------------------------
#
# System directory in which to look for the files generated by the ex-
# ternal model specified in EXTRN_MDL_NAME_ICS.  These files will be
# used to generate the input initial condition and surface files for the
# FV3SAR.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_FILES_SYSBASEDIR_ICS="${EXTRN_MDL_FILES_SYSBASEDIR_ICS}"
#
#-----------------------------------------------------------------------
#
# System directory in which to look for the files generated by the ex-
# ternal model specified in EXTRN_MDL_NAME_LBCS.  These files will be 
# used to generate the input lateral boundary condition files for the 
# FV3SAR.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_FILES_SYSBASEDIR_LBCS="${EXTRN_MDL_FILES_SYSBASEDIR_LBCS}"
#
#-----------------------------------------------------------------------
#
# Shift back in time (in units of hours) of the starting time of the ex-
# ternal model specified in EXTRN_MDL_NAME_LBCS.
#
#-----------------------------------------------------------------------
#
EXTRN_MDL_LBCS_OFFSET_HRS="${EXTRN_MDL_LBCS_OFFSET_HRS}"
#
#-----------------------------------------------------------------------
#
# Boundary condition update times (in units of forecast hours).  Note that
# LBC_UPDATE_FCST_HRS is an array, even if it has only one element.
#
#-----------------------------------------------------------------------
#
LBC_UPDATE_FCST_HRS=(${LBC_UPDATE_FCST_HRS[@]})
#
#-----------------------------------------------------------------------
#
# Computational parameters.
#
#-----------------------------------------------------------------------
#
NCORES_PER_NODE="${NCORES_PER_NODE}"
PE_MEMBER01="${PE_MEMBER01}"
EOM
} || print_err_msg_exit "\
Heredoc (cat) command to append new variable definitions to variable 
definitions file returned with a nonzero status."
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Setup script completed successfully!!!
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the start of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

}
#
#-----------------------------------------------------------------------
#
# Call the function defined above.
#
#-----------------------------------------------------------------------
#
setup

