fizzBuzz :: [Either Int String]
fizzBuzz = map pr [0..]
    where
        pr num
            | (mod num 3 == 0) && (mod num 5 == 0) = Right "FizzBuzz"
            | (mod num 3 == 0) = Right "Fizz"
            | (mod num 5 == 0) = Right "Buzz"
            | otherwise = Left num