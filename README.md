# aws-assume-oaar

Simplifies assuming the AWS OrganizationAccountAccessRole (default) or a provided role name. Depends on a locally configured awscli profile with Organization read permissions.

## Usage:

```
$ . aws-assume-oaar.sh aws-account-id payer-profile payer-username payer-mfa-token [override-role]
    Assumes the OrganizationAccountAccessRole

$ . aws-assume-oaar.sh --logout
    Clears credentials from local environment
```

## Example commands and outputs:

```
$ . aws-assume-oaar.sh 123456789012 jlyons210-awspayer jeremy 123456 S3ReadOnlyRole
Using provided account ID '123456789012'
Credentials added to environment, and expire Fri Dec 16 13:37:14 CST 2022.
Assumed role ARN: arn:aws:sts::123456789012:assumed-role/S3ReadOnlyRole/jeremy

$ . aws-assume-oaar.sh mycoolawsaccount mycoolmgmtaccount jeremy 123456 S3ReadOnlyRole
Searching account named 'mycoolawsaccount'... found 123456789012.
Credentials added to environment, and expire Fri Dec 16 13:26:51 CST 2022.
Assumed role ARN: arn:aws:sts::123456789012:assumed-role/S3ReadOnlyRole/jeremy

$ . aws-assume-oaar.sh mycoolawsaccount mycoolmgmtaccount jeremy 123456
Searching account named 'mycoolawsaccount'... found 123456789012.
Credentials added to environment, and expire Fri Dec 16 13:27:17 CST 2022.
Assumed role ARN: arn:aws:sts::123456789012:assumed-role/OrganizationAccountAccessRole/jeremy
```

## TODO:
- [x] Make 5th optional parameter, allowing specification of role name, defaulting to OrganizationAccountAccessRole.
- [x] Add dependency check for 'jq'
