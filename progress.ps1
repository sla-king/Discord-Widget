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

$bodyObj = @{
    data = @{
        dynamic = @(
            @{
                type  = 2
                name  = "progress"
                value = $progressValue
            }
        )
    }
}
$jsonBody = $bodyObj | ConvertTo-Json -Depth 5 -Compress

$appId    = $env:DISCORD_APP_ID
$userId   = $env:DISCORD_USER_ID
$botToken = $env:DISCORD_BOT_TOKEN

Invoke-RestMethod `
    -Uri "https://discord.com/api/v9/applications/$appId/users/$userId/identities/0/profile" `
    -Method PATCH `
    -Headers @{
        "Content-Type"  = "application/json"
        "Authorization" = "Bot $botToken"
        "User-Agent"    = "DiscordBot (https://github.com/discord/discord-api-docs, 1.0.0)"
    } `
    -Body $jsonBody