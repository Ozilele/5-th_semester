include("./Functions.jl")
using .Functions

e = Base.MathConstants.e

function f1(x)
    return abs(x)
end

function f2(x)
    return 1 / (1 + x^2)
end

Functions.rysujNnfx(f1, -1.0, 1.0, 15)
# Functions.rysujNnfx(f1, -1.0, 1.0, 10)
# Functions.rysujNnfx(f1, -1.0, 1.0, 5)
# Functions.rysujNnfx(f2, -5.0, 5.0, 5)
# Functions.rysujNnfx(f2, -5.0, 5.0, 10)
# Functions.rysujNnfx(f2, -5.0, 5.0, 15)