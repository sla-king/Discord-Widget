function Get-PokemonImage {
    $pokeId = Get-Random -Minimum 1 -Maximum 152
    $pokeImageUrl = "https://raw.githubusercontent.com/sla-king/Discord-Widget/main/assets/$pokeId.webp"
    return @{
        Id = $pokeId
        Url = $pokeImageUrl
    }
}
