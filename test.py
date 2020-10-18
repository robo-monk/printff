def get_digit(number, n):
    dec = number / 10**n
    if dec == 0: return -1
    return dec  % 10


print(get_digit(1020, 2))

