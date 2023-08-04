#!/bin/sh
#
# praevisio.sh
#
DDC="$1"
DMMrot="$PWD"
Simulator="composition.sh"
installer_name="praevisio.sh"
distro_name="composition.ahr"
# generate date format with AHR microseconds style
generate_date() {
    date +"%Y%m%d%H%M%S.%6N"
}

# installer-Log file path in the current directory
LOG_FILE="${DMMrot}/AHR$(generate_date).ahr"

# Function to log messages to the log file
log() {
    printf "%b \n" "$(generate_date) - $1" >> "$LOG_FILE"
    # if we declare a global var here we save many lines of code
    if [ "$p2V" = "verbose" ]; then
	printf "%b \n" "$1"
    fi
}

app_NewFiles() {
   local iFrm="$1"
   local iEm="$2"
   local xf=""
   local Fnme=""
   local Ftyp=""
   local Fpth=""
   local dFtp=""
   DMMwrk=$(echo "$iFrm" | cut -d'|' -f1)
   DMMtmp=$(echo "$iFrm" | cut -d'|' -f2)
   DMMbak=$(echo "$iFrm" | cut -d'|' -f3)

   # Retrieve the distribution list
   lst=$(cat 'composition.ahr')

   ck_distribution "$lst"
   create_structure "$iFrm" "$iEm"
   log "PASS: Structure Created"
   Config_Writer "$iFrm" "$iEm"
   log "Emancipation Started: $iEm"
   ahr_service

   lst=$(cat 'composition.ahr')
   # create distro backup folders
   create_DDir "$DMMbak"
   # backup Distro
   bk_distro "$lst" "$DMMbak"
   # engage new dev pertinent to emancipation
   for xf in $(echo "$lst"); do
	Fnme=$(echo "$xf" | cut -d'|' -f1)
	Fnme=$(echo "$Fnme" | cut -d'_' -f2)
	Ftyp=$(echo "$xf" | cut -d'|' -f2)
	Fdis=$(echo "$xf" | cut -d'|' -f3)
    # hardcoded destination
	if [ "$Ftyp" = "new" ]; then
	   # Subroutines
	   if [ "$Fdis" = "app" ]; then
		cp "$DMMbak/$Ftyp/$Fnme" "$DMMwrk/$Fnme"
		dFtp=$(echo "$Fnme" | cut -d'.' -f2)
		if [ "$dFtp" = "sh" ]; then
		   chmod +x "$DMMwrk/$Fnme"
		fi
		log "PASS: S($DMMbak/$Ftyp/$Fnme) $DMMwrk/$Fnme"

	   fi
	   # Main Routines
	   if [ "$Fdis" = "rot" ]; then
		cp "$DMMbak/$Ftyp/$Fnme" "$DMMrot/$Fnme"
		dFtp=$(echo "$Fnme" | cut -d'.' -f2)
		if [ "$dFtp" = "sh" ]; then
		   chmod +x "$DMMrot/$Fnme"
		fi
		log "PASS: M($DMMbak/$Ftyp/$Fnme) $DMMrot/$Fnme"
           fi
	fi
   done
   cre_newSIM > "aDStart.sh"
}

