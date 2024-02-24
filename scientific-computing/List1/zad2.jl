
function calc_macheps(T)
    value = one(T)
    value_3 = 3 * value
    value_4 = 4 * value
    macheps = value_3 * (value_4 / value_3 - value) - value
    return macheps
end

macheps_float_16 = calc_macheps(Float16)
macheps_float_32 = calc_macheps(Float32)
macheps_float_64 = calc_macheps(Float64)
println(macheps_float_16)
println(macheps_float_32)
println(macheps_float_64)