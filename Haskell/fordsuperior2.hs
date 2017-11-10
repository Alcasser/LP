flatten :: [[Int]] -> [Int]
flatten xs = foldr (++) [] xs

myLength :: String -> Int
myLength xs = foldl (+) 0 $ map (const 1) xs

myReverse :: [Int] -> [Int]
myReverse xs = foldl (flip (:)) []  xs

countIn :: [[Int]] -> Int -> [Int]
countIn l x = map (myiLength . filter (== x)) l

myiLength :: [Int] -> Int
myiLength xs = foldl (+) 0 $ map (const 1) xs

firstWord :: String -> String
firstWord xs = takeWhile (/= ' ') . dropWhile (== ' ') $ xs