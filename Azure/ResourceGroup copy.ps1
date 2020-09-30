using module D.InfoClasses
Import-Module  D.AzureFunctions -Force
## Sign in - Ctrl+Ship+P Azure: SignIn

enum rgProcess {
    newRG = 1
    testRG = 2
}

function Main() {

    InitializeVariables

    $VerbosePreference = "Continue"
    $script:menu = [rgProcess]::newRG
    $script:useURI = $false

    $Local:continueProcessing = TestConnection
    if($Local:continueProcessing) {
        if($menu -eq [rgProcess]::newRG) {
            $Local:continueProcessing = ResourceGroup_New
        }
        else {
            $Local:continueProcessing = ResourceGroup_Test           
        }
    }
}

function InitializeVariables() {

    Write-Verbose " => Initialize Variables"
    $script:deploymentLocation = "eastus"
    $script:gitRepositoryURI = "https://github.com/artcolman/ARM-Templates/blob/master/marker"
    $script:localRepositoryName = "C:\Users\Art\Documents\GitHub\ARM-Templates"
    $script:resourceGroupObject
    $script:resourceGroupName = "rg-pshell-test-eastus-001"
    $script:resourceLocation = "eastus"
    $script:subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
    $script:templateFileName = "/ResourceGroups/ResourceGroup.json"
    $script:templateFilePath = Join-Path $localRepositoryName $templateFileName
    $script:templateURI = $gitRepositoryURI.Replace("/marker", $templateFileName)
    $script:templateParameterFileName = "/ResourceGroups/ResourceGroup.parameters.json"
    $script:templateParameterFilePath = Join-Path $localRepositoryName $templateParameterFileName
    $script:templateParameterURIPath = $gitRepositoryURI.Replace("/marker", $templateParameterFileName)
    #$script:tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'

    Write-Verbose ( -join ("   TemplateFilePath: ", $templateFilePath))
    Write-Verbose ( -join ("   TemplateParameterFilePath: ", $templateParameterFilePath))
    Write-Verbose ( -join ("   TemplateURIPath: ", $templateURI))
    Write-Verbose ( -join ("   TemplateParameterURIPath: ", $templateParameterURI))
    
}

function TestConnection() {

    return Test-Subscription -subscriptionID $subscriptionID

}

function ResourceGroup_New() {

    $script:resourceGroupObject = $null
    
    if($useURI) {
        $script:resourceGroupObject = `
            New-ResourceGroup `
                -RGName $resourceGroupName `
                -DeploymentLocation $deploymentLocation `
                -TemplateURI $templateURI `
                -TemplateParameterURI $templateParameterURI `
                -RGLocation $resourceLocation
        }
    else {
        $script:resourceGroupObject = `
            New-ResourceGroup `
                -RGName $resourceGroupName `
                -DeploymentLocation $deploymentLocation `
                -TemplateFilePath $templateFilePath `
                -TemplateParameterFilePath $templateParameterFilePath `
                -RGLocation $resourceLocation            
    }

    if($null -ne $script:resourceGroupObject) {
        return $true
    }
    else {
        return $false
    }
}

function ResourceGroup_Test() {

    if($useURI) {
        $errObject = Test-ARMTemplate `
            -Location $deploymentLocation `
            -TemplateURI $templateURIPath `
            -TemplateParameterURI $script:templateParameterURIPath 
    }
    else {
        Write-Verbose "Test-ARMTemplate File Path"
        $errObject = Test-ARMTemplate `
            -Location $deploymentLocation `
            -TemplateFile $templateFilePath `
            -TemplateParameterFile $templateParameterFilePath
    }

    $errObject | Format-List -Property * -Force
}


## Do other creates

## Pause?

## Clean-up

. Main