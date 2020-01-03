# README

This function app returns _access url or secret_ of function.

see [documentation](https://github.com/projectkudu/kudu/wiki/Functions-API#getting-a-functions-secrets) for more information.

## Run

Update `variables.tf` and run terraform.

```
terraform init
terraform apply
```

## Test

```
curl -H "Content-Type: application/json" \
 -H "cid: _client_id" \
 -H "secret: _aad_secret" \
 -H "tenantid: tenant_id" \
 -H "rgname: xxx-rg" \
 -H "sitename: siteapp" \
 -H "fxname: fxapp" \
 https://fxurl.azurewebsites.net/api/HttpUrl?code=dTuX6laJcdlaeWd7nffFbY4c8TAq2my2Fywy/Ra9zBarHpJ4hvECig==
 ```