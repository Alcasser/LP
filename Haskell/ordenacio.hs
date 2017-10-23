insert :: [Int] -> Int -> [Int]
insert [] x = [x]
insert (x : xs) n = if x > (xs !! 0) then insertg
    | n <= x = n : x : xs
    | otherwise = x : (insert xs n)