class FieldSolver:
    def __init__(self, order):
        self.order = order

    def convert_to_field_element(self, abnormal_number):
        return abnormal_number % self.order

    def add(self, summand1, summand2):
        return (summand1 + summand2) % self.order

    def subtract(self, minuend, subtrahend):
        return (minuend - subtrahend) % self.order

    def multiply(self, factor1, factor2):
        return (factor1 * factor2) % self.order

    def opposite(self, number):
        return (-number) % self.order
    
    def extended_gcd(self, a, b):
        x0, x1, y0, y1 = 1, 0, 0, 1

        while b != 0:
            q = a // b
            temp = b
            b = a % b
            a = temp
            next_x = x0 - q * x1
            next_y = y0 - q * y1
            x0, y0, x1, y1 = x1, y1, next_x, next_y

        return a, x0, y0
    
    def inverse(self, number):
        d, x, y = self.extended_gcd(number, self.order)
        if d == 1:
            return (x % self.order + self.order) % self.order
        return None
    
    def divide(self, dividend, divisor):
        divisor_inverse = self.inverse(divisor)
        if divisor_inverse is not None:
            return self.multiply(dividend, divisor_inverse)
        return None
    
    def power(self, base, exponent):
        result = 1

        while exponent > 0:
            if exponent % 2 == 1:
                result *= base
                result %= self.order

            exponent //= 2
            base *= base
            base %= self.order

        return result