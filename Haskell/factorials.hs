fact1 :: Integer -> Integer
fact1 0 = 1
fact1 n = n * (fact1 $ n - 1)

fact2 :: Integer -> Integer
fact2 n = fact2' n 1
    where
        fact2' 0 y = y
        fact2' x y = fact2' (x - 1) $ x*y

fact3 :: Integer -> Integer
fact3 n = product [1..n]

fact4 :: Integer -> Integer
fact4 n = foldl (*) 1 [1..n]

fact5 :: Integer -> Integer
fact5 n = if n < 2 then 1 else n * fact5 (n-1)
