function ArmTemplate_Test() {

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
