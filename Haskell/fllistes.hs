-- 1)
myLength :: [Int] -> Int
myLength [] = 0
myLength (_ : xs) = 1 + myLength xs

-- 2)
myMaximum :: [Int] -> Int
myMaximum [x] = x
myMaximum (x : xs) 
    | x > m     = x
    | otherwise = m
        where
            m = myMaximum xs

-- 3)

average :: [Int] -> Float
average (x : xs) = fromIntegral(sum xs + x) / fromIntegral(myLength (x : xs))
    where
        sum :: [Int] -> Int
        sum [] = 0
        sum (x : xs) = sum xs + x

-- 4)

buildPalindrome :: [Int] -> [Int]
buildPalindrome [] = []
buildPalindrome (x : xs) = rev xs ++ [x] ++ (x : xs)
        where
            rev :: [Int] -> [Int]
            rev [] = []
            rev (x : xs) = rev xs ++ [x]

-- 5)

remove :: [Int] -> [Int] -> [Int]
remove [] [] = []
remove [] (x : xs) = []
remove (x : xs) [] = x : xs
remove (x : xs) y
    | isin y x  = remove xs y
    | otherwise = x : remove xs y
            where
                isin :: [Int] -> Int -> Bool
                isin [] x   = False
                isin (y : ys) x
                    | y == x    = True
                    | otherwise = isin ys x

-- 6)

flatten :: [[Int]] -> [Int]
flatten [] = []
flatten (x : xs) = x ++ flatten xs

-- 7)

oddsNevens :: [Int] -> ([Int],[Int])
oddsNevens [] = ([], [])
oddsNevens (x : xs)
    | xs == [] && even x = ([], [x])
    | xs == [] = ([x], []) 
    | even x  =  (fst neod, x : snd neod)
    | otherwise = (x : fst neod, snd neod)
                where
                    neod = oddsNevens xs


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

-- 8)
primeDivisors :: Int -> [Int]
primeDivisors n
    | isPrime n = [n]
    | otherwise = pd n 2
                where
                    pd :: Int -> Int -> [Int]
                    pd n c
                        | isPrime c && (mod n c == 0) = (c : (pd n (c + 1)))
                        | 2 * c > n = []
                        | otherwise = pd n (c + 1)

