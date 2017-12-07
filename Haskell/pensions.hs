data Avi = Avi {
    nom :: [Char],
    edat :: Int,
    despeses :: [Int]
} deriving (Show)

avis = [ Avi { nom = "Joan", edat = 68, despeses = [640, 589, 573]}, Avi { nom = "Pepa", edat = 69, despeses = [710,550,570,698,645,512]}, Avi { nom = "Anna", edat = 72, despeses = [530,534]}, Avi { nom = "Pep", edat = 75, despeses = [770,645,630,650,590,481,602]} ]


promigDespeses :: Avi -> Int
promigDespeses a = round $ (fromIntegral (sum (despeses a))) / (fromIntegral (length (despeses a)))

edatsExtremes :: [Avi] -> (Int, Int)
edatsExtremes (a : as) = foldl maxmin (ed, ed) as
    where
        maxmin = \pm a -> (min (fst pm) (edat a), max (snd pm) (edat a))
        ed = edat a

sumaPromig :: [Avi] -> Int
sumaPromig avis = foldl (\ac a -> ac + (promigDespeses a)) 0 avis

maximPromig :: [Avi] -> Int
maximPromig (a : as) = foldl (\mp avi -> max (promigDespeses avi) mp) (promigDespeses a) as

despesaPromigSuperior :: [Avi] -> Int -> ([Char], Int)
despesaPromigSuperior [] _ = ("",0)
despesaPromigSuperior (a : as) d
    | promigDespeses a > d = (nom a, edat a)
    | otherwise            = despesaPromigSuperior as d