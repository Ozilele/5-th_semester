 
# T is the type of variable - Float16, Float32, etc.
function machine_epsilon(T) 
    value = one(T)
    epsilon = value
    while value + epsilon > value
        if value + (epsilon / 2) <= value
            break
        else
            epsilon /= 2
        end
    end
    return epsilon
end

function calc_eta(T)
    eta = one(T)
    while eta > 0 && eta / 2 > 0
        eta /= 2
    end
    return eta
end
# Po wyjściu z while max to inf / 2
function calc_max(T)
    max = one(T)
    while !isinf(max * 2)
        max *= 2
    end
    gap = max / 2
    while !isinf(max + gap) && gap >= one(T)
        max += gap
        gap /= 2
    end
    return max
end

eps_float_16 = machine_epsilon(Float16)
println(eps_float_16)
eps_float_32 = machine_epsilon(Float32)
println(eps_float_32)
eps_float_64 = machine_epsilon(Float64)
println(eps_float_64)

println(eps(Float16))
println(eps(Float32))
println(eps(Float64))
println("---------------")

eta_float_16 = calc_eta(Float16)
println(eta_float_16)
eta_float_32 = calc_eta(Float32)
println(eta_float_32)
eta_float_64 = calc_eta(Float64)
println(eta_float_64)

println(nextfloat(Float16(0.0)))
println(nextfloat(Float32(0.0)))
println(nextfloat(Float64(0.0)))
println("---------------")

max_float_16 = calc_max(Float16)
println(max_float_16)
max_float_32 = calc_max(Float32)
println(max_float_32)
max_float_64 = calc_max(Float64)
println(max_float_64)

println(floatmax(Float16))
println(floatmax(Float32))
println(floatmax(Float64))
println("--------------")