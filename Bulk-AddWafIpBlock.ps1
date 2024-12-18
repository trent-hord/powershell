# Define the IP address to block
$ipAddressToBlock = "123.123.123.123"

# Define the policy name filter (ends with "dev")
$policyNameFilter = "dev$" 

# Get all WAF policies in the subscription
$wafPolicies = Get-AzApplicationGatewayFirewallPolicy

# Loop through each WAF policy
foreach ($policy in $wafPolicies) {
    # Filter policies by policyNameFilter
    if ($policy.Name -match $policyNameFilter) { 
        Write-Host "Processing policy: $($policy.Name)"

        # Create the match condition
        $variable = New-AzApplicationGatewayFirewallMatchVariable -VariableName RemoteAddr
        $condition = New-AzApplicationGatewayFirewallCondition -MatchVariable $variable -Operator IPMatch -MatchValue $ipAddressToBlock

        # Create the custom rule
        $ruleName = "BlockIP" + ($ipAddressToBlock -replace '\.', 'dot') 
        $rule = New-AzApplicationGatewayFirewallCustomRule -Name $ruleName -Priority 100 -RuleType MatchRule -MatchCondition $condition -Action Block -State Enabled

        # Add the rule to the policy
        $policy.CustomRules.Add($rule)

        # Update the policy
        Set-AzApplicationGatewayFirewallPolicy -InputObject $policy

        Write-Host "Added rule '$ruleName' to policy '$($policy.Name)'"
    } 
}

Write-Host "Finished processing WAF policies."
