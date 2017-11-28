import System.IO
import Data.List.Split -- Using it to comma separate words in each observation

--Data constructor of a Flower
type Label = String
data Flower a = Flower Label [a] deriving(Eq, Show)

getLabelF :: Flower a -> Label
getLabelF (Flower l _) = l

--Data constructor of a distance between two observations and the corresponding Label
data Dist a = Dist Label a deriving(Show)

getLabelD :: Dist a -> Label
getLabelD (Dist l _) = l


{--
Helper functions to sort and find maximum values
--}

--Quicksort algorithm
qsort :: Ord a => [a] -> [a]
qsort [] = []
qsort [x] = [x]
qsort (x : xs) = qsort(lt) ++ [x] ++ qsort(gt)
    where
        lt = filtra (<= x) xs
        gt = filtra (> x) xs

filtra :: Ord a => (a -> Bool) -> [a] -> [a]
filtra p [] = []
filtra p (x : xs) 
    | p x = x : (filtra p xs)
    | otherwise = filtra p xs

--Function to group adjacent equal elements
group :: Eq a => [a] -> [[a]]
group xs = foldr f [] xs
        where
            f x [] = [[x]]
            f x ((y : ys) : xs)
                | y == x = (x : y : ys) : xs
                | otherwise = [x] : (y : ys) : xs

--Function to calculate the maximum of an array
maxa :: [Int] -> Int
maxa xs = foldl (\b a -> if b >= a then b else a) 0 xs

{--
Helper functions to calculate distance between observations,
vote and perform the evalutaion
--}

instance Eq a => Eq (Dist a) where
    (==) (Dist _ d1) (Dist _ d2) = d1 == d2

instance (Eq a, Ord a) => Ord (Dist a) where
    compare (Dist _ d1) (Dist _ d2) = compare d1 d2

--Function to calculate the Euclidean distance between two observations
euclideanDist :: Floating a => Flower a -> Flower a -> a
euclideanDist (Flower _ as) (Flower _ bs) = sqrt $ sum $ map (^2) (zipWith (-) as bs)

--Function to calculate the Manhattan distance between two observations
manhattanDist :: Floating a => Flower a -> Flower a -> a
manhattanDist (Flower _ as) (Flower _ bs) = sum $ map abs (zipWith (-) as bs)

--Function to calculate distances with the testing dataset given a flower
calcDists :: Floating a => (Flower a -> Flower a -> a) -> [Flower a] -> Flower a -> [Dist a]
calcDists df flowers newFlower = map calcDistf flowers
    where
        calcDistf = \flower -> Dist (getLabelF flower) (df newFlower flower)

--Function to perform a basic vote
basicVote :: [Dist a] -> Label
basicVote ds = head $ head $ filter ((freq ==) . length) groups
        where
            groups = group $ qsort (map getLabelD ds)
            freq = maxa $ map length groups 

--Function kNN to classify a new flower
kNN :: (Ord a, Floating a) => [Flower a] -> (Flower a -> Flower a -> a) -> ([Dist a] -> Label) -> Int -> (Flower a -> Label)
kNN flowers df vf k = vf . (take k) . qsort . (calcDists df flowers)

{--
Helper functions to parse data.
Using System.IO to read training and testing CSV files.
--}

--Function to create a flower given a string line containing this flower data
parseFlower :: String -> Flower Double
parseFlower flower = Flower (last finfo) (map read $ init finfo)
        where
            finfo = splitOn "," flower

--Function to create a data structure of Flowers
parseI :: String -> [Flower Double]
parseI strOfFlowers = map parseFlower (lines strOfFlowers)

performKnn :: [Flower Double] -> [Flower Double] -> [Label]
performKnn fsTrain fsTest = map (kNN fsTrain euclideanDist basicVote 5) fsTest

--Main program execution
main :: IO()
main = do
    handleLearning <- openFile "./iris.train.csv" ReadMode
    handleTesting <- openFile "./iris.test.csv" ReadMode
    learningFlowers <- hGetContents handleLearning
    testingFlowers <- hGetContents handleTesting
    putStrLn $ show $ performKnn (parseI learningFlowers) (parseI testingFlowers)