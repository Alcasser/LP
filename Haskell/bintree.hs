data Tree a = Node a (Tree a) (Tree a) | Empty deriving (Show)

t7 = Node 7 Empty Empty
t6 = Node 6 Empty Empty
t5 = Node 5 Empty Empty
t4 = Node 4 Empty Empty
t3 = Node 3 t6 t7
t2 = Node 2 t4 t5
t1 = Node 1 t2 t3
t1' = Node 1 t3 t2

size :: Tree a -> Int
size Empty = 0
size (Node n esq dre) = 1 + (size esq) + (size dre)

height :: Tree a -> Int
height Empty = 0
height (Node n esq dre) = 1 + max (height esq) (height dre) 
            
equal :: Eq a => Tree a -> Tree a -> Bool
equal Empty Empty = True
equal Empty a = False
equal a Empty = False
equal (Node n1 e1 d1) (Node n2 e2 d2) = (n1 == n2) && (equal e1 e2) && (equal d1 d2) 

isomorphic :: Eq a =>  Tree a -> Tree a -> Bool
isomorphic Empty Empty = True
isomorphic Empty a = False
isomorphic a Empty = False
isomorphic (Node n1 e1 d1) (Node n2 e2 d2) =
     (n1 == n2) && (isomorphic e1 e2 || isomorphic e1 d2 || isomorphic d1 e2 || isomorphic d1 d2)
     
preOrder :: Tree a -> [a]
preOrder Empty = []
preOrder (Node a esq dre) = a : (preOrder esq) ++ (preOrder dre)

postOrder :: Tree a -> [a]
postOrder Empty = []
postOrder (Node a esq dre) = (postOrder esq) ++ (postOrder dre) ++ [a]

inOrder :: Tree a -> [a]
inOrder Empty = []
inOrder (Node a esq dre) = (inOrder esq) ++ (a : inOrder dre)

bfs :: Tree a -> [a]
bfs a = bfs' [a]
bfs' :: [Tree a] -> [a]
bfs' [] = []
bfs' (Empty : xs) = bfs' xs
bfs' ((Node a esq dre) : xs) = a : bfs' (xs ++ [esq, dre]) 

build :: Eq a => [a] -> [a] -> Tree a
build [] [] = Empty
build [x1, y1, z1] [x2, y2, z2] = Node y2 (Node x2 Empty Empty) (Node z2 Empty Empty)
build (x : xs) ys = Node x (build preLeft inLeft) (build preRight inRight)
    where
        inLeft = takeWhile (/= x) ys
        len = length inLeft
        preLeft = take len xs
        inRight = drop (len + 1) ys
        preRight = drop (len) xs