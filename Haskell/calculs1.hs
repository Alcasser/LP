sumMultiples35 :: Integer -> Integer
sumMultiples35 n = sum $ [3 * i | i <- [1..(div n 3) - 1]] ++ [5 * i | i <- [1..(div n 5) - 1] ]

fibonacci :: Int -> Integer
fibonacci n = snd $ fib n

fib :: Int -> (Integer, Integer)
fib 0 = (0, 0)
fib 1 = (0, 1)
fib n = (fn1, fn2 + fn1)
    where
        (fn2, fn1) = fib (n - 1)

fibolist :: [Integer]
fibolist = 0 : scanl (+) 1 fibolist

sumEvenFibonaccis :: Integer -> Integer
sumEvenFibonaccis n = sum $ filter even $ takeWhile (< n) fibolist

isPalindromic :: Integer -> Bool
isPalindromic n = (show n) == (reverse $ show n)
