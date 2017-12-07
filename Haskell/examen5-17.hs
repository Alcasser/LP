shuffleOnce :: [a] -> [a]
shuffleOnce [] = []
shuffleOnce xs
    | mod l 2 == 0 = conc zipit
    | otherwise    = init $ conc zipit
    where
        conc = foldr (\p list -> fst p : snd p : list) []
        zipit = zip (part xs (div l 2)) xs
        l = length xs

part :: [a] -> Int -> [a]
part xs 0 = xs
part (x : xs) n = part xs (n - 1)

shuffleBack :: Eq a => [a] -> Int
shuffleBack xs = howm 0 xs (shuffleOnce xs) + 1
        where
            howm :: Eq a => Int -> [a] -> [a] -> Int
            howm c rs ss
                | rs == ss  = c
                | otherwise = howm (c + 1) rs (shuffleOnce ss)