#hw1

$num = 0 #q1
$foo = "bar" #q2
$usr_arry = @() #q3

$usr_arry += "one" #q4
$usr_arry += "two"
$usr_arry += "three"
$usr_arry += "four"
$usr_arry += "five"

$usr_arry += $foo #q5

$int_arry = 1..10 #q6

$int_arry += $num #q7

$bool_val = $false #q8

$num_as_str = [string]$num

$usr_arry +=  $num_as_str #q9

$a, $b, $c, $d = 1, 2, 3, 4 #q11

$a + $b
$b - $c
$c * $d
$d / $a
$a % $b

$a+$b -gt $b-$c
$a+$b -ge $b-$c
$a+$b -lt $b-$c
$a+$b -le $b-$c
$a+$b -eq $b-$c
$a+$b -ne $b-$c



$a+$b -gt $b-$c -and $a+$b -ge $b-$c
$a+$b -lt $b-$c -or $a+$b -le $b-$c
$a+$b -lt $b-$c -xor $a+$b -le $b-$c
-not( $a+$b -lt $b-$c)