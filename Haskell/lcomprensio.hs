myMap :: (a -> b) -> [a] -> [b]
myMap f xs = [f x| x <- xs ]

myFilter :: (a -> Bool) -> [a] -> [a]
myFilter f xs = [x | x <- xs, f x]

myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith f xs ys = [ (uncurry f) p| p <- (zip xs ys)]

thingify :: [Int] -> [Int] -> [(Int, Int)]
thingify xs ys = [(x, y) | x <- xs, y <- ys, mod x y == 0]

factors :: Int -> [Int]
factors n = [x| x <- [1..n] , mod n x == 0]