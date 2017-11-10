myFoldl :: (a -> b -> a) -> a -> [b] -> a
myFoldl _ x0 [] = x0
myFoldl f x0 (x : xs) = myFoldl f (f x0 x) xs

myFoldr :: (a -> b -> b) -> b -> [a] -> b
myFoldr _ x0 [] = x0
myFoldr f x0 (x : xs) = f x (myFoldr f x0 xs) 

myIterate :: (a -> a) -> a -> [a]
myIterate f x = x : (myIterate f $ f x)

myUntil :: (a -> Bool) -> (a -> a) -> a -> a
myUntil fc fa a
    | fc $ a = a
    | otherwise = myUntil fc fa $ fa a

myMap :: (a -> b) -> [a] -> [b]
myMap f xs = foldr (\a bs -> f a : bs) [] xs

myFilter :: (a -> Bool) -> [a] ->[a]
myFilter f xs = foldr (\a bs -> if (f a) then a : bs else bs) [] xs

myAll :: (a -> Bool) -> [a] -> Bool
--myAll f xs = foldl (\b a -> b && (f a)) True xs
myAll f xs = foldr ((&&) . f) True xs

myAny :: (a -> Bool) -> [a] -> Bool
--myAny f xs = foldl (\b a -> b || (f a)) False xs
myAny f xs = foldr ((||) . f) False xs

myZip :: [a] -> [b] -> [(a,b)]
myZip [] ys = []
myZip xs [] = []
myZip (x : xs) (y : ys) = (x,y) : myZip xs ys

myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith f as bs =  myMap (\a -> f (fst a) (snd a)) (zip as bs)
