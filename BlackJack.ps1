<#
    Name: BlackJack.ps1
    Date: 16 July 2024
    Crew:
        1st Lt Jim Wang
        2d Lt Ryan Thomas
        Mr. Nick Fletcher

    Description:
        1v1 the dealer in a game of BlackJack. The game will be played in the 
        console and will be text based. The game will be played with a single
        deck of cards. The player will be able to hit or stay. The dealer will
        hit until they reach 17 or higher. The player will be able to play
        multiple games in a row. The player will be able to quit at any time.
        The player will be able to see the dealer's hand at the end of the game.
#>

function get_shuffled_deck(){
    $faces = @('2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A')
    $suits = @('♠', '♣', '♦', '♥')
    $deck = @()
    
    # Build deck of cards
    foreach ($face in $faces) {
        foreach ($suit in $suits) {
            $deck += "$face$suit"
        }
    }

    return ($deck | Get-Random -Count $deck.Count )
}

function get_continue_bool {
     # TODO: Add validation for terms other than y/n
    do {
        $user_cont = Read-Host "Do you want to play another game (y/n)?"
        if ($user_cont -ne 'y' -and $user_cont -ne 'n') {
            Clear-Host
            Write-Host "Please input y/n"
        }
        elseif ($user_cont -eq 'n') {
            return $false
        } elseif ($user_cont -eq 'y') {
            return $true
        }
    } while($user_cont -ne 'y' -and $user_cont -ne 'n') {
        
    }

}

function tally_score($hand, [ref]$total) { # TODO: convert pass by value
    $total.Value = 0
    $ace_count = 0
    foreach ($card in $hand) {
        $face = $card.Substring(0, $card.Length - 1)
        # Assuming $total is an object with a Value property and $ace_count is initialized
        switch ($face) {
            {$_ -eq 'J' -or $_ -eq 'Q' -or $_ -eq 'K'} { $total.Value += 10 }
            {$_ -eq 'A'} { $ace_count += 1 }
            default { $total.Value += [int]$face }
        }
    }
    # check for aces
    for ($i = 0; $i -lt $ace_count; $i++) {
        if ($total.Value -le 10) {
            $total.Value += 11
        } else {
            $total.Value += 1
        }
    }
}

function print_hand($p_hand, $d_hand) {
    Write-Host "Player Hand: $($p_hand -join ' ')"
    Write-Host "Dealer Hand: $($dealer_hand[0]) ?"
}

# main loop
function main_game_loop(){
    $deck = get_shuffled_deck
    $player_hand = @()
    $dealer_hand = @()

    # Deal two cards to player
    $player_hand += $deck[0]
    $player_hand += $deck[1]
    $deck = $deck[2..$deck.Count]

    # Deal two cards to dealer
    $dealer_hand += $deck[0]
    $dealer_hand += $deck[1]
    $deck = $deck[2..$deck.Count]

    # Player's turn
    $player_total = 0
    do {
        print_hand $player_hand $dealer_hand
        $user_input = Read-Host "Do you want to hit or stay?"
        if ($user_input -ne 'stay') {
            if ($user_input -eq 'hit') {
                $player_hand += $deck[0]
                $deck = $deck[1..$deck.Count]
                Write-Host "Player Hand: $($player_hand -join ' ')"
                Clear-Host
            }
            else {Clear-Host; Write-Host "Please write either hit or stay"}
        }
        #else {Write-Host "Please write either hit or stay"}
        tally_score $player_hand ([ref]$player_total)
    } while (($user_input -eq 'hit') -or ($user_input -ne 'stay') -and $player_total -lt 21)

    # Dealer's turn
    $dealer_total = 0
    do {
        tally_score $dealer_hand ([ref]$dealer_total)

        if ($dealer_total -lt 17) {
            $dealer_hand += $deck[0]
            $deck = $deck[1..$deck.Count]
            tally_score $dealer_hand ([ref]$dealer_total)
        }
    } while ($dealer_total -lt 17)

    # Display dealer hand
    Write-Host "Dealer Hand: $($dealer_hand -join ' ')"

    "Player score: $player_total"
    "Dealer score: $dealer_total"
    # Determine winner
    switch ($player_total){
        {$player_total -gt 21 -and $dealer_total -gt 21}
            {Write-Host "Both bust! Push!"; return}
        {$player_total -eq 21}{Write-Host "Blackjack! Player wins!"; return}
        {$dealer_total -eq 21}{Write-Host "Blackjack! Dealer wins!"; return}
        {$player_total -gt 21}{Write-Host "Player busts! Dealer wins!"; return}
        {$dealer_total -gt 21}{Write-Host "Dealer busts! Player wins!"; return}
        {$player_total -gt $dealer_total}{Write-Host "Player wins!"; return}
        {$player_total -lt $dealer_total}{Write-Host "Dealer wins!"; return}
        default{Write-Host "It's a tie!"; return} # both bust
    }
}



function blackjack() {
    do {
        Clear-Host
        main_game_loop    
    } while (get_continue_bool)

    "Thank you for playing"
}


blackjack