app_OldFiles() {
   local iFrm="$1"
   local iEm="$2"
   local xf=""
   local Fnme=""
   local Ftyp=""
   local Fpth=""
   local dFtp=""
   DMMwrk=$(echo "$iFrm" | cut -d'|' -f1)
   DMMtmp=$(echo "$iFrm" | cut -d'|' -f2)
   DMMbak=$(echo "$iFrm" | cut -d'|' -f3)

   # Retrieve the distribution list
   lst=$(cat 'composition.ahr')

   ck_distribution "$lst"
   create_structure "$iFrm" "$iEm"
   log "PASS: Structure Created"
   Config_Writer "$iFrm" "$iEm"
   log "Default Started: $iEm"

   lst=$(cat 'composition.ahr')
   # create distro backup folders
   create_DDir "$DMMbak"
   # backup Distro
   bk_distro "$lst" "$DMMbak"
   # engage new dev pertinent to emancipation
   for xf in $(echo "$lst"); do
        Fnme=$(echo "$xf" | cut -d'|' -f1)
        Fnme=$(echo "$Fnme" | cut -d'_' -f2)
        Ftyp=$(echo "$xf" | cut -d'|' -f2)
        Fdis=$(echo "$xf" | cut -d'|' -f3)
           # hardcoded destination
        if [ "$Ftyp" = "old" ]; then
           # Subroutines
           if [ "$Fdis" = "app" ]; then
                cp "$DMMbak/$Ftyp/$Fnme" "$DMMwrk/$Fnme"
                dFtp=$(echo "$Fnme" | cut -d'.' -f2)
                if [ "$dFtp" = "sh" ]; then
                   chmod +x "$DMMwrk/$Fnme"
                fi
                log "PASS: S($DMMbak/$Ftyp/$Fnme) $DMMwrk/$Fnme"

           fi
           # Main Routines
           if [ "$Fdis" = "rot" ]; then
                cp "$DMMbak/$Ftyp/$Fnme" "$DMMrot/$Fnme"
                dFtp=$(echo "$Fnme" | cut -d'.' -f2)
                if [ "$dFtp" = "sh" ]; then
                   chmod +x "$DMMrot/$Fnme"
                fi
                log "PASS: M($DMMbak/$Ftyp/$Fnme) $DMMrot/$Fnme"
           fi
        fi
   done
   cre_oldSIM > "aDStart.sh"
}

ending_statement() {
   local NdxFle="$1"
   local instTp="$2"
   local varNdx=""
   local tCnt=1
   local NdxLne=""

   local fBak=$(echo "$NdxFle" | sed -e "s:.ahr:.bak:")
   varNdx=$(cat "$NdxFle")

   > "$fBak"

   for NdxLne in $(echo "$varNdx"); do
	# remove index
	NdxLne=$(echo "$NdxLne" | cut -d'|' -f2,3,4,5)
        echo "${NdxLne}" >> "$fBak"
   done

   # push end statement to config-bak
   local hdr=""
   local rcd=""
   local dDate=$(generate_date)
   hdr="dst=DMMdst,DMMfix,DMMcnt"
   # hardcoded shortcut
   log "Create Distribution Group"
   rcd="DMMdst=$instTp|Distribution.+.Type|$dDate"
   echo "$hdr|$rcd" >> "$fBak"
   log "PASS: Distro  Record Type"
   rcd="DMMfix=nw,ol|Distribution.+.Prefix|$dDate"
   echo "$hdr|$rcd" >> "$fBak"
   log "PASS: Distro Array nw,ol"
   rcd="DMMcnt=001|Distribution.+.Version|$dDate"
   echo "$hdr|$rcd" >> "$fBak"
   log "PASS: Distro Version Counter"

   # reindex and deliver
   mv "$fBak" "$NdxFle"
   log "Create Distribution Group - Completed"
   > "$fBak"
   tCnt=1
   NdxLne=""
   varNdx=$(cat "$NdxFle")
   for NdxLne in $(echo "$varNdx"); do
	echo "${tCnt}|${NdxLne}" >> "$fBak"
   tCnt=$(($tCnt + 1));
   done

   mv "$fBak" "$NdxFle"

   # Backup Distribution Reference
   mv "$Simulator" "${DMMbak}/${dDate}.$Simulator"
   mv "$distro_name" "${DMMbak}/${dDate}.$distro_name"
   mv "$installer_name" "${DMMbak}/${dDate}.$installer_name"
   log "Success, Project Setup Completed!"
   if [ "$DDC" = "DDC" ]; then
	end_Stmt=$(cat "$LOG_FILE")
	echo "$end_Stmt" > "${DMMbak}/${dDate}.AHR.log"
   fi
   echo ""
   echo "Kick-start your Project by executing: sh aDStart.sh"
   echo ""
}

