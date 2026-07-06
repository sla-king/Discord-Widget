$today = Get-Date

if ($today.Month -eq 12 -and $today.Day -ge 30) {
    $cycleStart = [datetime]"$($today.Year)-12-30"
    $cycleEnd   = [datetime]"$($today.Year + 1)-12-29"
} else {
    $cycleStart = [datetime]"$($today.Year - 1)-12-30"
    $cycleEnd   = [datetime]"$($today.Year)-12-29"
}

$totalDays  = ($cycleEnd - $cycleStart).TotalDays
$daysPassed = ($today - $cycleStart).TotalDays

$rawPercentString = "$(($daysPassed / $totalDays) * 100)"
$wholePercentString = $rawPercentString -replace '\..*'
$progressValue = [double]$wholePercentString / 100

if ($progressValue -lt 0.0) { $progressValue = 0.0 }
if ($progressValue -gt 1.0) { $progressValue = 1.0 }

$validQuoteFound = $false
$attempt = 0

while (-not $validQuoteFound -and $attempt -lt 10) {
    $attempt++
    $quoteResponse = Invoke-RestMethod -Uri "https://zenquotes.io/api/random" -Method Get
    $fullQuote = "$($quoteResponse[0].q) - $($quoteResponse[0].a)"

    $visualLines = @("", "", "", "", "", "")
    $lineIndex = 0
    $words = $fullQuote -split ' '
    $exceedsLimit = $false

    foreach ($word in $words) {
        if ($lineIndex -ge 6) { 
            $exceedsLimit = $true
            break 
        }
        
        $currentLen = $visualLines[$lineIndex].Length
        $wordLen = $word.Length
        $projectedLen = if ($currentLen -eq 0) { $wordLen } else { $currentLen + 1 + $wordLen }
        
        if ($projectedLen -le 30) {
            if ($currentLen -eq 0) {
                $visualLines[$lineIndex] = $word
            } else {
                $visualLines[$lineIndex] += " $word"
            }
        } else {
            $lineIndex++
            if ($lineIndex -ge 6) {
                $exceedsLimit = $true
                break
            }
            $visualLines[$lineIndex] = $word
        }
    }

    if (-not $exceedsLimit) {
        $validQuoteFound = $true
    } elseif ($attempt -lt 10) {
        Start-Sleep -Seconds 1
    }
}

$boxes = @("", "", "")

if ($validQuoteFound) {
    for ($i = 0; $i -lt 3; $i++) {
        $l1 = $visualLines[$i * 2]
        $l2 = $visualLines[$i * 2 + 1]
        
        if ($l1 -ne "" -and $l2 -ne "") {
            $boxes[$i] = "$l1 $l2"
        } elseif ($l1 -ne "") {
            $boxes[$i] = $l1
        }
    }
}

$pokeId = Get-Random -Minimum 1 -Maximum 1026
$pokeImageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$pokeId.png"

$dynamicData = @(
    @{ type = 2; name = "progress"; value = $progressValue },
    @{ type = 3; name = "pokemon_image"; value = @{ url = $pokeImageUrl } }
)

if ($boxes[0] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_1"; value = $boxes[0] } }
if ($boxes[1] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_2"; value = $boxes[1] } }
if ($boxes[2] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_3"; value = $boxes[2] } }

$bodyObj = @{
    data = @{
        dynamic = $dynamicData
    }
}

$jsonBody = $bodyObj | ConvertTo-Json -Depth 5 -Compress

Write-Output "Sending Progress: $progressValue"
Write-Output "Sending Pokemon ID: $pokeId"

if ($validQuoteFound) {
    Write-Output "Line 1: $($boxes[0])"
    Write-Output "Line 2: $($boxes[1])"
    Write-Output "Line 3: $($boxes[2])"
} else {
    Write-Output "No suitable quote found after 10 attempts. Skipping quote update."
}

$appId    = $env:DISCORD_APP_ID
$userId   = $env:DISCORD_USER_ID
$botToken = $env:DISCORD_BOT_TOKEN

try {
    Invoke-RestMethod `
        -Uri "https://discord.com/api/v9/applications/$appId/users/$userId/identities/0/profile" `
        -Method PATCH `
        -Headers @{
            "Content-Type"  = "application/json"
            "Authorization" = "Bot $botToken"
            "User-Agent"    = "DiscordBot (https://github.com/discord/discord-api-docs, 1.0.0)"
        } `
        -Body $jsonBody
        
    Write-Output "Success! Profile updated."
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $errorMessage = $reader.ReadToEnd()
    
    Write-Output "--- ERROR DETAILS FROM DISCORD ---"
    Write-Output $errorMessage
}