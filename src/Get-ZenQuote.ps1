function Get-ZenQuote {
    $validQuoteFound = $false
    $attempt = 0
    $boxes = @("", "", "")

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

    return @{
        ValidQuoteFound = $validQuoteFound
        Boxes = $boxes
    }
}