# move files from current dir to backup
bk_distro() {
   local lst="$1"
   local bkD="$2"
   local xf=""
   local DTyp=""

   # REM: type is also dir name
   for xf in $(echo "$lst" | cut -d'|' -f1,2); do
	FlDis=$(echo "$xf" | cut -d'|' -f1)

        # strip version
	FlNme=$(echo "$FlDis" | cut -d'_' -f2)

	# move/backup files where they belong
	DTyp=$(echo "$xf" | cut -d'|' -f2)

	mv "${DMMrot}/$FlDis" "$bkD/$DTyp/$FlNme"
	log "PASS: Distro($FlDis):$bkD/$DTyp/$FlNme"
   done
}

cre_newSIM() {
echo '#!/bin/sh' > "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'DMMrot="$PWD"' >> "aDStart.sh"
echo 'simulate_ahr=$(ahr_stamp 2>&1 | head -n 1)' >> "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'simulate_new() {' >> "aDStart.sh"
echo '   local sim="$1"' >> "aDStart.sh"
echo '   local i=1' >> "aDStart.sh"
echo '   if echo "$sim" | grep -qi "not found"; then' >> "aDStart.sh"
echo '	echo "Hello World ..."' >> "aDStart.sh"
echo '   else' >> "aDStart.sh"
echo '	echo "You are emancipated ..."' >> "aDStart.sh"
echo '	for i in $(seq 11 -1 5); do' >> "aDStart.sh"
echo '	   str=$(echo "$(ahr_stamp)" | cut -dxx -f2)' >> "aDStart.sh"
echo '	   dst=$(echo "$str" | cut -dyy -f1)' >> "aDStart.sh"
echo '	   nst=$(echo "$str" | cut -dyy -f2)' >> "aDStart.sh"
echo '	   printf "%09d" "$i"' >> "aDStart.sh"
echo '	   printf "%b \\n" "$dst$nst"' >> "aDStart.sh"
echo '	   ###sleep 0.1' >> "aDStart.sh"
echo '	   i=$(($i+1))' >> "aDStart.sh"
echo '	done' >> "aDStart.sh"
echo '   fi' >> "aDStart.sh"
echo '}' >> "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'simulate_new "$simulate_ahr"' >> "aDStart.sh"
sed -i "s/dyy/d'.'/g" "aDStart.sh"
sed -i "s/dxx/d':'/" "aDStart.sh"
}

cre_oldSIM() {
echo '#!/bin/sh' > "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'DMMrot="$PWD"' >> "aDStart.sh"
echo 'simulate_ahr=$(ahr_stamp 2>&1 | head -n 1)' >> "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'simulate_old() {' >> "aDStart.sh"
echo '   local sim="$1"' >> "aDStart.sh"
echo '   if echo "$sim" | grep -qi "not found"; then' >> "aDStart.sh"
echo '	echo "Hello World ..."' >> "aDStart.sh"
echo '   else' >> "aDStart.sh"
echo '	echo "You are emancipated: $(ahr_stamp)"' >> "aDStart.sh"
echo '   fi' >> "aDStart.sh"
echo '}' >> "aDStart.sh"
echo "" >> "aDStart.sh"
echo 'simulate_old "$simulate_ahr"' >> "aDStart.sh"
}

ck_distribution() {
   local lst="$1"
   local lf=""

   for lf in $(echo "$lst" | cut -d'|' -f1); do
        if [ ! -f "$lf" ]; then
           log "ERROR: Distribution File Missing $lf"
           echo "ERROR: File Not Found: $lf"
           exit
	else
	   log "PASS: \tDistribution Files Ok $lf"
        fi
   done
}

