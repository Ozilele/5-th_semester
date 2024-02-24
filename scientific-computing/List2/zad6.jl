
function calc_equation(x, c, i)
    if i == 41
        return
    end
    next_x = x^2 + c
    println("$i & $next_x")
    return calc_equation(next_x, c, i + 1)
end

c = -1.0
x_0 = 0.75
i = 1.0
calc_equation(x_0, c, i)