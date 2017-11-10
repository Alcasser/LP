 countIf :: (Int -> Bool) -> [Int] -> Int
 --countIf f xs = foldl (\c x -> if (f x) then c + 1 else c) 0 xs
 countIf f  = foldr ((+) . g . f) 0  
        where
            g = \b -> if (b) then 1 else 0

