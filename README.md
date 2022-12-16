# aws-assume-oaar

Simplifies assuming the AWS OrganizationAccountAccessRole (default) or a provided role name. Depends on a locally configured awscli profile with Organization read permissions.

## Usage:
```
Usage:
    . aws-assume-oaar.sh aws-account-id payer-profile payer-username payer-mfa-token [override-role]
        Assumes the OrganizationAccountAccessRole

    . aws-assume-oaar.sh --logout
        Clears credentials from local environment
```

## TODO:
- [x] Make 5th optional parameter, allowing specification of role name, defaulting to OrganizationAccountAccessRole.
- [x] Add dependency check for 'jq'
