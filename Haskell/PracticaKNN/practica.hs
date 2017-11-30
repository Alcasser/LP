{--
TODO:
-Preguntar sobre la accuracy
-Preguntar sobre como hacer la version ponderada
-Repasar codigo
-
--}

import System.IO
import Data.List.Split -- Using it to comma separate words in each observation

--Data constructor of a Flower
type Label = String
data Flower = Flower Label [Double] deriving(Show)

getLabelF :: Flower -> Label
getLabelF (Flower l _) = l

--Data constructor of a distance between two observations and the corresponding Label
data Dist = Dist Label Double deriving(Show)

getLabelD :: Dist -> Label
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

instance Eq Dist where
    (==) (Dist _ d1) (Dist _ d2) = d1 == d2

instance Ord Dist where
    compare (Dist _ d1) (Dist _ d2) = compare d1 d2

--Function to calculate the Euclidean distance between two observations
euclideanDist :: Flower -> Flower -> Double
euclideanDist (Flower _ as) (Flower _ bs) = sqrt $ sum $ map (^2) (zipWith (-) as bs)

--Function to calculate the Manhattan distance between two observations
manhattanDist :: Flower -> Flower -> Double
manhattanDist (Flower _ as) (Flower _ bs) = sum $ map abs (zipWith (-) as bs)

--Function to calculate distances with the training dataset given a flower and a distance calculation function
calcDists :: (Flower -> Flower -> Double) -> [Flower] -> Flower -> [Dist]
calcDists df flowers newFlower = map calcDistf flowers
    where
        calcDistf = \flower -> Dist (getLabelF flower) (df newFlower flower)

--Function to perform a basic vote
basicVote :: [Dist] -> Label
basicVote ds = head $ head $ filter ((freq ==) . length) groups
        where
            groups = group $ qsort (map getLabelD ds)
            freq = maxa $ map length groups 

--Function to perform a weighted votation
--weightedVote :: [Dist] -> Label
--weightedVote ds = map \(Dist _ d) ds

--Function to evaluate the accuracy of the classification
accuracyEv :: [Label] -> [Label] -> Double
accuracyEv predLabels testLabels = (fromIntegral $ length $ filter id $ zipWith (==) predLabels testLabels) / (fromIntegral $ length testLabels)

--Function to evaluate the error of the classication
errorEv ::[Label] -> [Label] -> Double
errorEv predLabels testLabels = (fromIntegral $ length $ filter not . id $ zipWith (==) predLabels testLabels) / (fromIntegral $ length testLabels)


--Function kNN to classify a new flower
kNN :: [Flower] -> (Flower -> Flower -> Double) -> ([Dist] -> Label) -> Int -> (Flower -> Label)
kNN flowers df vf k = vf . (take k) . qsort . (calcDists df flowers)

--Function to evaluate a classification using a list of functions of evaluation
evaluation :: [Label] -> [Label] -> [[Label] -> [Label] -> Double] -> [Double]
evaluation predLabels testLabels fs = [f predLabels testLabels | f <- fs]


{--
Helper functions to parse data.
Using System.IO to read training and testing CSV files.
--}

--Function to create a flower given a string line containing this flower data
parseFlower :: String -> Flower
parseFlower flower = Flower (last finfo) (map read $ init finfo)
        where
            finfo = splitOn "," flower

--Function to create a data structure of Flowers
parseI :: String -> [Flower]
parseI strOfFlowers = map parseFlower (lines strOfFlowers)

performKnn :: [Flower] -> [Flower] -> [Label]
performKnn fsTrain fsTest = map (kNN fsTrain euclideanDist basicVote 5) fsTest

getLabels :: [Flower] -> [Label]
getLabels fs = map getLabelF fs

--Main program execution
main :: IO()
main = do
    handleLearning <- openFile "./iris.train.csv" ReadMode
    handleTesting <- openFile "./iris.test.csv" ReadMode
    learningFlowers <- hGetContents handleLearning
    testingFlowers <- hGetContents handleTesting
    let predLabs = performKnn (parseI learningFlowers) (parseI testingFlowers)
    let realLabs = getLabels (parseI testingFlowers)
    putStrLn "Classified as: "
    mapM_ print predLabs
    putStrLn "Real labels: "
    mapM_ print realLabs
    putStr "Accuracy: "
    print $ evaluation predLabs realLabs [accuracyEv, errorEv]