# Create distribution Backup sub-folder structure
create_DDir() {
   local bDir="$1"
   local DMMold="${bDir}/old"
   local DMMnew="${bDir}/new"

   if [ ! -d "$DMMold" ]; then
	mkdir -p "$DMMold"
	log "PASS: \tCreated Distro Backup $DMMold"
   else
	log "PASS: \tDistro Backup Exists $DMMold"
   fi

   if [ ! -d "$DMMnew" ]; then
        mkdir -p "$DMMnew"
        log "PASS: \tCreated Distro Backup $DMMnew"
   else
	# refresh
	rm -R "$DMMnew"
	mkdir -p "$DMMnew"
        log "PASS: \tDistro Backup Refresh $DMMnew"
   fi
}

###
##
#
##
###

ahr_service() {
   DMMahr="ahr_stamp.c"
   DMMahrExe="ahr_stamp"

   generate_ahr_stamp_code "$DMMahr"
   install_ahr_stamp "$DMMahrExe" "$DMMahr"
   setup_ahr_service "$DMMahrExe"
   verify_installation "$DMMahrExe"
   rm ahr_*
}

# Function to generate ahr_stamp C code
generate_ahr_stamp_code() {
    local ahrS="$1"
    cat << 'EOF' > "${ahrS}"
#include <stdio.h>
#include <time.h>

// Function to generate the auto-generated timestamp in the format "counter:timestamp"
void ahr_stamp() {
    static int callCounter = 0;
    struct timespec currentTime;
    clock_gettime(CLOCK_REALTIME, &currentTime);

    // Increment the call counter
    callCounter++;

    // Extract individual components of the timestamp
    struct tm timeInfo;
    localtime_r(&currentTime.tv_sec, &timeInfo);

    // Format and print the auto-generated timestamp
    printf("%09d:%04d%02d%02d%02d%02d%02d.%09ld\n",
           callCounter,
           timeInfo.tm_year + 1900,
           timeInfo.tm_mon + 1,
           timeInfo.tm_mday,
           timeInfo.tm_hour,
           timeInfo.tm_min,
           timeInfo.tm_sec,
           currentTime.tv_nsec);
}

int main() {
    // Call the function to generate and print the auto-generated timestamp
    ahr_stamp();

    return 0;
}
EOF
}

# Function to compile and install ahr_stamp
install_ahr_stamp() {
    local ias="$1"
    local ahr="$2"
    gcc -o "${ias}" "${ahr}" -lrt
    cp "${ias}" /usr/local/bin/
    chmod +x "/usr/local/bin/${ias}"
}

# Function to set up AHR service providing ahr_stamp
setup_ahr_service() {
    local isa="$1"
    cat << EOF | tee /etc/systemd/system/ahr.service > /dev/null
[Unit]
Description=AHR Service providing ahr_stamp

[Service]
ExecStart=/usr/local/bin/${isa}
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ahr
    systemctl start ahr
}

# Function to verify installation and service status
verify_installation() {
    local isa="$1"
    # Check if ahr_stamp is in place
    if [ -x "/usr/local/bin/${isa}" ]; then
        log "PASS: ahr_stamp is installed in /usr/local/bin/${isa}"
    else
        log "ERROR: ahr_stamp is not installed in /usr/local/bin/${isa}"
    fi

    # Check if the AHR service is enabled and running
    if systemctl is-active --quiet ahr; then
        log "PASS: AHR service is running."
    else
        log "ERROR: AHR service is not running."
    fi

    if systemctl is-enabled --quiet ahr; then
        log "PASS: AHR service is enabled to start on boot."
    else
        log "ERROR: AHR service is not enabled to start on boot."
    fi
}
#
##
###
ndx_config() {
   local NdxFle="$1"
   local varNdx=""
   local tCnt=1
   local NdxLne=""

   local fBak=$(echo "$NdxFle" | sed -e "s:.ahr:.bak:")
   varNdx=$(cat "$NdxFle")

   > "$fBak"

   for NdxLne in $(echo "$varNdx"); do
        echo "${tCnt}|${NdxLne}" >> "$fBak"
   tCnt=$(($tCnt + 1));
   done

   mv "$fBak" "$NdxFle"

   log "Indexing Configuration File Completed"
}

