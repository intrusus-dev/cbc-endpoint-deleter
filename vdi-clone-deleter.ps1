<#
.SYNOPSIS
    VDI Clone Deletion Script
.DESCRIPTION
    This script is used to delete VDI clones in the VMware Carbon Black Cloud environment as the minimum value in
    the CBC console is only 24 hours. The script reduces this dwell time to 1h.

    Author: Leon Schulze
    GitHub: github.com/intrusus-dev

    Copyright (c) 2023 VMware Carbon Black. All rights reserved.

    Licensed under the MIT License. See LICENSE file for more details.
#>

# Load environment variables from auth.env file
$envFile = Get-Content -Path "./auth.env" | ConvertFrom-StringData

# Extract the API credentials and organization key from environment variables
$apiId = $envFile.API_ID
$apiSecret = $envFile.API_SECRET
$orgUrl = $envFile.ORG_URL
$orgKey = $envFile.ORG_KEY

# Construct the authentication token
$authToken = "$apiSecret/$apiId"

# Construct the current system time minus 1 hour
$currentTimeMinus1Hour = (Get-Date).AddHours(-1).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Construct the API endpoint URLs
$searchEndpointUrl = "$orgUrl/appservices/v6/orgs/$orgKey/devices/_search"
$actionEndpointUrl = "$orgUrl/appservices/v6/orgs/$orgKey/device_actions"

# Construct the request body for device search
$searchRequestBody = @{
    "criteria" = @{
        "status" = @("DEREGISTERED")
        "deployment_type" = @("VDI")
        "golden_device_status" = @("NOT_GOLDEN_DEVICE")
        "deregistered_time" = @{
            "from" = $currentTimeMinus1Hour
            "range" = "gte"
        }
    }
    "rows" = 50
    "start" = 0
    "sort" = @(
        @{
            "field" = "name"
            "order" = "asc"
        }
    )
} | ConvertTo-Json

try {
    # Invoke the API endpoint for device search with authentication and request body
    $searchResponse = Invoke-RestMethod -Uri $searchEndpointUrl -Method Post -Headers @{
        'X-Auth-Token' = $authToken
        'Content-Type' = 'application/json'
    } -Body $searchRequestBody

    # Extract the device IDs from the search response
    $deviceIds = $searchResponse.results.id

    if ($deviceIds.Count -gt 0) {
        # Construct the request body for device deletion
        $deleteRequestBody = @{
            "action_type" = "DELETE_SENSOR"
            "device_id" = $deviceIds
        } | ConvertTo-Json

        # Invoke the API endpoint for device deletion with authentication and request body
        $deleteResponse = Invoke-RestMethod -Uri $actionEndpointUrl -Method Post -Headers @{
            'X-Auth-Token' = $authToken
            'Content-Type' = 'application/json'
        } -Body $deleteRequestBody

        # Output the deletion response
        Write-Host "Deletion Response:"
        Write-Host $deleteResponse
    }
    else {
        Write-Host "No devices found matching the criteria."
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response -ne $null) {
        $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
        Write-Host "Response Content: $responseContent"
    }
}
