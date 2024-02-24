
function calc_forwards(T, vecX, vecY, n)
    sum = one(T) - 1
    for i in 1:n 
        sum += vecX[i] * vecY[i]
    end
    return sum
end

# x = Vector{Float32}([2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995])
# y = Vector{Float32}([1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])
x = Vector{Float64}([2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995])
y = Vector{Float64}([1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049])

# Implementation of algorithm "backwards"
function calc_backwards(T, vecX, vecY, n)
    sum = one(T) - 1
    curr = n
    while curr >= 1
        sum += vecX[curr] * vecY[curr]
        if curr - 1 >= 1
            curr -= 1
        else
            break
        end
    end
    return sum
end

# Implementation of algorithm "descending"
function calc_descending(T, vecX, vecY) 
    sum_positive = one(T) - 1
    sum_negative = one(T) - 1
    sum = one(T) - 1
    tmp_positive = T[]
    tmp_negative = T[]
    if length(vecX) == length(vecY)
        for (i, j) in zip(vecX, vecY)
            if i * j > 0
                push!(tmp_positive, i * j)
            else 
                push!(tmp_negative, i * j)
            end
        end
        sort!(tmp_positive, rev = true)
        sort!(tmp_negative)
        for i in tmp_positive
            sum_positive += i
        end 
        for j in tmp_negative 
            sum_negative += j
        end
        sum = sum_positive + sum_negative
    else
        println("Wektory nie są prawidłowe")
    end
end

# Implementation of algorithm ascending
function calc_ascending(T, vecX, vecY)
    sum_positive = one(T) - 1
    sum_negative = one(T) - 1
    sum = one(T) - 1
    tmp_positive = T[]
    tmp_negative = T[]
    if length(vecX) == length(vecY)
        for (i, j) in zip(vecX, vecY)
            if i * j > 0
                push!(tmp_positive, i * j)
            else 
                push!(tmp_negative, i * j)
            end
        end
        sort!(tmp_positive)
        sort!(tmp_negative, rev = true)
        for i in tmp_positive
            sum_positive += i
        end 
        for j in tmp_negative
            sum_negative += j 
        end
        sum = sum_positive + sum_negative
    end
end

# sum_float_32 = calc_forwards(Float32, x, y, 5)
# sum_backward_32 = calc_backwards(Float32, x, y, 5)
# sum_float_64 = calc_forwards(Float64, x, y, 5)
# sum_backward_64 = calc_backwards(Float64, x, y, 5)

# sum_descending_64 = calc_descending(Float64, x, y)
# sum_descending = calc_descending(Float32, x, y)
# sum_descending = calc_descending(Float64, x, y)

# sum_ascending = calc_ascending(Float32, x, y)
# sum_ascending = calc_ascending(Float64, x, y)