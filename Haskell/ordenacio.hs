insert :: [Int] -> Int -> [Int]
insert [] x = [x]
insert (x : xs) n
    | n <= x = n : (x : xs)
    | otherwise = x : (insert xs n)

isort :: [Int] -> [Int]
isort [] = []
isort [x] = [x]
isort (x : xs)
    | tail xs  == [] && x >= head xs = [head xs, x]
    | otherwise = insert (isort xs) x

remove :: [Int] -> Int -> [Int]
remove [] x = []
remove (x : xs) n
    | x == n = xs
    | otherwise = x : (remove xs n)

ssort :: [Int] -> [Int]
ssort [] = []
ssort [x] = [x]
ssort xs = (lemin) : ssort (remove xs (lemin))
    where
        lemin = mini xs

mini :: [Int] -> Int
mini [x] = x
mini (x : xs)
    | x < m = x
    | otherwise = m
        where
            m = mini xs

merge :: [Int] -> [Int] -> [Int]
merge [] [] = []
merge xs [] = xs
merge [] xs = xs
merge (x : xs) (y : ys)
    | x <= y = x : (merge xs (y : ys))
    | otherwise = y : (merge (x : xs) ys)

myLength :: [Int] -> Int
myLength [] = 0
myLength (_ : xs) = 1 + myLength xs

msort :: [Int] -> [Int]
msort [] = []
msort xs = merge (msort left) (msort right)
    where
        left = take (div len 2) xs
        right = drop (div len 2) xs
        len = myLength xs

qsort :: [Int] -> [Int]
qsort [] = []
qsort [x] = [x]
qsort (x : xs) = qsort(lt) ++ [x] ++ qsort(gt)
    where
        lt = filtra (<= x) xs
        gt = filtra (> x) xs

filtra :: (Int -> Bool) -> [Int] -> [Int]
filtra p [] = []
filtra p (x : xs) 
    | p x = x : (filtra p xs)
    | otherwise = filtra p xs


genQsort :: (Ord a) => [a] -> [a]
genQsort [] = []
genQsort [x] = [x]
genQsort (x : xs) = genQsort(lt) ++ [x] ++ genQsort(gt)
    where
        lt = genFiltra (<= x) xs
        gt = genFiltra (> x) xs

genFiltra :: (a -> Bool) -> [a] -> [a]
genFiltra p [] = []
genFiltra p (x : xs) 
    | p x = x : (genFiltra p xs)
    | otherwise = genFiltra p xs
