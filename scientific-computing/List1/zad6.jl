
# x - arg funkcji
# func to funkcja to wyrazenie funkcji f(x) lub g(x)
# arr to tablica wyników
function calc_function(x, func, arr)
    for i in -1:-1:-200
        value = func(x^(i))
        push!(arr, value)
    end
end

function calc_f(x)
    return sqrt(x^2 + 1) -1
end

function calc_g(x)
    return x^2 / (sqrt(x^2 + 1) + 1)
end

arr1_f = Float64[]
calc_function(8.0, calc_f, arr1_f)
println(arr1_f)
arr2_g = Float64[]
calc_function(8.0, calc_g, arr2_g)
println(arr2_g)