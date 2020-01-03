## build & package apiapp

cd apiapp

Remove-Item out -Force -Recurse -

dotnet publish -c Release -o out apiapp.csproj

Compress-Archive -Path out\* -DestinationPath ..\..\assets\apiapp.zip -Force

## build & package fxeh

cd ..

dotnet build fxeh\extensions.csproj -o fxeh\bin --no-incremental

Remove-Item fxeh\obj -Force -Recurse

Compress-Archive -Path fxeh\* -DestinationPath ..\assets\fxeh.zip -Force

## package other fxapp

Compress-Archive -Path fxapp\* -DestinationPath ..\assets\fxapp.zip -Force

Compress-Archive -Path fxurl\* -DestinationPath ..\assets\fxurl.zip -Force

