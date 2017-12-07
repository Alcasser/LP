add :: [Double] -> [Double] -> [Double]
add [] ys = ys
add xs [] = xs
add (x : xs) (y : ys) = (x + y) : add xs ys

mult :: [Double] -> [Double] -> [Double]
mult [] ys = take (length ys) (repeat 0)
mult (x : xs) ys = add (map (* x) ys) (0 : (mult xs ys))