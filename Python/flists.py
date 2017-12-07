from functools import reduce


def myLength(l):
    return reduce(lambda acc, x: acc + 1, l, 0)


def myMaximum(l):
    return reduce(lambda mx, new: new if new > mx else mx, l[1:], l[0])


def average(l):
    def acc(l, elem):
        l[0] += elem
        l[1] += 1
        return l
    res = reduce(acc, l, [0, 0])
    return res[0] / res[1]


def buildPalindrome(list):
    return list[::-1] + list


def remove(l1, l2):
    return [x for x in l1 if x not in l2]


def flatten(lista):
    def app(acc, elem):
        if isinstance(elem, list):
            return acc + flatten(elem)
        else:
            acc.append(elem)
            return acc
    return reduce(app, lista, [])


def oddsNevens(lista):
    def acc(t, elem):
        if elem % 2 == 0:
            t[1].append(elem)
        else:
            t[0].append(elem)
        return t
    return reduce(acc, lista, ([], []))


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


def primeDivisors(n):
    ret = list()
    for i in range(1, n + 1):
        if n % i == 0 and isPrime(i):
            ret.append(i)
    return ret