Config_Writer() {
   local uCW="$1"

   DMMwrk=$(echo "$uCW" | cut -d'|' -f1)
   DMMtmp=$(echo "$uCW" | cut -d'|' -f2)
   DMMbak=$(echo "$uCW" | cut -d'|' -f3)

   DMMini="$DMMwrk/aDConfig.ahr"
   DMMfle="$DMMtmp/aDTmp.ahr"
   DMMapp="$DMMwrk/aDApp.sh"

   local vStr=$(get_version)
   local verGCC=$(echo "$vStr" | cut -d'|' -f1)
   local vCoreUtl=$(echo "$vStr" | cut -d'|' -f2)
   local vDialog=$(echo "$vStr" | cut -d'|' -f3)

   verGCC=$(echo "$verGCC" | cut -d'=' -f2)
   vCoreUtl=$(echo "$vCoreUtl" | cut -d'=' -f2)
   vDialog=$(echo "$vDialog" | cut -d'=' -f2)

   # groups have headers
   vH="ver=verGCC,vCoreUtl,vDialog"
   lH="loc=DMMrot,DMMwrk,DMMbak"
   mH="mma=DMMapp,DMMtmp,DMMfle"

   # desc as a library of group also sequence!
   vDsc="GCC.+.Version,CoreUtil.+.Version,Dialog.+.Version"
   lDsc="CodeRoot.+.Location,Project.+.Space,Project.+.Backup"
   mDsc="Dialog.+.Application,Dialog.+.TMP.+.Folder,Dialog.+.TMP.+.File"

   # etc but add date stamp while iterating
   local aC=1
   local vxD=$(generate_date)
   local rec=""
   log "Compiling Configuration File: $p2V"

   for aV in $(echo "$vH" | cut -d'=' -f2 | tr ',' '\n'); do
      # Get the corresponding description from the array using the counter
      vDesc=$(echo "$vDsc" | cut -d',' -f"${aC}")
      # Evaluate the variable to get its value
      eaV=$(eval "echo \$$aV")
      # Write the entry to the config file with the description
      echo "$vH|$aV=$eaV|$vDesc|$vxD" >> "${DMMini}"
      rec=$(echo "$vDesc" | sed "s/.+./ /g")
      log "PASS: \tRecord $rec Created"

      # Increment the counter for the next iteration
      aC=$((aC + 1))
   done

   # Reset the counter for the next group
   aC=1
   rec=""
   local lxD=$(generate_date)

   # Example for the "loc" group
   for aL in $(echo "$lH" | cut -d'=' -f2 | tr ',' '\n'); do
      lDesc=$(echo "$lDsc" | cut -d',' -f"${aC}")
      eaL=$(eval "echo \$$aL")
      echo "$lH|$aL=$eaL|$lDesc|$lxD" >> "${DMMini}"
      rec=$(echo "$lDesc" | sed "s/.+./ /g")
      log "PASS: \tRecord $rec Created"
      aC=$((aC + 1))
   done

   aC=1
   local mxD=$(generate_date)
   # Example for the "mma" group
   for aM in $(echo "$mH" | cut -d'=' -f2 | tr ',' '\n'); do
      mDesc=$(echo "$mDsc" | cut -d',' -f"${aC}")
      eaM=$(eval "echo \$$aM")
      echo "$mH|$aM=$eaM|$mDesc|$mxD" >> "${DMMini}"
      rec=$(echo "$mDesc" | sed "s/.+./ /g")
      log "PASS: \tRecord $rec Created"
      aC=$((aC + 1))
   done

   # the process of writing/compiling the configuration file
   # is completed by ndx_config()
   ndx_config "$DMMini" "$uMd"
}

