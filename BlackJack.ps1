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
        $user_cont = Read-Host "Do you want to play another game (y/n)?. Remember, 99% of gamblers quit right before they hit the jackpot."
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
        {$player_total -gt 21 -and $dealer_total -gt 21}{Write-Host "                                                               
                                                                           
PPPPPPPPPPPPPPPPP                                     hhhhhhh              
P::::::::::::::::P                                    h:::::h              
P::::::PPPPPP:::::P                                   h:::::h              
PP:::::P     P:::::P                                  h:::::h              
  P::::P     P:::::Puuuuuu    uuuuuu      ssssssssss   h::::h hhhhh        
  P::::P     P:::::Pu::::u    u::::u    ss::::::::::s  h::::hh:::::hhh     
  P::::PPPPPP:::::P u::::u    u::::u  ss:::::::::::::s h::::::::::::::hh   
  P:::::::::::::PP  u::::u    u::::u  s::::::ssss:::::sh:::::::hhh::::::h  
  P::::PPPPPPPPP    u::::u    u::::u   s:::::s  ssssss h::::::h   h::::::h 
  P::::P            u::::u    u::::u     s::::::s      h:::::h     h:::::h 
  P::::P            u::::u    u::::u        s::::::s   h:::::h     h:::::h 
  P::::P            u:::::uuuu:::::u  ssssss   s:::::s h:::::h     h:::::h 
PP::::::PP          u:::::::::::::::uus:::::ssss::::::sh:::::h     h:::::h 
P::::::::P           u:::::::::::::::us::::::::::::::s h:::::h     h:::::h 
P::::::::P            uu::::::::uu:::u s:::::::::::ss  h:::::h     h:::::h 
PPPPPPPPPP              uuuuuuuu  uuuu  sssssssssss    hhhhhhh     hhhhhhh         
                                        
"}
        {$player_total -gt 21 -and $dealer_total -gt 21}{Write-Host "Both bust! Push!"; return} 
        {$player_total -eq 21}{Write-Host "                                                                                                         
                                                                                                                                   
YYYYYYY       YYYYYYY                                     WWWWWWWW                           WWWWWWWW iiii                    !!!  
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::Wi::::i                  !!:!! 
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::W iiii                   !:::! 
Y::::::Y     Y::::::Y                                     W::::::W                           W::::::W                        !:::! 
YYY:::::Y   Y:::::YYYooooooooooo   uuuuuu    uuuuuu        W:::::W           WWWWW           W:::::Wiiiiiiinnnn  nnnnnnnn    !:::! 
   Y:::::Y Y:::::Y oo:::::::::::oo u::::u    u::::u         W:::::W         W:::::W         W:::::W i:::::in:::nn::::::::nn  !:::! 
    Y:::::Y:::::Y o:::::::::::::::ou::::u    u::::u          W:::::W       W:::::::W       W:::::W   i::::in::::::::::::::nn !:::! 
     Y:::::::::Y  o:::::ooooo:::::ou::::u    u::::u           W:::::W     W:::::::::W     W:::::W    i::::inn:::::::::::::::n!:::! 
      Y:::::::Y   o::::o     o::::ou::::u    u::::u            W:::::W   W:::::W:::::W   W:::::W     i::::i  n:::::nnnn:::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u             W:::::W W:::::W W:::::W W:::::W      i::::i  n::::n    n::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u              W:::::W:::::W   W:::::W:::::W       i::::i  n::::n    n::::n!!:!! 
       Y:::::Y    o::::o     o::::ou:::::uuuu:::::u               W:::::::::W     W:::::::::W        i::::i  n::::n    n::::n !!!  
       Y:::::Y    o:::::ooooo:::::ou:::::::::::::::uu              W:::::::W       W:::::::W        i::::::i n::::n    n::::n      
    YYYY:::::YYYY o:::::::::::::::o u:::::::::::::::u               W:::::W         W:::::W         i::::::i n::::n    n::::n !!!  
    Y:::::::::::Y  oo:::::::::::oo   uu::::::::uu:::u                W:::W           W:::W          i::::::i n::::n    n::::n!!:!! 
    YYYYYYYYYYYYY    ooooooooooo       uuuuuuuu  uuuu                 WWW             WWW           iiiiiiii nnnnnn    nnnnnn !!!  
                                                                                                                                                                                                                                                      
"} 
        {$player_total -eq 21}{Write-Host "Blackjack! Player wins!"; return} 
        {$dealer_total -eq 21}{Write-Host " 
                                                                                                                                                                                               
LLLLLLLLLLL                  OOOOOOOOO        SSSSSSSSSSSSSSS EEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR    
L:::::::::L                OO:::::::::OO    SS:::::::::::::::SE::::::::::::::::::::ER::::::::::::::::R   
L:::::::::L              OO:::::::::::::OO S:::::SSSSSS::::::SE::::::::::::::::::::ER::::::RRRRRR:::::R  
LL:::::::LL             O:::::::OOO:::::::OS:::::S     SSSSSSSEE::::::EEEEEEEEE::::ERR:::::R     R:::::R 
  L:::::L               O::::::O   O::::::OS:::::S              E:::::E       EEEEEE  R::::R     R:::::R 
  L:::::L               O:::::O     O:::::OS:::::S              E:::::E               R::::R     R:::::R 
  L:::::L               O:::::O     O:::::O S::::SSSS           E::::::EEEEEEEEEE     R::::RRRRRR:::::R  
  L:::::L               O:::::O     O:::::O  SS::::::SSSSS      E:::::::::::::::E     R:::::::::::::RR   
  L:::::L               O:::::O     O:::::O    SSS::::::::SS    E:::::::::::::::E     R::::RRRRRR:::::R  
  L:::::L               O:::::O     O:::::O       SSSSSS::::S   E::::::EEEEEEEEEE     R::::R     R:::::R 
  L:::::L               O:::::O     O:::::O            S:::::S  E:::::E               R::::R     R:::::R 
  L:::::L         LLLLLLO::::::O   O::::::O            S:::::S  E:::::E       EEEEEE  R::::R     R:::::R 
LL:::::::LLLLLLLLL:::::LO:::::::OOO:::::::OSSSSSSS     S:::::SEE::::::EEEEEEEE:::::ERR:::::R     R:::::R 
L::::::::::::::::::::::L OO:::::::::::::OO S::::::SSSSSS:::::SE::::::::::::::::::::ER::::::R     R:::::R 
L::::::::::::::::::::::L   OO:::::::::OO   S:::::::::::::::SS E::::::::::::::::::::ER::::::R     R:::::R 
LLLLLLLLLLLLLLLLLLLLLLLL     OOOOOOOOO      SSSSSSSSSSSSSSS   EEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRR                                                                                           
                                                                                                         
 "} 
        {$dealer_total -eq 21}{Write-Host "Blackjack! Dealer wins!"; return} 
        {$player_total -gt 21}{Write-Host "                                                                      
                                                                                    
BBBBBBBBBBBBBBBBB   UUUUUUUU     UUUUUUUU   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTT 
B::::::::::::::::B  U::::::U     U::::::U SS:::::::::::::::ST:::::::::::::::::::::T 
B::::::BBBBBB:::::B U::::::U     U::::::US:::::SSSSSS::::::ST:::::::::::::::::::::T 
BB:::::B     B:::::BUU:::::U     U:::::UUS:::::S     SSSSSSST:::::TT:::::::TT:::::T 
  B::::B     B:::::B U:::::U     U:::::U S:::::S            TTTTTT  T:::::T  TTTTTT 
  B::::B     B:::::B U:::::D     D:::::U S:::::S                    T:::::T         
  B::::BBBBBB:::::B  U:::::D     D:::::U  S::::SSSS                 T:::::T         
  B:::::::::::::BB   U:::::D     D:::::U   SS::::::SSSSS            T:::::T         
  B::::BBBBBB:::::B  U:::::D     D:::::U     SSS::::::::SS          T:::::T         
  B::::B     B:::::B U:::::D     D:::::U        SSSSSS::::S         T:::::T         
  B::::B     B:::::B U:::::D     D:::::U             S:::::S        T:::::T         
  B::::B     B:::::B U::::::U   U::::::U             S:::::S        T:::::T         
BB:::::BBBBBB::::::B U:::::::UUU:::::::U SSSSSSS     S:::::S      TT:::::::TT       
B:::::::::::::::::B   UU:::::::::::::UU  S::::::SSSSSS:::::S      T:::::::::T       
B::::::::::::::::B      UU:::::::::UU    S:::::::::::::::SS       T:::::::::T       
BBBBBBBBBBBBBBBBB         UUUUUUUUU       SSSSSSSSSSSSSSS         TTTTTTTTTTT       
                                                                                                                                                           
 "} 
        {$player_total -gt 21}{Write-Host "Player busts! Dealer wins!"; return} 
        {$dealer_total -gt 21}{Write-Host " 
                                                                                                                                                                                                                                                  
YYYYYYY       YYYYYYY                                     WWWWWWWW                           WWWWWWWW iiii                    !!!  
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::Wi::::i                  !!:!! 
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::W iiii                   !:::! 
Y::::::Y     Y::::::Y                                     W::::::W                           W::::::W                        !:::! 
YYY:::::Y   Y:::::YYYooooooooooo   uuuuuu    uuuuuu        W:::::W           WWWWW           W:::::Wiiiiiiinnnn  nnnnnnnn    !:::! 
   Y:::::Y Y:::::Y oo:::::::::::oo u::::u    u::::u         W:::::W         W:::::W         W:::::W i:::::in:::nn::::::::nn  !:::! 
    Y:::::Y:::::Y o:::::::::::::::ou::::u    u::::u          W:::::W       W:::::::W       W:::::W   i::::in::::::::::::::nn !:::! 
     Y:::::::::Y  o:::::ooooo:::::ou::::u    u::::u           W:::::W     W:::::::::W     W:::::W    i::::inn:::::::::::::::n!:::! 
      Y:::::::Y   o::::o     o::::ou::::u    u::::u            W:::::W   W:::::W:::::W   W:::::W     i::::i  n:::::nnnn:::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u             W:::::W W:::::W W:::::W W:::::W      i::::i  n::::n    n::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u              W:::::W:::::W   W:::::W:::::W       i::::i  n::::n    n::::n!!:!! 
       Y:::::Y    o::::o     o::::ou:::::uuuu:::::u               W:::::::::W     W:::::::::W        i::::i  n::::n    n::::n !!!  
       Y:::::Y    o:::::ooooo:::::ou:::::::::::::::uu              W:::::::W       W:::::::W        i::::::i n::::n    n::::n      
    YYYY:::::YYYY o:::::::::::::::o u:::::::::::::::u               W:::::W         W:::::W         i::::::i n::::n    n::::n !!!  
    Y:::::::::::Y  oo:::::::::::oo   uu::::::::uu:::u                W:::W           W:::W          i::::::i n::::n    n::::n!!:!! 
    YYYYYYYYYYYYY    ooooooooooo       uuuuuuuu  uuuu                 WWW             WWW           iiiiiiii nnnnnn    nnnnnn !!!  

"} 
        {$dealer_total -gt 21}{Write-Host "Dealer busts! Player wins!"; return} 
        {$player_total -gt $dealer_total}{Write-Host " 

YYYYYYY       YYYYYYY                                     WWWWWWWW                           WWWWWWWW iiii                    !!!  
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::Wi::::i                  !!:!! 
Y:::::Y       Y:::::Y                                     W::::::W                           W::::::W iiii                   !:::! 
Y::::::Y     Y::::::Y                                     W::::::W                           W::::::W                        !:::! 
YYY:::::Y   Y:::::YYYooooooooooo   uuuuuu    uuuuuu        W:::::W           WWWWW           W:::::Wiiiiiiinnnn  nnnnnnnn    !:::! 
   Y:::::Y Y:::::Y oo:::::::::::oo u::::u    u::::u         W:::::W         W:::::W         W:::::W i:::::in:::nn::::::::nn  !:::! 
    Y:::::Y:::::Y o:::::::::::::::ou::::u    u::::u          W:::::W       W:::::::W       W:::::W   i::::in::::::::::::::nn !:::! 
     Y:::::::::Y  o:::::ooooo:::::ou::::u    u::::u           W:::::W     W:::::::::W     W:::::W    i::::inn:::::::::::::::n!:::! 
      Y:::::::Y   o::::o     o::::ou::::u    u::::u            W:::::W   W:::::W:::::W   W:::::W     i::::i  n:::::nnnn:::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u             W:::::W W:::::W W:::::W W:::::W      i::::i  n::::n    n::::n!:::! 
       Y:::::Y    o::::o     o::::ou::::u    u::::u              W:::::W:::::W   W:::::W:::::W       i::::i  n::::n    n::::n!!:!! 
       Y:::::Y    o::::o     o::::ou:::::uuuu:::::u               W:::::::::W     W:::::::::W        i::::i  n::::n    n::::n !!!  
       Y:::::Y    o:::::ooooo:::::ou:::::::::::::::uu              W:::::::W       W:::::::W        i::::::i n::::n    n::::n      
    YYYY:::::YYYY o:::::::::::::::o u:::::::::::::::u               W:::::W         W:::::W         i::::::i n::::n    n::::n !!!  
    Y:::::::::::Y  oo:::::::::::oo   uu::::::::uu:::u                W:::W           W:::W          i::::::i n::::n    n::::n!!:!! 
    YYYYYYYYYYYYY    ooooooooooo       uuuuuuuu  uuuu                 WWW             WWW           iiiiiiii nnnnnn    nnnnnn !!!                                                                                                                        
                                                                                                                                
"} 
        {$player_total -gt $dealer_total}{Write-Host "Player wins!"; return} 
        {$player_total -lt $dealer_total}{Write-Host "                                                                                             
                                                                                                         
LLLLLLLLLLL                  OOOOOOOOO        SSSSSSSSSSSSSSS EEEEEEEEEEEEEEEEEEEEEERRRRRRRRRRRRRRRRR    
L:::::::::L                OO:::::::::OO    SS:::::::::::::::SE::::::::::::::::::::ER::::::::::::::::R   
L:::::::::L              OO:::::::::::::OO S:::::SSSSSS::::::SE::::::::::::::::::::ER::::::RRRRRR:::::R  
LL:::::::LL             O:::::::OOO:::::::OS:::::S     SSSSSSSEE::::::EEEEEEEEE::::ERR:::::R     R:::::R 
  L:::::L               O::::::O   O::::::OS:::::S              E:::::E       EEEEEE  R::::R     R:::::R 
  L:::::L               O:::::O     O:::::OS:::::S              E:::::E               R::::R     R:::::R 
  L:::::L               O:::::O     O:::::O S::::SSSS           E::::::EEEEEEEEEE     R::::RRRRRR:::::R  
  L:::::L               O:::::O     O:::::O  SS::::::SSSSS      E:::::::::::::::E     R:::::::::::::RR   
  L:::::L               O:::::O     O:::::O    SSS::::::::SS    E:::::::::::::::E     R::::RRRRRR:::::R  
  L:::::L               O:::::O     O:::::O       SSSSSS::::S   E::::::EEEEEEEEEE     R::::R     R:::::R 
  L:::::L               O:::::O     O:::::O            S:::::S  E:::::E               R::::R     R:::::R 
  L:::::L         LLLLLLO::::::O   O::::::O            S:::::S  E:::::E       EEEEEE  R::::R     R:::::R 
LL:::::::LLLLLLLLL:::::LO:::::::OOO:::::::OSSSSSSS     S:::::SEE::::::EEEEEEEE:::::ERR:::::R     R:::::R 
L::::::::::::::::::::::L OO:::::::::::::OO S::::::SSSSSS:::::SE::::::::::::::::::::ER::::::R     R:::::R 
L::::::::::::::::::::::L   OO:::::::::OO   S:::::::::::::::SS E::::::::::::::::::::ER::::::R     R:::::R 
LLLLLLLLLLLLLLLLLLLLLLLL     OOOOOOOOO      SSSSSSSSSSSSSSS   EEEEEEEEEEEEEEEEEEEEEERRRRRRRR     RRRRRRR
                                                                                                 
 "} 
        {$player_total -lt $dealer_total}{Write-Host "Dealer wins!"; return} 
        default{Write-Host "It's a tie!"; return} # both bust; thing nick mentioned 

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