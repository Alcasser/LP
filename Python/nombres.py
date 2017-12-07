def absValue(x):
    if x < 0:
        return -x
    else:
        return x


def power(x, p):
    if p == 0:
        return 1
    elif p % 2 == 0:
        return power(x, p//2) * power(x, p//2)
    else:
        return x * power(x, p//2) * power(x, p//2)


def hasDivisors(x, c):
    if c * c > x:
        return False
    elif x % c == 0:
        return True
    else:
        return hasDivisors(x, c + 1)


def isPrime(x):
    if x == 0 or x == 1:
        return False
    else:
        return not hasDivisors(x, 2)


def slowFib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return slowFib(n - 1) + slowFib(n - 2)


def quickFibAux(n):
    if n == 0:
        return (0, 0)
    elif n == 1:
        return (0, 1)
    else:
        q = quickFibAux(n-1)
        return q[1], q[0] + q[1]


def quickFib(n):
    return quickFibAux(n)[1]
