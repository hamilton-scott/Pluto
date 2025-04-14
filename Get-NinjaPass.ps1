## useful function that I used as a test for creating a function from the password.ninja API, found here https://password.ninja/api
## minimal testing was done, there may be errors
## example usage: Get-NinjaPass; Get-NinjaPass -NumofPasswords 5; Get-NinjaPass -MinLength 14 -excludeShapes

function Get-NinjaPass {
    [CmdletBinding()]
    param (
        [int]$MinLength = 12,
        [switch]$ExcludeAnimals,
        [switch]$ExcludeInstruments,
        [switch]$ExcludeColours,
        [switch]$ExcludeShapes,
        [switch]$ExcludeFood,
        [switch]$ExcludeSports,
        [switch]$ExcludeTransport,
        [switch]$CapitalizeWords,
        [int]$LettersForNumbers = 0,
        [int]$NumAtEnd = 2,
        [int]$NumOfPasswords = 1
    )

    $baseUri = 'https://password.ninja/api/password'
    $params = @{}

    if ($MinLength -lt 8) {
        Write-Warning "Minimum length is 8. Using 8."
        $MinLength = 8
    } elseif ($MinLength -gt 20) {
        Write-Warning "Maximum length is 20. Using 20."
        $MinLength = 20
    }
    $params['minPassLength'] = $MinLength

    if (-not $ExcludeAnimals)     { $params['animals']     = 'true' }
    if (-not $ExcludeInstruments) { $params['instruments'] = 'true' }
    if (-not $ExcludeColours)     { $params['colours']     = 'true' }
    if (-not $ExcludeShapes)      { $params['shapes']      = 'true' }
    if (-not $ExcludeFood)        { $params['food']        = 'true' }
    if (-not $ExcludeSports)      { $params['sports']      = 'true' }
    if (-not $ExcludeTransport)   { $params['transport']   = 'true' }

    if ($CapitalizeWords) { $params['capitals'] = 'true' }

    if ($LettersForNumbers -ge 0 -and $LettersForNumbers -le 100) {
        $params['lettersForNumbers'] = $LettersForNumbers
    }

    if ($NumAtEnd -ge 0 -and $NumAtEnd -le 5) {
        $params['numAtEnd'] = $NumAtEnd
    }

    if ($NumOfPasswords -lt 1 -or $NumOfPasswords -gt 100) {
        Write-Warning "Password count must be 1–100. Defaulting to 1."
        $NumOfPasswords = 1
    }
    $params['numOfPasswords'] = $NumOfPasswords

    $queryString = ($params.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    $uri = $baseUri + '?' + $queryString

    try {
        $response = Invoke-WebRequest -Uri $uri -UseBasicParsing
        $passwords = ($response.Content -replace '["\[\]]', '').Split(',')
        return $passwords
    }
    catch {
        Write-Error "Failed to retrieve password(s): $_"
    }
}
