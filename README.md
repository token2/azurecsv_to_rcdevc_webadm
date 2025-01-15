
# CSV Conversion Script for RCDevs WebADM

## Overview
This PowerShell script is designed to convert an Azure-compatible CSV containing token information into a target CSV format suitable for RCDevs WebADM. The script processes the source file and generates the required target file with fields such as `Type`, `Reference`, `Description`, and `Data`.

## Source CSV Format
The source CSV should have the following columns:
- `upn`: The user principal name (email address) associated with the token.
- `serial number`: The serial number of the token.
- `secret key`: The secret key (in hexadecimal format) for the token.
- `timeinterval`: The time step (in seconds) for TOTP tokens, usually 30.
- `manufacturer`: The manufacturer of the token (e.g., Token2).
- `model`: The model of the token (e.g., `c202`).

Example of source CSV:
```csv
upn,serial number,secret key,time interval,manufacturer,model
gulnara@token2.onmicrosoft.com,60234567,1234567890abcdef1234567890abcdef,30,Token2,c202
```

## Target CSV Format
The target CSV format is designed for RCDevs WebADM. The output file will have the following structure:

### Header
```text
# CSV import file for RCDevs WebADM
# Generated on <Current Date and Time>
```

### Data Fields
- `Type`: Always "OTP Token".
- `Reference`: Token serial number.
- `Description`: Token model.
- `Data`: A comma-separated list of the following fields (Base64 encoded):
  - `TokenKey`: The token secret key.
  - `TokenType`: The type of token (TOTP by default).
  - `TokenState`: A value representing the state (default `0`).
  - `OTPLength`: The OTP length (default `6`).
  - `TOTPTimeStep`: The time step in seconds for TOTP (Base64 encoded).

Example of target CSV:
```csv
Type,Reference,Description,Data
"OTP Token", "60234567", "c202", "TokenKey=1234567890abcdef1234567890abcdef,TokenType=VE9UUA==,TokenState=MA==,OTPLength=Ng==,TOTPTimeStep=MzA="
```

## Script Details

### Script Steps:
1. **Arguments for CSV Paths**:
   The script now accepts two arguments: 
   - `$sourceCSV`: The path to the source CSV file.
   - `$targetCSV`: The path to the target CSV file.

2. **Header Creation**:
   The script generates a header for the target CSV file, including a timestamp indicating when the file was generated.

3. **Data Transformation**:
   Each row of the source CSV is processed to generate the target data:
   - The `secret key` is used as the `TokenKey`.
   - The `TokenType` is hardcoded as `TOTP` (Base64 encoded value `VE9UUA==`).
   - The `TokenState` is set to `0` (Base64 encoded value `MA==`).
   - The `OTPLength` is set to `6` (Base64 encoded value `Ng==`).
   - The `TOTPTimeStep` is the `timeinterval` value from the source, Base64 encoded.

4. **CSV Creation**:
   The processed rows are written to the target CSV file.

### Example Output
After running the script, the target CSV will be formatted as shown in the example above, and will be saved to the specified path.

## How to Use the Script
1. Save the PowerShell script as `ConvertCSV.ps1`.
2. Open PowerShell and run the script with arguments for the source and target CSV file paths:
   ```powershell
   .\ConvertCSV.ps1 -sourceCSV "C:\path	o\source.csv" -targetCSV "C:\path	o	arget.csv"
   ```
3. The converted CSV will be saved at the location specified in `$targetCSV`.

## Notes
- The script assumes the `timeinterval` for TOTP is 30 seconds by default.
- The `TokenState`, `OTPLength`, and `TOTPTimeStep` values are hardcoded for simplicity but can be modified if needed.

## Requirements
- PowerShell 5.0 or higher.
- The source CSV must be in the correct format as described above.

## License
This script is provided as-is, with no warranty. Use it at your own risk.
