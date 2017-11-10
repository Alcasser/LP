ones :: [Integer]
ones = 1 : ones

nats :: [Integer]
nats = 0 : map (+1) nats

factorials :: [Integer]
factorials = scanl (*) 1 $ tail nats


ints :: [Integer]
ints = 0 : 1 : (g ints)
        where
            g = \(x : xs) -> [x - 1, (head xs) + 1] ++ (g  (tail xs))

triangulars :: [Integer]
triangulars = map g nats
        where
            g = \x -> div (x * (x + 1)) 2

fibs :: [Integer]
fibs = 0 : scanl (+) 1 fibs

primes :: [Integer]
primes = primes' (tail $ tail nats)
primes' (p : ps) = p : (primes' $ filter ((/= 0) . (`mod`p))  ps)

lookNsay :: [Integer]
lookNsay  = 1 : g lookNsay
            where  
                g = \(x : xs) -> x : lookNsay


gfd :: Integer -> Integer
gfd n
    | n <= 9 = n
    | otherwise = gfd $ n `div` 10

--hammings :: [Integer]
--hammings = [(x * y) * z | x <- (iterate (2^) nats), y <- (iterate (2^) nats), z <- (iterate (2^) nats)]


zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys

--filter ((==0) . (mod $ head primes)