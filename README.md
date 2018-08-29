# Bollard

A way of securing API communications with a JWT header that verifies a payload given a known secret

## Use
Install Bollard

```
gem install bollard
```

Use Bollard to :post messages
```
require "bollard"

Bollard.secure_post("https://my.endpoint/api", '{ "key_1": "val_1" }', "shared_secret_key")
```

Use Bollard to verify received messages
```
require "bollard"

Bollard.verify_post('{ "key_1": "val_1" }', "", "shared_secret_key")
```
