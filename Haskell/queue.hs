data Queue a = Queue [a] [a]
     deriving (Show)

create :: Queue a
create = Queue [] []

push :: a -> Queue a -> Queue a
push e (Queue ls rs) = Queue ls (e : rs)

pop :: Queue a -> Queue a
pop (Queue [] []) = create
pop (Queue [] rs) = Queue (tail (reverse rs)) []
pop (Queue (_ : ls) rs) = Queue ls rs

top :: Queue a -> a
top (Queue [] rs) = last rs
top (Queue (l : _) _) = l

empty :: Queue a -> Bool
empty (Queue [] []) = True
empty (Queue ls rs) = False

instance Eq a => Eq (Queue a) where
    (==) (Queue ls1 rs1) (Queue ls2 rs2) = (ls1 ++ reverse rs1) == (ls2 ++ reverse rs2)