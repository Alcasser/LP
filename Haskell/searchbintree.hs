data BST a = E | N a (BST a) (BST a) deriving (Show)

insert :: Ord a => BST a -> a -> BST a
insert E num = (N num E E)
insert (N n a1 a2) num
    | n == num = (N n a1 a2)
    | n < num  = (N n a1 $ insert a2 num)
    | otherwise = (N n (insert a1 num) a2)

create :: Ord a => [a] -> BST a
create [] = E
create (x : xs) = foldl (\t num -> insert t num) (insert E x) xs

removePlox :: Ord a => BST a -> BST a
removePlox (N n E E) = E
removePlox (N n E (N nd a1 a2)) = (N nd a1 a2)
removePlox (N n (N ni a1 a2) E) = (N ni a1 a2)
removePlox (N n a1 a2) = (N node a1 right)
    where
        node = minNode a2
        right = remove a2 node
        minNode (N nod E dre) = nod
        minNode (N _ esq dre) = minNode esq

remove :: Ord a => BST a -> a -> BST a
remove E _ = E
remove (N n a1 a2) num
    | n == num = removePlox (N n a1 a2)
    | n < num = (N n a1 $ remove a2 num)
    | otherwise = (N n (remove a1 num) a2)

contains :: Ord a => BST a -> (a -> Bool)
contains E _ = False
contains (N n a1 a2) nod  =  n == nod || (contains a1 nod) || (contains a2 nod)

getComp :: Ord a => BST a -> (a -> a -> a) -> a
getComp (N n E E) fc = n
getComp (N n a1 E) fc = fc n $ getComp a1 fc
getComp (N n E a2) fc = fc n $ getComp a2 fc
getComp (N n a1 a2) fc = foldl fc n [getComp a1 fc, getComp a2 fc]


getmax :: Ord a => BST a -> a
getmax t = getComp t max
       
getmin :: (Ord a) => BST a -> a
getmin t = getComp t min
 
size :: BST a -> Int
size E = 0
size (N n a1 E) = 1 + size a1
size (N n E a2) = 1 + size a2
size (N n a1 a2) = 1 + size a1 + size a2

elements :: BST a -> [a]
elements E = []
elements (N n a1 a2) = (elements a1) ++  (n : elements a2) 