using module D.InfoClasses
Import-Module  D.AzureFunctions -Force

$VerbosePreference = "Continue"


#region Internal Variables
$continueProcessing = $true
$deploymentLocation = "eastus"
$gitRepositoryURI = "https://github.com/artcolman/ARM-Templates/blob/master/"
$resourceGroupName = "rg-pshell-test-eastus-001"
$resourceLocation = "eastus"
$subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
$templateName = "ResourceGroups/ResourceGroup.json"
#$tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'

#endregion

## Sign in - Ctrl+Ship+P Azure: SignIn

#region Test connection

if ($continueProcessing -eq $true) {

    Write-Verbose 'Test-Subscription process initiated'

    $context = Get-AzContext
    $context | Select-Object -Property *
    
    $Script:continueProcessing = Test-Subscription -subscriptionID $subscriptionID

    Write-Verbose 'Test-Subscription process finished'

}

#endregion

#region Resource Group and Storage Account

if ($continueProcessing -eq $true) {

    $tempateURI = Join-Path $gitRepositoryURI $templateName

    Write-Output $templateURI
    
    $rgGroup = New-ResourceGroup `
                -RGName $resourceGroupName `
                -DeloymentLocation $deploymentLocation `
                -TemplateURI $tempateURI `
                -RGLocation $resourceLocation

    $rgGroup | Format-List * -Force

}

#endregion

## Do other creates

## Pause?

## Clean-up

