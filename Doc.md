# Run and test this terraform sample

## How to run

Deploy [tf_fxurl](./tf_fxurl) and update `variables.tf`.
Run `terraform` as following.

> Tested in the latest __Windows 10__ environment. You need to install [odbc driver](https://www.microsoft.com/en-us/download/confirmation.aspx?id=56567) and [sqlcmd](https://docs.microsoft.com/en-us/sql/tools/sqlcmd-utility?view=sql-server-ver15) tool in your PC to run successfully. You may use Azure Shell if you don't want to install any SW.

```
terraform init
terraform apply
```

> `fxurl` function app retrieves _function url_ of a function app without accessing Azure Portal.

## Setup and deploy manually

1. Setup database (MS SQL)

    - add your IP in firewall rules
    - run following `sqlcmd`

        ```
        sqlcmd -S <sqlsvr.database.windows.net> -d <dbname>  -U <username> -P <password> -Q "drop table events; create table events (id bigint identity primary key, message nvarchar(max), timecreated datetime)"
        ```

2. Deploying applications manually

    > update `username` and `password` from terraform _credentials output_ 

    ```
    .\zipdeploy.ps1 -username '<fxeh username>' -password <fxeh password> -appname <fxeh name> -filepath .\assets\fxeh.zip

    .\zipdeploy.ps1 -username '<webapp username>' -password <webapp password> -appname <webapp name> -filepath .\assets\apiapp.zip
    ```

3. Build applications

    App packages are provided in [assets](./assests) directory. However, you can build applications in case you have modified application source.

    - api app
        ```
        cd src\apiapp
        dotnet publish -c Release -o out apiapp.csproj
        Compress-Archive -Path out\* -DestinationPath ..\..\assets\apiapp.zip -Force
        ```

    - function app #1 (eh)
        > you need to install extension in your function app, see [documentation](https://docs.microsoft.com/en-us/azure/azure-functions/install-update-binding-extensions-manual)

        ```
        cd src
        dotnet build fxeh\extensions.csproj -o fxeh\bin --no-incremental
        Remove-Item fxeh\obj
        Compress-Archive -Path fxeh\* -DestinationPath ..\assets\fxeh.zip -Force
        ```

    - function app #2 (http)
        ```
        cd src
        Compress-Archive -Path fxapp\* -DestinationPath ..\assets\fxapp.zip -Force
        ```

## Test

1. Test event (upstream)

Go to [src/simeh](./src/simeh) and update `connectionString` of event hub that you just provisioned.

Run event simulator.

```
dotnet run
```

Check your MS SQL database for the events generated.

```
curl.exe -X GET https://<sitename>.azurewebsites.net/api/events
```

2. Test http (down stream)

```
 curl.exe -X POST -H "Content-Type: application/json" -d '\"batman\"' https://<sitename>.azurewebsites.net/api/values

```

## Tips

There are several ways to work around if terraform does not support Azure features.

- Using _ARM template_ for deploying webapp or functions app
- Using terraform `local_exec` for running commands locally. _e.g., sqlcmd, webapp zip deployment_

## Troubleshooting

Sometimes, provisioning takes several minutes and it's still running. In that case, cancel the task and run it again. 

## References

### Terraform

- Terraform Azure provider: https://www.terraform.io/docs/providers/azurerm/index.html
- Template deployment:https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html
- `file` function: https://www.terraform.io/docs/configuration/functions/file.html
- HTTP data source: https://www.terraform.io/docs/providers/http/data_source.html

### Azure App Svc/Fx

- Function key management: https://github.com/projectkudu/kudu/wiki/Functions-API#getting-a-functions-secrets
    - https://github.com/Azure/azure-functions-host/wiki/Changes-to-Key-Management-in-Functions-V2
- MSDeploy: https://docs.microsoft.com/en-us/rest/api/appservice/WebApps/CreateMSDeployOperation
- Zip Deploy: https://docs.microsoft.com/en-us/azure/azure-functions/deployment-zip-push
- REST API: https://github.com/projectkudu/kudu/wiki/REST-API
- Fx EH trigger: https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs#trigger---example
    - https://github.com/Azure/azure-functions-host/wiki/Updating-your-function-app-extensions