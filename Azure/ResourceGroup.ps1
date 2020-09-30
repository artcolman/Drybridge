Import-Module  D.AzureFunctions -Force
Import-Module  D.ArmTemplateFunctions -Force

## Sign in - Ctrl+Ship+P Azure: SignIn

#region Initialize Variables

$DebugPreference = "Continue"
$VerbosePreference = "Continue"

$script:BaseTimestamp = Get-Date -format FileDateTime
$script:resourceGroupName = "rg-pshell-test-eastus-001"
$script:resourceLocation = "eastus"
$script:deploymentLocation = "eastus"
$local:cleanUp = $true    

$script:gitRepositoryURI = "https://github.com/artcolman/ARM-Templates/blob/master/marker"
$script:localRepositoryName = "C:\Users\Art\Documents\GitHub\ARM-Templates"
$script:localRunFolder = "C:\Users\Art\Documents\Drybridge\AzureDeploys"
$script:resourceType = "ResourceGroup"
$script:subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
$script:templateFileName = "/ResourceGroups/ResourceGroup.json"
$script:templateFilePath = Join-Path $localRepositoryName $templateFileName
$script:templateURI = $gitRepositoryURI.Replace("/marker", $templateFileName)
$script:templateParameterFileName = "/ResourceGroups/ResourceGroup.parameters.json"
$script:templateParameterFilePath = Join-Path $localRepositoryName $templateParameterFileName
$script:templateParameterURIPath = $gitRepositoryURI.Replace("/marker", $templateParameterFileName)
#$script:tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'

Write-Debug ( -join ("TemplateFilePath: ", $templateFilePath))
Write-Debug ( -join ("TemplateParameterFilePath: ", $templateParameterFilePath))
Write-Debug ( -join ("TemplateURIPath: ", $templateURI))
Write-Debug ( -join ("TemplateParameterURIPath: ", $templateParameterURI))

#endregion

function Main {

    $Local:continueProcessing = TestConnection

    if($continueProcessing) {

        $BaseTemplate = "ResourceGroup - NoStorage.json"
        $BaseParameter = "ResourceGroup.parameters - Markers.json"
        $BaseTemplateFile = Join-Path -Path $script:localRepositoryName -ChildPath $BaseTemplate
        $BaseParameterFile = Join-Path -Path $script:localRepositoryName -ChildPath $BaseParameter
        $ResourceType = "ResourceGroup"

        $parmFile = -join ($ResourceType, "parameters.json")
        $newParmFilePath = Join-Path -Path $localRunFolder -ChildPath $parmFile

        Write-Debug "Initiating New-TemplateInstance"
        $continueProcessing = New-TemplateInstance { `
            -Timestamp $script:BaseTimestamp `
            -LocalRunFolder $script:localRunFolder `
            -ResourceType $ResourceType `
            -BaseTemplateFile $BaseTemplateFile `
            -BaseParameterFile $BaseParameterFile 
        }
            if ($continueProcessing) {

                $MarkerList = "rgName-Marker",  "rgLocation_Marker"
                $ValueList = $resourceGroupName, $resourceLocation

                $continueProcessing = Update-TemplateValues( `
                    -ParmFilePath $newParmFilePath `
                    -MarkerList $MarkerList `
                    -ValueList $ValueList ) 
            }           
    }

    if($continueProcessing) {
        $continueProcessing = ResourceGroup_New
    }

    if($continueProcessing -and $cleanUp) {
        Write-Verbose "=> Cleaning Up"
    }
}

function InitializeVariables {

    Write-Verbose " => Initialize Variables"

 
}

function TestConnection {

    return Test-Subscription -subscriptionID $subscriptionID

}

function ResourceGroup_New {
    
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
                -TemplateFilePath $templateFilePath `
                -TemplateParameterFilePath $templateParameterFilePath `
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