# --------------------
create_structure() {
   local uFld="$1"
   local uf=""
   local uc=1
   local dr=""
   clear
   log "Start Structure: $p2V"

   # Path Description Lib
   local udLib="Project Space Path,Dialog TmpDir,Backup Dir"
   for uf in $(echo "$uFld" | tr '|' '\n'); do
	dr=$(echo "$udLib" | cut -d',' -f"${uc}");
	mkdir -p "$uf"
	log "\t$dr: $uf"
   uc=$(($uc + 1));
   done
}

ui_Emancipation() {
    local uMOD="$1"
    local uBok=""
    UAHR="${UAHR=dialog}"

    uAHR=$("${UAHR}" --stdout --colors \
        --title "AHR(a dialog to?)" \
        --backtitle "A Dialog Experiment" \
	--ok-label "Accept" \
        --cancel-label "Default" \
        --menu "Create Project Type: \Z5${uMOD}" 12 64 4 \
        "1" "Emancipated Version ahr service" \
	"2" "Basic Code Development"
    )

    uBok="$?"

    case "$uBok" in
    0)
	# Get the form input -sterilize
	uAHR=$(echo "${uAHR}" | sed "s/ //g")

	# just making sure
	if [ -z "$uAHR" ]; then
	   uAHR="1"
	fi

	if [ "$uAHR" = "1" ]; then
	   log "PASS: Selected Install Type: emancipated"
	else
	   log "PASS: Selected Install Type: default"
	fi
   ;;
   1)
	   log "PASS: Selected Install Type: default"
   ;;
   255)
	   log "PASS: Selected Install Type: default"
   ;;
   esac
}

invalid_name() {
   local nme="$1"
   local e=""

   # Check if the first character is alphabetical
   if ! echo "$nme" | grep -Eq "^[[:alpha:]]"; then
      e="err"
   fi

   # Check if the name contains invalid characters or whitespace
   if echo "$nme" | grep -Eq '[^[:alnum:]_]'; then
      e="err"
   fi

   echo "$e"

}

check_SIN() {
   local sin="$1"
   local e=""
   for s in $(echo "$sin" | tr '|' '\n'); do
      for d in $(echo "$s" | tr '/' '\n'); do
         errName=$(invalid_name "$d")
         if [ ! -z "$errName" ]; then
            e="Invalid Name submitted"
            break
         fi
      done
   done
   echo "$e"
}

# Function to check the maximum depth among all paths in sIN
check_Depth() {
   local sin="$1"
   local max_encountered_depth=0

   for path in $(echo "$sin" | tr '|' '\n'); do
      current_depth=$(echo "$path" | awk -F'/' '{print NF-1}')
      if [ "$current_depth" -gt "$max_encountered_depth" ]; then
         max_encountered_depth="$current_depth"
      fi
   done

   echo "$max_encountered_depth"
}

check_DMMrot() {
   local sin="$1"
   local e=""
   DMMrot="$PWD"
   local DMMelements=$(echo "$DMMrot" | tr '/' '\n' | wc -l)

   if [ "$DMMelements" -gt 5 ]; then
      e="current path exceeds depth of 4 $DMMrot"
   else
      for path in $(echo "$sin" | tr '|' '\n'); do
         if [ "${path#$DMMrot}" = "$path" ]; then
            e="User cannot modify current path $DMMrot"
         fi
      done
   fi
   if [ ! -z "$e" ]; then
      echo "$e"
   fi
}

validate_uiForm() {
   local sIN="$1"
   # errName is global for now
   errName=$(check_SIN "$sIN")
   if [ ! -z "$errName" ]; then
        # echo "Invalid Name submitted"
        ui_DirForm "Invalid Name submitted"
   fi
   # overrides the prior error and calls the uFRM
   errMaxDepth=$(check_Depth "$sIN")
   if [ "$errMaxDepth" -gt 5 ]; then
	# echo "Exceeding maximum path depth of 5"
	ui_DirForm "Exceeding maximum path depth of 5"
   fi

   # Confined to the current directory
   errDMMrot=$(check_DMMrot "$sIN")
   if [ ! -z "$errDMMrot" ]; then
	ui_DirForm "$errDMMrot"
   fi
}

