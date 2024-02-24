
# Funkcja do sprawdzenia formatu 
# bias dla eksponenty Float64 jest 1023, mantysa ma 52 bity znaczące
function test(a :: Float64, b :: Float64, delta :: Float64)
    last = prevfloat(b) # największa liczba mniejsza od końca przedziału b
    cecha_first = SubString(bitstring(a), 2:12)
    cecha_last = SubString(bitstring(last), 2:12)
    # Sprawdzenie czy bity cech nie są równe, jeśli nie są to nie ma równego rozmieszczenia
    if cecha_first != cecha_last
        return false
    end
    println(cecha_first)
    wykladnik = parse(Int, cecha_first, base = 2)
    println(wykladnik)
    # cecha to zapis z biasem 1023 w przypadku Float64, zapis mantysy ma 52 miejsca 
    if ((2.0^(wykladnik - 1023))*2.0^(-52) != delta)
        return false
    end
    return true
end

check_0_5_1 = test(0.5, 1.0, 2^(-53))
check_1_2 = test(1.0, 2.0, 2^(-52))
check_2_4 = test(2.0, 4.0, 2^(-51))
println(check_1_2)
println(check_0_5_1)
println(check_2_4)

# Funkcja do sprawdzenia, czy w podanym przedziale liczby są porozmieszczane według wzoru:
# x = a + k * delta, gdzie 
# a to początek przedziału,
# delta to krok dla danego przedziału,
# k to liczby 1,2,...,2^(52)-1
function test_Interval(a, delta)::Bool
    tmp = a
    for k in 1:2^(52)-1
        x = a + k * delta
        if(bitstring(x) == bitstring(nextfloat(tmp)))
            tmp += delta
        else 
            return false
        end
    end
    return true
end
# check_first = test_Interval(0.5, 2^(-53))
# check_second = test_Interval(1.0, 2^(-52))
# check_third = test_Interval(2.0, 2^(-51))