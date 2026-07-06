function Update-DiscordProfile {
    param (
        [double]$ProgressValue,
        [string]$PokeImageUrl,
        [string[]]$Boxes
    )

    $dynamicData = @(
        @{ type = 2; name = "progress"; value = $ProgressValue },
        @{ type = 3; name = "pokemon_image"; value = @{ url = $PokeImageUrl } }
    )

    if ($Boxes[0] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_1"; value = $Boxes[0] } }
    if ($Boxes[1] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_2"; value = $Boxes[1] } }
    if ($Boxes[2] -ne "") { $dynamicData += @{ type = 1; name = "quote_line_3"; value = $Boxes[2] } }

    $bodyObj = @{
        data = @{
            dynamic = $dynamicData
        }
    }

    $jsonBody = $bodyObj | ConvertTo-Json -Depth 5 -Compress

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
}