ui_DirForm() {
    local uERR="${1}"
    local uBtn=""
    DMMrot="$PWD"
    UINP="${UINP=dialog}"

    uFRM=$("${UINP}" --clear --stdout --colors \
        --title "AHR(a dialog to?)" \
        --backtitle "A Dialog Experiment" \
        --form "Create Project Space: \Z5${uERR}" 12 64 4 \
        "    Project Name Folder: " 1 1 "${DMMrot}/Demo" 1 25 25 0 \
        "Dialog Temporary Folder: " 2 1 "${DMMrot}/zDtmp" 2 25 25 0 \
        "  Project Backup Folder: " 3 1 "${DMMrot}/zDBak" 3 25 25 0
    )

    uBtn="$?"  # Save the value of the buttons (OK = 0, Cancel = 1, ESC = 255)

    case "$uBtn" in
    0)
	# Get the form input -sterilize
	uFRM=$(echo "${uFRM}" | tr '\n' '|')
	uFRM=$(echo "${uFRM}" | sed "s/ //g")
	uFRM=$(echo "${uFRM}" | sed "s/|$//")

	# Validate the provided input
	validate_uiForm "${uFRM}"
   ;;
   1)
	return 1 ;; # Cancel pressed
   255)
	return 1 ;; # ESC pressed
    esac
}

# returns k=v| delimited...
get_version() {
   verGCC=$(gcc --version | head -n 1)
   verGCC=$(echo "$verGCC" | awk '{print $3}')
   verGCC=$(echo "$verGCC" | cut -d'-' -f1)
   verGCC=$(echo "$verGCC" | cut -d'.' -f1,2 | bc)

   vCoreUtl=$(dd --version | head -n 1)
   vCoreUtl=$(echo "$vCoreUtl" | cut -d' ' -f3)
   vCoreUtl=$(echo "$vCoreUtl" | bc)

   vDialog=$(dialog --version | head -n 1)
   vDialog=$(echo "$vDialog" | cut -d' ' -f2)
   vDialog=$(echo "$vDialog" | cut -d'-' -f1 | bc)

   echo "verGCC=$verGCC|vCoreUtl=$vCoreUtl|vDialog=$vDialog"
}

check_version() {
   local vStr=$(get_version)
   local verGCC=$(echo "$vStr" | cut -d'|' -f1)
   local vCoreUtl=$(echo "$vStr" | cut -d'|' -f2)
   local vDialog=$(echo "$vStr" | cut -d'|' -f3)

   verGCC=$(echo "$verGCC" | cut -d'=' -f2)
   if [ $(echo "${verGCC}*100 < 1130" | bc) -eq 1 ]; then
        log"Requires GCC Compiler version 11.3 or greater";
	log "ERROR: GCC Compiler version: $verGCC"
	exit
   else
	log "PASS: GCC Compiler version: $verGCC"
   fi

   vCoreUtl=$(echo "$vCoreUtl" | cut -d'=' -f2)
   if [ $(echo "${vCoreUtl}*100 < 832" | bc) -eq 1 ]; then
        log "Requires GNU CoreUtilities version 8.32 or greater";
	log "ERROR: GNU CoreUtilities version: $vCoreUtl"
        exit
   else
	log "PASS: GNU CoreUtilities version: $vCoreUtl"
   fi

   vDialog=$(echo "$vDialog" | cut -d'=' -f2)
   if [ $(echo "${vDialog}*100 < 130" | bc) -eq 1 ]; then
        log "Requires Dialog version 1.3 or greater";
	log "ERROR: Dialog version $vDialog"
        exit
   else
	log "PASS: Dialog version $vDialog"
   fi
}

# Function to control code for debugging purpose
ui_pausePRG() {
    local entr=""
    echo ""
    printf "%b \n" "\tPress Enter to continue ..."
    read -r entr
    echo ""
}

