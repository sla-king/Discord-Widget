$functionsToImport = Get-ChildItem -Path "$PSScriptRoot\src\*.ps1"
foreach ($import in $functionsToImport) {
    . $import.FullName
}

$progressValue = Get-YearProgress
$quoteResult = Get-ZenQuote
$pokemonResult = Get-PokemonImage

Write-Output "Sending Progress: $progressValue"
Write-Output "Sending Pokemon ID: $($pokemonResult.Id)"

if ($quoteResult.ValidQuoteFound) {
    Write-Output "Line 1: $($quoteResult.Boxes[0])"
    Write-Output "Line 2: $($quoteResult.Boxes[1])"
    Write-Output "Line 3: $($quoteResult.Boxes[2])"
} else {
    Write-Output "No suitable quote found after 10 attempts. Skipping quote update."
}

Update-DiscordProfile -ProgressValue $progressValue -PokeImageUrl $pokemonResult.Url -Boxes $quoteResult.Boxes