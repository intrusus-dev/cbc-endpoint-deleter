<#
.SYNOPSIS
    Deregistered Endpoint Deletion Script
.DESCRIPTION
    This script is used to delete deregistered endpoints in the VMware Carbon Black Cloud environment that have been unregistered for more than 5 minutes.

    Author: Leon Schulze
    GitHub: github.com/intrusus-dev

    Copyright (c) 2023. All rights reserved.

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

# Calculate the deregistered time threshold
$deregisteredTimeThreshold = (Get-Date).AddMinutes(-5).ToString("yyyy-MM-ddTHH:mm:ssZ")

# Construct the API endpoint URL for device search
$searchEndpointUrl = "$orgUrl/appservices/v6/orgs/$orgKey/devices/_search"

# Construct the request body for device search
$searchRequestBody = @{
    "criteria" = @{
        "status" = @("DEREGISTERED")
        "unregistered_time" = @{
            "from" = $deregisteredTimeThreshold
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

    # Extract the device IDs and deregistered times from the search response
    $devices = $searchResponse.results | Select-Object -Property id, deregistered_time

     if ($devices.Count -gt 0) {
        # Output the deregistered endpoints and their deregistered times
        Write-Host "Deregistered Endpoints:"
        $devices | ForEach-Object {
            Write-Host "Device ID: $($_.id)"
            Write-Host "Deregistered Time: $($_.deregistered_time)"
            Write-Host "------------------------"
        }

        # Construct the API endpoint URL for device deletion
        $deleteEndpointUrl = "$orgUrl/appservices/v6/orgs/$orgKey/device_actions"

        # Construct the request body for device deletion
        $deleteRequestBody = @{
            "action_type" = "DELETE_SENSOR"
            "device_id" = $devices.id
        } | ConvertTo-Json

        # Invoke the API endpoint for device deletion with authentication and request body
        $deleteResponse = Invoke-RestMethod -Uri $deleteEndpointUrl -Method Post -Headers @{
            'X-Auth-Token' = $authToken
            'Content-Type' = 'application/json'
        } -Body $deleteRequestBody

        # Output the deletion response
        Write-Host "Deletion Response:"
        Write-Host $deleteResponse
     }
     else {
         Write-Host "No deregistered endpoints found that meet the criteria."
     }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    if ($_.Exception.Response -ne $null) {
        $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
        Write-Host "Response Content: $responseContent"
    }
}