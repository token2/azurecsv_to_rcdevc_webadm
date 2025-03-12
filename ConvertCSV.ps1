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


# Function to decode Base32 string to byte array

function Convert-Base32ToBytes($base32String) {

    $base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'

    $base32String = $base32String.ToUpper().Trim()


    # Remove any padding characters (Base32 uses '=' padding)

    $base32String = $base32String.TrimEnd('=')


    $byteArray = New-Object 'System.Collections.Generic.List[Byte]'

    $buffer = 0

    $bitsLeft = 0


    # Process each character in the Base32 string

    foreach ($char in $base32String.ToCharArray()) {

        $value = [Array]::IndexOf($base32Chars.ToCharArray(), $char)

        $buffer = ($buffer -shl 5) -bor $value

        $bitsLeft += 5


        if ($bitsLeft -ge 8) {

            $bitsLeft -= 8

            $byteArray.Add([byte](($buffer -shr $bitsLeft) -band 0xFF))

            $buffer = $buffer -band ((1 -shl $bitsLeft) - 1)

        }

    }


    return $byteArray.ToArray()

}


# Function to decode Base32 and encode to Base64

function Convert-Base32ToBase64($base32String) {

    $base32Bytes = Convert-Base32ToBytes -base32String $base32String

    return [System.Convert]::ToBase64String($base32Bytes)

}


# Process each row in the source data

foreach ($row in $sourceData) {

    $serialNumber = $row.'serial number'

    $tokenSecret = $row.'secret key'

    $timeInterval = $row.'time interval'

    $model = $row.'model'


    # Convert the token secret from Base32 to Base64

    $base64TokenSecret = Convert-Base32ToBase64 -base32String $tokenSecret


    # Base64 encode required fields

    $tokenKey = $base64TokenSecret

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
