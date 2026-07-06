function Get-YearProgress {
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

    return $progressValue
}
