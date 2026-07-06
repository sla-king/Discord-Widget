function Get-PokemonImage {
    $pokeId = Get-Random -Minimum 1 -Maximum 1026
    $pokeImageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$pokeId.png"
    return @{
        Id = $pokeId
        Url = $pokeImageUrl
    }
}
