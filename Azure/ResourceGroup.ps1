using module InfoClasses

$continueProcessing = $true
$subscriptionID = '0e4fd2e3-7f26-412d-a598-3901151357b1'
$resourceGroupName = ""
# $tenantID = 'd1477d12-f77f-47a0-8b90-a8908fef66a2'

Import-Module D.AzureFunctions

## Offline sign in - could this be a manual intervention?

#region Test connection

if ($continueProcessing -eq $true) {
    $Script:continueProcessing = Test-Subscription( -subscriptionID $subscriptionID )
}

#endregion

#region Resource Group and Storage Account

if ($continueProcessing -eq $true) {

    $rgGroup = New-ResourceGroup( -Name $resourceGroupName )

    if($null -eq $rgGroup) {
        $Script:continueProcessing = Create-ResourceGroup(-resourceGroupName $resourceGroupName)
    }
    else {
        $Script:continueProcessing = $false  
    }

}
#endregion

## Do other creates

## Pause?

## Clean-up

