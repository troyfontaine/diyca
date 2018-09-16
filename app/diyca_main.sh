#!/bin/bash
#------------------------------------
# Put tree into a known state (clean)
# Should be positioned at treetop
#------------------------------------
MYNAME=`basename $0`
HERE=`pwd`

# CA Cert Variables
CERTCONFIG=$HERE/bin/diyca_ca_cert.cfg
OUTKEYNAME=$HERE/ca/private/diyca_ca.key
OUTCSR=$HERE/ca/temp_ca.csr
OUTCRT=$HERE/certs/diyca_ca.crt

CA_CERT_CONFIG=$HERE/bin/diyca_ca_cert.cfg
CA_CERT_FILE=$HERE/certs/diyca_ca.crt
CA_KEY_NAME=$HERE/ca/private/diyca_ca.key

# Website Cert Variables
USER_CERT_CONFIG=$HERE/bin/diyca_web_cert.cfg
USER_OUT_KEY_NAME=$HERE/app_web/private/diyca_web.key
USER_CSR=$HERE/signer/temp_web.csr
USER_OUT_CRT=$HERE/certs/diyca_web.crt
USER_OUT_KEY_SIZE=2048

# Directory List Array
declare -a DIR_LIST
DIR_LIST('app_web/private' 'ca/{certs,db,private}' 'signer' 'certs' 'log')

setup() {
	# Evaluate hostname and modify diyca_web_cert.cfg
	# Use sed to replace line 16
    prep
    validate
	initialize_ca
	initialize_web
}

prep() {
    # Create application subdirectories
    logger -s -t $MYNAME "Create subdirectories for app"
    for directory in $DIR_LIST; do
		mkdir -p $directory
	done
}

initialize_ca() {
	touch ca/db/index
	touch ca/db/index.attr
	
	openssl rand -hex 16  > ca/db/serial
	
	# Not sure what this does yet
	logger -s -t $MYNAME 1001 > ca/db/crlnumber
	
	# Generate keypair and CSR for CA
	openssl req -new -nodes \
    -config $CERTCONFIG \
    -out $OUTCSR \
    -keyout $OUTKEYNAME
    
    # Generate Root CA Cert
    openssl ca -batch -selfsign \
    -config $CERTCONFIG \
	-keyfile $OUTKEYNAME \
    -in $OUTCSR \
    -out $OUTCRT
    
    # Duplicate CA Root Cert to Nginx Root
    mkdir /var/www/ca
	cp $OUTCRT /var/www/ca/
}

initialize_web() {
	# Generate Key Pair for Web UI
	openssl genrsa -out $USER_OUT_KEY_NAME $USER_OUT_KEY_SIZE
	
	# Generate CSR
	openssl req -new -config $USER_CERT_CONFIG -key $USER_OUT_KEY_NAME -out $USER_CSR
	
	# Generate Cert
	openssl ca -batch \
		-cert $CA_CERT_FILE \
		-config $CA_CERT_CONFIG \
		-extfile $USER_CERT_CONFIG \
		-extensions ext \
		-keyfile $CA_KEY_NAME \
		-in $USER_CSR \
		-out $USER_OUT_CRT
	
	# Copy cert and key for use with nginx
	cp $USER_OUT_CRT /etc/ssl/certs/
	cp $USER_OUT_KEY_NAME /etc/ssl/private/
}

clean() {
    # Remove application generated files and directories to restore pristine state
    logger -s -t $MYNAME "Begin"
    logger -s -t $MYNAME "Remove all app generated files to reset"
    declare -a EXT_LIST
    EXT_LIST=('*.crt' '*.csr' '*.key' '*.pyc' '*.db')
    
    for extension in $EXT_LIST; do
       find . -name $extension -exec rm {} \;
    done
    
    logger -s -t $MYNAME "Remove app generated directories"
    for directory in $DIR_LIST; do
		rm -rf $directory
	done
    
    logger -s -t $MYNAME "End"
}

# Used only by validate function
check_subdir () {
	# Check subdirectories to ensure they're accessible
	if [ ! -d $2 ]; then
		logger -s -t $1 "*** Subdirectory $2 is inaccessible"
		exit 86
	fi
}

validate(){
    VALIDATOR="diyca_validate_tree"
	if [ ! -r allow_nonroot ]; then
			USERID=`id -u $USER`
			if [ $USERID -ne 0 ]; then
				logger -s -t $VALIDATOR "*** Expected User ID = 0; observed USER=$USER, ID=$USERID"
				exit 86
			fi
		fi
	fi
	if [ ! -r diyca.version ]; then
		logger -s -t $VALIDATOR "*** diy.ssl.ca.version is inaccessible"
		exit 86
	fi
	
	# Validate created directories
	for directory in $DIR_LIST
		check_subdir $VALIDATOR $directory
	done
	
	# Validate default set of directories
	check_subdir $VALIDATOR "app_web"
	check_subdir $VALIDATOR "app_web/static"
	check_subdir $VALIDATOR "app_web/templates"
	check_subdir $VALIDATOR "app"
	check_subdir $VALIDATOR "docs"
	
}



help() {
    echo "Test"
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	declare cmd="$1"
	case "$cmd" in
		prep)  shift; prep;;
        clean) shift; clean;;
        setup) shift; setup;;
		*)		help;;
	esac
}

main "$@"