using module D.InfoClasses
Import-Module  D.AzureFunctions -Force

$VerbosePreference = "Continue"

#region Internal Variables

enum rgProcess {
    newRG = 1
    testRG = 2
}

[rgProcess] $menu = [rgProcess]::testRG

$continueProcessing = $true
$deploymentLocation = "eastus"
$gitRepositoryURI = "https://github.com/artcolman/ARM-Templates/blob/master/marker"
$resourceGroupName = "rg-pshell-test-eastus-001"
$resourceLocation = "eastus"
$subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
$templateName = "/ResourceGroups/ResourceGroup.json"
#$tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'



#endregion

## Sign in - Ctrl+Ship+P Azure: SignIn

#region Test connection

if ($continueProcessing -eq $true) {

    Write-Verbose 'Test-Subscription process initiated'

    $Script:continueProcessing = Test-Subscription -subscriptionID $subscriptionID

    Write-Verbose 'Test-Subscription process finished'

}

#endregion

#region Resource Group and Storage Account

if ($continueProcessing -eq $true) {

    if($menu -eq [rgProcess]::newRG ) {

        $templateURI = $gitRepositoryURI.Replace("/marker", $templateName)

        Write-Verbose ( -join ("TemplateURI: ", $templateURI))
    
        $rgGroup = New-ResourceGroup `
            -RGName $resourceGroupName `
            -DeploymentLocation $deploymentLocation `
            -TemplateURI $templateURI `
            -RGLocation $resourceLocation

        $rgGroup
    }
    elseif($menu -eq [rgProcess]::testRG) {
        $templateURI = $gitRepositoryURI.Replace("/marker", $templateName)

        Write-Verbose ( -join ("TemplateURI: ", $templateURI))
    
        $errObject = Test-ARMTemplate `
            -Location $deploymentLocation `
            -TemplateURI $templateURI   

        $errObject | Format-List -Property * -Force
    }
}

#endregion

## Do other creates

## Pause?

## Clean-up

