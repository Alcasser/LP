--Data constructor of a Flower
type Label = String
data Flower = Flower Label [Double] deriving(Show)

getLabelF :: Flower -> Label
getLabelF (Flower l _) = l

--Data constructor of a distance between two observations and the corresponding Label
data Dist = Dist Label Double deriving(Show)

getLabelD :: Dist -> Label
getLabelD (Dist l _) = l

-- Instances of class types Eq and Ord in order to sort distances
instance Eq Dist where
    (==) (Dist _ d1) (Dist _ d2) = d1 == d2

instance Ord Dist where
    compare (Dist _ d1) (Dist _ d2) = compare d1 d2

    
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

{--
Helper functions to calculate distance between observations,
vote and perform the evalutaion
--}

{--
Distance functions
--}

--Function to calculate the Euclidean distance between two observations
euclideanDist :: Flower -> Flower -> Double
euclideanDist (Flower _ as) (Flower _ bs) = sqrt $ sum $ map (^2) (zipWith (-) as bs)

--Function to calculate the Manhattan distance between two observations
manhattanDist :: Flower -> Flower -> Double
manhattanDist (Flower _ as) (Flower _ bs) = sum $ map abs (zipWith (-) as bs)

--Function to calculate distances with the training dataset given a flower and a distance calculation function
--An array of Distances containing the label of each flower and the corresponding distance with newFlower is created
calcDists :: (Flower -> Flower -> Double) -> [Flower] -> Flower -> [Dist]
calcDists df flowers newFlower = map calcDistf flowers
    where
        calcDistf = \flower -> Dist (getLabelF flower) (df newFlower flower)

{--
Voting functions
--}

--Function to perform a basic vote. Labels are sorted and grouped in order to obtain the bigger group.
basicVote :: [Dist] -> Label
basicVote ds = head $ head $ filter ((freq ==) . length) groups
        where
            groups = group $ qsort (map getLabelD ds)
            freq = maximum $ map length groups 

--Function to perform a weighted votation. 
--Based on https://stats.stackexchange.com/questions/43388/different-use-of-neighbors-in-knn-classification-algorithm

--Function to get all the different classes or labels
allLabels :: [Dist] -> [Label]
allLabels ds = foldl (\(x : xs) new  -> if x /= new then new : (x : xs) else (x : xs)) [head sorted] (tail sorted)
        where
            sorted = qsort $ map getLabelD ds

--Funtion to calculate the average distance of one concrete Label
classDistanceAverage :: [Dist] -> Label -> Double
classDistanceAverage ds l = (foldl (\acc (Dist _ d) -> acc + d) 0 labelDs) / (fromIntegral $ length labelDs)
        where
            labelDs = filter ( (== l) . getLabelD) ds


--Function to calculate the score that obtains a Label.
score :: [Dist] -> [Label] -> Label -> Double
score ds differentLabels l  = 1 - ((classDistanceAverage ds l) / (classDistancesSum ds differentLabels))
        where
            classDistancesSum ds differentLabels = sum $ map (classDistanceAverage ds) (differentLabels)

--Function to make a weighted votation.
--The different labels of the distance structures are obtained here and passed to the other functions which need them.
weightedVote :: [Dist] -> Label
weightedVote distances = fst $ foldl (\new minTupl -> if (snd new) > (snd minTupl) then new else minTupl) (head scoretuples) (tail scoretuples)
        where
            scoretuples = map (\label -> (label, score distances diffLabels label)) diffLabels
            diffLabels = allLabels distances


{--
Evaluation functions
--}

--Function to evaluate the accuracy of the classification
accuracyEv :: [Label] -> [Label] -> Double
accuracyEv predLabels testLabels = (fromIntegral $ length $ filter id $ zipWith (==) predLabels testLabels) / (fromIntegral $ length testLabels)

--Function to evaluate the error of the classication
errorEv ::[Label] -> [Label] -> Double
errorEv predLabels testLabels = (fromIntegral $ length $ filter not . id $ zipWith (==) predLabels testLabels) / (fromIntegral $ length testLabels)

--Function to evaluate a classification using a list of functions of evaluation
evaluation :: [Label] -> [Label] -> [[Label] -> [Label] -> Double] -> [Double]
evaluation predLabels testLabels fs = [f predLabels testLabels | f <- fs]


{--
KNN
--}

--Function kNN to classify a new flower
kNN :: [Flower] -> (Flower -> Flower -> Double) -> ([Dist] -> Label) -> Int -> (Flower -> Label)
kNN flowers df vf k = vf . (take k) . qsort . (calcDists df flowers)


{--
Helper functions to parse data.
--}

--Function to split a string line sepparated by a given char in words 
mySplitOn :: Char -> String -> [String]
mySplitOn c t = foldr proc [] t
        where
            proc :: Char -> [String] -> [String]
            proc ch [] = if ch == c then [] else [[ch]] 
            proc ch (x : xs) 
                | c == ch   = ([] : x : xs)
                | otherwise = ((ch : x) : xs)

--Function to create a flower given a string line containing this flower data (init last finfo to delete \r)
parseFlower :: String -> Flower
parseFlower flower = Flower (init (last finfo)) (map read $ init finfo)
        where
            finfo = mySplitOn ',' flower

--Function to create a data structure of Flowers
parseFile :: String -> [Flower]
parseFile strOfFlowers = map parseFlower (lines strOfFlowers)


{--
Other helper functions used in main
--}

--Function to perform the Knn to all the flowers in the testing dataset
performKnn :: [Flower] -> [Flower] -> (Flower -> Flower -> Double) -> ([Dist] -> Label) -> Int -> [Label]
performKnn fsTrain fsTest distF voteF k = map (kNN fsTrain distF voteF k) fsTest

--Function to obtain the labels of every flower
getLabels :: [Flower] -> [Label]
getLabels fs = map getLabelF fs


--Main program execution
main :: IO()
main = do
    learningFlowers <- readFile "./iris.train.csv" 
    testingFlowers <- readFile "./iris.test.csv"
    let parsedLearningFlowers = parseFile learningFlowers
    let parsedTestingFlowers = parseFile testingFlowers
    let predLabs = performKnn parsedLearningFlowers parsedTestingFlowers euclideanDist basicVote 10
    let realLabs = getLabels parsedTestingFlowers
    putStrLn "Classified as: "
    mapM_ print predLabs
    putStrLn "Real labels: "
    mapM_ print realLabs
    putStr "Accuracy: "
    print $ evaluation predLabs realLabs [accuracyEv, errorEv]
