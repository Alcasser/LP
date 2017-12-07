serieCollatz :: Integer -> [Integer]
serieCollatz n = n : next n
    where
        next n
            | n == 1       = []
            | mod n 2 == 0 = serieCollatz $ div n 2
            | otherwise    = serieCollatz $ n * 3 + 1

collatzMesLlarga :: Integer -> Integer 
collatzMesLlarga n = maxLength n
        where
            maxLength :: Integer -> Integer
            maxLength 1 = 1
            maxLength n = max (fromIntegral (length (serieCollatz n))) $ maxLength (n - 1)

representantsCollatz :: [Integer] -> [Integer]
representantsCollatz xs = map snd $ representantsCollatz' xs

representantsCollatz' :: [Integer] -> [(Integer, Integer)]
representantsCollatz' xs = map calc xs
        where
            calc x = (head ser, fromIntegral $ length ser)
                where
                    ser = serieCollatz x