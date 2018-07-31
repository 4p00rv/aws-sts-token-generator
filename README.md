AWS STS token generator
---
Generates sts token using `aws sts` cmd and updates the credentials file. 
After successfully generating the credentials, the new credentials are written under new profile ("mfa") which can be changed in the `aws_get_token.rb` file.

Usage:
---
> $ ./aws_get_token.rb --token 123456

Duration and profile to be used for generating token can be specified as:

> $ ./aws_get_token.rb --duration 14400 --profile s3_access --token 123456

Instructions:
---
Please modify the file (`aws_get_token.rb`) to specify your mfa device id and corresponding profile.
For example:

``` ruby
MFA_DEVICE_TO_PROFILE_MAP = {
  'default' => 'arn:aws:iam::123456789012:mfa/user',
  's3_access' => 'arn:aws:iam::123456789012:mfa/otheruser'
}
```

