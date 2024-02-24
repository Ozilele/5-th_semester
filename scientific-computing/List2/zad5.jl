
function calc_population(p::Float64, r::Float64, i::Float64)
    next_p::Float64 = one(Float64) - 1
    if i == 41
        return
    end
    next_p = p + r * p * (1 - p)
    println("$i & $next_p")
    return calc_population(next_p, r, i + 1)
end

p0 = Float64(0.01)
r = Float64(3.0)
i = Float64(1.0)
calc_population(p0, r, i)

# p10 = Float32(0.722)
# i = Float32(11.0)
# calc_population(p10, r, i)
