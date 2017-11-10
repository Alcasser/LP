myLength :: [Int] -> Int
myLength xs = foldl (+) 0 $ map (const 1) xs

eql :: [Int] -> [Int] -> Bool
eql xs ys = (myLength xs == myLength ys) && (and (zipWith (==) xs ys))

prod :: [Int] -> Int
prod xs = foldl (*) 1 xs

prodOfEvens :: [Int] -> Int
prodOfEvens xs = prod $ filter even xs

powersOf2 :: [Int]
powersOf2 = iterate (*2) 1

scalarProduct :: [Float] -> [Float] -> Float
scalarProduct xs ys = foldl (+) 0 $ zipWith (*) xs ys
