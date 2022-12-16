#!/usr/bin/env bash

## Check dependencies
if ! ./util-check-dependency.sh date jq aws; then

	return 1 2> /dev/null; exit 1;

fi

## 'source' is required for script to set shell environment variables
case "${0##*/}" in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh)
	;;

*)
	echo "ERROR: Script is not being sourced. Re-run with 'source' or '.' prepended.";
	return 1 2> /dev/null; exit 1
	;;

esac

## --logout will clear locally set credentials from the environment
if [[ "$1" == "--logout" ]]; then

	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
	echo "Cleared credentials from environment."

	return 0 2> /dev/null; exit 0

fi

## Running without all required parameters displays help. --help prevents mockery.
if [[ "$1" == "" || "$2" == "" || "$3" == "" || "$4" == "" ]]; then

	if [[ "$1" != "--help" ]]; then

		echo "Invalid inputs. Don't run this all Willy Nilly."

	fi

	echo "Usage:"
	echo "    . ${BASH_SOURCE[0]} aws-account-id payer-profile payer-username payer-mfa-token [override-role]"
	echo "        Assumes the OrganizationAccountAccessRole"
	echo ""
	echo "    . ${BASH_SOURCE[0]} --logout"
	echo "        Clears credentials from local environment"

	return 1 2> /dev/null; exit 1

else

	## All required parameters are good, set variables
	ACCT_ID=$1
	PAYER_PROFILE=$2
	PAYER_USER=$3
	TOKEN_CODE=$4
	
	if [[ "$5" == "" ]]; then

		ROLE="OrganizationAccountAccessRole"

	else

		ROLE=$5

	fi

fi

## Get account ID by account name if name is provided
if [[ "$ACCT_ID" -gt 0 ]]; then

	echo "Using provided account ID '$ACCT_ID'"

else

	echo -n "Searching account named '$ACCT_ID'... "
	ACCT_ID=$(aws organizations list-accounts \
		--profile $PAYER_PROFILE \
		| jq -r ".Accounts[] | select(.Name==\"$ACCT_ID\") | .Id")

	if [[ "$ACCT_ID" == "" ]]; then

		echo "not found."
		return 1 2> /dev/null; exit 1

	else

		echo "found $ACCT_ID."

	fi

fi	

## Get MFA device serial ARN for $PAYER_USER
MFA_SERIAL=$(aws iam list-mfa-devices \
	--profile $PAYER_PROFILE \
	| jq -r ".MFADevices[] | select(.UserName==\"$PAYER_USER\") | .SerialNumber")

if [[ "$MFA_SERIAL" == "" ]]; then

	echo "ERROR: No MFA token found for user '$PAYER_USER'."
	return 1 2> /dev/null; exit 1

fi

## Assume role using MFA token
CRED_JSON=$(aws sts assume-role \
	--role-arn arn:aws:iam::$ACCT_ID:role/$ROLE \
	--role-session-name $PAYER_USER \
	--serial-number $MFA_SERIAL \
	--token-code $TOKEN_CODE \
	--profile $PAYER_PROFILE)

## Check assume-role command success
if [[ $? -gt 0 ]]; then

	echo "Assuming the role failed."
	return 1 2> /dev/null; exit 1

fi

## If everything was successful, set environment credentials
export AWS_ACCESS_KEY_ID=$(jq -r ".Credentials.AccessKeyId" <<< $CRED_JSON)
export AWS_SECRET_ACCESS_KEY=$(jq -r ".Credentials.SecretAccessKey" <<< $CRED_JSON)
export AWS_SESSION_TOKEN=$(jq -r ".Credentials.SessionToken" <<< $CRED_JSON)

CRED_EXPIRATION=$(date -d $(jq -r ".Credentials.Expiration" <<< $CRED_JSON))
CRED_ARN=$(jq -r ".AssumedRoleUser.Arn" <<< $CRED_JSON)
echo "Credentials added to environment, and expire $CRED_EXPIRATION."
echo "Assumed role ARN: $CRED_ARN"

return 0 2> /dev/null; exit 0
