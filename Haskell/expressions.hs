data Expr = Val Int | Add Expr Expr | Sub Expr Expr | Mul Expr Expr | Div Expr Expr deriving(Eq, Show)

eval1 :: Expr -> Int
eval1 (Val n) = n
eval1 (Add e1 e2) = eval1 e1 + eval1 e2
eval1 (Sub e1 e2) = eval1 e1 - eval1 e2
eval1 (Mul e1 e2) = eval1 e1 * eval1 e2
eval1 (Div e1 e2) = eval1 e1 `div` eval1 e2

eval2 :: Expr -> Maybe Int
eval2 (Val n) = Just n
eval2 (Add e1 e2) = eval2' e1 e2 (+)
eval2 (Sub e1 e2) = eval2' e1 e2 (-)
eval2 (Mul e1 e2) = eval2' e1 e2 (*)
--eval2 (Div _ (Val 0)) = Nothing
eval2 (Div e1 e2)
    | eval2 e2 == (Just 0) = Nothing
    | otherwise = eval2' e1 e2 div

eval2' :: Expr -> Expr -> (Int -> Int -> Int) -> Maybe Int
eval2' e1 e2 op = do
    ex1 <- eval2 e1
    ex2 <- eval2 e2
    return $ op ex1 ex2

eval3 :: Expr -> Either String Int
eval3 (Val n) = Right n
eval3 (Add e1 e2) = eval3' e1 e2 (+)
eval3 (Sub e1 e2) = eval3' e1 e2 (-)
eval3 (Mul e1 e2) = eval3' e1 e2 (*)
eval3 (Div e1 e2)
    | eval3 e2 == (Right 0) = Left "div0"
    | otherwise = eval3' e1 e2 div

eval3' :: Expr -> Expr -> (Int -> Int -> Int) -> Either String Int
eval3' e1 e2 op = do
    ex1 <- eval3 e1
    ex2 <- eval3 e2
    return $ op ex1 ex2