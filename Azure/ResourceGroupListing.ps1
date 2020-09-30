using module D.InfoClasses
Import-Module  D.AzureFunctions -Force
## Sign in - Ctrl+Ship+P Azure: SignIn

function Main () {

    $VerbosePreference = "Continue"
    $script:subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
    $script:resourceGroupName = "rg-pshell-test-eastus-001"

    TestConnection
    Write-Verbose "Test-ResourceGroup Start"
    Test-ResourceGroupExists -Name $resourceGroupName
}

function TestConnection() {

    return Test-Subscription -subscriptionID $subscriptionID

}

. Main