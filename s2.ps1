$fib_0 = 0
$fib_1 = 1
while ($fib_1 -lt 100){ #technical debt
    $fib_0
    $fib_1
    $fib_0 = $fib_0 + $fib_1
    $fib_1 = $fib_0 + $fib_1
}