# Function to display error messages and exit
error_exit() {
    echo "Error: $1"
    log "Error: $1"
    exit 1
}

# Installs required packages per user input
install_package_apt() {
   local iPkg="$1"
   local p=""
   local Pkg_status=""

   for p in $(echo "$iPkg" | tr ',' '\n'); do
	p=$(echo "$p" | sed "s/ //g")
	if [ ! -z "$p" ]; then
           # Suppress errors during package installation
           set +e
	   log "Updating System using APT..."
	   apt-get update
	   ### echo "Installing $p ..."
           log "Installing $p using APT..."
           apt-get install -y "$p" >/dev/null 2>&1
           Pkg_status=$?
           set -e
           if [ $Pkg_status -ne 0 ]; then
                error_exit "Failed to install $p using APT."
           else
                log "Success: $p - installed ..."
           fi
	fi
   done
}

yn_prompt () {
   # USE: if yn_prompt "Press Y/y to confirm (N/n to cancel):"
   local yn="";
   while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Please answer yes or no." ;;
        esac
    done
}

ui_packages() {
   local xitPkg="$1"
   local e=""

   clear
   printf "%b \n" "\n\n"
   echo "The installer required packages that are listed below:"
   echo ""
   for e in "$xitPkg"; do
	e=$(echo "$e" | cut -d'-' -f2,3)
	echo "$e"
   done
   echo ""
   echo "The installer uses apt-get install -y <package>"
   echo "- If you do not use apt package manager is recommended to exit now!"
   echo ""
   echo "- Use your favorite package manager and install the required package/s."
   echo "- Rerun this installer afterwords"
   echo ""
   echo "Do you want to install such package/s?"
   if yn_prompt "Press Y/y to confirm (N/n to cancel): "; then
	log "APT -installing packages per user input"
	install_package_apt "$xitPkg"
   else
        echo "Installation aborted"
        rm "$LOG_FILE"
        exit
   fi
   echo "Select install Mode Y/y Automated N/n Verbose?"
   if yn_prompt "Press Y/y to confirm (N/n to cancel): "; then
        log "Automated Install Mode Selected by user"
        p2V="automated"
   else
	log "Verbose Install Mode Selected by user"
	p2V="verbose"
   fi

}

probe_required_package() {
    local rPkg="$1"
    local rp=""
    local cMD=""
    local pkg=""
    # required packages
    for rp in $(echo "$rPkg"); do
	cMD=$($rp --version 2>&1 | head -n 1)
	if echo "$cMD" | grep -qi "not found"; then
	   log "$rp -package is required but not installed"
	   pkg="$pkg,$rp"
	fi
    done
    # remove 1st occurance
    pkg=$(echo "$pkg" | sed "s/,//");
    echo "$pkg"
}

# Function to kick-start the AHR installation
install_ahr() {
    # Check if the script is run as root or with sudo privileges
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root or with sudo privileges."
        exit 1
    fi

    # Create log file
    > "$LOG_FILE"

    # Packages
    local verPkg="gcc dd dialog"
    local regPkg=""

    log "Automated Hardcoded Resources (AHR)"
    reqPkg=$(probe_required_package "$verPkg")
    if [ ! -z "$reqPkg" ]; then
	ui_packages "$reqPkg"
    fi

    check_version "$verPkg"

##
#
##
    p2V="verbose" # override for touring purpose
    ui_DirForm "$procAS"
    if [ ! -z "$uFRM" ]; then
	log "PASS: User Input and Form Validation"
	vAHR=$(ui_Emancipation "$p2V")

	if echo "$vAHR" | grep -qi "emancipated"; then
	   app_NewFiles "$uFRM" "$p2V"
	   ending_statement "$DMMini" "new"
	else
	   app_OldFiles "$uFRM" "$p2V"
	   ending_statement "$DMMini" "old"
	fi
    else
	 log "Installation process canceled by user"
    fi

    rm "$LOG_FILE"
}

install_ahr
