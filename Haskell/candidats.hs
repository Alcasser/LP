import Data.List
import Data.Ord

ltVots = [("Joan Pere Jorbina Palau", 570::Int), ("Niceto Brunildo Fornells", 679::Int), ("Mariona Puig Peix", 701::Int), ("Adriana de Tor Quemada", 451::Int)]
ltIng = [("Mariona Puig Peix", 15456::Int), ("Arnau Osorio Lucas", 27654::Int), ("Arnau Brigat Pelfred", 18654::Int), ("Niceto Brunildo Fornells", 14567::Int)]

votsMinim :: [([Char], Int)] -> Int -> Bool
votsMinim candidats vm = any check candidats
    where
        check :: ([Char], Int) -> Bool
        check c = snd c <= vm

candidatMesVotat :: [([Char], Int)] -> [Char]
candidatMesVotat (c : cs) = fst $ foldl (\mxc c -> if (snd c) > (snd mxc) then c else mxc) c cs

votsIngressos :: [([Char], Int)] -> [([Char], Int)] -> [[Char]]
votsIngressos vs [] = map fst vs
votsIngressos vs (i : is) = votsIngressos (ingr i vs) is
        where
            ingr :: ([Char], Int) -> [([Char], Int)] -> [([Char], Int)]
            ingr _ [] = []
            ingr i (v : vs)
                | fst v == fst i = ingr i vs
                | otherwise      = v : (ingr i vs)


rics :: [([Char], Int)] -> [([Char], Int)] -> [[Char]]
rics cs is = map mrk $ take 3 $ reverse $ sortBy (comparing snd) is
            where
                mrk :: ([Char], Int) -> [Char]
                mrk r
                    | isin namer namecs = namer ++ "*"
                    | otherwise = namer
                        where
                            namer = fst r
                            namecs = map fst cs
                            isin :: String -> [String] -> Bool
                            isin nom [] = False
                            isin nom (n : ns)
                                | nom == n = True
                                | otherwise = isin nom ns

