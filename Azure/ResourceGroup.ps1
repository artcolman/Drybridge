Import-Module  D.AzureFunctions -Force
Import-Module  D.ArmTemplateFunctions -Force

$DebugPreference = "SilentlyContinue"
$VerbosePreference = "Continue"

## Sign in - Ctrl+Ship+P Azure: SignIn

#region Initialize Variables

$script:subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'

$script:rgPrefix = -"rg-pshell-test-eastus-"
$script:rgBaseTemplate = "/ResourceGroups/ResourceGroup - LinkedTemplate.json"
$script:rgBaseParameter = "/ResourceGroups/ResourceGroup.parameters - Markers.json"

$script:resourceLocation = "eastus"
$script:deploymentLocation = "eastus"

$local:cleanUp = $true

$script:localRepositoryName = "C:\Users\Art\Documents\GitHub\ARM-Templates"

#endregion

function Main {

    $continueProcessing = $true

    if($continueProcessing) {TestConnection}

    if($continueProcessing) {

        $script:BaseTimeStamp = Get-Date -UFormat %s
        $script:RunFolder = Join-Path "C:\Users\Art\Documents\Drybridge\AzureDeploys" $BaseTimestamp

        New-Item -Path $RunFolder -Type Directory
                    
    #region Create Resource Group Template Instance
        $ResourceType = "ResourceGroup"
        $rgBaseTemplateFile = Join-Path -Path $localRepositoryName -ChildPath $rgBaseTemplate
        $rgBaseParameterFile = Join-Path -Path $localRepositoryName -ChildPath $rgBaseParameter

        $rgTemplateFile = -join ('/', $ResourceType, '/', $ResourceType, ".json")
        $rgTemplateFilePath_Run = Join-Path -Path $LocalRunFolder -ChildPath $rgTemplateFile

        $rgParmFile = -join ('/', $ResourceType, $ResourceType, ".parameters.json")
        $rgParmFilePath_Run = Join-Path -Path $localRunFolder -ChildPath $rgParmFile

        $continueProcessing = New-TemplateInstance `
            -ResourceType $ResourceType `
            -BaseTemplateFile $rgBaseTemplateFile `
            -BaseParameterFile $rgBaseParameterFile `
            -TemplateFilePath $rgTemplateFilePath_Run `
            -ParmFilePath $rgParmFilePath_Run
    #endregion

        #region Create Storage Account Template Instance
        $ResourceType = "StorageAccount"
        $stBaseTemplateFile = Join-Path -Path $localRepositoryName -ChildPath $stBaseTemplate
        $stBaseParameterFile = Join-Path -Path $localRepositoryName -ChildPath $stBaseParameter

        $stTemplateFile = -join ('/', $ResourceType, '/', $ResourceType, ".json")
        $stTemplateFilePath_Run = Join-Path -Path $LocalRunFolder -ChildPath $stTemplateFile

        $stParmFile = -join ('/', $ResourceType, $ResourceType, ".parameters.json")
        $stParmFilePath_Run = Join-Path -Path $localRunFolder -ChildPath $stParmFile

        $continueProcessing = New-TemplateInstance `
            -ResourceType $ResourceType `
            -BaseTemplateFile $stBaseTemplateFile `
            -BaseParameterFile $stBaseParameterFile `
            -TemplateFilePath $stTemplateFilePath_Run `
            -ParmFilePath $stParmFilePath_Run
    #endregion
    }

    #Resource Group Parameters
    if ($continueProcessing) {

        $rgName = -join ($rgPrefix, $baseTimeID)

        $rgMarkerList = "rgName-Marker",  "rgLocation-Marker"
        $rgValueList = $rgName, $resourceLocation

        $continueProcessing = Update-TemplateValues `
            -ParmFilePath $newParmFilePath `
            -MarkerList $rgMarkerList `
            -ValueList $rgValueList
    }           

    #Storage Account Parameters
    if ($continueProcessing) {

        $stName = -join ($stPrefix, $baseTimeID)
        $stMarkerList = "rgName-Marker",  "rgLocation-Marker", "stType-Marker", "stName-Marker"
        $stValueList = $rgName, $resourceLocation, $stType, $stName

        $continueProcessing = Update-TemplateValues `
            -ParmFilePath $newParmFilePath `
            -MarkerList $stMarkerList `
            -ValueList $stValueList
    }   

    if($continueProcessing) {
        $continueProcessing = ResourceGroup_New `
            -TemplateFilePath $templateFilePath `
            -TemplateParameterFilePath $newParmFilePath
    }

    if($continueProcessing -and $cleanUp) {
        Write-Verbose "=> Cleaning Up"
    }
}


function TestConnection {

    return Test-Subscription -subscriptionID $subscriptionID

}

function ResourceGroup_New {`
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $TemplateFilePath,

        [Parameter(Mandatory)]
        [string]
        $TemplateParameterFilePath
    )
    Write-Verbose "=> Starting ResourceGroup_New"
    
    $Local:psDeployment = $null

    if($useURI) {
        $psDeployment = `
            New-ResourceGroup `
                -RGName $resourceGroupName `
                -DeploymentLocation $deploymentLocation `
                -TemplateURI $templateURI `
                -TemplateParameterURI $templateParameterURI `
                -RGLocation $resourceLocation
    }
    else {
        $psDeployment = `
            New-ResourceGroup `
                -RGName $resourceGroupName `
                -DeploymentLocation $deploymentLocation `
                -TemplateFilePath $TemplateFilePath `
                -TemplateParameterFilePath $TemplateParameterFilePath `
                -RGLocation $resourceLocation            
    }

    iF($psDeployment.ProvisioningState -eq "Succeede") {
        return $true
    }
    else {
        return $false
    }
}

. Main