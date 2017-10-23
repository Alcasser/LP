-- 1)
absValue :: Int -> Int
absValue x
    | x > 0 = x
    | otherwise = -x

-- 2)
power :: Int -> Int -> Int
power x p
    | p == 0 = 1
    | even p = pow * pow
    | otherwise = x * pow * pow
        where
            pow = power x (div p 2)

-- 3)
isPrime :: Int -> Bool
isPrime 0 = False
isPrime 1 = False
isPrime n = not (hasDivisors n 2)
    where
        hasDivisors :: Int -> Int -> Bool
        hasDivisors n c 
            | c * c > n     = False
            | mod n c == 0  = True
            | otherwise     = hasDivisors n (c + 1)

-- 4)
slowFib :: Int -> Int
slowFib 0 = 0
slowFib 1 = 1
slowFib n = slowFib (n - 1) + slowFib (n - 2)

-- 5)
quickFib :: Int -> Int
quickFib n = snd (quickFib' n)
    where
        quickFib' :: Int -> (Int, Int)
        quickFib' 0 = (0, 0)
        quickFib' 1 = (0, 1)
        quickFib' n = (fn1, fn1+fn2)
            where (fn2,fn1) = quickFib' (n-1)
