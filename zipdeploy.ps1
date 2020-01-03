
param(
    [string]$username,
    [string]$password,
    [string]$appname,
    [string]$filepath
)
<#
$username = '$sktdemotffxeh'
$password = "3nzQ9M47zvarwm1Rmv8Fo57fZxnQWfsocxZxCrTzRZQYfl0yXBtgHP3zP1Fg"
$apiUrl = "https://sktdemotffxeh.scm.azurewebsites.net/api/zipdeploy"
#>

$apiUrl = "https://$appname.scm.azurewebsites.net/api/zipdeploy"

echo "> $apiUrl, $username : $password"

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))
$userAgent = "powershell/1.0"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo); "content-type" = "multipart/form-data"} -UserAgent $userAgent -Method POST -InFile $filepath