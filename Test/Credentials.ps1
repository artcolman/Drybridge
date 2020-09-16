$tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'
$subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
$plainTextPassword = 'acAC1024!'

$sp = Get-AzADServicePrincipal -DisplayName 'Drybridge-SP'
if ($null -eq $sp) {
    Write-Host "Creating new Service Principal"
    $credentialsAD = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$plainTextPassword}
    $sp = New-AzADServicePrincipal -DisplayName 'Drybridge-SP' -PasswordCredential $credentialsAD 
}

$spName = $sp.ServicePrincipalNames[0]

Write-Host "Application ID: " $sp.ApplicationId

$ra = Get-AzRoleAssignment -ServicePrincipalName $spName -RoleDefinitionName "Contributor"
if ($null -eq $ra) {
    Write-Host "Creating new Contributor Role Assignment"
    New-AzRoleAssignment -ApplicationId $sp.ApplicationId -RoleDefinitionName "Contributor"
}

$spSecret = ConvertTo-SecureString $plainTextPassword -AsPlainText -Force
$pass = (New-Object PSCredential $sp.ID, $spSecret).GetNetworkCredential( ).Password
$servicePrincipalAppID = $sp.ApplicationId
$servicePrincipalPassID = $pass

$securePassword = ConvertTo-SecureString $servicePrincipalPassID -AsPlainText -Force
$psCredential = New-Object System.Management.Automation.PSCredential ($servicePrincipalAppID, $securePassword)

Connect-AzAccount -Credential $psCredential -ServicePrincipal -Tenant $tenantID -Subscription $subscriptionID
