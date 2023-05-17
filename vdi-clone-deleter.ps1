# Load environment variables from auth.env file
Get-Content -Path "./auth.env"

# API authentication
$authUrl = "$orgUrl/integrationServices/v3/carbonblack/auth"
$authHeaders = @{
    'Content-Type' = 'application/json'
}
$authBody = @{
    'apiKey' = $apiId
    'apiSecret' = $apiSecret
} | ConvertTo-Json

$authResponse = Invoke-RestMethod -Uri $authUrl -Method Post -Headers $authHeaders -Body $authBody

# Extract the token from the authentication response
$token = $authResponse.token

# Use the token to make subsequent API requests
$deviceUrl = "$orgUrl/integrationServices/v3/device"
$deviceHeaders = @{
    'Content-Type' = 'application/json'
    'X-Authorization' = $token
}

$deviceResponse = Invoke-RestMethod -Uri $deviceUrl -Method Get -Headers $deviceHeaders

# Display device information
$deviceResponse.devices | ForEach-Object {
    Write-Host "Device ID: $($_.deviceId), Hostname: $($_.hostname)"
}
