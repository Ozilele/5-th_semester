
function machine_epsilon(T)::T
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

# Funkcja do znalezienia najmniejszej liczby spełniającej zadane równanie
# a - początek przedziału
# b - koniec przedziału
function findNumber_1(T, a, b)
    curr_x = a
    while curr_x != b
        curr_x += machine_epsilon(Float64)
        reverse_x = 1 / curr_x
        if (curr_x * reverse_x) != 1
            return curr_x
        end
    end
    println("The end of function")
end

# Alternatywna funkcja z wykorzystaniem nextfloat()
function findNumber_2(T, a, b)
    curr_x = a
    while curr_x != b
        curr_x = nextfloat(curr_x)
        reverse_x = 1 / curr_x
        if (curr_x * reverse_x) != 1
            return curr_x
        end
    end
    println("The end of function")
end

the_smallest_1 = findNumber_1(Float64, 1.0, 2.0) 
the_smallest_2 = findNumber_2(Float64, 1.0, 2.0) 
println(the_smallest_1)
println(the_smallest_2)