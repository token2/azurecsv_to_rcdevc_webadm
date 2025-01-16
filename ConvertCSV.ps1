param(
    [string]$sourceCSV,  # Source CSV file path
    [string]$targetCSV   # Target CSV file path
)

# Check if source file exists
if (-not (Test-Path $sourceCSV)) {
    Write-Host "Source CSV file does not exist: $sourceCSV"
    exit
}

# Create the header for the target CSV
$header = "Type, Reference, Description, Data"
 

# Initialize the output array
$output = @()

# Import the source CSV
$sourceData = Import-Csv -Path $sourceCSV

# Process each row in the source data
foreach ($row in $sourceData) {
    $serialNumber = $row.'serial number'
    $tokenSecret = $row.'secret key'
    $timeInterval = $row.'time interval'
    $model = $row.'model'

    # Base64 encode required fields
    $tokenKey = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($tokenSecret))
    $tokenType = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("TOTP"))
    $tokenState = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("0"))
    $otpLength = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("6"))
    $totpTimeStep = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($timeInterval))

    # Build the Data field for the target CSV
    $dataField = "TokenKey=$tokenKey,TokenType=$tokenType,TokenState=$tokenState,OTPLength=$otpLength,TOTPTimeStep=$totpTimeStep"

    # Create the output row
    $outputRow = New-Object PSObject -property @{
        Type = "OTP Token"
        Reference = $serialNumber
        Description = $model
        Data = $dataField
		
    }
 
    # Add the row to the output
    $output += $outputRow
}

# Write the output to the target CSV
$header | Out-File -FilePath $targetCSV -Encoding ASCII
$output | Export-Csv -Path $targetCSV -Append -NoTypeInformation -Encoding ASCII

Write-Host "CSV conversion completed successfully. Output saved to $targetCSV"
